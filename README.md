# ihacres_nim

An experimental implementation of the IHACRES rainfall-runoff model written in [nim-lang](https://nim-lang.org/).

Intended to provide a consistent stable base for use across language ecosystems.


**Compilation**

Releases compile a library (downloads can be found [here](https://github.com/ConnectedSystems/ihacres_nim/releases))

For local development/testing, run from the project root:

`nim c --app:lib --opt:speed -d:release --outdir:./lib ./src/ihacres.nim`


## Examples

### Julia

Julia pre-v1.5.3

```julia
ccall((:calc_outflow, "./lib/ihacres.so"), Cdouble,(Cdouble, Cdouble), 1.0, 1.0)
```

Julia v1.5.3 onwards can leverage the provided base `@ccall` macro.

```julia
const ihacres = "./lib/ihacres.so"
@ccall ihacres.calc_outflow(10.0::Cdouble, 8.0::Cdouble)::Cdouble
```


### Python

```python
from ctypes import cdll

ihacres = cdll.LoadLibrary("./lib/ihacres.so")
ihacres.calc_outflow(1.0, 1.0)
```
