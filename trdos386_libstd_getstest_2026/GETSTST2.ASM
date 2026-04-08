; -----------------------------------------------------------
; Gets - Puts Source Code (Disassembly) Test (by using TCC)
; Erdoðan Tan - 31/03/2026
; -----------------------------------------------------------

; =============== CODE ======================================

; Attributes: bp-based frame

; int __cdecl main(int argc, const char **argv, const char **envp)
_main:

;argc           = dword ptr  8
;argv           = dword ptr  0Ch
;envp           = dword ptr  10h

                push    ebp
                mov     ebp, esp

		mov	eax,_HEADER
		push	eax
		call	_puts
		pop	eax

		mov	eax,_LINE               
		push	eax
		call	_gets
		pop	eax

		mov	eax,-1	; stdout
		push	eax
		mov	eax,13	; CR
		push	eax
		call	_putc
		add	esp,8

		mov	eax,-1	; stdout
		push	eax
		mov	eax,10	; LF
		push	eax
		call	_putc
		add	esp,8

		mov	eax,_LINE
		push	eax
		call	_puts
		pop	eax

		mov	eax,-1	; stdout
		push	eax
		mov	eax,13	; CR
		push	eax
		call	_putc
		add	esp,8

		mov	eax,-1	; stdout
		push	eax
		mov	eax,10	; LF
		push	eax
		call	_putc
		add	esp,8

                leave
                retn


; =============== DATA ======================================

_HEADER:	db 'Text Input: ',0
_LINE:          db 80 dup(0)
