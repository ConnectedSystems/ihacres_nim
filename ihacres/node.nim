## Example node implementations


import nimpy


type
    IHACRESNode* = ref object of RootObj ## abstract base class for an expression
        name*: string
        nodetype*: string
        area*: float  # area in km^2

        # Common parameters across all IHACRESNodes
        d*: float
        d2*: float
        e*: float
        f*: float

        level_params*: array[9, float]

        storage*: seq[float]
        quickflow*: seq[float]
        slowflow*: seq[float]
        outflow*: seq[float]
        effective_rainfall*: seq[float]
        et*: seq[float]
        inflow*: seq[float]
        level*: seq[float]

        storage_coef*: float

    BilinearNode* = ref object of IHACRESNode
        a*: float
        b*: float
        alpha*: float

    ExpuhNode* = ref object of IHACRESNode
        tau_s*: float
        tau_q*: float
        v_s*: float


proc set_calib_params*(s: IHACRESNode, d, d2, e, f: float) 
     {.stdcall,exportc,dynlib,exportpy.} =
    ## Helper function to set parameters during calibration. 
    s.d = d
    s.d2 = d2
    s.e = e
    s.f = f


proc update_state*(s: IHACRESNode, storage, e_rainfall, et, qflow_store, sflow_store, outflow, level: float) 
     {.stdcall,exportc,dynlib,exportpy.} =
    ## Add given values to their respective record arrays for node `s`.
    s.storage.add(storage)
    s.effective_rainfall.add(e_rainfall)
    s.et.add(et)
    s.outflow.add(outflow)

    s.quickflow.add(qflow_store)
    s.slowflow.add(sflow_store)
    s.level.add(level)
