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


def run_ihacres(cmd, rainfall, evaporation, inflow, quickflow, slowflow,
                loss, gw_state, gw_exchange, extraction):
    '''Example run function.

    Parameters
    ----------
    cmd : catchment moisture deficit, $M_{k}$ in the literature.
    rainfall : precipitation ($P$)
    evaporation : ($E$)
    inflow : flow from previous node
    quickflow : quickflow at previous time step, $(V_{q-1})$
    slowflow : slowflow at previous time step, $(V_{s-1})$
    loss : loss, volume loss
    gw_state : groundwater storage index at $t-1$
    gw_exchange : volume flux, interaction with groundwater
    extraction : volume extracted from stream
    '''
    d, d2, e, f = run_ihacres.d, run_ihacres.d2, run_ihacres.e, run_ihacres.f
    a, b, alpha, s = run_ihacres.a, run_ihacres.b, run_ihacres.alpha, run_ihacres.s
    catchment_area = run_ihacres.catchment_area

    mf, U, r = ihacres_cmd.calc_ft_interim_cmd(cmd, rainfall, d, d2, alpha)
    ET = climate.calc_ET(e, evaporation, mf, f, d)
    cmd = ihacres_cmd.calc_cmd(cmd, rainfall, ET, U, r)

    Vq, Vs, outflow = flow.calc_ft_flows(quickflow, slowflow, U, r,
                                         catchment_area, a, b, loss)

    # if node routes to another node
    gw_state, outflow = flow.routing(gw_state, s, inflow, outflow, extraction, gw_exchange)

    return {
        "flow": (gw_state, outflow),
        "state": (Vq, Vs, cmd)
    }

# Here we leverage the fact that everything in Python is an object
# including functions. We assign the model parameters to the function
# such that the function itself represents a node in a stream network.
# Of course, you could (should?) define a Class instead.
run_ihacres.d = 200.0  # flow threshold
run_ihacres.d2 = 2.0   # flow threshold, multiplier applied to `d`
run_ihacres.e = 0.1    # temperature to PET conversion factor
run_ihacres.f = 0.1    # plant stress threshold factor (applied to `d`). Determines effective rainfall.
run_ihacres.a = 54.35  # quickflow scaling factor
run_ihacres.b = 0.012  # slowflow scaling factor
run_ihacres.alpha = 0.727   #  effective rainfall scaling factor
run_ihacres.s = 2.5  # groundwater store factor
run_ihacres.catchment_area = 100.0  # area in km^2


# Initial conditions
cmd, quickflow, slowflow = 214.65, 0, 0

# Assume these are all 0.0
inflow = 0
loss = 0
gw_exchange = 0.0
extraction = 0.0

# Ideally, these would be read in via Numpy or Pandas
rainfall_ts = [70.0, 10.0, 0.0, 0.0, 200.0]
evaporation_ts = [2.0, 6.5, 7.0, 5.0, 1.0]

# Set up arrays to record state
outflow = [None] * len(rainfall_ts)
gw_state = [None] * (len(rainfall_ts)+1)
gw_state[0] = 0.0

# Run model (this would be in its own function)
for i in range(len(outflow)):
    progress = run_ihacres(cmd, rainfall_ts[i], evaporation_ts[i], inflow, quickflow, slowflow,
                           loss, gw_state[i], gw_exchange, extraction)
    quickflow, slowflow, cmd = progress["state"]
    gw_state[i+1], outflow[i] = progress["flow"]

# Remove initial gw state to line up records
gw_state = gw_state[1:]

print(outflow)
```

The streamflow output should be:

```
    [2219.61106301161, 752.5478564540413, 227.09475478084866, 76.8211905507675, 8925.85109370568]
```
"""

nbSave