# Required prior to any Nim module import
import nimporter

from ihacres import climate
from ihacres import flow
from ihacres import cmd as ihacres_cmd

nimporter.build_nim_extensions()  # Build Nim extension


def run(cmd, rainfall, evaporation, inflow, quickflow, slowflow, gw_state, gw_exchange, extraction):
    '''Example run function.

    Parameters
    ----------
    cmd : catchment moisture deficit, $M_{k}$ in the literature.
    rainfall : precipitation ($P$)
    evaporation : ($E$)
    inflow : flow from previous node
    quickflow : quickflow at previous time step, $(V_{q-1})$
    slowflow : slowflow at previous time step, $(V_{s-1})$
    gw_state : groundwater storage index at $t-1$
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
                                         catchment_area, a, b)

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
run.d = 200.0  # flow threshold
run.d2 = 2.0   # flow threshold, multiplier applied to `d`
run.e = 0.1    # temperature to PET conversion factor
run.f = 0.1    # plant stress threshold factor (applied to `d`). Determines effective rainfall.
run.a = 54.35  # quickflow scaling factor
run.b = 0.012  # slowflow scaling factor
run.alpha = 0.727   #  effective rainfall scaling factor
run.s = 2.5  # groundwater store factor
run.catchment_area = 100.0  # area in km^2


# Initial conditions
cmd, quickflow, slowflow = 214.65, 0, 0

# Assume these are all 0.0
inflow = 0.0
gw_exchange = 0.0
extraction = 0.0

rainfall_ts = [70.0, 10.0, 0.0, 0.0, 200]
evaporation_ts = [2.0, 6.5, 7.0, 5.0, 1.0]

# Record state
outflow = [None] * len(rainfall_ts)
gw_state = [None] * (len(rainfall_ts)+1)
gw_state[0] = 0.0

for i in range(len(outflow)):
    progress = run(cmd, rainfall_ts[i], evaporation_ts[i], inflow, quickflow, slowflow, 
                   gw_state[i], gw_exchange, extraction)
    quickflow, slowflow, cmd = progress["state"]
    gw_state[i+1], outflow[i] = progress["flow"]

# Remove initial gw state to line up records
gw_state = gw_state[1:]

print(outflow)