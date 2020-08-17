import ihacres/node

# stream_run

proc run*(s_node: StreamNode, rain: float, evap: float, inflow: float, extractions: float, gw_exchange=0.0, loss=0.0) =
    ## Run node to calculate outflow and update state.
    ## 
    ## Parameters
    ## ----------
    ## timestep: int, time step
    ## rain: float, rainfall
    ## evap: float, evapotranspiration
    ## extractions: float, irrigation and other water extractions
    ## gw_exchange: float, flux in ML - positive is contribution, negative is infiltration
    ## loss: float,
    ## 
    ## Returns
    ## ----------
    ## float, outflow from node

    # other extractions are ignored for stream nodes, so only extract irrigation ext.
    var ext: float = extractions

    var
        mf: float
        e_rainfall: float
        recharge: float

    mf, e_rainfall, recharge = ihacres_funcs.calc_ft_interim(s_node.storage, rainfall, s_node.d,
                                                                s_node.d2, s_node.alpha)

    et = ihacres_funcs.calc_ET(s_node.e, evap, mf, s_node.f, s_node.d)
    cmd = ihacres_funcs.calc_cmd(s_node.storage, rainfall, et, e_rainfall, recharge)

    inflow = 0.0
    for nid in s_node.prev_node:
        inflow += s_node.prev_node[nid].run(timestep, rain_evap, ext)
    # End for
    s_node.inflow.add(inflow)

    quick_store, slow_store, outflow = ihacres_funcs.calc_ft_flows(s_node.quickflow, s_node.slowflow,
                                                                    e_rainfall, recharge, s_node.area,
                                                                    s_node.a, s_node.b, loss=loss)

    if self.next_node:  # and ('dam' not in self.next_node.node_type):
        cmd, outflow = ihacres_funcs.routing(cmd, s_node.storage_coef, inflow, outflow, ext, gamma=gw_exchange)
    else:
        outflow = ihacres_funcs.calc_outflow(outflow, ext)
    # End if

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

    s_node.update_state(timestep, cmd, e_rainfall, et, quick_store, slow_store, outflow)

    return outflow
