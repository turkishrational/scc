; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 22/03/2026
; -----------------------------------------------------------
; Derived from 'cc2.asm' file of KolibriOS SCC source code
; 2024

_preprocess:	; preprocess() {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int k; char c;
		; if(ccode) {
	MOV	EAX,[_ccode]
	OR	EAX,EAX
	JNZ	short _2_3
		; else
_2_2:
	CALL	_inline	; inline();
_2_5:		; return;
	MOV	ESP,EBP
	POP	EBP
	RETN
_2_3:		; line = mline;
	MOV	EAX,[_mline]
	MOV	DWORD [_line],EAX
	CALL	_ifline	; ifline();
		; if(eof) return;
	MOV	EAX,[_eof]
	OR	EAX,EAX
	JNZ	short _2_5
_2_4:
_2_6:		; pptr = -1;
	MOV	EAX,-1
	MOV	DWORD [_pptr],EAX
_2_51:
_2_17:
_2_85:
_2_19:
_2_35:
_2_70:
_2_7:
	; /* while(ch != NEWLINE && ch) { */
	MOV	EBX,[_ch]
	;;; 	; TRDOS 386 modification
	MOV	EAX,13 ; CR
	CALL	__ne
	OR	EAX,EAX
	JZ	short _2_9
	;;;
	MOV	EAX,10
	CALL	__ne
	OR	EAX,EAX
	JE	short _2_9
_2_11:
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JNE	short _2_12
_2_9:
_2_8:
	; if(pptr >= LINEMAX) error("line too long");
	MOV	EBX,[_pptr]
	MOV	EAX,127	; LINEMAX
	CALL	__ge
	OR	EAX,EAX
	JE	short _2_108
_2_109:
	;MOV	EAX,_2_1+23
	MOV	EAX,_lin_t_l_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POP	EAX
;_2_108:
	XOR	EAX,EAX ; 0
_2_108:
	PUSH	EAX ; *
	PUSH	EAX
	CALL	_keepch	; keepch(NULL);
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,[_pline]
	MOV	DWORD [_line],EAX ; line = pline;
	;XOR	EAX,EAX ; 0
	;PUSH	EAX ; *
	CALL	_bump ; bump(0);
	ADD	ESP,4
	MOV	ESP,EBP
	POP	EBP
	RETN
_2_12:
	;MOV	EAX,1
_2_10:
_2_13:		; if(white()) {
	CALL	_white
	OR	EAX,EAX
	JE	short _2_14
_2_15:		; keepch(' ');
	MOV	EAX,32
	PUSH	EAX
	CALL	_keepch
	ADD	ESP,4
_2_16:		; while(white()) gch();
	CALL	_white
	OR	EAX,EAX
	JNE	short _2_18
	JMP	_2_17
_2_18:
	CALL	_gch
	JMP	short _2_16
_2_14:		; else if(ch == '"') {
	MOV	EBX,[_ch]
	MOV	EAX,34 ; '"'
	CALL	__eq
	OR	EAX,EAX
	;JE	short _2_20 ; else
	JNE	short _2_21
	JMP	_2_20
_2_21:
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_keepch	; keepch(ch);
	ADD	ESP,4
	CALL	_gch	; gch();
_2_22:
	; while(ch != '"' || (*(lptr-1) == 92
	;	&& *(lptr-2) != 92)) {
	MOV	EBX,[_ch]
	MOV	EAX,34
	CALL	__ne
	OR	EAX,EAX
	JNE	short _2_24
_2_28:
	MOV	EAX,[_lptr]
	DEC	EAX
	MOVSX	EBX,BYTE [EAX] ; *(lptr-1)
	MOV	EAX,92 ; underscore
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_25
_2_29:
	MOV	EAX,[_lptr]
	DEC	EAX
	DEC	EAX
	MOVSX	EBX,BYTE [EAX] ; *(lptr-2)
	MOV	EAX,92	; underscore
	CALL	__ne
	OR	EAX,EAX
	JE	short _2_25
_2_30:
_2_26:
_2_24:
_2_27:
_2_32:		; if(ch == NULL) {
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JNE	short _2_33
_2_34:		;  error("no quote");
	;MOV	EAX,_2_1+0
	MOV	EAX,_no_quote_
	PUSH	EAX
	CALL	_error
	ADD	ESP,4
	JMP	short _2_23 ; break;
_2_33:		; keepch(gch());
	CALL	_gch
	PUSH	EAX
	CALL	_keepch
	;ADD	ESP,4
	POP	EAX
	JMP	short _2_22
_2_25:
_2_31:
_2_23:
	CALL	_gch	; getch();
	MOV	EAX,34	; '"'
	PUSH	EAX
	CALL	_keepch	; keepch('"');
	ADD	ESP,4
	;JMP	_2_35
	JMP	_2_7
_2_20:		; else if(ch == 39) {
	MOV	EBX,[_ch]
	MOV	EAX,39	; single quote
	CALL	__eq
	OR	EAX,EAX
	;JE	short _2_36 ; else
	JNE	short _2_37
	JMP	_2_36
_2_37:
	MOV	EAX,39
	PUSH	EAX
	CALL	_keepch	; keepch(39);
	ADD	ESP,4
	CALL	_gch	; gch();
_2_38:
	; while(ch != 39 || (*(lptr-1) == 92 && *(lptr-2) != 92)) {
	;	&& *(lptr-2) != 92)) {
	MOV	EBX,[_ch]
	MOV	EAX,39	; single quote
	CALL	__ne
	OR	EAX,EAX
	JNE	short _2_40
_2_44:
	MOV	EAX,[_lptr]
	DEC	EAX
	MOVSX	EBX,BYTE [EAX] ; *(lptr-1)
	MOV	EAX,92 ; underscore
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_47
_2_45:
	MOV	EAX,[_lptr]
	DEC	EAX
	DEC	EAX
	MOVSX	EBX,BYTE [EAX] ; *(lptr-2)
	MOV	EAX,92	; ; underscore
	CALL	__ne
	OR	EAX,EAX
	JE	short _2_47
_2_46:
_2_42:
_2_40:
_2_48:		; if(ch == NULL) {
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JNE	short _2_49
_2_50:		; error("no apostrophe");
	;MOV	EAX,_2_1+9
	MOV	EAX,_no_apost_
	PUSH	EAX
	CALL	_error
	;ADD	ESP,4
	POp	EAX
	JMP	short _2_39 ; break;
_2_49:
	CALL	_gch	; gch();
	PUSH	EAX
	CALL	_keepch ; keepch(gch());
	;ADD	ESP,4
	POP	EAX
	JMP	short _2_38 ; while
_2_41:
_2_47:
_2_43:
_2_39:
	CALL	_gch	; gch();
	MOV	EAX,39	; single quote
	PUSH	EAX
	CALL	_keepch	; keepch(39);
	;ADD	ESP,4
	POP	EAX
	JMP	_2_51
_2_36:
	; else if(ch == '/' && nch == '*')
	MOV	EBX,[_ch]
	MOV	EAX,47 ; '/'
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_53
_2_55:
	MOV	EBX,[_nch]
	MOV	EAX,42 ; '*'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _2_53 ; else
_2_56:
	;MOV	EAX,1
_2_54:
_2_57:
	MOV	EAX,2
_2_67:
	PUSH	EAX
	CALL	_bump	; bump(2);
	;ADD	ESP,4
	POP	EAX
_2_68:
_2_58:	; while((ch == '*' && nch == '/') == 0)
	MOV	EBX,[_ch]
	MOV	EAX,42 ; '*'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _2_60
_2_62:		; &&
	MOV	EBX,[_nch]
	MOV	EAX,47	; '/'
	CALL	__eq
	OR	EAX,EAX
	;JE	short _2_60
;_2_63:
	;MOV	EAX,1
	;JMP	short _2_61
	JNE	short _2_61
_2_60:
_2_64:		; if(ch)
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JE	short _2_65 ; else
_2_66:		; bump(1);
	MOV	EAX,1
	JMP	short _2_67
_2_65:
	CALL	_ifline	; ifline();
		; if(eof)
	MOV	EAX,[_eof]
	OR	EAX,EAX
	;JNE	short _2_69 ; break;
	JE	short _2_68
_2_69:
_2_61:
_2_59:
	MOV	EAX,2
	PUSH	EAX
	CALL	_bump	; bump(2);
	;ADD	ESP,4
	POP	EAX
	JMP	_2_70
_2_53:
_2_52:
	; else if(ch == '/' && nch == '/')
	MOV	EBX,[_ch]
	MOV	EAX,47 ; '/'
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_72 ; else
_2_74:
	MOV	EBX,[_nch]
	MOV	EAX,47 ; '/!
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_72 ; else
_2_75:
	;MOV	EAX,1
_2_73:
_2_76:
	MOV	EAX,2
_2_81:
	PUSH	EAX
	CALL	_bump	; bump(2);
_2_82:
	ADD	ESP,4
_2_83:	; /* while(ch != NEWLINE) */
_2_77:	; while(ch != 13 && ch != NEWLINE)
	MOV	EBX,[_ch]
	;;;	; TRDOS 386 modification
	MOV	EAX,13 ; CR
	CALL	__ne
	OR	EAX,EAX
	JZ	short _2_78
	;;;
	MOV	EAX,10 ; LF
	CALL	__ne
	OR	EAX,EAX
	JE	short _2_78
_2_79:		; if(ch)
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JE	short _2_80 ; else
	MOV	EAX,1
	JMP	short _2_81
_2_80:		; if(eof)
	MOV	EAX,[_eof]
	OR	EAX,EAX
	JE	short _2_83 ; while
_2_84:		; break;
_2_78:
	MOV	EAX,1
	PUSH	EAX
	CALL	_bump ; bump(1);
	ADD	ESP,4
	JMP	_2_85
_2_72:
_2_71:		; else if(an(ch)) {
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JNE	short _2_87
	JMP	_2_86
_2_87:		; k = 0;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX
_2_88:	
	; while(an(ch) && k < NAMEMAX) {
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _2_90
_2_92:		; msname[k++] = ch;
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,8	; NAMEMAX
	CALL	__lt
	OR	EAX,EAX
	JZ	short _2_90
_2_93:
	;MOV	EAX,1
_2_91:
_2_94:		; msname[k++] = ch;
	LEA	EDX,[EBP-4] ; k
	MOV	EBX,[EDX]
	INC	DwORD [EDX] ; k++
	ADD	EBX,_msname ; msname[k]
	MOV	EAX,[_ch]
	MOV	[EBX],AL
	CALL	_gch
	JMP	short _2_88 ; while
_2_90:
_2_89:
		; msname[k] = NULL;
	MOV	ECX,_msname
	PUSH	ECX ; +6+
	LEA	EAX,[EBP-4] ; k
	MOV	EBX,[EAX]
	ADD	EBX,ECX ; msname[k]
	XOR	EAX,EAX
	MOV	[EBX],AL ; NULL
	; if(search(msname, macn, NAMESIZE+2,
	;	 MACNEND, MACNBR, 0)) {
	;MOV	EAX,_msname
	;PUSH	EAX ; +6+
	MOV	EBX,[_macn]
	PUSH	EBX ; +5+
	MOV	EAX,11	; NAMESIZE+2
	PUSH	EAX ; +4+
	;MOV	EBX,[_macn]
		; MACNSIZE = MACNBR*(NAMESIZE+2)
	MOV	EAX,3300
	ADD	EAX,EBX
	PUSH	EAX ; +3+
	MOV	EAX,300	; MACNBR
	PUSH	EAX ; +2+
	XOR	EAX,EAX ; 0
	PUSH	EAX ; +1+
	;MOV	CL,6
	CALL	_search
	ADD	ESP,24
	OR	EAX,EAX
	JE	short _2_95 ; else
_2_96:
	; k = getint(cptr+NAMESIZE, 2/*INTSIZE*/);
	MOV	EAX,[_cptr]
	MOV	EBX,9	; NAMESIZE
	ADD	EAX,EBX
	PUSH	EAX
	MOV	EAX,2
	PUSH	EAX
	CALL	_getint
	ADD	ESP,8
	LEA	EBX,[EBP-4] ; k
	MOV	[EBX],EAX
_2_97:	
		; while(c = macq[k++]) keepch(c);
	MOV	EDX,[_macq]
	LEA	EBX,[EBP-4] ; k
	MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	;DEC	EAX
	INC	DWORD [EBX] ; k++
	ADD	EDX,EAX
	MOVSX	EAX,BYTE [EDX]
	LEA	EBX,[EBP-8] ; c
	MOV	[EBX],AL
	OR	EAX,EAX
	JE	short _2_98
_2_99:
	;LEA	EBX,[EBP-8]
	;MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_keepch
	;ADD	ESP,4
	POP	EAX
	JMP	short _2_97
_2_98:
_2_100:		; while(an(ch)) gch();
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _2_101
_2_102:
	CALL	_gch
	JMP	short _2_100
_2_95:		
		; k = 0;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX
_2_104:		; while(c = msname[k++])
	MOV	EDX,_msname
	LEA	EBX,[EBP-4] ; k
	MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	;DEC	EAX
	INC	DWORD [EBX] ; k++
	ADD	EDX,EAX
	MOVSX	EAX,BYTE [EDX]
	LEA	EBX,[EBP-8] ; c
	MOV	[EBX],AL
	OR	EAX,EAX
	JZ	short _2_105
_2_106:
		; keepch(c);
	;LEA	EBX,[EBP-8] ; c
	;MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	CALL	_keepch
	;ADD	ESP,4
	POP	EAX
	JMP	short _2_104 ; while
_2_86:		
		; else keepch(gch());
	CALL	_gch
	PUSH	EAX
	CALL	_keepch
	ADD	ESP,4
_2_101:
_2_105:
_2_103:
_2_107:
	JMP	_2_7

_2_1:
_no_quote_: DB "no quote",0
_no_apost_: DB "no apostrophe",0
_lin_t_l_:  DB "line too long",0

_keepch:	; keepch(c)
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EBX,[_pptr] ; if(pptr < LINEMAX)
	MOV	EAX,127
	CALL	__lt
	OR	EAX,EAX
	JZ	short _2_111 ; false
_2_112:			; pline[++pptr] = c;
	MOV	EAX,[_pptr]
	INC	EAX
	MOV	DWORD [_pptr],EAX
	MOV	EBX,[_pline]
	ADD	EBX,EAX
	LEA	EDX,[EBP+8] ; char c;
	;MOVSX	EAX,BYTE [EDX]
	MOV	AL,[EDX]
	MOV	[EBX],AL
_2_111:
	POP	EBP
	RETN

_ifline:	; ifline() {
	PUSH	EBP
	MOV	EBP,ESP
_2_114:	; while(1) {
		; inline();
	CALL	_inline
		; if(eof) return;
	MOV	EAX,[_eof]
	OR	EAX,EAX
	JE	short _2_116
_2_117:
	POP	EBP
	RETN
_2_116:		; if(match("#ifdef")) {
	;MOV	EAX,_2_113+0
	MOV	EAX,_if_def_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _2_118
_2_119:		; ++iflevel;
	;MOV	EAX,[_iflevel]
	;INC	EAX
	;MOV	DWORD [_iflevel],EAX
	INC	DWORD [_iflevel]
		; if(skiplevel) continue;
	MOV	EAX,[_skipleve]
	OR	EAX,EAX
	JNE	short _2_114 ; while
_2_120:		; symname(msname);
	MOV	EAX,_msname
	PUSH	EAX ; +6+
	PUSH	EAX
	CALL	_symname
	;ADD	ESP,4
	POP	EAX
	; if(search(msname, macn, NAMESIZE+2,
	;	MACNEND, MACNBR, 0) == 0)
	;MOV	EAX,_msname
	;PUSH	EAX ; +6+
	MOV	EBX,[_macn]
	PUSH	EBX ; +5+
	MOV	EAX,11	; NAMESIZE+2
	PUSH	EAX ; +4+
	;MOV	EBX,[_macn]
		; MACNSIZE = MACNBR*(NAMESIZE+2)
	MOV	EAX,3300
	ADD	EAX,EBX	; MACNEND = macn+MACNSIZE
	PUSH	EAX ; +3+
	MOV	EAX,300	; MACNBR
	PUSH	EAX ; +2+
	XOR	EAX,EAX ; 0
	PUSH	EAX ; +1+
	;MOV	CL,6
	CALL	_search
	ADD	ESP,24
	OR	EAX,EAX
	;JNE	short _2_122
	JNZ	short _2_114
_2_123:		; skiplevel = iflevel;
	MOV	EAX,[_iflevel]
	MOV	DWORD [_skipleve],EAX
_2_122:		; continue;
	JMP	short _2_114 ; while
_2_118:		; if(match("#ifndef")) {
	;MOV	EAX,_2_113+7
	MOV	EAX,_if_ndef_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _2_124
_2_125:		; ++iflevel;
	;MOV	EAX,[_iflevel]
	;INC	EAX
	;MOV	DWORD [_iflevel],EAX
	INC	DWORD [_iflevel]
		; if(skiplevel) continue;
	MOV	EAX,[_skipleve]
	OR	EAX,EAX
	;JNE	short _2_114 ; while
	JE	short _2_126
	JMP	_2_114
_2_126:		; symname(msname);
	MOV	EAX,_msname
	PUSH	EAX ; +6+
	PUSH	EAX
	CALL	_symname
	;ADD	ESP,4
	POP	EAX
	; if(search(msname, macn, NAMESIZE+2,
	;	MACNEND, MACNBR, 0))
	;MOV	EAX,_msname
	;PUSH	EAX ; +6+
	MOV	EBX,[_macn]
	PUSH	EBX ; +5+
	MOV	EAX,11	; NAMESIZE+2
	PUSH	EAX ; +4+
	;MOV	EBX,[_macn]
		; MACNSIZE = MACNBR*(NAMESIZE+2)
	MOV	EAX,3300
	ADD	EAX,EBX	; MACNEND = macn+MACNSIZE
	PUSH	EAX ; +3+
	MOV	EAX,300	; MACNBR
	PUSH	EAX ; +2+
	XOR	EAX,EAX ; 0
	PUSH	EAX ; +1+
	;MOV	CL,6
	CALL	_search
	ADD	ESP,24
	OR	EAX,EAX
	JE	short _2_128 ; continue; (while)
	;JNZ	short _2_129
	;JMP	_2_114
_2_129:		; skiplevel = iflevel;
	MOV	EAX,[_iflevel]
	MOV	DWORD [_skipleve],EAX
_2_128:
	JMP	_2_114 ; continue;
_2_124:		; if(match("#else")) {
	;MOV	EAX,_2_113+15
	MOV	EAX,_if_else_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _2_130
_2_131:		; if(iflevel) {
	MOV	EAX,[_iflevel]
	OR	EAX,EAX
	JE	short _2_132 ; else
_2_133:		; if(skiplevel == iflevel)
	MOV	EBX,[_skipleve]
	MOV	EAX,[_iflevel]
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_134 ; else
_2_135:		; skiplevel = 0;
	XOR	EAX,EAX
	MOV	DWORD [_skipleve],EAX
	;JMP	short _2_136
	JMP	_2_114
_2_134:		; else if(skiplevel == 0)
	MOV	EAX,[_skipleve]
	OR	EAX,EAX
	;JZ	short _2_138
	;JMP	_2_114
	JNZ	short _2_128
_2_138:		; skiplevel = iflevel;
	MOV	EAX,[_iflevel]
	MOV	DWORD [_skipleve],EAX
_2_137:
;_2_136:
	;JMP	short _2_139
	JMP	_2_114	; while
_2_132:		; else noiferr();
	CALL	_noiferr
;_2_139:	; continue;
	JMP	_2_114
_2_130:		; if(match("#endif")) {
	;MOV	EAX,_2_113+21
	MOV	EAX,_endif_
	PUSH	EAX
	CALL	_match
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _2_140
_2_141:		; if(iflevel) {
	MOV	EAX,[_iflevel]
	OR	EAX,EAX
	JE	short _2_142 ; else
_2_143:		; if(skiplevel == iflevel)
	MOV	EBX,[_skipleve]
	MOV	EAX,[_iflevel]
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_144
_2_145:		; skiplevel = 0;
	XOR	EAX,EAX
	MOV	DWORD [_skipleve],EAX
_2_144:		; --iflevel;
	;MOV	EAX,[_iflevel]
	;DEC	EAX
	;MOV	DWORD [_iflevel],EAX
	DEC	DWORD [_iflevel]
	JMP	_2_114 ; while
_2_142:		; else noiferr();
	CALL	_noiferr
_2_146:		; continue;
	JMP	_2_114 ; while
_2_140:		; if(skiplevel) continue;
	MOV	EAX,[_skipleve]
	OR	EAX,EAX
	;JNE	short _2_114
	JNZ	short _2_146
_2_147:		; if(ch == 0) continue;
	MOV	EAX,[_ch]
	OR	EAX,EAX
	;JE	short _2_114
	JZ	short _2_146
_2_149:		; break;
_2_115:
	POP	EBP
	RETN

_2_113:
_if_def_:  DB "#ifdef",0
_if_ndef_: DB "#ifndef",0
_if_else_: DB "#else",0
_endif_:   DB "#endif",0

_inline:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int k, unit;
	MOV	EBX,[_input] ; if(input == EOF) openfile();
	MOV	EAX,-1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _2_152
_2_153:
	;XOR	CL,CL
	CALL	_openfile ; openfile();
_2_152:
	MOV	EAX,[_eof] ; if(eof) return;
	OR	EAX,EAX
	JZ	short _2_154
_2_155:
	MOV	ESP,EBP
	POP	EBP
	RETN
_2_154:
	MOV	EAX,[_input2] ; if((unit = input2) == EOF)
	LEA	EBX,[EBP-8]
	MOV	[EBX],EAX ; unit = input2
	;MOV	EBX,EAX
	;MOV	EAX,-1	; EOF
	MOV	EBX,-1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _2_156 ; false
_2_157:		; true
	LEA	EBX,[EBP-8] ; unit
	MOV	EAX,[_input]
	MOV	[EBX],EAX ; unit = input;
_2_156:	 ; if(fgets(line, LINEMAX, unit) == NULL) {
	MOV	EAX,[_line]
	PUSH	EAX
	MOV	EAX,127	; LINEMAX
	PUSH	EAX
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX] ; unit
	PUSH	EAX
	;MOV	CL,3
	CALL	_fgets
	ADD	ESP,12
	OR	EAX,EAX	 ; NULL ?
	JNZ	short _2_158 ; no, false
_2_159:		; yes, true
	LEA	EBX,[EBP-8] ; unit
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_OS_fclose ; fclose(unit);
	;ADD	ESP,4
	POP	EAX
	MOV	EBX,[_input2]
	MOV	EAX,-1
	CALL	__ne	; if(input2 != EOF)
	OR	EAX,EAX
	JZ	short _2_160 ; false
_2_161:		; true
	MOV	EAX,-1	; input2 = EOF;
	MOV	DWORD [_input2],EAX
	JMP	short _2_162
_2_160:		; else
	;MOV	EAX,-1
	DEC	EAX
	; eax = -1
	MOV	DWORD [_input],EAX ; input = EOF;
_2_162:
	MOV	EBX,[_line]
	XOR	EAX,EAX
	MOV	[EBX],AL ; *line = NULL;
	JMP	short _2_163
_2_158:		; else if(listfp)
	MOV	EBX,[_listfp]
	OR	EBX,EBX
	JZ	short _2_164 ; false
_2_165:
	;MOV	EBX,[_listfp] ; if(listfp == output)
	MOV	EAX,[_output]
	CALL	__eq
	OR	EAX,EAX
	JZ	short _2_166 ; false
_2_167:		; true
	MOV	EAX,59	; ';'
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc ; fputc(';', output);
	ADD	ESP,8
_2_166:
	MOV 	EAX,[_line]
	PUSH	EAX
	MOV	EAX,[_listfp]
	PUSH	EAX
	;MOV	CL,2
	CALL	_fputs	; fputs(line, listfp);
	ADD	ESP,8
_2_164:
_2_163:
	XOR	EAX,EAX
	PUSH	EAX
	;MOV	CL,1
	CALL	_bump	; bump(0);
	;ADD	ESP,4
	MOV	ESP,EBP
	POP	EBP
	RETN

_inbyte:
	;PUSH	EBP
	;MOV	EBP,ESP
_2_169:
	MOV	EAX,[_ch] ; while(ch == 0) {
	OR	EAX,EAX
	JNZ	short _2_170
_2_171:
	MOV	EAX,[_eof] ; if(eof) return 0;
	OR	EAX,EAX
	JZ	short _2_172
_2_173:
	XOR	EAX,EAX	; return(0);
	;POP	EBP
	RETN
_2_172:
	;XOR	CL,CL
	CALL	_preprocess ; preprocess();
	JMP	short _2_169
_2_170:
	;XOR	CL,CL
	CALL	_gch	; return gch();
	;POP	EBP
	RETN

_symname:	; symname(sname)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int k;char c;
	;XOR	CL,CL
	CALL	_blanks	; blanks();
	MOV	EAX,[_ch]
	PUSH	EAX
	;MOV	CL,1
	CALL	_alpha	; if(alpha(ch) == 0)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_175 ; false
_2_176:		; return (*sname = 0);
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	XOR	EAX,EAX
	MOV	[EBX],AL
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _2_180 ; TRDOS 386 modification 
_2_175:		; k = 0;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX
_2_177:		; while(an(ch)) {
	MOV	EAX,[_ch]
	PUSH	EAX
	;MOV	CL,1
	CALL	_an	; an(ch)
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _2_178
_2_179:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; sname[0] address
	;PUSH	EAX
	LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;POP	EBX
	ADD	EAX,[EBX] ; sname[k] address
	PUSH	EAX
	;XOR	CL,CL
	CALL	_gch
	POP	EBX
	MOV	[EBX],AL ; sname[k] = gch();
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,8
	CALL	__lt	; if(k < NAMEMAX) ++k;
	OR	EAX,EAX
	;JZ	short _2_180
	JZ	short _2_177
_2_181:
	LEA	EBX,[EBP-4] ; k address
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX] ; ++k;
;_2_180:
	JMP	short _2_177 ; jump to while(an(ch))
_2_178:
	LEA	EAX,[EBP+8] ; sname[0] address
	MOV	EBX,[EAX]
	;PUSH	EBX
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;POP	EBX
	LEA	EAX,[EBP-4]
	ADD	EBX,[EAX] ; sname[k] address
	XOR	EAX,EAX	; 0
	MOV	[EBX],AL  ; sname[k] = 0;
	;MOV	EAX,1
	INC	EAX
_2_180:		; TRDOS 386 modification
	MOV	ESP,EBP
	POP	EBP
	RETN

_need:
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8] ; str
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_match	; if(match(str) == 0)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_183
_2_184:
	MOV	EAX,err_mt	; _2_182+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_error	; error("missing token");
	ADD	ESP,4
_2_183:
	POP	EBP
	RETN

_2_182:
err_mt: DB "missing token",0

_ns:
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,SEMICOLON ; _2_185+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_match	; if(match(";") == 0)
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_186
_2_187:
	MOV	EAX,err_nsc ; _2_185+2
	PUSH	EAX
	;MOV	CL,1
	CALL	_error	; error("no semicolon");
	ADD	ESP,4
	;JMP	short _2_188
	RETN
_2_186:		; else errflag = 0;
	XOR	EAX,EAX
	MOV	DWORD [_errflag],EAX
_2_188:
	;POP	EBP
	RETN

_2_185:
SEMICOLON: DB ";",0 ; DB 59,0
err_nsc: DB "no semicolon",0

_match:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
	;XOR	CL,CL
	CALL	_blanks	; blanks();
	LEA	EAX,[EBP-4] ; if(k = streq(lptr, lit)) {
	PUSH	EAX
	MOV	EAX,[_lptr]
	PUSH	EAX
	LEA	EBX,[EBP+8] ; char *lit;
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_streq
	ADD	ESP,8
	POP	EBX
	MOV	[EBX],EAX
	OR	EAX,EAX
	JZ	short _2_190 ; false
_2_191:		; true
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_bump	; bump(k);
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,1	; return 1;
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
_2_190:
	;XOR	EAX,EAX	; return 0;
	; eax = 0
	MOV	ESP,EBP
	POP	EBP
	RETN

_streq:		; streq(str1, str2)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; k = 0;
_2_193:
	; EBX = EBP-4
	LEA	EAX,[EBP+8] ; while (str2[k]) {
	MOV	EDX,[EAX]   ; str2
	;LEA	EBX,[EBP-4] ; k address
	ADD	EDX,[EBX]   ; add k value to str2
	MOVSX	EAX,BYTE [EDX] ; str2[k]
	OR	EAX,EAX
	JZ	short _2_194 ; return k;
_2_195:
	LEA	EBX,[EBP+12] ; str1
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-4]
	ADD	EAX,[EBX]   ; str1[k]
	MOVSX	EBX,BYTE [EAX]
	PUSH	EBX
	LEA	EAX,[EBP+8] ; str2
	MOV	EBX,[EAX]
	LEA	EAX,[EBP-4]
	ADD	EBX,[EAX]   ; str2[k]
	MOVSX	EAX,BYTE [EBX]
	POP	EBX
	CALL	__ne	; str1[k] != str2[k]
	OR	EAX,EAX
	JZ	short _2_196
_2_197:
	XOR	EAX,EAX	; return 0;
	MOV	ESP,EBP
	POP	EBP
	RETN
_2_196:
	LEA	EBX,[EBP-4] ; ++k;
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]  ; k = k+1
	JMP	short _2_193 ; jump to while (str2[k])
_2_194:
	;LEA	EBX,[EBP-4] ; return k;
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

_amatch:	; amatch(lit, len)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
	;XOR	CL,CL
	CALL	_blanks	; blanks();
	;LEA	EAX,[EBP-4]
	;PUSH	EAX	; k address
	MOV	EAX,[_lptr]
	PUSH	EAX	; lptr
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX	; lit
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX	; len
	;MOV	CL,3
	CALL	_astreq	; k = astreq(lptr, lit, len)
	ADD	ESP,12
	;POP	EBX
	LEA	EBX,[EBP-4] ; k address
	MOV	[EBX],EAX
	OR	EAX,EAX	; if(k) {
	JZ	short _2_199 ; false
_2_200:		; true
	;LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX] ; k
	PUSH	EAX
	;MOV	CL,1
	CALL	_bump	; bump(k);
	;ADD	ESP,4
	POP	EAX
	MOV	EAX,1	; return 1;
_2_199:		; (eax = 0)
	MOV	ESP,EBP
	POP	EBP
	RETN
;_2_199:
	; eax = 0
	;XOR	EAX,EAX	; return 0;
	;MOV	ESP,EBP
	;POP	EBP
	;RETN

_astreq:	; astreq(str1, str2, len)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; k = 0
_2_202:		; while (k < len) {
	;LEA	EBX,[EBP-4]
	; EBX = EBP-4
	MOV	EAX,[EBX]
	PUSH	EAX	; k
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; len
	POP	EBX
	CALL	__lt	; is eax > ebx ?
	OR	EAX,EAX
	JZ	short _2_203 ; no, false
_2_204:		; if(str1[k] != str2[k]) break;
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX] ; str1[0]
	LEA	ECX,[EBP-4]
	MOV	EAX,[ECX] ; k
	ADD	EAX,EBX
	MOVSX	EBX,BYTE [EAX] ; val str1[k]
	LEA	EDX,[EBP+12]
	MOV	EAX,[EDX] ; str2[0]
	;LEA	ECX,[EBP-4]
	MOV	EDX,[ECX] ; k
	ADD	EDX,EAX
	MOVSX	EAX,BYTE [EDX] ; val str2[k]
	CALL	__ne
	OR	EAX,EAX
	JNZ	short _2_203
_2_205:		; if(str2[k] < ' ') break;
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX] ; str2[0] address
	LEA	EDX,[EBP-4] ; k address
	MOV	EAX,[EDX] ; k value
	ADD	EAX,EBX	; str2[k] address
	MOVSX	EBX,BYTE [EAX] ; str2[k] value
	MOV	EAX,32	; ' '
	CALL	__lt
	OR	EAX,EAX
	JNZ	short _2_203
_2_207:		; if(str1[k] < ' ') break;
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX] ; str1[0] address
	LEA	EDX,[EBP-4]
	MOV	EAX,[EDX] ; k value
	ADD	EAX,EBX	; str1[k] address
	MOVSX	EBX,BYTE [EAX] ; str1[k] value
	MOV	EAX,32	; ' '
	CALL	__lt
	OR	EAX,EAX
	JNZ	short _2_203
_2_209:
	LEA	EBX,[EBP-4] ; ++k;
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
	JMP	short _2_202
_2_203:		; if(an(str1[k]) || an(str2[k]))
	LEA	EAX,[EBP+16]
	MOV	EBX,[EAX] ; str1[0] address
	LEA	EDX,[EBP-4] ; k address
	MOV	EAX,[EDX] ; k value
	ADD	EBX,EAX	; str1[k] address
	MOVSX	EAX,BYTE [EBX] ; str1[k] value
	PUSH	EAX
	;MOV	CL,1
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_216 ; true (return 0)
_2_214:
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX] ; str2[0] address
	LEA	EDX,[EBP-4] ; k address
	MOV	EAX,[EDX] ; k value
	ADD	EBX,EAX	; str2[k] address
	MOVSX	EAX,BYTE [EBX] ; str2[k] value
	PUSH	EAX
	;MOV	CL,1
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _2_211 ; false (return k value)
_2_216:
	XOR	EAX,EAX ; return 0;
	MOV	ESP,EBP
	POP	EBP
	RETN
_2_211:
	LEA	EBX,[EBP-4] ; return k;
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

_nextop:	; nextop(list) char *list; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; char op[4];
	XOR	EAX,EAX	; opindex = 0;
	MOV	DWORD [_opindex],EAX
	CALL	_blanks	; blanks();
_2_218:		; while(1) {
	XOR	EAX,EAX ; 0
	MOV	DWORD [_opsize],EAX ; opsize = 0;
_2_220:		; while(*list > ' ')
	LEA	EBX,[EBP+8] ; list
	MOV	EAX,[EBX]
	MOVSX	EBX,BYTE [EAX] ; *list
	MOV	EAX,32	; ' '
	CALL	__gt
	OR	EAX,EAX
	JE	short _2_221
_2_222:		; op[opsize++] = *list++;
	LEA	EBX,[EBP-4] ; op[0]
	MOV	EAX,[_opsize]
	;INC	EAX
	;MOV	DWORD [_opsize],EAX
	;DEC	EAX
	INC	DWORD [_opsize]
	ADD	EBX,EAX ; op[opsize++]
	LEA	EDX,[EBP+8]
	MOV	ECX,[EDX]
	;INC	ECX
	;MOV	[EDX],ECX
	;DEC	ECX
	INC	DWORD [EDX] ; list++
	MOVSX	EAX,BYTE [ECX] ; *list
	MOV	[EBX],AL
	JMP	short _2_220
_2_221:		; if(opsize = streq(lptr, op))
	LEA	EBX,[EBP-4] ; op[0]
	MOV	EAX,[_opsize]
	ADD	EBX,EAX
	XOR	EAX,EAX ; 0
	MOV	[EBX],AL ; op[opsize] = 0;
		; if(opsize = streq(lptr, op))
	MOV	EAX,[_lptr]
	PUSH	EAX
	LEA	EAX,[EBP-4] ; op
	PUSH	EAX
	CALL	_streq
	ADD	ESP,8
	MOV	DWORD [_opsize],EAX
	OR	EAX,EAX
	JE	short _2_223
_2_224:	; if(*(lptr+opsize) != '=' &&
	MOV	EAX,[_lptr]
	;MOV	EBX,[_opsize]
	;ADD	EAX,EBX
	ADD	EAX,[_opsize]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,61 ; '='
	CALL	__ne
	OR	EAX,EAX
	;JE	short _2_226
	JZ	short _2_225
_2_228:	; *(lptr+opsize) != *(lptr+opsize-1))
	MOV	EDX,[_lptr]
	MOV	ECX,[_opsize]
	ADD	EDX,ECX
	;MOVSX	EAX,BYTE [EDX]
	;PUSH	EAX ; ++ ; *(lptr+opsize)
	MOVSX	EBX,BYTE [EDX]
	;MOV	EDX,[_lptr]
	;MOV	EAX,[_opsize]
	;ADD	EDX,EAX
	; EDX = lptr+opsize
	;MOV	EAX,1
	;SUB	EDX,EAX	; *(lptr+opsize-1)
	DEC	EDX
	MOVSX	EAX,BYTE [EDX]
	;POP	EBX ; ++ ; *(lptr+opsize)
	CALL	__ne
	OR	EAX,EAX
	;JNE	short _2_229
	;JMP	short _2_226
	JZ	short _2_225
	; eax = 1
;_2_229:
	;MOV	EAX,1
	;JMP	short _2_227
;_2_226:
	;XOR	EAX,EAX
;_2_227:
	;OR	EAX,EAX
	;JZ	short _2_225
_2_230:		; return 1;
	;MOV	EAX,1
	MOV	ESP,EBP
	POP	EBP
	RETN
_2_225:
_2_223:		; if(*list) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JZ	short _2_231
_2_232:		; ++list;
	LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
		; ++opindex;
	;MOV	EAX,[_opindex]
	;INC	EAX
	;MOV	DWORD [_opindex],EAX
	INC	DWORD [_opindex]
	;JMP	_2_233
	JMP	_2_218 ; } while
_2_231:
	;XOR	EAX,EAX
	; eax = 0
_2_219:
	MOV	ESP,EBP
	POP	EBP
	RETN
;_2_233:
;	JMP	_2_218
;_2_219:
;	MOV	ESP,EBP
;	POP	EBP
;	RETN

_blanks:
	;PUSH	EBP
	;MOV	EBP,ESP
_2_235:		; while(1) {
_2_237:		; while(ch) {
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JZ	short _2_238
_2_239:		; if(white()) gch();
	;XOR	CL,CL
	CALL	_white
	OR	EAX,EAX
	JZ	short _2_240 ; else return;
_2_241:
	;XOR	CL,CL
	CALL	_gch
	JMP	short _2_237
_2_240:
	;POP	EBP
	RETN
_2_238:		; if(line == mline) return;
	MOV	EBX,[_line]
	MOV	EAX,[_mline]
	CALL	__eq
	OR	EAX,EAX
	JNZ	short _2_240
_2_243:
	;XOR	CL,CL
	CALL	_preprocess ; preprocess();
	MOV	EAX,[_eof]  ; if(eof) break;
	OR	EAX,EAX
	JZ	short _2_235 ; jump to while(1)
_2_236:
	;POP	EBP
	RETN

_white:		; return (*lptr <= ' ' && *lptr);
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,[_lptr]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32	; ' '
	CALL	__le	; *lptr <= ' '
	OR	EAX,EAX
	JZ	short _2_248 ; false
_2_250:		; condition 1 is true and
	MOV	EBX,[_lptr] ; condition 2 is
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JZ	short _2_248 ; not true
_2_251:		; true
	MOV	EAX,1	; && *lptr > 0
	;JMP	short _2_249
_2_248:
	;XOR	EAX,EAX
_2_249:
	;POP	EBP
	RETN

_gch:
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4		; int c;
	;LEA	EAX,[EBP-4]
	;PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[_ch]	; if(c = ch)
	;POP	EBX
	MOV	[EBX],EAX
	OR	EAX,EAX
	JZ	short _2_253	; false
_2_254:			; true
	PUSH	EAX ; c
	MOV	EAX,1		; bump(1)
	PUSH	EAX
	;MOV	CL,1
	CALL	_bump
	;ADD	ESP,4
	POP	EAX
	POP	EAX ; c
;_2_253:
	;LEA	EBX,[EBP-4]	; return c;
	;MOV	EAX,[EBX]
_2_253:
	MOV	ESP,EBP
	POP	EBP
	RETN

_bump:
	PUSH	EBP		; bump(n) int n; {
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; n
	OR	EAX,EAX		; if(n) lptr += n;
	JZ	short _2_256	; false, else lptr = line;
_2_257:			; true, lptr += n;
	MOV	EBX,[_lptr]
	ADD	EBX,EAX		; lptr += n;
	;MOV	DWORD [_lptr],EBX
	JMP	short _2_258
_2_256:
	MOV	EBX,[_line]	; lptr = line;
	;MOV	DWORD [_lptr],EBX
_2_258:
	MOV	DWORD [_lptr],EBX
	;MOV	EBX,[_lptr]
	MOVSX	EAX,BYTE [EBX]	; nch = *lptr
	MOV	DWORD [_nch],EAX
	MOV	DWORD [_ch],EAX	; ch = nch = *lptr
	OR	EAX,EAX		; if(ch = nch = *lptr)
	JZ	short _2_259	; false
_2_260:			; true
	;MOV	EBX,[_lptr]	; nch = *(lptr+1);
	INC	EBX
	MOVSX	EAX,BYTE [EBX]	; *(lptr+1)
	MOV	DWORD [_nch],EAX
_2_259:
	POP	EBP
	RETN

_kill:
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EBX,[_line]
	XOR	EAX,EAX
	MOV	[EBX],AL ; *line = 0;
	;XOR	EAX,EAX
	PUSH	EAX ; 0
	;MOV	CL,1
	CALL	_bump	; bump(0);
	ADD	ESP,4
	;POP	EBP
	RETN

_skip:		; skip() {
	;PUSH	EBP
	;MOV	EBP,ESP
		; if(an(inbyte()))
	CALL	_inbyte
	PUSH	EAX
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _2_263 ; else
_2_264:
_2_265:		; while(an(ch)) gch();
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JZ	short _2_268
_2_267:
	CALL	_gch
	JMP	short _2_265
;_2_266:
	;JMP	short _2_268
_2_263: ; else
_2_269:		; while(an(ch) == 0) {
	MOV	EAX,[_ch]
	PUSH	EAX
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_270
_2_271:		; if(ch == 0) break;
	MOV	EAX,[_ch]
	OR	EAX,EAX
	JZ	short _2_270
;_2_273:
	;JMP	short _2_270
_2_272:		; gch();
	CALL	_gch
	JMP	short _2_269 ; while
_2_270:
_2_268:		; blanks();
	CALL	_blanks
	;POP	EBP
	RETN

_endst:
	;PUSH	EBP
	;MOV	EBP,ESP
	;XOR	CL,CL
	CALL	_blanks	; blanks();
		; return (streq(lptr, ";") || ch == 0);
	MOV	EAX,[_lptr] 
	PUSH	EAX
	MOV	EAX,SEMICOLON ; _2_274+0
	PUSH	EAX
	;MOV	CL,2
	CALL	_streq	; streq(lptr, ";")
	ADD	ESP,8
	OR	EAX,EAX
	;JNZ	short _2_275 ; EAX >= 1
	jZ	short _2_277
_2_275:
	MOV	EAX,1	; return(true);
_2_276:
	;POP	EBP
	RETN
_2_277:
	MOV	EBX,[_ch]
	XOR	EAX,EAX	; is ch == 0 ?
	CALL	__eq
	;OR	EAX,EAX
	;JNZ	short _2_275 ; eax = 1
_2_278:
	;XOR	EAX,EAX	; return(false);
	;JMP	short _2_276
	;POP	EBP
	RETN

_2_274:
;SEMICOLON: DB ";",0 ; DB 59,0

	; /* symbol table management functions */
_addsym: ; addsym(sname, id, type, size, value, lgpp, class)
		; char *sname, id, type;
		; int size, value, *lgpp, class;
	PUSH	EBP
	MOV	EBP,ESP
		; if(lgpp == &glbptr)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX] ; lgpp
	MOV	EAX,_glbptr ; address of glbptr
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_280 ; else {
_2_281:		; if(cptr2 = findglb(sname))
	LEA	EBX,[EBP+32]
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_findglb
	ADD	ESP,4
		; return cptr2;
	MOV	DWORD [_cptr2],EAX
	OR	EAX,EAX
	JE	short _2_282
_2_283:
	;MOV	EAX,[_cptr2]
	POP	EBP
	RETN
_2_282:		; if(cptr == 0)
	MOV	EAX,[_cptr]
	OR	EAX,EAX
	;JNE	short _2_284
	JNZ	short _2_286
_2_285:	; error("global symbol table overflow");
	;MOV	EAX,_2_279+0
	MOV	EAX,_gsto_
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	POP	EAX
		; return 0;
	XOR	EAX,EAX
	POP	EBP
	RETN
;_2_284:
	;JMP	short _2_286
_2_280:		; if(locptr > (ENDLOC-SYMMAX))
	MOV	EBX,[_locptr]
	;PUSH	EBX
		; ENDLOC = symtab+(NUMLOCS*SYMAVG)
	MOV	EAX,[_symtab]
	;MOV	EBX,400 ; NUMLOCS*SYMAVG
	;ADD	EAX,EBX
	;MOV	EBX,20	; SYMMAX = 16+4
	;SUB	EAX,EBX
	ADD	EAX,380 ; 400-20 ; ENDLOC-SYMMAX
	;POP	EBX
	CALL	__ugt
	OR	EAX,EAX
	JE	short _2_287
_2_288:
	;MOV	EAX,_2_279+29
	MOV	eax,_lsto_
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	POP	EAX
		; exit(ERRCODE);
	MOV	EAX,7
	PUSH	EAX
	;MOV	CL,1
	CALL	_OS_exit
	;ADD	ESP,4
	POP	EAX
_2_287:		; cptr = *lgpp;
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	MOV	DWORD [_cptr],EAX
_2_286:		; cptr[IDENT] = id;
	MOV	EBX,[_cptr] ; IDENT = 0
	LEA	EDX,[EBP+28] ; id
	MOVSX	EAX,BYTE [EDX]
	MOV	[EBX],AL
		; cptr[TYPE] = type;
	;MOV	EBX,[_cptr]
	;MOV	EAX,1 ; TYPE = 1
	;ADD	EBX,EAX
	INC	EBX
	LEA	EDX,[EBP+24] ; type
	MOVSX	EAX,BYTE [EDX]
	MOV	[EBX],AL
		; cptr[CLASS] = class;
	;MOV	EBX,[_cptr]
	;;MOV	EAX,2 ; CLASS = 2
	;;ADD	EBX,EAX
	;INC	EBX
	INC	EBX
	LEA	ECX,[EBP+8]
	MOV	EAX,[ECX] ; class
	MOV	[EBX],AL
	; putint(size, cptr + SIZE, INTSIZE);
	LEA	EBX,[EBP+20] ; size
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EBX,[_cptr]
	MOV	EAX,3 ; SIZE = 3
	ADD	EBX,EAX
	PUSH	EBX ; cptr+size
	;MOV	EAX,4 ; INTSIZE = 4
	INC	EAX ; 4
	PUSH	EAX
	;MOV	CL,3
	CALL	_putint
	ADD	ESP,12
	; putint(value, cptr + OFFSET, INTSIZE);
	LEA	EBX,[EBP+16] ; value
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EBX,[_cptr]
	MOV	EAX,7 ; OFFSET = 5+2
	ADD	EBX,EAX
	PUSH	EBX
	;MOV	EAX,4 ; INTSIZE = 4
	MOV	AL,4
	PUSH	EAX
	;MOV	CL,3
	CALL	_putint
	ADD	ESP,12
		; cptr3 = cptr2 = cptr + NAME;
	MOV	EAX,[_cptr]
	;MOV	EBX,11 ; NAME = 11
	;ADD	EAX,EBX
	ADD	EAX,11
	MOV	DWORD [_cptr2],EAX
	MOV	DWORD [_cptr3],EAX
_2_289:		;  while(an(*sname))
	LEA	EAX,[EBP+32]
	MOV	EBX,[EAX]
	MOVSX	EAX,BYTE [EBX] ; *sname
	PUSH	EAX
	;MOV	CL,1
	CALL	_an
	ADD	ESP,4
	OR	EAX,EAX
	JE	short _2_290
_2_291:		; *cptr2++ = *sname++;
	MOV	EDX,[_cptr2]
	;INC	EDX
	;MOV	DWORD [_cptr2],EDX
	;DEC	EDX
	INC	DWORD [_cptr2] ; *cptr++
	LEA	EBX,[EBP+32] ; addr sname
	MOV	ECX,[EBX] ; val sname
	;INC	ECX
	;MOV	[EBX],ECX
	;DEC	ECX
	INC	DWORD [EBX] ; *sname++
	;MOVSX	EAX,BYTE [ECX] ; *sname (char)
	MOV	AL,[ECX]
	MOV	[EDX],AL
	JMP	short _2_289 ; while
_2_290:		; if(lgpp == &locptr)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX] ; lgpp
	MOV	EAX,_locptr ; &locptr
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_292
_2_293: 	; *cptr2 = cptr2 - cptr3;
		; /* set length */
	MOV	EBX,[_cptr2]
	MOV	EAX,EBX
	SUB	EAX,[_cptr3]
	MOV	[EBX],AL
		; *lgpp = ++cptr2;
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX] ; *lgpp
	MOV	EAX,[_cptr2]
	INC	EAX
	MOV	DWORD [_cptr2],EAX
	MOV	[EBX],EAX
_2_292:		; return cptr;
	MOV	EAX,[_cptr]
	POP	EBP
	RETN

_2_279:
_gsto_: DB "global symbol table overflow",0
_lsto_: DB "local symbol table overflow",0

_search:
	; /* search for symbol match */
	; /* on return cptr points to slot found or empty slot */
	; search(sname, buf, len, end, max, off)
	; char *sname, *buf, *end;  int len, max, off; {
	PUSH	EBP
	MOV	EBP,ESP
	; cptr = cptr2 = buf+((hash(sname)%(max-1))*len);
	LEA	EBX,[EBP+24]
	MOV	EAX,[EBX]
	PUSH	EAX ; *	; value of buf
	LEA	EBX,[EBP+28]
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_hash
	ADD	ESP,4
		; eax = hash(sname)
	;PUSH	EAX
	LEA	EDX,[EBP+12] ; address of max
	MOV	EBX,[EDX] ; value of max
	;MOV	ECX,1
	;SUB	EBX,ECX
	DEC	EBX ; max - 1
	;POP	EAX
	CDQ
	IDIV	EBX ; hash(sname)%(max-1)
	;PUSH	EDX ; % (remainder)
	LEA	EBX,[EBP+20]
	MOV	EAX,[EBX] ; len
	;POP	EBX
	;IMUL	EBX
	IMUL	EDX
	POP	EBX ; * (buf)
	ADD	EAX,EBX
	MOV	DWORD [_cptr2],EAX
	MOV	DWORD [_cptr],EAX
_2_295:		; while(*cptr != NULL) {
	MOV	EBX,[_cptr]
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JE	short _2_296
_2_297:
	; if(astreq(sname, cptr+off, NAMEMAX)) return 1;
	LEA	EBX,[EBP+28] ; sname
	MOV	EAX,[EBX]
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	EAX,[_cptr]
	PUSH	EAX
	MOV	EAX,8
	PUSH	EAX
	;MOV	CL,3
	CALL	_astreq
	ADD	ESP,12
	OR	EAX,EAX
	JZ	short _2_298
	; eax = >= 1
_2_299:
	MOV	EAX,1
	POP	EBP
	RETN
_2_298:	; if((cptr = cptr+len) >= end) cptr = buf;
	MOV	EAX,[_cptr]
	LEA	EDX,[EBP+20] ; len
	MOV	EBX,[EDX]
	ADD	EBX,EAX ; cptr+len
	MOV	DWORD [_cptr],EBX
	LEA	EDX,[EBP+16] ; end
	MOV	EAX,[EDX]
	CALL	__uge
	OR	EAX,EAX
	JE	short _2_300
_2_301:
	LEA	EBX,[EBP+24] ; buf
	MOV	EAX,[EBX]
	MOV	DWORD [_cptr],EAX
_2_300:	; if(cptr == cptr2) return (cptr = 0);
	MOV	EBX,[_cptr]
	MOV	EAX,[_cptr2]
	CALL	__eq
	OR	EAX,EAX
	;JE	short _2_302
	JZ	short _2_295
_2_303:
	XOR	EAX,EAX
	MOV	DWORD [_cptr],EAX
	POP	EBP
	RETN
;_2_302:
	;JMP	_2_295

_2_296:		; return 0;
	XOR	EAX,EAX
	POP	EBP
	RETN

_hash:		; hash(sname) char *sname; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8	; int i, c;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; i = 0;
_2_305:	; while(c = *sname++) i = (i << 1) + c;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX] ; sname
	;INC	EBX
	;MOV	[EAX],EBX
	;DEC	EBX
	INC	DWORD [EAX]
	MOVSX	EAX,BYTE [EBX] ; *sname
	LEA	EBX,[EBP-8] ; c
	MOV	[EBX],EAX
	OR	EAX,EAX
	JE	short _2_306 ; c = 0
_2_307:		; c > 0
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	;MOV	ECX,1
	;SAL	EAX,CL
	SAL	EAX,1	; i << 1
	LEA	EDX,[EBP-8]
	MOV	ECX,[EDX]
	ADD	EAX,ECX ; + c
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX ; i = (i << 1) + c;
	JMP	short _2_305
_2_306:		; return i;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

_findglb: ; findglb(sname)  char *sname; {
	PUSH	EBP
	MOV	EBP,ESP
	; if(search(sname, STARTGLB, SYMMAX,
	;	    ENDGLB, NUMGLBS, NAME))
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,[_symtab]
	;MOV	EBX,400	; STARTGLB = symtab+NUMLOCS*SYMAVG
	;ADD	EAX,EBX
	ADD	EAX,400
	PUSH	EAX
	MOV	EAX,20	; SYMMAX
	PUSH	EAX
	MOV	EAX,[_symtab]
	;;MOV	EBX,400	; NUMGLBS*SYMMAX
	;;ADD	EAX,EBX
	;ADD	EAX,400
		; ENDGLB = (ENDLOC+(NUMGLBS-1)*SYMMAX)
	;;MOV	EBX,3980 ; (NUMGLBS-1)*SYMMAX ; 199*20
	;;ADD	EAX,EBX
	;ADD	EAX,3980
	ADD	EAX,4380 ; 3980+400
	PUSH	EAX
	MOV	EAX,200	; NUMGLBS
	PUSH	EAX
	MOV	EAX,11	; NAME
	PUSH	EAX
	;MOV	CL,6
	CALL	_search
	ADD	ESP,24
	OR	EAX,EAX
	JZ	short _2_309 ; return 0;
_2_310:		; return cptr;
	MOV	EAX,[_cptr]
_2_309:
	POP	EBP
	RETN
;_2_309:
	;XOR	EAX,EAX
	;POP	EBP
	;RETN

_findloc: ; findloc(sname) char *sname; {
	PUSH	EBP
	MOV	EBP,ESP
	; /* search backward for block locals */
	; cptr = locptr - 1;
	MOV	EAX,[_locptr]
	;MOV	EBX,1
	;SUB	EAX,EBX
	DEC	EAX
	MOV	DWORD [_cptr],EAX
_2_312:
	MOV	EBX,[_cptr]
	MOV	EAX,[_symtab]
	CALL	__ugt
	OR	EAX,EAX
	JE	short _2_313
_2_314:		; cptr = cptr - *cptr;
	;MOV	EBX,[_cptr]
	MOVSX	EAX,BYTE [EBX]
	SUB	EBX,EAX
	MOV	DWORD [_cptr],EBX
	; if(astreq(sname, cptr, NAMEMAX))
	;	return (cptr - NAME);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; sname
	PUSH	EAX
	MOV	EAX,[_cptr]
	PUSH	EAX
	MOV	EAX,8 ; NAMEMAX
	PUSH	EAX
	;MOV	CL,3
	CALL	_astreq
	ADD	ESP,12
	OR	EAX,EAX
	JE	short _2_315
_2_316:
	MOV	EAX,[_cptr]
	;MOV	EBX,11	; NAME
	;SUB	EAX,EBX
	SUB	EAX,11
_2_313:
	POP	EBP
	RETN
_2_315:		; cptr = cptr - NAME - 1;
	MOV	EAX,[_cptr]
	;;MOV	EBX,11
	;;SUB	EAX,EBX
	;SUB	EAX,11
	;;MOV	EBX,1
	;;SUB	EAX,EBX
	;DEC	EAX
	SUB	EAX,12
	MOV	DWORD [_cptr],EAX
	JMP	short _2_312
;_2_313:
	;XOR	EAX,EAX ; 0
	;POP	EBP
	;RETN

_nextsym:	; nextsym(entry) char *entry; {
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	EAX,11	; NAME = 7+4
	MOV	[EBX],EAX ; entry = entry + NAME;
_2_318:		; while(*entry++ >= ' ');
			; /* find length byte */
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	;DEC	EAX
	INC	DWORD [EBX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32 ; ' '
	CALL	__ge
	OR	EAX,EAX
	JNE	short _2_318
_2_319:		; return entry;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	POP	EBP
	RETN

_addwhile:	; addwhile(ptr)  int ptr[]; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
		; ptr[WQSP] = csp; /* and stk ptr */
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; WQSP = 0 (ptr[0])
	MOV	ECX,[_csp]
	MOV	[EAX],ECX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;;MOV	EBX,4
	;;ADD	EAX,EBX
	ADD	EAX,4	; WQLOOP = 1 (1*4)
	PUSH	EAX
	;XOR	CL,CL
	CALL	_getlabel ; ptr[WQLOOP] = getlabel();
		; /* and looping label */
	POP	EBX
	MOV	[EBX],EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;MOV	EBX,8
	;ADD	EAX,EBX
	ADD	EAX,8	; WQEXIT = 2 (2*4)
	PUSH	EAX
	;XOR	CL,CL
	CALL	_getlabel ; ptr[WQEXIT] = getlabel();
		; /* and exit label */
	POP	EBX
	MOV	[EBX],EAX
		; if(wqptr == WQMAX) {
	MOV	EAX,[_wq]
	;;MOV	EBX,120
	;;ADD	EAX,EBX
	;ADD	EAX,120	; WQTABSZ = 30 (30*4)
	;;MOV	EBX,12
	;;SUB	EAX,EBX
	;SUB	EAX,12	; WQSIZ = 3 (3*4)
	ADD	EAX,108	; WQMAX = wq+WQTABSZ-WQSIZ
	MOV	EBX,[_wqptr]
	CALL	__eq
	OR	EAX,EAX
	JE	short _2_322
_2_323:		; error("control statement nesting limit");
	;MOV	EAX,_2_321+0
	MOV	EAX,_err_csnl
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	POP	EAX
		; exit(ERRCODE);
	MOV	EAX,7
	PUSH	EAX
	;MOV	CL,1
	CALL	_OS_exit
	;ADD	ESP,4
	POP	EAX
_2_322:
	;LEA	EBX,[EBP-4]
	;XOR	EAX,EAX
	;MOV	[EBX],EAX
	LEA	EAX,[EBP-4]
	XOR	ECX,ECX
	MOV	[EAX],ECX ; k = 0;
_2_324:	; while (k < WQSIZ) *wqptr++ = ptr[k++];
	;LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,3	; WQSIZ
	CALL	__lt
	OR	EAX,EAX
	JE	short _2_325
_2_326:
	MOV	EDX,[_wqptr]
	ADD	DWORD [_wqptr],4
	LEA	EBX,[EBP+8] ; ptr
	MOV	ECX,[EBX]
	LEA	EAX,[EBP-4] ; k
	MOV	EBX,[EAX]
	INC	EBX
	MOV	[EAX],EBX ; k = k+1
	DEC	EBX
	SHL	EBX,1
	SHL	EBX,1	; k*4 (k*integersize)
	ADD	EBX,ECX
	MOV	ECX,[EBX] ; ptr[k]
	MOV	[EDX],ECX
	; EAX = EBP-4
	JMP	short _2_324
_2_325:
	MOV	ESP,EBP
	POP	EBP
	RETN

_2_321:
_err_csnl: DB "control statement nesting limit",0

_readwhil:	; readwhile(ptr) int *ptr; {
	PUSH	EBP
	MOV	EBP,ESP
		; if(ptr <= wq) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[_wq]
	CALL	__ule
	OR	EAX,EAX
	JE	short _2_328
_2_329:		; error("out of context");
	;MOV	EAX,_2_327+0
	MOV	EAX,_o_o_cont
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	POP	EAX
	XOR	EAX,EAX	; return 0;
	POP	EBP
	RETN
_2_328:		; else return (ptr - WQSIZ);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	;MOV	EBX,12	; WQSIZ = 3 (3*4)
	;SUB	EAX,EBX
	SUB	EAX,12
_2_330:
	POP	EBP
	RETN
;_2_330:
	;POP	EBP
	;RETN

_2_327:
_o_o_cont: DB "out of context",0

_delwhile:	; delwhile() {
	;PUSH	EBP
	;MOV	EBP,ESP
		; if(wqptr > wq) wqptr -= WQSIZ;
	MOV	EBX,[_wqptr]
	MOV	EAX,[_wq]
	CALL	__ugt
	OR	EAX,EAX
	JZ	short _2_332
_2_333:
	MOV	EAX,[_wqptr]
	;MOV	EBX,12
	;SUB	EAX,EBX
	SUB	EAX,12	; WQSIZ = 3 (3*4)
	MOV	DWORD [_wqptr],EAX
_2_332:
	;POP	EBP
	RETN

_alpha:		; alpha(c)  char c; {
	PUSH	EBP
	MOV	EBP,ESP
		; return (isalpha(c) || c == '_');
	LEA	EBX,[EBP+8]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_isalpha
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_335
_2_337:
	LEA	EAX,[EBP+8]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,95	; '_'
	CALL	__eq
	;OR	EAX,EAX
	;;JNE	short _2_335
	;JNZ	short _2_336 ; eax = 1
_2_338:
	;XOR	EAX,EAX ; eax = 0
	;JMP	short _2_336
	POP	EBP
	RETN
_2_335:
_2_340:
	MOV	EAX,1
_2_336:
	POP	EBP
	RETN

_an:		; an(c) char c; {
	PUSH	EBP
	MOV	EBP,ESP
		; return (alpha(c) || isdigit(c));
	LEA	EBX,[EBP+8]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_alpha
	ADD	ESP,4
	OR	EAX,EAX
	;JNE	short _2_340
	JNZ	short _2_341 ; eax = 1
_2_342:
	LEA	EBX,[EBP+8]
	MOVSX	EAX,BYTE [EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_isdigit
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _2_340 ; eax > 0
_2_343:
	;XOR	EAX,EAX ; eax = 0
	;JMP	short _2_341
_2_341:
	POP	EBP
	RETN

;_2_340:
;	MOV	EAX,1
;_2_341:
;	POP	EBP
;	RETN

_getlabel:	; getlabel() {
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,[_nxtlab] ; return(++nxtlab);
	INC	EAX
	MOV	DWORD [_nxtlab],EAX
	;POP	EBP
	RETN

_getint:
	; getint(addr, len) char *addr; int len; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int i;
	; i = *(addr + --len);
	;	/* high order byte sign extended */
	LEA	EBX,[EBP+12]
	MOV	ECX,[EBX] ; *addr
	LEA	EBX,[EBP+8] ; address of len
	MOV	EAX,[EBX] ; value of len
	DEC	EAX
	MOV	[EBX],EAX ; len = len - 1
	ADD	ECX,EAX
	MOVSX	EAX,BYTE [ECX]
	LEA	EBX,[EBP-4] ; i
	MOV	[EBX],EAX
_2_346:
	; while(len--) i = (i << 8) | *(addr + len) & 255;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; len
	DEC	EAX
	MOV	[EBX],EAX ; len--
	INC	EAX
	;OR	EAX,EAX
	JZ	short _2_347
_2_348:
	LEA	EBX,[EBP-4] ; i
	PUSH	EBX ; *	; address of i
	MOV	EAX,[EBX]
	MOV	CL,8
	SAL	EAX,CL
	PUSH	EAX ; ** ; i << 8
	LEA	EBX,[EBP+12] ; addr
	MOV	EAX,[EBX] ; *addr
	LEA	EDX,[EBP+8] ; len
	MOV	ECX,[EDX]
	ADD	ECX,EAX
	MOVSX	EAX,BYTE [ECX]
	AND	EAX,255
	POP	EBX ; **
	OR	EAX,EBX
	POP	EBX ; * ; address of i
	MOV	[EBX],EAX
	JMP	short _2_346
_2_347:			; return i;
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN

_putint:
	; putint(i, addr, len) char *addr; int i, len; {
	PUSH	EBP
	MOV	EBP,ESP
_2_350:		; while(len--) {
	LEA	EBX,[EBP+8] ; len
	MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	INC	EAX
	;OR	EAX,EAX
	JZ	short _2_351
_2_352:
	LEA	EBX,[EBP+12] ; *addr
	MOV	EDX,[EBX]
	INC	DWORD [EBX]
	LEA	EBX,[EBP+16] ; int i
	MOV	EAX,[EBX]
	MOV	[EDX],AL ; *addr++ = i;
	;LEA	EBX,[EBP+16]
	MOV	EAX,[EBX]
	;MOV	ECX,8
	MOV	CL,8
	SAR	EAX,CL	; i = i >> 8;
	MOV	[EBX],EAX
	JMP	short _2_350 ; }
_2_351:
	POP	EBP
	RETN

_lout:		; lout(line, fd)
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+12] ; line address
	MOV	EAX,[EBX]    ; line
	PUSH	EAX
	LEA	EBX,[EBP+8]  ; fd address
	MOV	EAX,[EBX]    ; fd (file number)
	; TRDOS 386
	CMP	EAX, -1	; is STDOUT/STDERR ?
	JE	short _lout_@ ;yes
	;
	PUSH	EAX
	;MOV	CL,2
	CALL	_fputs	; fputs(line, fd);
	ADD	ESP,8
	MOV	EAX,10	; LF (not CRLF !)
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; fd
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc ; fputc(NEWLINE, fd);
	ADD	ESP,8
	POP	EBP
	RETN
_lout_@:	; TRDOS 386 Modification
	;MOV	CL,1
	CALL	_puts	; puts(line);
	;ADD	ESP,4
	POP	EAX
	;MOV	EAX,NEWLINE ; crlf
	;PUSH	EAX
	;CALL	_puts	; puts(crlf);
	;POP	EAX
	MOV	EAX,13	; putc(13);
	PUSH	EAX
	;MOV	CL,1
	CALL	_OS_putc
	POP	EAX
	MOV	EAX,10	; putc(10);
	PUSH	EAX
	;MOV	CL,1
	CALL	_OS_putc
	POP	EAX
	POP	EBP
	RETN

_illname:
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,err_ils ; _2_354+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_error	; error("illegal symbol");
	ADD	ESP,4
	;XOR	CL,CL
	CALL	_skip	; skip();
	;POP	EBP
	RETN
_2_354:
err_ils: DB "illegal symbol",0

_multidef:
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,err_alrd ; _2_355+0
_needlval_@:
	PUSH	EAX
	;MOV	CL,1
	CALL	_error	; error("already defined");
	ADD	ESP,4
	;POP	EBP
	RETN

_2_355:
err_alrd: DB "already defined",0

_needlval:
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,err_mblv ; _2_356+0
	;PUSH	EAX
	;;MOV	CL,1
	;CALL	_error	; error("must be lvalue");
	;ADD	ESP,4
	;;POP	EBP
	;RETN
	JMP	short _needlval_@

_2_356:
err_mblv: DB "must be lvalue",0

_noiferr:
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,err_nmif ; _2_357+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_error ; error("no matching #if...");
	;ADD	ESP,4
	POP	EAX
	XOR	EAX,EAX	; errflag = 0;
	MOV	DWORD [_errflag],EAX
	;POP	EBP
	RETN

_2_357:
err_nmif: DB "no matching #if...",0

	; TRDOS 386 modification 

_error:		; error(msg)
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,[_errflag] ; if(errflag)
	OR	EAX,EAX
	JZ	short _2_359 ; false
_2_360:		; return;
	POP	EBP
	RETN
_2_359:		; else
	;MOV	EAX,1	; errflag = 1;
	INC	EAX
	MOV	DWORD [_errflag],EAX
_2_361:
	MOV	EAX,[_line] ; lout(line, stderr);
	PUSH	EAX
	MOV	EAX,-1 ; write to STDERR/STDOUT (TRDOS 386)
	PUSH	EAX
	;MOV	CL,2
	CALL	_lout  ; lout(line, -1);
	ADD	ESP,8
	LEA	EBX,[EBP+8] ; errout(msg, stderr);
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,-1 ; write to STDERR/STDOUT (TRDOS 386)
	PUSH	EAX
	;MOV	CL,2
	CALL	_errout	; errout(msg, -1);
	ADD	ESP,8
	MOVSX	EAX,BYTE [_alarm] ; if(alarm)
	OR	EAX,EAX
	JZ	short _2_362 ;false
_2_363:
	MOV	EAX,7
	PUSH	EAX
	;MOV	CL,1
	CALL	_OS_putc ; putc(7); (TRDOS 386)
	;ADD	ESP,4
	POP	EAX
_2_362:
	;MOVSX	EAX,BYTE [_pause]
	MOV	AL,BYTE [_pause]
	OR	EAX,EAX	; if(pause)
	JZ	short _2_364 ; false
_2_365:		; true
_2_366:		; while(fgetc(stderr) != NEWLINE);
	;XOR	CL,CL
	CALL	_OS_getc ; while(getc() != 13); (TRDOS 386)
	;ADD	ESP,4
	;MOV	EBX,EAX
	;MOV	EAX,10
	MOV	EBX,13	; TRDOS 386 Modification
	CALL	__ne
	OR	EAX,EAX
	JNZ	short _2_366 ; jump to while(getc() != 13)
_2_367:
_2_364:
	MOV	EAX,[_listfp] ; if(listfp > 0)
	OR	EAX,EAX
	JNG	short _2_369
	;JZ	short _2_369 ; TRDOS 386
_2_370:		; errout(msg, listfp);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	MOV	EAX,[_listfp]
	PUSH	EAX
	;MOV	CL,2
	CALL	_errout
	ADD	ESP,8
_2_369:
	POP	EBP
	RETN

_errout: 	; errout(msg, fp)
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int k;
	;LEA	EAX,[EBP-4]
	;PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[_line]
	;MOV	EBX,2
	;ADD	EAX,EBX
	ADD	EAX,2
	;POP	EBX
	MOV	[EBX],EAX
_2_372:
	LEA	EAX,[EBP-4] ; while(k++ <= lptr)
	MOV	EBX,[EAX]
	INC	DWORD [EAX]
	MOV	EAX,[_lptr]
	CALL	__ule
	OR	EAX,EAX
	JZ	short _2_373 ; false
_2_374:
	MOV	EAX,32	; ' '
	PUSH	EAX
	LEA	EBX,[EBP+8] ; fp address
	MOV	EAX,[EBX]   ; fp
	PUSH	EAX
	;MOV	CL,2
; (if fp = -1, _OS_fputc will be redirected to _OS_putc)
; (_OS_putc writes char to STDOUT/STDERR)
	CALL	_OS_fputc
	ADD	ESP,8
	JMP	short _2_372
_2_373:
	MOV	EAX,fsbs ; _2_371+0 ; "/\"
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; fp
	PUSH	EAX
	;MOV	CL,2
	CALL	_lout	; lout("/\\", fp);
	ADD	ESP,8
	MOV	EAX,fsas ; _2_371+3 ; "**** "
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
; (if fp = -1, _OS_fputc in _fputs 
;  will be redirected to _OS_putc -in OSFUNCS.ASM-)
; (_OS_putc writes char to STDOUT/STDERR)
	PUSH	EAX
	;MOV	CL,2
	CALL	_fputs	; fputs("**** ", fp);
	ADD	ESP,8
_2_377:		; TRDOS 386
	LEA	EBX,[EBP+12] ; address of msg address
	MOV	EAX,[EBX]   ; msg address (message's itself)
	PUSH	EAX
	LEA	EBX,[EBP+8] ; fp address
	MOV	EAX,[EBX]   ; fp (file number)
	PUSH	EAX
	;MOV	CL,2
	CALL	_lout	; lout(msg, fp);
	;ADD	ESP,8
	MOV	ESP,EBP
	POP	EBP
	RETN

_2_371:
fsbs: DB "/\",0 ; 47,92,0
fsas: DB "**** ",0 ; 42,42,42,42,32,0
