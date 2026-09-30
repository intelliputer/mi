## How to compile assembly code for games on the Atari 2600

This article was written to take a look at the basic tools to compile and run Atari 2600 games in the emulator. Afterwards we’ll use the open source code from some popular games to test it. So, if you want to write a program to run in the processor 6502 with assembly code — used by Atari 2600 — here you will learn how to start. If you remember having a good time playing Atari games this post is for you.

_Install Stella emulator_ *Done*

The first tool you need to install is the emulator. Stella is an open source emulator multi-platform for Atari 2600. Read more about Stella history.

Go to the download page and choose the correct version to your operating system — Linux, Mac or Windows — download and install to the appropriate OS system version.

For debian-based linux just run the command below:

`sudo apt-get install stella`

Once Stella is installed, you are able to open the emulator and load the game image (aka ROM). Type stella on the prompt. I encourage you to take a look at this user’s guide.

_Install dasm 8-bit macro assembler_ *Done*

dasm is a macro assembler used to assemble binary data for 8-bit microprocessors like MOS 6502 used by Atari. This is a great tool for coding demos on the Atari 2600. Download the latest version of dasm and install for your operation system.

For debian-based linux use the command below:

`sudo apt-get install dasm `

As an example, consider that the file mygame.asm contains the assembly code, the command below is used to assemble the asm file to a binary file:

`dasm mygame.asm -omygame.bin -f3`

The name of the source code and the binary file is the same mygame. The -o tells DASM which name will be used for the output, -ofilename. The output format used is -f3. It indicates the output file contains data only without header information. For more details about the commands, please take a look at the documentation.

If you use VS Code you can use a extension dasm macro assembler to make things easier.

_Compile the Assembly Code_

We are ready to assembly a game. I chose the game Gene Medic. Gene Medic is a homebrew game and you can know more about it accessing the official page.

If you have the source code of other games you can use it in this step. I have a GitHub respository with some assembly codes, feel free to use anyone them.

Use the following commands in sequence to assembly and run the game with Stella.


mkdir genemedic
cd genemedic

wget https://atariprojects.org/wp-content/uploads/2019/01/macro.h
wget https://raw.githubusercontent.com/johnidm/asm-atari-2600/master/vcs.h

wget https://raw.githubusercontent.com/moorejh28/genemedic/master/genemedic.asm

dasm genemedic.asm -ogenemedic.bin -f3
vcs.h and macro.h are two important files that include some important assembly macros. Same assemblies code will eventually need these files.

Get Johni Douglas Marangon’s stories in your inbox
Join Medium for free to get updates from this writer.

Enter your email
Subscribe

Remember me for faster sign in

Once the assembler is finished, you should be able to load the binary produced into the Stella emulator with the command below:

stella genemedic.bin -fullscreen 1
Stella keyboard controller
The Atari 2600 console controls are mapped to the computer’s keyboard as following:

Escape — Exit game mode/enter launcher mode
F1 — Select Game
F2 — Reset Game
Up arrow — Joystick up
Down arrow — Joystick down
Left arrow — Joystick left
Right arrow — Joystick right
Space — Fire button
Those are all commands that you need to know to play the games.

Running an existing ROM file
If you search the internet probably you are find a lot of ROMs from the classical games to run in Stella. Two interesting places to find games are AtariMania and My Abandonware. So, just download the game ROM and run with Stella.

Let’s play the Keystone Kapers game using a ROM:

wget https://raw.githubusercontent.com/johnidm/asm-atari-2600/master/ROMs/Keystone-Kapers.bin

stella Keystone-Kapers.bin -fullscreen 1
Before open the ROM with Stella press F2 and enjoy it.

