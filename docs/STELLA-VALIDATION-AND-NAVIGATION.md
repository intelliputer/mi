# Stella validation and algorithmic-navigation notes

This project now has the beginnings of two related systems:

1. a reproducible build-and-emulation workflow for the 2600 assembly ROM; and
2. an experimental platform for an agent to navigate the running game through
   timed controller inputs and evaluate game state.

They should be kept conceptually distinct. The first answers “does this source
build and run?” The second answers questions such as “can a policy reach this
object without dying?”

## 1. Assembly → ROM → Stella workflow

### Source and output

`src/adventure.asm` is the canonical ROM source. DASM builds it as a 4 KiB
Atari 2600 binary:

```sh
make
```

The generated ROM is `build/adventure.bin`. `build/` is deliberately ignored:
it contains only reproducible output and is recreated by the Makefile. The old
checked-in compile-output directory was therefore not needed.

Useful targets are:

```sh
make                         # assemble src/adventure.asm
make run                     # assemble and open the ROM in installed Stella
make validate                # run Stella and save a short screenshot
make validate-dragon-loss    # run the scripted dragon-loss policy
make record-dragon-loss      # create a replayable experiment bundle
make clean                   # remove build/ output
```

`make validate` is a smoke test, not a gameplay test. It launches the ROM with
audio disabled, asks Stella to take one screenshot, and fails if no non-empty
PNG was created in `build/validation/`.

### Audio and desktop environment

The machine’s audio stack was inspected while bringing up Stella. It is a
healthy PipeWire setup exposing PulseAudio compatibility: PipeWire and
WirePlumber are running, the USB analogue sink is selected, and VLC playback
was active. The automated validation explicitly uses `SDL_AUDIODRIVER=dummy`,
so it neither depends on nor changes the desktop audio configuration.

Stella still needs access to a real graphical session. A restricted terminal
sandbox can report “No available video device”; that is a sandbox/display
restriction, not evidence that PipeWire or Stella is broken. Runs intended to
exercise the SDL display loop should be executed from the desktop session (or
with the required graphical-session permission).

### Local Stella extension

The sibling checkout at `../stella` was configured and built successfully with
all 32 available cores:

```sh
cd ../stella
./configure
make -j32
```

The build required the SDL 3 development dependency, which is now installed.
The resulting executable is `../stella/stella`.

That local Stella checkout contains experimental, currently uncommitted source
changes supporting non-interactive validation:

- `-inputscript FILE` reads a JSON list of frame-indexed emulator events.
- `-snapshotframes N` saves a screenshot and quits after `N` emulated frames.
- `-assertmemory ADDRESS=VALUE` compares an emulated memory byte at snapshot
  time and returns a non-zero process status on mismatch.

The implementation lives in Stella’s `OSystem` and command-line setup code.
Input events are passed to Stella’s normal event handler, rather than changing
the Adventure ROM or spoofing RAM. Thus the ROM receives the same console and
joystick state transitions as a player would.

For scenario tests, the Makefile defaults to this local executable:

```sh
make validate-dragon-loss
```

Use an alternate binary explicitly when needed:

```sh
make validate-dragon-loss SCENARIO_STELLA=/path/to/stella
```

The current custom command-line additions should be reviewed and committed in
the `../stella` repository separately from this ROM repository. They are a
local research extension, not part of upstream Stella yet.

### Why state assertions matter

A 2600 screenshot is useful for diagnosis but is not a sufficiently reliable
test oracle. The visible buffer can be captured during blanking or an
incomplete draw, producing a black or title-like image even when input was
accepted. The custom memory assertion makes tests deterministic and
machine-checkable.

For this ROM, `$9D` is the carried-object byte. Game 1’s yellow key is object
`$BF`; a successful pickup therefore has the postcondition:

```text
RAM[$9D] == $BF
```

This was the predicate used by the attempted yellow-key experiment. A future scenario can
assert a different documented RAM byte, or Stella can be extended to support a
small set of assertions in the JSON file.

### Recorded experiment bundles

`make record-dragon-loss` writes `build/experiments/dragon-loss/`. It contains
the exact copied action trace, a manifest with ROM SHA-256 and run settings,
per-frame `telemetry.jsonl`, numbered PNG keyframes every 10 frames, and a
looping `trajectory.gif`. It records both passing and failing runs; the exit
code is retained in `manifest.json`. Snapshots are supporting evidence rather
than the source of truth. The action trace makes a run replayable, while the
telemetry makes it searchable and suitable for later trajectory analysis.

## 2. Agent-experimental platform for algorithmic navigation

### Scenario representation

`validation/dragon-loss.json` is a simple action trace. Each entry has:

```json
{ "frame": 37, "event": "LeftJoystickDown", "value": 1 }
```

`frame` is the emulated-frame index, `event` is a Stella `Event::Type` name,
and `value` is normally `1` for press and `0` for release. Useful event names
include:

- `ConsoleReset` (the keyboard F2/reset action)
- `LeftJoystickUp`, `LeftJoystickDown`
- `LeftJoystickLeft`, `LeftJoystickRight`

This is a deliberately small action language. An agent can generate a trace,
run it repeatably, then use the exit status and/or final memory values as its
reward signal.

### What was learned about Adventure startup

The disassembly clarifies a non-obvious detail of the game’s startup state
machine. In `CheckGameStart`, the first reset edge takes the ROM through level
selection/setup. A subsequent reset edge starts the active game and places the
player in the yellow castle:

```text
room = $11
x    = $50
y    = $20
```

Game 1 positions the yellow key at:

```text
room = $11
x    = $20
y    = $40
```

Consequently, a trace intended to play must model two F2/reset cycles, not just
one. Holding the reset option only at process startup was insufficient because
this ROM looks for a reset edge relative to its saved switch state.

### Current dragon-loss experiment

The current JSON is an exploratory, non-passing route. It performs the two
startup resets and tries a route around the yellow castle’s internal walls.
It is named for its observed result: the dragon eats the player.
`make validate-dragon-loss` deliberately retains `$9D=$BF` as a failing
yellow-key predicate, rather than creating a false success.

The investigations already established several useful facts:

- The scripted F2 and arrow events reach the running ROM.
- The first F2 alone remains in the number/selection room; the second starts
  gameplay.
- A naive diagonal path from the yellow-castle start is blocked by the castle
  geometry.
- One attempted detour left the intended area and led to a dragon-loss state.
  This is a valuable observation: the runner can expose bad policies and real
  game failure states, not merely replay a cosmetic recording.
- The yellow-key postcondition was not met, so no objective was incorrectly
  recorded as complete.

### A practical experimental loop

An Ariadne/Theseus-style experiment can use the following loop:

1. Build the current assembly source with `make`.
2. Produce a JSON trace from a fixed policy, a search algorithm, or a learned
   controller.
3. Run `make validate-dragon-loss` (or a new target for another goal).
4. Interpret success as a state predicate, and retain diagnostic screenshots
   and failure coordinates for analysis.
5. Change either the trace/policy or `src/adventure.asm`, then repeat.

The disassembly gives semantic anchors for reward design: current room is
`$8A`, player coordinates are `$8B/$8C`, and carried object is `$9D`. At
present the custom Stella diagnostic reports room and player coordinates when
an assertion fails; this is helpful for manually mapping collision geometry.

### Recommended next increments

- Preserve the current dragon-loss trace as a regression/diagnostic case.
- Add a known-safe navigation trace before defining the yellow-key trace as a
  required build gate.
- Extend the JSON schema with explicit assertions such as expected room,
  coordinate ranges, carried object, and “not dead.” This avoids encoding all
  checks only in Makefile command-line arguments.
- Add a structured result file (JSON) containing the final frame, room,
  coordinates, carried object, and assertion status. That will make policy
  search easier than parsing terminal text or inspecting PNGs.
- Keep gameplay experiments deterministic: fixed game level, fixed startup
  sequence, fixed frame budget, temporary Stella configuration directory, and
  disabled audio.
- When modifying the assembly for maze experiments, keep the baseline ROM and
  its scenarios unchanged, then add a scenario and a state predicate for each
  new behavior. This makes intended design changes distinguishable from
  accidental regressions.

## Current status

The infrastructure is proven: the ROM compiles, local Stella builds, scripted
inputs are injected into real emulation, screenshots can be captured, and a
RAM predicate can make the process pass or fail. The yellow-key navigation
policy remains an open research task. Its current failure is useful data, not
a validation success, and should guide the next navigation/search iteration.
