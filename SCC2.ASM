; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 06/03/2026
; Last Update: 23/03/2026
; -----------------------------------------------------------
; Modified from 'scc.asm' file (26/09/2024)

;B+ System header
use32
org 0x0
  jmp	START	; TRDOS 386 PRG file doesn't contain header

  dd  0

_fopen	equ _OS_fopen
_fputc	equ _OS_fputc
_fgetc	equ _OS_fgetc
_fclose equ _OS_fclos
_putchar equ _OS_putc
_getc	equ _OS_getc
_putc	equ _OS_putc

  include "INTRINS.ASM"

  include "LIBSTD2.ASM"

  include "OSFUNC2.ASM"

  ; Main program (compiled from C)
  include "SMALLC.ASM"

START:
  ; esp = argc
  ; esp+4 = argv[0] address
  pop	eax	; argc (value)
  mov	ebx,esp	; argv[0] address (not value)
  push	eax	; argc
  push	ebx
  call	_main
  ;add	esp,8
  pop	ebx
  ;
  xor	ebx,ebx	; exit code = 0
  mov	eax,1	; sysexit
  int	40h

  db 0	
  db "Small C Compiler v1.0 for TRDOS 386"
  db 0
  db "Erdogan Tan - 2026"
  db 0	