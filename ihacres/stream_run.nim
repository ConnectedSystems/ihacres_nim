## Example functions for running a stream network.
import node
import flow
import climate
import cmd


proc run*(s_node: BilinearNode, rain: float, evap: float, inflow: float, ext: float, gw_exchange: float = 0.0):
     (float, float) =
    ## Run node to calculate outflow and update state.
    ##
    ## :Parameters:
    ##     - timestep    : time step
    ##     - rain        :  rainfall
    ##     - evap        : evapotranspiration
    ##     - extractions : irrigation and other water extractions
    ##     - gw_exchange : flux in ML - positive is contribution, negative is infiltration
    ##
    ## :Returns:
    ##    outflow from node, level

    # other extractions are ignored for stream nodes, so only extract irrigation ext.
    var
        mf: float
        e_rainfall: float
        recharge: float
        quick_store: float
        slow_store: float
        outflow: float
        vol: float

    var arr_len = s_node.storage.len() - 1
    let current_store = s_node.storage[arr_len]
    (mf, e_rainfall, recharge) = calc_ft_interim_cmd(current_store, rain, s_node.d,
                                                 s_node.d2, s_node.alpha)

    var et: float = calc_ET(s_node.e, evap, mf, s_node.f, s_node.d)
    var cmd: float = calc_cmd(current_store, rain, et, e_rainfall, recharge)

    s_node.inflow.add(inflow)
    (quick_store, slow_store, outflow) = calc_ft_flows(s_node.quickflow[arr_len], s_node.slowflow[arr_len],
                                                        e_rainfall, recharge, s_node.area,
                                                        s_node.a, s_node.b)

    (vol, outflow) = routing(cmd, s_node.storage_coef, inflow, outflow, ext, gw_exchange)

    var level: float = calc_ft_level(outflow, s_node.level_params)

    s_node.update_state(cmd, e_rainfall, et, quick_store, slow_store, outflow, level)

    return (outflow, level)


proc run_expuh*(s_node: ExpuhNode, rain, evap, inflow, ext: float, gw_exchange: float=0.0):
     (float, float) =
    ## Run node to calculate outflow and update state.
    ## 
    ## :Parameters:
    ##     - timestep: int, time step
    ##     - rain: float, rainfall
    ##     - evap: float, evapotranspiration
    ##     - extractions: float, irrigation and other water extractions
    ##     - gw_exchange: float, flux in ML - positive is contribution, negative is infiltration
    ## 
    ## :Returns:
    ##     outflow from node, level

    # other extractions are ignored for stream nodes, so only extract irrigation ext.
    var
        mf: float
        e_rainfall: float
        quick_store: float
        slow_store: float
        outflow: float
        vol: float
        recharge: float = 0.0

    var arr_len = s_node.storage.len() - 1
    let current_store = s_node.storage[arr_len]

    e_rainfall = calc_effective_rainfall(rain, current_store, s_node.d, s_node.d2)
    mf = calc_trig_interim_cmd(current_store, s_node.d, e_rainfall)

    var et: float = calc_ET(s_node.e, evap, mf, s_node.f, s_node.d)
    var cmd: float = calc_cmd(mf, rain, et, e_rainfall, recharge)

    s_node.inflow.add(inflow)

    (quick_store, slow_store, outflow) = calc_flows(s_node.quickflow[-1],
                                                    s_node.slowflow[-1],
                                                    s_node.v_s,
                                                    e_rainfall,
                                                    s_node.area,
                                                    s_node.tau_q,
                                                    s_node.tau_s)

    (vol, outflow) = routing(cmd, s_node.storage_coef, inflow, outflow, ext, gw_exchange)

    var level: float = calc_ft_level(outflow, s_node.level_params)

    s_node.update_state(cmd, e_rainfall, et, quick_store, slow_store, outflow, level)

    return (outflow, level)
