; Windows (32bit) Version - 12/03/2026
; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 14/09/2024
; -----------------------------------------------------------
; Derived from 'getarg.asm' file of KolibriOS SCC source code
; 2024

; Win32
; =============== S U B R O U T I N E =======================

get_commandline:
	call    [GetCommandLineA]
	mov     esi,eax
	mov     edi,cmdline_buf
	mov     ecx,256
.get_cmdline_lop:
	lodsb
	cmp     al,0
	stosb
	loopne  .get_cmdline_lop
	mov     byte [edi-1],0
	mov     esi,cmdline_buf
 	mov     edi,cmdline_buf
	mov	edx,argv	; & argv[0]
	mov	dword [argc],0
.get_items_lop:
	call    _@@get_item
	mov     al,[ebx]
	cmp     al,0
	jz      short .done
	inc	dword [argc]	; argument count
	mov	[edx],ebx	; argv[x]
	add	edx,4
	cmp	edx,argv+64	; max. 16 arguments
	jb	short .get_items_lop
.done:
	retn

; Win32
; =============== S U B R O U T I N E =======================

_@@get_item:
	lodsb
	dec	al
	cmp	al,1Fh		; 20-1
	jbe	short _@@get_item ; _@@skip_spc_lop
	dec	esi
	mov	ebx,edi
	mov	ah,0		; flag initially not quoted
.char_lop:
	lodsb
	cmp	al,'"'
	jnz	short .no_quote
	xor	ah,1
	jmp	short .char_lop
.no_quote:
	stosb
	cmp	al,0
	jz	short .src_end
	cmp	al,20h
	ja	short .char_lop
	cmp	ah,0	; ignore spaces if inside "quoted area"
	jnz	short .char_lop
	mov	byte [edi-1],0	; eol (replace space by 00h)
	retn
.src_end:
	dec	esi
	retn

; =============== S U B R O U T I N E =======================

; Get command line argument. 
; Entry: n    = Number of the arguments.
;        s    = Destination string pointer.
;        size = Size of destination string.
;        argc = Argument count from main().
;        argv = Argument vector(s) from main().
; Returns number of characters moved on success,
; else EOF.

_getarg:	; int n; char *s; int size,argc,argv[];
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8  ; char *str; int i;
	LEA	EAX,[EBP+24] ; n
	MOV	EBX,[EAX] ; if(n<0 | n>=argc)
	XOR	EAX,EAX	  ; 0
	CALL	__lt	; if(n<0
	PUSH	EAX	; 0 (false) or 1 (true)
	;LEA	EBX,[EBP+24]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	PUSH	EBX	; n
	LEA	EBX,[EBP+12] ; argc
	MOV	EAX,[EBX]
	POP	EBX
	CALL	__ge	; | n>=argc)
	POP	EBX
	OR	EAX,EBX	; (condition 1 or condition 2)
	;OR	EAX,EAX
	;JNZ	short _0_3
	JZ	short _0_2 ; }
_0_3:		; {*s=NULL;
	LEA	EAX,[EBP+20] ; pointer to *s address
	MOV	EBX,[EAX]  ; (ebx = address of *s)
	XOR	EAX,EAX	; NULL
	MOV	[EBX],AL ; *s=NULL;  ; ([ebx] = s value)
	MOV	EAX,-1	; return EOF;
	MOV	ESP,EBP
	POP	EBP
	RETN
_0_2:		; }
	LEA	EBX,[EBP-8]
	;XOR	EAX,EAX
	; eax = 0
	MOV	[EBX],EAX ; i=0;
	LEA	EAX,[EBP-4]
	PUSH	EAX	; str
	LEA	EBX,[EBP+8] ; pointer to argv[]
	MOV	EAX,[EBX]
	PUSH	EAX	; argv[] (address)
	LEA	EBX,[EBP+24] ; n
	MOV	EAX,[EBX]
	POP	EBX
	SHL	EAX,1
	SHL	EAX,1	; n*4
	ADD	EBX,EAX	; argv[0]+4*n
	MOV	EAX,[EBX]	; argv[n]
	POP	EBX		; str (address)
	MOV	[EBX],EAX	; str = argv[n]
_0_4:		; while(i<size)
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX	; i
	LEA	EBX,[EBP+16] ; pointer to size
	MOV	EAX,[EBX]
	POP	EBX
	CALL	__lt	; is i<size ?
	OR	EAX,EAX
	JZ	short _0_5 ; false, jump to s[i]=NULL;
_0_6:		; true, if((s[i]=str[i])==NULL) break;
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]
	PUSH	EAX	; s (address)
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX] ; i (value)
	POP	EBX
	ADD	EAX,EBX	; (i offset from start of s)
	PUSH	EAX	; s[i]
	LEA	EBX,[EBP-4] ; pointer to of *str address
	MOV	EAX,[EBX]   ; str
	PUSH	EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	POP	EBX	; str (address)
	ADD	EBX,EAX	; (i offset from start of str)
	MOVSX	EAX,BYTE [EBX] ; char str[i]
	POP	EBX	; s[i]
	MOV	[EBX],AL ; s[i] = str[i]
	OR	EAX,EAX	; if((s[i]=str[i])==NULL
	JZ	short _0_5 ; break;
_0_7:		; else, ++i;
	LEA	EBX,[EBP-8]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX] ; ++i
	JMP	short _0_4  ; jump to while(i<size)
_0_5:
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]
	PUSH	EAX	; s
	LEA	EBX,[EBP-8] 
	MOV	EAX,[EBX] ; i
	POP	EBX
	ADD	EBX,EAX	; start of s + i = s[i]
	;PUSH	EAX	; i
	;XOR	EAX,EAX	; NULL
	;MOV	[EBX],AL ; s[i]=NULL;
	MOV	BYTE [EBX],0
	;;LEA	EBX,[EBP-8]
	;;MOV	EAX,[EBX]
	;POP	EAX 	; return i;
	MOV	ESP,EBP
	POP	EBP
	RETN
