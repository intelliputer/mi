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

## Validate yellow-key pickup

For the full build/emulation workflow and the algorithmic-navigation research
platform, see [Stella validation and navigation notes](docs/STELLA-VALIDATION-AND-NAVIGATION.md).

The local Stella checkout one directory above this repository includes a
frame-indexed input-script extension used for the first gameplay scenario:

```sh
make validate-yellow-key
```

The scenario presses and releases Reset (F2), then holds Left and Up long
enough to move the player from `(0x50, 0x20)` to the yellow key at
`(0x20, 0x40)`. The first F2 enters the level-selection state and the second
starts the game. At 1350 emulated frames, Stella asserts that Adventure's
carried-object byte is `$BF` at RAM address `$9D`—the yellow-key object—and
saves a snapshot to `build/validation`.

The custom Stella binary defaults to `../stella/stella`. Override it when
needed:

```sh
make validate-yellow-key SCENARIO_STELLA=/path/to/stella
```

## Record an experiment

```sh
make record-yellow-key
```

This writes a replayable bundle at `build/experiments/yellow-key/`: the action
trace, per-frame `telemetry.jsonl`, periodic keyframe PNGs, and a manifest with
the ROM hash and final exit status. The current yellow-key route is exploratory
and is expected to record a failing outcome until a safe route is found.

## Clean

Remove generated build output:

```sh
make clean
```
