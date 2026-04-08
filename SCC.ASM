; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 07/04/2026
; -----------------------------------------------------------
; Derived from 'scc.asm' file of KolibriOS SCC source code
; 2024

	use32
	org 0x0
	jmp	START
		; TRDOS 386 PRG file doesn't contain header
	;dd 0

; ===========================================================
;section '.text' code readable executable
; ===========================================================

	; Compiler tools
	include	"INTRINS.ASM"

	; C Library ("stdio.asm")
	include	"LIBSTD.ASM"

	; Operating System Calls
	include	"OSFUNC.ASM"

_fopen	equ _OS_fopen
_fputc	equ _OS_fputc
_fgetc	equ _OS_fgetc
_fclose equ _OS_fclos

  ; Main program (compiled from C)
	include	"GETARG.ASM"
	include	"CC1.ASM"
	include	"CC2.ASM"
	include	"CC3.ASM"
	include	"CC4.ASM"

START:
	; esp = argc
	; esp+4 = argv[0] address
	pop	eax	; argc (value)
	mov	ebx,esp	; argv[0] address (not value)
	push	eax	; number of arguments
	push	ebx	; argv[0] address
	call	_main
	;add	esp,8
	pop	ebx
_exit_:
	xor	ebx,ebx	; exit code = 0
	mov	eax,1	; sysexit
	int	40h

; ===========================================================
;section '.data' data readable writeable
; ===========================================================

  db 0
  db "Small C Compiler v1.0 for TRDOS 386"
  db 0
  db "Erdogan Tan - 2026"
  db 0

; ===========================================================
; end
