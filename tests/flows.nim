import unittest

import ihacres/flow


suite "Flows":

    test "CMD stores":
        var
            area, a, b, e_rain, recharge, loss, prev_quick, prev_slow: float
            quick_store, slow_store, outflow: float

        area = 1985.73
        a = 54.352
        b = 0.187
        e_rain = 3.421537294474909e-6
        recharge = 3.2121031313153022e-6
        loss = 0.0
        prev_quick = 100.0
        prev_slow = 100.0

        (quick_store, slow_store, outflow) = calc_ft_flows(prev_quick, prev_slow, e_rain, recharge, area, a, b, loss)

        check quick_store == (1.0 / (1.0 + a) * (prev_quick + (e_rain * area)))

        var b2 = 1.0
        var check_val = prev_slow + (recharge * area) - (loss * b2)
        check_val = 1.0 / (1.0 + b) * check_val
        check slow_store == check_val

        # Use values that trigger alternate calculation

        e_rain = 0.0
        recharge = 0.0

        prev_quick = 3.3317177943791187
        prev_slow = 144.32012122323678

        (quick_store, slow_store, outflow) = calc_ft_flows(prev_quick, prev_slow, e_rain, recharge, area, a, b, loss)

        check quick_store == (1.0 / (1.0 + a) * (prev_quick + (e_rain * area)))

        b2 = 1.0
        check_val = prev_slow + (recharge * area) - (loss * b2)
        check_val = 1.0 / (1.0 + b) * check_val
        check slow_store == check_val