
type
    NetworkNode* = object of RootObj
        name: string
        nodetype: string


type
    StreamNode* = ref object of NetworkNode
        area*: float  # area in km^2

        d*: float
        d2*: float
        e*: float
        f*: float
        a*: float
        b*: float
        storage_coef*: float
        alpha*: float

        level_params*: array[9, float]

        storage*: seq[float]
        quickflow*: seq[float]
        slowflow*: seq[float]
        outflow*: seq[float]
        effective_rainfall*: seq[float]
        et*: seq[float]
        inflow*: seq[float]
        level*: seq[float]


proc set_calib_params*(s: StreamNode, d, d2, e, f: float) =
    s.d = d
    s.d2 = d2
    s.e = e
    s.f = f


proc update_state*(s: StreamNode, storage, e_rainfall, et, qflow_store, sflow_store, outflow, level: float) =
    s.storage.add(storage)
    s.effective_rainfall.add(e_rainfall)
    s.et.add(et)
    s.outflow.add(outflow)

    s.quickflow.add(qflow_store)
    s.slowflow.add(sflow_store)
    s.level.add(level)
