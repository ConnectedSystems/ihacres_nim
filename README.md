ihacres_nim



Examples
--------

**Julia**

Julia pre-v1.5.3

```julia
ccall((:calc_outflow, "./lib/ihacres.so"), Cdouble,(Cdouble, Cdouble), 1.0, 1.0)
```

Julia v1.5.3 onwards - leverage available macro

```julia
const ihacres = "./lib/ihacres.so"
@ccall ihacres.calc_outflow(10.0::Cdouble, 8.0::Cdouble)::Cdouble
```


**Python**

```python
from ctypes import cdll

ihacres = cdll.LoadLibrary("./lib/ihacres.so")
ihacres.calc_outflow(1.0, 1.0)
```
