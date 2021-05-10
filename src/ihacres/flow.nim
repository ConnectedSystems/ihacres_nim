import math
import defines
import strformat


proc convert_taus(tau: float, v: float): (float, float) =
    #[ Convert $\tau$ to $\alpha$ and $\beta$ ]#
    let alpha: float = exp(-1.0 / tau)
    let beta: float = v * (1.0 - alpha)

    return (alpha, beta)


proc calc_stores(tau: float, prev_store: float, v: float, e_rainfall: float): float =
    var alpha, beta, store: float

    (alpha, beta) = convert_taus(tau, v)
    store = (beta * e_rainfall) + alpha * prev_store

    return max(0.0, store)


# redo to allow `n` stores
proc calc_flows*(prev_quick: float, prev_slow: float, v_s: float, 
                 e_rainfall: float, area: float, tau_q: float, tau_s: float):
                 (float, float, float)
                 {.stdcall,exportc,dynlib.} =
    #[ Calculate quick and slow flow, and outflow using a Unit Hydrograph 
       composed of exponential components.

       Calculates flows for current time step based on previous 
       flows and current effective rainfall.

       Assumes components are in parallel.

       References
        ----------
        .. [1] https://wiki.ewater.org.au/display/SD45/IHACRES-CMD+-+SRG

        .. [2] Croke, B.F.W., Jakeman, A.J. 2004
                A catchment moisture deficit module for the IHACRES rainfall-runoff model, 
                Environmental Modelling & Software, 19(1), pp. 1–5. 
                doi: 10.1016/j.envsoft.2003.09.001

        .. [3] Croke, B.F.W., Jakeman, A.J. 2005
                Corrigendum to "A Catchment Moisture Deficit module for the IHACRES 
                rainfall-runoff model [Environ. Model. Softw. 19 (1) (2004) 1–5]"
                Environmental Modelling & Software, 20(7), p. 997.
                doi: 10.1016/j.envsoft.2004.11.004

       Parameters
       ----------
       prev_quick : previous quick flow in ML/day
       prev_slow  : previous slow flow in ML/day
       v_s        : proportional amount that goes to slow flow. $v_{s} <= 1.0$
       e_rainfall : effective rainfall for $t$
       tau_q      : Time constant, quick flow $\tau$ value
       tau_s      : Time constant slow flow $\tau$ value
                       Represents the time required for the quickflow and slowflow
                       responses to fall to $1/e$ of their initial values 
                       after an impulse of rainfall.

       Returns
       -------
       quickflow, slowflow, outflow in ML/day
    ]#
    let v_q: float = 1.0 - v_s  # proportional quick flow
    let areal_rainfall: float = e_rainfall * area
    var quick: float = calc_stores(tau_q, prev_quick, v_q, areal_rainfall)
    var slow: float = calc_stores(tau_s, prev_slow, v_s, areal_rainfall)
    var outflow: float = (quick + slow)

    return (quick, slow, outflow)


proc routing*(volume: float, storage_coef: float, inflow: float, flow: float, 
              irrig_ext: float, gw_exchange: float = 0.0):
              (float, float)
              {.stdcall,exportc,dynlib.} = 
    #[ Routing method 
        
        Parameters
        ----------
        volume       : representing catchment moisture deficit in mm
        storage_coef : storage factor
        inflow       : incoming streamflow (flow from previous node)
        flow         : flow for the node (local flow)
        irrig_ext    : volume of irrigation extraction in ML
        gw_exchange  : groundwater flux. Defaults to 0.0
        
        Returns
        -------
        volume and streamflow in ML/day
    ]#
    var threshold: float = volume + (inflow + flow + gw_exchange) - irrig_ext
    var new_vol: float  # new volume
    var c1, outflow: float
    if (threshold > 0.0):
        new_vol = 1.0 / (1.0 + storage_coef) * threshold
        c1 = exp(-storage_coef)
        outflow = (1.0 - c1) * threshold
    else:
        new_vol = threshold
        outflow = 0.0
    # End if

    return (new_vol, outflow)


proc calc_outflow*(flow: float, extractions: float): float {.stdcall,exportc,dynlib.} = 
    #[ Calculate streamflow of node taking into account extractions

        Parameters
        ----------
        flow        : unmodified sum of quickflow and slowflow in ML/day
        extractions : water extractions that occurred in ML/day
        
        Returns
        -------
        flow - extractions, minimum possible is 0.0
    ]#
    return max(0.0, flow - extractions)


proc calc_ft_flows*(prev_quick: float, prev_slow: float,
                    e_rain: float, recharge: float, 
                    area: float, a: float, b: float, 
                    loss: float = 0.0):
                    (float, float, float)
                    {.stdcall,exportc,dynlib.} =
    #[ Fortran port of flow calculation.
    
        Parameters
        ----------
        prev_quick : previous quickflow storage
        prev_slow  : previous slowflow storage
        e_rain     : effective rainfall in mm
        recharge   : recharge amount in mm
        area       : catchment area in km^2
        a          : quickflow storage coefficient, inverse of $tau_q$ such that $a == (1/tau_q)$
        b          : slowflow storage coefficient, inverse of $tau_s$ such that $b == (1/tau_s)$
        loss       : losses in mm depth
        
        Returns
        -------
        quick store, slow store, outflow
    ]#
    var a2: float = 0.5
    var quick_store, slow_store, outflow, c1: float

    var tmp_calc: float = max(0.0, prev_quick + (e_rain * area) - (a2*loss))
    if (tmp_calc > 0.0):
        c1 = exp(-a)
        quick_store = c1 * tmp_calc
        outflow = (1.0 - c1) * tmp_calc
    else:
        quick_store = tmp_calc
        outflow = 0.0

        # Modifiy a2 for outflow calculation
        # reminder: tmp_calc can be negative
        if loss > 0.0:
            a2 = max(0.0, min(1.0, tmp_calc))
        else:
            a2 = 0.0
    # End if

    assert outflow >= 0.0, fmt"Calculating quick store: Outflow cannot be negative: {outflow}"

    let b2: float = 1.0 - a2
    slow_store = prev_slow + (recharge * area) - (b2 * loss)
    if (slow_store > 0.0):
        c1 = exp(-b)
        outflow = outflow + (1.0 - c1) * slow_store
        slow_store = c1*slow_store
    # End if

    assert outflow >= 0.0, fmt"Calculating slow store: Outflow cannot be negative: {outflow}"

    return (quick_store, slow_store, outflow)


proc calc_ft_level*(outflow: float, level_params: ptr array[9, float]):float {.stdcall,exportc,dynlib.} =

    (p1, p2, p3, p4, p5, p6, p7, p8, CTF) := level_params
    
    var level: float
    level = exp(p1) * pow(outflow, p2) * 1.0 / (1.0 + pow(pow((outflow / p3), p4), (p5/p4)) * exp(p6 / (1.0+exp(-p7*p8)) * pow(outflow, p7)))
    level = max(level, 0.0)
    level = level + CTF  # add Cease to Flow (base height of stream in local datum)

    assert level >= 0.0, fmt"Stream level cannot be below 0.0, got {level}"

    return level
