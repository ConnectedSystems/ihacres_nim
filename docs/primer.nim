import strformat, strutils
import nimib

nbInit

nbDoc.useLatex

nbText: """
<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js"></script>

## Primer

IHACRES converts rainfall and temperature data into estimations of runoff at catchment scale.

The model can be conceptualized as taking the following structure:

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcblxuICByYWluZmFsbFtcIlJhaW5mYWxsIChQW3RdKVwiXVxuICByYWluZmFsbCAtLT4gbmxfbG9zc1tcIkNhdGNobWVudCBNb2lzdHVyZSBEZWZpY2l0IG1vZHVsZVwiXVxuICBUW1wiVGVtcGVyYXR1cmUgKFQpXCJdIC0tPiBubF9sb3NzXG4gIG5sX2xvc3MgLS0-IHVoW1VuaXQgSHlkcm9ncmFwaF1cblxuICB1aCAtLT58UXVpY2tmbG93fCBTdHJlYW1mbG93XG4gIHVoIC0tPnxTbG93Zmxvd3wgU3RyZWFtZmxvd1xuXG4gIGNsYXNzRGVmIHZhcmlhYmxlIGZpbGw6bGlnaHRibHVlXG4gIGNsYXNzIHJhaW5mYWxsLFQgdmFyaWFibGVcblxuICBjbGFzc0RlZiBub25saW5lYXIgZmlsbDpsaWdodGdyZWVuXG4gIGNsYXNzIG5sX2xvc3Mgbm9ubGluZWFyXG5cbiAgY2xhc3NEZWYgbVVIIGZpbGw6YmVpZ2VcbiAgY2xhc3MgdWggbVVIIiwibWVybWFpZCI6e30sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggTFJcblxuICByYWluZmFsbFtcIlJhaW5mYWxsIChQW3RdKVwiXVxuICByYWluZmFsbCAtLT4gbmxfbG9zc1tcIkNhdGNobWVudCBNb2lzdHVyZSBEZWZpY2l0IG1vZHVsZVwiXVxuICBUW1wiVGVtcGVyYXR1cmUgKFQpXCJdIC0tPiBubF9sb3NzXG4gIG5sX2xvc3MgLS0-IHVoW1VuaXQgSHlkcm9ncmFwaF1cblxuICB1aCAtLT58UXVpY2tmbG93fCBTdHJlYW1mbG93XG4gIHVoIC0tPnxTbG93Zmxvd3wgU3RyZWFtZmxvd1xuXG4gIGNsYXNzRGVmIHZhcmlhYmxlIGZpbGw6bGlnaHRibHVlXG4gIGNsYXNzIHJhaW5mYWxsLFQgdmFyaWFibGVcblxuICBjbGFzc0RlZiBub25saW5lYXIgZmlsbDpsaWdodGdyZWVuXG4gIGNsYXNzIG5sX2xvc3Mgbm9ubGluZWFyXG5cbiAgY2xhc3NEZWYgbVVIIGZpbGw6YmVpZ2VcbiAgY2xhc3MgdWggbVVIIiwibWVybWFpZCI6e30sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)


`IHACRES_nim` provides functions which may be composed to represent different formulations of the IHACRES_CMD model.

All formulations require the following four parameters (with usual bounds)

| Parameter 	| Bounds             	| Description                            	|
|-----------	|--------------------	|----------------------------------------	|
| $d$       	| $10 \le d \le 550$ 	| flow threshold                         	|
| $d_2$     	| $0 < d_2 \le 10$    | multiplicative factor applied to $d$   	|
| $e$       	| $0.1 \le e \le 1.5$ | Temperature to PET conversion factor   	|
| $f$       	| $0.01 \le f \le 3$ 	| Plant stress threshold, applied to $d$ 	|


A six parameter implementation (as in IHACRES Classic) can be achieved by fixing $d_2 = 2.0$, with the following additional parameters:

| Parameter | Bounds             	| Description                            	                          |
|-----------|--------------------	|-----------------------------------------------------------------	|
| $\tau_q$  | $0.5 \le d \le 10$ 	| Time constant value controlling how fast quickflow recedes      	|
| $\tau_s$  | $10 < d_2 \le 350$  | Time constant value that governs the speed of slowflow recession 	|
| $v_s$     | $0 < v_s \le 1$     | Partitioning factor separating slow and quick flow contributions 	|

An eight parameter, bilinear, implementation replaces the above parameters with the following:

| Parameter 	| Bounds        | Description                            	                          |
|-----------	|---------------|-----------------------------------------------------------------	|
| $a$      | see note below   | Time constant value controlling how fast quickflow recedes      	|
| $b$      | see note below   | Time constant value that governs the speed of slowflow recession 	|
| $\alpha$ | $0 < v_s \le 1$  | Partitioning factor separating slow and quick flow contributions 	|
| $s$      | $0.1 < s \le 10$ | storage factor |


Note: Appropriate values of $a$ and $b$ can be context specific. Nevertheless, to give some guidance, these values can be set between 0.1 and 10.0 for $a$ and between 0.001 and 0.1 for $b$.

Delving into the implementation, the flow between parameters (light blue) and functions (rounded boxes) can be seen in the diagram below.

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggTFJcbiAgbWtbXCJDTUQgKE1ba10pXCJdIC0tPiBjYWxjX2NtZChjYWxjX2NtZClcbiAgbWsgLS0-IGludGVyaW0oXCJjYWxjX2Z0X2ludGVyaW1fY21kXCIpXG5cbiAgcmFpbltcIlJhaW5mYWxsIChQW3RdKVwiXSAtLT4gaW50ZXJpbVxuICBcbiAgcmFpbiAtLT4gY2FsY19jbWRcbiAgRVtcIkV2YXBvcmF0aW9uIChFKVwiXSAtLT4gRVQoXCJjYWxjX0VUXCIpIC0tPiBjYWxjX2NtZFxuICBpbnRlcmltIC0tPnxcIkludGVyaW0gQ01EIChNW2ZdKVwifCBFVFxuXG4gIGludGVyaW0gLS0-fFwiZWZmZWN0aXZlIHJhaW5mYWxsIChVW3RdKVwifGNhbGNfY21kXG4gIGludGVyaW0gLS0-IHxcInJlY2hhcmdlIChyKVwifCBjYWxjX2NtZCAtLT4gY21kX291dFtcIkNNRCAoTVtrKzFdKVwiXVxuICBcbiAgaW50ZXJpbSAtLT58XCJlZmZlY3RpdmUgcmFpbmZhbGwgKFVbdF0pXCJ8IHVoKGNhbGNfZnRfZmxvd3MpXG4gIGludGVyaW0gLS0-IHxcInJlY2hhcmdlIChyKVwifCB1aFxuXG4gIHFzW1wiUXVpY2tmbG93IChWW3EsdC0xXSlcIl0gLS0-IHVoXG4gIHNzW1wiU2xvd2Zsb3cgKFZbcyx0LTFdKVwiXSAtLT4gdWhcbiAgbG9zc1tcIkxvc3MgKExbdF0pXCJdIC0tPiB1aFxuXG4gIHVoIC0tPnxcIlF1aWNrZmxvd1t0XVwifCBzZmxvd1tcIlN0cmVhbWZsb3cgKFFba10pXCJdXG4gIHVoIC0tPnxcIlNsb3dmbG93W3RdXCJ8IHNmbG93W1wiU3RyZWFtZmxvdyAoUVtrXSlcIl1cblxuICBzZmxvdyAtLT4gcm91dGluZyhyb3V0aW5nKVxuICBleHRbZXh0cmFjdGlvbl0gLS0-IHJvdXRpbmdcbiAgZ3dbZ3JvdW5kd2F0ZXIgZXhjaGFuZ2VdIC0tPiByb3V0aW5nXG4gIHNjb2VmW1wic3RvcmFnZSBmYWN0b3IgKHMpXCJdIC0tPiByb3V0aW5nXG5cbiAgcm91dGluZyAtLT4gT3V0Zmxvd1xuXG4gIGNsYXNzRGVmIHZhcmlhYmxlIGZpbGw6bGlnaHRibHVlXG4gIGNsYXNzIG1rLEUscmFpbixxcyxzcyxsb3NzLGV4dCxndyxzY29lZiB2YXJpYWJsZVxuXG4gIGNsYXNzRGVmIG5vbmxpbmVhciBmaWxsOmxpZ2h0Z3JlZW5cbiAgY2xhc3MgaW50ZXJpbSxFVCxjYWxjX2NtZCBub25saW5lYXJcblxuICBjbGFzc0RlZiBtVUggZmlsbDpiZWlnZVxuICBjbGFzcyB1aCBtVUgiLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggTFJcbiAgbWtbXCJDTUQgKE1ba10pXCJdIC0tPiBjYWxjX2NtZChjYWxjX2NtZClcbiAgbWsgLS0-IGludGVyaW0oXCJjYWxjX2Z0X2ludGVyaW1fY21kXCIpXG5cbiAgcmFpbltcIlJhaW5mYWxsIChQW3RdKVwiXSAtLT4gaW50ZXJpbVxuICBcbiAgcmFpbiAtLT4gY2FsY19jbWRcbiAgRVtcIkV2YXBvcmF0aW9uIChFKVwiXSAtLT4gRVQoXCJjYWxjX0VUXCIpIC0tPiBjYWxjX2NtZFxuICBpbnRlcmltIC0tPnxcIkludGVyaW0gQ01EIChNW2ZdKVwifCBFVFxuXG4gIGludGVyaW0gLS0-fFwiZWZmZWN0aXZlIHJhaW5mYWxsIChVW3RdKVwifGNhbGNfY21kXG4gIGludGVyaW0gLS0-IHxcInJlY2hhcmdlIChyKVwifCBjYWxjX2NtZCAtLT4gY21kX291dFtcIkNNRCAoTVtrKzFdKVwiXVxuICBcbiAgaW50ZXJpbSAtLT58XCJlZmZlY3RpdmUgcmFpbmZhbGwgKFVbdF0pXCJ8IHVoKGNhbGNfZnRfZmxvd3MpXG4gIGludGVyaW0gLS0-IHxcInJlY2hhcmdlIChyKVwifCB1aFxuXG4gIHFzW1wiUXVpY2tmbG93IChWW3EsdC0xXSlcIl0gLS0-IHVoXG4gIHNzW1wiU2xvd2Zsb3cgKFZbcyx0LTFdKVwiXSAtLT4gdWhcbiAgbG9zc1tcIkxvc3MgKExbdF0pXCJdIC0tPiB1aFxuXG4gIHVoIC0tPnxcIlF1aWNrZmxvd1t0XVwifCBzZmxvd1tcIlN0cmVhbWZsb3cgKFFba10pXCJdXG4gIHVoIC0tPnxcIlNsb3dmbG93W3RdXCJ8IHNmbG93W1wiU3RyZWFtZmxvdyAoUVtrXSlcIl1cblxuICBzZmxvdyAtLT4gcm91dGluZyhyb3V0aW5nKVxuICBleHRbZXh0cmFjdGlvbl0gLS0-IHJvdXRpbmdcbiAgZ3dbZ3JvdW5kd2F0ZXIgZXhjaGFuZ2VdIC0tPiByb3V0aW5nXG4gIHNjb2VmW1wic3RvcmFnZSBmYWN0b3IgKHMpXCJdIC0tPiByb3V0aW5nXG5cbiAgcm91dGluZyAtLT4gT3V0Zmxvd1xuXG4gIGNsYXNzRGVmIHZhcmlhYmxlIGZpbGw6bGlnaHRibHVlXG4gIGNsYXNzIG1rLEUscmFpbixxcyxzcyxsb3NzLGV4dCxndyxzY29lZiB2YXJpYWJsZVxuXG4gIGNsYXNzRGVmIG5vbmxpbmVhciBmaWxsOmxpZ2h0Z3JlZW5cbiAgY2xhc3MgaW50ZXJpbSxFVCxjYWxjX2NtZCBub25saW5lYXJcblxuICBjbGFzc0RlZiBtVUggZmlsbDpiZWlnZVxuICBjbGFzcyB1aCBtVUgiLCJtZXJtYWlkIjp7fSwidXBkYXRlRWRpdG9yIjpmYWxzZX0)


Here, 
 - rounded boxes represent functions
 - blue boxes represent input factors
 - green functions indicate those relevant to the non-linear loss module
 - the beige function is the relevant unit hydrograph function

Use of any component function may be replaced with an equivalent. For example, `calc_ft_interim_cmd` may be replaced by any other `calc_*_interim_cmd` function, so long as the correct parameters are passed in. See [documentation](https://connectedsystems.github.io/ihacres_nim/ihacres.html) for details.

An implementation example for the Python language, can be found [here](usage.html).


"""

nbSave