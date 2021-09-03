import nimpy
import climate
import cmd
import flow
import node

# include climate, cmd, flow
export climate, cmd, flow, node

proc test(): int {.exportpy.} =
    return 1