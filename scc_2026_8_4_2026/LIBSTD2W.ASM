; Windows (32bit) Console Version - 04/04/2026
; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 04/04/2026
; -----------------------------------------------------------
; Derived from 'libstd.asm' file of KolibriOS SCC source code
; 2024

;NOTE: The assembly source code will be more optimized later.
;  For now (current version), semi-optimized source code
;  will be preserved for comparison with existing C code.
;Erdogan Tan - 11/09/2024

; TRDOS 386 v2 modification
; Write string to standard output.
;
;puts(string) char *string;
;{while(*string)
;     OS_putc(*string++);
; OS_putc('\n');

_puts:
	PUSH	EBP
	MOV	EBP,ESP
_puts_1:
	LEA	EBX,[EBP+8]	; (*string)
	MOV	EDX,[EBX] 	; string's itself
	MOVSX	EAX,BYTE [EDX]	; char in string
	OR	EAX,EAX
	JZ	short _puts_2
	INC	DWORD [EBX]	; (*string++);
	PUSH	EAX
	;MOV	CL,1 ; 1 argument
	CALL	_OS_putc
	;ADD	ESP,4
	POP	EAX
	JMP	short _puts_1
_puts_2:
	POP	EBP
	RETN

;/* TRDOS 386 v2 modification */
;putc(c) char *c;
;{
; OS_putc(*c);
;}
;
;getc()
;{
;return(OS_getc());
;}
;
;_putc:		; putchar (to stdout)
;	PUSH	EBP
;	MOV	EBP,ESP
;	LEA	EAX,[EBP+8]
;	MOV	EBX,[EAX]
;	MOVSX	EAX,BYTE [EBX]
;	PUSH	EAX
;	;MOV	CL,1
;	CALL	_OS_putc
;	ADD	ESP,4
;	POP	EBP
;	RETN
;
;_getc:		; getchar (from stdin)
;	;PUSH	EBP
;	;MOV	EBP,ESP
;	;XOR	CL,CL
;	CALL	_OS_getc
;	;POP	EBP
;	;RETN

; reverse string in place

_reverse:			; reverse(s) char *s;
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8		; char *j; int c;
	LEA	EBX,[EBP+8]	; j=s+strlen(s)-1;
	MOV	EAX,[EBX]
	PUSH	EAX ; *
	PUSH	EAX
	;MOV	CL,1
	CALL	_strlen
	;ADD	ESP,4
	POP	EBX
	POP	EBX ; *
	ADD	EAX,EBX
	;SUB	EAX,1
	DEC	EAX
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
_lib_3:				; while(s<j)
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	LEA	ECX,[EBP-4]
	MOV	EAX,[ECX]
	CALL	__ult
	OR	EAX,EAX
	JNE	short _lib_5
_lib_4:
	MOV	ESP,EBP
	POP	EBP
	RETN
_lib_5:
	LEA	ECX,[EBP-8]	; c=*s;
	;LEA	EDX,[EBP+8]
	;MOV	EBX,[EDX]
	MOVSX	EAX,BYTE [EBX]
	MOV	[ECX],EAX
	;LEA	EDX,[EBP+8]	; *s++ =*j;
	;MOV	EBX,[EDX]
	;INC	EBX
	;MOV	[EDX],EBX
	;DEC	EBX
	INC	DWORD [EDX]
	LEA	EAX,[EBP-4]
	MOV	EDX,[EAX]
	;DEC	EDX
	;MOV	[EAX],EDX
	;INC	EDX
	;PUSH	EDX
	DEC	DWORD [EAX]	; **j-- =c;
	MOVSX	EAX,BYTE [EDX]	; 04/04/2026
	MOV	[EBX],AL
	;LEA	ECX,[EBP-8]
	MOV	EAX,[ECX]
	;POP	EDX
	MOV	[EDX],AL
	JMP	short _lib_3

; copy string t to s

_strcpy:			; strcpy(s,t) char *s,*t;
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4		; char *d;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; char *s
	LEA	EDX,[EBP-4]
	MOV	[EDX],EAX	; d=s;
_strcpy_1:			; while(*s++ =*t++);
	;LEA	EBX,[EBP+8] 	; *s
	MOV	ECX,[EBX]
	;INC	ECX
	;MOV	[EBX],ECX
	;DEC	ECX
	INC	DWORD [EBX] 	; *s++
	LEA	EAX,[EBP+12] 	; *t
	MOV	EDX,[EAX]
	INC	DWORD [EAX] 	; *t++
	MOVSX	EAX,BYTE [EDX]
	MOV	[ECX],AL	; *s++ =*t++
	; ebx = [EBP+8]
	OR	EAX,EAX
	JNZ	short _strcpy_1
	LEA	EBX,[EBP-4] 	; pointer to d
	MOV	EAX,[EBX] 	; return (d);
	MOV	ESP,EBP
	POP	EBP
	RETN

; return length of string s

_strlen:			; strlen(s)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4		; char *ptr;
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	LEA	ECX,[EBP-4]
	MOV	[ECX],EBX	; ptr=s;
_strlen_1:
	;LEA	ECX,[EBP-4]	; while(*ptr)
	;MOV	EBX,[ECX]
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JZ	short _strlen_2
;_lib_13:
	;LEA	ECX,[EBP-4]
	;MOV	EBX,[ECX]
	INC	EBX
	MOV	[ECX],EBX	; ++ptr;
	JMP	short _strlen_1
_strlen_2:
	;LEA	EDX,[EBP+8]
	MOV	ECX,[EDX]	; s
	LEA	EBX,[EBP-4]	; ptr
	MOV	EAX,[EBX]
	SUB	EAX,ECX		; return (ptr-s);
	MOV	ESP,EBP
	POP	EBP
	RETN

; return upper-case of c if it is lower-case, else c

_toupper:			; toupper(c)
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EAX,[EBP+8]	; if(c<='z' && c>='a')
	MOV	EBX,[EAX]	; int c;
	MOV	EAX,122		; 'z'
	CALL	__le
	OR	EAX,EAX
	;;JZ	short _lib_16
	;JZ	short _lib_15
	JZ	short _toupper_ok ; condition 1 = false
;_lib_18:
	;LEA	EAX,[EBP+8]
	;MOV	EBX,[EAX]
	MOV	EAX,97		; 'a'
	CALL	__ge
	OR	EAX,EAX
	;;JZ	short _lib_16
	;JZ	short _lib_15
	JZ	short _toupper_ok ; condition 2 = false
;_lib_19:
	;MOV	EAX,1
	; eax = 1
	;;JMP	short _lib_17
	;JMP	short _lib_20
;_lib_16:
	;XOR	EAX,EAX
;_lib_17:
	;OR	EAX,EAX
	;JZ	short _lib_15
;_lib_20:
	;;LEA	EAX,[EBP+8]	; condition 1 & 2 = true
	;;MOV	EBX,[EAX]	; int c
	;MOV	EAX,32
	;SUB	EBX,EAX		; return (c-32);
	SUB	EBX,32
_toupper_ok:	; return (c);
	XCHG	EAX,EBX
	POP	EBP
	RETN

;_lib_15:
;_toupper_ok:
	;;LEA	EBX,[EBP+8]
	;;MOV	EAX,[EBX]
	;; ebx = int c
	;XCHG	EAX,EBX		; return (c);
	;POP	EBP
	;RETN

; atoi(s) - convert s to integer.

_atoi:				; atoi(s) char *s;
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8		; int sign,n;
;_lib_22:
	LEA	EAX,[EBP+8]	; while(isspace(*s)) ++s;
	MOV	EBX,[EAX]
_lib_22:
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_isspace
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _lib_23
_lib_24:
	LEA	EBX,[EBP+8]
	INC	DWORD [EBX]
	JMP	short _lib_22
_lib_23:
	LEA	EBX,[EBP-4]	; sign = 1;
	MOV	EAX,1
	MOV	[EBX],EAX
	LEA	EAX,[EBP+8]	; switch(*s)
	MOV	EBX,[EAX]
	MOVSX	EAX,BYTE [EBX]
	JMP	short _lib_27
_lib_28:	
	LEA	EBX,[EBP-4]	; case '-': sign=-1;
	MOV	EAX, -1
	MOV	[EBX],EAX
_lib_29:	
	LEA	EBX,[EBP+8]	; case '+': ++s;
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
	JMP	short _lib_26
_lib_27:
	CALL	__switch	; switch(*s) {

 DD _lib_28	; case '-':
 DD 45
 DD _lib_29	; case '+':
 DD 43
 DD 0

_lib_26:
	LEA	EBX,[EBP-8]	; n=0;
	XOR	EAX,EAX
	MOV	[EBX],EAX
_lib_30:
	LEA	EAX,[EBP+8]	; while(isdigit(*s))
	MOV	EBX,[EAX]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _lib_31
_lib_32:
	LEA	EBX,[EBP-8]	; n=10*n+*s++ -'0';
	MOV	EAX,[EBX]
	MOV	ECX,10
	IMUL	ECX
	; eax = 10*n
	LEA	EDX,[EBP+8]
	MOV	ECX,[EDX]
	INC	DWORD [EDX]
	MOVSX	EDX,BYTE [ECX]
	ADD	EAX,EDX
	SUB	EAX,48		; '0'
	MOV	[EBX],EAX
	JMP	short _lib_30
_lib_31:
	LEA	EBX,[EBP-8]	; return (sign*n);
	MOV	EAX,[EBX]	; n
	LEA	EBX,[EBP-4]
	MOV	ECX,[EBX]	; sign
	IMUL	ECX
	MOV	ESP,EBP
	POP	EBP
	RETN

; atoib(s,b) - Convert s to "unsigned" integer in base b.

_atoib:				; atoib(s,b)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8		; int n, digit;
	LEA	EBX,[EBP-4] 	; n=0;
	XOR	EAX,EAX
	MOV	[EBX],EAX
_lib_34:
	LEA	EAX,[EBP+8]	; while(isspace(*s)) ++s;
	MOV	EBX,[EAX]
	MOVSX	EAX, BYTE [EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_isspace
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _lib_35
_lib_36:
	LEA	EBX,[EBP+8]	; ++s;
	INC	DWORD [EBX]
	JMP	short _lib_34
_lib_35:
_lib_37:
	LEA	EDX,[EBP-8]	; while((digit=(127 & *s++))>='0')
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	INC	DWORD [EBX]
	MOVSX	EBX,BYTE [EAX]
	AND	EBX,127
	MOV	[EDX],EBX
	MOV	EAX,48		; '0'
	CALL	__ge
	OR	EAX,EAX
	JNE	short _lib_39
_lib_47:
_lib_38:
	LEA	EBX,[EBP-4]	; return (n);
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_lib_39:
	;LEA	EDX,[EBP-8]	; if(digit>='a')
	MOV	EBX,[EDX]
	MOV	EAX,97		; 'a'
	CALL	__ge
	OR	EAX,EAX
	JE	short _lib_40
_lib_41:
	;LEA	EDX,[EBP-8]	; digit-=87;
	MOV	EAX,[EDX]
	SUB	EAX,87		; a = 10, f = 15
	MOV	[EDX],EAX
	JMP	short _lib_42
_lib_40:
	;LEA	EDX,[EBP-8]	; else if(digit>='A')
	;MOV	EBX,[EDX]
	MOV	EAX,65		; 'A'
	CALL	__ge
	OR	EAX,EAX
	JE	short _lib_43
_lib_44:
	;LEA	EDX,[EBP-8]	; digit-=55;
	MOV	EAX,[EDX]
	SUB	EAX,55		; A = 10, F = 15
	MOV	[EDX],EAX
	JMP	short _lib_45
_lib_43:
	;LEA	EDX,[EBP-8]	; else digit -= '0';
	MOV	EAX,[EDX]
	SUB	EAX,48		; '0'
	MOV	[EDX],EAX
_lib_45:
_lib_42:
	;LEA	EDX,[EBP-8]	; if(digit>=b) break;
	;MOV	EAX,[EDX]
	PUSH	EAX		; digit
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]	; b
	POP	EBX
	CALL	__ge
	OR	EAX,EAX
	JNE	short _lib_47
_lib_46:
	LEA	EDX,[EBP-4]	; n=b*n+digit;
	LEA	EBX,[EBP+12]
	MOV	ECX,[EBX]	; b
	;LEA	EDX,[EBP-4]
	MOV	EAX,[EDX]	; n
	IMUL	ECX		; b*n
	; eax = b*n
	LEA	EBX,[EBP-8]
	MOV	ECX,[EBX]
	ADD	EAX,ECX
	MOV	[EDX],EAX
	JMP	_lib_37


	; 04/04/2026 
	; ("smallcw.exe' argument order modification)
	; ("scc.exe" -> push arguments from left to right)
	; ("smallcw.exe" -> push arguments from right to left)

; Gets an entire string (including its newline terminator)

_fgets:				; fgets(str,size,fd)
	PUSH	EBP
	MOV	EBP,ESP		; return (_gets(1,fd,size,str));
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX		; str
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX		; size
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX		; fd
	MOV	EAX,1
	;PUSH	EAX		; 1
	;;MOV	CL,4
	;CALL	__gets
	;;ADD	ESP,16
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _gets_@

; Gets an entire string from stdin
;	(excluding its newline terminator)

	; 04/04/2026

	; /* TRDOS 386 v2 modification */
_gets:				; gets(str)
	PUSH	EBP		; char *str;
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]	; return (_gets(0,stdin,256,str))
	MOV	EAX,[EBX]
	PUSH	EAX		; str
	;MOV	EAX,32767
	MOV	EAX,256
	PUSH	EAX		; size
	MOV	EAX,-1 ; STDIN	; stdin is -1 for TRDOS 386
	PUSH	EAX		; -1
	XOR	EAX,EAX
_gets_@:
	PUSH	EAX		; 0
	;MOV	CL,4
	CALL	__gets
	;ADD	ESP,16
	MOV	ESP,EBP
	POP	EBP
	RETN

	; 04/04/2026

	; /* TRDOS 386 v2 modification */
__gets:
	PUSH	EBP		; _gets(nl,fd,size,str)
	MOV	EBP,ESP	; char *str; unsigned size,fd,nl;
	ADD	ESP,-8		; int backup; char *next;
	XOR	EAX,EAX ; 0
	PUSH	EAX		; int previous;
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]	; str
	LEA	EBX,[EBP-8]	; next
	MOV	[EBX],EAX	; next=str;
_gets_1:
_gets_2:
_gets_3:			; while(--size>0)
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX	; --size
	LEA	EDX,[EBP-8] ;*	; next
	MOV	EBX,[EDX] ;*
	OR	EAX,EAX
	;JNZ	short _gets_5
	;JMP	short _gets_4
	JZ	short _gets_4
;_gets_4:
	;LEA	EDX,[EBP-8]	; *next = NULL;
	;MOV	EBX,[EDX]
	;XOR	EAX,EAX
	;MOV	[EBX],AL
	;LEA	EBX,[EBP+20]
	;MOV	EAX,[EBX]
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	;JMP	short _gets_9
_gets_5:			; {switch (*next=OS_fgetc(fd))
	;LEA	EDX,[EBP-8]
	;MOV	EBX,[EDX]
	PUSH	EBX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX		; fd
	;MOV	CL,1
	CALL	_OS_fgetc
	ADD	ESP,4
	POP	EBX
	MOV	[EBX],AL	; *next=OS_fgetc(fd)
	JMP	_gets_19
_gets_6:			; case EOF:
	LEA	EDX,[EBP-8]	; *next=NULL;
	MOV	EBX,[EDX]
	;XOR	EAX,EAX
	;MOV	[EBX],AL
	MOV	BYTE [EBX],0
	;LEA	EDX,[EBP-8]	; if(next==str)
	;MOV	EBX,[EDX]
	LEA	ECX,[EBP+20]
	MOV	EAX,[ECX]
	CALL	__eq
	OR	EAX,EAX
	JZ	short _gets_10
_gets_7:
	XOR	EAX,EAX	; 0	; NULL
	MOV	ESP,EBP
	POP	EBP
	RETN
_gets_21:
	; case '\r':
	LEA	EBX,[EBP-12]	; previous
	MOV	BYTE [EBX],13
	JMP	short _gets_18
_gets_8:			; case '\n':
	LEA	EDX,[EBP-8]	; *(next+nl)=NULL;
	MOV	EBX,[EDX]
	LEA	ECX,[EBP+8]
	MOV	EAX,[ECX]
	ADD	EBX,EAX
	;ADD	EBX,[ECX]
	LEA	EDX,[EBP-12]
	CMP	BYTE [EDX],0	; previous
	JNA	short _gets_4
	OR	EAX,EAX		; nl
	JNZ	short _gets_4
	DEC	EBX
_gets_4:
_gets_9:
	;XOR	EAX,EAX	; 0	; NULL
	;MOV	[EBX],EAX	; *next = 0
	MOV	BYTE [EBX],0
_gets_10:			; return (str);
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_gets_11:			; case RUB: // \b
	LEA	EDX,[EBP-8]	; if(next>str)
	MOV	EBX,[EDX]
	LEA	ECX,[EBP+20]
	MOV	EAX,[ECX]
	CALL	__ugt
	LEA	EBX,[EBP-4] ; *
	OR	EAX,EAX
	JZ	short _gets_13	; backup=0;
_gets_12:
	;LEA	EBX,[EBP-4] ; *	; backup=1;
	;MOV	EAX,1
	;MOV	[EBX],EAX ; **
	JMP	short _gets_15
_gets_13:
	;LEA	EBX,[EBP-4] ; *
	;XOR	EAX,EAX
	;MOV	[EBX],EAX ; **
	JMP	short _gets_16
_gets_14:			; case WIPE:
	LEA	EDX,[EBP-8]
	MOV	EAX,[EDX]	; next
	LEA	ECX,[EBP+20]
	MOV	EBX,[ECX]	; str
	SUB	EAX,EBX
	LEA	EBX,[EBP-4]	; backup=next-str;
	;MOV	[EBX],EAX
_gets_15:
_gets_16:
	MOV	[EBX],EAX ; **
_gets_17:
_gets_18:
	LEA	EBX,[EBP-8]	; ++next;
	MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	_gets_2	; while

_gets_19:	; {switch (*next=OS_fgetc(fd))
	CALL	__switch

 DD _gets_6	; case EOF:
 DD -1
 DD _gets_8	; case '\n':	; LF
 DD 10
 DD _gets_21	; case '\r':	; CR
 DD 13
 DD _gets_11	; case RUB:
 DD 8
 DD _gets_14	; case WIPE:
 DD 24
 DD 0		; default:
	JMP	short _gets_18

;_gets_20: DB 8,32,8,0		; "\b \b"

; /* fprintf(fd, ctlstring, arg, arg, ...)
; Formatted print. */
; (b, c, d, o, s, u, and x specifications are supported.) */

	; /* TRDOS 386 v2 modification */
	; 03/04/2026
_fprintf:
	MOV	EAX,[ESP+8] ; fd  ; 04/04/2026
	PUSH	EBP
	MOV	EBP,ESP
	PUSH	EAX	; repositioning fd for '__print'
	CALL	__print
	MOV	ESP,EBP
	POP	EBP
	RETN

; /* printf(ctlstring, arg, arg, ...) - Formatted print.
; (b, c, d, o, s, u, and x specifications are supported.)
; Note: b (binary) is a non-standard extension. */

	; /* TRDOS 386 v2 modification */
	; 03/04/2026
_printf:
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,-1	; TRDOS 386 STDOUT/STDERR
	PUSH	EAX		; (file number)
	CALL	__print
	MOV	ESP,EBP
	POP	EBP
	RETN

; /* _print(fd, ctlstring, arg, arg, ...)
; ** Called by fprintf() and printf(). */

	; /* TRDOS 386 v2 modification */
	; 03/04/2026
__print:
	PUSH	EBP
	MOV	EBP,ESP
		; int arg,left,pad,cc,len,maxchr,width;
	ADD	ESP,-56		; char *ctl,*sptr,str[17];
	LEA	EBX,[EBP-16]	; cc=0;
	XOR	EAX,EAX
	MOV	[EBX],EAX
	LEA	EDX,[EBP+20]	; 04/04/2026
	LEA	EBX,[EBP-4]	; arg = ebp+20
	MOV	[EBX],EDX
	LEA	EBX,[EBP-32]	; ctl = ctlstring
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
__p_1:				; while(*ctl)
	LEA	EDX,[EBP-32]
	MOV	EAX,[EDX]
	MOVSX	EBX,BYTE [EAX]
	OR	EBX,EBX
	JNZ	short __p_3
__p_2:				; return (cc);
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
__p_3:				; {if(*ctl!='%')
	;LEA	EDX,[EBP-32]
	;MOV	EAX,[EDX]
	;MOVSX	EBX,BYTE [EAX]
	MOV	EAX,37	; '%'
	CALL	__ne
	OR	EAX,EAX
	JZ	short __p_5	; else
__p_4:
	LEA	EBX,[EBP+8]	; fd (file number)
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EBX,[EDX]
	INC	DWORD [EDX]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX		; *ctl (character)
	CALL	_OS_fputc	; {OS_fputc(*ctl++,fd);
	ADD	ESP,8
	LEA	EBX,[EBP-16]	; ++cc;
	INC	DWORD [EBX]
	JMP	short __p_1	; continue;
__p_5: ; *ctl=='%'		; else ++ctl;
	INC	DWORD [EDX]	; (next char)
	;
	MOV	EAX,[EDX]	; if(*ctl=='%')
	MOVSX	EBX,BYTE [EAX]  ; (*)
	MOV	EAX,37	; '%'
	CALL	__eq
	OR	EAX,EAX
	;JZ	short __p_6
	JNZ	short __p_4	; %%
__p_6: 
	; ebx = character (*ctl)
	MOV	EAX,45	; '-'	; if(*ctl=='-')
	CALL	__eq
	LEA	EBX,[EBP-8] ; *
	MOV	[EBX],EAX ; *	; (eax = 0 or 1)
	OR	EAX,EAX
	JZ	short __p_7	; else
	;
	; eax = 1
	INC	DWORD [EDX] ; *	; {left=1; ++ctl;}
__p_7:
	;LEA	EDX,[EBP-32]	; if(*ctl=='0') pad='0';
	MOV	EAX,[EDX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,48	; '0'
	CALL	__eq
	LEA	ECX,[EBP-12] ; *
	OR	EAX,EAX
	JNZ	short __p_8
	; else
	;LEA	ECX,[EBP-12] ; *
	MOV	EBX,32 ; space	; else pad=' ';
__p_8: ; **
	MOV	[ECX],EBX	; ebx = '0'
	LEA	EDX,[EBP+12]	; 04/04/2026
	MOV	EBX,[EDX]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_isdigit	; if(isdigit(*ctl))
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short __p_10	; else
	;
	LEA	EBX,[EBP+12]	; ctl++
	MOV	EAX,[EBX]
	INC	DWORD [EBX]
	PUSH	EAX
	CALL	_atoi
	ADD	ESP,4
	LEA	EBX,[EBP-28]	; width=atoi(ctl++);
	MOV	[EBX],EAX
	;			; while(isdigit(*ctl))
	LEA	EAX,[EBP-32]
	MOV	EBX,[EAX]
__p_9: ; *
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short __p_11
	;			; ++ctl;
	LEA	EAX,[EBP-32]
	MOV	EBX,[EAX]
	INC	EBX
	MOV	[EAX],EBX
	JMP	short __p_9 ;*	; while
__p_10:
	LEA	EBX,[EBP-28]	; else width=0;
	;XOR	EAX,EAX ; 0
	; eax = 0
	MOV	[EBX],EAX
__p_11:
	LEA	EDX,[EBP-32]	; if(*ctl=='.')
	MOV	ECX,[EDX]
	MOVSX	EBX,BYTE [ECX]
	MOV	EAX,46	; '.'
	CALL	__eq
	OR	EAX,EAX
	JZ	short __p_13	; else
	;
	;LEA	EDX,[EBP-32]	; ++ctl
	;MOV	ECX,[EDX]
	INC	ECX
	MOV	[EDX],ECX
	PUSH	ECX
	CALL	_atoi
	ADD	ESP,4
	LEA	EBX,[EBP-24]	; maxchr=atoi(++ctl);
	MOV	[EBX],EAX
	;
	LEA	EAX,[EBP-32]	; while(isdigit(*ctl))
	MOV	EBX,[EAX]
__p_12: ; *
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short __p_14
	;
	LEA	EAX,[EBP-32]	; ++ctl;
	MOV	EBX,[EAX]
	INC	EBX
	MOV	[EAX],EBX
	JMP	short __p_12 ;*	; while
__p_13:
	LEA	EBX,[EBP-24]	; else maxchr=0;
	;XOR	EAX,EAX
	; eax = 0
	MOV	[EBX],EAX
__p_14:				; arg = arg+4
	LEA	EBX,[EBP-4]
	ADD	DWORD [EBX],4
	LEA	EDX,[EBP-36]	; sptr=str;
	LEA	EAX,[EBP-56]
	MOV	[EDX],EAX
	LEA	EBX,[EBP-32]	; switch(*ctl++)
	MOV	ECX,[EBX]
	INC	DWORD [EBX]
	MOVSX	EAX,BYTE [ECX]
	JMP	short __p_21
__p_15:			; case 'c':
	LEA	EDX,[EBP-56]	; str[0]=arg;
	LEA	EBX,[EBP-4]
	MOV	ECX,[EBX]	; EBP+24 .. EBP+32
	MOV	EAX,[ECX]	; [EBP+24]..[EBP+32]
	MOV	[EDX],AL	
	;LEA	EDX,[EBP-56]
	;ADD	EDX,1
	INC	EDX
	XOR	EAX,EAX ; 0
	MOV	[EDX],AL	; str[1]=NULL;
	JMP	__p_24	; break;
__p_16:			; case 's':
	LEA	EBX,[EBP-4]	; sptr=arg;
	MOV	ECX,[EBX]	; EBP+24 .. EBP+32
	MOV	EAX,[ECX]	; [EBP+24]..[EBP+32]
	LEA	EBX,[EBP-36]
	MOV	[EBX],EAX
	JMP	__p_24	; break;
__p_17:			; case 'd':
	; 04/04/2026
	LEA	EAX,[EBP-56]
	PUSH	EAX
	LEA	EDX,[EBP-4]	; itoa(arg,str);
	MOV	EBX,[EDX]	; EBP+24 .. EBP+32
	MOV	EAX,[EBX]	; [EBP+24]..[EBP+32]
	PUSH	EAX
	CALL	_itoa
	ADD	ESP,8
	JMP	short __p_24	; break;
__p_18:			; case 'o':
	MOV	ECX,8 ; *
	JMP	short __p_23	; itoab(arg,str,8);
__p_19:			; case 'u':
	MOV	ECX,10 ; *
	JMP	short __p_23	; itoab(arg,str,10);
__p_20:			; case 'x':
	MOV	ECX,16 ; *
	JMP	short __p_23	; itoab(arg,str,16);

__p_21:			; switch(*ctl++)
	CALL	__switch

 DD __p_15	; case 'c':
 DD 99
 DD __p_16	; case 's':
 DD 115
 DD __p_17	; case 'd':
 DD 100
 DD __p_22	; case 'b':
 DD 98
 DD __p_18	; case 'o':
 DD 111
 DD __p_19	; case 'u':
 DD 117
 DD __p_20	; case 'x':
 DD 120
 DD 0		; default:
	JMP	__p_2	; return (cc);

__p_22:			; case 'b':
	MOV	ECX,2 ; *
__p_23:
	; ecx = number base (2,8,10,16)
	; 04/04/2026
	PUSH	ECX ; *
	LEA	EAX,[EBP-56]
	PUSH	EAX		; str
	LEA	EBX,[EBP-4]
	MOV	ECX,[EBX]	; EBP+24 .. EBP+32
	MOV	EAX,[ECX]	; [EBP+24]..[EBP+32]
	PUSH	EAX		; arg
	CALL	_itoab		; itoab(arg,str,?);
	ADD	ESP,12
__p_24:
	LEA	EBX,[EBP-36]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_strlen
	ADD	ESP,4
	LEA	ECX,[EBP-20]
	MOV	[ECX],EAX	; len=strlen(sptr);
	LEA	EDX,[EBP-24]	; if(maxchr && maxchr<len)
	MOV	EBX,[EDX]
	OR	EBX,EBX
	;JZ	short __p_25
	JZ	short __p_26	; *
	;
	;LEA	EDX,[EBP-24]	; maxchr
	;MOV	EBX,[EDX]
	;LEA	ECX,[EBP-20]	; len
	;MOV	EAX,[ECX]
	CALL	__lt
	OR	EAX,EAX
	JZ	short __p_25
	;
	;LEA	ECX,[EBP-20]
	;LEA	EDX,[EBP-24]
	;MOV	EBX,[EDX]
	MOV	[ECX],EBX	; len=maxchr;
__p_25:
	;LEA	ECX,[EBP-20]	; len
	MOV	EAX,[ECX]
__p_26: ; *			; if(width>len)
	LEA	EDX,[EBP-28]
	MOV	EBX,[EDX]	; width
	CALL	__gt
	OR	EAX,EAX
	JZ	short __p_27	; else
	;
	;LEA	EDX,[EBP-28]	; width=width-len;
	;MOV	EBX,[EDX]
	;LEA	ECX,[EBP-20]
	MOV	EAX,[ECX]	; len
	SUB	EBX,EAX
	MOV	[EDX],EBX
	JMP	short __p_28
__p_27:
	;LEA	EDX,[EBP-28]	; else width=0;
	;XOR	EAX,EAX
	; eax = 0
	MOV	[EDX],EAX
__p_28:
	LEA	EBX,[EBP-8]	; if(!left)
	MOV	EAX,[EBX]
	CALL	__lneg
	OR	EAX,EAX
	JZ	short __p_30
__p_29:
	;LEA	EDX,[EBP-28]	; while(width--)
	MOV	EAX,[EDX]
	DEC	DWORD [EDX]
	OR	EAX,EAX
	JZ	short __p_30
	;
	LEA	EBX,[EBP+8]	; 04/04/2026
	MOV	EAX,[EBX]
	PUSH	EAX		; fd
	LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_OS_fputc	; {OS_fputc(pad,fd);
	ADD	ESP,8
	LEA	EBX,[EBP-16]	; ++cc;}
	INC	DWORD [EBX]
	LEA	EDX,[EBP-28]
	JMP	short __p_29
__p_30:
	LEA	EBX,[EBP-20]	; while(len--)
	MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	INC	EAX
	;OR	EAX,EAX
	JZ	short __p_31
	;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX		; fd (file number)
	LEA	EDX,[EBP-36]
	MOV	EBX,[EDX]
	INC	DWORD [EDX]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_OS_fputc	; {OS_fputc(*sptr++,fd);
	ADD	ESP,8
	LEA	EBX,[EBP-16]	; ++cc;}
	INC	DWORD [EBX]
	JMP	short __p_30
__p_31:
	LEA	EBX,[EBP-8]	; if(left)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JZ	short __p_33
	JNZ	short __p_32
__p_33:
	JMP	__p_1		; while(*ctl)
__p_32:
	LEA	EBX,[EBP-28]	; while(width--)
	MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	INC	EAX
	;OR	EAX,EAX
	JZ	short __p_33
	;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX		; fd
	LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	PUSH	EAX		; pad
	CALL	_OS_fputc	; {OS_fputc(pad,fd);
	ADD	ESP,8
	LEA	EBX,[EBP-16]	; ++cc;}
	INC	DWORD [EBX]
	JMP	short __p_32

	; /* TRDOS 386 v2 modification */
	; 03/04/2026
_fputs:				; fputs(string,fd)
	PUSH	EBP
	MOV	EBP,ESP
_fputs_1:
	LEA	EDX,[EBP+12]	; while(*string)
	MOV	EBX,[EDX]
	MOVSX	EAX,BYTE [EBX]	; *string (char)
	OR	EAX,EAX
	JZ	short _fputs_2	; char = 0 (ASCIIZ string)
	INC	DWORD [EDX]	; *string++
	LEA	EBX,[EBP+8]
	MOV	ECX,[EBX]	; fd (-1 -> STDOUT/STDERR)
	PUSH	ECX	; file number
	PUSH	EAX	; char
	CALL	_OS_fputc	; OS_fputc(*string++,fd);
	ADD	ESP,8
	JMP	short _fputs_1	; jump to while(*string)
_fputs_2:
	POP	EBP
	RETN

;#define ALNUM     1
;#define ALPHA     2
;#define CNTRL     4
;#define DIGIT     8
;#define GRAPH    16
;#define LOWER    32
;#define PRINT    64
;#define PUNCT   128
;#define BLANK   256
;#define UPPER   512
;#define XDIGIT 1024

__is:				; int _is[128] =
 DD 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
 DD 004h, 104h, 104h, 104h, 104h, 104h, 004h, 004h
 DD 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
 DD 004h, 004h, 004h, 004h, 004h, 004h, 004h, 004h
 DD 140h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h
 DD 0D0h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h
 DD 459h, 459h, 459h, 459h, 459h, 459h, 459h, 459h
 DD 459h, 459h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h
 DD 0D0h, 653h, 653h, 653h, 653h, 653h, 653h, 253h
 DD 253h, 253h, 253h, 253h, 253h, 253h, 253h, 253h
 DD 253h, 253h, 253h, 253h, 253h, 253h, 253h, 253h
 DD 253h, 253h, 253h, 0D0h, 0D0h, 0D0h, 0D0h, 0D0h
 DD 0D0h, 473h, 473h, 473h, 473h, 473h, 473h, 073h
 DD 073h, 073h, 073h, 073h, 073h, 073h, 073h, 073h
 DD 073h, 073h, 073h, 073h, 073h, 073h, 073h, 073h
 DD 073h, 073h, 073h, 0D0h, 0D0h, 0D0h, 0D0h, 004h

; isalnum (c) int c; {return (_is[c] & ALNUM);}
; /* 'a'-'z', 'A'-'Z', '0'-'9' */

_isalnum:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX,__is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,1		; ALNUM
	;AND	EAX,EBX		; return (_is[c] & ALNUM);
	AND	EAX,1		; (bit 0)
	POP	EBP
	RETN

;isalpha (c) int c; {return (_is[c] & ALPHA);}
; /* 'a'-'z', 'A'-'Z' */

_isalpha:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX,__is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,2		; ALPHA
	;AND	EAX,EBX		; return (_is[c] & ALPHA);
	AND	EAX,2		; (bit 1)
	POP	EBP
	RETN

; iscntrl (c) int c; {return (_is[c] & CNTRL);}
; /* 0-31, 127 */

_iscntrl:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX,__is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,4		; CNTRL
	;AND	EAX,EBX		; return (_is[c] & CNTRL);
	AND	EAX,4		; (bit 2)
	POP	EBP
	RETN

;isdigit (c) int c; {return (_is[c] & DIGIT );}
; /* '0'-'9' */

_isdigit:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX,__is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,8		; DIGIT
	;AND	EAX,EBX		; return (_is[c] & DIGIT);
	AND	EAX,8		; (bit 3)
	POP	EBP
	RETN

;isgraph (c) int c; {return (_is[c] & GRAPH);}
; /* '!'-'~' */

_isgraph:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX,__is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,16		; GRAPH
	;AND	EAX,EBX		; return (_is[c] & GRAPH);
	AND	EAX,16		; (bit 4)
	POP	EBP
	RETN

;islower (c) int c; {return (_is[c] & LOWER);}
; /* 'a'-'z' */

_islower:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX, __is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,32		; LOWER
	;AND	EAX,EBX		; return (_is[c] & LOWER);
	AND	EAX,32		; (bit 5)
	POP	EBP
	RETN

;isprint (c) int c; {return (_is[c] & PRINT);}
; /* ' '-'~' */

_isprint:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX, __is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,64		; PRINT
	;AND	EAX,EBX		; return (_is[c] & PRINT);
	AND	EAX,64		; (bit 6)
	POP	EBP
	RETN

;ispunct (c) int c; {return (_is[c] & PUNCT);}
; /* !alnum && !cntrl && !space */

_ispunct:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX, __is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,128		; PUNCT
	;AND	EAX,EBX		; return (_is[c] & PUNCT);
	AND	EAX,128		; (bit 7)
	POP	EBP
	RETN

;isspace (c) int c; {return (_is[c] & BLANK);}
; /* HT, LF, VT, FF, CR, ' ' */

_isspace:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX, __is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,256		; BLANK
	;AND	EAX,EBX		; return (_is[c] & BLANK);
	AND	EAX,256		; (bit 8)
	POP	EBP
	RETN

;isupper (c) int c; {return (_is[c] & UPPER);}
; /* 'A'-'Z' */

_isupper:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX, __is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,512		; UPPER
	;AND	EAX,EBX		; return (_is[c] & UPPER);
	AND	EAX,512		; (bit 9)
	POP	EBP
	RETN

;isxdigit(c) int c; {return (_is[c] & XDIGIT);}
; /* '0'-'9', 'a'-'f', 'A'-'F' */

_isxdigit:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; int c;
	MOV	EBX,__is
	SHL	EAX,1
	SHL	EAX,1
	ADD	EBX,EAX
	MOV	EAX,[EBX]
	;MOV	EBX,1024	; XDIGIT
	;AND	EAX,EBX		; return (_is[c] & XDIGIT);
	AND	EAX,1024	; (bit 10)
	POP	EBP
	RETN

; /* itoa(n,s) - Convert n to characters in s */

_itoa:				; itoa(n,s)
	PUSH	EBP		; char *s; int n;
	MOV	EBP,ESP
	ADD	ESP,-8		; int sign; char *ptr;
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-8]	; 04/04/2026
	MOV	[EBX],EAX	; ptr=s;
	LEA	EBX,[EBP+8]	; if((sign=n)<0) n=-n;
	MOV	EAX,[EBX]	; n
	LEA	EDX,[EBP-4]	; sign
	MOV	[EDX],EAX	; sign = n
	OR	EAX,EAX
	JNL	short _lib_150
_lib_151:
	;LEA	EBX,[EBP+8]	; n=-n;
	;MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
_lib_150:
_lib_154:
_lib_152:			; do
	LEA	EBX,[EBP-8]	; {*ptr++ = n%10+'0';
	MOV	EAX,[EBX]
	INC	DwORD [EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; n
	MOV	ECX,10
	CDQ
	IDIV	ECX		; n/10
	ADD	DL,48		; '0'
	POP	ECX
	MOV	[ECX],DL
	; eax = n/10
	MOV	[EBX],EAX	; n = n/10
	OR	EAX,EAX		; }while((n=n/10)>0);
	JG	short _lib_154
_lib_153:
	LEA	EBX,[EBP-4]	; if(sign<0)
	MOV	EAX,[EBX]
	LEA	EDX,[EBP-8] ;*
	MOV	EBX,[EDX] ;*
	OR	EAX,EAX
	JNL	short _lib_155
_lib_156:
	;LEA	EDX,[EBP-8]	; *ptr++='-';
	;MOV	EBX,[EDX]
	INC	DWORD [EDX]
	;MOV	EAX,45	; '-'
	;MOV	[EBX],AL
	MOV	BYTE [EBX],45
_lib_155:
	;LEA	EDX,[EBP-8] ;*	; *ptr='\0';
	;MOV	EBX,[EDX] ;*
	;XOR	EAX,EAX
	;MOV	[EBX],AL
	MOV	BYTE [EBX],0
	LEA	EBX,[EBP+12]	; reverse(s);
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_reverse
	;ADD	ESP,4
	MOV	ESP,EBP
	POP	EBP
	RETN

; /*
; ** itoab(n,s,b) - Convert "unsigned" n to characters
; **		    in s using base b.
; ** 	NOTE: This is a non-standard function.
; */

_itoab:				; itoab(n,s,b)
	PUSH	EBP		; int n; char *s; int b;
	MOV	EBP,ESP
	ADD	ESP,-8		; char *ptr; int lowbit;
	LEA	EBX,[EBP+12]	; *s
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-4]	; ptr
	MOV	[EBX],EAX	; ptr=s;
	LEA	EBX,[EBP+16]	; b >>= 1;
	MOV	EAX,[EBX]
	SAR	EAX,1
	MOV	[EBX],EAX
_lib_163:
_lib_158:			; do
	LEA	EDX,[EBP-8]	; {lowbit=n&1;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; n
	AND	EAX,1
	MOV	[EDX],EAX	; n&1
	;LEA	EBX,[EBP+8]	; n=(n>>1)&32767;
	MOV	EAX,[EBX]
	SAR	EAX,1
	AND	EAX,32767
	MOV	[EBX],EAX
	;LEA	EBX,[EBP-4]	; *ptr=((n%b)<<1)+lowbit;
	;MOV	EAX,[EBX]	; *ptr
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; n
	LEA	EDX,[EBP+16]	; b
	MOV	ECX,[EDX]
	CDQ
	IDIV	ECX		; n/b
	; edx = mod n/b
	SAL	EDX,1
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]	; lowbit
	ADD	EAX,EDX
	;POP	EDX
	LEA	ECX,[EBP-4]	; *ptr=((n%b)<<1)+lowbit;
	MOV	EDX,[ECX]	; ptr
	MOV	[EDX],AL
	;LEA	ECX,[EBP-4]	; if(*ptr<10)
	;MOV	EDX,[ECX]
	MOVSX	EBX,BYTE [EDX]
	MOV	EAX,10
	CALL	__lt
	OR	EAX,EAX
	JZ	short _lib_160	; else
_lib_161:
	;LEA	ECX,[EBP-4]	; *ptr+='0';
	;MOV	EDX,[ECX]
	MOVSX	EAX,BYTE [EDX]
	ADD	EAX,48	; '0'
	MOV	[EDX],AL
	JMP	short _lib_162
_lib_160:			; hex. character (A..F)
	;LEA	ECX,[EBP-4]	; *ptr+=55;
	;MOV	EDX,[ECX]
	MOVSX	EAX,BYTE [EDX]
	ADD	EAX,55	; (skip chars between '9' and 'A')
	MOV	[EDX],AL
_lib_162:
	LEA	EBX,[EBP-4]	; ++ptr;
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
	LEA	EBX,[EBP+8]	; }while(n/=b);
	MOV	EAX,[EBX]	; n
	LEA	EDX,[EBP+16]	; b
	MOV	ECX,[EDX]
	CDQ
	IDIV	ECX		; n/b
	MOV	[EBX],EAX	; n = n/b
	OR	EAX,EAX
	JNZ	short _lib_163	; do..while
_lib_159:
	LEA	EAX,[EBP-4]	; *ptr=0;
	MOV	EBX,[EAX]
	;XOR	EAX,EAX	; 0
	;MOV	[EBX],AL
	MOV	BYTE [EBX],0
	LEA	EBX,[EBP+12]	; s
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_reverse	; reverse(s);
	;ADD	ESP,4
	MOV	ESP,EBP
	POP	EBP
	RETN

;/*
;** itod -- convert nbr to signed decimal string of
;**	    width sz right adjusted, blank filled;
;**	    returns str
;**
;**	if sz > 0 terminate with null byte
;**	if sz = 0 find end of string
;**	if sz < 0 use last byte for data
;*/

_itod:				; itod(nbr,str,sz)
	PUSH	EBP	; int nbr; char str[]; int sz;
	MOV	EBP,ESP
	ADD	ESP,-4		; char sgn;
	LEA	EDX,[EBP+8]	; if(nbr<0)
	MOV	EAX,[EDX]
	LEA	EBX,[EBP-4]	; sgn
	OR	EAX,EAX
	JNL	short _lib_165	; else sgn=' ';
_lib_166:
	;LEA	EDX,[EBP+8]	; {nbr=-nbr; sgn='-';}
	;MOV	EAX,[EDX]
	NEG	EAX
	MOV	[EDX],EAX
	;LEA	EBX,[EBP-4]	; sgn
	MOV	EAX,45	; '-'
	;MOV	[EBX],AL
	;MOV	BYTE [EBX],45
	JMP	short _lib_167
_lib_165:
	;LEA	EBX,[EBP-4]
	MOV	EAX,32
_lib_167:
	MOV	[EBX],AL
;_lib_167:
	LEA	EBX,[EBP+16]	; if(sz>0)
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+12] ;*	; str[--sz]=NULL;
	MOV	ECX,[EDX] ;*	; str[0] address
	OR	EAX,EAX
	JNG	short _lib_168	; else
_lib_169:
	;LEA	EDX,[EBP+12] ;*	; str[--sz]=NULL;
	;MOV	ECX,[EDX] ;*	; str[0] address
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX		; --sz
	MOV	[EBX],EAX
	ADD	ECX,EAX		; str[sz]
	MOV	BYTE [ECX],0
	JMP	short _lib_170
_lib_168:			; else if(sz<0)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	; eax = sz
	OR	EAX,EAX
	JNL	short _lib_171	; else
_lib_172:
	;LEA	EBX,[EBP+16]	; sz=-sz;
	;MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
	JMP	short _lib_173
_lib_174:			; else
	LEA	EDX,[EBP+12] ;*	; while(str[sz]!=NULL)
	MOV	ECX,[EDX] ;*
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	ADD	ECX,EAX		; addr str[0]+sz
_lib_171:	; (eax = 0)
	MOVSX	EDX,BYTE [ECX]	; str[sz]
	OR	EDX,EDX
	JZ	short _lib_175	; = NULL
_lib_176:	; != NULL
	;LEA	EBX,[EBP+16]	; ++sz;
	;MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _lib_174	; while
_lib_175:
_lib_173:
_lib_170:
_lib_180:
_lib_177:			; while(sz)
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	; eax = sz
	OR	EAX,EAX
	JZ	short _lib_178
_lib_179:			; {str[--sz]=(nbr%10+'0');
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	; eax = sz 
	DEC	EAX		; --sz
	MOV	[EBX],EAX
	LEA	EDX,[EBP+12]	; str[0]
	MOV	EBX,[EDX]
	ADD	EBX,EAX		; str[sz]

	LEA	EDX,[EBP+8]	; nbr address
	MOV	EAX,[EDX]	; nbr
	PUSH	EDX ; *
	MOV	ECX,10
	CDQ
	IDIV	ECX		; nbr/10
	; edx = mod nbr/10
	;ADD	EDX,48	; '0'
	ADD	DL,48
	MOV	[EBX],DL	; = (nbr%10+'0');
	;LEA	EDX,[EBP+8]
	;MOV	EAX,[EDX]
	POP	EBX ; *
	;;MOV	ECX,10
	;CDQ
	;IDIV	ECX
	; eax = int nbr/10
				; if((nbr=nbr/10)==0)
	MOV	[EBX],EAX	; nbr = nbr/10
	OR	EAX,EAX
	JNZ	short _lib_180	; while
_lib_181:			; break;
_lib_178:
	LEA	EBX,[EBP+16]	; if(sz) str[--sz]=sgn;
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+12] ;*
	OR	EAX,EAX
	;JZ	short _lib_182
	JNZ	short _lib_183
_lib_185:
	;LEA	EDX,[EBP+12] ;*
	MOV	EAX,[EDX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_lib_183:
	;LEA	EDX,[EBP+12] ;*	; str address
	MOV	ECX,[EDX]	; str[0]
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]	; sz
	DEC	EAX		; --sz
	MOV	[EBX],EAX
	ADD	ECX,EAX
	LEA	EBX,[EBP-4]
	;MOVSX	EAX,BYTE [EBX]	; sgn
	MOV	AL,[EBX]
	MOV	[ECX],AL	; str[--sz]=sgn;
;_lib_184:
	LEA	EBX,[EBP+16]	; while(sz>0)
	MOV	EAX,[EBX]
_lib_184:
_lib_182:
	OR	EAX,EAX
	JNG	short _lib_185
_lib_186:			; str[--sz]=' ';
	;LEA	EDX,[EBP+12] ;*
	MOV	ECX,[EDX]
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX		; --sz
	MOV	[EBX],EAX	; sz
	ADD	ECX,EAX
	MOV	BYTE [ECX],32	; space
	JMP	short _lib_184

;/*
;** itoo -- converts nbr to octal string of
;**	    length sz right adjusted and
;**	    blank filled, returns str
;**
;**	if sz > 0 terminate with null byte
;**	if sz = 0 find end of string
;**	if sz < 0 use last byte for data
;*/

_itoo:				; itoo(nbr,str,sz)
	PUSH	EBP	; int nbr; char str[]; int sz;
	MOV	EBP,ESP
	ADD	ESP,-4		; int digit;
	LEA	EBX,[EBP+16]	; if(sz>0)
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+12] ;*
	MOV	ECX,[EDX] ;*
	OR	EAX,EAX
	JG	short _lib_189
	JE	short _lib_191	; JNL (eax=0)
_lib_188:
_lib_192:	; JL
	;LEA	EBX,[EBP+16]	; else if(sz<0)
	;MOV	EAX,[EBX]	; sz=-sz;
	NEG	EAX
	MOV	[EBX],EAX
	JMP	short _lib_193
_lib_189:
	;LEA	EDX,[EBP+12] ;*	; str[--sz]=0;
	;MOV	ECX,[EDX] ;*
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	ADD	ECX,EAX
	;XOR	EAX,EAX
	;MOV	[ECX],AL
	MOV	BYTE [ECX],0
	JMP	short _lib_190
;_lib_191:			; else
_lib_194:			; while(str[sz]!=0)
	;LEA	EDX,[EBP+12] ;*
	MOV	ECX,[EDX] ;*
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	; eax = sz
	; ecx = str[0]
	ADD	ECX,EAX
_lib_191: ; (eax = 0)
	MOVSX	EAX,BYTE [ECX]	; str[sz]
	OR	EAX,EAX
	JZ	short _lib_195
_lib_196:
	;LEA	EBX,[EBP+16]	; ++sz;
	MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _lib_194
_lib_195:
;_lib_193:
;_lib_190:
_lib_200:
_lib_197:			; while(sz)
	;LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
_lib_190:
	OR	EAX,EAX
	JZ	short _lib_198
_lib_193:
_lib_199:
	LEA	ECX,[EBP-4]	; {digit=nbr&7;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	AND	EAX,7
	MOV	[ECX],EAX
	;LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; nbr=(nbr>>3)&8191;
	;MOV	CL,3
	;SAR	EAX,CL
	SAR	EAX,3
	AND	EAX,8191
	MOV	[EBX],EAX
	;LEA	EDX,[EBP+12]	; str[--sz]=digit+48;
	MOV	ECX,[EDX]	; str[0]
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]	; sz
	DEC	EAX		; --sz
	MOV	[EBX],EAX
	ADD	ECX,EAX		; str[sz]
	LEA	EDX,[EBP-4]	; digit
	MOV	EAX,[EDX]
	;ADD	EAX,48	; '0'
	ADD	AL,48		; digit+48
	MOV	[ECX],AL
	LEA	ECX,[EBP+8]	; if(nbr==0)
	MOV	EAX,[ECX]
	OR	EAX,EAX
	JNZ	short _lib_200	; while
_lib_201:
;_lib_198:
;_lib_202:			; break;
	;LEA	EBX,[EBP+16]	; while(sz>0)
	MOV	EAX,[EBX]
_lib_202:
	OR	EAX,EAX
	JNZ	short _lib_204
	;JMP	short _lib_203
_lib_198: ; (eax = 0)
_lib_203:
	LEA	EBX,[EBP+12]	; return str;
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_lib_204:			; str[--sz]=' ';
	LEA	EDX,[EBP+12]	; str address
	MOV	ECX,[EDX]	; str[0]
	LEA	EBX,[EBP+16]	; sz address
	MOV	EAX,[EBX]
	DEC	EAX		; --sz
	MOV	[EBX],EAX	; sz
	ADD	ECX,EAX		; str[sz]
	MOV	BYTE [ECX],32	; space
	JMP	short _lib_202	; while

;/*
;** itou -- convert nbr to unsigned decimal string
;**	    of width sz right adjusted,
;**	    blank filled; returns str
;**
;**	if sz > 0 terminate with null byte
;**	if sz = 0 find end of string
;**	if sz < 0 use last byte for data
;*/

_itou:				; itou(nbr,str,sz)
	PUSH	EBP	; int nbr; char str[]; int sz;
	MOV	EBP,ESP
	ADD	ESP,-4		; int lowbit;
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]	; if(sz>0)
	LEA	EDX,[EBP+12] ;*
	MOV	ECX,[EDX] ;*	; str[0] address
	OR	EAX,EAX
	;JG	short _lib_207
	;JMP	short _lib_206
	;JNG	short _lib_206	; else
	JG	short _lib_207
	JZ	short _lib_209	; JNL (eax=0)
;_lib_206:
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	;OR	EAX,EAX
	;JNL	short _lib_209	; else
_lib_210:	; JL
	;LEA	EBX,[EBP+16]	; sz=-sz;
	;MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
	JMP	short _lib_211
_lib_207:
	;LEA	EDX,[EBP+12] ;*	; str[--sz]=NULL;
	;MOV	ECX,[EDX] ;*
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	ADD	ECX,EAX
	;XOR	EAX,EAX
	;MOV	[ECX],AL
	MOV	BYTE [ECX],0
	JMP	short _lib_208
;_lib_209: ; (eax = sz = 0)	; else
_lib_212:			; while(str[sz]!=NULL)
	;LEA	EDX,[EBP+12] ;*
	MOV	ECX,[EDX] ;*	; str[0] address
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	; eax = sz
	; ecx = str[0]
	ADD	ECX,EAX
_lib_209: ; (eax = 0)
	MOVSX	EAX,BYTE [ECX]	; str[sz] value
	OR	EAX,EAX
	JZ	short _lib_213
_lib_214:
	;LEA	EBX,[EBP+16]	; ++sz;
	MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _lib_212
_lib_213:
;_lib_211:
;_lib_208:
_lib_215:
_lib_218:			; while(sz)
	;LEA	EBX,[EBP+16] ; *
	MOV	EAX,[EBX]
_lib_208:
	OR	EAX,EAX
	JZ	short _lib_216
_lib_211:
_lib_217:			; {lowbit=nbr&1;
	LEA	EDX,[EBP-4]	; lowbit
	LEA	ECX,[EBP+8]
	MOV	EAX,[ECX]	; nbr
	AND	EAX,1
	MOV	[EDX],EAX
	;LEA	ECX,[EBP+8]	; nbr=(nbr>>1)&32767;
	MOV	EAX,[ECX]
	SAR	EAX,1
	AND	EAX,32767
	MOV	[ECX],EAX
		; str[--sz]=((nbr%5)<<1)+lowbit+'0';
	LEA	EDX,[EBP+12]	; str
	MOV	ECX,[EDX]	; str[0]
	LEA	EBX,[EBP+16]	; sz address
	MOV	EAX,[EBX]	; sz value
	DEC	EAX		; --sz
	MOV	[EBX],EAX	; sz = sz-1
	ADD	ECX,EAX		; str[sz] address
	PUSH	ECX ; ***
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; ((nbr%5)<<1)
	MOV	ECX,5
	CDQ
	IDIV	ECX
	MOV	[EBX],EAX ; **	; nbr = nbr/5
	SAL	EDX,1		; <<1
	LEA	ECX,[EBP-4]
	MOV	EAX,[ECX]
	ADD	EAX,EDX		; +lowbit+'0';
	;ADD	EAX,48	; '0'
	ADD	AL,48
	POP	ECX ; ***
	MOV	[ECX],AL	; str[sz] =
		; if((nbr=nbr/5)==0) break;
	MOV	EAX,[EBX] ; **	; nbr
	LEA	EBX,[EBP+16] ; *
	OR	EAX,EAX
	JNZ	short _lib_218	; nbr <> 0
_lib_219:			; nbr = 0
;_lib_216:
_lib_220:
	;LEA	EBX,[EBP+16]	; while(sz)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _lib_221
	JNE	short _lib_222
_lib_221:
_lib_216:			; return str;
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_lib_222:			; str[--sz]=' ';
	LEA	EDX,[EBP+12]
	MOV	ECX,[EDX]	; str[0]
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX	; sz = sz-1
	ADD	ECX,EAX
	;MOV	EAX,32
	;MOV	[ECX],AL	; str[sz] =
	MOV	BYTE [ECX],32	; space
	JMP	short _lib_220

;/*
;** itox -- converts nbr to hex string of
;**	    length sz right adjusted and
;**	    blank filled, returns str
;**
;**	if sz > 0 terminate with null byte
;**	if sz = 0 find end of string
;**	if sz < 0 use last byte for data
;*/

_itox:				; itox(nbr,str,sz)
	PUSH	EBP	; int nbr; char str[]; int sz;
	MOV	EBP,ESP
	ADD	ESP,-8		; int digit,offset;
	LEA	EBX,[EBP+16]	; if(sz>0) str[--sz]=0;
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JG	short _lib_225
	;JMP	short _lib_224
	;JNG	short _lib_224
	JL	short _lib_228	; else if(sz<0)
	JE	short _lib_227
_lib_225:
	LEA	EDX,[EBP+12]	; str[--sz]=0;
	MOV	ECX,[EDX]
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	ADD	ECX,EAX
	;XOR	EAX,EAX
	;MOV	[ECX],AL
	MOV	BYTE [ECX],0
	JMP	short _lib_226
;_lib_224:
	;;LEA	EBX,[EBP+16]
	;;MOV	EAX,[EBX]
	;OR	EAX,EAX
	;JL	short _lib_228
	;;JMP	short _lib_227
_lib_227:			; else
_lib_230:			; while(str[sz]!=0)
	LEA	EDX,[EBP+12]
	MOV	ECX,[EDX]	; str[0]
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	ADD	ECX,EAX
	MOVSX	EDX,BYTE [ECX]	; str[sz]
	OR	EDX,EDX
	JE	short _lib_231
_lib_232:
	;LEA	EBX,[EBP+16]	; ++sz;
	;MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _lib_230
_lib_228:
	;LEA	EAX,[EBP+16]	; sz=-sz;
	;MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
	;JMP	short _lib_229
	JMP	short _lib_235	; eax > 0
_lib_231:
_lib_229:
_lib_226:
_lib_233:
_lib_239:			; while(sz)
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _lib_234
_lib_235:
	LEA	EDX,[EBP+8]	; {digit=nbr&15;
	MOV	EAX,[EDX]
	AND	EAX,15
	LEA	EBX,[EBP-4]	; digit
	MOV	[EBX],EAX
	;LEA	EDX,[EBP+8]	; nbr=nbr/16;
	MOV	EAX,[EDX]
	MOV	ECX,16
	CDQ
	IDIV	ECX
	MOV	[EDX],EAX	; nbr
	LEA	EAX,[EBP-4]	; if(digit<10)
	MOV	EBX,[EAX]
	MOV	EAX,10
	CALL	__lt
	LEA	EBX,[EBP-8] ; * ; offset
	OR	EAX,EAX
	JZ	short _lib_236	; else
_lib_237:
	;LEA	EBX,[EBP-8] ; *	; offset=48;
	;MOV	EAX,48
	MOV	AL,48
	;MOV	[EBX],EAX
	;MOV	[EBX],48
	JMP	short _lib_238
_lib_236:
	;LEA	EBX,[EBP-8] ; *
	;MOV	EAX,55
	MOV	AL,55
_lib_238:
	MOV	[EBX],EAX
;_lib_238:		; str[--sz]=digit+offset;
	PUSH	EBX ; *
	LEA	EDX,[EBP+12]	; str
	MOV	ECX,[EDX]	; str[0]
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	DEC	EAX		; --sz
	MOV	[EBX],EAX
	ADD	ECX,EAX		; str[sz]
	LEA	EBX,[EBP-4]	; digit+offset;
	MOV	EAX,[EBX]
	;LEA	EBX,[EBP-8] ; *
	POP	EBX ; *
	ADD	EAX,[EBX]	; + offset
	MOV	[ECX],AL
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _lib_239
_lib_240:
_lib_234:
;_lib_241:
	LEA	EBX,[EBP+16]	; while(sz)
	MOV	EAX,[EBX]
_lib_241:
	OR	EAX,EAX
	;JZ	short _lib_242
	JNZ	short _lib_243
_lib_242:
	;LEA	EDX,[EBP+12]	; return str;
	MOV	EAX,[EDX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_lib_243:
	;LEA	EDX,[EBP+12]	; str[--sz]=' ';
	MOV	ECX,[EDX]
	;LEA	EBX,[EBP+16]
	;MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	ADD	ECX,EAX
	;MOV	EAX,32
	;MOV	[EBX],AL
	MOV	BYTE [ECX],32	; space
	JMP	short _lib_241

;__iob:
;times 3*32 db 0x0
