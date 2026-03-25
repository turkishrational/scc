; -----------------------------------------------------------
; FASM (& SCC) TEST -ASM- FILE (for Win32 and TRDOS 386)
; -----------------------------------------------------------
; 23/03/2024

_main:
	PUSH	EBP
	MOV	EBP,ESP

	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]

	CMP	EAX,1
	JA	short _main_@
	MOV	EAX,USAGE
	PUSH	EAX
	call	_puts
	;POP	EAX
	JMP	short _main_retn ; usage

_main_@:
	MOV	DWORD [_argcs],EAX	; argc; (value)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	DWORD [_argvs],EAX	; argv; (address)

	MOV	EAX,128	; LINESIZE
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_line],EAX

	CALL	_readfile

_main_retn:
	MOV	ESP,EBP
	POP	EBP
	RETN

USAGE:
	db "FASM (& SCC) Test File for TRDOS 386 v2",13,10
	db "Erdogan Tan - 2026",13,10
	db 13,10
	db "Usage: READFILE FILENAME.TXT"
NEWLINE:
	db 13,10,0
	
_argcs:	dd 0
_argvs: dd 0

_line:	dd 0	
_output:
	dd -1
_input: dd 0
	
_readfile:
	PUSH	EBP
	MOV	EBP,ESP
	;ADD	ESP,-4
	XOR	EAX,EAX
	;MOV	[EBP-4],EAX ; 0
	PUSH	EAX ; 0

	;MOV	DWORD [_output],-1 ; stdout

	; getarg(1, line, LINESIZE, argcs, argvs)
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	INC	EAX ; 1	
	MOV	[EBX],EAX
	PUSH	EAX
	MOV	EAX,[_line]
	PUSH	EAX
	MOV	EAX,128	; LINESIZE
	PUSH	EAX
	MOV	EAX,[_argcs] ; argc (value)
	PUSH	EAX
	MOV	EAX,[_argvs] ; argv[] (address)
	PUSH	EAX
	CALL	_getarg
	ADD	ESP,20
	MOV	EBX,EAX
	MOV	EAX,-1	; EOF
	CALL	__ne	; != EOF
	OR	EAX,EAX
	JZ	short _readfile_rtn ; EOF
	CALL	_openfile
	CALL	_readf
_readfile_rtn:
	MOV	ESP,EBP
	POP	EBP
	RETN

_openfile:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,-1	; EOF;
	MOV	[_input],EAX ; input = EOF;
		; input = mustopen(pline, "r");
	MOV	EAX,[_line]
	PUSH	EAX
	MOV	EAX,OPEN_R	; 'r'
	PUSH	EAX
	CALL	_mustopen
	;ADD	ESP,8
	MOV	[_input],EAX ; ! file handle + 1
	MOV	ESP,EBP
	POP	EBP
	retn

_mustopen:
	; mustopen(fn, mode) char *fn, *mode; {
	PUSH	EBP
	MOV	EBP,ESP
	;*ADD	ESP,-4 ; int fd; ; TRDOS 386
	;LEA	EAX,[EBP-4]
	;PUSH	EAX
	LEA	EBX,[EBP+12] ; file name
	MOV	EAX,[EBX]
	PUSH	EAX	; fn
	LEA	EBX,[EBP+8] ; open mode
	MOV	EAX,[EBX]
	PUSH	EAX	; mode
	CALL	_OS_fopen
	ADD	ESP,8
	;POP	EBX
	;*LEA	EBX,[EBP-4] ; fd = fopen(fn, mode)
	;*MOV	[EBX],EAX ; file handle + 1 (for TRDOS 386)
	OR	EAX,EAX
	JZ	short _mo_error
			; error (file not found or access err)
_mo_retn:
	;LEA	EBX,[EBP-4] ; fd
	;MOV	EAX,[EBX]  ; return fd
	; eax = file handle + 1
	MOV	ESP,EBP
	POP	EBP
	RETN
_mo_error:		; puts("open error on ");
	MOV	EAX,OPEN_ERR
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	LEA	EBX,[EBP+12] ; file name
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_puts	; puts(fn);
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,NEWLINE
	PUSH	EAX
	CALL	_puts	; puts(NEWLINE); (putc(NEWLINE);
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,7	; exit(ERRCODE);
	PUSH	EAX
	CALL	_OS_exit
	;ADD	ESP,4
	MOV	ESP,EBP
	POP	EBP
	RETN

OPEN_ERR: DB "open error on ", 0
OPEN_R:  DB "r",0

_readf:
	PUSH	EBP
	MOV	EBP,ESP
_read_loop:
	MOV	EAX,[_input] ; file handle + 1 (TRDOS 386)
	PUSH	EAX
	CALL	_OS_fgetc ; _fgetc
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _readf_rtn
	PUSH	EAX	; character (in AL)
	;CALL	_OS_putc ; _putc
	;ADD	ESP,4
	MOV	EAX,-1	; STDOUT for TRDOS 386
	PUSH	EAX
	CALL	_OS_fputc ; _fputc
	ADD	ESP,8
		; read/write next char if not EOF
	JMP	short _read_loop
_readf_rtn:	
	MOV	ESP,EBP
	POP	EBP
	RETN	
