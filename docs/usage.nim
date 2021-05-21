import nimib
import strformat, strutils


nbInit

nbDoc.context["highlight"] = """
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/10.5.0/styles/default.min.css">
<script src="assets/highlight.pack.js"></script>
<script>hljs.highlightAll();</script>"""

let
    index = read("index.nim".RelativeFile)

nbText: """

## Usage Examples

### Julia

Use of this package can be found in the [Streamfall.jl](https://github.com/ConnectedSystems/Streamfall.jl) package
[here](https://github.com/ConnectedSystems/Streamfall.jl/blob/d0558990c4c1ffce6f14e914d854ab2b83282867/src/IHACRESNode.jl#L186).

Examples of direct function calls through Julia's `ccall` method is shown below.

**Julia pre-v1.5.3**

```julia
ccall((:calc_outflow, "./lib/ihacres.so"), Cdouble,(Cdouble, Cdouble), 1.0, 1.0)
```

**Julia v1.5.3 onwards**

These versions include a `@ccall` macro which simplifies usage.
Note: if on Windows, replace `.so` with `.dll`.

```julia
const IHACRES = "./lib/ihacres.so"
@ccall IHACRES.calc_outflow(10.0::Cdouble, 8.0::Cdouble)::Cdouble
```


### Python

Use of the compiled DLL/so/dynlib is possible via the `ctypes` package, but declaring input/return types can get tedious (see the tutorial [here](https://docs.python.org/3/library/ctypes.html)).

Instead, the most straightforward approach is to use the `nimporter` package.

In future, a dedicated Python package may be made available.

1. Generate `.pyd` files:

```bash
# In IHACRES_nim project directory
$ nimble install nimporter
$ nimporter compile
```

2. Create a `ihacres` directory in your Python project location, and move the `__pycache__` folder (created by the `nimporter compile` command above).

```plaintext
  ihacres_nim/
  ├─ ihacres/
  │  ├─ __pycache__/     <- copy this folder

  YOUR_PYTHON_PROJECT/
  ├─ ihacres/            <- create this folder
  │  ├─ __pycache__/     <- paste the copy of this folder
```

3. Use in a python file

```python
import nimporter  # Required prior to any Nim module import

from ihacres import climate
from ihacres import flow
from ihacres import cmd as ihacres_cmd

nimporter.build_nim_extensions()  # Build Nim extension


def run(cmd, rainfall, evaporation, inflow, quickflow, slowflow, loss, gw_exchange, extraction):
    '''Example run function.

    Parameters
    ----------
    cmd : catchment moisture deficit, $M_{k}$ in the literature.
    rainfall : precipitation (P)
    evaporation : (E)
    inflow : flow from previous node
    quickflow : quickflow at previous time step, $(V_{q-1})$
    slowflow : slowflow at previous time step, $(V_{s-1})$
    gw_exchange : volume flux, interaction with groundwater
    extraction : volume extracted from stream
    '''
    d, d2, e, f = run.d, run.d2, run.e, run.f
    a, b, alpha, s = run.a, run.b, run.alpha, run.s
    catchment_area = run.catchment_area

    mf, U, r = ihacres_cmd.calc_ft_interim_cmd(cmd, rainfall, d, d2, alpha)
    ET = climate.calc_ET(e, evaporation, mf, f, d)
    cmd = ihacres_cmd.calc_cmd(cmd, rainfall, ET, U, r)

    Vq, Vs, outflow = flow.calc_ft_flows(quickflow, slowflow, U, r, 
                                         catchment_area, a, b, loss)

    # if node routes to another node
    volume, outflow = flow.routing(cmd, run.s, inflow, outflow, extraction, gw_exchange)

    return {
        "flow": (volume, outflow),
        "state": (Vq, Vs, cmd)
    }

# Here we leverage the fact that everything in Python is an object
# including functions. We assign the model parameters to the function
# such that the function itself represents a node in a stream network.
# Of course, you could (should?) define a Class instead.
run.d = 200.0
run.d2 = 2.0
run.e = 0.1
run.f = 0.1
run.a = 54.35
run.b = 0.012
run.alpha = 0.727
run.s = 2.5
run.catchment_area = 100.0


# Initial conditions
cmd, rainfall, evaporation = 214.6561105573191, 76.6251447, 6.22
quickflow, slowflow = 0, 0

# Assume these are all 0.0
inflow = 0
loss = 0
gw_exchange = 0.0
extraction = 0.0

rainfall_ts = [70.0, 10.0, 0.0, 0.0, 200]
evaporation_ts = [2.0, 6.5, 7.0, 5.0, 1.0]

outflow = [None] * len(rainfall_ts)

for i in range(len(outflow)):
    progress = run(cmd, rainfall, evaporation, inflow, quickflow, slowflow, loss, gw_exchange, extraction)
    quickflow, slowflow, cmd = progress["state"]
    outflow[i] = progress["flow"][1]

print(outflow)
```

The output should be:

```
    [2673.079788519708, 3128.2662749539195, 3505.4202255215077, 3818.5465178864956, 4079.1271026927366]
```
"""

nbSave