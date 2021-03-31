import math

proc calc_effective_rainfall*(rainfall: float, cmd: float, Mf: float, d: float, d2: float, n: float=0.1): 
     float {.stdcall,exportc,dynlib.} = 
    #[ Calculate effective rainfall
    
        Parameters
        ----------
        rainfall: float, rainfall for time step
        cmd: float, previous CMD value
        Mf, float, interim CMD value
        d: float, threshold value
        d2: float, scaling factor applied to `d`
        n: float, scaling factor taken from Croke & Jakeman (2004).
        `n` = 0.1 in suitable for most cases
        
        Returns
        ----------
        float : effective rainfall
    ]#
    let d2: float = d * d2
    var e_rainfall: float

    if (cmd > d2):
        e_rainfall = rainfall
    else:
        let f1: float = min(1.0, cmd / d)
        let f2: float = min(1.0, cmd / d2)
        e_rainfall = rainfall * ((1.0 - n) * (1.0 - f1) + (n * (1.0 - f2)))

    return e_rainfall


# def calc_effective_rainfall_orig(rainfall, cmd, Mf, d, d2):
#     d2 = d * d2
#     if cmd > d2:
#         e_rainfall = rainfall
#     else:
#         # effective rainfall = rainfall - prev_cmd + (cmd before ET loss is accounted for)
#         e_rainfall = max(0.0, rainfall - cmd + Mf)
#     # End if

#     return e_rainfall
# # End calc_effective_rainfall2()


proc calc_ET_from_T*(e: float, T: float, interim_cmd: float, f: float, d: float): 
     float {.stdcall,exportc,dynlib.} =
    #[ Calculate evapotranspiration based on temperature data.

        Parameters `f` and `d` are used to calculate `g`, the value of the CMD
        which the ET rate will begin to decline due to insufficient
        water availability for plant transpiration.
        
        Parameters
        ----------
        e: float, temperature to PET conversion factor (a stress threshold)
        T: float or None, temperature in degrees C
        interim_cmd: float, Catchment Moisture Deficit prior to accounting for ET losses (`M_{f}`)
        f: float, multiplication factor on `d`
        d: float, flow threshold factor
        
        Returns
        -------
        float : estimate of ET from temperature
    ]#
    let param_g: float = f * d
    var et: float = e * T * exp(2.0 * (1.0 - (interim_cmd / param_g))) 

    # temperature can be negative, so we have a min cap of 0.0
    return max(0.0, et)


proc calc_ET*(e: float, evap: float, interim_cmd: float, f: float, d: float): 
     float {.stdcall,exportc,dynlib.} =
    #[ Calculate evapotranspiration.

        Parameters
        ----------
        e: float, temperature to PET conversion factor (a stress threshold)
        evap: float, evaporation for given time step.
        interim_cmd: float, Catchment Moisture Deficit prior to accounting for ET losses (`M_{f}`)
        f: float, calibrated parameter that acts as a multiplication factor on `d`
        d: float, flow threshold factor

        Results
        ----------
        float : estimate of ET 
    ]#
    let param_g: float = f * d
    var et: float = e * evap

    if interim_cmd > param_g:
        et = et * exp((1.0 - interim_cmd/param_g)*2.0)

    if et < 0.0:
        et = 0.0

    return et
