SMALL C COMPILER (Origin: J.E.Hendrix) for TRDOS386 Operating System
*** 32 bit C compiler, flat memory, FASM output  ***

Modified/Derived from: KolibriOS SCC
Origin: Small C Compiler for MSDOS (J. E. Hendrix)

Operating System depended file (contains TRDOS 386 system calls): OSFUNC.ASM

Major difference from other SCC adaptations/ports:
    In TRDOS 386, STDIN/STDOUT/STDERR (can be used but) are not used in
    same meanings.. SYSSTDIO system call is used instead of SYSREAD/SYSWRITE
    system calls with file handles 0,1,2 for STDIN/STDOUT/STDERR.
    In 'stdio.h' header file, STDIN,STDOUT and STDERR 
    file handles are set to -1 (not 0,1,2 as in other systems).
    This is a signature that directs code to SYSSTDIO system call
    (for putc, getc) instead of SYSREAD/SYSWRITE (fputc, fgetc) system calls.
    (You can see it in 'OSFUNC.ASM' file)
    SYSSTDIO system call can be used to redirect STDIN and STDOUT to a file.
    (But this is not a subject for SCC here.)

Compiling:  fasm scc.asm SCC.PRG  (in Windows or Linux)
    (FASM, flat assembler is used to assemble SCC source code.)

Using compiler: scc cfile
    (use scc without a file name -without an argument- to see options)

SCC compiler output: ASM file
    (label numbers may need to be changed later by using NOTEPAD
    or a similar text editor.)

Assembling: FASM filename.asm
    (Note: 'include' files and a header file 
    -for setting '_main' function, entry point- is needed.
    SCC output file must be included to TRDOS 386 compatible ASM file.
    (There are samples in this SCC repository.)

What is PRG file: 
PRG extension means TRDOS 386 flat image binary/executable
file (like as a .BIN file or similar to MSDOS .COM files but startup address
is 0 not 100h). (TRDOS 386 PRG file size + BSS limit is virtually 4GB-4MB.)

Erdogan Tan - September 2024