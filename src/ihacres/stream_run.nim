import sequtils

import ihacres/node
import ihacres/flow
import ihacres/climate
import ihacres/cmd


proc run*(s_node: StreamNode, rain: float, evap: float, inflow: float, ext: float, gw_exchange=0.0, loss=0.0): tuple =
    #[ Run node to calculate outflow and update state.
 
        Parameters
        ----------
        timestep: int, time step
        rain: float, rainfall
        evap: float, evapotranspiration
        extractions: float, irrigation and other water extractions
        gw_exchange: float, flux in ML - positive is contribution, negative is infiltration
        loss: float,
        
        Returns
        ----------
        float, outflow from node
    ]#

    # other extractions are ignored for stream nodes, so only extract irrigation ext.
    var
        mf: float64
        e_rainfall: float64
        recharge: float64
        quick_store: float64
        slow_store: float64
        outflow: float64

    var arr_len = s_node.storage.len() - 1
    let current_store = s_node.storage[arr_len]
    (mf, e_rainfall, recharge) = calc_ft_interim(current_store, rain, s_node.d,
                                                 s_node.d2, s_node.alpha)

    var et: float64 = calc_ET(s_node.e, evap, mf, s_node.f, s_node.d)
    var cmd: float64 = calc_cmd(current_store, rain, et, e_rainfall, recharge)

    s_node.inflow.add(inflow)
    var ret: array[3, float64] = [0.0, 0.0, 0.0]
    calc_ft_flows(ret.addr, s_node.quickflow[arr_len], s_node.slowflow[arr_len],
                                                                    e_rainfall, recharge, s_node.area,
                                                                    s_node.a, s_node.b, loss=loss)
    (quick_store, slow_store, outflow) = ret

    var cmd_ret: array[2, float64] = [0.0, 0.0]
    routing(cmd_ret.addr, cmd, s_node.storage_coef, inflow, outflow, ext, gw_exchange)
    (cmd, outflow) = cmd_ret

    var level: float64 = calc_ft_level(outflow, s_node.level_params)

    s_node.update_state(cmd, e_rainfall, et, quick_store, slow_store, outflow, level)

    return (outflow, level)
