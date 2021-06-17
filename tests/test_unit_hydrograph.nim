import unittest
import math

import ../ihacres/flow


suite "Flows":

    test "CMD stores":
        var
            area, a, b, e_rain, recharge, prev_quick, prev_slow: float
            quick_store, slow_store, outflow: float

        area = 1985.73
        a = 54.352
        b = 0.187
        e_rain = 3.421537294474909e-6
        recharge = 3.2121031313153022e-6
        prev_quick = 100.0
        prev_slow = 100.0

        (quick_store, slow_store, outflow) = calc_ft_flows(prev_quick, prev_slow, e_rain, recharge, area, a, b)
        
        check quick_store == exp(-a) * (prev_quick + (e_rain * area))

        var check_val = prev_slow + (recharge * area)
        check_val = exp(-b) * check_val
        check slow_store == check_val

        # Use values that trigger alternate calculation

        e_rain = 0.0
        recharge = 0.0

        prev_quick = 3.3317177943791187
        prev_slow = 144.32012122323678

        (quick_store, slow_store, outflow) = calc_ft_flows(prev_quick, prev_slow, e_rain, recharge, area, a, b)

        check quick_store == exp(-a) * (prev_quick + (e_rain * area))

        check_val = prev_slow + (recharge * area)
        check_val = exp(-b) * check_val
        check slow_store == check_val