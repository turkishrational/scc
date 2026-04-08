; -----------------------------------------------------------
; Small C Compiler (Roy Cain) for TRDOS 386 (v2.0.9 & later)
; Erdogan Tan - 2026 !!! Modified for FASM syntax !!!
; Beginning: 27/03/2026
; Last Update: 07/04/2026
; -----------------------------------------------------------
; Derived from 'smc386c.c' file 
;	of adamsch1's 'scc' repository in GitHub
;
; https://github.com/adamsch1/scc (smc386c.c)

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
_getc	equ _OS_fgetc	; !
_putc	equ _OS_fputc	; !

	include "INTRINS.ASM"

	include "LIBSTD2.ASM"

	include "OSFUNC2.ASM"

	; Main program (compiled from C)
	include "SMALLC0.ASM"

START:
  	; esp = argc
  	; esp+4 = argv[0] address
	pop	eax	; argc (value)
	mov	ebx,esp	; argv[0] address (not value)
	push	eax	; argc
	push	ebx

	; clear bss
	mov	ecx, bss_end-bss_start
	shr	ecx, 2
	xor	eax, eax
	mov	edi, bss_start
	rep	stosd

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

	align 4

bss_start:
	_tolitstk: rd 1
	_litstk: rb 5000
	_litstk2: rb 5000
	_litstkle: rd 10
	_litstkpt: rd 10
	_SYMTAB: rb 5040
	_glbptr: rd 1
	_locptr: rd 1
	_wq: rd 300
	_wqptr: rd 1
	_litq: rb 8000
	_litptr: rd 1
	_macq: rb 3000
	_macptr: rd 1
	_line: rb 80
	_mline: rb 80
	_lptr: rd 1
	_mptr: rd 1
	_field_of: rd 1
	_nxtlab: rd 1
	_litlab: rd 1
	_Zsp: rd 1
	_argstk: rd 1
	_argtop: rd 1
	_ncmp: rd 1
	_errcnt: rd 1
	_errstop: rd 1
	_eof: rd 1
	_input: rd 1
	_output: rd 1
	_input2: rd 1
	_glbflag: rd 1
	_ctext: rd 1
	_cmode: rd 1
	_lastst: rd 1
	_mainflg: rd 1
	_saveout: rd 1
	_kandr: rd 1
	_fnstart: rd 1
	_lineno: rd 1
	_infunc: rd 1
	_savestar: rd 1
	_saveline: rd 1
	_saveinfn: rd 1
	_currfn: rd 1
	_savecurr: rd 1
	_quote: rb 2
	_cptr: rd 1
	_iptr: rd 1

	align 4
bss_end: