import unittest
import math
import strformat

import ihacres/node
import ihacres/stream_run


suite "Test Run":
    test "Node Run":
        var test_node = StreamNode(
            area:100, 
            d: 0.1, d2: 0.1, e: 0.1, f: 0.1, 
            a: 54.35,
            b: 0.012,
            storage_coef: 2.5,
            alpha: 0.240195,
            storage: @[100.0],
            quickflow: @[0.0],
            slowflow: @[0.0],
        )

        echo test_node.run(rain=5.0, evap=1.0, inflow=50.0, ext=25.0, gw_exchange=0.0, loss=0.0)
    
    test "No NaN":
        var test_node = StreamNode(
            area:100, 
            d: 0.1, d2: 0.1, e: 0.1, f: 0.1, 
            a: 54.35,
            b: 0.012,
            storage_coef: 2.5,
            alpha: 0.240195,
            storage: @[100.0],
            quickflow: @[8.46269687e+02],
            slowflow: @[3.67133471e+02],
        )

        var outflow, level, cmd, quick, slow: float

        (outflow, level) = test_node.run(rain=7.96848605e+01, evap=3.32467909e+00, inflow=9.19583373e-11, 
                                         ext=1.59313987e-12, gw_exchange=2.47076926e-11, loss=5.51086184e-11)
        
        var idx: int = test_node.storage.len() - 1
        cmd = test_node.storage[idx]
        quick = test_node.quickflow[idx]
        slow = test_node.slowflow[idx]

        assert (quick.classify != fcNaN), fmt"Got {quick}"
        assert (slow.classify != fcNaN), fmt"Got {slow}"
