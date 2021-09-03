## Functions related to estimating ET and U (evapotranspiration and effective rainfall)

import math


proc calc_effective_rainfall*(rainfall, cmd, d, d2: float, n: float=0.1): float
     {.stdcall,exportc,dynlib.} =
    ## Estimate effective rainfall.
    ##
    ## :References:
    ##     Croke, B.F.W., Jakeman, A.J. 2004
    ##         A catchment moisture deficit module for the IHACRES rainfall-runoff model,
    ##         Environmental Modelling & Software, 19(1), pp. 1–5.
    ##         doi: 10.1016/j.envsoft.2003.09.001
    ##
    ##     Croke, B.F.W., Jakeman, A.J. 2005
    ##         Corrigendum to "A Catchment Moisture Deficit module for the IHACRES
    ##         rainfall-runoff model [Environ. Model. Softw. 19 (1) (2004) 1–5]"
    ##         Environmental Modelling & Software, 20(7), p. 997.
    ##         doi: https://doi.org/10.1016/j.envsoft.2004.11.004
    ##
    ## :Parameters:
    ##     - rainfall : rainfall for time step
    ##     - cmd      : previous CMD value
    ##     - Mf       : interim CMD value
    ##     - d        : threshold value
    ##     - d2       : scaling factor applied to `d`
    ##     - n        : scaling factor (default = 0.1)
    ##                  Default value is suitable for most cases (Croke & Jakeman, 2004)
    ## 
    ## :Returns:
    ##     effective rainfall
    let d2: float = d * d2
    var e_rainfall: float

    if (cmd > d2):
        e_rainfall = rainfall
    else:
        let f1: float = min(1.0, cmd / d)
        let f2: float = min(1.0, cmd / d2)
        e_rainfall = rainfall * ((1.0 - n) * (1.0 - f1) + (n * (1.0 - f2)))

    return max(0.0, e_rainfall)


proc calc_ET_from_E*(e, evap, Mf, f, d: float): float
     {.stdcall,exportc,dynlib.} =
    ## Calculate evapotranspiration from evaporation.
    ##
    ## :Parameters:
    ##     - e    : temperature to PET conversion factor (a stress threshold)
    ##     - evap : evaporation for given time step.
    ##     - Mf   : Catchment Moisture Deficit prior to accounting for ET losses (`M_{f}`)
    ##     - f    : calibrated parameter that acts as a multiplication factor on `d`
    ##     - d    : flow threshold factor
    ##
    ## :Results:
    ##     estimate of ET
    let param_g: float = f * d
    var et: float = e * evap

    if Mf > param_g:
        et = et * min(1.0, exp((1.0 - Mf/param_g)*2.0))

    return max(0.0, et)


proc calc_ET*(e, evap, Mf, f, d: float): float
     {.stdcall,exportc,dynlib.} =
    ## Deprecated function - call calc_ET_from_E instead.
    return calc_ET_from_E(e, evap, Mf, f, d)


proc calc_ET_from_T*(e, T, Mf, f, d: float): float
     {.stdcall,exportc,dynlib.} =
    ## Calculate evapotranspiration based on temperature data.
    ##
    ## Parameters `f` and `d` are used to calculate `g`, the value of the CMD
    ## which the ET rate will begin to decline due to insufficient
    ## water availability for plant transpiration.
    ##
    ## :Parameters:
    ##     - e  : temperature to PET conversion factor (a stress threshold)
    ##     - T  : temperature in degrees C
    ##     - Mf : Catchment Moisture Deficit prior to accounting for ET losses (`M_{f}`)
    ##     - f  : multiplication factor on `d`
    ##     - d  : flow threshold factor
    ##
    ## :Returns:
    ##     estimate of ET from temperature (for catchment area)

    # temperature can be negative, so we have a min cap of 0.0
    if T <= 0.0:
        return 0.0

    let param_g: float = f * d
    var et: float = e * T * min(1.0, exp(2.0 * (1.0 - (Mf / param_g))) )

    return max(0.0, et)