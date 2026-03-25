*** Notes on compiling the Windows (Win32) Console version of the Small C Compiler ***

Required systems:
1) Windows 7 (8,10,11) operating system OR
2) TRDOS 386 or Linux operating system to generate SCC.EXE by using FASM assembler.
   (Because ASM outputs are in FASM syntax)

Compile the following (TRDOS 386 & Windows compatible) C files
Using SCC.PRG on TRDOS 386 operating system or SCC.EXE on Windows operating system.

('cc.h', 'stdio.h' and 'notice.h' must be in the same directory)

> scc cc1.c
> scc cc2.c
> scc cc3.c
> scc cc4.c
> scc libstd.c
> scc getarg.c (not required, original GETARG.ASM can be used)

((Rename/Modify labels in asm files if required.))

and then move SCC's ASM output files to a directory
which includes

FASM.EXE (Windows program)
SCC.ASM (TRDOS 386 version) or SCCW.ASM (Windows 32 bit console version)
INTRINS.ASM
OSFUNC.ASM (or OSFUNCW.ASM for Windows version)
(GETARG.ASM or GETARGW.ASM) files

NOTE: It is better to use existing CC1.ASM (CC1W.ASM for Windows -uppercase file names-),
      CC2.ASM, CC3.ASM, CC4.ASM, LIBSTD.ASM, GETARG.ASM (GETARGW.ASM for Windows)
      files (semi-optimized ASM files) directly with FASM.

Then...

use "FASM.EXE SCCW.ASM SCC.EXE" (or "FASM.PRG SCC.ASM SCC.PRG") 
command (or use 'makescc.bat' or 'makesccw.bat') to make executable SCC file.

Erdogan Tan - 24/03/2026
