
type
    NetworkNode* = object of RootObj
        name: string
        nodetype: string


type
    StreamNode* = ref object of NetworkNode
        area*: float64  # area in km^2

        d*: float64
        d2*: float64
        e*: float64
        f*: float64
        a*: float64
        b*: float64
        storage_coef*: float64
        alpha*: float64

        storage*: seq[float64]
        quickflow*: seq[float64]
        slowflow*: seq[float64]
        outflow*: seq[float64]
        effective_rainfall*: seq[float64]
        et*: seq[float64]
        inflow*: seq[float64]


proc set_calib_params*(s: StreamNode, d: float64, d2: float64, e: float64, f: float64) =
    s.d = d
    s.d2 = d2
    s.e = e
    s.f = f


proc update_state*(s: StreamNode, storage: float64, e_rainfall: float64, et: float64, qflow_store: float64, sflow_store: float64, outflow: float64) =
    s.storage.add(storage)
    s.effective_rainfall.add(e_rainfall)
    s.et.add(et)
    s.outflow.add(outflow)

    s.quickflow.add(qflow_store)
    s.slowflow.add(sflow_store)
