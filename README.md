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

## Clean

Remove generated build output:

```sh
make clean
```

