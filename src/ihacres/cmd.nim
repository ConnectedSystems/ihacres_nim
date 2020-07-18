from math import arctan, exp, log, PI, tan, pow, ln


proc calc_cmd(prev_cmd: float, rainfall: float, et: float, 
             effective_rainfall: float, recharge: float): float =
    ## Calculate Catchment Moisture Deficit.
    ## 
    ## Min value of CMD is 0.0 and is in represented in mm depth.
    ## A value of 0 indicates that the catchment is fully saturated.
    ## A value greater than 0 means that there is a moisture deficit.
    var cmd: float = prev_cmd + et + effective_rainfall + recharge - rainfall  # units in mm

    return max(0.0, cmd)


proc calc_interim_cmd(cmd: float, param_d: float, rainfall: float): float =
    ## Calculate interim CMD (M_{f}) in its linear form.
    ##
    ## Based on HydroMad implementation.
    ## 
    ## Parameters
    ## ----------
    ## cmd: float, current Catchment Moisture Deficit (M_{k})
    ## param_d: float, model parameter factor `d`
    ## rainfall: float, rainfall for current time step in mm
    ## 
    ## Returns
    ## ----------
    ## float, interim CMD (M_{f})
    var Mf: float
    if cmd < param_d:
        Mf = cmd * exp(-rainfall / param_d)
    elif cmd < (param_d + rainfall):
        Mf = param_d * exp((-rainfall + cmd - param_d) / param_d)
    else:
        Mf = cmd - rainfall
    # End if

    return Mf
# End calc_interim_cmd()


proc calc_trig_interim_cmd(cmd: float, param_d: float, rainfall: float): float =
    ## Calculate interim CMD (M_{f}) in its trigonometric form.
    ## 
    ## Based on HydroMad implementation.
    ## 
    ## Parameters
    ## ----------
    ## cmd: float, current Catchment Moisture Deficit (M_{k})
    ## param_d: float, model parameter factor `d`
    ## rainfall: float, rainfall for current time step in mm
    ## 
    ## Returns
    ## -------
    ## float, interim CMD (M_{f})
    var Mf: float
    if cmd < param_d:
        Mf = 1.0 / tan((cmd / param_d) * (PI / 2.0))
        Mf = (2.0 * param_d / PI) * arctan(1.0 / (PI * rainfall / (2.0 * param_d) + Mf))
    elif (rainfall < (param_d + rainfall)):
        Mf = (2.0 * param_d / PI) * arctan(2.0 * param_d / (PI * (param_d - cmd + rainfall)))
    else:
        Mf = cmd - rainfall
    # End if

    return Mf
# End calc_trig_interim_cmd()


proc calc_ft_interim(cmd: float, rain: float, d: float, d2: float, alpha: float): (float, float, float) =
    ## Direct port of original Fortran implementation to calculate interim CMD.
    ## 
    ## Parameters
    ## ----------
    ## cmd: float, Catchment Moisture Deficit
    ## rain: float, rainfall for time step in mm
    ## d: float, flow threshold value
    ## d2: float, scaling factor applied to `d`
    ## alpha: float, took value from IHACRESparams.csv file for 406219 for dev purposes only
    ## 
    ## Returns
    ## ----------
    ## tuple[float], interim CMD value, effective rainfall, recharge (all in mm)
    var n_cmd: float  # new CMD value
    var tmp_rain: float

    var d2: float = d * d2
    var tmp_cmd: float = cmd
    var e_rain: float = 0.0
    var recharge: float = 0.0
    if rain == 0.0:
        return (cmd, e_rain, recharge)
    # End if

    if tmp_cmd > (d2 + rain):
        # CMD never reaches d2, so all rain is effective
        n_cmd = tmp_cmd - rain
    else:
        if tmp_cmd > d2:
            tmp_rain = rain - (tmp_cmd - d2)  # leftover rain after reaching d2 threshold
            tmp_cmd = d2
        else:
            tmp_rain = rain
        # End if

        var eps: float
        var depth_to_d: float
        var lam: float
        var d1a: float
        var epsilon: float
        var gamma: float

        d1a = d * (2.0 - exp(pow(-(rain / 50.0), 2)))
        if tmp_cmd > d1a:
            eps = d2 / (1.0 - alpha)

            # original comment: now get rainfall to reach cmd = d1a
            # amount of rain necessary to get to threshold `d`
            depth_to_d = eps * ln((alpha + tmp_cmd / eps) / (alpha + d1a / eps))
            if depth_to_d > tmp_rain:
                lam = exp(tmp_rain * (1.0 - alpha) / d2)
                epsilon = alpha * eps

                n_cmd = tmp_cmd / lam - epsilon * (1.0 - 1.0 / lam)
                e_rain = 0.0
            else:
                if (tmp_cmd > d1a):
                    tmp_rain = tmp_rain - depth_to_d

                tmp_cmd = d1a
                gamma = (alpha * d2 + (1.0 - alpha) * d1a) / (d1a * d2)
                n_cmd = tmp_cmd * exp(-tmp_rain * gamma)
                e_rain = alpha * (tmp_rain + 1.0 / d1a / gamma * (cmd - tmp_cmd))
            # End if
        else:
            gamma = (alpha * d2 + (1.0 - alpha) * d1a) / (d1a * d2)
            n_cmd = tmp_cmd * exp(-tmp_rain * gamma)
            e_rain = alpha * (tmp_rain + 1.0 / d1a / gamma * (n_cmd - tmp_cmd))
        # End if

        recharge = rain - (tmp_cmd - n_cmd) - e_rain
    # End if

    return (n_cmd, e_rain, recharge)
