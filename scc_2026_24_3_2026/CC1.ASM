; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 24/03/2026
; -----------------------------------------------------------
; Derived from 'cc1.asm' file of KolibriOS SCC source code
; 2024

_nogo:		TIMES 1 DD 0
_noloc: 	TIMES 1 DD 0
_opindex:	TIMES 1 DD 0
_opsize:	TIMES 1 DD 0
_swactive:	TIMES 1 DD 0
_swdefaul:	TIMES 1 DD 0
_swnext:	DD 0
_swend:		DD 0
_stage:		DD 0
_wq:		DD 0
_argcs:		TIMES 1 DD 0
_argvs:		DD 0
_wqptr:		DD 0
_litptr:	TIMES 1 DD 0
_macptr:	TIMES 1 DD 0
_pptr:		TIMES 1 DD 0
_ch:		TIMES 1 DD 0
_nch:		TIMES 1 DD 0
_declared:	TIMES 1 DD 0
_iflevel:	TIMES 1 DD 0
_skipleve:	TIMES 1 DD 0
_nxtlab:	TIMES 1 DD 0
_litlab:	TIMES 1 DD 0
_csp:		TIMES 1 DD 0
_argstk:	TIMES 1 DD 0
_argtop:	TIMES 1 DD 0
_ncmp:		TIMES 1 DD 0
_errflag:	TIMES 1 DD 0
_eof:		TIMES 1 DD 0
_output:	TIMES 1 DD 0
_files:		TIMES 1 DD 0
_filearg:	DD 0
_input:		DD -1
_input2:	DD -1
_usexpr:	DD 1
_ccode:		DD 1
_snext:		DD 0
_stail:		DD 0
_slast:		DD 0
_listfp:	TIMES 1 DD 0
_lastst:	TIMES 1 DD 0
_oldseg:	TIMES 1 DD 0

_optimize:	TIMES 1 DB 0
_alarm:		TIMES 1 DB 0
_monitor:	TIMES 1 DB 0
_pause:		TIMES 1 DB 0
_symtab:	DD 0
_litq:		DD 0
_macn:		DD 0
_macq:		DD 0
_pline:		DD 0
_mline:		DD 0
_line:		DD 0
_lptr:		DD 0
_glbptr:	DD 0
_locptr:	DD 0
_quote:		DB 34
		TIMES 1 DB 0
_cptr:		DD 0
_cptr2:		DD 0
_cptr3:		DD 0
_msname:	TIMES 9 DB 0
_ssname:	TIMES 9 DB 0

; p-codes of unsigned binary operators

_op:		DD 57,73,3,20,55,43,22,47,35,7
		DD 6,1,69,52,16,49
_op2:		DD 57,73,3,20,55,44,23,48,36,7
		DD 6,1,69,53,17,50

; TRDOS 386 modification
; 11/09/2024 (fputs -> puts)

_main:
	PUSH	EBP
	MOV	EBP,ESP

	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]

	; TRDOS 386 modification
	CMP	EAX,1
	JA	short _main_@
	MOV	EAX,TVERSION
	PUSH	EAX
	call	_puts
	POP	EAX
	JMP	_1_483 ; usage

_main_@:
	MOV	DWORD [_argcs],EAX	; argc; (value)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	DWORD [_argvs],EAX	; argv; (address)

	MOV	EAX,VERSION
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,CRIGHT1
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,CRIGHT2
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,360	; SWTABSZ (Note: It would be 90*8!) (*)
	PUSH	EAX	; 90*4 (90*SWSIZ) (*)
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_swnext],EAX
;
; 		; swend = swnext+(SWTABSZ-SWSIZ);
;;	MOV	EAX,[_swnext]
;;	MOV	EBX,1424
;;	ADD	EAX,EBX  ; 4*356
;	ADD	EAX,1424 ; This may be compiler expression defect!?
;	TRDOS 386 Modification - 23/09/2024
;	Note: SWSIZ was 2*BPW (16 bit label ptr + value ptr)
;	but, I think.. (*)
;	It must be 2*BPD = 8 (32 bit label ptr + value ptr)
;	Erdogan Tan - 23/09/2024
;	ADD	EAX,356	; SWTABSZ-SWSIZ
	ADD	EAX,352	; SWTABSZ-8
	MOV	DWORD [_swend],EAX
;
	MOV	EAX,200 ; STAGESIZE
	PUSH	EAX
	MOV	EAX,8	; 2*INTSIZE
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_stage],EAX
	MOV	EAX,30	; WQTABSZ
	PUSH	EAX
	MOV	EAX,4	; INTSIZE
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_wq],EAX
	MOV	DWORD [_wqptr],EAX
	MOV	EAX,3000 ; LITABSZ
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_litq],EAX
	MOV	EAX,3300 ; MACNSIZE = MACNBR*(NAMESIZE+2)
	PUSH	EAX	; MACNBR = 300 ; NAMESIZE = 9
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_macn],EAX
	MOV	EAX,2100 ; MACQSIZE = MACNBR*7
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_macq],EAX
	MOV	EAX,128	; LINESIZE
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_pline],EAX
	MOV	EAX,128	; LINESIZE
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_mline],EAX
	MOV	EAX,[_stage]
;
;		; slast = stage+(STAGESIZE*2*INTSIZE);
;;	MOV	EBX,6400
;;	ADD	EAX,EBX	; 1600*4 (STAGESIZE*2*INSIZE=1600)
;	ADD	EAX,6400 ; This may be compiler expression defect!?
;	TRDOS 386 Modification - 23/09/2024
;	Note:
;	The expression result is seen as also multiplied by INTSIZE,
;	the final result is 6400 (wrong!?)
;	It must be 1600 (STAGESIZE*2*INTSIZE=1600)
;	Erdogan Tan - 23/09/2024
	ADD	EAX,1600
;
	MOV	DWORD [_slast],EAX ; stage+(STAGESIZE*2*INTSIZE);
	MOV	EAX,4400 ; NUMLOCS*SYMAVG + NUMGLBS*SYMMAX
	PUSH	EAX	; 25*16 + 200*20
	MOV	EAX,1
	PUSH	EAX
	CALL	_OS_calloc
	ADD	ESP,8
	MOV	DWORD [_symtab],EAX
;	MOV	EAX,[_symtab] ; STARTLOC = symtab
	MOV	DWORD [_locptr],EAX ; STARTLOC
	MOV	EAX,[_symtab]
;	MOV	EBX,400
;	ADD	EAX,EBX	; ENDLOC = symtab+NUMLOCS*SYMAVG
	ADD	EAX,400	; STARTGLB = ENDLOC
	MOV	DWORD [_glbptr],EAX ; STARTGLB
	CALL	_ask
	CALL	_openfile
	CALL	_preprocess
	CALL	_header
	;CALL	_setcodes
	CALL	_parse
	CALL	_trailer
	MOV	EAX,[_output]
	PUSH	EAX
	CALL	_OS_fclose
	ADD	ESP,4
	POP	EBP
	RETN

VERSION: db "Small C 386/NT, Version 3.1, Revision Level 1",13,10,0
CRIGHT1: db "Copyright 1982-1998 J. E. Hendrix H T Walheim",13,10,0
CRIGHT2: db "TRDOS 386 Adaptation: Erdogan Tan - 2026",13,10,13,10,0

TVERSION:
	db "Small C Compiler v1.0 for TRDOS 386 v2",13,10
	db "Erdogan Tan - 2026",13,10

NEWLINE:
crlf:	db 13,10,0

_parse:
	PUSH	EBP
	MOV	EBP,ESP
_1_3:
	MOV	EAX,[_eof]
	OR	EAX,EAX
	;JNZ	short _1_4
	JZ	short _1_5
_1_4:
	POP	EBP
	RETN
_1_5:		; if (amatch("extern", 6))
	MOV	EAX,_EXTERN_ ; _1_2+0
	PUSH	EAX
	MOV	EAX,6
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_6
_1_7:
	MOV	EAX,3	; EXTERNAL
	PUSH	EAX
	CALL	_dodeclar ; dodeclare(EXTERNAL);
	ADD	ESP,4
	JMP	short _1_8
_1_6:		; else if(dodeclare(STATIC))
	MOV	EAX,2	; STATIC
	PUSH	EAX
	CALL	_dodeclar ; dodeclare(STATIC)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_11
_1_9:		; else if(match("#asm"))
	MOV	EAX,_ASM_ ; _1_2+7
	PUSH	EAX
	CALL	_match	; match("#asm")
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_12
_1_13:
	CALL	_doasm
	JMP	short _1_14
_1_12:		; else if(match("#include"))
	MOV	EAX,_INCLUD_ ; _1_2+12
	PUSH	EAX
	CALL	_match	; match("#include")
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_15
_1_16:
	CALL	_doinclud ; doinclude();
	JMP	short _1_17
_1_15:		; else if(match("#define"))
	MOV	EAX,_DEFINE_ ; _1_2+21
	PUSH	EAX
	CALL	_match	; match("#define")
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_18
_1_19:
	CALL	_dodefine ; dodefine();
	JMP	short _1_20
_1_18:		; else
	CALL	_dofuncti ; dofunction();
_1_20:
_1_17:
_1_14:
_1_11:
_1_8:
	CALL	_blanks	; blanks();
	JMP	_1_3

_1_2:
_EXTERN_:
	DB "extern",0
_ASM_:	DB "#asm",0
_INCLUD_:
	DB "#include",0
_DEFINE_:
	DB "#define",0

_dodeclar:	 ; dodeclare(class)
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,_CHAR_ ; _1_21+0
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch	; if (amatch("char",4))
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_22
_1_23:
	MOV	EAX,4	; CHR
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_declglb ; declglb(CHR,class);
	ADD	ESP,8
	JMP	_1_24
_1_22:		; else if(amatch("unsigned",8))
	MOV	EAX,_UNSGND_ ; _1_21+5
	PUSH	EAX
	MOV	EAX,8
	PUSH	EAX
	CALL	_amatch	; if(amatch("unsigned", 8))
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_25
_1_26:		; & if(amatch("char",4)
	MOV	EAX,_CHAR_ ; _1_21+14
	PUSH	EAX
	MOV	EAX,4	; CHR
	PUSH	EAX
	CALL	_amatch	; if(amatch("char",4))
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_27
_1_28:
	MOV	EAX,5	; UCHR
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_declglb ; declglb(UCHR,class);
	ADD	ESP,8
	;JMP	short _1_29
	JMP	short _1_30
_1_27:		; else {amatch("int",3);
	MOV	EAX,_INT_ ; _1_21+19
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch	; amatch("int",3)
	ADD	ESP,8
	MOV	EAX,17	; INT
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_declglb ; declglb(UINT, class);
	ADD	ESP,8
;_1_29:
	JMP	short _1_30
_1_25:		; else if(amatch("int",3)
	MOV	EAX,_INT_	; _1_21+23
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JNZ	short _1_36
_1_34:		; || class == EXTERNAL)
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,3	; EXTERNAL
	CALL	__eq
	OR	EAX,EAX
	JNZ	short _1_36
_1_31:		; else return 0;
	;XOR	EAX,EAX
	;eax = 0
	POP	EBP
	RETN
_1_36:		; declglb(INT,class);
	MOV	EAX,16
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_declglb
	ADD	ESP,8
_1_30:
_1_24:
	CALL	_ns	; ns();
	MOV	EAX,1	; return 1;
	POP	EBP
	RETN

_1_21:
_CHAR_: DB "char",0
_UNSGND_:
	DB "unsigned",0
_INT_:	DB "int",0

_declglb:	; declglb(type, class)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int id, dim;
_1_39:		; while(1);
	CALL	_endst	; if(endst())
	OR	EAX,EAX
	JZ	short _1_41
_1_42:
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_41:
	MOV	EAX,_STAR_ ; _1_38+0
	PUSH	EAX
	CALL	_match	; if(match("*"))
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_43
_1_44:
	LEA	EBX,[EBP-4]
	MOV	EAX,3	; POINTER
	MOV	[EBX],EAX   ; id = POINTER;
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	MOV	[EBX],EAX   ; dim = 0;
	JMP	short _1_45
_1_43:		; else
	LEA	EBX,[EBP-4]
	MOV	EAX,1	; VARIABLE
	MOV	[EBX],EAX   ; id = VARIABLE;
	LEA	EBX,[EBP-8]
	;MOV	EAX,1
	MOV	[EBX],EAX   ; dim = 1;
_1_45:
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_symname    ; if(symname(ssname) == 0)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_46
_1_47:
	CALL	_illname    ; illname();
_1_46:
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_findglb    ; if(findglb(ssname))
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_48
_1_49:
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_multidef   ; multidef(ssname);
	;ADD	ESP,4
	POP	EAX
_1_48:
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]   ; id
	MOV	EAX,1	; VARIABLE
	CALL	__eq	    ; if(id == VARIABLE)
	OR	EAX,EAX
	JZ	short _1_50
_1_51:
	MOV	EAX,_LPARN_ ; _1_38+2
	PUSH	EAX
	CALL	_match	; if (match("("))
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_52
_1_53:
	LEA	EBX,[EBP-4]
	MOV	EAX,4
	MOV	[EBX],EAX   ; id = FUNCTION;
	MOV	EAX,_RPARN_ ; _1_38+4
	PUSH	EAX
	CALL	_need	; need(")");
	;ADD	ESP,4
	POP	EAX
	JMP	short _1_54
_1_52:
	MOV	EAX,_LBRCK_ ;1_38+6
	PUSH	EAX
	CALL	_match	; else if(match("["))
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_55
_1_56:
	LEA	EBX,[EBP-4]
	MOV	EAX,2
	MOV	[EBX],EAX  ; id = ARRAY;
	LEA	EAX,[EBP-8]
	PUSH	EAX
	CALL	_needsub
	POP	EBX
	MOV	[EBX],EAX ; dim = needsub();
_1_55:
_1_54:
_1_50:		; if (class == EXTERNAL)
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX] ; class
	MOV	EAX,3	; EXTERNAL
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_57
_1_58:
	MOV	EAX,_ssname
	PUSH	EAX	; sname
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX] ; type
	MOV	ECX,2
	SAR	EAX,CL
	PUSH	EAX	; type >> 2
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX	; id
	CALL	_external ; external(ssname,type>>2,id);
	ADD	ESP,12
	JMP	short _1_59
_1_57:		; else if (id != FUNCTION)
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,4	; FUNCTION
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_60
_1_61:
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX] ; type
	MOV	ECX,2
	SAR	EAX,CL
	PUSH	EAX	; type >> 2
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX	; id
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX	; dim
	CALL	_initials ; initials(type >> 2, id, dim);
	ADD	 ESP,12
_1_60:
_1_59:		; if(id == POINTER)
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,3	; POINTER
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_62
_1_63:
	MOV	EAX,_ssname
	PUSH	EAX	; ssname
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX	; id
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX	; type
	MOV	EAX,4
	PUSH	EAX	; PTRSIZE
	XOR	EAX,EAX
	PUSH	EAX	; 0
	MOV	EAX,_glbptr
	PUSH	EAX	; &glbptr
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX	; class
	;addsym(ssname,id,type,PTRSIZE,0,&glbptr,class);
	CALL	_addsym
	ADD	ESP,28
	JMP	short _1_64
_1_62:		; else
	MOV	EAX,_ssname
	PUSH	EAX	; ssname
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX	; id
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX	; type
	LEA	ECX,[EBP-8]
	MOV	EBX,[ECX] ; dim
	;PUSH	EBX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	MOV	ECX,2
	SAR	EAX,CL
	;POP	EBX
	IMUL	EBX
	PUSH	EAX	; dim*(type>>2)
	XOR	EAX,EAX
	PUSH	EAX	; 0
	MOV	EAX,_glbptr
	PUSH	EAX	; &glbptr
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX	; class
	; addsym(ssname,id,type,dim*(type>>2),0,&glbptr,class);
	CALL	_addsym
	ADD	ESP,28
_1_64:
	MOV	EAX,_COMMA_ ; _1_38+8
	PUSH	EAX
	CALL	_match	; if(match(",") == 0)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_65 ; jump to while(1)
_1_66:		; return;
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_65:
	JMP	_1_39

_1_38:
_STAR_ : DB "*",0
_LPARN_: DB "(",0
_RPARN_: DB ")",0
_LBRCK_: DB "[",0
_COMMA_: DB ",",0

_initials:	; initials(size, ident, dim)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int savedim;
	XOR	EAX,EAX
	MOV	DWORD [_litptr],EAX ; litptr = 0;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX	; if(dim == 0) dim = -1;
	JNZ	short _1_68
_1_69:
	LEA	EBX,[EBP+8]
	MOV	EAX,-1
	MOV	[EBX],EAX ; dim = -1;
_1_68:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX ; savedim = dim;
	MOV	EAX,_EQUAL_ ; _1_67+0
	PUSH	EAX
	CALL	_match	; if(match("=")) {
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_70
_1_71:
	MOV	EAX,_LBRACE_ ; _1_67+2
	PUSH	EAX
	CALL	_match	; if(match("{")) {
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_72 ; else
_1_73:
_1_74:		; while(dim) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _1_75
_1_76:
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP+8]
	PUSH	EAX
	CALL	_init	; init(size, ident, &dim);
	ADD	ESP,12
	;MOV	EAX,_COMMA2 ; _1_67+4
	MOV	EAX,_COMMA_
	PUSH	EAX
	CALL	_match	; if(match(",") == 0) break;
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_74 ; jump to while(dim)
_1_75:		; break;
	MOV	EAX,_RBRACE_ ; _1_67+6
	PUSH	EAX
	CALL	_need	; need("}");
	ADD	ESP,4
	JMP	short _1_79
_1_72:		; else init(size, ident, &dim);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP+8]
	PUSH	EAX
	CALL	_init
	ADD	ESP,12
_1_79:
_1_70:		; if(savedim == -1 && dim == -1) {
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,-1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_80
_1_83:
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,-1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_80
_1_85:		; if(ident == ARRAY)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]	; ident
	MOV	EAX,2	; ARRAY
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_86
_1_87:
	MOV	EAX,err_nas ; _1_67+8
	PUSH	EAX
	CALL	_error	; error("need array size");
	;ADD	ESP,4
	POP	EAX
_1_86:
	XOR	EAX,EAX
	PUSH	EAX
	LEA	EBX,[EBP+16]
	MOV	EAX,4	; PTRSIZE
	MOV	[EBX],EAX ; size = PTRSIZE
	PUSH	EAX
	CALL	_stowlit ; stowlit(0, size = PTRSIZE);
	ADD	ESP,8
_1_80:
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_public	; public(ident);  ;;; FASM
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,[_litptr]
	OR	EAX,EAX	 ; if(litptr>0) dumplits(size);
	JNG	short _1_88 ; false
_1_89:		; true
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_dumplits ; dumplits(size);
	;ADD	ESP,4
	POP	EAX
	JMP	short _1_90
_1_88:		; else if(dim>0)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNG	short _1_91 ; false
_1_92:		; true
	; In FASM: "<variable>: TIMES <number> D<type> 0"
	MOV	EAX,58
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	CALL	_OS_fputc ; fputc(':',output);
	ADD	ESP,8
_1_91:
_1_90:
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_dumpzero ; dumpzero(size, dim);
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_67:
_EQUAL_:  DB "=",0 ; DB 61,0
_LBRACE_: DB "{",0 ; DB 123,0
;_COMMA2: DB ",",0 ; DB 44,0
_RBRACE_: DB "}",0 ; DB 125,0
err_nas:  DB "need array size",0

_init:		; init(size, ident, dim)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int value;
	LEA	EAX,[EBP-4]
	PUSH	EAX
	CALL	_string	; if(string(&value)) {
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_94
_1_95:		; if(ident == VARIABLE || size != 1)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__eq
	OR	EAX,EAX
	JNZ	short _1_101 ; ident == VARIABLE
_1_99:
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_96 ; size = 1
_1_101:		; ident == VARIABLE || size != 1
	; error("must assign to char pointer or char array");
	MOV	EAX,err_matcp ; _1_93+0
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_96:
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	PUSH	EBX	; DIM (address)
	MOV	EAX,[EBX]
	PUSH	EAX	; *DIM (value)
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]	; value
	MOV	EBX,[_litptr]
	SUB	EBX,EAX	; litptr - value
	POP	EAX	; *DIM (value)
	SUB	EAX,EBX	; 
	POP	EBX	; DIM (address)
	MOV	[EBX],EAX ; *dim -= (litptr - value);
	LEA	EAX,[EBP+12] ; if(ident == POINTER) point();
	MOV	EBX,[EAX]
	MOV	EAX,3	; POINTER
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_104
_1_103:		; ident == POINTER
	CALL	_point	; point();
_1_102:
	JMP	short _1_104
_1_94:		; else if(constexpr(&value)) {
	LEA	EAX,[EBP-4]
	PUSH	EAX
	CALL	_constexp
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_105 ; false
_1_106:		; if(ident == POINTER)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,3
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_107
_1_108:
	MOV	EAX,err_cnatp ; _1_93+42
	PUSH	EAX
	CALL	_error	; error("cannot assign to pointer");
	;ADD	ESP,4
	POP	EAX
_1_107:
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_stowlit ; stowlit(value, size);
	ADD	ESP,8
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	;;MOV	EBX,1
	;;SUB	EAX,EBX
	;SUB	EAX,1
	DEC	EAX
	MOV	[EBX],EAX ; *dim -= 1;
_1_105:
_1_104:
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_93:
err_matcp: DB "must assign to char pointer or char array",0
err_cnatp: DB "cannot assign to pointer",0

_needsub:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int val;
		; if(match("]")) return 0;
	MOV	EAX,_RBRCK_	; _1_109+0
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_110
_1_111:
	XOR	EAX,EAX	; 0
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_110:		; if(constexpr(&val) == 0)
	LEA	EAX,[EBP-4]
	PUSH	EAX
	CALL	_constexp
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_112
_1_113:
	LEA	EBX,[EBP-4] ; val = 1;
	MOV	EAX,1
	MOV	[EBX],EAX
_1_112:
	LEA	EBX,[EBP-4] ; if(val < 0) {
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNL	short _1_114
_1_115:
	MOV	EAX,errnsi ; _1_109+2
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	LEA	EBX,[EBP-4] ; val = -val;
	MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
_1_114:
	MOV	EAX,_RBRCK_ ; _1_109+24
	PUSH	EAX
	CALL	_need	; need("]");
	;ADD	ESP,4
	POP	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX] ; return val;
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_109:
_RBRCK_: DB "]",0 ; DB 93,0
errnsi:	 DB "negative size illegal",0

_doinclud:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-36	; int i; char str[30];
	CALL	_blanks	; blanks();
	; if(*lptr == '"' || *lptr == '<') ++lptr;
	MOV	EAX,[_lptr]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,34	; '"'
	CALL	__eq
	OR	EAX,EAX
	JNZ	short _1_122
_1_120:
	;MOV	EAX,[_lptr]
	;MOVSX	EBX,BYTE [EAX]
	MOV	EAX,60	; '<'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_117
_1_122:		; ++lptr;
	;MOV	EAX,[_lptr]
	;INC	EAX
	;MOV	DWORD [_lptr],EAX
	INC	DWORD [_lptr]
_1_117:		; i = 0;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX
_1_123:		; while(lptr[i] &&
	;MOV	EAX,[_lptr]
	;PUSH	EAX
	LEA	EBX,[EBP-4] ; i
	MOV	EAX,[EBX]
	;POP	EBX
	;ADD	EAX,EBX
	ADD	EAX,[_lptr]
	MOVSX	EBX,BYTE [EAX]
	OR	EBX,EBX
	JZ	short _1_124
_1_127:		; && lptr[i] != '"'
	;;MOV	EAX,[_lptr]
	;;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;;POP	EBX
	;;ADD	EAX,EBX
	;ADD	EAX,[_lptr]
	;MOVSX	EBX,BYTE [EAX]
	MOV	EAX,34	; '"'
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_124
_1_128:		; && lptr[i] != '>'
	;;MOV	EAX,[_lptr]
	;;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;;POP	EBX
	;;ADD	EAX,EBX
	;ADD	EAX,[_lptr]
	;MOVSX	EBX,BYTE [EAX]
	MOV	EAX,62	; '>'
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_124
_1_129:		; && lptr[i] != '\n') {
	;;MOV	EAX,[_lptr]
	;;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;;POP	EBX
	;;ADD	EAX,EBX
	;ADD	EAX,[_lptr]
	;MOVSX	EBX,BYTE [EAX]
	;;;
	;MOV	EAX,10	; LF ; '\n'
	MOV	EAX,13	; CR ; TRDOS 386 Modification
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_124
	MOV	EAX,10	; LF ; '\n'
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_124
	;;;
_1_131:		; str[i] = lptr[i];
	;LEA	EAX,[EBP-36]
	;PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	;POP	EBX
	LEA	EBX,[EBP-36]
	ADD	EAX,EBX	; str[i]
	PUSH	EAX
	;MOV	EAX,[_lptr]
	;PUSH	EAX
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	;POP	EAX
	;MOV	EAX,[_lptr]
	;ADD	EBX,EAX
	ADD	EBX,[_lptr] ; lptr[i]
	MOVSX	EAX,BYTE [EBX]
	POP	EBX
	MOV	[EBX],AL ; str[i] = lptr[i]
	LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX] ; ++i;
	JMP	short _1_123
_1_124:		; str[i] = NULL;
	LEA	EBX,[EBP-4] ; i
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-36] ; str[]
	PUSH	EBX
	ADD	EBX,EAX	; str[i]
	XOR	EAX,EAX
	MOV	[EBX],AL ; str[i] = NULL;
	; if((input2 = fopen(str,"r")) == NULL) {
	;LEA	EAX,[EBP-36]
	;PUSH	EAX
	MOV	EAX,iopr ; _1_116+0
	PUSH	EAX
	CALL	_OS_fopen
	ADD	ESP,8
	MOV	DWORD [_input2],EAX
	OR	EAX,EAX
	JNZ	short _1_132
_1_133:	; error("open failure on include file");
	;MOV	EAX,-1
	DEC	EAX
	;eax = -1
	MOV	DWORD [_input2],EAX
	MOV	EAX,iopfail ; _1_116+2
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
_1_132:
	CALL	_kill
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_116:
iopr:	 DB "r",0
iopfail: DB "open failure on include file",0

_dodefine:	; dodefine() {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
	MOV	EAX,_msname
	PUSH	EAX
	CALL	_symname ; if(symname(msname) == 0) {
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_135 ; false
_1_136:		; true
	CALL	_illname ; illname();
	;XOR	CL,CL
	;CALL	_kill	; kill();
	;MOV	ESP,EBP	; return;
	;POP	EBP
	;RETN
	JMP	short _1_132 ; TRDOS 386
_1_135:
	LEA	EBX,[EBP-4] ; k = 0;
	XOR	EAX,EAX
	MOV	[EBX],EAX
	; if(search(msname,macn,NAMESIZE+2,MACNEND,MACNBR,0) == 0) {
	MOV	EAX,_msname
	PUSH	EAX
	MOV	EBX,[_macn]
	PUSH	EBX
	MOV	EAX,11	; NAMESIZE+2
	PUSH	EAX
	;MOV	EBX,[_macn]
	;MOV	EAX,3300 ; MACNSIZE = MACNBR*(NAMESIZE+2))
	;ADD	EBX,EAX	; MACNEND = macn+MACNSIZE
	ADD	EBX,3300
	PUSH	EBX
	MOV	EAX,300	; MACNBR
	PUSH	EAX
	XOR	EAX,EAX	; 0
	PUSH	EAX
	CALL	_search
	ADD	ESP,24
	OR	EAX,EAX
	JNZ	short _1_137 ; false
_1_138:		; true
	MOV	EAX,[_cptr] ; if(cptr2 = cptr)
	MOV	DWORD [_cptr2],EAX
	OR	EAX,EAX
	JNZ	short _1_140 ; true
_1_139:		; false
	MOV	EAX,err_mntf ; _1_134+0
	PUSH	EAX
	CALL	_error	; error("macro name table full");
	;ADD	ESP,4
	POP	EAX
	MOV	ESP,EBP	; return;
	POP	EBP
	RETN
_1_140:
_1_141:		; while(*cptr2++ = msname[k++]) ;
	MOV	EAX,[_cptr2]
	;INC	EAX
	;MOV	DWORD [_cptr2],EAX
	;DEC	EAX
	INC	DWORD [_cptr2] ; *cptr2++
	PUSH	EAX
	;MOV	EAX,_msname
	;PUSH	EAX
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	;INC	EBX
	;MOV	EAX],EBX
	;DEC	EBX
	INC	DWORD [EAX] ; k++
	;POP	EAX
	;ADD	EBX,EAX
	ADD	EBX,_msname
	MOVSX	EAX,BYTE [EBX]
	POP	EBX	; *cptr2
	MOV	[EBX],AL ; *cptr2 = msname[k++]
	OR	EAX,EAX
	JNZ	short _1_141 ; true, jump to while(*cptr2++
_1_144:
_1_137:	; putint(macptr, cptr+NAMESIZE, 2 /*INTSIZE*/);
	MOV	EAX,[_macptr]
	PUSH	EAX
	MOV	EAX,[_cptr]
	;MOV	EBX,9	; NAMESIZE
	;ADD	EAX,EBX
	ADD	EAX,9
	PUSH	EAX
	MOV	EAX,2
	PUSH	EAX
	CALL	_putint
	ADD	ESP,12
_1_145:		; while(white()) gch();
	CALL	_white
	OR	EAX,EAX
	JZ	short _1_146
_1_147:
	CALL	_gch	; gch();
	JMP	short _1_145 ; jump to while(white())
_1_146:
_1_148:		; while(putmac(gch()));
	CALL	_gch	; gch()
	PUSH	EAX
	CALL	_putmac
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_148 ; jump to while(putmac(gch()));
_1_149:
	MOV	EBX,[_macptr] ; MACQSIZE = MACNBR*7 = 2100
	MOV	EAX,2099 ; MACMAX = MACQSIZE-1
	CALL	__ge	; if(macptr >= MACMAX) {
	OR	EAX,EAX
	JZ	short _1_151 ; false
_1_152:
	MOV	EAX,err_msqf ; _1_134+22
	PUSH	EAX
	CALL	_error	; error("macro string queue full");
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,7	; ERRCODE
	PUSH	EAX
	CALL	_OS_exit ; exit(ERRCODE);
	;ADD	ESP,4
	POP	EAX	; TRDOS 386 (cpu must not come here)
_1_151:
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_134:
err_mntf: DB "macro name table full",0
err_msqf: DB "macro string queue full",0

_putmac:		 ; putmac(c)
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EBX,[_macq]
	MOV	EDX,[_macptr]
	ADD	EDX,EBX
	LEA	EBX,[EBP+8]
	MOVSX	EAX,BYTE [EBX]	; c
	MOV	[EDX],AL	; macq[macptr] = c;
	MOV	EBX,[_macptr]	; if(macptr < MACMAX) ++macptr;
	MOV	EAX,2099	; MACMAX
	CALL	__lt
	OR	EAX,EAX
	JZ	short _1_154	; false
_1_155:
	;MOV	EAX,[_macptr]
	;INC	EAX
	;MOV	DWORD [_macptr],EAX
	INC	DWORD [_macptr]	; ++macptr
_1_154:
	LEA	EBX,[EBP+8]
	MOVSX	EAX,BYTE [EBX]	; return c;
	POP	EBP
	RETN

_dofuncti:		; dofunction()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4		; char *ptr;
	XOR	EAX,EAX		; 0
	MOV	DWORD [_litptr],EAX
	MOV	DWORD [_lastst],EAX
	MOV	DWORD [_noloc],EAX
	MOV	DWORD [_nogo],EAX
	CALL	_getlabel	; litlab = getlabel();
	MOV	DWORD [_litlab],EAX
	MOV	EAX,[_symtab]	; STARTLOC;
	MOV	DWORD [_locptr],EAX
	MOV	EAX,_void_ ; _1_156+0 ; if(match("void")) blanks();
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_157	; false
_1_158:
	CALL	_blanks		; blanks();
_1_157:
	MOVSX	EAX,BYTE [_monitor] ; if(monitor) lout(line, -1);
	OR	EAX,EAX
	JZ	short _1_159	; false
_1_160:
	MOV	EAX,[_line]
	PUSH	EAX
	MOV	EAX,-1  ; STDOUT/STDERR (TRTDOS 386)
	PUSH	EAX
	CALL	_lout		; lout(line, -1);
	ADD	ESP,8
_1_159:
	MOV	EAX,_ssname	; if(symname(ssname) == 0) {
	PUSH	EAX
	CALL	_symname	; symname(ssname)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_161	; false
_1_162:
	MOV	EAX,err_ifd ;_1_156+5
	PUSH	EAX
	CALL	_error	; error("illegal function or declaration");
	ADD	ESP,4
	XOR	EAX,EAX
	MOV	DWORD [_errflag],EAX ; errflag = 0;
	CALL	_kill		; kill();
	MOV	ESP,EBP		; return;
	POP	EBP
	RETN
_1_161:			; if(ptr = findglb(ssname)) {
	LEA	EAX,[EBP-4]
	PUSH	EAX		; ptr
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_findglb
	ADD	ESP,4
	POP	EBX
	MOV	[EBX],EAX	; ptr = findglb(ssname)
	OR	EAX,EAX
	JZ	short _1_163	; = 0, false
_1_164:
	LEA	EBX,[EBP-4]	; if(ptr[CLASS] == AUTOEXT)
	MOV	EAX,[EBX]
	;MOV	EBX,2		; CLASS
	;ADD	EAX,EBX
	ADD	EAX,2  
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,4		; AUTOEXT
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_165	; false
_1_166:
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]	; ptr
	;ADD	EBX,2		; CLASS
	MOV	EAX,2		; STATIC
	ADD	EBX, EAX
	MOV	[EBX],AL	; ptr[CLASS] = STATIC;
	JMP	short _1_168
_1_165:
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_multidef	; multidef(ssname);
	ADD	ESP,4
_1_167:
	JMP	short _1_168
_1_163:
	; addsym(ssname,FUNCTION,INT,0,0,&glbptr,STATIC);
	MOV	EAX,_ssname
	PUSH	EAX
	MOV	EAX,4		; FUNCTION
	PUSH	EAX
	;MOV	EAX,16		; INT (= INTSIZE*4)
	MOV	AL,16
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX		; 0
	;XOR	EAX,EAX
	PUSH	EAX		; 0
	MOV	EAX,_glbptr
	PUSH	EAX		; &glbptr
	MOV	EAX,2
	PUSH	EAX		; STATIC = 2
	CALL	_addsym
	ADD	ESP,28
_1_168:
	MOV	EAX,4		; FUNCTION
	PUSH	EAX
	CALL	_public		; public(FUNCTION);
	;ADD	ESP,4
	POP	EAX
	XOR	EAX,EAX
	MOV	DWORD [_argstk],EAX ; argstk = 0;
	;MOV	EAX,_LPAREN ; _1_156+37 
	MOV	EAX,_LPARN_	; if(match("(") == 0)
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_169	; false
_1_170:
	MOV	EAX,err_nop ; _1_156+39
	PUSH	EAX
	CALL	_error		; error("no open paren");
	;ADD	ESP,4
	POP	EAX
_1_169:
_1_171:			; while(match(")") == 0) {
	;MOV	EAX,_RPAREN ; _1_156+53
	MOV	EAX,_RPARN_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_173	; true
	JMP	_1_172		; false
_1_173:			; if(symname(ssname)) {
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_symname	; symname(ssname)
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_174	; false
_1_175:			; if(findloc(ssname))
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_findloc
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_176	; false
_1_177:
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_multidef	; multidef(ssname);
	ADD	ESP,4
	JMP	short _1_179	; jump to blanks(); row
_1_176:
	; addsym(ssname,0,0,0,argstk,&locptr,AUTOMATIC);
	MOV	EAX,_ssname
	PUSH	EAX		; ssname
	XOR	EAX,EAX
	PUSH	EAX		; 0
	;XOR	EAX,EAX
	PUSH	EAX		; 0
	;XOR	EAX,EAX
	PUSH	EAX		; 0
	MOV	EAX,[_argstk]
	PUSH	EAX		; argstk
	MOV	EAX,_locptr
	PUSH	EAX		; &locptr
	MOV	EAX,1
	PUSH	EAX		; AUTOMATIC
	CALL	_addsym
	ADD	ESP,28
	MOV	EAX,[_argstk]
	;MOV	EBX,4
	;ADD	EAX,EBX		; + INTSIZE
	ADD	EAX,4
	MOV	DWORD [_argstk],EAX ; argstk += INTSIZE;
_1_178:
	JMP	short _1_179	; jump to blanks(); row
_1_174:
	MOV	EAX,err_ian ; _1_156+55
	PUSH	EAX
	CALL	_error		; error("illegal argument name");
	ADD	ESP,4
	CALL	_skip		; skip();
_1_179:
	CALL	_blanks		; blanks();
	MOV	EAX,[_lptr]
	PUSH	EAX
	;MOV	EAX,_RPAREN ; _1_156+77
	MOV	EAX,_RPARN_
	PUSH	EAX
	CALL	_streq		; if(streq(lptr,")") == 0
	ADD	ESP,8
	;MOV	EBX,EAX
	;XOR	EAX,EAX
	XOR	EBX,EBX		; 0
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_180	; false
_1_183:
	;MOV	EAX,_COMMA ; _1_156+79
	MOV	EAX,_COMMA_
	PUSH	EAX
	CALL	_match		; && match(",") == 0)
	ADD	ESP,4
	;MOV	EBX,EAX
	;XOR	EAX,EAX
	XOR	EBX,EBX		; 0
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_180	; false
_1_185:
	MOV	EAX,err_nc ; _1_156+81
	PUSH	EAX
	CALL	_error		; error("no comma");
	ADD	ESP,4
_1_180:
	CALL	_endst		; if(endst())
	OR	EAX,EAX
	JNZ	short _1_172	; break;
_1_186:
	JMP	_1_171		; jump to while(match(")")
_1_172:
	XOR	EAX,EAX
	MOV	DWORD [_csp],EAX ; csp = 0;
	MOV	EAX,[_argstk]
	;MOV	EBX,4
	;ADD	EAX,EBX
	ADD	EAX,4		; INTSIZE 
	MOV	DWORD [_argtop],EAX ; argtop = argstk+INTSIZE;
_1_188:
	MOV	EAX,[_argstk]	; while(argstk) {
	OR	EAX,EAX
	JNZ	short _1_190	; true
	JMP	_1_189		; false
_1_190:			; if (amatch("char",4))
	;MOV	EAX,_CHAR ; _1_156+90
	MOV	EAX,_CHAR_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_191	; false/else
_1_192:			; {doargs(CHR); ns();}
	MOV	EAX,4		; CHR
	PUSH	EAX
	CALL	_doargs
	ADD	ESP,4
	CALL	_ns
	JMP	short _1_188	; jump to while(argstk)
_1_191:			; else if(amatch("int",3))
	;MOV	EAX,_INT ; _1_156+95
	MOV	EAX,_INT_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_194	; false/else
_1_195:			; {doargs(INT); ns();}
	MOV	EAX,16		; INT
	PUSH	EAX
	CALL	_doargs
	ADD	ESP,4
	CALL	_ns
	JMP	short _1_188	; jump to while(argstk)
_1_194:			; else if(amatch("unsigned", 8))
	;MOV	EAX,_UNSIGNED ; _1_156+99
	MOV	EAX,_UNSGND_
	PUSH	EAX
	MOV	EAX,8
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_197	; false/else
_1_198:			; if (amatch("char", 4))
	;MOV	EAX,_CHAR2 ; _1_156+108
	MOV	EAX,_CHAR_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JZ	short _1_199	; false/else
_1_200:			; {doargs(UCHR); ns();}
	MOV	EAX,5		; UCHR
	PUSH	EAX
	CALL	_doargs
	ADD	ESP,4
	CALL	_ns
	JMP	short _1_202	; jump to while(argstk)
_1_199:			; else {amatch("int", 3);
	;MOV	EAX,_INT2 ; _1_156+113
	MOV	EAX,_INT_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	MOV	EAX,17		; doargs(UINT); ns();}
	PUSH	EAX		; UINT = 17
	CALL	_doargs
	ADD	ESP,4
	CALL	_ns
_1_201:
	;JMP	short _1_202
_1_202:
_1_196:
_1_193:
	JMP	_1_188
_1_197:		; else {error("wrong number of arguments");
	MOV	EAX,err_wnoa ; _1_156+117
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
	;JMP	short _1_189
_1_189:			; break;}
	MOV	EAX,18		; ENTER
	PUSH	EAX
	XOR	EAX,EAX		; 0
	PUSH	EAX
	CALL	_gen		; gen(ENTER, 0);
	ADD	ESP,8
	CALL	_statemen	; statement();
	MOV	EBX,[_lastst] 	; if(lastst != STRETURN
	MOV	EAX,3		; STRETURN
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_203 	; false
_1_206:
	;MOV	EBX,[_lastst] 	; && lastst != STGOTO)
	;ebx = [_lastst]
	MOV	EAX,13		; STGOTO
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_203 	; false
_1_208:			; gen(RETURN, 0);
	MOV	EAX,67		; RETURN
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_1_203:
	MOV	EAX,[_litptr]  	; if(litptr) {
	OR	EAX,EAX
	JZ	short _1_209	; false
_1_210:
	MOV	EAX,1		; DATASEG
	PUSH	EAX
	CALL	_toseg		; toseg(DATASEG);
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,66		; REFm
	PUSH	EAX
	MOV	EAX,[_litlab]
	PUSH	EAX		; litlab
	CALL	_gen		; gen(REFm, litlab);
	ADD	ESP,8
	MOV	EAX,1
	PUSH	EAX
	CALL	_dumplits	; dumplits(1);
	ADD	ESP,4
_1_209:
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_156:
_void_:	  DB "void",0
err_ifd:  DB "illegal function or declaration",0
;_LPAREN: DB "(",0 ; DB 40,0
err_nop:  DB "no open paren",0
;_RPAREN: DB ")",0
err_ian:  DB "illegal argument name",0
;_RPAREN2: DB ")",0 ; DB 41,0'
;_COMMA:  DB ",",0 ; DB 44,0
err_nc:   DB "no comma",0
;_CHAR:   DB "char",0
;_INT:    DB "int",0
;_UNSIGNED: DB "unsigned",0
;_CHAR2:  DB "char",0
;_INT2:   DB "int",0
err_wnoa: DB "wrong number of arguments",0

_doargs:	; declare argument types
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-16	 ; int id, sz;
			 ; char c, *ptr;
_1_211:
	MOV	EAX,[_argstk]
	OR	EAX,EAX
	JE	short _1_212
_1_213:		; if(decl(type, POINTER, &id, &sz)) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	LEA	EAX,[EBP-4]
	PUSH	EAX
	LEA	EAX,[EBP-8]
	PUSH	EAX
	;MOV	CL,4
	CALL	_decl
	ADD	ESP,16
	OR	EAX,EAX
	JE	short _1_217
_1_214:		; if(ptr = findloc(ssname)) {
	MOV	EAX,_ssname
	PUSH	EAX
	;MOV	CL,1
	CALL	_findloc
	ADD	ESP,4
	LEA	EBX,[EBP-16]
	MOV	[EBX],EAX ; ptr
	OR	EAX,EAX
	JNE	short _1_216
_1_215:		; else error("not an argument");
	;MOV	EAX,_1_222+0
	mov	EAX,_not_argument
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_217:		; argstk = argstk - INTSIZE;
_1_218:		; /* cnt down */
	MOV	EAX,[_argstk]
	;MOV	EBX,4
	;SUB	EAX,EBX
	SUB	EAX,4
	MOV	DWORD [_argstk],EAX
	;XOR	CL,CL
	CALL	_endst
	OR	EAX,EAX	; if(endst()) return;
	JE	short _1_220
_1_212:
_1_219:
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_220:		; if(match(",") == 0) error("no comma");
	;MOV	EAX,_1_222+16
	MOV	EAX,_COMMA_
	PUSH	EAX
	;MOV	CL,1
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _1_211
_1_221:
	;MOV	EAX,_1_222+18
	MOV	EAX,_no_comma
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	JMP	_1_211	; while(1) {
_1_216:
	LEA	EDX,[EBP-16] ; *ptr
	MOV	EBX,[EDX]
	LEA	ECX,[EBP-4]
	MOV	EAX,[ECX]
	MOV	[EBX],AL  ; ptr[IDENT] = id;
	;LEA	EDX,[EBP-16]
	;MOV	EBX,[EDX]
	;ADD	EBX,1
	INC	EBX
	LEA	ECX,[EBP+8]
	MOV	EAX,[ECX]
	MOV	[EBX],AL ; ptr[TYPE]  = type;
	LEA	ECX,[EBP-8]
	MOV	EAX,[ECX]
	PUSH	EAX
	;LEA	EDX,[EBP-16]
	MOV	EAX,[EDX]
	MOV	ECX,3
	ADD	EAX,ECX	; ptr+SIZE
	PUSH	EAX
	;MOV	EAX,4	; INTSIZE
	;PUSH	EAX
	INC	ECX ; 4
	PUSH	ECX
	;MOV	CL,3
	CALL	_putint	; putint(sz, ptr+SIZE, INTSIZE);
	ADD	ESP,12
	; putint(argtop-getint(ptr+OFFSET, INTSIZE),
	;	 ptr+OFFSET, INTSIZE);
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	;ADD	EAX,5
	;ADD	EAX,2
	ADD	EAX,7	; ptr+OFFSET
	PUSH	EAX ; *
	PUSH	EAX
	MOV	EAX,4	; INTSIZE
	PUSH	EAX
	;MOV	CL,2
	CALL	_getint
	ADD	ESP,8
	POP	ECX ; *
	MOV	EBX,[_argtop]
	;XCHG	EAX,EBX
	;SUB	EAX,EBX
	;PUSH	EAX
	SUB	EBX,EAX	; argtop-getint
	PUSH	EBX
	;LEA	EBX,[EBP-16]
	;MOV	EAX,[EBX]
	;;ADD	EAX,5
	;;ADD	EAX,2
	;ADD	EAX,7	; ptr+OFFSET
	;PUSH	EAX
	PUSH	ECX ; *
	MOV	EAX,4	; INTSIZE
	PUSH	EAX
	;MOV	CL,3
	CALL	_putint
	ADD	ESP,12
	JMP	_1_217

_1_222:
_not_argument:
	   DB "not an argument",0
;_COMMA_:  DB ",", 0
_no_comma: DB "no comma", 0

_decl:	; /* parse next local or argument declaration */
	PUSH	EBP	; decl(type, aid, id, sz)
	MOV	EBP,ESP
	ADD	ESP,-12	; int n, p, mod;
	;MOV	EAX,_1_225+0
	MOV	EAX,_LP_
	PUSH	EAX
	CALL	_match	; if(match("("))
	ADD	ESP,4
	LEA	EBX,[EBP-8] ; p
	;OR	EAX,EAX
	;JE	short _1_226 ; EAX = 0
	; EAX = 1
_1_227:
	;;LEA	EBX,[EBP-8] ; p
	;MOV	EAX,1
	;;MOV	[EBX],EAX
	;JMP	short _1_228
_1_226:		; else p = 0;
	;;LEA	EBX,[EBP-8] ; p
	;;XOR	EAX,EAX ; 0
_1_228:
	MOV	[EBX],EAX
;_1_228: ; if(match("*")) {*id = POINTER;  *sz  = PTRSIZE;}
	;MOV	EAX,_1_225+2
	MOV	EAX,_STAR_
	PUSH	EAX
	CALL	_match	; match("*")
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_229
_1_230:
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,3
	MOV	[EBX],EAX
	LEA	ECX,[EBP+8]
	MOV	EBX,[ECX]
	;MOV	EAX,4
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _1_231
_1_229:		; else {*id = VARIABLE; *sz  = type >> 2;}
	LEA	EAX,[EBP+12] ; *id
	MOV	EBX,[EAX]
	MOV	EAX,1	; VARIABLE
	MOV	[EBX],EAX
	LEA	EBX,[EBP+8] ; *sz
	MOV	EDX,[EBX]
	LEA	EBX,[EBP+20] ; type
	MOV	EAX,[EBX]
	;MOV	ECX,2
	MOV	CL,2
	SAR	EAX,CL
	MOV	[EDX],EAX
_1_231:		; if((n = symname(ssname)) == 0) illname();
	;LEA	EAX,[EBP-4]
	;PUSH	EAX
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_symname
	ADD	ESP,4
	;POP	EBX
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _1_232
_1_233:
	CALL	_illname
_1_232:		; if(p && match(")")) ;  !!!!!
	LEA	EBX,[EBP-8] ; p
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _1_234
_1_237:
	;MOV	EAX,_1_225+4
	MOV	EAX,_RP_
	PUSH	EAX
	CALL	_match	; if(p && match(")")) ;  !!!!!
	ADD	ESP,4
	;OR	EAX,EAX
	;JZ	short _1_234
;_1_238:
	;MOV	EAX,1
	;JMP	short _1_236
;_1_236:
	;OR	EAX,EAX
	;JE	short _1_234
;_1_239:
;_1_235:
_1_234:
	;MOV	EAX,_1_225+6
	MOV	EAX,_LP_
	PUSH	EAX
	CALL	_match	; if(match("("))
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_240
_1_241:
	LEA	EBX,[EBP-8] ; p	
	MOV	EAX,[EBX]
	CALL	__lneg	; !p
	OR	EAX,EAX
	;JNZ	short _1_243
	JNZ	short _1_247
_1_245:		; if(!p || *id != POINTER)
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	MOV	EBX,[EAX] ; *id
	MOV	EAX,3	; POINTER
	CALL	__ne
	OR	EAX,EAX
	;;JNZ	short _1_243
	;JNZ	short _1_247
	JZ	short _1_242
;_1_246:
;	XOR	EAX,EAX
;	JMP	short _1_244
;_1_243:
;	MOV	EAX,1
;_1_244:
;	OR	EAX,EAX
;	JZ	short _1_242
_1_247:
	;MOV	EAX,_1_225+8
	MOV	EAX,_try_s ; error("try (*...)()");
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_242:		; need(")");
	;MOV	EAX,_1_225+21
	MOV	EAX,_need_RP_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
	POP	EAX
	JMP	short _1_248
_1_240:
	; else if(*id == VARIABLE && match("["))
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	MOV	EBX,[EAX] ; *id
	MOV	EAX,1	; VARIABLE
	CALL	__eq
	OR	EAX,EAX
	;JZ	short _1_250
	JZ	short _1_249
_1_252:
	;MOV	EAX,_1_225+23
	MOV	EAX,_LBRCK_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_249
;_1_253:
;	MOV	EAX,1
;	JMP	short _1_254
;_1_250:
;	XOR	EAX,EAX
;_1_251:
;	OR	EAX,EAX
;	JZ	short _1_249
_1_254:
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX] ; *id	
	LEA	EAX,[EBP+16] ; aid
	MOV	ECX,[EAX]
	MOV	[EBX],ECX ; *id = aid;
		; if((*sz *= needsub()) == 0)
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	PUSH	EBX
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_needsub
	POP	EBX
	IMUL	EBX
	POP	EBX
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _1_255
_1_256:		; if(aid == ARRAY) error("need array size");
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	MOV	EAX,2	; ARRAY = 2
	CALL	__eq
	OR	EAX,EAX
	JE	short _1_257
_1_258:
	;MOV	EAX,_1_225+25
	MOV	EAX,_need_as
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_257:
	LEA	EAX,[EBP+8] ; *sz
	MOV	EBX,[EAX]
		; /* size of pointer argument */
	;MOV	EAX,4
	;MOV	[EBX],EAX *sz  = PTRSIZE;
	mov	DWORD [EBX],4
_1_255:
_1_249:
_1_248:		; mod = *sz % ALIGN;
	LEA	EAX,[EBP+8] ; *sz
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	MOV	ECX,4	; ALIGN
	CDQ
	IDIV	ECX
	LEA	EBX,[EBP-12]
	MOV	[EBX],EDX ; %
	OR	EDX,EDX
	JZ	short _1_259
_1_260:		; if (mod) {
		; *sz = *sz + (ALIGN-mod);
	LEA	EAX,[EBP+8] ; sz
	MOV	EBX,[EAX]
	;PUSH	EBX	; *sz
	;LEA	EAX,[EBP-12] ; mod
	;MOV	EBX,[EAX]
	;MOV	ECX,4	; ALIGN
	; ECX = 4
	;SUB	ECX,EBX
	SUB	ECX,EDX	; ALIGN-mod
	;POP	EBX
	MOV	EAX,[EBX]
	ADD	EAX,ECX
	MOV	[EBX],EAX
_1_259:
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_225:
_need_LP_:
_LP_:	DP "(",0
;_STAR_:
;	DP "*",0
;_LP_:	DP "(",0
_try_s: DB "try (*...)()",0
_need_RP_:
_RP_:	DB ")",0
;_LBRCK_:
;	DB "[",0
_need_as:
	DB "need array size",0

_statemen:	; statement() {
	; /* statement parser */
	PUSH	EBP
	MOV	EBP,ESP
		; if(ch == 0 && eof) return;
	MOV	EBX,[_ch]
	XOR	EAX,EAX ; 0
	CALL	__eq
	OR	EAX,EAX
	;JZ	short _1_263
	JZ	short _1_262
_1_265:
	MOV	EAX,[_eof]
	OR	EAX,EAX
	;JZ	short _1_263
	JZ	short _1_262
;_1_266:
;	MOV	EAX,1
;	JMP	short _1_264
;_1_263:
;	XOR	EAX,EAX
;_1_264:
;	OR	EAX,EAX
;	JE	short _1_262
_1_267:
	POP	EBP
	RETN

_1_262:
	; else if(amatch("char",4)) {declloc(CHR); ns();}
	;MOV	EAX,_1_261+0
	MOV	EAX,_CHAR_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_269
_1_270:
	MOV	EAX,4	; CHR (1 << 2)
	;PUSH	EAX
	;CALL	_declloc
	;ADD	ESP,4
	;CALL	_ns
	;JMP	short _1_271
	JMP	short _1_268
_1_269:
	; else if(amatch("int",3)) {declloc(INT); ns();}
	;MOV	EAX,_1_261+5
	MOV	EAX,_INT_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_272
_1_273:
	MOV	EAX,16	; INT (INTSIZE << 2)
	;PUSH	EAX
	;CALL	_declloc
	;ADD	ESP,4
	;CALL	_ns
	;JMP	short _1_274
	JMP	short _1_268
_1_272:
	; else if(amatch("unsigned",8)) {
	;MOV	EAX,_1_261+9
	MOV	EAX,_UNSGND_
	PUSH	EAX
	MOV	EAX,8
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_275
_1_276:	; if (amatch("char",4)) {declloc(UCHR); ns();}
	;MOV	EAX,_1_261+18
	MOV	EAX,_CHAR_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_277
_1_278:
	MOV	EAX,5 ; UCHR (( 1 << 2) + 1)
_1_268:
	PUSH	EAX
	CALL	_declloc
	ADD	ESP,4
	CALL	_ns
	;JMP	short _1_279
	JMP	_1_280
_1_277:
	; else {amatch("int",3); declloc(UINT); ns();}
	;MOV	EAX,_1_261+23
	MOV	EAX,_INT_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	MOV	EAX,17
	;PUSH	EAX
	;CALL	_declloc
	;ADD	ESP,4
	;CALL	_ns
	JMP	short _1_268
;_1_279:
	;JMP	_1_280

_1_275:	; else {
		; if(declared >= 0) {
	MOV	EAX,[_declared]
	OR	EAX,EAX
	;JGE	short _1_282
	;JMP	short _1_281
	JNGE	short _1_281
_1_282:
	; if(ncmp > 1) nogo = declared; /* disable goto */
	MOV	EAX,[_ncmp]
	MOV	EBX,EAX
	MOV	EAX,1
	CALL	__gt
	OR	EAX,EAX
	JE	short _1_283
_1_284:
	MOV	EAX,[_declared]
	MOV	DWORD [_nogo],EAX
_1_283:		; gen(ADDSP, csp - declared);
	MOV	EAX,2 ; ADDSP
	PUSH	EAX
	MOV	EAX,[_csp]
	;MOV	EBX,[_declared]
	;SUB	EAX,EBX
	SUB	EAX,[_declared]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	MOV	EAX,-1
	MOV	DWORD [_declared],EAX ; declared = -1;
_1_281:
	; if(match("{")) compound();
	;MOV	EAX,_1_261+27
	MOV	EAX,_LBRACE_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_285
_1_286:
	CALL	_compound
	JMP	_1_287
_1_285:
	; else if(amatch("if",2)) {doif(); lastst = STIF;}
	;MOV	EAX,_1_261+29
	MOV	EAX,_if_
	PUSH	EAX
	MOV	EAX,2
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_288
_1_289:
	CALL	_doif
	;MOV	EAX,1
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],1
	JMP	_1_290
_1_288:
	; else if(amatch("while",5)) {dowhile(); lastst = STWHILE;}
	;MOV	EAX,_1_261+32
	MOV	EAX,_while_ 
	PUSH	EAX
	MOV	EAX,5
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_291
_1_292:
	CALL	_dowhile
	;MOV	EAX,2
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],2
	JMP	_1_293
_1_291:
	; else if(amatch("do",2)) {dodo(); lastst = STDO;}
	;MOV	EAX,_1_261+38
	MOV	EAX,_do_
	PUSH	EAX
	MOV	EAX,2
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_294
_1_295:
	CALL	_dodo
	;MOV	EAX,8
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],8
	JMP	_1_296
_1_294:
	; else if(amatch("for",3)) {dofor(); lastst = STFOR;}
	;MOV	EAX,_1_261+41
	MOV	EAX,_for_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_297
_1_298:
	CALL	_dofor
	;MOV	EAX,9
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],9
	JMP	_1_299
_1_297:
	; else if(amatch("switch",6)) {doswitch(); lastst = STSWITCH;}
	;MOV	EAX,_1_261+45
	MOV	EAX,_switch_
	PUSH	EAX
	MOV	EAX,6
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_300
_1_301:
	CALL	_doswitch
	;MOV	EAX,10
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],10
	JMP	_1_302
_1_300:
	; else if(amatch("case",4)) {docase(); lastst = STCASE;}
	;MOV	EAX,_1_261+52
	MOV	EAX,_case_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_303
_1_304:
	CALL	_docase
	;MOV	EAX,11
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],11
	JMP	_1_305
_1_303:
	; else if(amatch("default",7)) {dodefault(); lastst = STDEF;}
	;MOV	EAX,_1_261+57
	MOV	EAX,_default_
	PUSH	EAX
	MOV	EAX,7
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_306
_1_307:
	CALL	_dodefaul
	;MOV	EAX,12
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],12
	JMP	_1_308
_1_306:
	; else if(amatch("goto",4)) {dogoto(); lastst = STGOTO;}
	;MOV	EAX,_1_261+65
	MOV	EAX,_goto_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_309
_1_310:
	CALL	_dogoto
	;MOV	EAX,13
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],13
	JMP	_1_311
_1_309:
	; else if(dolabel()) lastst = STLABEL;
	CALL	_dolabel
	OR	EAX,EAX
	JE	short _1_312
_1_313:
	;MOV	EAX,14
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],14
	JMP	_1_314
_1_312:
	; else if(amatch("return",6)) {doreturn(); ns();
	;	 lastst = STRETURN;}
	;MOV	EAX,_1_261+70
	MOV	EAX,_return_
	PUSH	EAX
	MOV	EAX,6
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_315
_1_316:
	CALL	_doreturn
	CALL	_ns
	;MOV	EAX,3
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],3 ; STRETURN
	JMP	_1_317
_1_315:
	; else if(amatch("break",5)) {dobreak(); ns();
	;	 lastst = STBREAK;}
	;MOV	EAX,_1_261+77
	MOV	EAX,_break_
	PUSH	EAX
	MOV	EAX,5
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_318
_1_319:
	CALL	_dobreak
	CALL	_ns
	;MOV	EAX,4
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],4
	JMP	_1_320
_1_318:
	; else if(amatch("continue",8)) {docont(); ns();
	;	 lastst = STCONT;}
	;MOV	EAX,_1_261+83
	MOV	EAX,_continue_
	PUSH	EAX
	MOV	EAX,8
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _1_321
_1_322:
	CALL	_docont
	CALL	_ns
	;MOV	EAX,5
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],5
	JMP	short _1_323
_1_321:
	; else if(match(";")) errflag = 0;
	;MOV	EAX,_1_261+92
	MOV	EAX,_SC_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_324
_1_325:
	XOR	EAX,EAX
	MOV	DWORD [_errflag],EAX ; 0
	JMP	short _1_326
_1_324:
	; else if(match("#asm")) {doasm(); lastst = STASM;}
	;MOV	EAX,_1_261+94
	MOV	EAX,_asm_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_327
_1_328:
	CALL	_doasm
	;MOV	EAX,6
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],6
	JMP	short _1_329
_1_327:
	; else {doexpr(NO); ns(); lastst = STEXPR;}
	XOR	EAX,EAX ; NO = 0
	PUSH	EAX
	CALL	_doexpr
	ADD	ESP,4
	CALL	_ns
	;MOV	EAX,7	; STEXPR
	;MOV	DWORD [_lastst],EAX
	MOV	DWORD [_lastst],7
_1_329:
_1_326:
_1_323:
_1_320:
_1_317:
_1_314:
_1_311:
_1_308:
_1_305:
_1_302:
_1_299:
_1_296:
_1_293:
_1_290:
_1_287:
_1_280:
_1_274:
_1_271:
;_1_268:	; return lastst;
	MOV	EAX,[_lastst]
	POP	EBP
	RETN	; }

_1_261:
;_CHAR_:DB "char",0
;_INT_:	DB "int",0
;_UNSGND_:
;	DB "unsigned",0
;_LBRACE_:
;	DB "{",0
_if_:	DB "if",0
_while_:
	DB "while",0
_do_:	DB "do",0
_for_:	DB "for",0
_switch_:
	db "switch",0
_case_:	db "case",0
_default_:
	db "default",0
_goto_:	db "goto",0
_return_:
	db "return",0
_break_:
	db "break",0
_continue_:
	db "continue",0
_need_SC_:
_SC_:	db ";",0
_asm_:	db "#asm",0

_declloc:	; /* declare local variables */
	PUSH	EBP	; declloc(type) int type; {
	MOV	EBP,ESP
	ADD	ESP,-8	; int id, sz;
	; if(swactive) error("not allowed in switch");
	MOV	EAX,[_swactive]
	OR	EAX,EAX
	JE	short _1_331
_1_332:
	;MOV	EAX,_1_330+0
	MOV	EAX,_not_allow_s
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_331:
	; if(noloc) error("not allowed with goto");
	MOV	EAX,[_noloc]
	OR	EAX,EAX
	JE	short _1_333
_1_334:
	;MOV	EAX,_1_330+22
	MOV	EAX,_not_allow_g
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_333:
	; if(declared < 0) error("must declare first in block");
	MOV	EAX,[_declared]
	OR	EAX,EAX
	;JL	short _1_336
	;JMP	short _1_335
	JNL	short _1_335
_1_336:
	;MOV	EAX,_1_330+44
	MOV	EAX,_must_decl_f
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
_1_335:	; while(1) {
_1_337:		; if(endst()) return;
	CALL	_endst
	OR	EAX,EAX
	JE	short _1_339
_1_340:
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_339:		; decl(type, ARRAY, &id, &sz);
	LEA	EBX,[EBP+8] ; type
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,2 ; ARRAY
	PUSH	EAX
	LEA	EAX,[EBP-4] ; &id
	PUSH	EAX
	LEA	EAX,[EBP-8] ; &sz
	PUSH	EAX
	CALL	_decl
	ADD	ESP,16
		; declared += sz;
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	;MOV	EBX,[_declared]
	;ADD	EAX,EBX
	ADD	EAX,[_declared] 
	MOV	DWORD [_declared],EAX
	; addsym(ssname, id, type,  sz, csp - declared,
	;	 &locptr, AUTOMATIC);
	MOV	EAX,_ssname
	PUSH	EAX
	LEA	EBX,[EBP-4] ; id
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8] ; type
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-8] ; sz
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,[_csp]
	MOV	EBX,[_declared]
	SUB	EAX,EBX
	PUSH	EAX
	MOV	EAX,_locptr ; &locptr
	PUSH	EAX
	MOV	EAX,1	; AUTOMATIC
	PUSH	EAX
	;MOV	CL,7
	CALL	_addsym
	ADD	ESP,28
		; if(match(",") == 0) return;
	;MOV	EAX,_1_330+72
	MOV	EAX,_COMMA_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_342
	;JMP	short _1_341
	JMP	_1_337
_1_342:
_1_338:
	MOV	ESP,EBP
	POP	EBP
	RETN
;_1_341:
	;JMP	_1_337
;_1_338:
	;MOV	ESP,EBP
	;POP	EBP
	;RETN

_1_330:
_not_allow_s:
	DB "not allowed in switch",0
_not_allow_g:
	DB "not allowed with goto",0
_must_decl_f:
	DB "must declare first in block",0
;_COMMA_:
;	DB ",",0 ; DB 44,0

_compound:	; compound()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int savcsp; char *savloc;
	LEA	EBX,[EBP-4]
	MOV	EAX,[_csp]
	MOV	[EBX],EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[_locptr]
	MOV	[EBX],EAX ; savloc = locptr;
	XOR	EAX,EAX
	MOV	DWORD [_declared],EAX ; declared = 0
	;MOV	EAX,[_ncmp]
	;INC	EAX
	;MOV	DWORD [_ncmp],EAX
	INC	DWORD [_ncmp] ; ++ncmp;
_1_344:		; while (match("}") == 0)
	;MOV	EAX,_1_343+0
	MOV	EAX,_RCB_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _1_345
_1_346:
	MOV	EAX,[_eof] ; if(eof) {
	OR	EAX,EAX
	JE	short _1_347
_1_348:		; error("no final }");
	;MOV	EAX,_1_343+2
	MOV	EAX,_no_fRCB_
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
	JMP	short _1_345 ; break;
	;JMP	short _1_349
_1_347:
	CALL	_statemen  ; else statement();
;_1_349:
	JMP	short _1_344
_1_345:
	; if(--ncmp && lastst != STRETURN && lastst != STGOTO)
	MOV	EAX,[_ncmp]
	DEC	EAX
	MOV	DWORD [_ncmp],EAX
	OR	EAX,EAX
	;JE	short _1_351
	JZ	short _1_350
_1_353:
	MOV	EAX,[_lastst]
	MOV	EBX,EAX
	MOV	EAX,3	 ; STRETURN
	CALL	__ne
	OR	EAX,EAX
	;JE	short _1_351
	JZ	short _1_350
_1_354:
	MOV	EAX,[_lastst]
	MOV	EBX,EAX
	MOV	EAX,13	; STGOTO
	CALL	__ne
	OR	EAX,EAX
	;JE	short _1_351
	JZ	short _1_350
_1_355:
	;MOV	EAX,1
	;;JMP	short _1_352
	;JMP	short _1_356
;_1_351:
	;XOR	EAX,EAX
;_1_352:
	;OR	EAX,EAX
	;JNE	short _1_356
	;JMP	short _1_350
_1_356:
	MOV	EAX,2
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(ADDSP, savcsp)
	ADD	ESP,8
_1_350:
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	MOV	DWORD [_cptr],EAX ; cptr = savloc;
_1_357:
	MOV	EBX,[_cptr] ; while(cptr < locptr) {
	MOV	EAX,[_locptr]
	CALL	__ult
	OR	EAX,EAX
	JE	short _1_358
_1_359:
	MOV	EAX,[_cptr]
	PUSH	EAX
	CALL	_nextsym
	ADD	ESP,4
		; cptr2 = nextsym(cptr);
	MOV	DWORD [_cptr2],EAX
	MOV	EBX,[_cptr]	; if(cptr[IDENT] == LABEL) {
	;MOVSX	EAX,BYTE [EBX]
	;OR	EAX,EAX	; LABEL = 0
	;JNE	short _1_360
	CMP	BYTE [EBX],0
	JNZ	short _1_360 ; else cptr = cptr2;
_1_361:
	; while(cptr < cptr2) *savloc++ = *cptr++;
_1_362:
	MOV	EBX,[_cptr]
	MOV	EAX,[_cptr2]
	CALL	__ult
	OR	EAX,EAX
	;JNE	short _1_364
	;JMP	short _1_363
	JE	short _1_357
_1_364:
	LEA	EBX,[EBP-8] ; savloc
	MOV	ECX,[EBX]
	INC	DWORD [EBX]
	MOV	EBX,[_cptr]
	;INC	EBX
	;MOV	DWORD [_cptr],EBX
	;DEC	EBX
	INC	DWORD [_cptr]
	MOVSX	EAX,BYTE [EBX]
	MOV	[ECX],AL
	JMP	short _1_362 ; }
;_1_363:
	;JMP	short _1_365
_1_360:
	MOV	EAX,[_cptr2]
	MOV	DWORD [_cptr],EAX
_1_365:
	JMP	short _1_357 ; }
_1_358:
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	MOV	DWORD [_locptr],EAX ; locptr = savloc;
	MOV	EAX,-1
	MOV	DWORD [_declared],EAX ; declared = -1;
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_343:
_RCB_:	DB "}",0
_no_fRCB_:
	DB "no final }",0

_doif:		; doif()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int flab1, flab2;
	LEA	EAX,[EBP-4] ; flab1
	PUSH	EAX
	CALL	_getlabel
	POP	EBX
	MOV	[EBX],EAX
	PUSH	EAX
	MOV	EAX,1	; YES
	PUSH	EAX
	CALL	_test	; test(flab1 = getlabel(), YES);
	ADD	ESP,8
	CALL	_statemen ; statement();
	;MOV	EAX,_1_366+0
	MOV	EAX,_else_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch	; if(amatch("else", 4) == 0) {
	ADD	ESP,8
	OR	EAX,EAX
	JNE	short _1_367
_1_368:
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
		; /* simple "if"...print false label */
	CALL	_gen	; gen(LABm, flab1);
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_367:
	LEA	EAX,[EBP-8] ; flab2
	PUSH	EAX
	CALL	_getlabel ; flab2 = getlabel();
	POP	EBX
	MOV	[EBX],EAX
	; if(lastst != STRETURN && lastst != STGOTO)
	MOV	EBX,[_lastst]
	MOV	EAX,3 ; STRETURN
	CALL	__ne
	OR	EAX,EAX
	;JE	short _1_370
	JZ	short _1_369
_1_372:		; &&
	MOV	EBX,[_lastst]
	MOV	EAX,13 ; STGOTO
	CALL	__ne
	OR	EAX,EAX
	;JE	short _1_370
	JZ	short _1_369
_1_373:
	;MOV	EAX,1
	;JMP	short _1_371
;_1_370:
	;XOR	EAX,EAX
;_1_371:
	;OR	EAX,EAX
	;JE	short _1_369
_1_374:
	MOV	EAX,40	; JMPm
	PUSH	EAX
	LEA	EBX,[EBP-8] ; flab2
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(JMPm, flab2);
	ADD	ESP,8
_1_369:
	MOV	EAX,41	; LABm
	PUSH	EAX
	LEA	EBX,[EBP-4] ; flab1
	MOV	EAX,[EBX]
	PUSH	EAX
		; /* print false label */
	CALL	_gen	; gen(LABm, flab1);
	ADD	ESP,8
		; /* and do "else" clause */
	CALL	_statemen ; statement();
	MOV	EAX,41	; LABm
	PUSH	EAX
	LEA	EBX,[EBP-8] ; flab2
	MOV	EAX,[EBX]
	PUSH	EAX
		; /* print true label */
	CALL	_gen	; gen(LABm, flab2);
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_366:
_else_: DB "else",0

_dowhile:	; dowhile()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-16	; int wq[4];
	LEA	EAX,[EBP-16]
	PUSH	EAX
	;MOV	CL,1
	CALL	_addwhile ; addwhile(wq);
	ADD	ESP,4
	MOV	EAX,41	; LABm
	PUSH	EAX
	;LEA	EAX,[EBP-16]
	;MOV	EBX,4
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,4	; WQLOOP = 1
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(LABm, wq[WQLOOP]);
	ADD	ESP,8
	;LEA	EAX,[EBP-16]
	;MOV	EBX,8
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,1	; YES = 1
	PUSH	EAX
	;MOV	CL,2
	CALL	_test	; test(wq[WQEXIT], YES);
	ADD	ESP,8
	;XOR	CL,CL
	CALL	_statemen ; statement();
	MOV	EAX,40	; JMPm
	PUSH	EAX
	;LEA	EAX,[EBP-16]
	;MOV	EBX,4
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,4	; WQLOOP = 1
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(JMPm, wq[WQLOOP]);
	ADD	ESP,8
	MOV	EAX,41
	PUSH	EAX
	;LEA	EAX,[EBP-16]
	;MOV	EBX,8
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(LABm, wq[WQEXIT]);
	ADD	ESP,8
	;XOR	CL,CL
	CALL	_delwhile ; delwhile();
	MOV	ESP,EBP
	POP	EBP
	RETN

_dodo:		; dodo() {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-16	; int wq[4];
	LEA	EAX,[EBP-16]
	PUSH	EAX
	;MOV	CL,1
	CALL	_addwhile ; addwhile(wq);
	ADD	ESP,4
	MOV	EAX,41
	PUSH	EAX
	;LEA	EAX,[EBP-16]
	;MOV	EBX,4
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,4	; WQLOOP = 1
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(LABm, wq[WQLOOP]);
	ADD	ESP,8
	;XOR	CL,CL
	CALL	_statemen ; statement();
	;MOV	EAX,_1_376+0
	mov	eax,_while_
	PUSH	EAX
	;MOV	CL,1
	CALL	_need	; need("while");
	ADD	ESP,4
	;LEA	EAX,[EBP-16]
	;MOV	EBX,8
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,1	; YES
	PUSH	EAX
	;MOV	CL,2
	CALL	_test	; test(wq[WQEXIT], YES);
	ADD	ESP,8
	MOV	EAX,40	; JMPm
	PUSH	EAX
	;LEA	EAX,[EBP-16]
	;MOV	EBX,4
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,4	; WQLOOP = 1
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(JMPm, wq[WQLOOP]);
	ADD	ESP,8
	MOV	EAX,41	; LABm
	PUSH	EAX
	;LEA	EAX,[EBP-16]
	;MOV	EBX,8
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(LABm, wq[WQEXIT]);
	ADD	ESP,8
	;XOR	CL,CL
	CALL	_delwhile ; delwhile();
	;XOR	CL,CL
	CALL	_ns	; ns();
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_376:
;_while_: DB "while",0
_dofor:		; dofor() {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-24 ; int wq[4], lab1, lab2;
	LEA	EAX,[EBP-16]
	PUSH	EAX
	CALL	_addwhile ; addwhile(wq);
	;ADD	ESP,4
	POP 	EAX
	LEA	EAX,[EBP-20]
	PUSH	EAX
	CALL	_getlabel
	POP	EBX
	MOV	[EBX],EAX ; lab1 = getlabel();
	LEA	EAX,[EBP-24]
	PUSH	EAX
	CALL	_getlabel
	POP	EBX
	MOV	[EBX],EAX ; lab2 = getlabel();
	;MOV	EAX,_1_377+0
	MOV 	EAX,_need_LP_
	PUSH	EAX
	CALL	_need	; need("(");
	ADD	ESP,4
		; if(match(";") == 0) {
	;MOV	EAX,_1_377+2
	MOV	EAX,_SC_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _1_378
_1_379:
	XOR	EAX,EAX	; NO
	PUSH	EAX
	CALL	_doexpr	; doexpr(NO);
			; /* expr 1 */
	ADD	ESP,4
	CALL	_ns	; ns();
_1_378:
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(LABm, lab1);
	ADD	ESP,8
		; if(match(";") == 0) {
	;MOV	EAX,_1_377+4
	MOV	EAX,_SC_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _1_380
_1_381:
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2 (2*4)
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX ; 0 ; NO
	PUSH	EAX
	CALL	_test	; test(wq[WQEXIT], NO);
			; /* expr 2 */
	ADD	ESP,8
	CALL	_ns	;  ns();
_1_380:
	MOV	EAX,40
	PUSH	EAX
	LEA	EBX,[EBP-24]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(JMPm, lab2);
	ADD	ESP,8
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,4	; WQLOOP = 1 (1*4)
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(LABm, wq[WQLOOP]);
	ADD	ESP,8
		; if(match(")") == 0) {
	;MOV	EAX,_1_377+6
	MOV	EAX,_RP_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _1_382
_1_383:
	XOR	EAX,EAX	; NO = 0 (YES = 1)
	PUSH	EAX
	CALL	_doexpr	; doexpr(NO);
			; /* expr 3 */
	ADD	ESP,4
	;MOV	EAX,_1_377+8
	MOV	EAX,_need_RP_
	PUSH	EAX
	CALL	_need	; need(")");
	ADD	ESP,4	; }
_1_382:
	MOV	EAX,40
	PUSH	EAX
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(JMPm, lab2);
	ADD	ESP,8
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-24]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(LABm, lab2);
	ADD	ESP,8
	CALL	_statemen ; statement();
	MOV	EAX,40
	PUSH	EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,4
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(JMPm, wq[WQLOOP]);
	ADD	ESP,8
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(LABm, wq[WQEXIT]);
	ADD	ESP,8
	CALL	_delwhile ; delwhile();
	MOV	ESP,EBP
	POP	EBP
	RETN

;_1_377:
;_need_LP_:
;_LP_:	DB "(",0
;_need_RP_:
;_RP_:	DB ")",0
;_need_SC_:
;_SC_:	DB ";",0

_doswitch:	; doswitch() {
	PUSH	EBP
	MOV	EBP,ESP
	; int wq[4], endlab, swact, swdef, *swnex, *swptr;
	ADD	ESP,-36
	LEA	EBX,[EBP-24]
	MOV	EAX,[_swactive]
	MOV	[EBX],EAX	; swact = swactive;
	LEA	EBX,[EBP-28]
	MOV	EAX,[_swdefaul]
	MOV	[EBX],EAX	; swdef = swdefault;
	LEA	EDX,[EBP-32]	; (swnex)
	LEA	EBX,[EBP-36]	; (swptr)
	MOV	EAX,[_swnext]
	MOV	[EBX],EAX
	MOV	[EDX],EAX	; swnex = swptr = swnext;
	LEA	EAX,[EBP-16]
	PUSH	EAX
	CALL	_addwhile	; addwhile(wq);
	;ADD	ESP,4		; WQLOOP = 1 (1*4)
	POP	EAX
	;MOV	EAX,[_wqptr]
	;MOV	EBX,4
	;ADD	EBX,EAX
	;MOV	EAX,12		; WQSIZ = 3 (3*4)
	;SUB	EBX,EAX
	MOV	EBX,[_wqptr]
	SUB	EBX,8
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX	; *(wqptr + WQLOOP - WQSIZ) = 0;
	;MOV	EAX,_1_384+0
	MOV	EAX,_need_LP_
	PUSH	EAX
	CALL	_need		; need("(");
	;ADD	ESP,4
	POP	EAX
			; /* evaluate switch expression */
	MOV	EAX,1
	PUSH	EAX
	CALL	_doexpr		; doexpr(YES);
	;ADD	ESP,4
	POP	EAX
	;MOV	EAX,_1_384+2
	MOV	EAX,_need_RP_
	PUSH	EAX
	CALL	_need		; need(")");
	;ADD	ESP,4
	POP	EAX
	XOR	EAX,EAX ; 0
	MOV	DWORD [_swdefaul],EAX ; swdefault = 0;
	;MOV	EAX,1
	INC	EAX
	MOV	DWORD [_swactive],EAX ; swactive = 1;
	;MOV	EAX,40
	MOV	AL,40
	PUSH	EAX
	;LEA	EAX,[EBP-20] ; endlab
	;PUSH	EAX
	CALL	_getlabel
	;POP	EBX
	LEA	EBX,[EBP-20]
	MOV	[EBX],EAX
	PUSH	EAX
	CALL	_gen	; gen(JMPm, endlab = getlabel());
	ADD	ESP,8
	CALL	_statemen ; statement(); /* cases, etc. */
	MOV	EAX,40
	PUSH	EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2 (2*4)
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(JMPm, wq[WQEXIT]);
	ADD	ESP,8
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(LABm, endlab);
	ADD	ESP,8
	MOV	EAX,72	; SWITCH
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	CALL	_gen	; gen(SWITCH, 0); /* match cases */
	ADD	ESP,8
_1_385:		; while(swptr < swnext) {
	LEA	EAX,[EBP-36]
	MOV	EBX,[EAX]
	MOV	EAX,[_swnext]
	CALL	__ult
	OR	EAX,EAX
	JE	short _1_386
_1_387:
	MOV	EAX,56
	PUSH	EAX
	LEA	EBX,[EBP-36]
	MOV	EDX,[EBX]
	ADD	DWORD [EBX],4
	MOV	EAX,[EDX]
	PUSH	EAX
	CALL	_gen	; gen(NEARm, *swptr++);
	ADD	ESP,8
	MOV	EAX,112
	PUSH	EAX
	LEA	EBX,[EBP-36]
	MOV	EDX,[EBX]
	ADD	DWORD [EBX],4
	MOV	EAX,[EDX]
	PUSH	EAX
	CALL	_gen ; gen(DWORDn, *swptr++); /* case value */
	ADD	ESP,8
	JMP	short _1_385
_1_386:
	;MOV	EAX,112
	MOV	AL,112
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	CALL	_gen	; gen(DWORDn, 0);
	ADD	ESP,8
		; if(swdefault) gen(JMPm, swdefault);
	MOV	EAX,[_swdefaul]
	OR	EAX,EAX
	JE	short _1_388
_1_389:
	MOV	EAX,40 ; JMPn
	PUSH	EAX
	MOV	EAX,[_swdefaul]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_1_388:
	MOV	EAX,41	; LABm
	PUSH	EAX
	LEA	EBX,[EBP-16]
	ADD	EBX,8	; WQEXIT = 2 (2*4)
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(LABm, wq[WQEXIT]);
	ADD	ESP,8
	CALL	_delwhile ; delwhile();	
	LEA	EBX,[EBP-32]
	MOV	EAX,[EBX]
	MOV	DWORD [_swnext],EAX ; swnext = swnex;
	LEA	EBX,[EBP-28]
	MOV	EAX,[EBX]
	MOV	DWORD [_swdefaul],EAX ; swdefault = swdef;
	LEA	EBX,[EBP-24]
	MOV	EAX,[EBX]
	MOV	DWORD [_swactive],EAX ; swactive  = swact;
	MOV	ESP,EBP
	POP	EBP
	RETN

;_1_384:
;_need_LP_: DB "(",0
;_need_RP_: DB ")",0

_docase:	; docase() {
	PUSH	EBP
	MOV	EBP,ESP
	; if(swactive == 0) error("not in switch");
	MOV	EAX,[_swactive]
	OR	EAX,EAX
	JNE	short _1_391
_1_392:
	;MOV	EAX,_1_390+0
	MOV	EAX,_not_in_switch
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_1_391:		; if(swnext > swend) {
	MOV	EBX,[_swnext]
	MOV	EAX,[_swend]
	CALL	__ugt
	OR	EAX,EAX
	JE	short _1_393
_1_394:		; error("too many cases");
	;MOV	EAX,_1_390+14
	MOV	EAX,_too_many_c
	PUSH	EAX
	CALL	_error
	ADD	ESP,4	; return;
	POP	EBP
	RETN
_1_393:	; gen(LABm, *swnext++ = getlabel());
	MOV	EAX,41
	PUSH	EAX
	MOV	EAX,[_swnext]
	;INC	EAX
	;INC	EAX
	;INC	EAX
	;INC	EAX
	;MOV	DWORD [_swnext],EAX
	;DEC	EAX
	;DEC	EAX
	;DEC	EAX
	;DEC	EAX
	ADD	DWORD [_swnext],4
	PUSH	EAX
	CALL	_getlabel
	POP	EBX
	MOV	[EBX],EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	MOV	EAX,[_swnext]
	;INC	EAX
	;INC	EAX
	;INC	EAX
	;INC	EAX
	;MOV	DWORD [_swnext],EAX
	;DEC	EAX
	;DEC	EAX
	;DEC	EAX
	;DEC	EAX
	ADD	DWORD [_swnext],4
	PUSH	EAX
	CALL	_constexp ; constexpr(swnext++);
	;ADD	ESP,4
	POP	EAX
	;MOV	EAX,_1_390+29
	MOV	EAX,_need_column
	PUSH	EAX
	CALL	_need	; need(":");
	ADD	ESP,4
	POP	EBP
	RETN

_1_390:
;_not_in_switch:
;	DB "not in switch",0
_too_many_c:
 	DB "too many cases",0
;_need_column:
;	DB ':',0

_dodefaul:	; dodefault() {
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,[_swactive] ; if(swactive) {
	OR	EAX,EAX
	JE	short _1_396
_1_397:
	MOV	EAX,[_swdefaul]
	OR	EAX,EAX
	JE	short _1_400
_1_399:		; if(swdefault) error("multiple defaults");
	;MOV	EAX,_1_395+0
	MOV	EAX,_multiple_def
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	;JMP	short _1_400
	JMP	short _1_398
_1_396:		; else error("not in switch");
	;MOV	EAX,_1_395+18
	MOV	EAX,_not_in_switch
	PUSH	EAX
	CALL	_error
_1_398:
	;ADD	ESP,4
	POP	EAX
_1_400:
	;MOV	EAX,_1_395+32
	MOV	EAX,_need_column
	PUSH	EAX
	CALL	_need	; need(":");
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,41
	PUSH	EAX
	CALL	_getlabel
	MOV	DWORD [_swdefaul],EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	POP	EBP
	RETN

_1_395:
_multiple_def:
	DB "multiple defaults",0
_not_in_switch:
	DB "not in switch",0
_need_column:
	DB ':',0

_dogoto:	; dogoto() {
	; if(nogo > 0) error("not allowed with block-locals");
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,[_nogo]
	OR	EAX,EAX
	JNG	short _1_402
_1_403:
	;MOV	EAX,_1_401+0
	MOV	EAX,_not_allow_wbl
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	JMP	short _1_404
_1_402:		; else noloc = 1;
	MOV	EAX,1
	MOV	DWORD [_noloc],EAX
_1_404:
	; if(symname(ssname)) gen(JMPm, addlabel(NO));
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_symname
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _1_405
_1_406:
	MOV	EAX,40
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_addlabel
	ADD	ESP,4
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	JMP	short _1_407
_1_405:
	;MOV	EAX,_1_401+30
	MOV	EAX,_bad_label
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
_1_407:
	CALL	_ns ; ns();
	POP	EBP
	RETN

_1_401:
_not_allow_wbl:
	DB "not allowed with block-locals",0
_bad_label:
	DB "bad label",0

_dolabel:	; dolabel() {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; char *savelptr;
	CALL	_blanks	; blanks();
	LEA	EBX,[EBP-4]
	MOV	EAX,[_lptr]
	MOV	[EBX],EAX ; savelptr = lptr;
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_symname ; if(symname(ssname)) {
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _1_409
_1_410:
	CALL	_gch	; if(gch() == ':') {
	MOV	EBX,EAX
	MOV	EAX,58	; ':'
	CALL	__eq
	OR	EAX,EAX
	JE	short _1_411
_1_412:		; gen(LABm, addlabel(YES));
	MOV	EAX,41	; LABm
	PUSH	EAX
	;MOV	EAX,1
	MOV	AL,1	; YES
	PUSH	EAX
	CALL	_addlabel
	ADD	ESP,4
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	MOV	EAX,1	; return 1;
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_411:		 ; else bump(savelptr-lptr);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	EBX,[_lptr]
	SUB	EAX,EBX
	PUSH	EAX
	CALL	_bump
	;;ADD	ESP,4
	;POP	EAX
_1_413:
	XOR	EAX,EAX
_1_409:
	MOV	ESP,EBP
	POP	EBP
	RETN

_addlabel:	; addlabel(def) int def; {
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_findloc ; if(cptr = findloc(ssname)) {
	ADD	ESP,4
	MOV	DWORD [_cptr],EAX
	OR	EAX,EAX
	JE	short _1_415
_1_416:
	MOV	EBX,[_cptr]
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JE	short _1_417
_1_418:	; if(cptr[IDENT] != LABEL) error("not a label");
	;MOV	EAX,_1_414+0
	MOV	EAX,_not_label_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	JMP	short _1_425
_1_417:		; else if(def) {
	LEA	EBX,[EBP+8] ; int def;
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _1_425
_1_421:
	MOV	EBX,[_cptr]
	;MOV	EAX,1
	;ADD	EBX,EAX
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JE	short _1_422
_1_423:	; if(cptr[TYPE]) error("duplicate label");
	;MOV	EAX,_1_414+12
	MOV	EAX,_dup_label_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	JMP	short _1_425
_1_422:
	MOV	EBX,[_cptr]
	MOV	EAX,1
	ADD	EBX, EAX
	MOV	[EBX],AL  ; else cptr[TYPE] = YES;
	JMP	short _1_425
_1_415:
	; else cptr = addsym(ssname, LABEL, def, 0,
	;		     getlabel(), &locptr, LABEL);
	MOV	EAX,_ssname
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	LEA	EBX,[EBP+8] ; def
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	CALL	_getlabel
	PUSH	EAX
	MOV	EAX,_locptr ; &locptr
	PUSH	EAX
	XOR	EAX,EAX ; LABEL = 0
	PUSH	EAX
	CALL	_addsym
	ADD	ESP,28
	MOV	DWORD [_cptr],EAX
_1_425:	; return (getint(cptr+OFFSET, INTSIZE));
	MOV	EAX,[_cptr]
	;MOV	EBX,5
	;ADD	EAX,EBX
	;MOV	EBX,2
	;ADD	EAX,EBX
	ADD	EAX,7 ; OFFSET = 5+2
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_getint
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_1_414:
_not_label_:
	DB "not a label", 0
_dup_label_:
	DB "duplicate label", 0

_doreturn:	; doreturn()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int savcsp;
	; if(endst() == 0) doexpr(YES);
	CALL	_endst
	OR	EAX,EAX
	JNE	short _1_427
_1_428:
	MOV	EAX,1
	PUSH	EAX
	CALL	_doexpr
	ADD	ESP,4
_1_427:
	LEA	EBX,[EBP-4]
	MOV	EAX,[_csp]
	MOV	[EBX],EAX ; savcsp = csp;
	MOV	EAX,67
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen	; gen(RETURN, 0);
	;ADD	ESP,8
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
		; csp = savcsp;
	MOV	DWORD [_csp],EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_dobreak:	; dobreak()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int *ptr;
	; if((ptr = readwhile(wqptr)) == 0) return;
	MOV	EAX,[_wqptr]
	PUSH	EAX
	CALL	_readwhil
	ADD	ESP,4
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _1_430
_1_431:
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_430:
	MOV	EAX,2
	PUSH	EAX
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(ADDSP, ptr[WQSP]);
	ADD	ESP,8
	MOV	EAX,40
	PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;MOV	EBX,8
	;ADD	EBX,EAX
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	ADD	EBX,8
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen	; gen(JMPm, ptr[WQEXIT]);
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_docont:	; docont()  {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4
	LEA	EBX,[EBP-4]	; int *ptr;
	MOV	EAX,[_wqptr]
	MOV	[EBX],EAX	; ptr = wqptr;
_1_433:		; while (1) {
	; if((ptr = readwhile(ptr)) == 0) return;
	LEA	EBX,[EBP-4]
	PUSH	EBX
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_readwhil
	ADD	ESP,4
	POP	EBX
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _1_435
_1_436:
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_435:		; if(ptr[WQLOOP]) break;
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	ADD	EBX,4
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _1_433
_1_434:		; gen(ADDSP, ptr[WQSP]);
	MOV	EAX,2
	PUSH	EAX
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(JMPm, ptr[WQLOOP]);
	MOV	EAX,40
	PUSH	EAX
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	ADD	EBX,4
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_doasm:		; doasm()  {
	PUSH	EBP
	MOV	EBP,ESP
	XOR	EAX,EAX
	MOV	DWORD [_ccode],EAX ; ccode = 0;
_1_440:
	;XOR	CL,CL
	CALL	_inline	; inline();
	MOV	EAX,_endasm_ ; _1_439+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_match	; if(match("#endasm")) break;
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _1_441
_1_442:
	MOV	EAX,[_eof]
	OR	EAX,EAX
	JNZ	short _1_441 ; if(eof)break;
_1_444:
	MOV	EAX,[_line]
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_fputs	; fputs(line, output);
	ADD	ESP,8
	JMP	short _1_440
_1_441:		; break
	;XOR	CL,CL
	CALL	_kill	; kill();
	MOV	EAX,1	; ccode = 1;
	MOV	DWORD [_ccode],EAX
	POP	EBP
	RETN

_1_439:
_endasm_: DB "#endasm",0

_doexpr:	; doexpr(use) int use; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-16	; int constant, val;
		; int *before, *start;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	DWORD [_usexpr],EAX ; usexpr = use;
_1_447:		; while(1) {
	LEA	EAX,[EBP-12]
	PUSH	EAX
	LEA	EAX,[EBP-16]
	PUSH	EAX
	CALL	_setstage ; setstage(&before, &start);
	ADD	ESP,8
	LEA	EAX,[EBP-4]
	PUSH	EAX
	LEA	EAX,[EBP-8]
	PUSH	EAX
	CALL	_expressi ; expression(&constant, &val);
	ADD	ESP,8
	LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_clearsta ; clearstage(before, start);
	ADD	ESP,8
	MOV	EBX,[_ch]
	MOV	EAX,44
	CALL	__ne	; if(ch != ',') break;
	OR	EAX,EAX
	JNZ	short _1_448
_1_449:
	;MOV	EAX,1
	INC	EAX
	PUSH	EAX
	CALL	_bump	; bump(1);
	;ADD	ESP,4
	POP	 EAX
	JMP  short _1_447 ; jump to while
_1_448:		; break;
	;MOV	EAX,1
	; eax = 1
	MOV	DWORD [_usexpr],EAX ; usexpr = YES;
	MOV	ESP,EBP
	POP	EBP
	RETN

_ask:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8
	LEA	EBX,[EBP-4]
	;PUSH	EAX	; int i
	XOR	EAX,EAX ; 0
	MOV	DWORD [_nxtlab],EAX
	MOV	DWORD [_listfp],EAX
	;POP	EBX
	MOV	[EBX],EAX	; i = listfp = nxtlab = 0;
	;XOR	EAX,EAX ; 0
	MOV	BYTE [_optimize],AL ; optimize = NO;
	DEC	EAX ; -1
	MOV	DWORD [_output],EAX ; stdout
	;XOR	EAX,EAX ; 0
	INC	EAX		; alarm = monitor = pause = NO;
	MOV	BYTE [_pause],AL
	MOV	BYTE [_monitor],AL
	MOV	BYTE [_alarm],AL
	MOV	EAX,[_mline]
	MOV	DWORD [_line],EAX ; line = mline;
_1_452:
	; while(getarg(++i, line, LINESIZE, argcs, argvs) != EOF)
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	INC	EAX
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
	JNZ	short _1_454 ; not EOF
	;JMP	_1_453	; = EOF
_1_453:
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_454:
	MOV	EAX,[_line]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,45	; '-'
	CALL	__ne
	OR	EAX,EAX
	JZ	short _1_456
_1_458:
	MOV	EAX,[_line]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,47	 ; '/'
	CALL	__ne
	OR	EAX,EAX
	;JZ	short _1_456
	;JMP	short _1_452
	JNZ	short _1_452 ; continue;
_1_459:
	;MOV	EAX,1
	;JMP	short _1_452
_1_456:
_1_455:
	MOV	EBX,[_line]	; if(toupper(line[1]) == 'L'
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,76	; 'L'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_461
_1_464:
	MOV	EBX,[_line]
	;ADD	EBX,2
	INC	EBX
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_isdigit
	;ADD	ESP,4
	POP	EBX
	OR	EAX,EAX
	JZ	short _1_461
_1_465:
	MOV	EAX,[_line]
	ADD	EAX,3
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32	; ' '
	CALL	__le
	OR	EAX,EAX
	JZ	short _1_461
_1_466:
_1_467:
	MOV	EBX,[_line]
	INC	EBX
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	;MOV	EBX,48	 ; '0'
	;SUB	EAX,EBX
	SUB	EAX,48
	MOV	DWORD [_listfp],EAX
	JMP	_1_452
_1_461:
	MOV	EBX,[_line]	; if(toupper(line[1]) == 'N'
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,78	 ;'N'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_468
_1_471:
	MOV	EBX,[_line]
	;ADD	EBX,2
	INC	EBX
	INC	EBX
	;MOVSX	EAX,BYTE [EBX]
	MOV	AL,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,79	; 'O'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_468
_1_472:
	MOV	EAX,[_line]
	ADD	EAX,3
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32	; ' '
	CALL	__le
	OR	EAX,EAX
	JZ	short _1_468
_1_473:
_1_474:
	XOR	EAX,EAX
	MOV	BYTE [_optimize],AL
	JMP	_1_452
_1_468:
	MOV	EBX,[_line] ; if(toupper(line[1]) == 'D')
	INC	EBX
	;MOVSX	EAX,BYTE [EBX]
	MOV	AL,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,68	; 'D'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_475
_1_476:
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	MOV	[EBX],EAX  ; j = 0;
	;MOV	EAX,[_line]
	;PUSH	EAX
	;LEA	EBX,[EBP-8]
	;MOV	EAX,[EBX]
	;;ADD	EAX,2
	;INC	EAX
	;INC	EAX
	;POP	EBX
	INC	EAX
	INC	EAX ; (j+2 = 2)
	MOV	EBX,[_line]
	ADD	EBX,EAX	; line + j+2;
	MOVSX	EAX,BYTE [EBX]
	MOV	DWORD [_ch],EAX ; ch = line[j+2];
	;MOV	EAX,[_line]
	;PUSH	EAX
	;LEA	EAX,[EBP-8]
	;MOV	EBX,EAX
	;MOV	EAX,[EBX] ; j = 0
	;POP	EBX 	
	;ADD	EAX,EBX ; j + line
	;;ADD	EAX,2
	;INC	EAX
	;INC	EAX  ; lptr = line + j+2
	;MOV	DWORD [_lptr],EAX
	MOV	DWORD [_lptr],EBX
	CALL	_dodefine
	JMP	_1_452
_1_475:
	MOV	EAX,[_line] ; if(line[2] <= ' ')
	;ADD	EAX,2
	INC	EAX
	INC	EAX
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32	 ; ' '
	CALL	__le
	OR	EAX,EAX
	JNZ	short _1_478  ; true
	JMP	_1_477
_1_478:
	MOV	EBX,[_line] ; if(toupper(line[1]) == 'A')
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,65	; 'A'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_479 ; false
_1_480:		; {alarm = YES; continue;}
	;MOV	EAX,1
	;eax = 1
	MOV	BYTE [_alarm],AL
	;MOV	BYTE [_alarm],1
	JMP	_1_452
_1_479:
	MOV	EBX,[_line] ; if(toupper(line[1]) == 'M')
	INC	EBX
	;MOVSX	EAX,BYTE [EBX]
	MOV	AL,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,77	; 'M'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_481 ; false
_1_482:		; {monitor = YES; continue;}
	;MOV	EAX,1
	;eax = 1
	MOV	BYTE [_monitor],AL
	;MOV	BYTE [_monitor],1
	JMP	_1_452
_1_481:
	MOV	EBX,[_line] ; if(toupper(line[1]) == 'P')
	INC	EBX
	;MOVSX	EAX,BYTE [EBX]
	MOV	AL,BYTE [EBX]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,80	; 'P'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _1_483 ; false
_1_484:		; {pause = YES; continue;}
	MOV	EAX,1
	MOV	BYTE [_pause],AL
	JMP	_1_452
_1_483:
_1_477:
	MOV	EAX,usage ; _1_451+0
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,usage_m
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,usage_a
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,usage_p
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,usage_l
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,usage_no
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,usage_d
	PUSH	EAX
	CALL	_puts
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,7  ; error code = 7 ; ERRCODE
	PUSH	EAX
	CALL	_OS_exit ; exit(ERRCODE);
	;ADD	ESP,4
	POP	EAX	;   }
	JMP	_1_452	; }

_1_451:
usage:
 	DB "usage: cc [file]... [-m] [-a] [-p] [-l#] [-no] [-d<id>]",13,10,0
usage_m:
 	DB " -m     monitor",13,10,0
usage_a:
 	DB " -a     alarm",13,10,0
usage_p:
 	DB " -p     pause",13,10,0
usage_l:
 	DB " -l#    list",13,10,0
usage_no:
 	DB " -no    no optimize",13,10,0
usage_d:
 	DB " -d<id> pre-#define id",13,10,0

_openfile:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-28	; char outfn[15]; int i, j, ext;
	MOV	EAX,-1	; EOF;
	MOV	DWORD [_input],EAX ; input = EOF;
_1_486:
	; while(getarg(++filearg, pline, LINESIZE, argcs, argvs) != EOF)
	INC	DWORD [_filearg]
	MOV	EAX,[_filearg]
	;INC	EAX
	;MOV	DWORD [_filearg],EAX
	PUSH	EAX
	MOV	EAX,[_pline]
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
	MOV	EAX,-1
	CALL __ne
	OR	EAX,EAX
	JNZ	short _1_488
	JMP	_1_487
_1_488:	 ; if(pline[0] == '-' || pline[0] == '/')
	MOV	EAX,[_pline]
	MOVSX	EBX,BYTE [EAX] ; pline[0]
	MOV	EAX,45	; '-'
	CALL	__eq
	OR	EAX,EAX
	;JNZ	short _1_490 ; pline[0] == '-'
	JNZ	short _1_486 ; continue ;
_1_492:
	MOV	EAX,[_pline]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,47	; '/'
	CALL	__eq
	;OR	 EAX,EAX
	;JNZ	short _1_490
_1_493:
	;XOR	EAX,EAX
	;eax	= 0
	;JMP	_1_491
_1_490:
	;MOV	EAX,1
	;eax = 1
_1_491:
	OR	EAX,EAX
	JNZ	short _1_486 ; true, continue;
_1_489:		 ; false
	LEA	EBX,[EBP-28]
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX	; ext = NO;
	LEA	EBX,[EBP-24]
	;XOR	EAX,EAX
	MOV	[EBX],EAX	; j = 0;
	LEA	EBX,[EBP-20]
	;MOV	EAX,-1
	DEC	EAX ; -1
	MOV	[EBX],EAX	; i = -1;
	;LEA	EBX,[EBP-24]
	;;XOR	EAX,EAX
	;INC	EAX ; 0
	;MOV	[EBX],EAX	; j = 0;
_1_495:		; while(pline[++i]) {
	MOV	EAX,[_pline]
	LEA	EBX,[EBP-20]
	INC	DWORD [EBX] ; ++i
	ADD	EAX,[EBX]
	MOVSX	EBX,BYTE [EAX]
	OR	EBX,EBX
	JZ	short _1_496 ; pline[++i] = 0
_1_497:
	;MOV	EAX,[_pline]
	;LEA	EBX,[EBP-20]
	;ADD	EAX,[EBX]	
	;MOVSX	EBX,BYTE [EAX] ; pline[i]
	MOV	EAX,46	; '.'
	CALL	__eq	; if(pline[i] == '.')
	OR	EAX,EAX
	JZ	short _1_498 ; false
_1_499:		; true
	LEA	EBX,[EBP-28]
	;MOV	EAX,1
	;eax = 1
	MOV	[EBX],EAX	; ext = YES;
	JMP	short _1_496 ; break;
_1_498:		; if(j < 10)
	LEA	EAX,[EBP-24]
	MOV	EBX,[EAX]
	MOV	EAX,10
	CALL	__lt
	OR	EAX,EAX
	;JZ	short _1_500 ; false
	JZ	short _1_495
_1_501:		; outfn[j++] = pline[i];
	;LEA	EAX,[EBP-16]
	;PUSH	EAX
	LEA	EBX,[EBP-24]
	MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	;DEC	EAX
	INC	DWORD [EBX]
	;POP	EBX
	LEA	EBX,[EBP-16] ; outfn[0]
	ADD	EAX,EBX	; outfn[j++]
	PUSH	EAX
	;MOV	EAX,[_pline]
	;PUSH	EAX
	LEA	EBX,[EBP-20] ; i
	MOV	EAX,[EBX]
	;POP	EBX
	MOV	EBX,[_pline] ; pline[0]
	ADD	EBX,EAX	; pline[i];
	MOVSX	EAX,BYTE [EBX]
	POP	EBX
	MOV	[EBX],AL     ; outfn[j++] = pline[i];
_1_500:
	JMP	short _1_495 ; jump to while(pline[++i])
_1_496:	; if(!ext) strcpy(pline + i, ".C");
	LEA	EBX,[EBP-28]
	MOV	EAX,[EBX]
	CALL	__lneg	; if(!ext)
	OR	EAX,EAX
	JZ	short _1_502 ; false (fn with extension)
_1_503:		; true (fn without extension)
	LEA	EBX,[EBP-20] ; i
	MOV	EAX,[EBX]
	MOV	EBX,[_pline] ; pline
	ADD	EAX,EBX	; pline + i
	PUSH	EAX
	MOV	EAX,EXT_C    ; _1_485+0 ; ".C" extension
	PUSH	EAX
	CALL	_strcpy
	ADD	ESP,8
_1_502:		; input = mustopen(pline, "r");
	MOV	EAX,[_pline]
	PUSH	EAX
	MOV	EAX,OPEN_R	; 'r'
	PUSH	EAX
	CALL	_mustopen
	ADD	ESP,8
	MOV	DWORD [_input],EAX
	MOV	EAX,[_files]
	CALL	__lneg	; if(!files) {
	OR	EAX,EAX
	JZ	short _1_504 ; false
_1_505:
	LEA	EBX,[EBP-24] ; j
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-16] ; outfn
	ADD	EAX,EBX	; outfn + j
	PUSH	EAX
	MOV	EAX,EXT_ASM ; ".ASM" extension
	PUSH	EAX
	CALL	_strcpy	; strcpy(outfn + j, ".ASM");
	ADD	ESP,8
	LEA	EAX,[EBP-16] ; outfn
	PUSH	EAX
	MOV	EAX,OPEN_W   ; 'w'
	PUSH	EAX
	CALL	_mustopen    ; output = mustopen(outfn, "w");
	ADD	ESP,8
	MOV	DWORD [_output],EAX
_1_504:
	MOV	EAX,1
	MOV	DWORD [_files],EAX ; files = YES;
	JMP	short _1_508
	;XOR	CL,CL
	;CALL	_kill
	;MOV	ESP,EBP
	;POP	EBP
	;RETN

_1_487:		; if(files++) eof = YES;
	MOV	EAX,[_files]
	INC	DWORD [_files]
	OR	EAX,EAX
	JZ	short _1_506 ; false
_1_507:
	MOV	EAX,1
	MOV	DWORD [_eof],EAX ; eof = YES
_1_508:	; 
	;XOR	CL,CL	; kill();
	CALL	_kill
	MOV	ESP,EBP	; return;
	POP	EBP
	RETN

_1_506:
	; TRDOS 386 modification
	;MOV	EAX,-1
	DEC	EAX
	;eax = -1
	MOV	DWORD [_input],EAX ; input = stdin;
	JMP	short _1_508

_1_485:
EXT_C:   DB ".C",0
OPEN_R:  DB "r",0
EXT_ASM: DB ".ASM",0
OPEN_W:  DB "w",0

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
	JZ	short _1_510
			; error (file not found or access err)
_1_511:
	;LEA	EBX,[EBP-4] ; fd
	;MOV	EAX,[EBX]  ; return fd
	; eax = file handle + 1
	MOV	ESP,EBP
	POP	EBP
	RETN
_1_510:		; puts("open error on ");
	MOV	EAX,OPEN_ERR ; _1_509+0
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

_1_509:
OPEN_ERR: DB "open error on ", 0
