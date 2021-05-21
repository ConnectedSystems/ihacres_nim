import unittest
import math

import ../ihacres/cmd


proc `~=`(a, b: float, tolerance: float = 1e-10): bool =
    #[
        Check if "a" and "b" are close.
        We use a relative tolerance to compare the values.

        Note: later versions of Nim may have an almostEqual() proc
        to be imported from std/math
    ]#
  ## 
  result = abs(a - b) < max(abs(a), abs(b)) * tolerance


suite "Catchment Moisture Deficit":
    test "Interim CMD Not NaN/Inf":
        var 
            Mf, e_rainfall, recharge: float
            current_store, rain, d, d2, alpha: float

        let params = (214.6561105573191, 76.6251447, 200.0, 2.0, 0.727)
        (current_store, rain, d, d2, alpha) = params

        (Mf, e_rainfall, recharge) = calc_ft_interim_cmd(current_store, rain, d, d2, alpha)

        check (Mf.classify != fcNaN) and (Mf.classify != fcInf)
        check (e_rainfall.classify != fcNaN) and (e_rainfall.classify != fcInf)
        check (recharge.classify != fcNaN) and (recharge.classify != fcInf)

        (current_store, rain) = (103.467364, 79.6848605)
        (Mf, e_rainfall, recharge) = calc_ft_interim_cmd(current_store, rain, d, d2, alpha)
        check (Mf.classify != fcNaN) and (Mf.classify != fcInf)
        check (e_rainfall.classify != fcNaN) and (e_rainfall.classify != fcInf)
        check (recharge.classify != fcNaN) and (recharge.classify != fcInf)

    test "CMD expected value":
        var
            cmd, et, e_rain, recharge, rain, n_cmd: float

        cmd = 100.0
        et = 6.22
        e_rain = 6.83380027058404E-06
        recharge = 3.84930005080411E-06
        rain = 0.0000188

        n_cmd = calc_cmd(cmd, rain, et, e_rain, recharge)

        check `~=`(n_cmd, 106.22, tolerance=0.001)
