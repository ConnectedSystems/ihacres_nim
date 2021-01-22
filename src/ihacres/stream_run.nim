import sequtils

import ihacres/node
import ihacres/flow
import ihacres/climate
import ihacres/cmd

# stream_run

proc run*(s_node: StreamNode, rain: float, evap: float, inflow: float, ext: float, gw_exchange=0.0, loss=0.0): float =
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
    (quick_store, slow_store, outflow) = calc_ft_flows(s_node.quickflow[arr_len], s_node.slowflow[arr_len],
                                                                    e_rainfall, recharge, s_node.area,
                                                                    s_node.a, s_node.b, loss=loss)

    (cmd, outflow) = routing(cmd, s_node.storage_coef, inflow, outflow, ext, gw_exchange)

    # TODO: Calc stream level
    # if self.formula_type == 1:
    #     waterlevel = 1.0 * np.exp

    #       if (formula.eq.1) then
    # c      write(*,*) 'i'
    #        waterlevel=1.0d0
    #      :  *exp(par(1))*(tmp_flow**par(2))
    #      :  *1.0d0/((1.0d0+(tmp_flow/par(3))**par(4))**(par(5)/par(4)))
    #      :  *exp(par(6)/(1+exp(-par(7)*par(8))*tmp_flow**par(7)))
    #      :  +CTF

    s_node.update_state(cmd, e_rainfall, et, quick_store, slow_store, outflow)

    return outflow
