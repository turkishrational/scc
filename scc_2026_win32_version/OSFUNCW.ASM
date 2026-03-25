; Windows (32bit) Console Version - 12/03/2026
; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 23/03/2026
; -----------------------------------------------------------
; Derived from 'osfunc.asm' file of KolibriOS SCC source code
; 2024

CREATE_ALWAYS	  = 2
OPEN_EXISTING	  = 3

FILE_SHARE_READ   = 1

GENERIC_READ	  = 80000000h
GENERIC_WRITE	  = 40000000h

STD_INPUT_HANDLE  = 0FFFFFFF6h
STD_OUTPUT_HANDLE = 0FFFFFFF5h
STD_ERROR_HANDLE  = 0FFFFFFF4h

;Main OS functions

_OS_fopen:
	;Implement "fopen"
	; esp+4 - mode
	; esp+8 - file name

	mov	eax,[esp+4] ; file open mode
	mov	ebx,[esp+8] ; file name

	cmp	byte [eax],'r'
	je	short open_read
	cmp	byte [eax],'w'
	je	short open_write

	; bad mode
	xor	eax,eax ; 0 ; invalid open mode
open_rw_error:
	retn

open_read:	; open for read
	push	0		; hTemplateFile
	push	0		; dwFlagsAndAttributes
	push	OPEN_EXISTING	; dwCreationDisposition
	push	0		; lpSecurityAttributes
	push	FILE_SHARE_READ	; dwShareMode
	push	GENERIC_READ	; dwDesiredAccess
	jmp	short open_rw

open_write:	; open for write
	push	0		; hTemplateFile
	push	0		; dwFlagsAndAttributes
	push	CREATE_ALWAYS	; dwCreationDisposition
	push	0		; lpSecurityAttributes
	push	FILE_SHARE_READ	; dwShareMode
	push	GENERIC_WRITE	; dwDesiredAccess
open_rw:
	push	ebx		; lpFileName
	call    [CreateFileA]
	;mov	[hFile],eax
	; eax = 0FFFFFFFFh = INVALID_HANDLE_VALUE
	inc	eax
	; eax = 0 -> not found or access error
	; eax > 0 -> ok
	jz	short open_rw_error
	; 23/03/2026
	; eax = file handle + 1
	retn

_OS_fclose:
;Close file
	; esp+4 - file handle

	mov	ebx,[esp+4] ; file handle + 1
	; 23/03/2026
	dec	ebx ; file handle
	push	ebx
	call	[CloseHandle]
	retn

_OS_fgetc:
	;Load char from file
	; esp+4 - input file

	mov	ebx,[esp+4] ; file handle + 1
	; -1 -> STDIN
	inc	ebx ; -1 -> 0
	jz	short _OS_getc ; 16/09/2024

	dec	ebx	; file handle + 1
	; 23/03/2026
	dec	ebx	; file handle

sys_read:
	push	0	; lpOverlapped
	push	lpdword	; lpNumberOfBytesRead
	push	1	; nNumberOfBytesToRead
	push	character ; lpBuffer
	push	ebx	; file handle
	call	[ReadFile]
	or	eax, eax
	jz	short sys_read_eof
	mov	eax,[lpdword] ; must be 1
	;or	eax,eax
	;jnz	short _OS_fgetc_ok
	cmp	eax,1
	je	short _OS_fgetc_ok
sys_read_eof:
	; eax = 0 -> file read error
	; 23/03/2026
	mov	eax,-1	; EOF
	retn
_OS_fgetc_ok:
	mov	al,[character]
	retn

_OS_getc:
	mov	ebx,[stdin] ; console
	jmp	short sys_read

_OS_fputc:
	;Save char to file
	; esp+4 - output file
	; esp+8 - char to write

	mov	ecx,[esp+8]

	mov	ebx,[esp+4] ; file handle + 1
	; -1 -> STDOUT/STDERR (TRDOS 386)
	inc	ebx ; -1 -> 0
	jz	short _OS_putc_@ ; 16/09/2024

	dec	ebx	; file handle + 1
	; 23/03/2026
	dec	ebx	; file handle

sys_write:
	mov	[character],cl
sys_write_@:
	push	0	; lpOverlapped
	push	lpdword	; lpNumberOfBytesWritten
	push	1	; nNumberOfBytesToWrite
	push	character ; lpBuffer
	push	ebx	; file handle
	call	[WriteFile]
	; eax = 0 -> file write error
	retn

_OS_putc:
	;Write char to screen
	; esp+4 - char to write

	mov	ecx,[esp+4]
_OS_putc_@:
	mov	ebx,[stdout] ; console
	jmp	short sys_write

_OS_calloc:
	; 12/03/2026
	; TRDOS 386 (sys _break) _OS_calloc simulation
	;	for Windows 32 bit console version
	; (For CC1.ASM compatibility with TRDOS 386 version of SCC,
	;  allocating a new memory block in heap/bss
	;  < sys _break system call subject > is simulated by
	;  using existing bss memory block without using windows
	;  relevant/complex windows/win32 functions.)

	; Alloc memory

	mov	eax,[u_break]
		; the start value is u_break address + 4.
	add	eax,3
	and	al,not 3 ; dword aligned allocation (malloc) address

	push	eax ; *
	mov	eax,[esp+8] ; element size (integer=4)
	mov	ebx,[esp+12] ; structure/area length (element count)
	mul	ebx
	pop	edx ; *
	add	eax,edx

	; new break point - old break point = allocation size

	cmp	eax,[bss_end]
	ja	short calloc_err

	mov	[u_break],eax
	mov	eax,edx

	retn

calloc_err:
	; write "malloc error" message to STDERR
	mov	esi,malloc_err_msg
	mov	ebx,[stdout] ; file handle (console)
.calloc_err_p:
	lodsb
	or	al,al
	jz	short .calloc_err_x
	mov	[character],al
	call	sys_write_@
	jmp	short .calloc_err_p

.calloc_err_x:
	mov	ebx,-1
	jmp	short _OS_exit_@

_OS_exit:
	mov	ebx,[esp+4]	; exit code ; 13/09/2024
_OS_exit_@:
	call	[ExitProcess]
	retn		; normally cpu must not come here !
