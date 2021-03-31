import math
import defines
import strformat


proc calc_flow*(tau: float64, flow: float64, v: float64, e_rainfall: float64): float64 {.stdcall,exportc,dynlib.} = 
    #[ Common function to calculate quick and slow flows.
        
        Parameters
        ----------
        tau        : `tau` value for flow
        flow       : proportional quick or slow flow in ML/day
        v          : `v` parameter in the literature
        e_rainfall : effective rainfall in mm (`E` parameter in the literature)
            
        Returns
        -------
        float, adjusted quick or slow flow in ML/day
    ]#
    
    # convert from 'tau' and 'v' to 'alpha' and 'beta'
    let alpha: float64 = exp(-1.0 / tau)
    let beta: float64 = v * (1.0 - alpha)

    var flow: float64 = (-alpha * flow) + (1.0 - alpha) * (beta * e_rainfall)

    return flow



proc calc_flows*(prev_flows: (float64, float64), v_s: float64, 
                e_rainfall: float64, tau_q: float64, tau_s: float64):
                (float, float, float)
                {.stdcall,exportc,dynlib.} =
    #[ Calculate quick and slow flow, and outflow.
        Calculates flows for current time step based on previous 
        flows and current effective rainfall.
        
        Parameters
        ----------
        prev_flows : previous quick and slow flow in ML/day
        v_s        : proportional amount that goes to slow flow. v_s <= 1.0
        e_rainfall : current and previous effective rainfall
        taus       : Time constant, quick and slow flow tau variables.
                     Represent the time required for the quickflow and slowflow
                     responses to fall to :math:`1/e` of their initial values 
                     after an impulse of rainfall.
        
        Returns
        -------
        quickflow, slowflow, outflow in ML/day
    ]#

    let v_q: float64 = 1.0 - v_s  # proportional quick flow
    var prev_quick: float64 = prev_flows[0]
    var prev_slow: float64 = prev_flows[1]
    var quick:float64 = calc_flow(tau_q, prev_quick, v_q, e_rainfall)
    var slow: float64 = calc_flow(tau_s, prev_slow, v_s, e_rainfall)
    var outflow: float64 = (quick + slow)

    return (quick, slow, outflow)


proc routing*(volume: float64, storage_coef: float64, inflow: float64, flow: float64, 
              irrig_ext: float64, gw_exchange: float64 = 0.0):
              (float, float)
              {.stdcall,exportc,dynlib.} = 
    #[ Linear routing used to convert effective rainfall into streamflow 
        for a given time step.
        
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
        cmd in mm, and streamflow in ML/day
    ]#
    var threshold: float64 = volume + (inflow + flow + gw_exchange) - irrig_ext
    var n_vol: float64  # new volume
    var outflow: float64
    if (threshold > 0.0) and (threshold != 0.0):
        n_vol = 1.0 / (1.0 + storage_coef) * threshold
        outflow = storage_coef * volume
    else:
        n_vol = threshold
        outflow = 0.0
    # End if

    return (n_vol, outflow)


proc calc_outflow*(flow: float64, extractions: float64): float64 {.stdcall,exportc,dynlib.} = 
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


proc calc_ft_flows*(prev_quick: float64, prev_slow: float64,
                    e_rain: float64, recharge: float64, 
                    area: float64, a: float64, b: float64, 
                    loss: float64 = 0.0):
                    (float64, float64, float64)
                    {.stdcall,exportc,dynlib.} =
    #[ Fortran port of flow calculation.
    
        Parameters
        ----------
        prev_quick : previous quickflow storage
        prev_slow  : previous slowflow storage
        e_rain     : effective rainfall in mm
        recharge   : recharge amount in mm
        area       : catchment area in km^2
        a          : `a` factor controlling quickflow rate
        b          : `b` factor controlling slowflow rate
        loss       : losses in mm depth
        
        Returns
        -------
        quick store, slow store, outflow
    ]#
    var a2: float = 0.5
    var quick_store, slow_store, outflow: float

    var tmp_calc: float = prev_quick + (e_rain * area)
    var sub_calc: float = tmp_calc - (0.5 * loss)
    if (sub_calc > 0.0):
        quick_store = 1.0 / (1.0 + a) * sub_calc
        outflow = a * quick_store
    else:
        if loss > 0.0:
            a2 = max(0.0, min(1.0, (tmp_calc / loss)))
        else:
            a2 = 0.0

        quick_store = tmp_calc - (a2 * loss)
        outflow = 0.0
    # End if

    assert outflow >= 0.0, fmt"Calculating quick store: Outflow cannot be negative: {outflow}"

    let b2: float64 = 1.0 - a2
    tmp_calc = prev_slow + (recharge * area)
    slow_store = tmp_calc - (b2 * loss)
    if (slow_store > 0.0):
        slow_store = 1.0 / (1.0 + b) * slow_store
        outflow = outflow + b * slow_store
    # End if

    assert outflow >= 0.0, fmt"Calculating slow store: Outflow cannot be negative: {outflow}"

    return (quick_store, slow_store, outflow)


proc calc_ft_level*(outflow: float64, level_params: ptr array[9, float64]):float64 {.stdcall,exportc,dynlib.} =

    (p1, p2, p3, p4, p5, p6, p7, p8, CTF) := level_params
    
    var level: float64
    level = exp(p1) * pow(outflow, p2) * 1.0 / (1.0 + pow(pow((outflow / p3), p4), (p5/p4)) * exp(p6 / (1.0+exp(-p7*p8)) * pow(outflow, p7)))
    level = max(level, 0.0)
    level = level + CTF  # add Cease to Flow (base height of stream in local datum)

    assert level >= 0.0, fmt"Stream level cannot be below 0.0, got {level}"

    return level
