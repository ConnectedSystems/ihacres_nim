import unittest

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

