import strformat
import nimib

nbInit

nbDoc.title = "IHACRES_nim documentation"

let
  repo = "https://github.com/connectedsystems/ihacres_nim"
  docs = "https://connectedsystems.github.io/ihacres_nim"
  index = read("index.nim".RelativeFile)
  primer = read("primer.nim".RelativeFile)
  usage = read("usage.nim".RelativeFile)
  publications = read("publications.nim".RelativeFile)
  assets = "docs/static"
  highlight = "highlight.nim.js"
  defaultHighlightCss = "atom-one-light.css"


nbText: fmt"""
The IHACRES_CMD rainfall-runoff model written in [nim-lang](https://nim-lang.org).

Motivation
==========

`IHACRES_nim` is an implementation of the IHACRES rainfall-runoff model written in the Nim 
programming language.

Prior implementations (see list in "Other implementations" in the 
[publications](publications.html) page) either do not have the source code available, or 
ties their use to a specific computing environment. Others are embedded as part of a 
modelling suite, and are not directly accessible or reusable. In the usual case, only 
partial support for functionality desirable within an integrated context is provided, such 
as interactions across socio-environmental systems at requisite time steps.

This package provides a common suite of functions with which the model may be applied, and 
is accessible from any language which has a C Foreign Function Interface. The code is 
open-source, under the ISC License, to allow open reuse and experimentation.

This User Guide consists of:

- [Primer](primer.html) - a basic primer on the IHACRES module.
- [Usage](usage.html) - some examples on how to compose IHACRES_nim functions together.
- [API documentation](ihacres.html) - details of each function.
"""


nbSave