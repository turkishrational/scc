***Notes on compiling the TRDOS 386 version of the Small C Compiler
using the compiler itself (self-compilation)***

Required systems:
1) TRDOS 386 Floppy or Disk to run on real computer or emulator
2) Windows or Linux operating system to generate SCC.PRG using FASM compiler.
   (Because ASM outputs are in FASM syntax)   

Compile the following (TRDOS 386 compatible) C files
Using SCC.PRG on TRDOS 386 operating system (floppy disk or disk):

('cc.h', 'stdio.h' and 'notice.h' must be in the same directory)

> scc cc1.c
> scc cc2.c
> scc cc3.c
> scc cc4.c
> scc libstd.c
> scc getarg.c (not required, original GETARG.ASM can be used)

and then move SCC's ASM output files to a directory
which includes

FASM.EXE (window program)
SCC.ASM (TRDOS 386 version)
INTRINS.ASM
(GETARG.ASM) files

(precompiled files: CC1.ASM,CC2.ASM,CC3.ASM,CC4.ASM,LIBSTD.ASM)

Later...

to use

> FASM SCC.ASM to create SCC.BIN

and finally rename SCC.BIN to SCC.PRG.

Erdogan Tan - 24/09/2024






 