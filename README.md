ihacres_nim



Examples
--------

**Julia**

```julia
ccall((:calc_outflow, "./lib/ihacres.so"), Cdouble,(Cdouble, Cdouble), 1.0, 1.0)
```

**Python**

```python
from ctypes import cdll

ihacres = cdll.LoadLibrary("./lib/ihacres.so")
ihacres.calc_outflow(1.0, 1.0)
```
