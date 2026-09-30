# Validation evidence

`dragon-loss.json` is the replayable timed-input trace for the observed
dragon-loss policy. `dragon-loss-trajectory.gif` is the preserved visual record
from the corresponding 1,350-frame Stella run.

The GIF contains 135 keyframes captured every 10 emulation frames. Its first
frame is the ROM's title screen; subsequent frames show the transition into
the game and the complete recorded trajectory. The run did not satisfy the
yellow-key predicate (`RAM[$9D] == $BF`); its final manifest recorded exit
status `1` and no carried object (`$A2`).

The runnable experiment output remains generated under
`build/experiments/dragon-loss/`. This GIF is intentionally retained here as
versioned visual evidence, so it is not replaced by subsequent runs.
