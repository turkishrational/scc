; -----------------------------------------------------------
; Small C Compiler (SCC, Hendrix) "LIBSTD.ASM" (FASM) Test
; Erdogan Tan - 07/04/2026
; -----------------------------------------------------------
; fasm READFILEPRG.ASM READFILE.PRG

	use32
	org 0x0
  	jmp	START	; TRDOS 386 PRG file doesn't contain header

  	dd  0

	include "INTRINS.ASM"
	include "LIBSTD.ASM"
	include "OSFUNC.ASM"
	include "GETARG.ASM"

	; Main program
	include	"READFILE.ASM"

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
@exit:
	xor	ebx,ebx	; exit code = 0
	mov	eax,1	; sysexit
	int	40h

	jmp	short @exit	; hang
