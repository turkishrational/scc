; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 24/03/2026
; -----------------------------------------------------------
; Derived from 'cc3.asm' file of KolibriOS SCC source code
; 2024

_constexp:	; constexpr(val) int *val; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-12	; int constant; *before, *start;
	LEA	EAX,[EBP-8]
	PUSH	EAX
	LEA	EAX,[EBP-12]
	PUSH	EAX
	CALL	_setstage ; setstage(&before, &start);
	ADD	ESP,8
	LEA	EAX,[EBP-4]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_expressi ; expression(&constant, val);
	ADD	ESP,8
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta ; clearstage(before, 0);
	ADD	ESP,8
		; if(constant == 0)
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_2
_3_3:		; error("must be constant expression");
	;MOV	EAX,_3_1+0
	MOV	EAX,_mbcexp_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
;_3_2:		; return constant;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
_3_2:
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_1:
_mbcexp_: DB "must be constant expression",0

_null_is:	; null_is (is)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4
	LEA	EAX,[EBP-4] ; i
	XOR	ECX,ECX
_3_7:
	MOV	[EAX],ECX
;_3_7:		; for (i = 0; i < 7; ++i)
	;LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,7
	CALL	__lt
	OR	EAX,EAX
	JNE	short _3_8
_3_6:
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_5:
	;LEA	EAX,[EBP-4]
	MOV	ECX,[EAX]
	INC	ECX
	;MOV	[EAX],ECX
	JMP	short _3_7
_3_9:
_3_8:		; is[i] = 0;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	LEA	EAX,[EBP-4]
	MOV	ECX,[EAX]
	SHL	ECX,1
	SHL	ECX,1
	ADD	EDX,ECX
	XOR	ECX,ECX
	MOV	[EDX],ECX
	JMP	short _3_5

_expressi:	; expression(con, val) int *con, *val;
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-32	; int i; int is[7];
	LEA	EAX,[EBP-32]
	PUSH	EAX ; *
	PUSH	EAX
	CALL	_null_is ; null_is (is);
	;ADD	ESP,4
	POP	EAX
		; if(level1(is)) fetch(is);
	;LEA	EAX,[EBP-32]
	;PUSH	EAX ; *
	CALL	_level1
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_11
_3_12:
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_11:		; *con = is[TC];
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-32]
	ADD	EDX,12	; TC = 3 (3*4)
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
		; *val = is[CV];
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-32]
	ADD	EDX,16	; CV = 4 (4*4)
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_test:	; test(label, parens) int label, parens; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-36
		; int is[7]; int *before, *start;
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_null_is ; null_is (is);
	;ADD	ESP,4
	POP	EAX
		; if(parens) need("(");
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_14
_3_15:
	;MOV	EAX,_3_13+0
	MOV	EAX,_LPR_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
	POP	EAX
_3_14:
_3_16:		; while(1) {
_3_22:
	LEA	EAX,[EBP-32]
	PUSH	EAX
	LEA	EAX,[EBP-36]
	PUSH	EAX
	CALL	_setstage ; setstage(&before, &start);
	ADD	ESP,8
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_level1	; if(level1(is)) fetch(is);
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_18
_3_19:
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_18:	; if(match(",")) clearstage(before, start);
	;MOV	EAX,_3_13+2
	MOV	EAX,_COMMA
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_20 ; else break;
_3_21:
	LEA	EBX,[EBP-32]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-36]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_clearsta ; clearstage(before, start);
	ADD	ESP,8
	JMP	short _3_22
_3_20:
_3_17:		; if(parens) need(")");
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_23
_3_24:
	;MOV	EAX,_3_13+4
	MOV	EAX,_RPR_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
	POP	EAX
_3_23:		; if(is[TC]) {
	;LEA	EAX,[EBP-28]
	;MOV	EBX,12
	;ADD	EBX,EAX
	LEA	EBX,[EBP-28]
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_25
_3_26:		; clearstage(before, 0);
	LEA	EBX,[EBP-32]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta
	ADD	ESP,8
		; if(is[CV]) return;
	;LEA	EAX,[EBP-28]
	;MOV	EBX,16
	;ADD	EBX,EAX
	LEA	EBX,[EBP-28]
	ADD	EBX,16
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_28
_3_27:		; gen(JMPm, label);
	MOV	EAX,40
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
_3_28:
		; return;
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_25:		; if(is[SA]) {
	;LEA	EAX,[EBP-28]
	;MOV	EBX,24	; SA = 6 (6*4)
	;ADD	EBX,EAX
	LEA	EBX,[EBP-28]
	ADD	EBX,24
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNZ	short _3_30
_3_29:		; else gen(NE10f, label);
	MOV	EAX,54
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
_3_45_@:
	ADD	ESP,8
_3_32:		; break;
_3_45:		; clearstage(before, start);
	LEA	EBX,[EBP-32]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-36]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_clearsta
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_30:		; is[OP]
	;LEA	EAX,[EBP-28]
	;MOV	EBX,20 ; OP = 5 (5*4)
	;ADD	EBX,EAX
	LEA	EBX,[EBP-28]
	ADD	EBX,20
	MOV	EAX,[EBX]
	JMP	_3_33	; switch(is[OP]) {
_3_34:		; case EQ12:
_3_35:		; case LE12u:
		; zerojump(EQ10f, label, is);
	MOV	EAX,19
_3_32_@:
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_zerojump
	ADD	ESP,12
	JMP	short _3_32 ; break;

_3_36:		; case NE12:
_3_37:		; case GT12u:
		; zerojump(NE10f, label, is);
	MOV	EAX,54
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EAX,[EBP-28]
	;PUSH	EAX
	;CALL	_zerojump
	;ADD	ESP,12
	;JMP	short _3_32 ; break;
	JMP	short _3_32_@
_3_38:		; case GT12:
		; zerojump(GT10f, label, is);
	MOV	EAX,34
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EAX,[EBP-28]
	;PUSH	EAX
	;CALL	_zerojump
	;ADD	ESP,12
	;JMP	short _3_32 ; break;
	JMP	short _3_32_@
_3_39:		; case GE12:
		; zerojump(GE10f, label, is);
	MOV	EAX,21
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EAX,[EBP-28]
	;PUSH	EAX
	;CALL	_zerojump
	;ADD	ESP,12
	;JMP	short _3_32 ; break;
	JMP	short _3_32_@
_3_40:		; case GE12u:
		; clearstage(is[SA], 0);
	LEA	EBX,[EBP-28]
	ADD	EBX,24
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta
	;ADD	ESP,8
	;JMP	short _3_32 ; break;
	JMP	short _3_45_@
_3_41:		; case LT12:
		; zerojump(LT10f, label, is);
	MOV	EAX,46
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EAX,[EBP-28]
	;PUSH	EAX
	;CALL	_zerojump
	;ADD	ESP,12
	;JMP	short _3_32 ; break;
	JMP	short _3_32_@
_3_42:		; case LT12u:
		; zerojump(JMPm,  label, is);
	MOV	EAX,40
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EAX,[EBP-28]
	;PUSH	EAX
	;CALL	_zerojump
	;ADD	ESP,12
	;JMP	short _3_32 ; break;
	JMP	short _3_32_@
_3_43:		; case LE12:
		; zerojump(LE10f, label, is);
	MOV	EAX,42
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EAX,[EBP-28]
	;PUSH	EAX
	;CALL	_zerojump
	;ADD	ESP,12
	;JMP	short _3_32 ; break;
	JMP	short _3_32_@
_3_44:		; default:
		; gen(NE10f, label);
	MOV	EAX,54
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	;JMP	short _3_32 ; break;
	JMP	_3_45_@
_3_33:
		; switch(is[OP]) {
	CALL	__switch

 DD _3_34
 DD 20
 DD _3_35
 DD 44
 DD _3_36
 DD 55
 DD _3_37
 DD 36
 DD _3_38
 DD 35
 DD _3_39
 DD 22
 DD _3_40
 DD 23
 DD _3_41
 DD 47
 DD _3_42
 DD 48
 DD _3_43
 DD 43
 DD 0
		; default:
	JMP	short _3_44

_3_13:
_LPR_:	 DB "(",0
_COMMA:  DB ",",0
_RPR_:	 DB ")",0

_zerojump:	; zerojump(oper, label, is)
		;     int oper, label, is[]; {
	PUSH	EBP
	MOV	EBP,ESP
		; clearstage(is[SA], 0);
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;MOV	EBX,24
	;ADD	EBX,EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,24
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta
	ADD	ESP,8
		; gen(oper, label);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_level1:	; level1(is) int is[]; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-48
		; int k, is2[7], is3[2], oper, oper2;
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_null_is ; null_is (is2);
	;ADD	ESP,4
	POP	EAX
	LEA	EAX,[EBP-40]
	PUSH	EAX
	CALL	_null_is ; null_is (is3);
	;ADD	ESP,4
	POP	EAX
		; k = down1(level2, is);
	MOV	EAX,_level2 ; procedure address
	PUSH	EAX
	LEA	EBX,[EBP+8] ; is
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
	LEA	EBX,[EBP-4] ; k
	MOV	[EBX],EAX
		; if(is[TC]) {
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;MOV	EBX,12
	;ADD	EBX,EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_48
_3_49:		; gen(GETd1n, is[CV]);
	MOV	EAX,108
	PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;MOV	EBX,16
	;ADD	EBX,EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,16
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_48:		; if(match("|="))
	;MOV	EAX,_3_47+0
	MOV	EAX,_OREQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_50
_3_51:		; {oper = oper2 = OR12;}
	MOV	EAX,57
	;LEA	EBX,[EBP-48]
	;MOV	[EBX],EAX
	;LEA	EBX,[EBP-44]
	;MOV	[EBX],EAX
	;JMP	_3_52
	JMP	short _3_52 ; *
_3_50:		; else if(match("^="))
	;MOV	EAX,_3_47+3
	MOV	EAX,_XOREQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_53
_3_54:		; {oper = oper2 = XOR12;}
	MOV	EAX,73
_3_52:	; *
	LEA	EBX,[EBP-48]
	MOV	[EBX],EAX
	LEA	EBX,[EBP-44]
	MOV	[EBX],EAX
	JMP	_3_55
_3_53:		; else if(match("&=")) 
	;MOV	EAX,_3_47+6
	MOV	EAX,_ANDEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _3_56
_3_57:		; {oper = oper2 = AND12;}
	MOV	EAX,3
	;LEA	EBX,[EBP-48]
	;MOV	[EBX],EAX
	;LEA	EBX,[EBP-44]
	;MOV	[EBX],EAX
	;JMP	_3_58
	JMP	short _3_52 ; *
_3_56:		; else if(match("+="))
	;MOV	EAX,_3_47+9
	MOV	EAX,_ADDEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_59
_3_60:		; {oper = oper2 = ADD12;}
	MOV	EAX,1
	;LEA	EBX,[EBP-48]
	;MOV	[EBX],EAX
	;LEA	EBX,[EBP-44]
	;MOV	[EBX],EAX
	;JMP	_3_61
	JMP	short _3_52 ; *
_3_59:		; else if(match("-="))
	;MOV	EAX,_3_47+12
	MOV	EAX,_SUBEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_62
_3_63:		; {oper = oper2 = SUB12;}
	MOV	EAX,69
	;LEA	EBX,[EBP-48]
	;MOV	[EBX],EAX
	;LEA	EBX,[EBP-44]
	;MOV	[EBX],EAX
	;JMP	_3_64
	JMP	short _3_52 ; *
_3_62:		; else if(match("*="))
	;MOV	EAX,_3_47+15
	MOV	EAX,_MULEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_65
_3_66:		; {oper = MUL12; oper2 = MUL12u;}
	LEA	EBX,[EBP-44]
	MOV	EAX,52
	MOV	[EBX],EAX
	LEA	EBX,[EBP-48]
	;MOV	EAX,53
	INC	EAX
	MOV	[EBX],EAX
	JMP	_3_67
_3_65:		; else if(match("/="))
	;MOV	EAX,_3_47+18
	MOV	EAX,_DIVEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_68 ; else
_3_69:		; {oper = DIV12; oper2 = DIV12u;}
	LEA	EBX,[EBP-44]
	MOV	EAX,16
	MOV	[EBX],EAX
	LEA	EBX,[EBP-48]
	;MOV	EAX,17
	INC	EAX
	MOV	[EBX],EAX
	JMP	_3_70
_3_68:		; else if(match("%="))
	;MOV	EAX,_3_47+21
	MOV	EAX,_MODEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_71 ; else
_3_72:		; {oper = MOD12; oper2 = MOD12u;}
	LEA	EBX,[EBP-44]
	MOV	EAX,49
	MOV	[EBX],EAX
	LEA	EBX,[EBP-48]
	;MOV	EAX,50
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _3_73 ; else
_3_71:		; else if(match(">>="))
	;MOV	EAX,_3_47+24
	MOV	EAX,_ASREQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_74 ; else
_3_75:		; {oper = oper2 = ASR12;}
	MOV	EAX,7
	;LEA	EBX,[EBP-48]
	;MOV	[EBX],EAX
	;LEA	EBX,[EBP-44]
	;MOV	[EBX],EAX
	JMP	short _3_76 ; **
_3_74:		; else if(match("<<="))
	;MOV	EAX,_3_47+28
	MOV	EAX,_ASLEQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_77
_3_78:		; {oper = oper2 = ASL12;}
	MOV	EAX,6
_3_76:	; **
	LEA	EBX,[EBP-48]
	MOV	[EBX],EAX
	LEA	EBX,[EBP-44]
	MOV	[EBX],EAX
	JMP	short _3_79
_3_77:		; else if(match("="))
	;MOV	EAX,_3_47+32
	MOV	EAX,_EQU_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_80 ; else
_3_81:		; {oper = oper2 = 0;}
	LEA	EBX,[EBP-44] ; oper
	LEA	EDX,[EBP-48] ; oper2
	XOR	EAX,EAX	; 0
	MOV	[EDX],EAX
	MOV	[EBX],EAX
	JMP	short _3_82
_3_80:		; else return k;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_82:
_3_79:
;_3_76: ; **
_3_73:
_3_70:
_3_67:
_3_64:
_3_61:
_3_58:
;_3_52: ; *
_3_55:		; if(k == 0) {
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_83
_3_84:
	CALL	_needlval ; needlval();	
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_83:		; is3[ST] = is[ST];
	LEA	EBX,[EBP-40]
	LEA	EAX,[EBP+8]
	MOV	EDX,[EAX] ; *
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
		; is3[TI] = is[TI];
	LEA	EBX,[EBP-40]
	MOV	ECX,4
	ADD	EBX,ECX
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX] ; *
	;MOV	ECX,4
	ADD	ECX,EDX
	MOV	EAX,[ECX]
	MOV	[EBX],EAX
		; if(is[TI]) {
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;MOV	EBX,4
	;ADD	EBX,EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,4
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_85
_3_86:		; if(oper) {
	LEA	EBX,[EBP-44]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_87
_3_88:		; gen(PUSH1, 0);
	MOV	EAX,60
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; fetch(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_87:		; down2(oper, oper2, level1, is, is2);
	LEA	EBX,[EBP-44]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-48]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,_level1 ; procedure address
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_down2
	ADD	ESP,20
		; if(oper) gen(POP2, 0);
	LEA	EBX,[EBP-44]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _3_89
	JE	short _3_91
_3_90:
	MOV	EAX,59
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_89:
	JMP	short _3_91
_3_85:		; if(oper) {
	LEA	EBX,[EBP-44]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_92
_3_93:		; fetch(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
		; down2(oper, oper2, level1, is, is2);
	LEA	EBX,[EBP-44] ; oper
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-48] ; oper2
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,_level1  ; procedure address
	PUSH	EAX
	LEA	EBX,[EBP+8]  ; is
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP-32] ; is2
	PUSH	EAX
	CALL	_down2
	ADD	ESP,20
	JMP	short _3_94
_3_92:		; else {
		; if(level1(is2)) fetch(is2);
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_level1
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_95
_3_96:
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_95:
_3_94:
_3_91:		; store(is3);
	LEA	EAX,[EBP-40]
	PUSH	EAX
	CALL	_store
	;ADD	ESP,4
	POP	EAX
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_47:
_OREQ_:  DB "|=",0
_XOREQ_: DB "^=",0
_ANDEQ_: DB "&=",0
_ADDEQ_: DB "+=",0
_SUBEQ_: DB "-=",0
_MULEQ_: DB "*=",0
_DIVEQ_: DB "/=",0
_MODEQ_: DB "%=",0
_ASREQ_: DB ">>=",0
_ASLEQ_: DB "<<=",0
_EQU_:   DB "=",0

_level2:	; level2(is1) int is1[]; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-76
		; int is2[7], is3[7], k, flab,
		;     endlab, *before, *after;
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_null_is ; null_is (is2);
	;ADD	ESP,4
	POP	EAX
	LEA	EAX,[EBP-56]
	PUSH	EAX
	CALL	_null_is ; null_is (is3);
	;ADD	ESP,4
	POP	EAX
		; k = down1(level3, is1);
	MOV	EAX,_level3
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
	LEA	EBX,[EBP-60] ; k
	MOV	[EBX],EAX
	PUSH	EAX ; -k-
		; if(match("?") == 0)
	;MOV	EAX,_3_97+0
	MOV	EAX,_QUEST_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_98
_3_99:		; return k;
	;LEA	EBX,[EBP-60]
	;MOV	EAX,[EBX]
	POP	EAX ; -k-
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_98:	; dropout(k, NE10f, flab = getlabel(), is1);
	;LEA	EBX,[EBP-60]
	;MOV	EAX,[EBX]
	;POP	EAX ; -k-
	;PUSH	EAX
	MOV	EAX,54
	PUSH	EAX
	CALL	_getlabel
	LEA	EBX,[EBP-64]
	MOV	[EBX],EAX ; flab
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_dropout
	ADD	ESP,16
	; if(down1(level2, is2)) fetch(is2);
	MOV	EAX,_level2
	PUSH	EAX
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _3_100 ; else
_3_101:
	LEA	EAX,[EBP-28]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
	JMP	short _3_102
_3_100:		; else if(is2[TC])
	LEA	EBX,[EBP-28]
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_103
_3_104:		; gen(GETd1n, is2[CV]);
	MOV	EAX,108
	PUSH	EAX
	LEA	EBX,[EBP-28]
	ADD	EBX,16
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_103:
_3_102:		; need(":");
	;MOV	EAX,_3_97+2
	MOV	EAX,_COLON_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
	POP	EAX
		; gen(JMPm, endlab = getlabel());
	MOV	EAX,40
	PUSH	EAX
	CALL	_getlabel
	LEA	EBX,[EBP-68]
	MOV	[EBX],EAX ; endlab
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(LABm, flab);
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-64]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	; if(down1(level2, is3)) fetch(is3);
	LEA	EBX,[EBP-56] ; is3
	PUSH	EBX ; * ; -is3-
	MOV	EAX,_level2
	PUSH	EAX
	PUSH	EBX ; is3
	CALL	_down1
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _3_105 ; else
_3_106:
	;LEA	EAX,[EBP-56]
	;PUSH	EAX ; -is3-
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX ; * ; -is3-
	JMP	short _3_107
_3_105:		; else if(is3[TC])
	;LEA	EAX,[EBP-56]
	;MOV	EBX,12
	;ADD	EBX,EAX
	;LEA	EBX,[EBP-56]
	POP	EBX ; * ; -is3-
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_108
_3_109:		; gen(GETd1n, is3[CV]);
	MOV	EAX,108
	PUSH	EAX
	;LEA	EAX,[EBP-56]
	;MOV	EBX,16
	;ADD	EBX,EAX
	LEA	EBX,[EBP-56]
	ADD	EBX,16
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_108:
_3_107:		; gen(LABm, endlab);
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-68]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is1[TC] = is1[CV] = 0;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	XOR	EAX,EAX	; 0
	MOV	ECX,12
	ADD	EDX,ECX
	MOV	[EDX],EAX ; is[TC] = 0
	;LEA	EBX,[EBP+8]
	;MOV	EDX,[EBX]
	;ADD	EDX,16
	ADD	EDX,4 ; 12+4
	MOV	[EDX],EAX ; is[CV] = 0
		; if(is2[TC] && is3[TC]) {
	LEA	EBX,[EBP-28]
	;MOV	ECX,12
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_111 ; else if(is3[TC]) {
_3_113:		; && is3[TC]
	LEA	EBX,[EBP-56]
	;MOV	ECX,12
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_110 ; else if(is3[TC]) {
_3_115:	; is1[TA] = is1[TI] = is1[SA] = 0;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	EBX,8
	ADD	EBX,EAX
	;LEA	ECX,[EBP+8]
	;MOV	EAX,[ECX]
	MOV	ECX,4
	ADD	ECX,EAX
	;LEA	EDX,[EBP+8]
	;MOV	EAX,[EDX]
	MOV	EDX,24
	ADD	EDX,EAX
	XOR	EAX,EAX ; 0
	MOV	[EDX],EAX ; is1[SA] = 0
	MOV	[ECX],EAX ; is1[TI] = 0
	MOV	[EBX],EAX ; is1[TA] = 0
	JMP	_3_116
_3_111:
_3_110:		; else if(is3[TC]) {
	LEA	EBX,[EBP-56]
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_117
_3_118:		; is1[TA] = is2[TA];
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	EBX,8
	LEA	EDX,[EBP-28]
	ADD	EDX,EBX ; +8
	MOV	ECX,[EDX]
	ADD	EBX,EAX
	MOV	[EBX],ECX
		; is1[TI] = is2[TI];
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	MOV	EBX,4
	LEA	EDX,[EBP-28]
	ADD	EDX,EBX ; +4
	MOV	ECX,[EDX]
	ADD	EBX,EAX
	MOV	[EBX],ECX
		; is1[SA] = is2[SA];
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	MOV	EBX,24
	LEA	EDX,[EBP-28]
	ADD	EDX,EBX	; +24
	MOV	ECX,[EDX]
	ADD	EBX,EAX
	MOV	[EBX],ECX
	JMP	short _3_119
_3_117:		; else if((is2[TC])
	LEA	EBX,[EBP-28]
	MOV	ECX,8
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_121
_3_123:		; || (is2[TA] == is3[TA])) {
	LEA	EAX,[EBP-28]
	;MOV	ECX,8
	ADD	EAX,ECX
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-56]
	;MOV	ECX,8
	ADD	EDX,ECX
	MOV	EAX,[EDX]
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_120 ; else
_3_121:
_3_125:		; is1[TA] = is3[TA];
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	ECX,8
	ADD	EBX,ECX
	LEA	EDX,[EBP-56]
	ADD	EDX,ECX ; +8
	MOV	ECX,[EDX]
	MOV	[EBX],ECX
		; is1[TI] = is3[TI];
	;LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	ECX,4
	ADD	EBX,ECX
	LEA	EDX,[EBP-56]
	ADD	EDX,ECX ; +4
	MOV	ECX,[EDX]
	MOV	[EBX],ECX
		; is1[SA] = is3[SA]
	;LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	ECX,24
	ADD	EBX,ECX ; +24
	LEA	EDX,[EBP-56]
	ADD	EDX,ECX
	MOV	ECX,[EDX]
	MOV	[EBX],ECX
	JMP	short _3_126
_3_120:
	; else error("mismatched expressions");
	;MOV	EAX,_3_97+4
	MOV	EAX,_ERR_MEX_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_3_126:
_3_119:
_3_116:		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_97:
_QUEST_: DB "?",0
_COLON_: DB ":",0
_ERR_MEX_: DB "mismatched expressions",0

_level3:	; level3 (is) int is[];
	; {return skim("||", EQ10f, 1, 0, level4, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_127+0
	MOV	EAX,_OROR_
	PUSH	EAX
	MOV	EAX,19
	PUSH	EAX
	;MOV	EAX,1
	MOV	AL,1
	PUSH	EAX
	;XOR	EAX,EAX
	DEC	EAX ; 0
	PUSH	EAX
	MOV	EAX,_level4
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_skim
	;ADD	ESP,24
	;POP	EBP
	;RETN
	JMP	short _level3_@

_3_127: ; DB 124,124,0
_OROR_: DB "||",0

_level4:	; level4 (is) int is[];
	; {return skim("&&", NE10f, 0, 1, level5, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_128+0
	MOV	EAX,_ANDAND_
	PUSH	EAX
	MOV	EAX,54
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	;MOV	EAX,1
	INC	EAX
	PUSH	EAX
	MOV	EAX,_level5
_level3_@:
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_skim
	ADD	ESP,24
	POP	EBP
	RETN

_3_128: ; DB 38,38,0
_ANDAND_: DB "&&",0

_level5:	; level5 (is) int is[];
	; {return down("|", 0, level6, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_129+0
	MOV	EAX,_OR_
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	MOV	EAX,_level6
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	short _level5_@

_3_129: ; DB 124,0
_OR_:	  DB "|",0

_level6:	; level6 (is) int is[];
	; {return down("^", 1, level7, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_130+0
	MOV	EAX,_XOR_
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	MOV	EAX,_level7
_level5_@:
_level6_@:
_level7_@:
_level8_@:
_level9_@:
_level10_@:
_level11_@:
_level12_@:
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down
	ADD	ESP,16
	POP	EBP
	RETN

_3_130: ; DB 94,0
_XOR_:	  DB "^",0

_level7:	; level7 (is) int is[];
	; {return down("&", 2, level8, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_131+0
	MOV	EAX,_AND_
	PUSH	EAX
	MOV	EAX,2
	PUSH	EAX
	MOV	EAX,_level8
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	short _level7_@

_3_131: ; DB 38,0
_amp_:
_AND_:	  DB "&",0

_level8:	; level8 (is) int is[];
	; {return down("== !=", 3, level9, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_132+0
	MOV	EAX,_EQUEQU_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	MOV	EAX,_level9
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	short _level8_@

_3_132: ; DB 61,61,32,33,61,0
_EQUEQU_: DB "== !=",0

_level9:	; level9 (is) int is[];
	; {return down("<= >= < >", 5, level10, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_133+0
	MOV	EAX,_LTEQU_
	PUSH	EAX
	MOV	EAX,5
	PUSH	EAX
	MOV	EAX,_level10
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	short _level9_@

_3_133: ; DB 60,61,32,62,61,32,60,32,62,0
_LTEQU_:  DB "<= >= < >",0

_level10:	; level10(is) int is[];
	; {return down(">> <<", 9, level11, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_134+0
	MOV	EAX,_ASRASL_
	PUSH	EAX
	MOV	EAX,9
	PUSH	EAX
	MOV	EAX,_level11
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	short _level10_@

_3_134: ; DB 62,62,32,60,60,0
_ASRASL_: DB ">> <<",0

_level11:	; level11(is) int is[];
	; {return down("+ -", 11, level12, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_135+0
	MOV	EAX,_PLUSMIN_
	PUSH	EAX
	MOV	EAX,11
	PUSH	EAX
	MOV	EAX,_level12
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	_level11_@

_3_135: ; DB 43,32,45,0
_PLUSMIN_: DB "+ -",0

_level12:	; level12(is) int is[];
	; {return down("* / %", 13, level13, is);}
	PUSH	EBP
	MOV	EBP,ESP
	;MOV	EAX,_3_136+0
	MOV	EAX,_MULDIV_
	PUSH	EAX
	MOV	EAX,13
	PUSH	EAX
	MOV	EAX,_level13
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_down
	;ADD	ESP,16
	;POP	EBP
	;RETN
	JMP	_level12_@

_3_136: ; DB 42,32,47,32,37,0
_MULDIV_: DB "* / %",0

_level13:	; level13(is) int is[]; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int k; char *ptr;
		; if(match("++")) {
	;MOV	EAX,_3_137+0
	MOV	EAX,_PLUSPLUS_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_138 ; else
_3_139:		; if(level13(is) == 0) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_140
_3_146:
_3_141:		; needlval();
	CALL	_needlval
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_140:		; step(rINC1, is, 0);
	MOV	EAX,68
_3_145_@:
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_step
	;ADD	ESP,12
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_138:		; else if(match("--")) {
	;MOV	EAX,_3_137+3
	MOV	EAX,_MINMIN_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_143 ; else
_3_144:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	;JNE	short _3_145
;_3_146:
	;CALL	_needlval
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JE	short _3_146
_3_145:
	MOV	EAX,65
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_step
	;ADD	ESP,12
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_145_@
	
_3_143:		; else if(match("~")) {
	;MOV	EAX,_3_137+6
	MOV	EAX,_TILDE_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_148 ; else
_3_149:		; if(level13(is)) fetch(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_150
_3_151:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_150:		; gen(COM1, 0);
	MOV	EAX,13
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[CV] = ~ is[CV];
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	PUSH	EBX ; *
	ADD	EBX,16
	;LEA	EDX,[EBP+8]
	;MOV	EBX,[EDX]
	;ADD	EBX,16
	MOV	EAX,[EBX]
	NOT	EAX
	MOV	[EBX],EAX
_3_155_@:
_3_160_@:
		; return (is[SA] = 0);
	;LEA	EDX,[EBP+8]
	;MOV	EBX,[EDX]
	POP	EBX ; *
	ADD	EBX,24
	XOR	EAX,EAX
	MOV	[EBX],EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_148:		; else if(match("!")) {
	;MOV	EAX,_3_137+8
	MOV	EAX,_EXCL_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_153 ; else
_3_154:		; if(level13(is)) fetch(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_155
_3_156:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_155:		; gen(LNEG1, 0);
	MOV	EAX,45
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[CV] = ! is[CV];
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	PUSH	EBX ; *
	ADD	EBX,16
	;PUSH	EBX
	MOV	EAX,[EBX]
	CALL	__lneg
	;POP	EBX
	MOV	[EBX],EAX
		; return (is[SA] = 0);
	;;LEA	EDX,[EBP+8]
	;;MOV	EBX,[EDX]
	;POP	EBX ; *
	;ADD	EBX,24
	;XOR	EAX,EAX
	;MOV	[EBX],EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_155_@

_3_153:		; else if(match("-")) {
	;MOV	EAX,_3_137+10
	MOV	EAX,_MINUS_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_158 ; else
_3_159:		; if(level13(is)) fetch(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_160
_3_161:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_160:		; gen(ANEG1, 0);
	MOV	EAX,4
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[CV] = -is[CV];
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	PUSH	EBX ; *
	ADD	EBX,16
	;LEA	EDX,[EBP+8]
	;MOV	EBX,[EDX]
	;ADD	EBX,16
	MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
		; return (is[SA] = 0);
	;;LEA	EDX,[EBP+8]
	;;MOV	EBX,[EDX]
	;POP	EBX ; *
	;ADD	EBX,24
	;XOR	EAX,EAX
	;MOV	[EBX],EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	_3_160_@

_3_158:		; else if(match("*")) {
	;MOV	EAX,_3_137+12
	MOV	EAX,_AST_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_163 ; else
_3_164:		; if(level13(is)) fetch(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_165
_3_166:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_165:		; if(ptr = is[ST]) is[TI] = ptr[TYPE];
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-8] ; ptr
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_167 ; else
_3_168:
	LEA	ECX,[EBP+8]
	MOV	EDX,[ECX]
	ADD	EDX,4	; TI = 1 (1*4)
	;LEA	EBX,[EBP-8]
	MOV	ECX,[EBX]
	;ADD	ECX,1	; TYPE = 1
	INC	ECX
	MOVSX	EAX,BYTE [ECX]
	MOV	[EDX],EAX
	JMP	short _3_169
_3_167:		; else is[TI] = INT;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,4
	MOV	EAX,16 ; INT
	MOV	[EBX],EAX
_3_169:		; is[SA] = is[TA] = is[TC] = 0;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	PUSH	EDX ; *
	MOV	EBX,24	; SA = 2 (6*4)
	ADD	EBX,EDX
	MOV	ECX,8	; TA = 2 (2*4)
	ADD	ECX,EDX
	ADD	EDX,12	; TC = 3 (3*4)
	XOR	EAX,EAX
	MOV	[EDX],EAX ; 0
	MOV	[ECX],EAX ; 0
	MOV	[EBX],EAX ; 0
		; is[CV] = 1;
	;LEA	EAX,[EBP+8]
	;MOV	EBX,[EAX]
	POP	EBX ; *
	ADD	EBX,16
	;MOV	EAX,1
	INC	EAX ; 1
	MOV	[EBX],EAX
	;MOV	EAX,1
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_163:		; else if(amatch("sizeof", 6)) {
	;MOV	EAX,_3_137+14
	MOV	EAX,_sizeof_
	PUSH	EAX
	MOV	EAX,6
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	;JE	short _3_171 ; else
	JNE	short _3_172
	JMP	_3_171
_3_172:		; int sz, p;  char *ptr, sname[NAMESIZE];
	ADD	ESP,-24
		; if(match("(")) p = 1;
		; else           p = 0;
	;MOV	EAX,_3_137+21
	MOV	EAX,_LPR_
	PUSH	EAX
	CALL	_match
	; eax = 0 (false) or eax = 1 (true)
	ADD	ESP,4
	LEA	EBX,[EBP-16] ; p
	;OR	EAX,EAX
	;JE	short _3_173
_3_174:
	;LEA	EBX,[EBP-16]
	;MOV	EAX,1	; p = 1
	;MOV	[EBX],EAX
	;JMP	short _3_175
_3_173:
	;LEA	EBX,[EBP-16]
	;XOR	EAX,EAX	; p = 0
	MOV	[EBX],EAX
_3_175:		; sz = 0;
	LEA	EBX,[EBP-12]
	XOR	EAX,EAX
	MOV	[EBX],EAX
	; if (amatch("unsigned", 8)) sz = INTSIZE;
	;MOV	EAX,_3_137+23
	MOV	EAX,_unsgnd_
	PUSH	EAX
	MOV	EAX,8
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _3_176
_3_177:
	LEA	EBX,[EBP-12]
	MOV	EAX,4	; INTSIZE = 4
	MOV	[EBX],EAX
_3_176:	; if (amatch("int", 3)) sz = INTSIZE;
	;MOV	EAX,_3_137+32
	MOV	EAX,_int_
	PUSH	EAX
	MOV	EAX,3
	PUSH	EAX
	CALL	_amatch
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _3_178 ; else
_3_179:
	LEA	EBX,[EBP-12]
	MOV	EAX,4	; INTSIZE = 4
	MOV	[EBX],EAX
	JMP	short _3_180
_3_178:	
	; else if(amatch("char", 4)) sz = 1;
	;MOV	EAX,_3_137+36
	MOV	EAX,_char_
	PUSH	EAX
	MOV	EAX,4
	PUSH	EAX
	CALL	_amatch
	; eax = 0 (false) or eax = 1 (true)
	ADD	ESP,8
	LEA	EBX,[EBP-12]
	OR	EAX,EAX
	JE	short _3_181
_3_182:
	;LEA	EBX,[EBP-12]
	;MOV	EAX,1
	MOV	[EBX],EAX ; 1 ; sz = 1
	JMP	short _3_184
_3_181:
_3_180:		; if(sz)
	;LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_183 ; else
_3_184:		; if(match("*")) sz = PTRSIZE;
	;MOV	EAX,_3_137+41
	MOV	EAX,_AST_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_185
_3_186:
	LEA	EBX,[EBP-12]
	MOV	EAX,4	; PTRSIZE
	MOV	[EBX],EAX
_3_185:
	JMP	_3_187
_3_183:
		; else if(symname(sname)
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_symname
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_189
_3_193:		; && ((ptr = findloc(sname)) ||
	LEA	EAX,[EBP-32] ; sname
	PUSH	EAX
	CALL	_findloc
	ADD	ESP,4
	LEA	EBX,[EBP-20] ; ptr
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _3_196
_3_194:		; (ptr = findglb(sname)))
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_findglb
	ADD	ESP,4
	LEA	EBX,[EBP-20] ; ptr
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_189
_3_196:		; && ptr[IDENT] != FUNCTION
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]	; IDENT = 0
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,4	; FUNCTION = 4
	CALL	__ne
	OR	EAX,EAX
	JE	short _3_189
_3_197:		; && ptr[IDENT] != LABEL)
	;LEA	EBX,[EBP-20] ; ptr
	;MOV	EAX,[EBX]
	;MOVSX	EBX,BYTE [EAX]
	XOR	EAX,EAX	 ; LABEL = 0
	CALL	__ne
	OR	EAX,EAX
	JE	short _3_189
_3_198:
_3_192:
_3_199:		; sz = getint(ptr+SIZE, INTSIZE);
	LEA	EAX,[EBP-12]
	PUSH	EAX
	LEA	EDX,[EBP-20]
	MOV	EBX,[EDX] ; ptr
	MOV	EAX,3	; + SIZE
	ADD	EBX,EAX
	PUSH	EBX
	;MOV	EAX,4	; INTSIZE
	INC	EAX
	PUSH	EAX
	CALL	_getint
	ADD	ESP,8
	POP	EBX
	MOV	[EBX],EAX
	JMP	short _3_200
_3_189:
_3_188:		; else if(sz == 0) error("must be object or type");
	LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_201
_3_202:
	;MOV	EAX,_3_137+43
	MOV	EAX,_mboot_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_3_201:
_3_200:
_3_187:		; if(p) need(")");
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_203
_3_204:
	;MOV	EAX,_3_137+66
	MOV	EAX,_RPR_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
	POP	EAX
_3_203:		; is[TC] = INT;
	LEA	EAX,[EBP+8]
	MOV	EDX,[EAX]
	MOV	EBX,12
	ADD	EBX,EDX
	;MOV	EAX,16
	MOV	ECX,16
	;MOV	[EBX],EAX
	MOV	[EBX],ECX
		; is[CV] = sz;
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX]
	;MOV	ECX,16
	ADD	ECX,EDX
	LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	MOV	[ECX],EAX
		; is[TA] = is[TI] = is[ST] = 0;
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX]
	MOV	EBX,8	; TA = 2
	ADD	EBX,EDX
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX]
	MOV	ECX,4	; TI = 1, ST = 0
	ADD	ECX,EDX	; ST
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX]
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX ; is(TA) = 0
	MOV	[ECX],EAX ; is(TI) = 0
	MOV	[EDX],EAX ; is(ST) = 0
		; return 0;
	;XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_171:		; else if(match("&")) {
	;MOV	EAX,_3_137+68
	MOV	EAX,_amp_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_206 ; else
_3_207:		; if(level13(is) == 0) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level13
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_208
_3_209:		; error("illegal address")
	;MOV	EAX,_3_137+70
	MOV	EAX,_err_ia_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
_3_211:		; return 0;
	XOR	EAX,EAX ; 0
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_208:		; ptr = is[ST];
	LEA	EAX,[EBP+8] ; is
	MOV	EDX,[EAX]
	MOV	EAX,[EDX] ; ST = 0
	LEA	EBX,[EBP-8] ; ptr
	MOV	[EBX],EAX
		; is[TA] = ptr[TYPE];
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX]
	MOV	EBX,8
	PUSH	EDX ; *
	ADD	EDX,EBX
	;LEA	EBX,[EBP-8]
	;MOV	EAX,[EBX]
	;ADD	EAX,1
	INC	EAX ; ptr[TYPE]
	MOVSX	EBX,BYTE [EAX]
	MOV	[EDX],EBX ; is[TA]
		; if(is[TI]) return 0;
	;LEA	EAX,[EBP+8]
	;MOV	EDX,[EAX]
	POP	EBX ; *
	ADD	EBX,4 ; TI = 1 (1*4)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_211
_3_210:		; gen(POINT1m, ptr);
	MOV	EAX,25
	PUSH	EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[TI] = ptr[TYPE];
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	EAX,4
	PUSH	EAX
	LEA	EAX,[EBP-8]
	MOV	EBX,[EAX]
	;MOV	EAX,1
	;ADD	EBX,EAX
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	POP	EBX
	MOV	[EBX],EAX
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_211
_3_206:		; else {
		; k = level14(is);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level14
	ADD	ESP,4
	LEA	EBX,[EBP-4] ; k
	MOV	[EBX],EAX
		; if(match("++")) {
	;MOV	EAX,_3_137+86
	MOV	EAX,_PLUSPLUS_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_213 ; else
_3_214:		; if(k == 0) {
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_215
_3_221:
_3_216:		; needlval();
	CALL	_needlval
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	_3_211
_3_215:		; step(rINC1, is, rDEC1);
	MOV	EAX,68
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,65
_3_222:
	PUSH	EAX
	CALL	_step
	;ADD	ESP,12
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_213:		; else if(match("--")) {
	;MOV	EAX,_3_137+89
	MOV	EAX,_MINMIN_ 
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_218 ; else
_3_219:		; if(k == 0) {
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_221
	;JMP	short _3_220
;_3_221:	; needlval();
	;CALL	_needlval
		; return 0;
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
_3_220:		; step(rDEC1, is, rINC1);
	MOV	EAX,65
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,68
	;PUSH	EAX
	;CALL	_step
	;ADD	ESP,12
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_222
_3_218:		; else return k;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
_3_217:
_3_212:
_3_205:
_3_170:
_3_162:
_3_157:
_3_152:
_3_147:
_3_142:
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_137:
_PLUSPLUS_: DB "++",0
_MINMIN_:   DB "--",0
_TILDE_:    DB "~",0
_EXCL_:	    DB "!",0
_MINUS_:    DB "-",0
_AST_:      DB "*",0
_sizeof_:   DB "sizeof",0
;_LPR_:	    DB "(",0
_unsgnd_:   DB "unsigned",0
_int_:	    DB "int",0
_char_:	    DB "char",0
;_RPR_:	    DB ")",0
;_amp_:	    DB "&",0
_mboot_:    DB "must be object or type",0
_err_ia_:   DB "illegal address",0

_level14:	; level14(is)  int *is; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-24 ; int k, consta, val;
  			; char *ptr, *before, *start;
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_primary ; k = primary(is);
	ADD	ESP,4
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
		; ptr = is[ST];
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-16]
	MOV	[EBX],EAX
	CALL	_blanks	; blanks();
		; if(ch == '[' || ch == '(') {
	MOV	EBX,[_ch]
	MOV	EAX,91	; "["
	CALL	__eq
	OR	EAX,EAX
	JNE	short _3_225
_3_227:
	;MOV	EBX,[_ch]
	;MOV	EAX,40	; "("
	MOV	AL,40
	CALL	__eq
	OR	EAX,EAX
	JNE	short _3_225
	JMP	_3_224	; else
_3_225:
_3_229:
	ADD	ESP,-28	; int is2[7];
		; null_is (is2);
	LEA	EAX,[EBP-52]
	PUSH	EAX
	CALL	_null_is
	;ADD	ESP,4
	POP	EAX
_3_230:
_3_257:		; while(1) {
_3_272:		; if(match("[")) {
	;MOV	EAX,_3_223+0
	MOV	EAX,_LSQB_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_233
	JMP	_3_232	; else
_3_233:		; if(ptr == 0) {
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_234
_3_235:		; error("can't subscript");
	;MOV	EAX,_3_223+2
	MOV	EAX,_err_cs_
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
	CALL	_skip
	;MOV	EAX,_3_223+18
	MOV	EAX,_RSQB_
	PUSH	EAX
	CALL	_need ; need("]");
	;ADD	ESP,4
	POP	EAX
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_234:		; if(is[TA]) {if(k) fetch(is);}
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,8
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_236
_3_237:
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _3_238
	JZ	short _3_240
_3_239:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
;_3_238:
	JMP	short _3_240
_3_236:	
	; else {error("can't subscript"); k = 0;}
	;MOV	EAX,_3_223+20
	MOV	EAX,_err_cs_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX
_3_240:		; setstage(&before, &start);
	LEA	EAX,[EBP-20]
	PUSH	EAX
	LEA	EAX,[EBP-24]
	PUSH	EAX
	CALL	_setstage
	ADD	ESP,8
		; is2[TC] = 0;
	LEA	EBX,[EBP-52]
	ADD	EBX,12
	XOR	EAX,EAX
	MOV	[EBX],EAX ; 0
		; down2(0, 0, level1, is2, is2);
	;XOR	EAX,EAX
	PUSH	EAX
	;XOR	EAX,EAX
	PUSH	EAX
	MOV	EAX,_level1
	PUSH	EAX
	LEA	EAX,[EBP-52]
	PUSH	EAX
	;LEA	EAX,[EBP-52]
	PUSH	EAX
	CALL	_down2
	ADD	ESP,20
		; need("]");
	;MOV	EAX,_3_223+36
	MOV	EAX,_RSQB_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
	POP	EAX
		; if(is2[TC]) {
	LEA	EBX,[EBP-52]
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _3_241 ; else
	JNE	short _3_242
	JMP	_3_241
_3_242:		; clearstage(before, 0);
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta
	ADD	ESP,8
		; if(is2[CV])
	LEA	EBX,[EBP-52]
	ADD	EBX,16
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _3_243
	JNE	short _3_244
	JMP	_3_243
_3_244:		; if(ptr[TYPE] >> 2 == BPD)
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	;MOV	EBX,1
	;ADD	EAX,EBX
	INC	EAX
	MOVSX	EBX,BYTE [EAX]
	;MOV	ECX,2
	MOV	CL,2
	SAR	EBX,CL
	MOV	EAX,4 ; BDP = 4
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_245 ; else
_3_246:		; gen(GETd2n, is2[CV] << LBPD);
	MOV	EAX,110
	PUSH	EAX
	LEA	EBX,[EBP-52]
	ADD	EBX,16
	MOV	EAX,[EBX]
	;MOV	ECX,2 ; LBPD
	MOV	CL,2
	SAL	EAX,CL
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	;JMP	short _3_247
	JMP	_3_250 ; *
_3_245:		; else if(ptr[TYPE] >> 2 == BPW)
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	;MOV	EBX,1
	;ADD	EAX,EBX
	INC	EAX
	MOVSX	EBX,BYTE [EAX]
	MOV	ECX,2
	SAR	EBX,CL
	;MOV	EAX,2
	MOV	EAX,ECX
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_248 ; else
_3_249:		; gen(GETd2n, is2[CV] << LBPW);
	MOV	EAX,110
	PUSH	EAX
	LEA	EBX,[EBP-52]
	ADD	EBX,16
	MOV	EAX,[EBX]
	;MOV	ECX,1
	;SAL	EAX,CL
	SAL	EAX,1
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	JMP	short _3_250 ; *
_3_248:		; gen(GETd2n, is2[CV]);
	MOV	EAX,110
	PUSH	EAX
	LEA	EBX,[EBP-52]
	ADD	EBX,16
	MOV	EAX,[EBX]
	;
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
;;_3_250:
;_3_247:	; gen(ADD12, 0);
	;MOV	EAX,1
	;PUSH	EAX
	;;XOR	EAX,EAX
	;DEC	EAX ; 0
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
;;_3_243:
	;JMP	short _3_251
	JMP	short _3_250 ; *
_3_241:		; if(ptr[TYPE] >> 2 == BPD) 
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	;MOV	EBX,1
	;ADD	EAX,EBX
	INC	EAX ; PTR[TYPE]
	MOVSX	EBX,BYTE [EAX]
	;MOV	ECX,2
	;SAR	EBX,CL
	SAR	EBX,1
	SAR	EBX,1
	MOV	EAX,4 ; BPD
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_252
_3_253:		; gen(DBL1, 0);
	MOV	EAX,14
	PUSH	EAX ; ++
	;XOR	EAX,EAX
	;PUSH	EAX
	XOR	ECX,ECX ; 0
	PUSH	ECX ; +
	PUSH	EAX
	PUSH	ECX
	CALL	_gen
	ADD	ESP,8
		; gen(DBL1, 0);
	;MOV	EAX,14
	;PUSH	EAX ; ++
	;XOR	EAX,EAX
	;PUSH	EAX ; +
	CALL	_gen
	ADD	ESP,8
	JMP	short _3_254
_3_252:		; else if(ptr[TYPE] >> 2 == BPW)
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	;MOV	EBX,1
	;ADD	EAX,EBX
	INC	EAX
	MOVSX	EBX,BYTE [EAX]
	;MOV	ECX,2
	;SAR	EBX,CL
	SAR	EBX,1
	SAR	EBX,1
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_255
_3_256:		; gen(DBL1, 0);
	MOV	EAX,14
	PUSH	EAX
	XOR	EAX,EAX ; 0
_3_250: ; *
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_255:
_3_254:		; gen(ADD12, 0);
	MOV	EAX,1
	PUSH	EAX
	;XOR	EAX,EAX
	DEC	EAX ; 0
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_251:
_3_243:		; is[TA] = 0;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	MOV	EBX,8 ; TA = 2*4
	ADD	EBX,EDX
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX
		; is[TI] = ptr[TYPE];
	;LEA	EBX,[EBP+8]
	;MOV	EDX,[EBX]
	ADD	EDX,4 ; TI = 1*4
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX]
	;MOV	EAX,1
	;ADD	EBX,EAX
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	MOV	[EDX],EAX
		; k = 1;
	LEA	EBX,[EBP-4]
	MOV	EAX,1
	MOV	[EBX],EAX
	JMP	_3_257	; while
_3_232:		
		; else if(match("(")) {
	;MOV	EAX,_3_223+38
	MOV	EAX,_LPR_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	;JE	short _3_258
	JNE	short _3_259
	JMP	_3_258
_3_259:		; if(ptr == 0) callfunc(0);
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_260 ; else
_3_261:
	XOR	EAX,EAX ; 0
	PUSH	EAX
	CALL	_callfunc
	;ADD	ESP,4
	POP	EAX
	JMP	short _3_262
_3_260:		; else if(ptr[IDENT] != FUNCTION) {
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX] ; ptr[0]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,4 ; FUNCTION = 4, IDENT = 0
	CALL	__ne
	OR	EAX,EAX
	JE	short _3_263 ; else
_3_264:		; if(k && !is[CV]) fetch(is);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX] ; k
	OR	EAX,EAX
	JE	short _3_266
_3_268:
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,16
	MOV	EAX,[EBX] ; is[CV]
	CALL	__lneg
	OR	EAX,EAX
	JE	short _3_266
_3_269:
_3_267:
_3_270:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_266:
_3_265:		; callfunc(0);
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_callfunc
	;ADD	ESP,4
	POP	EAX
	JMP	short _3_271
_3_263:		; callfunc(ptr);
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_callfunc
	;ADD	ESP,4
	POP	EAX
_3_271:
_3_262:	; k = is[ST] = is[TC] = is[CV] = 0;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX] ; ST = 0
	MOV	EBX,12	  ; TC = 3 (3*4)
	ADD	EBX,EDX
	MOV	ECX,16	  ; CV = 4 (4*4)
	ADD	ECX,EDX
	XOR	EAX,EAX	; 0
	MOV	[EBX],EAX ; is[TC] = 0
	MOV	[ECX],EAX ; is[CV] = 0
	MOV	[EDX],EAX ; is[ST] = 0
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX ; k = 0
	JMP	_3_272	  ; while
_3_258:
_3_273:
_3_274:		; else return k;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

;_3_231:
	;ADD	ESP,28
_3_224:	
	; if(ptr && ptr[IDENT] == FUNCTION) {
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX] ; ptr
	OR	EAX,EAX
	JE	short _3_274 ; return k;
_3_276:
	;LEA	EBX,[EBP-16]
	;MOV	EAX,[EBX] ; IDENT = 0
	MOVSX	EBX,BYTE [EAX]  ; ptr[IDENT]
	MOV	EAX,4 ; FUNCTION
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_274 ; return k;
_3_277:
_3_275:
_3_278:		; gen(POINT1m, ptr);
	MOV	EAX,25
	PUSH	EAX
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[ST] = 0;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
		; return 0;
	XOR	EAX,EAX
	MOV	[EBX],EAX
	;XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_223:
_LSQB_:	DB "[",0
_err_cs_:
	DB "can't subscript",0
_RSQB_:	DB "]",0

_primary:	; primary(is)  int *is; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-20
		; char *ptr, sname[NAMESIZE]; int k;
		; if(match("(")) {
	;MOV	EAX,_3_279+0
	MOV	EAX,_LPR_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_280
_3_284:
_3_281:
_3_282:	; do k = level1(is); while(match(","));
	LEA	EAX,[EBP-20]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_level1
	ADD	ESP,4
	POP	EBX
	MOV	[EBX],EAX
	;MOV	EAX,_3_279+2
	MOV	EAX,_COMMA
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_284
_3_283:		; need(")");
	;MOV	EAX,_3_279+4
	MOV	EAX,_RPR_
	PUSH	EAX
	CALL	_need
	;ADD	ESP,4
		; return k;
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_280:		; putint(0, is, 7 << LBPW);
	XOR	EAX,EAX ; 0
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,14	; LBPW = 1
	PUSH	EAX
	CALL	_putint
	ADD	ESP,12
	LEA	EAX,[EBP-16]
	PUSH	EAX
	CALL	_symname
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_286
	JMP	_3_285
_3_286:		; if(ptr = findloc(sname)) {
	LEA	EAX,[EBP-16]
	PUSH	EAX
	CALL	_findloc
	ADD	ESP,4
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _3_288
	JMP	_3_287
_3_288:		; IDENT = 0, LABEL = 0
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	MOVSX	EBX,BYTE [EAX]
	OR	EAX,EAX
	JNE	short _3_289
;_3_290:	; experr();
	;CALL	_experr
;_3_290_@:	; return 0;
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	_3_305 ; experr(); return 0;

_3_289:	; gen(POINT1s, getint(ptr+OFFSET, INTSIZE));
	MOV	EAX,58
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	;;MOV	EBX,5
	;;ADD	EAX,EBX
	;;MOV	EBX,2
	;;ADD	EAX,EBX
	;MOV	EBX,7 ; OFFSET (5+2)
	;ADD	EAX,EBX
	ADD	EAX,7
	PUSH	EAX
	MOV	EAX,4 ; INTSIZE
	PUSH	EAX
	CALL	_getint
	ADD	ESP,8
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[ST] = ptr;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
		; is[TI] = ptr[TYPE];
	ADD	EDX,4
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	INC	EBX
	MOVSX	EAX,BYTE [EBX]
	MOV	[EDX],EAX
		; if(ptr[IDENT] == ARRAY) {
	LEA	EDX,[EBP-4]
	MOV	ECX,[EDX]
	MOVSX	EBX,BYTE [ECX] ; *
	MOV	EAX,2 ; ARRAY
	CALL	__eq
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	OR	EAX,EAX
	JE	short _3_291
_3_292:		; is[TA] = ptr[TYPE];
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	INC	ECX   ; TYPE = 1
	MOVSX	EAX,BYTE [ECX]
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	ADD	EBX,8 ; TA = 2 (2*4)
	MOV	[EBX],EAX
		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
	;JMP	short _3_290_@
_3_291:		; if(ptr[IDENT] == POINTER) {
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	;MOVSX	EBX,BYTE [ECX]
	; ebx = [ecx] ; *
	;MOV	EAX,3 ; POINTER
	MOV	AL,3
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_293
_3_294:		; is[TI] = UINT;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	PUSH	EBX ; *
	ADD	EBX,4  ; is[TI]
	MOV	EAX,17 ; ((INTSIZE << 2) + 1)
	MOV	[EBX],EAX
		; is[TA] = ptr[TYPE];
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	INC	ECX
	MOVSX	EAX,BYTE [ECX]
	POP	EBX ; *
	ADD	EBX,8  ; is[TA]
	MOV	[EBX],EAX
_3_293:		; return 1;
	MOV	EAX,1
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_287:		; if(ptr = findglb(sname)) {
	LEA	EAX,[EBP-16]
	PUSH	EAX
	CALL	_findglb
	ADD	ESP,4
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_295
_3_296:		; is[ST] = ptr;
	LEA	EAX,[EBP+8] ; ST = 0
	MOV	EBX,[EAX]  ; is[0] ; is[ST]
	LEA	EDX,[EBP-4]
	MOV	EAX,[EDX] ; IDENT = 0
	MOV	[EBX],EAX ; ptr[0]
		; if(ptr[IDENT] != FUNCTION) {
	;LEA	EDX,[EBP-4]
	;MOV	EAX,[EDX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,4	; FUNCTION
	CALL	__ne
	OR	EAX,EAX
	JE	short _3_297
_3_298:		; if(ptr[IDENT] == ARRAY) {
	;LEA	EDX,[EBP-4]
	;MOV	EAX,[EDX]
	;MOVSX	EBX,BYTE [EAX]
	;MOV	EAX,2 ; ARRAY
	MOV	AL,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_299
_3_300:		; gen(POINT1m, ptr);
	MOV	EAX,25
	PUSH	EAX
	;LEA	EDX,[EBP-4]
	MOV	EAX,[EDX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; is[TI] = is[TA] = ptr[TYPE];
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	MOV	ECX,4	; TI
	ADD	ECX,EDX
	ADD	EDX,8	; TA
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX] ; ptr[0]
	INC	EBX
	MOVSX	EAX,BYTE [EBX] ; ptr[TYPE]
	MOV	[ECX],EAX ; is[TI]
	MOV	[EDX],EAX ; is[TA]
_3_297:		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_299:		; if(ptr[IDENT] == POINTER)
	;LEA	EDX,[EBP-4]
	;MOV	EAX,[EDX]
	;MOVSX	EBX,BYTE [EAX]
	;MOV	EAX,3 ; POINTER
	MOV	AL,3
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_301
_3_302:		; is[TA] = ptr[TYPE];
	;LEA	EDX,[EBP-4]
	MOV	EBX,[EDX] ; ptr[0]
	INC	EBX	  ; ptr[1]
	MOVSX	EAX,BYTE [EBX] ; ptr[TYPE]
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX] ; is[0]
	ADD	EBX,8	  ; is[TA]
	MOV	[EBX],EAX
_3_301:		; return 1;
	MOV	EAX,1
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_295:	; else is[ST] =
	; addsym(sname, FUNCTION, INT, 0, 0, &glbptr, AUTOEXT);
	LEA	EAX,[EBP-16]
	PUSH	EAX ; sname
	MOV	EAX,4 ; FUNCTION
	PUSH	EAX
	;MOV	EAX,16 ; INT (INTSIZE << 2)
	MOV	AL,16
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	;XOR	EAX,EAX
	PUSH	EAX
	MOV	EAX,_glbptr
	PUSH	EAX
	MOV	EAX,4 ; AUTOEXT
	PUSH	EAX
	;MOV	CL,7
	CALL	_addsym
	ADD	ESP,28
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX] ; is[ST] (ST=0)
	MOV	[EBX],EAX
_3_303:
_3_304:		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_285:		; if(constant(is) == 0) experr();
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_constant
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_304
_3_305:
	CALL	_experr
;_3_304:
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_304

;_3_279: DB 40,0,44,0,41,0

_experr:	; error("invalid expression");
	;PUSH	EBP
	;MOV	EBP,ESP
	;MOV	EAX,_3_306+0
	MOV	EAX,_err_ie_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
		; gen(GETd1n, 0);
	MOV	EAX,108
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	CALL	_skip
	;POP	EBP
	RETN

_3_306:
_err_ie_: DB "invalid expression",0

_callfunc:	; callfunc(ptr) char *ptr; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-12	; int nargs, consta, val;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; nargs = 0;
	CALL	_blanks	; blanks();
_3_308:
_3_316:		; while(streq(lptr, ")") == 0)
	MOV	EAX,[_lptr]
	PUSH	EAX
	;MOV	EAX,_3_307+0
	MOV	EAX,_RPR_
	PUSH	EAX
	CALL	_streq
	ADD	ESP,8
	OR	EAX,EAX
	JNE	short _3_309
_3_310:		; if(endst())
	CALL	_endst
	OR	EAX,EAX
	JNE	short _3_312 ; break;
_3_311:		; if(ptr)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_313 ; else
_3_314:		; expression(&consta, &val);
	LEA	EAX,[EBP-8]
	PUSH	EAX
	LEA	EAX,[EBP-12]
	PUSH	EAX
	CALL	_expressi
	ADD	ESP,8
		; gen(PUSH1, 0);
	MOV	EAX,60
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	JMP	short _3_315
_3_313:		; gen(PUSH1, 0);
	;MOV	EAX,60
	MOV	AL,60
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; expression(&consta, &val);
	LEA	EAX,[EBP-8]
	PUSH	EAX
	LEA	EAX,[EBP-12]
	PUSH	EAX
	CALL	_expressi
	ADD	ESP,8
		; gen(SWAP1s, 0);
	MOV	EAX,71
_3_315:
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
;_3_315:	; nargs = nargs + INTSIZE;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	ADD	EAX,4
	MOV	[EBX],EAX
		; if(match(",") == 0) break;
	;MOV	EAX,_3_307+2
	MOV	EAX,_COMMA
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_317 ; break;
	JMP	_3_316
_3_317:
_3_312:
_3_309:		; need(")");
	;MOV	EAX,_3_307+4
	MOV	EAX,_RPR_
	PUSH	EAX
	CALL	_need
	ADD	ESP,4
		; if(ptr)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _3_319 ; * (ptr = 0)

_3_321:	; if(streq(ptr + NAME, "CCARGC") == 0)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	ADD	EAX,11	; + NAME
	PUSH	EAX
	;MOV	EAX,_3_307+6
	MOV	EAX,_CCARGC_
	PUSH	EAX
	CALL	_streq
	ADD	ESP,8
	;MOV	EBX,EAX
	;XOR	EAX,EAX ; 0
	;CALL	__eq
	;OR	EAX,EAX
	;JZ	short _3_323
	OR	EAX,EAX
	;JNZ	short 
	JNZ	short _3_323 ; (ptr > 0)
_3_320:
		; gen(ARGCNTn, npargs >> LBPD);
	MOV	EAX,5
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ECX,2
	SAR	EAX,CL
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen
	ADD	ESP,8
	JMP	short _3_323
;_3_319:
_3_318:		; if(ptr)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_322
_3_323:		; gen(CALLm, ptr);
	MOV	EAX,9
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	JMP	short _3_324 ; **
_3_319:	; *
_3_322:		; else
		; gen(CALL1, 0);
	;MOV	EAX,8
	MOV	AL,8
	PUSH	EAX
	XOR	EAX,EAX
_3_324: ; **
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
;_3_324:	; gen(ADDSP, csp + nargs);
	MOV	EAX,2
	PUSH	EAX
	;MOV	ECX,[_csp]
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	;ADD	EAX,ECX
	ADD	EAX,[_csp]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_307:
_CCARGC_: DB "CCARGC",0

_fdouble:	; fdouble (oper, is1, is2)
	PUSH	EBP
	MOV	EBP,ESP
		; if ((oper == ADD12 || oper == SUB12)
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	;PUSH	EBX ; *
	MOV	EAX,1
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JNE	short _3_329
_3_333:
	;LEA	EAX,[EBP+16]
	;MOV	EBX,[EAX]
	;MOV	EAX,69
	MOV	AL,69
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_328
_3_329:
_3_335:		; && (is2[TA] == 0))
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;MOV	EBX,8
	;ADD	EAX,EBX
	ADD	EAX,8
	MOV	EBX,[EAX]
	XOR	EAX,EAX
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_328
_3_336:
_3_337:		; switch (is1[TA]>>2)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	;MOV	EAX,8
	;ADD	EBX,EAX
	ADD	EBX,8
	MOV	EAX,[EBX]
	;MOV	ECX,2
	MOV	CL,2
	SAR	EAX,CL
	JMP	short _3_340
_3_339:
;_3_328:
_3_341:
_3_342:		; return (0);
	XOR	EAX,EAX	; char
_3_328:		; eax = 0
	POP	EBP
	RETN
_3_343:		; return (1);
	MOV	EAX,1	; short
	POP	EBP
	RETN
_3_344:		; return (3);
	MOV	EAX,2	; int
	POP	EBP
	RETN
_3_340:
	CALL	__switch

 DD _3_342	; case 1:
 DD 1	; char
 DD _3_343	; case 2:
 DD 2	; short
 DD _3_344	; case 4:
 DD 4	; int
 DD 0

	JMP	short _3_341  ; default

_step:		; step (oper, is, oper2)
	PUSH	EBP
	MOV	EBP,ESP
		; fetch(is);
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
	; gen(oper, is[TA] ? (is[TA] >> 2) : 1);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	;MOV	EAX,8
	;ADD	EBX,EAX
	ADD	EBX,8
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNZ	short _3_348
_3_346:		; 1
	;MOV	EAX,1
	INC	EAX
	JMP	short _3_347
_3_348:		; (is[TA] >> 2)
	;LEA	EAX,[EBP+12]
	;MOV	EBX,[EAX]
	;;MOV	EAX,8
	;;ADD	EBX,EAX
	;ADD	EBX,8
	;MOV	EAX,[EBX]
	;
	;MOV	ECX,2
	;SAR	EAX,CL
	SAR	EAX,1
	SAR	EAX,1
_3_347:
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; store(is);
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_store
	;ADD	ESP,4
	POP	EAX
	; if(oper2) gen(oper2, is[TA] ? (is[TA] >> 2) : 1);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_349
_3_350:
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	PUSH	EAX	; oper2
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	;MOV	EAX,8
	;ADD	EBX,EAX
	ADD	EBX,8
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_353
_3_351:		; 1
	;MOV	EAX,1
	INC	EAX
	JMP	short _3_352
_3_353:		; (is[TA] >> 2)
	;LEA	EAX,[EBP+12]
	;MOV	EBX,[EAX]
	;;MOV	EAX,8
	;;ADD	EBX,EAX
	;ADD	EBX,8
	;MOV	EAX,[EBX]
	;
	;MOV	ECX,2
	;SAR	EAX,CL
	SAR	EAX,1
	SAR	EAX,1
_3_352:
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_349:
	POP	EBP
	RETN

_store:		; store(is)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; char *ptr;
		; if(is[TI])
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,4
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_355 ; else
_3_356:		; if(is[TI] >> 2 == 1)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;;MOV	EBX,4
	;;ADD	EAX,EBX
	;ADD	EAX,4
	;MOV	EBX,[EAX]
	MOV	EBX,EAX ; is[TI]
	;
	;MOV	ECX,2
	MOV	CL,2
	SAR	EBX,CL
	MOV	EAX,1
	;PUSH	EBX ; *
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JE	short _3_357 ; else
_3_358:		; gen(PUTbp1, 0);
	;MOV	EAX,62
	MOV	AL,62
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;;JMP	short _3_359
	;JMP	short _3_363
	JMP	short _3_362 ; *
_3_357:		; else if(is[TI] >> 2 == 2)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;;MOV	EBX,4
	;;ADD	EAX,EBX
	;ADD	EAX,4
	;MOV	EBX,[EAX]
	;;MOV	ECX,2
	;MOV	CL,2
	;SAR	EBX,CL
	; ebx = (is[TI] >> 2)
	;MOV	EAX,2
	MOV	AL,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_360 ; else
_3_361:		; gen(PUTwp1, 0);
	;MOV	EAX,64
	MOV	AL,64
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;;JMP	short _3_362
	;JMP	short _3_363
	JMP	short _3_362 ; *
_3_360:		; gen(PUTdp1, 0);
	;MOV	EAX,115
	MOV	AL,115
_3_362:	; *
	PUSH	EAX
	XOR	EAX,EAX
	; **
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
;_3_362:
_3_359:
	;JMP	short _3_363
	JMP	short _3_365 ; **
_3_355:	; else
		; ptr = is[ST];
	LEA	EBX,[EBP-4]
	LEA	EAX,[EBP+8]
	MOV	EDX,[EAX]
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
		; if(ptr[IDENT] == POINTER)
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,3
	CALL	__eq
	OR	EAX,EAX
	;JE	short _3_364
	JNE	short _3_370
;_3_365:
	;MOV	EAX,114
	;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_366
_3_364:		; else if (ptr[TYPE] >> 2 == 1)
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	;MOV	EBX,1
	;ADD	EAX,EBX
	INC	EAX
	MOVSX	EBX,BYTE [EAX]
	;MOV	ECX,2
	MOV	CL,2
	SAR	EBX,CL
	MOV	EAX,1
	;PUSH	EBX ; *
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JE	short _3_367
_3_368:		; gen(PUTbm1, ptr);
	MOV	EAX,61
	;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_369
	JMP	short _3_372 ; *
_3_367:		; else if (ptr[TYPE] >> 2 == BPW)
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;;MOV	EBX,1
	;;ADD	EAX,EBX
	;INC	EAX
	;MOVSX	EBX,BYTE [EAX]
	;;MOV	ECX,2
	;MOV	CL,2
	;SAR	EBX,CL
	; ebx = (ptr[TYPE] >> 2)
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_370 ; else
_3_371:
	MOV	EAX,63
	;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	;JMP	short _3_372
	JMP	short _3_372 ; *
_3_370:		; gen(PUTdm1, ptr);
	MOV	EAX,114
_3_372: ; *
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
_3_365: ; **
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
;_3_372:
_3_369:
_3_366:
_3_363:
	MOV	ESP,EBP
	POP	EBP
	RETN

_fetch:		; fetch(is)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; char *ptr;
		; ptr = is[ST];
	LEA	EBX,[EBP-4]
	LEA	ECX,[EBP+8]
	MOV	EDX,[ECX]
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
		; if(is[TI])
	;LEA	ECX,[EBP+8]
	;MOV	EDX,[ECX]
	ADD	EDX,4
	MOV	EAX,[EDX]
	OR	EAX,EAX
	JE	short _3_374 ; else
_3_375:		; if(is[TI] >> 2 == BPD)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;;MOV	EBX,4
	;;ADD	EAX,EBX
	;ADD	EAX,4
	;MOV	EBX,[EAX]
	MOV	EBX,EAX ; is[TI]
	;;MOV	ECX,2
	;MOV	CL,2
	;SAR	EBX,CL
	SAR	EBX,1
	SAR	EBX,1
	;PUSH	EBX ; *
	MOV	EAX,4
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JE	short _3_376
_3_377:		; gen(GETd1p, 0);
	;MOV	EAX,109
	MOV	AL,109
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_378
	JMP	short _3_378 ; *
_3_376:		; else if(is[TI] >> 2 == BPW)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;;MOV	EBX,4
	;;ADD	EAX,EBX
	;ADD	EAX,4
	;MOV	EBX,[EAX]
	;;MOV	ECX,2
	;MOV	CL,2
	;SAR	EBX,CL
	; ebx = (is[TI] >> 2)
	;MOV	EAX,2
	MOV	AL,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_379 ; else
_3_380:		; gen(GETw1p, 0);
	;MOV	EAX,32
	MOV	AL,2
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_381
	JMP	short _3_378 ; *
_3_379:		; if(ptr[TYPE] & UNSIGNED)
	LEA	ECX,[EBP-4]
	MOV	EBX,[ECX]
	;MOV	EAX,1
	;ADD	EBX,EAX
	INC	EBX
	;MOVSX	EAX,BYTE [EBX]
	MOV	AL,[EBX]
	;;MOV	EBX,1
	;;AND	EAX,EBX
	;AND	EAX,1  ; UNSIGNED
	AND	AL,1
	;OR	EAX,EAX
	JZ	short _3_382 ; else
_3_383:		; gen(GETb1pu, 0);
	;MOV	EAX,29
	MOV	AL,29
	;PUSH	EAX
	;XOR	EAX,EAX
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_384
	JMP	short _3_378 ; *
_3_382:		; gen(GETb1p, 0);
	;MOV	EAX,28
	MOV	AL,28
_3_378: ; *
	PUSH	EAX
	XOR	EAX,EAX
	; **
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
_3_384:
_3_381:
;_3_378:
	;JMP	short _3_385
	JMP	short _3_385 ; **
_3_374: ; else
		; if(ptr[IDENT] == POINTER)
	LEA	EDX,[EBP-4]
	MOV	ECX,[EDX]
	MOVSX	EBX,BYTE [ECX]
	MOV	EAX,3  ; POINTER
	;PUSH	EBX ; *
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JE	short _3_386 ; else
_3_387:		; gen(GETd1m, ptr);
	;MOV	EAX,107
	MOV	AL,107
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	JMP	short _3_388
_3_386:		; else if (ptr[TYPE] >> 2 == BPD)
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	;ADD	ECX,1
	INC	ECX
	MOVSX	EBX,BYTE [ECX]
	; ebx = ptr[TYPE]
	;;MOV	ECX,2
	;MOV	CL,2
	;SAR	EBX,CL
	SAR	EBX,1
	SAR	EBX,1
	MOV	EAX,4
	;PUSH	EBX ; *
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JE	short _3_389 ; else
_3_390:		; gen(GETd1m, ptr);
	;MOV	EAX,107
	MOV	AL,107
	;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_391
	JMP	short _3_394 ; *
_3_389:		; else if (ptr[TYPE] >> 2 == BPW)
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	;ADD	ECX,1
	;INC	ECX
	;MOVSX	EBX,BYTE [ECX]
	; ebx = ptr[TYPE]
	;;MOV	ECX,2
	;MOV	CL,2
	;;SAR	EBX,CL
	;SAR	EBX,1
	;SAR	EBX,1
	; ebx = (ptr[TYPE] >> 2))
	;MOV	EAX,2
	MOV	AL,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_392 ; else
_3_393:		; gen(GETw1m, ptr);
	;MOV	EAX,30
	MOV	AL,30
	;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_397
	JMP	short _3_394 ; *
_3_392:		; if(ptr[TYPE] & UNSIGNED)
	;LEA	EDX,[EBP-4]
	;MOV	ECX,[EDX]
	;ADD	ECX,1
	;INC	ECX
	;MOVSX	EAX,BYTE [ECX]
	MOV	AL,[ECX] ; PTR[TYPE]
	AND	AL,1	; UNSIGNED
	;OR	EAX,EAX
	JE	short _3_395 ; else
_3_396:		; gen(GETb1mu, ptr);
	;MOV	EAX,27
	MOV	AL,27
	;PUSH	EAX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;;ADD	ESP,8
	;JMP	short _3_397
	JMP	short _3_394 ; *
_3_395:		; gen(GETb1m, ptr);
	;MOV	EAX,26
	MOV	AL,26
_3_394: ; *
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
_3_385: ; **
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
_3_397:
_3_391:
_3_388:
;_3_385:
	MOV	ESP,EBP
	POP	EBP
	RETN

_constant:	; constant(is)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int offset;
		; if (is[TC] = number(is + CV))
	LEA	EBX,[EBP+8]
	MOV	ECX,[EBX]
	MOV	EAX,12 ; TC
	ADD	EAX,ECX
	PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	ECX,[EBX]
	;MOV	EAX,16 ; CV
	;ADD	EAX,ECX
	ADD	EAX,4
	PUSH	EAX
	CALL	_number
	ADD	ESP,4
	POP	EBX
	MOV	[EBX],EAX
	OR	EAX,EAX
;	JE	short _3_399
	JNE	short _3_403
;_3_400:		; gen(GETd1n, is[CV]);
;	MOV	EAX,108
;	PUSH	EAX
;	LEA	EAX,[EBP+8]
;	MOV	EBX,[EAX]
;	;MOV	EAX,16
;	;ADD	EBX,EAX
;	ADD	EBX,16
;	;MOV	EAX,[EBX]
;	;PUSH	EAX
;	;CALL	_gen
;	;;ADD	ESP,8
;	;JMP	short _3_401
;	JMP	short _3_407 ; *

_3_399:		; else if(is[TC] = chrcon(is + CV))
	LEA	EBX,[EBP+8]
	MOV	ECX,[EBX]
	MOV	EAX,12
	ADD	EAX,ECX
	PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	ECX,[EBX]
	MOV	EAX,16
	ADD	EAX,ECX
	PUSH	EAX
	CALL	_chrcon
	ADD	ESP,4
	POP	EBX
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_402
_3_403:		; gen(GETd1n, is[CV]);
	MOV	EAX,108
	PUSH	EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	;MOV	EAX,16
	;ADD	EBX,EAX
	ADD	EBX,16
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	;JMP	short _3_404
	JMP	short _3_407 ; *
_3_402:		; else if(string(&offset))
	LEA	EAX,[EBP-4]
	PUSH	EAX
	CALL	_string
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _3_405 ; else
_3_406:		; gen(POINT1l, offset);
	MOV	EAX,24
	PUSH	EAX
	LEA	EBX,[EBP-4]
_3_407: ; *
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	;JMP	short _3_407
	;JMP	short _3_401
;_3_405:
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
;_3_407:
_3_404:
_3_401:		; return 1;
	MOV	EAX,1
_3_405:		; return 0;
	MOV	ESP,EBP
	POP	EBP
	RETN

_number:	; number(value) int *value; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int k, minus;
		; k = minus = 0;
	LEA	EBX,[EBP-4]
	LEA	EDX,[EBP-8]
	XOR	EAX,EAX ; 0
	MOV	[EDX],EAX ; minus = 0
	MOV	[EBX],EAX ; k = 0
_3_409:
_3_412:
_3_413:
_3_416:	; while(1) {
		; if(match("+")) ;
	;MOV	EAX,_3_408+0
	MOV	EAX,_plus_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_412
_3_411:		; else if(match("-")) minus = 1;
	;MOV	EAX,_3_408+2
	MOV	EAX,_minus_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_414 ; else break;
_3_415:
	LEA	EBX,[EBP-8]
	MOV	EAX,1
	MOV	[EBX],EAX
	JMP	short _3_416
_3_414:
_3_410:		; if(isdigit(ch) == 0) return 0;
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_417
_3_418:		; return 0;
	;XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_417:		; if(ch == '0') {
	MOV	EBX,[_ch]
	MOV	EAX,48 ; '0'
	CALL	__eq
	OR	EAX,EAX
	;JE	short _3_419
	JNE	short _3_420
	JMp	_3_419 
_3_420:
_3_421:		; while(ch == '0') inbyte();
	;MOV	EBX,[_ch]
	MOV	EAX,48 ; '0'
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_422
_3_423:
	CALL	_inbyte
	JMP	short _3_421 ; while
_3_422:		; if(toupper(ch) == 'X') {
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	MOV	EBX,EAX
	MOV	EAX,88 ; 'X'
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_424
_3_425:
	CALL	_inbyte	; inbyte();
_3_426:
_3_431:		; while(isxdigit(ch)) {
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_isxdigit
	ADD	ESP,4
	OR	EAX,EAX
	;JE	short _3_427
	JNE	short _3_428
	JMP	_3_427
_3_428:		; if(isdigit(ch))
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_429
_3_430:		; k = k*16 + (inbyte() - '0');
	LEA	EAX,[EBP-4]
	PUSH	EAX
	;LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,16
	IMUL	EBX
	PUSH	EAX
	CALL	_inbyte
	;MOV	EBX,48
	;SUB	EAX,EBX
	SUB	EAX,48 ; '0'
	POP	EBX
	ADD	EAX,EBX
	POP	EBX
	MOV	[EBX],EAX
	JMP	short _3_431
_3_429: ; else 
	; k = k*16 + 10 + (toupper(inbyte()) - 'A');
	LEA	EAX,[EBP-4]
	PUSH	EAX
	;LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,16
	IMUL	EBX
	;MOV	EBX,10
	;ADD	EAX,EBX
	ADD	EAX,10
	PUSH	EAX
	CALL	_inbyte
	PUSH	EAX
	CALL	_toupper
	;ADD	ESP,4
	POP	EBX
	;MOV	EBX,65
	;SUB	EAX,EBX
	SUB	EAX,65	; 'A'
	POP	EBX
	ADD	EAX,EBX
	POP	EBX
	MOV	[EBX],EAX
	JMP	short _3_426
_3_424:
_3_433:	; else while (ch >= '0' && ch <= '7')
	MOV	EBX,[_ch]
	MOV	EAX,48 ; '0'
	CALL	__ge
	OR	EAX,EAX
	JE	short _3_435
_3_437:
	;MOV	EBX,[_ch]
	MOV	EAX,55 ; '7'
	CALL	__le
	OR	EAX,EAX
	JE	short _3_435
_3_438:
_3_436:
_3_439:		; k = k*8 + (inbyte() - '0');
	LEA	EAX,[EBP-4]
	PUSH	EAX
	;LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,8
	IMUL	EBX
	PUSH	EAX
	CALL	_inbyte
	;MOV	EBX,48
	;SUB	EAX,EBX
	SUB	EAX,48
	POP	EBX
	ADD	EAX,EBX
	POP	EBX
	MOV	[EBX],EAX
	JMP	short _3_433
_3_419:
_3_441:	; else while (isdigit(ch))
	;	k = k*10 + (inbyte() - '0');
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_442
_3_443:
	LEA	EAX,[EBP-4]
	PUSH	EAX
	;LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,10
	IMUL	EBX
	PUSH	EAX
	CALL	_inbyte
	;MOV	EBX,48
	;SUB	EAX,EBX
	SUB	EAX,48
	POP	EBX
	ADD	EAX,EBX
	POP	EBX
	MOV	[EBX],EAX
	JMP	short _3_441
_3_427:
_3_435:
_3_442:
_3_434:
_3_432:
_3_440:		; if(minus) {
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_444
_3_445:		; *value = -k;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-4]
	MOV	EAX,[EDX]
	NEG	EAX
	MOV	[EBX],EAX
	;MOV	EAX,16
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_446
_3_444:	; if((*value = k) < 0) return (UINT);
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-4]
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JL	short _3_447
_3_446:		; return (INT);
	MOV	EAX,16
_3_448:
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_447:		; return (UINT);
	MOV	EAX,17
	JMP	short _3_448

_3_408:
_plus_:	 DB "+",0 ; 43
_minus_: DB "-",0 ; 45

_chrcon:	; chrcon(value)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
		; if(match("'") == 0)
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX
	;MOV	EAX,_3_449+0
	MOV	EAX,_SQ_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_450
_3_451:		; return 0;
	;XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_450:
_3_452:		; while(ch != '\'')
	MOV	EBX,[_ch]
	MOV	EAX,39	; '
	CALL	__ne
	OR	EAX,EAX
	JE	short _3_453
_3_454:		; k = (k << 8) + (litchar() & 255);
	LEA	EAX,[EBP-4]
	PUSH	EAX ; **
	MOV	EBX,[EAX]
	;MOV	ECX,8
	MOV	CL,8
	SAL	EBX,CL
	PUSH	EBX ; *
	CALL	_litchar
	AND	EAX,255
	POP	EBX ; *
	ADD	EAX,EBX
	POP	EBX ; **
	MOV	[EBX],EAX
	JMP	short _3_452 ; while
_3_453:
	CALL	_gch ; gch();
		; *value = k;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-4]
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
		; return (INT);
	MOV	EAX,16
	MOV	ESP,EBP
	POP	EBP
	RETN

_3_449:
_SQ_:	DB 39,0	; single quote (')

_string:	; string(offset) int *offset; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4 ; char c;
		; if(match(quote) == 0) return 0;
	MOV	EAX,_quote
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_456
_3_457:		; return 0;
	;XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_456:		; *offset = litptr;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[_litptr]
	MOV	[EBX],EAX
_3_458:		; while (ch != '"') {
	MOV	EBX,[_ch]
	MOV	EAX,34 ; "
	CALL	__ne
	OR	EAX,EAX
	JE	short _3_459
_3_460:		; if(ch == 0) break;
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JE	short _3_462
_3_461:		; stowlit(litchar(), 1);
	CALL	_litchar
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_stowlit
	ADD	ESP,8
	JMP	short _3_458 ; while
_3_462:
_3_459:
	CALL	_gch ; gch();
		; litq[litptr++] = 0;
	MOV	EBX,[_litq]
	MOV	EAX,[_litptr]
	INC	DWORD [_litptr]
	ADD	EBX,EAX
	XOR	EAX,EAX ; 0
	MOV	[EBX],AL
		; return 1;
	;MOV	EAX,1
	INC	EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_457

_stowlit: ; stowlit(value, size) int value, size; {
	PUSH	EBP
	MOV	EBP,ESP
		; if((litptr+size) >= LITMAX) {
	;MOV	EAX,[_litptr]
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	;ADD	EBX,EAX
	ADD	EBX,[_litptr]
	MOV	EAX,2999 ; LITMAX
	CALL	__ge
	OR	EAX,EAX
	JE	short _3_464
_3_465:		; error("literal queue overflow");
	;MOV	EAX,_3_463+0
	MOV	EAX,_lqof_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
		; exit(ERRCODE);
	MOV	EAX,7
	PUSH	EAX
	CALL	_OS_exit
	;ADD	ESP,4
	POP	EAX
_3_464:		; putint(value, litq+litptr, size);
	LEA	EBX,[EBP+12] ; value
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	ECX,[_litq]
	MOV	EAX,[_litptr]
	;ADD	EAX,ECX
	ADD	EAX,[_litq]
	PUSH	EAX
	LEA	EBX,[EBP+8] ; size
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_putint
	ADD	ESP,12
	;MOV	ECX,[_litptr]
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;ADD	EAX,ECX
	ADD	EAX,[_litptr]
	MOV	DWORD [_litptr],EAX
	POP	EBP
	RETN

_3_463:
_lqof_: DB "literal queue overflow",0

_litchar:	; litchar() {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int i, oct;
	; if(ch != '\\' || nch == 0) return gch();
	MOV	EBX,[_ch]
	MOV	EAX,92
	CALL	__ne
	OR	EAX,EAX
	JNE	short _3_468
_3_470:
	MOV	EBX,[_nch]
	XOR	EAX,EAX
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_471
_3_468:
_3_472:		; return gch();
	CALL	_gch
_3_473:
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_476:		; case 'n': gch(); return NEWLINE;
	CALL	_gch
	MOV	EAX,10
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_473
_3_477:		; /* TRDOS 386 v2 - 22/02/2026 */
    		; case 'r': qch(): return 13;  /* CR */
	CALL	_gch
	MOV	EAX,13
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_473
_3_478:		; case 't': gch(); return  9;  /* HT */
	CALL	_gch
	MOV	EAX,9
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_473
_3_479:		; case 'b': gch(); return  8;  /* BS */
	CALL	_gch
	MOV	EAX,8
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_473
_3_480:		; case 'f': gch(); return 12;  /* FF */
	CALL	_gch
	MOV	EAX,12
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_473

_3_471:
_3_469:
_3_467:		; gch();
	CALL	_gch
		; switch(ch) {
	MOV	EAX,[_ch]
_3_475:
	CALL	__switch

 DD _3_476
 DD 110		; 'n'
 DD _3_477
 DD 114		; 'r'
 DD _3_478
 DD 116		; 't'
 DD _3_479
 DD 98		; 'b'
 DD _3_480
 DD 102		; 'f'
 DD 0

_3_474:		; default
	LEA	EBX,[EBP-4]
	MOV	EAX,3
	MOV	[EBX],EAX ; i = 3;
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; oct = 0;
_3_481:	; while((i--) > 0 && ch >= '0' && ch <= '7')
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	DEC	DWORD [EAX]
	XOR	EAX,EAX
	CALL	__gt
	OR	EAX,EAX
	JE	short _3_483
_3_485:
	MOV	EBX,[_ch]
	MOV	EAX,48	; '0'
	CALL	__ge
	OR	EAX,EAX
	JE	short _3_483
_3_486:
	;MOV	EBX,[_ch]
	MOV	EAX,55	; '7'
	CALL	__le
	OR	EAX,EAX
	JE	short _3_483
_3_487:
_3_484:
_3_488:		; oct = (oct << 3) + gch() - '0';
	LEA	EAX,[EBP-8]
	PUSH	EAX
	;LEA	EAX,[EBP-8]
	MOV	EBX,[EAX]
	;MOV	ECX,3
	MOV	CL,3
	SAL	EBX,CL
	PUSH	EBX
	CALL	_gch
	POP	EBX
	ADD	EAX,EBX
	;MOV	EBX,48
	;SUB	EAX,EBX
	SUB	EAX,48	; '0'
	POP	EBX
	MOV	[EBX],EAX
	JMP	short _3_481
_3_483:
_3_482:		; if(i == 2) return gch();
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_489
_3_490:
	CALL	_gch
_3_491:
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_489:		; else return oct;
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _3_491

_skim:	; skim(opstr, tcode, dropval, endval, level, is)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-12	; int k, droplab, endlab;
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; droplab = 0;
_3_502:
_3_499:
_3_493:		; while(1) {
		; k = down1(level, is);
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
		; if(nextop(opstr)) {
	LEA	EBX,[EBP+28]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_nextop
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_495
_3_496:
	MOV	EAX,[_opsize]
	PUSH	EAX
	CALL	_bump ; bump(opsize);
	;ADD	ESP,4
	POP	EAX
		; if(droplab == 0) droplab = getlabel();
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_497
_3_498:
	LEA	EAX,[EBP-8]
	PUSH	EAX
	CALL	_getlabel
	POP	EBX
	MOV	[EBX],EAX
_3_497:		; dropout(k, tcode, droplab, is);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_dropout
	ADD	ESP,16
	JMP	short _3_499 ; while
_3_495:		; else if(droplab) {
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _3_500
	JNZ	short _3_501
_3_500:		; else return k;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
_3_494:
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_501:		; dropout(k, tcode, droplab, is);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_dropout
	ADD	ESP,16
		; gen(GETd1n, endval);
	MOV	EAX,108
	PUSH	EAX
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(JMPm, endlab = getlabel());
	MOV	EAX,40
	PUSH	EAX
	LEA	EAX,[EBP-12]
	PUSH	EAX
	CALL	_getlabel
	POP	EBX
	MOV	[EBX],EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(LABm, droplab);
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(GETd1n, dropval);
	MOV	EAX,108
	PUSH	EAX
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(LABm, endlab);
	MOV	EAX,41
	PUSH	EAX
	LEA	EBX,[EBP-12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
	; is[TI] = is[TA] = is[TC] = is[CV] = is[SA] = 0;
	LEA	EBX,[EBP+8]
	MOV	EDX,[EBX]
	XOR	EAX,EAX ; 0
	MOV	EBX,4	; TI = 1 * INTSIZE (=4)
	ADD	EBX,EDX
	MOV	[EBX],EAX
	MOV	EBX,8	; TA = 2 * INTSIZE (=4)
	ADD	EBX,EDX
	MOV	[EBX],EAX ; 0
	MOV	EBX,12	; TC = 3 * INTSIZE (=4)
	ADD	EBX,EDX
	MOV	[EBX],EAX
	MOV	EBX,16	; CV = 4 * INTSIZE (=4)
	ADD	EBX,EDX
	MOV	[EBX],EAX ; 0
	MOV	EBX,24	; SA = 6 * INTSIZE (=4)
	ADD	EBX,EDX
	MOV	[EBX],EAX ; 0
	;XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_dropout: ; dropout(k, tcode, exit1, is)
		; int k, tcode, exit1, is[]; {
	PUSH	EBP
	MOV	EBP,ESP
		; if(k) fetch(is);
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_504
_3_505:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
	JMP	short _3_506
_3_504:		; else if(is[TC])
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	;MOV	EAX,12
	;ADD	EBX,EAX
	ADD	EBX,12
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_507
_3_508:		; gen(GETd1n, is[CV]);
	MOV	EAX,108
	PUSH	EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	;MOV	EAX,16
	;ADD	EBX,EAX
	ADD	EBX,16
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_507:
_3_506:		; gen(tcode, exit1);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_gen
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_down:		; down(opstr, opoff, level, is)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
		; k = down1(level, is);
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
		; if(nextop(opstr) == 0) return k;
	LEA	EBX,[EBP-4] ; k
	MOV	[EBX],EAX
	PUSH	EBX ; *
	LEA	EBX,[EBP+20] ; opstr
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_nextop
	ADD	ESP,4
	POP	EBX ; *
	OR	EAX,EAX
	JNE	short _3_510
_3_511:		; return k;
	;LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_3_510:		; f(k) fetch(is);
	;LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_512
_3_513:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_512:
_3_514:
_3_518:	; while(1) {
		; if(nextop(opstr)) {
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_nextop
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_516 ; else
_3_517:
	ADD	ESP,-28 ; int is2[7];
		; null_is (is2);
	LEA	EAX,[EBP-32]
	PUSH	EAX
	CALL	_null_is
	;ADD	ESP,4
	POP	EAX
		; bump(opsize);
	MOV	EAX,[_opsize]
	PUSH	EAX
	CALL	_bump
	ADD	ESP,4
		; opindex += opoff;
	MOV	EAX,[_opindex]
	LEA	EBX,[EBP+16]
	MOV	ECX,[EBX]
	ADD	EAX,ECX
	MOV	DWORD [_opindex],EAX
		; down2(op[opindex], op2[opindex],
		;	level, is, is2);
	MOV	EBX,_op
	MOV	ECX,[_opindex]
	SHL	ECX,1
	SHL	ECX,1
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EBX,_op2
	;MOV	ECX,[_opindex]
	;SHL	ECX,1
	;SHL	ECX,1
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12] ; level
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8] ; is
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EAX,[EBP-32] ; is2[0]
	PUSH	EAX
	CALL	_down2
	;ADD	ESP,20
	;ADD	ESP,28
	ADD	ESP,48
	JMP	short _3_518 ; while
_3_516:		; else return 0;
	;XOR	EAX,EAX ; eax = 0
_3_515:
	MOV	ESP,EBP
	POP	EBP
	RETN

_down1:
	; down1(level, is) int (*level)(), is[]; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-12	; int k, *before, *start;
	LEA	EAX,[EBP-8]
	PUSH	EAX
	LEA	EAX,[EBP-12]
	PUSH	EAX
	CALL	_setstage ; setstage(&before, &start);
	ADD	ESP,8
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX] ; *level
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX] ; is
	PUSH	EBX
	CALL	EAX	; (*level)(is)
	ADD	ESP,4
	LEA	EBX,[EBP-4] ; k
	MOV	[EBX],EAX ; k = (*level)(is);
		; if(is[TC])
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX] ; is
	;MOV	EAX,12
	;ADD	EBX,EAX
	ADD	EBX,12	; TC = 3 (3*4)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_520
_3_521:
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX] ; before
	PUSH	EAX
	XOR	EAX,EAX ; 0
	PUSH	EAX
	CALL	_clearsta ; clearstage(before, 0);
	ADD	ESP,8
_3_520:
	LEA	EBX,[EBP-4] ; return k;
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

_down2:		; down2(oper, oper2, level, is, is2)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-16	; int *before, *start;
			; char *ptr; int value;
	; setstage(&before, &start);
	LEA	EAX,[EBP-4]
	PUSH	EAX
	LEA	EAX,[EBP-8]
	PUSH	EAX
	CALL	_setstage
	ADD	ESP,8
		; is[SA] = 0;
	LEA	EBX,[EBP+12] ; is[]
	MOV	ECX,[EBX]
	MOV	EBX,24 ; SA
	ADD	EBX,ECX
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX
		; if(is[TC]) {
	;LEA	EBX,[EBP+12]
	;MOV	ECX,[EBX]
	MOV	EBX,12
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_523 ; else
_3_524:		; if(down1(level, is2)) fetch(is2);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _3_525
_3_526:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	;ADD	ESP,4
	POP	EAX
_3_525:		; if(is[CV] == 0) is[SA] = snext;
	LEA	EBX,[EBP+12]
	MOV	ECX,[EBX]
	MOV	EDX,16
	ADD	EDX,ECX
	MOV	EAX,[EDX]
	OR	EAX,EAX
	JNE	short _3_527
_3_528:
	;LEA	EBX,[EBP+12]
	;MOV	ECX,[EBX]
	MOV	EBX,24
	ADD	EBX,ECX
	MOV	EAX,[_snext]
	MOV	[EBX],EAX
_3_527:	; gen(GETw2n, is[CV] << fdouble(oper, is2, is));
	MOV	EAX,33
	PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	ECX,[EBX]
	;MOV	EDX,16
	;ADD	EDX,ECX
	MOV	EAX,[EDX]
	PUSH	EAX ; *
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	ECX,[EBX]
	PUSH	ECX
	CALL	_fdouble
	ADD	ESP,12
	MOV	ECX,EAX
	POP	EAX ; * ; is[CV]
	SAL	EAX,CL
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
	JMP	_3_529 ; *
_3_523:	; else {
	 	; gen(PUSH1, 0);
	;MOV	EAX,60
	MOV	AL,60
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; if(down1(level, is2)) fetch(is2);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_down1
	ADD	ESP,8
	OR	EAX,EAX
	JE	short _3_530
_3_531:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fetch
	ADD	ESP,4
_3_530:		; if(is2[TC]) {
	LEA	EAX,[EBP+8]
	MOV	ECX,[EAX]
	MOV	EBX,12
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JE	short _3_532 ; else
	JNE	short _3_533
	JMP	_3_532
_3_533:		; if(is2[CV] == 0) is[SA] = start;
	;LEA	EBX,[EBP+8]
	;MOV	ECX,[EBX]
	MOV	EBX,16
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_534
_3_535:
	LEA	EBX,[EBP+12] ; is[]
	MOV	EDX,[EBX]
	ADD	EDX,24
	LEA	EBX,[EBP-8] ; start
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
_3_534:		; csp += BPD;
	MOV	EAX,[_csp]
	ADD	EAX,4
	MOV	DWORD [_csp],EAX
		; clearstage(before, 0);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta
	ADD	ESP,8
		; f(oper == ADD12) {
	LEA	EDX,[EBP+24]
	MOV	EBX,[EDX]
	MOV	EAX,1 ; ADD12
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_536
_3_537: ; gen(GETd2n, is2[CV] << fdouble(oper, is, is2));
	;MOV	EAX,110
	MOV	AL,110
	;PUSH	EAX ; GETd2n ; **
	JMP	short _3_538 ; * ; **
	;;;
	;LEA	EBX,[EBP+24]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EBX,[EBP+12]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;CALL	_fdouble
	;ADD	ESP,12
	;MOV	ECX,EAX
	;LEA	EDX,[EBP+8]
	;MOV	EBX,[EDX]
	;ADD	EBX,16
	;MOV	EAX,[EBX] ; is2[CV]
	;SAL	EAX,CL	; << fdouble(...)
	;;PUSH	EAX
	;;CALL	_gen
	;;ADD	ESP,8
	;;;JMP	short _3_538
	;;JMP	short _3_539
	;JMP	short _3_529 ; *
	;;;
_3_536:
	; else {
	;MOV	EAX,51
	MOV	AL,51
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen ; gen(MOVE21, 0);
	ADD	ESP,8
	; gen(GETd1n, is2[CV] << fdouble(oper, is, is2));
	MOV	EAX,108
_3_538: ; **
	PUSH	EAX ; GETd1n
;_3_538:	; *
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fdouble
	ADD	ESP,12
	MOV	ECX,EAX
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	ADD	EBX,16
	MOV	EAX,[EBX] ; is2[CV]
	SAL	EAX,CL	; << fdouble(...)
	;PUSH	EAX
	;CALL	_gen
	;ADD	ESP,8
;_3_538:
	;JMP	short _3_539
	JMP	_3_529 ; *
_3_532: ; else {
		; gen(POP2, 0);	
	MOV	EAX,59
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; if(value = fdouble(oper, is, is2))
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fdouble
	ADD	ESP,12
	LEA	EBX,[EBP-16] ; value
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_540
_3_541:		; gen(DBL1, 0);
	MOV	EAX,14
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; if (value > 1)
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__gt
	OR	EAX,EAX
	JE	short _3_542
_3_543:		; gen(DBL1, 0);
	;MOV	EAX,14
	MOV	AL,14
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_542:
_3_540:		; if(value = fdouble(oper, is2, is))
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_fdouble
	ADD	ESP,12
	LEA	EBX,[EBP-16]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_544
_3_545:		; gen(DBL2, 0);
	MOV	EAX,15
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; if (value > 1)
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__gt
	OR	EAX,EAX
	JE	short _3_546
_3_547:		; gen(DBL2, 0);
	;MOV	EAX,15
	MOV	AL,15
	PUSH	EAX
	XOR	EAX,EAX
_3_529: ; *
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_546:
_3_544:
_3_539:		; if(oper) {
;_3_529:
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _3_549
	JMP	_3_548	; return
_3_549: ; if(nosign(is) || nosign(is2)) oper = oper2;
	LEA	EBX,[EBP+12] ; is
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_nosign
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _3_551
_3_553:
	LEA	EBX,[EBP+8] ; is2
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_nosign
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _3_554
_3_551:
_3_555:		; oper = oper2;
	LEA	EBX,[EBP+24]
	LEA	EDX,[EBP+20]
	MOV	EAX,[EDX]
	MOV	[EBX],EAX
_3_552:
_3_554:
_3_550:		; if(is[TC] = is[TC] & is2[TC]) {
	LEA	EBX,[EBP+12]
	MOV	EDX,[EBX]
	ADD	EDX,12
	MOV	ECX,[EDX] ; is[TC]
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,12
	MOV	EAX,[EBX] ; is2[TC]
	AND	EAX,ECX
	MOV	[EDX],EAX
	OR	EAX,EAX
	JE	short _3_556
_3_557:		; is[CV] = calc(is[CV], oper, is2[CV]);
	LEA	EBX,[EBP+12]
	MOV	EDX,[EBX]
	ADD	EDX,16
	PUSH	EDX ; *
	MOV	EAX,[EDX] ; is[CV]
	PUSH	EAX
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX] ; oper
	PUSH	EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,16	; is2[CV]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_calc
	ADD	ESP,12
	POP	EBX ; *
	MOV	[EBX],EAX
		; clearstage(before, 0);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_clearsta
	ADD	ESP,8
		; if(is2[TC] == UINT) is[TC] = UINT;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	EAX,12	; is2[TC]
	MOV	EBX,[EAX]
	MOV	EAX,17	; UINT
	CALL	__eq
	OR	EAX,EAX
	;JE	short _3_558
	JNE	short _3_559
	JMP	_3_558
_3_559:		; is[TC] = UINT;
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	ADD	EBX,12
	MOV	EAX,17
	MOV	[EBX],EAX
;_3_558:
	JMP	_3_560
_3_556: ; else {
		; gen(oper, 0);
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; if(oper == SUB12
	LEA	EAX,[EBP+24]
	MOV	EBX,[EAX]
	MOV	EAX,69
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_562
_3_564:		; && is [TA] >> 2 == BPW
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	ADD	EAX,8
	MOV	EBX,[EAX]
	MOV	ECX,2
	;MOV	CL,2
	SAR	EBX,CL
	;MOV	EAX,2
	MOV	EAX,ECX
	;PUSH	ECX ; *
	CALL	__eq
	;POP	ECX ; *
	OR	EAX,EAX
	JE	short _3_562
_3_565:		; && is2[TA] >> 2 == BPW) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	EAX,8
	MOV	EBX,[EAX]
	;MOV	ECX,2
	;;MOV	CL,2
	SAR	EBX,CL
	;MOV	EAX,2
	MOV	EAX,ECX
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_562
_3_566:
_3_563:
_3_567:		; gen(SWAP12, 0);
	;MOV	EAX,70
	MOV	AL,70
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(GETw1n, 1);
	MOV	EAX,31
	PUSH	EAX
	MOV	EAX,1
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
		; gen(ASR12, 0);
	MOV	EAX,7
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	CALL	_gen
	ADD	ESP,8
_3_562:
_3_561:		; is[OP] = oper;
	LEA	EDX,[EBP+12]
	MOV	EBX,[EDX]
	ADD	EBX,20 ; OP = 5 (5*4)
	LEA	EDX,[EBP+24]
	MOV	EAX,[EDX] ; oper
	MOV	[EBX],EAX
_3_558:
_3_560:	; if(oper == SUB12 || oper == ADD12) {
	LEA	EAX,[EBP+24]
	MOV	EBX,[EAX]
	MOV	EAX,69	; SUB12
	;PUSH	EBX ; *
	CALL	__eq
	;POP	EBX ; *
	OR	EAX,EAX
	JNE	short _3_569
_3_571:
	;LEA	EDX,[EBP+24]
	;MOV	EBX,[EDX]
	; ebx = oper
	;MOV	EAX,1	; ADD12
	MOV	AL,1
	CALL	__eq
	OR	EAX,EAX
	JE	short _3_572
_3_569:
_3_573:		; if(is[TA] && is2[TA])
	LEA	EAX,[EBP+12]
	MOV	EDX,[EAX]
	MOV	ECX,8
	ADD	EDX,ECX
	MOV	EAX,[EDX]
	OR	EAX,EAX
	JE	short _3_575 ; else
_3_577:
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	;MOV	ECX,8
	ADD	EBX,ECX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _3_575 ; else
_3_578:
_3_576:
_3_579:		; is[TA] = 0;
	;LEA	EAX,[EBP+12]
	;MOV	EDX,[EAX]
	;ADD	EDX,8
	; edx = is[TA]
	XOR	EAX,EAX ; 0
	MOV	[EDX],EAX
	JMP	short _3_580
_3_575:
_3_574:		; else if(is2[TA]) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,8
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _3_581
_3_582:		; is[ST] = is2[ST];
	LEA	EBX,[EBP+12]
	MOV	EDX,[EBX]
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
		; is[TI] = is2[TI];
	;LEA	EBX,[EBP+12]
	;MOV	EDX,[EBX]
	PUSH	EDX	; is[0]
	MOV	ECX,4 ; TI
	ADD	EDX,ECX	; is[TI]
	;LEA	EAX,[EBP+8]
	;MOV	EBX,[EAX]
	PUSH	EBX	; is2[0]
	;MOV	ECX,4
	ADD	EBX,ECX	; is2[TI]
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
		; is[TA] = is2[TA];
	;LEA	EBX,[EBP+12]
	;MOV	EDX,[EBX]
	POP	EBX ; is2[0]
	POP	EDX ; is[0]
	MOV	ECX,8 ; TA
	ADD	EBX,ECX
	ADD	EDX,ECX
	MOV	EAX,[EBX] ; is2[TA]
	MOV	[EDX],EAX ; is[TA]
_3_572:
_3_570:
_3_581:
_3_580:
_3_568:	; if(is[ST] == 0 || ((ptr = is2[ST])
	;	 && (ptr[TYPE] & UNSIGNED)))
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	MOV	EBX,[EAX]
	XOR	EAX,EAX
	CALL	__eq
	OR	EAX,EAX
	JNE	short _3_584
_3_588:		; || ((ptr = is2[ST]
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-12] ; ptr
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _3_585
_3_589:		; && (ptr[TYPE] & UNSIGNED)
	;LEA	EBX,[EBP-12]
	MOV	EDX,[EBX]
	INC	EDX ; + 1 ; TYPE
	;MOVSX	EAX,BYTE [EDX]
	MOV	AL,[EDX]
	AND	EAX,1 ; UNSIGNED
	OR	EAX,EAX
	JE	short _3_585
_3_590:
_3_586:
_3_584:
_3_592:		; is[ST] = is2[ST];
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	LEA	EAX,[EBP+8]
	MOV	EDX,[EAX]
	MOV	EAX,[EDX] ; is2[ST]
	MOV	[EBX],EAX
_3_585:
_3_591:
_3_587:
_3_583:
_3_548:		; (return)
	MOV	ESP,EBP
	POP	EBP
	RETN

_nosign:	; nosign(is) int is[]; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; char *ptr;
		; if(is[TA]
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	;MOV	EAX,8
	;ADD	EBX,EAX
	ADD	EBX,8	; TA = 2 (2*4)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _3_599
	;JMP	short _3_595
	MOV	EAX,1
	JMP	short _3_596
_3_599:		; || is[TC] == UINT
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;MOV	EBX,12
	;ADD	EAX,EBX
	ADD	EAX,12	; TC = 3 (3*4)
	MOV	EBX,[EAX]
	MOV	EAX,17 ; UINT = (INTSIZE << 2) + 1
	CALL	__eq
	OR	EAX,EAX
	JNE	short _3_595 ; eax = 1
_3_600:	; || ((ptr = is[ST]) && (ptr[TYPE] & UNSIGNED))
	LEA	EBX,[EBP-4]
	LEA	EAX,[EBP+8] ; is
	MOV	EDX,[EAX]
	MOV	EAX,[EDX]
	MOV	[EBX],EAX ; ST = 0
	OR	EAX,EAX
	JZ	short _3_596 ; eax = 0
_3_601:
	LEA	EBX,[EBP-4] ; ptr
	MOV	EAX,[EBX]
	;MOV	EBX,1
	;ADD	EAX,EBX
	INC	EAX	; TYPE = 1
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,1	; UNSIGNED = 1
	AND	EAX,EBX
	;OR	EAX,EAX
	;JZ	short _3_596
_3_595:
_3_597:
_3_602:
_3_604:
	;MOV	EAX,1
_3_596:
	MOV	ESP,EBP
	POP	EBP
	RETN
;_3_603:
;_3_598:
;_3_596:
;_3_594:
	;;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN

_calc:	; calc(left, oper, right) int left, oper, right; {
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+12] ; oper
	MOV	EAX,[EBX]
	JMP	_3_608
_3_609:		; case ADD12: return (left  +  right);
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	ADD	EAX,EBX
	POP	EBP
	RETN
_3_610:		; case SUB12: return (left  -  right);
	LEA	EBX,[EBP+16] ; left
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+8]  ; right
	MOV	EBX,[EDX]
	SUB	EAX,EBX
	POP	EBP
	RETN
_3_611:		; case MUL12: return (left  *  right);
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	IMUL	EBX
	POP	EBP
	RETN
_3_612:		; case DIV12: return (left  /  right);
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+16]
	MOV	EAX,[EDX]
	CDQ
	IDIV	EBX
	POP	EBP
	RETN
_3_613:		; case MOD12: return (left  %  right);
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+16]
	MOV	EAX,[EDX]
	CDQ
	IDIV	EBX
	MOV	EAX,EDX
	POP	EBP
	RETN
_3_614:		; case EQ12:  return (left  == right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__eq
	POP	EBP
	RETN
_3_615:		; case NE12:  return (left  != right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__ne
	POP	EBP
	RETN
_3_616:		; case LE12:  return (left  <= right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__le
	POP	EBP
	RETN
_3_617:		; case GE12:  return (left  >= right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__ge
	POP	EBP
	RETN
_3_618:		; case LT12:  return (left  <  right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__lt
	POP	EBP
	RETN
_3_619:		; case GT12:  return (left  >  right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__gt
	POP	EBP
	RETN
_3_620:		; case AND12: return (left  &  right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	AND	EAX,EBX
	POP	EBP
	RETN
_3_621:		; case OR12:  return (left  |  right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	OR	EAX,EBX
	POP	EBP
	RETN
_3_622:		; case XOR12: return (left  ^  right);
	LEA	ECX,[EBP+16]
	MOV	EBX,[ECX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	XOR	EAX,EBX
	POP	EBP
	RETN
_3_623:		; case ASR12: return (left  >> right);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+8]
	MOV	ECX,[EDX]
	SAR	EAX,CL
	POP	EBP
	RETN
_3_624:		; case ASL12: return (left  << right);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+8]
	MOV	ECX,[EDX]
	SAL	EAX,CL
	POP	EBP
	RETN

_3_608:		; switch(oper) {
	CALL	__switch

 DD _3_609
 DD 1
 DD _3_610
 DD 69
 DD _3_611
 DD 52
 DD _3_612
 DD 16
 DD _3_613
 DD 49
 DD _3_614
 DD 20
 DD _3_615
 DD 55
 DD _3_616
 DD 43
 DD _3_617
 DD 22
 DD _3_618
 DD 47
 DD _3_619
 DD 35
 DD _3_620
 DD 3
 DD _3_621
 DD 57
 DD _3_622
 DD 73
 DD _3_623
 DD 7
 DD _3_624
 DD 6
 DD 0
		; default
_3_607:		; return (calc2(left, oper, right));
	LEA	EBX,[EBP+16] ; left
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+12] ; oper
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]  ; right
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_calc2
	ADD	ESP,12
	POP	EBP
	RETN

_calc2:
	; calc2(left, oper, right) unsigned left,
	;	right; int oper; {
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+12] ; oper
	MOV	EAX,[EBX]
	JMP	short _3_628
_3_629:		; case MUL12u:
		; return (left * right)
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	MUL	EBX
	POP	EBP
	RETN
_3_630:		; case DIV12u:
		; return (left / right);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	XOR	EDX,EDX
	DIV	EBX
	POP	EBP
	RETN
_3_631:		; MOD12u:
		; return (left % right);
	LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	XOR	EDX,EDX
	DIV	EBX
	MOV	EAX,EDX
	POP	EBP
	RETN
_3_632:		; case LE12u:
		; return (left <= right);
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__ule
	POP	EBP
	RETN
_3_633:		; case GE12u:
		; return (left >= right);
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__uge
	POP	EBP
	RETN
_3_634:		; case LT12u:
		; return (left < right);
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__ult
	POP	EBP
	RETN
_3_635:		; case GT12u:
		; return (left > right);
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX]
	LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	CALL	__ugt
	POP	EBP
	RETN

_3_628:
	CALL	__switch  ; switch(oper) {

 DD _3_629	; case MUL12u:
 DD 53
 DD _3_630	; case DIV12u:
 DD 17
 DD _3_631	; MOD12u:
 DD 50
 DD _3_632	; case LE12u:
 DD 44
 DD _3_633	; case GE12u:
 DD 23
 DD _3_634	; case LT12u:
 DD 48
 DD _3_635	; case GT12u:
 DD 36
 DD 0

_3_627:		; default
	XOR	EAX,EAX ; return (0);
	POP	EBP
	RETN
