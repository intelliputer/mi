# mi

`mi` contains a self-contained DASM source file for an Atari 2600 ROM.

## Requirements

Install these command-line programs and ensure they are on your `PATH`:

- [DASM](https://dasm-assembler.github.io/) — the 6502 assembler
- [Stella](https://stella-emu.github.io/) — optional, for running the ROM

On Debian or Ubuntu:

```sh
sudo apt-get install dasm stella
```

## Build

From the repository root:

```sh
make
```

This assembles `src/adventure.asm` as a headerless 4 KiB ROM at
`build/adventure.bin`.

To use a DASM executable at a non-default path, set `DASM`:

```sh
make DASM=/path/to/dasm
```

## Run

After building, start the ROM in Stella:

```sh
make run
```

Set `STELLA` when the emulator command has a different name or path:

```sh
make run STELLA=/path/to/stella
```

Stella's usual keyboard controls are arrow keys for movement, Space for
fire, F1 for Select, F2 for Reset, and Escape to leave game mode.

## Validate

Run a non-interactive Stella smoke test:

```sh
make validate
```

This builds the ROM, runs it in Stella for 30 emulated frames, and requires
Stella to save a non-empty PNG snapshot in `build/validation`. The snapshot
is generated output and can be inspected locally when diagnosing a failure.

## Validate dragon-loss experiment

For the full build/emulation workflow and the algorithmic-navigation research
platform, see [Stella validation and navigation notes](docs/STELLA-VALIDATION-AND-NAVIGATION.md).

The local Stella checkout one directory above this repository includes a
frame-indexed input-script extension used for the first gameplay scenario:

```sh
make validate-dragon-loss
```

The scenario is an exploratory route that starts the game and ultimately leads
to a dragon-loss state. It is retained as a reproducible failing policy, not a
yellow-key pickup test. The first F2 enters the level-selection state and the
second starts the game. At 1350 emulated frames, it asserts the former
yellow-key predicate (`$9D=$BF`), which is expected to fail.

The custom Stella binary defaults to `../stella/stella`. Override it when
needed:

```sh
make validate-dragon-loss SCENARIO_STELLA=/path/to/stella
```

## Record an experiment

```sh
make record-dragon-loss
```

This writes a replayable bundle at `build/experiments/dragon-loss/`: the action
trace, per-frame `telemetry.jsonl`, 10-frame keyframe PNGs, a looping
`trajectory.gif`, and a manifest with the ROM hash and final exit status. This
known dragon-loss policy is expected to record a failing yellow-key predicate.

Set `KEYFRAME_INTERVAL` or `GIF_DELAY` (centiseconds per frame) to tune the
visual recording:

```sh
make record-dragon-loss KEYFRAME_INTERVAL=5 GIF_DELAY=4
```

## Clean

Remove generated build output:

```sh
make clean
```
