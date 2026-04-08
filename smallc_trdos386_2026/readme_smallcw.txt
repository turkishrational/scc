!!!! SMALL C Compiler development stage for TRDOS 386 !!!!
!!!! Windows (32 bit) console cersion !!!!

at first...
"smallc1.exe" was created by using tcc (windows)>

c:\tcc>tcc smallc1.c

then... "smallc1.exe" was used for creating "smallc1.asm"

c:\tcc>smallc1
Output file: smallc1.asm
Input file: smallc1.c

finally...

"smallc1.asm" is used (as included by 'smallcw.asm')
for creating "smallcw.exe" via fasm

c:\scc_2026>fasm smallcw.asm SMALLCW.EXE

Erdogan Tan: 05/04/2026 (April 2026)