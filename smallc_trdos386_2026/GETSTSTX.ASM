; -----------------------------------------------------------
; Gets - Puts Source Code (Disassembly) Test (by using TCC)
; Erdoðan Tan - 02/04/2026
; -----------------------------------------------------------

	use32
	org 0x0
  	jmp	START	; TRDOS 386 PRG file doesn't contain header

  	dd  0

define	TRDOS386 1	; getchar echo (for '_gets:' in 'LIBSTD2.ASM')

_fopen	equ _OS_fopen
_fputc	equ _OS_fputc
_fgetc	equ _OS_fgetc
_fclose equ _OS_fclos
_putchar equ _OS_putc
_getc	equ _OS_fgetc	; !
_putc	equ _OS_fputc	; !

	include "INTRINS.ASM"
	include "LIBSTD2.ASM"
	include "OSFUNC2.ASM"
	; Main program (compiled from C)
	include "GETSTST2.ASM"
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

; -----------------------------------------------------------	
	; END