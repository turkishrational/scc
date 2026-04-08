; Windows (32bit) Console Version - 12/03/2026
; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 07/04/2026
; -----------------------------------------------------------

	format PE console
	use32
	entry START

; ===========================================================
section '.text' code readable writeable executable
; ===========================================================

	; Compiler tools
	include	"INTRINS.ASM"

  	; C Library ("stdio.asm")
	include	"LIBSTD2.ASM"

	; Operating System Calls
	include	"OSFUNCW2.ASM"

_fopen	equ _OS_fopen
_fputc	equ _OS_fputc
_fgetc	equ _OS_fgetc
_fclose equ _OS_fclos
_putchar equ _OS_putc
_getc	equ _OS_fgetc	; !
_putc	equ _OS_fputc	; !

  ; Main program (compiled from C)
	;include "GETARGW.ASM"
	include	"HELLO2.ASM"

START:
	;call	get_commandline

	push	STD_INPUT_HANDLE
	call	[GetStdHandle]
	mov	[stdin],eax

	push	STD_OUTPUT_HANDLE
	call	[GetStdHandle]
	mov	[stdout],eax

	mov	dword [u_break], _m_start_
	mov	dword [bss_end], _m_end_

	push	dword [argc]	; number of arguments
	push	argv		; argv[0] address
	call	_main
	;add	esp,8
_exit:
	push	0               ; Exit Code
	call	[ExitProcess]
	jmp	short _exit	; hang

; ===========================================================
section '.data' data readable writeable
; ===========================================================

; OSFUNC.ASM

malloc_err_msg:
  db 0Dh,0Ah
  db 07h  ; beep !
  db "Memory Allocation Error!"
  db 0Dh,0Ah,0

lpdword: dd 1
character: db '@'

; ===========================================================
section '.bss' data readable writeable
; ===========================================================

align 4

cmdline_buf:	rb 256
stdin:		rd 1
stdout:		rd 1
argc:		rd 1
argv:		rd 16
;lpdword:	rd 1
bss_end:	rd 1
u_break:	rd 1
_m_start_:
		rb (16384-344)
_m_end_:

; ===========================================================
section '.idata' import data readable writeable
; ===========================================================

  dd 0,0,0,rva kernel_name,rva kernel_table
  dd 0,0,0,0,0

  kernel_table:
    GetCommandLineA dd rva _GetCommandLineA
    WriteFile dd rva _WriteFile
    CreateFileA dd rva _CreateFileA
    CloseHandle dd rva _CloseHandle
    ReadFile dd rva _ReadFile
    GetStdHandle dd rva _GetStdHandle
    ExitProcess dd rva _ExitProcess
    dd 0

  kernel_name db 'KERNEL32.DLL',0

  _GetCommandLineA dw 0
    db 'GetCommandLineA',0
  _WriteFile dw 0
    db 'WriteFile',0
  _CreateFileA dw 0
    db 'CreateFileA',0
  _ReadFile dw 0
    db 'ReadFile',0
  _CloseHandle dw 0
    db 'CloseHandle',0
  _GetStdHandle dw 0
    db 'GetStdHandle',0
  _ExitProcess dw 0
    db 'ExitProcess',0

; ===========================================================================
; end
