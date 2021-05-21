# IHACRES_nim

![DOI](https://zenodo.org/badge/280612089.svg)

An experimental implementation of the IHACRES rainfall-runoff model written in 
[nim-lang](https://nim-lang.org/).

`IHACRES_nim` provides functions which may be composed to represent different formulations of the IHACRES_CMD model. These functions are intended for use and experimentation across language ecosystems.

The [primer]([primer.md](https://connectedsystems.github.io/ihacres_nim/primer.html)) provides more details on the model itself.


## Compilation

Releases compile a dynamic library (downloads can be found [here](https://github.com/ConnectedSystems/ihacres_nim/releases))

For local development/testing, run from the project root:

`nim c --app:lib -d:release --outdir:./lib ./src/ihacres.nim`


## Tests

Tests can be found under the `tests` directory, and are invoked with the `testament` tool.

`testament pattern "tests/*.nim"`


## Documentation

The User Documentation may be found [here](https://connectedsystems.github.io/ihacres_nim)

API Documentation may be found [here](https://connectedsystems.github.io/ihacres_nim/ihacres.html)

User documentation is generated using [nimib](https://github.com/pietroppeter/nimib)

**TODO:** auto-generation of documentation.

`nim r docs/index.nim`
`nim r docs/primer.nim`
`nim r docs/usage.nim`
`nim r docs/publications.nim`

API documentation is generated from source with the following:

`nim doc --project --outdir=./docs --index:on src/ihacres.nim`


## Examples

Usage examples may be found [here](https://connectedsystems.github.io/ihacres_nim/usage.html)

Use of this package can be found in the [Streamfall.jl](https://github.com/ConnectedSystems/Streamfall.jl) package
[here](https://github.com/ConnectedSystems/Streamfall.jl/blob/d0558990c4c1ffce6f14e914d854ab2b83282867/src/IHACRESNode.jl#L186).



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

More publications may be found [here](https://connectedsystems.github.io/ihacres_nim/publications.html)