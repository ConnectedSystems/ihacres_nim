# IHACRES_nim

![DOI](https://zenodo.org/badge/280612089.svg)

An experimental implementation of the IHACRES rainfall-runoff model written in 
[nim-lang](https://nim-lang.org/).

This package provides a consistent stable set of functions for development and 
experimentation across language ecosystems.


## Compilation

Releases compile a dynamic library (downloads can be found [here](https://github.com/ConnectedSystems/ihacres_nim/releases))

For local development/testing, run from the project root:

`nim c --app:lib -d:release --outdir:./lib ./src/ihacres.nim`


## Tests

Tests can be found under the `tests` directory, and are invoked with the `testament` tool.
Tests are invoked with the `testament` tool.

`testament pattern "tests/*.nim"`


## Documentation

Documentation is generated from source with the following:

`nim doc --project --outdir=./htmldocs --index:on src/ihacres.nim`

## Examples

### Julia

Julia pre-v1.5.3

```julia
ccall((:calc_outflow, "./lib/ihacres.so"), Cdouble,(Cdouble, Cdouble), 1.0, 1.0)
```

Julia v1.5.3 onwards can leverage the provided base `@ccall` macro.

```julia
const IHACRES = "./lib/ihacres.so"
@ccall IHACRES.calc_outflow(10.0::Cdouble, 8.0::Cdouble)::Cdouble
```


### Python

```python
from ctypes import cdll

IHACRES = cdll.LoadLibrary("./lib/ihacres.so")
IHACRES.calc_outflow(1.0, 1.0)
```

References
----------
    Croke, B.F.W., Jakeman, A.J. 2004
      A catchment moisture deficit module for the IHACRES rainfall-runoff model, 
      Environmental Modelling & Software, 19(1), pp. 1–5. 
      doi: 10.1016/j.envsoft.2003.09.001

    Croke, B.F.W., Jakeman, A.J. 2005
      Corrigendum to "A Catchment Moisture Deficit module for the IHACRES 
      rainfall-runoff model [Environ. Model. Softw. 19 (1) (2004) 1–5]"
      Environmental Modelling & Software, 20(7), p. 997.
      doi: 10.1016/j.envsoft.2004.11.004

    Jakeman, A.J., Littlewood, I.G., Whitehead, P.G.
      Computation of the instantaneous unit hydrograph and identifiable component flows with application to two small upland catchments
      Journal of Hydrology, 117(1), pp. 275-300.
      doi: 10.1016/0022-1694(90)90097-H
    