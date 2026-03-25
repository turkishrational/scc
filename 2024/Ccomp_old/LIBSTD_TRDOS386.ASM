; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 15/09/2024
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
PUSH EBP
MOV  EBP, ESP
_puts_1:
LEA  EAX, [EBP+8]
PUSH EAX	; (*string)
MOV  EBX, [EAX] ; string's itself
MOVSX EAX, BYTE [EBX] ; char in string
POP  EBX
OR   EAX, EAX
JZ   short _puts_2
INC  DWORD [EBX] ; (*string++);
PUSH EAX
MOV  CL, 1 ; 1 argument
CALL _OS_putc
;ADD ESP, 4
POP  EAX
JMP  short _puts_1
_puts_2:
POP  EBP
RETN

_reverse:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -8
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  CL, 1
CALL _strlen
ADD  ESP, 4
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, 1
XCHG EAX, EBX
SUB  EAX, EBX
POP  EBX
MOV  [EBX], EAX
_lib_3:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
CALL __ult
OR   EAX, EAX
JNE  short _lib_5
JMP  short _lib_4
_lib_5:
LEA  EAX, [EBP-8]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
DEC  EAX
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
INC  EAX
PUSH EAX
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
MOV  [EBX], AL
JMP  short _lib_3
_lib_4:
MOV  ESP, EBP
POP  EBP
RETN

_strcpy:	; strcpy(s,t) char *s,*t;
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -4	; char *d;
LEA  EBX, [EBP+12]
MOV  EAX, [EBX]	; char *s
LEA  EBX, [EBP-4]
MOV  [EBX], EAX	; d=s;
_strcpy_1:	; while(*s++ =*t++);
LEA  EBX, [EBP+12] ; *s
MOV  EAX, [EBX]
INC  DWORD [EBX] ; *s++
PUSH EAX
LEA  EAX, [EBP+8] ; *t
MOV  EBX, [EAX]
INC  DWORD [EAX] ; *t++
MOVSX EAX, BYTE [EBX]
POP  EBX
MOV  [EBX], AL	; *s++ =*t++
OR   EAX, EAX
JNZ  short _strcpy_1
LEA  EBX, [EBP-4] ; pointer to d
MOV  EAX, [EBX] ; return (d);
MOV  ESP, EBP
POP  EBP
RETN

_strlen:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -4
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
MOV  [EBX], EAX
_lib_11:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
OR   EAX, EAX
JNE  short _lib_13
JMP  short _lib_12
_lib_13:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_11
_lib_12:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
XCHG EAX, EBX
SUB  EAX, EBX
MOV  ESP, EBP
POP  EBP
RETN

_toupper:
PUSH EBP
MOV  EBP, ESP
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 122
CALL __le
OR   EAX, EAX
JNE  short _lib_18
JMP  short _lib_16
_lib_18:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 97
CALL __ge
OR   EAX, EAX
JNE  short _lib_19
JMP  short _lib_16
_lib_19:
MOV  EAX, 1
JMP  short _lib_17
_lib_16:
XOR  EAX, EAX
_lib_17:
OR   EAX, EAX
JNE  short _lib_20
JMP  short _lib_15
_lib_20:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 32
XCHG EAX, EBX
SUB  EAX, EBX
POP  EBP
RETN
_lib_15:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBP
RETN

_atoi:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -8
_lib_22:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV  CL, 1
CALL _isspace
ADD  ESP, 4
OR   EAX, EAX
JNE  short _lib_24
JMP  short _lib_23
_lib_24:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_22
_lib_23:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, 1
MOV  [EBX], EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
JMP  short _lib_27
_lib_28:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, -1
MOV  [EBX], EAX
_lib_29:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_26
_lib_27:
CALL __switch
 DD _lib_28
 DD 45
 DD _lib_29
 DD 43
 DD 0
_lib_26:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], EAX
_lib_30:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV  CL, 1
CALL _isdigit
ADD  ESP, 4
OR   EAX, EAX
JNE  short _lib_32
JMP  short _lib_31
_lib_32:
LEA  EAX, [EBP-8]
PUSH EAX
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, 10
IMUL EBX
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
DEC  EAX
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, 48
XCHG EAX, EBX
SUB  EAX, EBX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_30
_lib_31:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
IMUL EBX
MOV  ESP, EBP
POP  EBP
RETN

_atoib:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -8
LEA  EAX, [EBP-4]
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], EAX
_lib_34:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
PUSH EAX
MOV  CL, 1
CALL _isspace
ADD  ESP, 4
OR   EAX, EAX
JNE  short _lib_36
JMP  short _lib_35
_lib_36:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_34
_lib_35:
_lib_37:
LEA  EAX, [EBP-8]
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
DEC  EAX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
MOV  EBX, 127
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
MOV  EBX, EAX
MOV  EAX, 48
CALL __ge
OR   EAX, EAX
JNE  short _lib_39
JMP  _lib_38
_lib_39:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 97
CALL __ge
OR   EAX, EAX
JNE  short _lib_41
JMP  short _lib_40
_lib_41:
LEA  EAX, [EBP-8]
PUSH EAX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 87
XCHG EAX, EBX
SUB  EAX, EBX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_42
_lib_40:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 65
CALL __ge
OR   EAX, EAX
JNE  short _lib_44
JMP  short _lib_43
_lib_44:
LEA  EAX, [EBP-8]
PUSH EAX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 55
XCHG EAX, EBX
SUB  EAX, EBX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_45
_lib_43:
LEA  EAX, [EBP-8]
PUSH EAX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 48
XCHG EAX, EBX
SUB  EAX, EBX
POP  EBX
MOV  [EBX], EAX
_lib_45:
_lib_42:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
CALL __ge
OR   EAX, EAX
JNE  short _lib_47
JMP  short _lib_46
_lib_47:
JMP  short _lib_38
_lib_46:
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
IMUL EBX
PUSH EAX
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
POP  EBX
MOV  [EBX], EAX
JMP  _lib_37
_lib_38:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  ESP, EBP
POP  EBP
RETN

_fgets:
PUSH EBP
MOV  EBP, ESP
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  EAX, 1
PUSH EAX
MOV  CL, 4
CALL __gets
ADD  ESP, 16
POP  EBP
RETN

_gets:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -12		; size,backup,*next
MOV  DWORD [EBP-4], 32767 ; size
LEA  EAX, [EBP-12]
PUSH EAX		; *next
LEA  EBX, [EBP+8]	; *str
MOV  EAX, [EBX]		; str
POP  EBX
MOV [EBX], EAX		; next=str;
_gets_1:
LEA  EBX, [EBP-4]	; *size
MOV  EAX, [EBX]		; ebx = *size, eax = size
DEC  EAX
MOV  [EBX], EAX
OR   EAX,EAX
JNZ  short _gets_2	; while(--size>0)
JMP  _gets_13
_gets_2:
LEA  EBX, [EBP-12]	; (*next=OS_getc())
MOV  EAX, [EBX]
PUSH EAX		; *next
MOV  CL,0		; no arguments
CALL _OS_getc
POP  EBX		; *next = *str
MOV  [EBX], AL		; *str=OS_getc()
JMP  _gets_12		; {switch (*next=OS_getc())
_gets_3:
LEA  EAX, [EBP-12]	; **next
MOV  EBX, [EAX]		; *next (address)
XOR  EAX, EAX		; NULL
MOV  [EBX], AL		; *next = NULL (value)
PUSH  EBX
LEA  EAX, [EBP+8]	; *str
MOV  EBX, [EAX]		; eax = *str, ebx = str
POP  EAX		; next
CALL __eq		; if(next==str) return (NULL);
OR   EAX, EAX
JZ  short _gets_4	; false (eax = 0)
			; true (eax = 1)
			; return (NULL);
XOR  EBX, EBX ; NULL
_gets_4:		; return (str);
MOV  EAX, EBX
MOV  ESP, EBP
POP  EBP
RETN

_gets_5:		; case '\n' 	
LEA  EAX, [EBP-12]	; **next
MOV  EBX, [EAX]		; *next (address)
XOR  EAX, EAX		; NULL
MOV  [EBX],EAX		; *next=NULL; (value)

LEA  EBX, [EBP+8]	; *str (ebx = str address)
MOV  EAX, [EBX]		; return (str);
MOV  ESP, EBP
POP  EBP
RETN

_gets_6:		; case '\b'
LEA  EBX, [EBP-12]	; *next
MOV  EAX, [EBX]		; ebx = *next, eax = next
PUSH EAX
LEA  EBX, [EBP+8]	; *str
MOV  EAX, [EBX]		; ebx = *str, eax = str
POP  EBX		; next (*next, string address/pos)
CALL __ugt		; if(next>str) backup=1;
;OR  EAX,EAX
;JNZ short _lib_63	; true (eax=1)
;JMP short _lib_62	; false (eax=0)
;_lib_63:		; backup=1;
;LEA EBX, [EBP-8]	; *backup
;MOV EAX, 1		; ebx = *backup (pointer to backup val)	
;MOV [EBX], EAX		; backup=1
;;JMP short _lib_64
;JMP short _gets_8
;_lib_62:		; else backup=0;
LEA EBX, [EBP-8]	; ebx = *backup
;XOR EAX, EAX ; 0
MOV  [EBX], EAX		; backup = 1 or backup = 0
;_lib_64:
JMP  short _gets_8	; goto backout;
_gets_7:		; case '\r' ; WIPE
LEA  EAX, [EBP-8]	; *backup ; backup=next-str;
PUSH EAX
LEA  EBX, [EBP-12]	; *next
;MOV EAX, [EBX]		; ebx = *next, eax = next
;PUSH EAX
PUSH DWORD [EBX]
LEA  EAX, [EBP+8]	; *str
MOV  EBX, [EAX]		; eax = *str, ebx = str 
POP  EAX		; next
SUB  EAX, EBX		; next-str
POP  EBX		; *backup
MOV  [EBX], EAX		; ebx = *backup, eax = backup (value)
			; backup=next-str;
_gets_8:		; backout:
;JMP short _lib_67	; if(0/*iscons(fd)*/)
LEA  EBX, [EBP-4]	; *size
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]	; ++size;	
_gets_9:		; while(backup--)
LEA  EBX, [EBP-8]	; *backup
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
INC  EAX
;OR  EAX, EAX
JNZ  short _gets_10
;JMP short _lib_69
JMP  _gets_1
_gets_10:		; puts("\b \b");
MOV  EAX, _gets_14	; "\b \b"
PUSH EAX
CALL _puts
POP  EAX		; add esp, 4
LEA  EBX, [EBP-12]	; *next
;MOV EAX, [EBX]		; ebx = *next (address)
;DEC EAX
;MOV [EBX], EAX
DEC  DWORD [EBX]	; --next	
LEA  EBX, [EBP-4]	; *size
;MOV EAX, [EBX]		; ebx = *size
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]	; ++size
JMP  short _gets_9
;_lib_69:
;JMP _gets_1
;_lib_67:
_gets_11:		; default:
LEA  EBX, [EBP-12]	; **next
;MOV EAX, [EBX]		; ebx = *next
;INC EAX		; ++next
;MOV [EBX], EAX
INC  DWORD [EBX]
;JMP short _lib_55
jmp  _gets_1	
_gets_12:		; {switch (*next=OS_getc())
CALL __switch
 DD  _gets_3		; case EOF
 DD  -1
 DD  _gets_5		; case '\n' 
 DD  10
 DD  _gets_6		; case '\b' ; case RUB
 DD  8
 DD  _gets_7		; case '\r' ; case WIPE
 DD  24
 DD  0			; case default
JMP short _gets_11	; default: ++next;
;_lib_55:
;JMP _gets_1
_gets_13:
LEA  EAX, [EBP-12]	; **next
MOV  EBX, [EAX]		; ebx = *next, eax = **next
XOR  EAX, EAX		; NULL
MOV  [EBX], AL		; *next = NULL;
LEA  EBX, [EBP+8]	; **str
MOV  EAX, [EBX]		; ebx = *str, eax = str
MOV  ESP, EBP		; return (str);
POP  EBP
RETN

_gets_14: DB 8,32,8,0	; "\b \b"

__gets:
PUSH EBP
MOV EBP,ESP
ADD ESP,-8
LEA EAX,[EBP-8]
PUSH EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],EAX
_lib_51:
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
OR EAX,EAX
JNE _lib_53
JMP _lib_52
_lib_53:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _OS_fgetc
ADD ESP,4
POP EBX
MOV [EBX],AL
JMP _lib_56
_lib_57:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
CALL __eq
OR EAX,EAX
JNE _lib_59
JMP _lib_58
_lib_59:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET
_lib_58:
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET
_lib_60:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET
_lib_61:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
CALL __ugt
OR EAX,EAX
JNE _lib_63
JMP _lib_62
_lib_63:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX,1
MOV [EBX],EAX
JMP _lib_64
_lib_62:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_lib_64:
JMP _lib_65
_lib_66:
LEA EAX,[EBP-4]
PUSH EAX
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
XCHG EAX,EBX
SUB EAX,EBX
POP EBX
MOV [EBX],EAX
_lib_65:
JMP _lib_67
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
_lib_68:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
OR EAX,EAX
JNE _lib_70
JMP _lib_69
_lib_70:
MOV EAX,_lib_50+0
PUSH EAX
MOV EAX,__iob
MOV EBX,64
ADD EAX,EBX
PUSH EAX
MOV CL,2
CALL _fputs
ADD ESP,8
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_68
_lib_69:
JMP _lib_51
_lib_67:
_lib_71:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_55
_lib_56:
CALL __switch
 DD _lib_57
 DD -1
 DD _lib_60
 DD 10
 DD _lib_61
 DD 8
 DD _lib_66
 DD 24
 DD 0
JMP _lib_71
_lib_55:
JMP _lib_51
_lib_52:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET
_lib_50 DB 8,32,8,0


_fprintf:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -4
LEA  EAX, [EBP-4]
PUSH EAX
CALL _CCARGC
PUSH EAX
LEA  EAX, [EBP+8]
POP  EBX
SHL  EBX, 1
SHL  EBX, 1
ADD  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
DEC  EAX
DEC  EAX
DEC  EAX
MOV  [EBX], EAX
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
DEC  EAX
DEC  EAX
DEC  EAX
MOV  [EBX], EAX
PUSH EAX
MOV  CL, 2
CALL __print
ADD  ESP, 8
MOV  ESP, EBP
POP  EBP
RETN

__print:
PUSH EBP
MOV EBP,ESP
ADD ESP,-56
LEA EAX,[EBP-16]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
LEA EAX,[EBP-32]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
DEC EAX
DEC EAX
DEC EAX
MOV [EBX],EAX
INC EAX
INC EAX
INC EAX
INC EAX
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],EAX
_lib_75:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _lib_77
JMP _lib_76
_lib_77:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,37
CALL __ne
OR EAX,EAX
JNE _lib_79
JMP _lib_78
_lib_79:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_75
JMP _lib_80
_lib_78:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
_lib_80:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,37
CALL __eq
OR EAX,EAX
JNE _lib_82
JMP _lib_81
_lib_82:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_75
_lib_81:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,45
CALL __eq
OR EAX,EAX
JNE _lib_84
JMP _lib_83
_lib_84:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX,1
MOV [EBX],EAX
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_85
_lib_83:
LEA EAX,[EBP-8]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_lib_85:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,48
CALL __eq
OR EAX,EAX
JNE _lib_87
JMP _lib_86
_lib_87:
LEA EAX,[EBP-12]
MOV EBX,EAX
MOV EAX,48
MOV [EBX],EAX
JMP _lib_88
_lib_86:
LEA EAX,[EBP-12]
MOV EBX,EAX
MOV EAX,32
MOV [EBX],EAX
_lib_88:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _isdigit
ADD ESP,4
OR EAX,EAX
JNE _lib_90
JMP _lib_89
_lib_90:
LEA EAX,[EBP-28]
PUSH EAX
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
PUSH EAX
MOV CL,1
CALL _atoi
ADD ESP,4
POP EBX
MOV [EBX],EAX
_lib_91:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _isdigit
ADD ESP,4
OR EAX,EAX
JNE _lib_93
JMP _lib_92
_lib_93:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_91
_lib_92:
JMP _lib_94
_lib_89:
LEA EAX,[EBP-28]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_lib_94:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,46
CALL __eq
OR EAX,EAX
JNE _lib_96
JMP _lib_95
_lib_96:
LEA EAX,[EBP-24]
PUSH EAX
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
PUSH EAX
MOV CL,1
CALL _atoi
ADD ESP,4
POP EBX
MOV [EBX],EAX
_lib_97:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _isdigit
ADD ESP,4
OR EAX,EAX
JNE _lib_99
JMP _lib_98
_lib_99:
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_97
_lib_98:
JMP _lib_100
_lib_95:
LEA EAX,[EBP-24]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_lib_100:
LEA EAX,[EBP-4]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
DEC EAX
DEC EAX
DEC EAX
MOV [EBX],EAX
INC EAX
INC EAX
INC EAX
INC EAX
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],EAX
LEA EAX,[EBP-36]
PUSH EAX
LEA EAX,[EBP-56]
POP EBX
MOV [EBX],EAX
LEA EAX,[EBP-32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
JMP _lib_103
_lib_104:
LEA EAX,[EBP-56]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],AL
LEA EAX,[EBP-56]
MOV EBX,1
ADD EAX,EBX
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
JMP _lib_102
_lib_105:
LEA EAX,[EBP-36]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],EAX
JMP _lib_102
_lib_106:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-56]
PUSH EAX
MOV CL,2
CALL _itoa
ADD ESP,8
JMP _lib_102
_lib_107:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-56]
PUSH EAX
MOV EAX,2
PUSH EAX
MOV CL,3
CALL _itoab
ADD ESP,12
JMP _lib_102
_lib_108:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-56]
PUSH EAX
MOV EAX,8
PUSH EAX
MOV CL,3
CALL _itoab
ADD ESP,12
JMP _lib_102
_lib_109:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-56]
PUSH EAX
MOV EAX,10
PUSH EAX
MOV CL,3
CALL _itoab
ADD ESP,12
JMP _lib_102
_lib_110:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-56]
PUSH EAX
MOV EAX,16
PUSH EAX
MOV CL,3
CALL _itoab
ADD ESP,12
JMP _lib_102
_lib_111:
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET
JMP _lib_102
_lib_103:
CALL __switch
 DD _lib_104
 DD 99
 DD _lib_105
 DD 115
 DD _lib_106
 DD 100
 DD _lib_107
 DD 98
 DD _lib_108
 DD 111
 DD _lib_109
 DD 117
 DD _lib_110
 DD 120
 DD 0
JMP _lib_111
_lib_102:
LEA EAX,[EBP-20]
PUSH EAX
LEA EAX,[EBP-36]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _strlen
ADD ESP,4
POP EBX
MOV [EBX],EAX
LEA EAX,[EBP-24]
MOV EBX,EAX
MOV EAX, [EBX]
OR EAX,EAX
JNE _lib_115
JMP _lib_113
_lib_115:
LEA EAX,[EBP-24]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
CALL __lt
OR EAX,EAX
JNE _lib_116
JMP _lib_113
_lib_116:
MOV EAX,1
JMP _lib_114
_lib_113:
XOR EAX,EAX
_lib_114:
OR EAX,EAX
JNE _lib_117
JMP _lib_112
_lib_117:
LEA EAX,[EBP-20]
PUSH EAX
LEA EAX,[EBP-24]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],EAX
_lib_112:
LEA EAX,[EBP-28]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
CALL __gt
OR EAX,EAX
JNE _lib_119
JMP _lib_118
_lib_119:
LEA EAX,[EBP-28]
PUSH EAX
LEA EAX,[EBP-28]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
XCHG EAX,EBX
SUB EAX,EBX
POP EBX
MOV [EBX],EAX
JMP _lib_120
_lib_118:
LEA EAX,[EBP-28]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_lib_120:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
CALL __lneg
OR EAX,EAX
JNE _lib_122
JMP _lib_121
_lib_122:
_lib_123:
LEA EAX,[EBP-28]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
OR EAX,EAX
JNE _lib_125
JMP _lib_124
_lib_125:
LEA EAX,[EBP-12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_123
_lib_124:
_lib_121:
_lib_126:
LEA EAX,[EBP-20]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
OR EAX,EAX
JNE _lib_128
JMP _lib_127
_lib_128:
LEA EAX,[EBP-36]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_126
_lib_127:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
OR EAX,EAX
JNE _lib_130
JMP _lib_129
_lib_130:
_lib_131:
LEA EAX,[EBP-28]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
OR EAX,EAX
JNE _lib_133
JMP _lib_132
_lib_133:
LEA EAX,[EBP-12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _lib_131
_lib_132:
_lib_129:
JMP _lib_75
_lib_76:
LEA EAX,[EBP-16]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET

_printf:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -60
CALL _CCARGC		; CCARGC()+
DEC  EAX		; &argc-1;
SHL  EAX, 1
SHL  EAX, 1
LEA  EBX, [EBP+8]	; &argc
ADD  EAX, EBX
LEA  EBX, [EBP-4]	; *nxtarg;
MOV  [EBX], EAX		; *nxtarg=CCARGC()+&argc-1;
;
LEA  EBX, [EBP-20]	; cc
XOR  EAX, EAX		; 0
MOV  [EBX], EAX		; cc=0;
LEA  EBX, [EBP-4]	; *nxtarg
MOV  EAX, [EBX]
PUSH EBX
LEA  EBX, [EBP-36]	; ctl
MOV  [EBX], EAX		; ctl=*nxtarg
POP  EBX
DEC  EAX
DEC  EAX
DEC  EAX
DEC  EAX
MOV  [EBX], EAX		; ctl=*nxtarg--;
_printf_1:		; while(*ctl)
LEA  EBX, [EBP-36]
MOV  EBX, [EBX]
MOVSX EAX, BYTE [EBX]
OR   EAX, EAX
JNZ  short _printf_2	; jump to {if(*ctl!='%')
JMP  short _lib_76	; jump to return (cc);
_printf_2:		; {if(*ctl!='%')
MOV  EBX, EAX
MOV  EAX, 37		;'%'
CALL __ne		; if(*ctl!='%') 
OR   EAX, EAX
;JNZ short _lib_79	; {OS_putc(*ctl++);
;JMP short _printf_3	; else ++ctl;
JZ   short _printf_3
;_lib_79:
LEA  EBX, [EBP-36]	; *ctl++
MOV  EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]	; ctl++
;DEC EAX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]	; *ctl
PUSH EAX
MOV  CL, 1
CALL _OS_putc		; OS_putc(*ctl++);
POP  EAX		; add esp, 4
LEA  EBX, [EBP-20]	; ++cc;
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]
JMP  short _printf_1	; continue; (jump to while(*ctl))
_printf_3:		; else ++ctl;
LEA  EBX, [EBP-36]	; *ctl++
MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]
MOVSX EBX, BYTE [EAX]
MOV  EAX, 37		;'%'
CALL __eq		; if(*ctl=='%')
OR   EAX, EAX
;JNZ short _lib_82	; {OS_putc(*ctl++)
;JMP short _printf_4	; else/endif
JZ   short _printf_4	
;_lib_82:
LEA  EBX, [EBP-36]	; ctl++
MOV  EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
;DEC EAX
INC  DWORD [EBX]
MOVSX EBX, BYTE [EAX]
PUSH EBX
MOV  CL, 1
CALL _OS_putc
POP  EAX		; add esp, 4
LEA  EBX, [EBP-20]	; ++cc;
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]
JMP  short _printf_1	; continue;
_printf_4:
LEA  EBX, [EBP-36]	; if(*ctl=='-')
MOV  EAX, [EBX]
MOVSX EBX, BYTE [EAX]
MOV  EAX, 45		; '-'
CALL __eq
OR   EAX, EAX
;JNZ short _lib_84	; if(*ctl=='-')
;JMP short _printf_5	; else
JZ   short _printf_5 
;_lib_84:
LEA  EBX, [EBP-12]	; {left=1;
;MOV EAX, 1
;eax = 1
MOV  [EBX], EAX
LEA  EBX, [EBP-36]
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]	; ++ctl;}
JMP  short _printf_6
_printf_5:		; left=0;
LEA  EBX, [EBP-12]
;XOR EAX, EAX
;eax = 0
MOV  [EBX], EAX
_printf_6:		; if(*ctl=='0') pad='0';
LEA  EBX, [EBP-36]
MOV  EAX, [EBX]
MOVSX EBX, BYTE [EAX]
MOV  EAX, 48		; '0'
CALL __eq		; if(*ctl=='0')
LEA  EBX, [EBP-16]
OR   EAX, EAX
;JNZ short _lib_87	; pad='0';
;JMP short _printf_7	; else pad=' ';
JZ   short _printf_7 
;_lib_87:
;LEA EBX, [EBP-16]	; pointer to pad
MOV  EAX, 48		; '0'
;MOV [EBX], EAX		; pad='0';
JMP  short _printf_8	; if(isdigit(*ctl))
_printf_7:
;LEA  EBX, [EBP-16]
MOV  EAX, 32		; pad=' ';
_printf_8:
MOV  [EBX], EAX
;_printf_8:
LEA  EAX, [EBP-36]	; if(isdigit(*ctl))
MOV  EBX, [EAX]
MOVSX EAX, BYTE [EBX]
PUSH EAX
MOV  CL, 1
CALL _isdigit
;ADD ESP, 4
POP  EBX		; add esp, 4
OR   EAX, EAX
;JNZ short _lib_90	; {width=atoi(ctl++);
;JMP short _printf_10
JZ   short _printf_10 	; width=0;
;_lib_90:		
LEA  EAX, [EBP-32]	; width=atoi(ctl++);
PUSH EAX		; pointer to width
LEA  EBX, [EBP-36]
MOV  EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
;DEC EAX
INC  DWORD [EBX]	; (ctl++);
PUSH EAX
MOV  CL, 1		; argument count
CALL _atoi		; atoi(ctl++);
;ADD ESP, 4
POP  EBX		; add esp, 4	
POP  EBX		; pointer to width
MOV  [EBX], EAX		; width=atoi(ctl++);
_printf_9:
LEA  EAX, [EBP-36]	; while(isdigit(*ctl))
MOV  EBX, [EAX]
MOVSX EAX, BYTE [EBX]
PUSH EAX
MOV  CL, 1
CALL _isdigit
;ADD ESP, 4
POP  EBX
OR   EAX, EAX
;JNZ short _lib_93	; isdigit(*ctl) = true/1
;JMP short _lib_92	; isdigit(*ctl) = false/0
JZ   short _printf_11	; jump to if(*ctl=='.')
;_lib_93:
LEA  EBX, [EBP-36]	; ++ctl;
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]
JMP  short _printf_9	; jump to while(isdigit(*ctl))
;_lib_92:
;JMP  short _printf_11	; jump to if(*ctl=='.')
_printf_10:
LEA  EBX, [EBP-32]	; width=0;
;XOR  EAX, EAX
;eax = 0
MOV  [EBX], EAX
_printf_11:
LEA  EBX, [EBP-36]	; if(*ctl=='.')
MOV  EAX, [EBX]
MOVSX EBX,BYTE [EAX]
MOV  EAX, 46		; '.'
CALL __eq
OR   EAX, EAX
;JNZ short _lib_96	; *ctl=='.' = true/1
;JMP short _lib_95	; *ctl=='.' = false/0
JZ   short _printf_13	; else maxchr=0;
;_lib_96:		; {maxchr=atoi(++ctl);
;LEA EAX, [EBP-28]
;PUSH EAX		; maxchr
LEA  EBX, [EBP-36]
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
PUSH EAX
MOV  CL, 1
CALL _atoi
;ADD ESP, 4
POP  EBX 		; add esp, 4
;POP EBX		; maxchr
LEA EBX, [EBP-28]
MOV  [EBX], EAX		; maxchr=atoi(++ctl);
_printf_12:
LEA  EAX, [EBP-36]	; while(isdigit(*ctl))
MOV  EBX, [EAX]
MOVSX EAX, BYTE [EBX]	; (*ctl)
PUSH EAX
MOV  CL, 1
CALL _isdigit		; isdigit(*ctl)
;ADD ESP, 4
POP  EBX		; add esp, 4 
OR   EAX, EAX
;JNZ short _lib_99	; isdigit(*ctl) = true/1
;JMP short _lib_98	; isdigit(*ctl) = false/0
JZ   short _printf_14	; jump to arg=*nxtarg--;
;_lib_99:
LEA  EBX, [EBP-36]
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX		; ++ctl;
INC  DWORD [EBX]
JMP  short _printf_12	; jump to while(isdigit(*ctl))
;_lib_98:
;JMP short _printf_14
_printf_13:		; else maxchr=0;
LEA  EBX, [EBP-28]
;XOR EAX, EAX
;eax = 0
MOV  [EBX], EAX		; maxchr=0;
_printf_14:
;LEA  EAX, [EBP-8]	; arg=*nxtarg--;
;PUSH EAX
LEA  EBX, [EBP-4]
MOV  EAX, [EBX]		; *nxtarg
PUSH EAX
DEC  EAX
DEC  EAX
DEC  EAX
DEC  EAX
MOV  [EBX], EAX		; *nxtarg--
POP  EBX
MOV  EAX, [EBX]
;POP EBX
LEA  EBX, [EBP-8]	; pointer to arg
MOV  [EBX], EAX		; arg=*nxtarg--;
;LEA EAX, [EBP-40]	; *sptr
;PUSH EAX		
LEA  EAX, [EBP-60]	; pointer to str[17];
;POP EBX
LEA  EBX, [EBP-40]	; *sptr	
MOV  [EBX], EAX		; sptr=str;
LEA  EAX, [EBP-36]	; switch(*ctl++)
MOV  EBX, [EAX]
INC  DWORD [EAX]	; *ctl++
MOVSX EAX, BYTE [EBX]	; char = (*ctl++)
JMP  _printf_23		; jump to switch
;
_printf_15:		; case 'c': str[0]=arg; str[1]=NULL;
LEA  EBX, [EBP-8]	; pointer to arg
MOV  EAX, [EBX]		; arg
LEA  EBX, [EBP-60]	; pointer to str ; str[0]
MOV  [EBX], AL		; str[0]=arg
INC  EBX		; str[1]	
XOR  EAX, EAX		; NULL
MOV  [EBX], AL		; str[1]=NULL;
JMP  _printf_24		; break;
_printf_16:		; case 's': sptr=arg;
LEA  EBX, [EBP-8]	; pointer to arg
MOV  EAX, [EBX]		; arg
LEA  EBX, [EBP-40]	; pointer to sptr
MOV  [EBX], EAX		; sptr=arg;
JMP  _printf_24		; break;
_printf_17:		; case 'd': itoa(arg,str);
LEA  EBX, [EBP-8]
MOV  EAX, [EBX]		; arg
PUSH EAX
LEA  EAX, [EBP-60]
PUSH EAX
MOV  CL, 2		; 2 arguments
CALL _itoa		; itoa(arg,str);
;ADD ESP, 8
POP  EAX
POP  EAX
JMP  _printf_24		; break;
_printf_18:		; case 'b': itoab(arg,str,2);
LEA  EBX, [EBP-8]
MOV  EAX, [EBX]		; arg
PUSH EAX
LEA  EAX, [EBP-60]
PUSH EAX		; str (address)
MOV  EAX, 2		; 2 ; binary
PUSH EAX
MOV  CL, 3		; 3 arguments
CALL _itoab		; itoab(arg,str,2);
ADD  ESP, 12
JMP  _printf_24		; break;
_printf_19:		; case 'o': itoab(arg,str,8);
LEA  EBX, [EBP-8]
MOV  EAX, [EBX]
PUSH EAX		; arg
LEA  EAX, [EBP-60]
PUSH EAX		; str
MOV  EAX, 8		; 8 ; octal
PUSH EAX
MOV  CL, 3
CALL _itoab		; itoab(arg,str,8);
ADD  ESP, 12
JMP  _printf_24		; break;
_printf_20:		; case 'u': itoab(arg,str,10);
LEA  EBX, [EBP-8]
MOV  EAX, [EBX]
PUSH EAX		; arg
LEA  EAX, [EBP-60]
PUSH EAX		; str
MOV  EAX, 10		; 10 ; decimal
PUSH EAX
MOV  CL,3
CALL _itoab		; itoab(arg,str,10);
ADD  ESP, 12
JMP  short _printf_24	; break;
_printf_21:		; case 'x': itoab(arg,str,16);
LEA  EBX, [EBP-8]
MOV  EAX, [EBX]
PUSH EAX		; arg
LEA  EAX, [EBP-60]
PUSH EAX		; str
MOV  EAX, 16		; 16 ; hexadecimal
PUSH EAX
MOV  CL,3
CALL _itoab		; itoab(arg,str,16);
ADD  ESP, 12
JMP  short _printf_24	; break;
;
_printf_22:		; return (cc);
;_lib_76:		; return (cc);
LEA  EBX, [EBP-20]
MOV  EAX, [EBX]		; cc
MOV  ESP, EBP
POP  EBP
RETN
;
_printf_23:		; switch(*ctl++)
CALL __switch
 DD  _printf_15		; case 'c'
 DD  99			; 'c'
 DD  _printf_16		; case 's'
 DD  115		; 's'
 DD  _printf_17		; case 'd'
 DD  100		; 'd'
 DD  _printf_18		; case 'b'
 DD  98			; 'b'
 DD  _printf_19		; case 'o'
 DD  111		; 'o'
 DD  _printf_20		; case 'u'
 DD  117		; 'u'
 DD  _printf_21		; case 'x'
 DD  120		; 'x'
 DD  0			; case default
JMP  short _printf_22	; default: return (cc);
;
_printf_24:		; len=strlen(sptr);
;LEA  EAX, [EBP-24]
;PUSH EAX
LEA  EBX, [EBP-40]
MOV  EAX, [EBX]
PUSH EAX
MOV  CL, 1
CALL _strlen		; strlen(sptr);
;ADD ESP, 4
POP  EBX		; add esp, 4
;POP EBX
LEA  EBX, [EBP-24]	; pointer to len
MOV  [EBX], EAX		; len=strlen(sptr);
LEA  EBX, [EBP-28]	; pointer to maxchr
MOV  EAX, [EBX]
OR   EAX, EAX
;JNZ short _lib_115	; if(maxchr &&
;JMP short _lib_113	; else/endif
JZ   short _printf_25
;_lib_115:
;LEA EAX, [EBP-28]	; if(maxchr && maxchr<len)
;MOV EBX, EAX
;MOV EAX, [EBX]
PUSH EAX
LEA  EBX, [EBP-24]	; pointer to len
MOV  EAX, [EBX]		; len
POP  EBX		; maxchr
CALL __lt		; if (maxchr<len) ; if (eax > ebx)
OR   EAX, EAX
;JNZ short _lib_116	; true/1, then len=maxchr;
;JMP short _lib_113
JZ  short _printf_25	; false/0, endif
;_lib_116:
;MOV EAX, 1
;eax = 1
;JMP  short _lib_114
;_lib_113:
;XOR  EAX, EAX
;_lib_114:
;OR  EAX, EAX
;JNZ short _lib_117
;JMP short _printf_25
;_lib_117:		; len=maxchr;
;LEA EAX, [EBP-24]
;PUSH EAX
LEA  EBX, [EBP-28]	; pointer to maxchr
MOV  EAX, [EBX]
;POP EBX
LEA  EBX, [EBP-24]	; pointer to len
MOV  [EBX], EAX		; len=maxchr;
_printf_25:		; if(width>len)
LEA  EBX, [EBP-32]
MOV  EAX, [EBX]		; width
PUSH EAX
LEA  EBX, [EBP-24]
MOV  EAX, [EBX]		; len
POP  EBX		; width	
CALL __gt		; if (width>len) ; if (eax < ebx)
LEA  EBX, [EBP-32]	; width (address)
OR   EAX, EAX
;JNZ short _lib_119	; width=width-len;
;JMP short _printf_26	; else width=0;
JZ   short _printf_26
;_lib_119:
;LEA EBX, [EBP-32]	; width=width-len
PUSH EBX		; pointer to width (width address)
MOV  EAX, [EBX]		; width (value)
PUSH EAX
LEA  EAX, [EBP-24]	; pointer to len (len address)
MOV  EBX, [EAX]		; len value
POP  EAX		; width value
SUB  EAX, EBX		; width-len
POP  EBX
MOV  [EBX], EAX ; *	; width=width-len
;JMP short _lib_120 ; *	; jump to if(!left)
_printf_26:		; else width=0;
;LEA EBX, [EBP-32]
;XOR EAX, EAX
; eax = 0
MOV  [EBX], EAX	; *	; width=0;
;_lib_120:
LEA  EBX, [EBP-12]	; if(!left)
MOV  EAX, [EBX]
CALL __lneg		; (!left) ; if left = 0
OR   EAX, EAX
;JNZ short _lib_122	; true/1
;JMP short _printf_28	; false/0
JZ   short _printf_28	; else/endif
;_lib_122:
_printf_27:		; while(width--)
LEA  EBX, [EBP-32]
MOV  EAX, [EBX]
DEC  DWORD [EBX]
OR   EAX, EAX
;JNZ short _lib_125	; {OS_putc(pad);
;JMP short _lib_124	; jump to while(len--)
JZ   short _printf_28
;_lib_125:
LEA  EBX, [EBP-16]
MOV  EAX, [EBX]		; pad
PUSH EAX
MOV  CL, 1
CALL _OS_putc
;ADD ESP, 4
POP  EAX		; add esp, 4
LEA  EBX, [EBP-20]	; ++cc;}
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]	; ++cc
JMP  short _printf_27	; jump to while(width--)
;_lib_124:
_printf_28:		; while(len--)
;_lib_126:
LEA  EBX, [EBP-24]
MOV  EAX, [EBX]		; len
;DEC EAX
;MOV [EBX], EAX
;INC EAX
DEC  DWORD [EBX]	; (len--)
OR   EAX, EAX
;JNZ short _lib_128	; {OS_putc(*sptr++);
;JMP short _printf_29	; if(left)
JZ   short _printf_29
;_lib_128:
LEA  EAX, [EBP-40]	; (*sptr++)
MOV  EBX, [EAX]
INC  DWORD [EAX]
MOVSX EAX, BYTE [EBX]
PUSH EAX
MOV  CL, 1		; 1 argument
CALL _OS_putc		; OS_putc(*sptr++);
;ADD ESP, 4
POP  EAX		; add esp, 4
LEA  EBX, [EBP-20]
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]	; ++cc;}
;JMP short _lib_126
JMP  short _printf_28	; jump to while(len--)
_printf_29:
LEA  EBX, [EBP-12]	; if(left)
MOV  EAX, [EBX]
OR   EAX, EAX
;JNZ short _lib_130	; true/1, while(width--)
;JMP short _printf_31	; false/0, jump to while(*ctl)
jz   short _printf_31
;_lib_130:
_printf_30:		; while(width--)
LEA  EBX, [EBP-28]
MOV  EAX, [EBX]
DEC  DWORD [EBX]	; (width--)
OR   EAX, EAX
JNZ  short _printf_32
;JMP short _lib_132
;_lib132:
_printf_31:
JMP  _printf_1		; jump to while(*ctl)
_printf_32:
LEA  EBX, [EBP-16]	; {OS_putc(pad);
MOV  EAX, [EBX]
PUSH EAX		; pad (value/char)
MOV  CL, 1
CALL _OS_putc		; OS_putc(pad);
;ADD ESP, 4
POP  EAX		; add esp, 4
LEA  EBX, [EBP-20]	; ++cc;}
;MOV EAX, [EBX]
;INC EAX
;MOV [EBX], EAX
INC  DWORD [EBX]
JMP  short _printf_30	; jump to while(width--)

;_lib_76:		; return (cc);
;LEA EBX, [EBP-20]	; cc
;MOV EAX, [EBX]
;MOV ESP, EBP
;POP EBP
;RETN

_fputs:
PUSH EBP
MOV  EBP, ESP
_lib_135:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
OR   EAX, EAX
JNE  short _lib_137
JMP  short _lib_136
_lib_137:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
DEC  EAX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  CL, 2
CALL _OS_fputc
ADD  ESP, 8
JMP  short _lib_135
_lib_136:
POP  EBP
RETN
__is DD 4,4,4,4,4,4,4,4,4,260
 DD 260,260,260,260,4,4,4,4,4,4
 DD 4,4,4,4,4,4,4,4,4,4
 DD 4,4, 320,208,208,208,208,208,208,208
 DD 208,208,208,208,208,208,208,208,1113,1113
 DD 1113,1113,1113,1113,1113,1113,1113,1113,208,208
 DD 208,208,208,208,208,1619,1619,1619,1619,1619
 DD 1619,595,595,595,595,595,595,595,595,595
 DD 595,595,595,595,595,595,595,595,595,595
 DD 595,208,208,208,208,208,208,1139,1139,1139
 DD 1139,1139,1139,115,115,115,115,115,115,115
 DD 115,115,115,115,115,115,115,115,115,115
 DD 115,115,115,208,208,208,208,4

_isalnum:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1
AND  EAX, EBX
POP  EBP
RETN

_isalpha:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 2
AND  EAX, EBX
POP  EBP
RETN

_iscntrl:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 4
AND  EAX, EBX
POP  EBP
RETN

_isdigit:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 8
AND  EAX, EBX
POP  EBP
RETN

_isgraph:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 16
AND  EAX, EBX
POP  EBP
RETN

_islower:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 32
AND  EAX, EBX
POP  EBP
RETN

_isprint:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 64
AND  EAX, EBX
POP  EBP
RETN

_ispunct:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 128
AND  EAX, EBX
POP  EBP
RETN

_isspace:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 256
AND  EAX, EBX
POP  EBP
RETN

_isupper:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 512
AND  EAX, EBX
POP  EBP
RETN

_isxdigit:
PUSH EBP
MOV  EBP, ESP
MOV  EAX, __is
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
SHL  EAX, 1
SHL  EAX, 1
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1024
AND  EAX, EBX
POP  EBP
RETN

_itoa:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -8
LEA  EAX, [EBP-8]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
MOV  [EBX], EAX
OR   EAX, EAX
JL   short _lib_151
JMP  short _lib_150
_lib_151:
LEA  EAX, [EBP+12]
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
NEG EAX
POP  EBX
MOV  [EBX], EAX
_lib_150:
_lib_152:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
DEC  EAX
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 10
XCHG EAX, EBX
CDQ
IDIV EBX
MOV  EAX, EDX
MOV  EBX, 48
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP+12]
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 10
XCHG EAX, EBX
CDQ
IDIV EBX
POP  EBX
MOV  [EBX], EAX
OR   EAX, EAX
JG   short _lib_154
JMP  short _lib_153
_lib_154:
JMP  short _lib_152
_lib_153:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JL   short _lib_156
JMP  short _lib_155
_lib_156:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
DEC  EAX
MOV  EBX, EAX
MOV  EAX, 45
MOV  [EBX], AL
_lib_155:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], AL
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  CL, 1
CALL _reverse
ADD  ESP, 4
MOV  ESP, EBP
POP  EBP
RETN

_itoab:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -8
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+8]
PUSH EAX
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1
MOV  ECX, EAX
MOV  EAX, EBX
SAR  EAX, CL
POP  EBX
MOV  [EBX], EAX
_lib_158:
LEA  EAX, [EBP-8]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1
MOV  ECX, EAX
MOV  EAX, EBX
SAR  EAX, CL
MOV  EBX, EAX
MOV  EAX, 32767
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
XCHG EAX, EBX
CDQ
IDIV EBX
MOV  EAX, EDX
MOV  EBX, EAX
MOV  EAX, 1
MOV  ECX, EAX
MOV  EAX, EBX
SAL  EAX, CL
PUSH EAX
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
MOV  EBX, EAX
MOV  EAX, 10
CALL __lt
OR   EAX, EAX
JNE  short _lib_161
JMP  short _lib_160
_lib_161:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
MOV  EBX, 48
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
JMP  short _lib_162
_lib_160:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
MOV  EBX, 55
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
_lib_162:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
LEA  EAX, [EBP+16]
PUSH EAX
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
XCHG EAX, EBX
CDQ
IDIV EBX
POP  EBX
MOV  [EBX], EAX
OR   EAX, EAX
JNE  short _lib_163
JMP  short _lib_159
_lib_163:
JMP  _lib_158
_lib_159:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], AL
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
MOV  CL, 1
CALL _reverse
ADD  ESP, 4
MOV  ESP, EBP
POP  EBP
RETN

_itod:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -4
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JL   short _lib_166
JMP  short _lib_165
_lib_166:
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
NEG  EAX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, 45
MOV  [EBX], AL
JMP  short _lib_167
_lib_165:
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, 32
MOV  [EBX], AL
_lib_167:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JG   short _lib_169
JMP  short _lib_168
_lib_169:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], AL
JMP  short _lib_170
_lib_168:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JL   short _lib_172
JMP  short _lib_171
_lib_172:
LEA  EAX, [EBP+8]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
NEG  EAX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_173
_lib_171:
_lib_174:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
OR   EAX, EAX
JNE  short _lib_176
JMP  short _lib_175
_lib_176:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_174
_lib_175:
_lib_173:
_lib_170:
_lib_177:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_179
JMP  short _lib_178
_lib_179:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 10
XCHG EAX, EBX
CDQ
IDIV EBX
MOV  EAX, EDX
MOV  EBX, 48
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 10
XCHG EAX, EBX
CDQ
IDIV EBX
POP  EBX
MOV  [EBX], EAX
OR   EAX, EAX
JE   short _lib_181
JMP  short _lib_180
_lib_181:
JMP  short _lib_178
_lib_180:
JMP  short _lib_177
_lib_178:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_183
JMP  short _lib_182
_lib_183:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
POP  EBX
MOV  [EBX], AL
_lib_182:
_lib_184:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JG   short _lib_186
JMP  short _lib_185
_lib_186:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, 32
MOV  [EBX], AL
JMP  short _lib_184
_lib_185:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  ESP, EBP
POP  EBP
RETN

_itoo:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -4
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JG   short _lib_189
JMP  short _lib_188
_lib_189:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], AL
JMP  short _lib_190
_lib_188:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JL   short _lib_192
JMP  short _lib_191
_lib_192:
LEA  EAX, [EBP+8]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
NEG EAX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_193
_lib_191:
_lib_194:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
OR   EAX, EAX
JNE  short _lib_196
JMP  short _lib_195
_lib_196:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_194
_lib_195:
_lib_193:
_lib_190:
_lib_197:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_199
JMP  short _lib_198
_lib_199:
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 7
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 3
MOV  ECX, EAX
MOV  EAX, EBX
SAR  EAX, CL
MOV  EBX, EAX
MOV  EAX, 8191
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, 48
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JE   short _lib_201
JMP  short _lib_200
_lib_201:
JMP  short _lib_198
_lib_200:
JMP  short _lib_197
_lib_198:
_lib_202:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_204
JMP  short _lib_203
_lib_204:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, 32
MOV  [EBX], AL
JMP  short _lib_202
_lib_203:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  ESP, EBP
POP  EBP
RETN

_itou:
PUSH EBP
MOV  EBP, ESP
ADD  ESP, -4
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JG   short _lib_207
JMP  short _lib_206
_lib_207:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], AL
JMP  short _lib_208
_lib_206:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JL _lib_210
JMP  short _lib_209
_lib_210:
LEA  EAX, [EBP+8]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
NEG EAX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_211
_lib_209:
_lib_212:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOVSX EAX, BYTE [EBX]
OR   EAX, EAX
JNE  short _lib_214
JMP  short _lib_213
_lib_214:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_212
_lib_213:
_lib_211:
_lib_208:
_lib_215:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_217
JMP  _lib_216
_lib_217:
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 1
MOV  ECX, EAX
MOV  EAX, EBX
SAR  EAX, CL
MOV  EBX, EAX
MOV  EAX, 32767
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 5
XCHG EAX, EBX
CDQ
IDIV EBX
MOV  EAX, EDX
MOV  EBX, EAX
MOV  EAX, 1
MOV  ECX, EAX
MOV  EAX, EBX
SAL  EAX,CL
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
MOV  EBX, 48
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 5
XCHG EAX, EBX
CDQ
IDIV EBX
POP  EBX
MOV  [EBX], EAX
OR   EAX, EAX
JE   short _lib_219
JMP  short _lib_218
_lib_219:
JMP  short _lib_216
_lib_218:
JMP  _lib_215
_lib_216:
_lib_220:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_222
JMP  short _lib_221
_lib_222:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, 32
MOV  [EBX], AL
JMP  short _lib_220
_lib_221:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  ESP, EBP
POP  EBP
RETN

_itox:
PUSH EBP
MOV  EBP, ESP
ADD  ESP,-8
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JG _lib_225
JMP  short _lib_224
_lib_225:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
XOR  EAX, EAX
MOV  [EBX], AL
JMP  short _lib_226
_lib_224:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JL   short _lib_228
JMP  short _lib_227
_lib_228:
LEA  EAX, [EBP+8]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
NEG EAX
POP  EBX
MOV  [EBX], EAX
JMP  short _lib_229
_lib_227:
_lib_230:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOVSX EAX,BYTE [EBX]
OR   EAX, EAX
JNE  short _lib_232
JMP  short _lib_231
_lib_232:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
INC  EAX
MOV  [EBX], EAX
JMP  short _lib_230
_lib_231:
_lib_229:
_lib_226:
_lib_233:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_235
JMP  _lib_234
_lib_235:
LEA  EAX, [EBP-4]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 15
AND  EAX, EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP+16]
PUSH EAX
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 16
XCHG EAX, EBX
CDQ
IDIV EBX
POP  EBX
MOV  [EBX], EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  EBX, EAX
MOV  EAX, 10
CALL __lt
OR   EAX, EAX
JNE  short _lib_237
JMP  short _lib_236
_lib_237:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, 48
MOV  [EBX], EAX
JMP  short _lib_238
_lib_236:
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, 55
MOV  [EBX], EAX
_lib_238:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
PUSH EAX
LEA  EAX, [EBP-4]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP-8]
MOV  EBX, EAX
MOV  EAX, [EBX]
POP  EBX
ADD  EAX, EBX
POP  EBX
MOV  [EBX], AL
LEA  EAX, [EBP+16]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JE   short _lib_240
JMP  short _lib_239
_lib_240:
JMP  short _lib_234
_lib_239:
JMP  _lib_233
_lib_234:
_lib_241:
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
OR   EAX, EAX
JNE  short _lib_243
JMP  short _lib_242
_lib_243:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
PUSH EAX
LEA  EAX, [EBP+8]
MOV  EBX, EAX
MOV  EAX, [EBX]
DEC  EAX
MOV  [EBX], EAX
POP  EBX
ADD  EAX, EBX
MOV  EBX, EAX
MOV  EAX, 32
MOV  [EBX], AL
JMP  short _lib_241
_lib_242:
LEA  EAX, [EBP+12]
MOV  EBX, EAX
MOV  EAX, [EBX]
MOV  ESP, EBP
POP  EBP
RETN

__iob:
times 3*32 db 0x0
