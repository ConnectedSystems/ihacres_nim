type
    NetworkNode* = object of RootObj
        name: string
        nodetype: string


type
    StreamNode* = ref object of NetworkNode
        area: float64  # area in km^2

        d*: float64
        d2*: float64
        e*: float64
        f*: float64

        storage*: seq[float64]
        quickflow: seq[float64]
        slowflow: seq[float64]
        outflow: seq[float64]
        effective_rainfall: seq[float64]
        et: seq[float64]
        inflow: seq[float64]


proc set_calib_params*(s: var StreamNode, d: float64, d2: float64, e: float64, f: float64) =
    s.d = d
    s.d2 = d2
    s.e = e
    s.f = f


var test_node* = StreamNode(
    area:100, 
    d: 0.1, d2: 0.1, e: 0.1, f: 0.1, 
    storage: @[100.0])

