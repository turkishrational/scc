; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 26/09/2024
; -----------------------------------------------------------
; Derived from 'cc2.asm' file of KolibriOS SCC source code
; 2024

_preprocess:
PUSH EBP
MOV EBP,ESP
ADD ESP,-8
MOV EAX,[_ccode]
OR EAX,EAX
JNE _2_3
JMP _2_2
_2_3:
MOV EAX,[_mline]
MOV DWORD [_line],EAX
XOR CL,CL
CALL _ifline
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_5
JMP _2_4
_2_5:
MOV ESP,EBP
POP EBP
RET
_2_4:
JMP _2_6
_2_2:
XOR CL,CL
CALL _inline
MOV ESP,EBP
POP EBP
RET
_2_6:
MOV EAX,-1
MOV DWORD [_pptr],EAX
_2_7:
MOV EAX,[_ch]
MOV EBX,EAX
;;;		; TRDOS 386 modification
MOV  EAX,13	; CR
CALL __ne
OR   EAX,EAX
JZ   short _2_9
;;;
MOV EAX,10
CALL __ne
OR EAX,EAX
JNE _2_11
JMP _2_9
_2_11:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_12
JMP _2_9
_2_12:
MOV EAX,1
JMP _2_10
_2_9:
XOR EAX,EAX
_2_10:
OR EAX,EAX
JNE _2_13
JMP _2_8
_2_13:
XOR CL,CL
CALL _white
OR EAX,EAX
JNE _2_15
JMP _2_14
_2_15:
MOV EAX,32
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
_2_16:
XOR CL,CL
CALL _white
OR EAX,EAX
JNE _2_18
JMP _2_17
_2_18:
XOR CL,CL
CALL _gch
JMP _2_16
_2_17:
JMP _2_19
_2_14:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,34
CALL __eq
OR EAX,EAX
JNE _2_21
JMP _2_20
_2_21:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
XOR CL,CL
CALL _gch
_2_22:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,34
CALL __ne
OR EAX,EAX
JE _2_28
JMP _2_24
_2_28:
MOV EAX,[_lptr]
MOV EBX,EAX
MOV EAX,1
XCHG EAX,EBX
SUB EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,92
CALL __eq
OR EAX,EAX
JNE _2_29
JMP _2_25
_2_29:
MOV EAX,[_lptr]
MOV EBX,EAX
MOV EAX,2
XCHG EAX,EBX
SUB EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,92
CALL __ne
OR EAX,EAX
JNE _2_30
JMP _2_25
_2_30:
MOV EAX,1
JMP _2_26
_2_25:
XOR EAX,EAX
_2_26:
OR EAX,EAX
JE _2_31
JMP _2_24
_2_31:
XOR EAX,EAX
JMP _2_27
_2_24:
MOV EAX,1
_2_27:
OR EAX,EAX
JNE _2_32
JMP _2_23
_2_32:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_34
JMP _2_33
_2_34:
MOV EAX,_2_1+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
JMP _2_23
_2_33:
XOR CL,CL
CALL _gch
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_22
_2_23:
XOR CL,CL
CALL _gch
MOV EAX,34
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_35
_2_20:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,39
CALL __eq
OR EAX,EAX
JNE _2_37
JMP _2_36
_2_37:
MOV EAX,39
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
XOR CL,CL
CALL _gch
_2_38:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,39
CALL __ne
OR EAX,EAX
JE _2_44
JMP _2_40
_2_44:
MOV EAX,[_lptr]
MOV EBX,EAX
MOV EAX,1
XCHG EAX,EBX
SUB EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,92
CALL __eq
OR EAX,EAX
JNE _2_45
JMP _2_41
_2_45:
MOV EAX,[_lptr]
MOV EBX,EAX
MOV EAX,2
XCHG EAX,EBX
SUB EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,92
CALL __ne
OR EAX,EAX
JNE _2_46
JMP _2_41
_2_46:
MOV EAX,1
JMP _2_42
_2_41:
XOR EAX,EAX
_2_42:
OR EAX,EAX
JE _2_47
JMP _2_40
_2_47:
XOR EAX,EAX
JMP _2_43
_2_40:
MOV EAX,1
_2_43:
OR EAX,EAX
JNE _2_48
JMP _2_39
_2_48:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_50
JMP _2_49
_2_50:
MOV EAX,_2_1+9
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
JMP _2_39
_2_49:
XOR CL,CL
CALL _gch
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_38
_2_39:
XOR CL,CL
CALL _gch
MOV EAX,39
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_51
_2_36:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_55
JMP _2_53
_2_55:
MOV EAX,[_nch]
MOV EBX,EAX
MOV EAX,42
CALL __eq
OR EAX,EAX
JNE _2_56
JMP _2_53
_2_56:
MOV EAX,1
JMP _2_54
_2_53:
XOR EAX,EAX
_2_54:
OR EAX,EAX
JNE _2_57
JMP _2_52
_2_57:
MOV EAX,2
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
_2_58:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,42
CALL __eq
OR EAX,EAX
JNE _2_62
JMP _2_60
_2_62:
MOV EAX,[_nch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_63
JMP _2_60
_2_63:
MOV EAX,1
JMP _2_61
_2_60:
XOR EAX,EAX
_2_61:
OR EAX,EAX
JE _2_64
JMP _2_59
_2_64:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_66
JMP _2_65
_2_66:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_67
_2_65:
XOR CL,CL
CALL _ifline
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_69
JMP _2_68
_2_69:
JMP _2_59
_2_68:
_2_67:
JMP _2_58
_2_59:
MOV EAX,2
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_70
_2_52:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_74
JMP _2_72
_2_74:
MOV EAX,[_nch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_75
JMP _2_72
_2_75:
MOV EAX,1
JMP _2_73
_2_72:
XOR EAX,EAX
_2_73:
OR EAX,EAX
JNE _2_76
JMP _2_71
_2_76:
MOV EAX,2
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
_2_77:
MOV EAX,[_ch]
MOV EBX,EAX
;;;		; TRDOS 386 modification
MOV  EAX,13	; CR
CALL __ne
OR   EAX,EAX
JZ   short _2_78
;;;
MOV EAX,10
CALL __ne
OR EAX,EAX
JNE _2_79
JMP _2_78
_2_79:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_81
JMP _2_80
_2_81:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_82
_2_80:
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_84
JMP _2_83
_2_84:
JMP _2_78
_2_83:
_2_82:
JMP _2_77
_2_78:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_85
_2_71:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_87
JMP _2_86
_2_87:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_88:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_92
JMP _2_90
_2_92:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,8
CALL __lt
OR EAX,EAX
JNE _2_93
JMP _2_90
_2_93:
MOV EAX,1
JMP _2_91
_2_90:
XOR EAX,EAX
_2_91:
OR EAX,EAX
JNE _2_94
JMP _2_89
_2_94:
MOV EAX,_msname
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
POP EBX
ADD EAX,EBX
PUSH EAX
MOV EAX,[_ch]
POP EBX
MOV [EBX],AL
XOR CL,CL
CALL _gch
JMP _2_88
_2_89:
MOV EAX,_msname
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
MOV EAX,_msname
PUSH EAX
MOV EAX,[_macn]
PUSH EAX
MOV EAX,11
PUSH EAX
MOV EAX,[_macn]
MOV EBX,3300
ADD EAX,EBX
PUSH EAX
MOV EAX,300
PUSH EAX
XOR EAX,EAX
PUSH EAX
MOV CL,6
CALL _search
ADD ESP,24
OR EAX,EAX
JNE _2_96
JMP _2_95
_2_96:
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_cptr]
MOV EBX,9
ADD EAX,EBX
PUSH EAX
MOV EAX,2
PUSH EAX
MOV CL,2
CALL _getint
ADD ESP,8
POP EBX
MOV [EBX],EAX
_2_97:
LEA EAX,[EBP-8]
PUSH EAX
MOV EAX,[_macq]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
OR EAX,EAX
JNE _2_99
JMP _2_98
_2_99:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_97
_2_98:
_2_100:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_102
JMP _2_101
_2_102:
XOR CL,CL
CALL _gch
JMP _2_100
_2_101:
JMP _2_103
_2_95:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_104:
LEA EAX,[EBP-8]
PUSH EAX
MOV EAX,_msname
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
OR EAX,EAX
JNE _2_106
JMP _2_105
_2_106:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_104
_2_105:
_2_103:
JMP _2_107
_2_86:
XOR CL,CL
CALL _gch
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
_2_107:
_2_85:
_2_70:
_2_51:
_2_35:
_2_19:
JMP _2_7
_2_8:
MOV EAX,[_pptr]
MOV EBX,EAX
MOV EAX,127
CALL __ge
OR EAX,EAX
JNE _2_109
JMP _2_108
_2_109:
MOV EAX,_2_1+23
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
_2_108:
XOR EAX,EAX
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
MOV EAX,[_pline]
MOV DWORD [_line],EAX
XOR EAX,EAX
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
MOV ESP,EBP
POP EBP
RET
_2_1 DB 110,111,32,113,117,111,116,101,0,110
 DB 111,32,97,112,111,115,116,114,111,112
 DB 104,101,0,108,105,110,101,32,116,111
 DB 111,32,108,111,110,103,0

_keepch:		; keepch(c)
PUSH EBP
MOV  EBP,ESP
MOV  EBX,[_pptr]	; if(pptr < LINEMAX)
MOV  EAX,127
CALL __lt
OR   EAX,EAX
JZ   short _2_111 	; false
_2_112:			; pline[++pptr] = c;
MOV  EAX,[_pptr]
INC  EAX
MOV  DWORD [_pptr],EAX
MOV  EBX,[_pline]
ADD  EAX,EBX
PUSH EAX
LEA  EBX,[EBP+8] ; char c;
MOVSX EAX,BYTE [EBX]
POP  EBX
MOV  [EBX],AL
_2_111:
POP  EBP
RETN

_ifline:
PUSH EBP
MOV EBP,ESP
_2_114:
XOR CL,CL
CALL _inline
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_117
JMP _2_116
_2_117:
POP EBP
RET
_2_116:
MOV EAX,_2_113+0
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_119
JMP _2_118
_2_119:
MOV EAX,[_iflevel]
INC EAX
MOV DWORD [_iflevel],EAX
MOV EAX,[_skipleve]
OR EAX,EAX
JNE _2_121
JMP _2_120
_2_121:
JMP _2_114
_2_120:
MOV EAX,_msname
PUSH EAX
MOV CL,1
CALL _symname
ADD ESP,4
MOV EAX,_msname
PUSH EAX
MOV EAX,[_macn]
PUSH EAX
MOV EAX,11
PUSH EAX
MOV EAX,[_macn]
MOV EBX,3300
ADD EAX,EBX
PUSH EAX
MOV EAX,300
PUSH EAX
XOR EAX,EAX
PUSH EAX
MOV CL,6
CALL _search
ADD ESP,24
OR EAX,EAX
JE _2_123
JMP _2_122
_2_123:
MOV EAX,[_iflevel]
MOV DWORD [_skipleve],EAX
_2_122:
JMP _2_114
_2_118:
MOV EAX,_2_113+7
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_125
JMP _2_124
_2_125:
MOV EAX,[_iflevel]
INC EAX
MOV DWORD [_iflevel],EAX
MOV EAX,[_skipleve]
OR EAX,EAX
JNE _2_127
JMP _2_126
_2_127:
JMP _2_114
_2_126:
MOV EAX,_msname
PUSH EAX
MOV CL,1
CALL _symname
ADD ESP,4
MOV EAX,_msname
PUSH EAX
MOV EAX,[_macn]
PUSH EAX
MOV EAX,11
PUSH EAX
MOV EAX,[_macn]
MOV EBX,3300
ADD EAX,EBX
PUSH EAX
MOV EAX,300
PUSH EAX
XOR EAX,EAX
PUSH EAX
MOV CL,6
CALL _search
ADD ESP,24
OR EAX,EAX
JNE _2_129
JMP _2_128
_2_129:
MOV EAX,[_iflevel]
MOV DWORD [_skipleve],EAX
_2_128:
JMP _2_114
_2_124:
MOV EAX,_2_113+15
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_131
JMP _2_130
_2_131:
MOV EAX,[_iflevel]
OR EAX,EAX
JNE _2_133
JMP _2_132
_2_133:
MOV EAX,[_skipleve]
PUSH EAX
MOV EAX,[_iflevel]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_135
JMP _2_134
_2_135:
XOR EAX,EAX
MOV DWORD [_skipleve],EAX
JMP _2_136
_2_134:
MOV EAX,[_skipleve]
OR EAX,EAX
JE _2_138
JMP _2_137
_2_138:
MOV EAX,[_iflevel]
MOV DWORD [_skipleve],EAX
_2_137:
_2_136:
JMP _2_139
_2_132:
XOR CL,CL
CALL _noiferr
_2_139:
JMP _2_114
_2_130:
MOV EAX,_2_113+21
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_141
JMP _2_140
_2_141:
MOV EAX,[_iflevel]
OR EAX,EAX
JNE _2_143
JMP _2_142
_2_143:
MOV EAX,[_skipleve]
PUSH EAX
MOV EAX,[_iflevel]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_145
JMP _2_144
_2_145:
XOR EAX,EAX
MOV DWORD [_skipleve],EAX
_2_144:
MOV EAX,[_iflevel]
DEC EAX
MOV DWORD [_iflevel],EAX
JMP _2_146
_2_142:
XOR CL,CL
CALL _noiferr
_2_146:
JMP _2_114
_2_140:
MOV EAX,[_skipleve]
OR EAX,EAX
JNE _2_148
JMP _2_147
_2_148:
JMP _2_114
_2_147:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_150
JMP _2_149
_2_150:
JMP _2_114
_2_149:
JMP _2_115
JMP _2_114
_2_115:
POP EBP
RET
_2_113 DB 35,105,102,100,101,102,0,35,105,102
 DB 110,100,101,102,0,35,101,108,115,101
 DB 0,35,101,110,100,105,102,0

_inline:
PUSH EBP
MOV  EBP,ESP
ADD  ESP,-8	; int k, unit;
MOV  EBX,[_input] ; if(input == EOF) openfile();
MOV  EAX,-1
CALL __eq
OR   EAX,EAX
JZ   short _2_152
_2_153:
XOR  CL,CL
CALL _openfile	; openfile();
_2_152:
MOV  EAX,[_eof]	; if(eof) return;
OR   EAX,EAX
JZ   short _2_154
_2_155:
MOV  ESP,EBP
POP  EBP
RETN
_2_154:
MOV  EAX,[_input2] ; if((unit = input2) == EOF)
LEA  EBX,[EBP-8]
MOV  [EBX],EAX	; unit = input2
;MOV EBX,EAX
;MOV EAX,-1	; EOF
MOV  EBX,-1
CALL __eq
OR   EAX,EAX
JZ   short _2_156 ; false
_2_157:		; true
LEA  EBX,[EBP-8] ; unit
MOV  EAX,[_input]
MOV  [EBX],EAX	; unit = input;
_2_156:	 ; if(fgets(line, LINEMAX, unit) == NULL) {
MOV  EAX,[_line]
PUSH EAX
MOV  EAX,127	; LINEMAX
PUSH EAX
LEA  EBX,[EBP-8]
MOV  EAX,[EBX]	; unit
PUSH EAX
MOV  CL,3
CALL _fgets
ADD  ESP,12
OR   EAX,EAX	 ; NULL ?
JNZ  short _2_158 ; no, false
_2_159:		; yes, true
LEA  EBX,[EBP-8] ; unit
MOV  EAX,[EBX]
PUSH EAX
MOV  CL,1
CALL _OS_fclose	; fclose(unit);
;ADD ESP,4
POP  EAX
MOV  EBX,[_input2]
MOV  EAX,-1
CALL __ne	; if(input2 != EOF)
OR   EAX,EAX
JZ   short _2_160 ; false
_2_161:		; true
MOV  EAX,-1	; input2 = EOF;
MOV  DWORD [_input2],EAX
JMP  short _2_162
_2_160:		; else
;MOV EAX,-1
DEC  EAX
;eax = -1
MOV  DWORD [_input],EAX ; input  = EOF;
_2_162:
MOV  EBX,[_line]
XOR  EAX,EAX
MOV  [EBX],AL	; *line = NULL;
JMP  short _2_163
_2_158:		; else if(listfp)
MOV  EBX,[_listfp]
OR   EBX,EBX
JZ   short _2_164 ; false
_2_165:
;MOV EBX,[_listfp] ; if(listfp == output)
MOV  EAX,[_output]
CALL __eq
OR   EAX,EAX
JZ   short _2_166 ; false
_2_167:		; true
MOV  EAX,59	; ';'
PUSH EAX
MOV  EAX,[_output]
PUSH EAX
MOV  CL,2
CALL _OS_fputc	; fputc(';', output);
ADD  ESP,8
_2_166:
MOV  EAX,[_line]
PUSH EAX
MOV  EAX,[_listfp]
PUSH EAX
MOV  CL,2
CALL _fputs	; fputs(line, listfp);
ADD  ESP,8
_2_164:
_2_163:
XOR  EAX,EAX
PUSH EAX
MOV  CL,1
CALL _bump	; bump(0);
ADD  ESP,4
MOV  ESP,EBP
POP  EBP
RETN

_inbyte:
PUSH EBP
MOV  EBP,ESP
_2_169:
MOV  EAX,[_ch]	; while(ch == 0) {
OR   EAX,EAX
JNZ  short _2_170
_2_171:
MOV  EAX,[_eof]	; if(eof) return 0;
OR   EAX,EAX
JZ   short _2_172
_2_173:
XOR  EAX,EAX	; return(0);
POP  EBP
RETN
_2_172:
XOR  CL,CL
CALL _preprocess ; preprocess();	
JMP  short _2_169
_2_170:
XOR  CL,CL
CALL _gch	; return gch();
POP  EBP
RETN

_symname:	; symname(sname)
PUSH EBP
MOV  EBP,ESP
ADD  ESP,-8	; int k;char c;
XOR  CL,CL
CALL _blanks	; blanks();
MOV  EAX,[_ch]
PUSH EAX
MOV  CL,1
CALL _alpha	; if(alpha(ch) == 0)
ADD  ESP,4
OR   EAX,EAX
JNZ  short _2_175 ; false
_2_176:		; return (*sname = 0);
LEA  EAX,[EBP+8]
MOV  EBX,[EAX]
XOR  EAX,EAX
MOV  [EBX],AL
;MOV ESP,EBP
;POP EBP
;RETN
JMP  short _2_180 ; TRDOS 386 modification 
_2_175:		; k = 0;
LEA  EBX,[EBP-4]
XOR  EAX,EAX
MOV  [EBX],EAX
_2_177:		; while(an(ch)) {
MOV  EAX,[_ch]
PUSH EAX
MOV  CL,1
CALL _an	; an(ch)
ADD  ESP,4
OR   EAX,EAX
JZ   short _2_178
_2_179:
LEA  EBX,[EBP+8] 
MOV  EAX,[EBX]	; sname[0] address
;PUSH EAX
LEA  EBX,[EBP-4]
;MOV EAX,[EBX]
;POP EBX
ADD  EAX,[EBX]	; sname[k] address
PUSH EAX
XOR  CL,CL
CALL _gch
POP  EBX
MOV  [EBX],AL	 ; sname[k] = gch();
LEA  EAX,[EBP-4]
MOV  EBX,[EAX]
MOV  EAX,8
CALL __lt	; if(k < NAMEMAX) ++k;
OR   EAX,EAX
;JZ  short _2_180
JZ   short _2_177
_2_181:
LEA  EBX,[EBP-4] ; k address
;MOV EAX,[EBX]
;INC EAX
;MOV [EBX],EAX
INC  DWORD [EBX] ; ++k;
;_2_180:
JMP  short _2_177 ; jump to while(an(ch))
_2_178:
LEA  EAX,[EBP+8] ; sname[0] address
MOV  EBX,[EAX]
;PUSH EBX
;LEA EBX,[EBP-4]
;MOV EAX,[EBX]
;POP EBX
LEA  EAX,[EBP-4]		
ADD  EBX,[EAX]	; sname[k] address
XOR  EAX,EAX	; 0
MOV  [EBX],AL	; sname[k] = 0;
;MOV EAX,1
INC  EAX
_2_180:		; TRDOS 386 modification
MOV  ESP,EBP
POP  EBP
RETN

_need:
PUSH EBP
MOV  EBP,ESP
LEA  EBX,[EBP+8] ; str
MOV  EAX,[EBX]
PUSH EAX
MOV  CL,1
CALL _match	; if(match(str) == 0)
ADD  ESP,4
OR   EAX,EAX
JNZ  short _2_183
_2_184:
MOV  EAX,err_mt	; _2_182+0
PUSH EAX
MOV  CL,1
CALL _error	; error("missing token");
ADD  ESP,4
_2_183:
POP  EBP
RETN

_2_182:
err_mt: DB "missing token",0

_ns:
PUSH EBP
MOV  EBP,ESP
MOV  EAX,SEMICOLON ; _2_185+0
PUSH EAX
MOV  CL,1
CALL _match	; if(match(";") == 0)
ADD  ESP,4
OR   EAX,EAX
JNZ  short _2_186
_2_187:
MOV  EAX,err_nsc ; _2_185+2
PUSH EAX
MOV  CL,1
CALL _error	; error("no semicolon");
ADD  ESP,4
JMP  short _2_188
_2_186:		; else errflag = 0;
XOR  EAX,EAX
MOV  DWORD [_errflag],EAX
_2_188:
POP  EBP
RETN

_2_185:
SEMICOLON: DB ";",0 ; DB 59,0
err_nsc: DB "no semicolon",0

_match:
PUSH EBP
MOV  EBP,ESP
ADD  ESP,-4	; int k;
XOR  CL,CL
CALL _blanks	; blanks();
LEA  EAX,[EBP-4] ; if(k = streq(lptr, lit)) {
PUSH EAX
MOV  EAX,[_lptr]
PUSH EAX
LEA  EBX,[EBP+8] ; char *lit;
MOV  EAX,[EBX]
PUSH EAX
MOV  CL,2
CALL _streq
ADD  ESP,8
POP  EBX
MOV  [EBX],EAX
OR   EAX,EAX
JZ   short _2_190 ; false
_2_191:		; true
LEA  EBX,[EBP-4]
MOV  EAX,[EBX]
PUSH EAX
MOV  CL,1
CALL _bump	; bump(k);
;ADD ESP,4
POP  EAX
MOV  EAX,1	; return 1;
MOV  ESP,EBP
POP  EBP
RETN
_2_190:
;XOR EAX,EAX	; return 0;
;eax = 0
MOV  ESP,EBP
POP  EBP
RETN

_streq:		; streq(str1, str2)
PUSH EBP
MOV  EBP,ESP
;ADD ESP,-4	; int k;
;LEA EBX,[EBP-4]
XOR  EAX,EAX
;MOV [EBX],EAX	; k = 0;
PUSH EAX
_2_193:
LEA  EAX,[EBP+8] ; while (str2[k]) {
MOV  EBX,[EAX]	; str2
LEA  EAX,[EBP-4] ; k address
ADD  EBX,[EAX]	; add k value to str2
MOVSX EAX,BYTE [EBX] ; str2[k]
OR   EAX,EAX
JZ   short _2_194 ; return k;
_2_195:
LEA  EBX,[EBP+12] ; str1
MOV  EAX,[EBX]
LEA  EBX,[EBP-4]
ADD  EAX,[EBX]	; str1[k]
MOVSX EBX,BYTE [EAX]
PUSH EBX
LEA  EAX,[EBP+8] ; str2
MOV  EBX,[EAX]
LEA  EAX,[EBP-4]
ADD  EBX,[EAX]	; str2[k]
MOVSX EAX,BYTE [EBX]
POP  EBX
CALL __ne	; str1[k] != str2[k]
OR   EAX,EAX
JZ   short _2_196
_2_197:
XOR  EAX,EAX	; return 0;
MOV  ESP,EBP
POP  EBP
RETN
_2_196:
LEA  EBX,[EBP-4] ; ++k;
;MOV EAX,[EBX]
;INC EAX
;MOV [EBX],EAX
INC  DWORD [EBX]
JMP  short _2_193 ; jump to while (str2[k])
_2_194:
LEA  EBX,[EBP-4] ; return k;
MOV  EAX,[EBX]
MOV  ESP,EBP
POP  EBP
RETN

_amatch:	; amatch(lit, len)
PUSH EBP
MOV  EBP,ESP
ADD  ESP,-4	; int k;
XOR  CL,CL
CALL _blanks	; blanks();
;LEA EAX,[EBP-4]
;PUSH EAX	; k address
MOV  EAX,[_lptr]
PUSH EAX	; lptr
LEA  EBX,[EBP+12]
MOV  EAX,[EBX]
PUSH EAX	; lit
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]
PUSH EAX	; len
MOV  CL,3
CALL _astreq	; k = astreq(lptr, lit, len)
ADD  ESP,12
;POP EBX
LEA  EBX,[EBP-4] ; k address
MOV  [EBX],EAX
OR   EAX,EAX	; if(k) {
JZ   short _2_199 ; false
_2_200:		; true
;LEA EBX,[EBP-4]
;MOV EAX,[EBX]	; k
PUSH EAX
MOV  CL,1
CALL _bump	; bump(k);
;ADD ESP,4
POP  EAX
MOV  EAX,1	; return 1;
_2_199:		; (eax = 0)			
MOV  ESP,EBP
POP  EBP
RETN
;_2_199:
;eax = 0
;XOR  EAX,EAX	; return 0;
;MOV  ESP,EBP
;POP  EBP
;RETN

_astreq:	; astreq(str1, str2, len)
PUSH EBP
MOV  EBP,ESP
;ADD ESP,-4	; int k;
;LEA EBX,[EBP-4]
XOR  EAX,EAX
;MOV [EBX],EAX
PUSH EAX	; k = 0
_2_202:		; while (k < len) {
LEA  EBX,[EBP-4]
MOV  EAX,[EBX]	
PUSH EAX	; k
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]	; len
POP  EBX
CALL __lt	; is eax > ebx ?		
OR   EAX,EAX
JZ   short _2_203 ; no, false
_2_204:		; if(str1[k] != str2[k]) break;
LEA  EBX,[EBP+16]
MOV  EAX,[EBX]
PUSH EAX	; str1[0]
LEA  EBX,[EBP-4]
MOV  EAX,[EBX]	; k
POP  EBX
ADD  EBX,EAX
MOVSX EAX,BYTE [EBX] ; val str1[k]
PUSH EAX ; +
LEA  EBX,[EBP+12]
MOV  EAX,[EBX]
PUSH EAX	; str2[0]
LEA  EBX,[EBP-4]
MOV  EAX,[EBX]  ; k
POP  EBX
ADD  EBX,EAX
MOVSX EAX,BYTE [EBX] ; val str2[k]
POP  EBX ; +
CALL __ne
OR   EAX,EAX
JNZ  short _2_203
_2_205:		; if(str2[k] < ' ') break;
LEA  EBX,[EBP+12]
MOV  EAX,[EBX]
PUSH EAX	; str2[0] address
LEA  EBX,[EBP-4] ; k address
MOV  EAX,[EBX]	; k value
POP  EBX
ADD  EBX,EAX	; str2[k] address
MOVSX EAX,BYTE [EBX] ; str2[k] value
MOV  EBX,EAX
MOV  EAX,32	; ' '
CALL __lt
OR   EAX,EAX
JNZ  short _2_203
_2_207:		; if(str1[k] < ' ') break;
LEA  EBX,[EBP+16]
MOV  EAX,[EBX]
PUSH EAX	; str1[0] address
LEA  EBX,[EBP-4]
MOV  EAX,[EBX]
POP  EBX
ADD  EBX,EAX	; str1[k] address
MOVSX EAX,BYTE [EBX] ; str1[k] value
MOV  EBX,EAX
MOV  EAX,32	; ' '
CALL __lt
OR   EAX,EAX
JNZ  short _2_203
_2_209:
LEA  EBX,[EBP-4] ; ++k;
;MOV EAX,[EBX]
;INC EAX
;MOV [EBX],EAX
INC  DWORD [EBX]
JMP  _2_202
_2_203:		; if(an(str1[k]) || an(str2[k]))
LEA  EBX,[EBP+16]
MOV  EAX,[EBX]
PUSH EAX	; str1[0] address
LEA  EBX,[EBP-4]	; k address
MOV  EAX,[EBX]	; k value
POP  EBX
ADD  EBX,EAX	; str1[k] address
MOVSX EAX,BYTE [EBX] ; str1[k] value
PUSH EAX
MOV  CL,1
CALL _an
ADD  ESP,4
OR   EAX,EAX
JNZ  short _2_216 ; true (return 0)
_2_214:
LEA  EBX,[EBP+12]
MOV  EAX,[EBX]
PUSH EAX	 ; str2[0] address
LEA  EBX,[EBP-4] ; k address
MOV  EAX,[EBX]	; k value
POP  EBX
ADD  EBX,EAX	; str2[k] address
MOVSX EAX,BYTE [EBX] ; str2[k] value
PUSH EAX
MOV  CL,1
CALL _an
ADD  ESP,4
OR   EAX,EAX
JZ   short _2_211 ; false (return k value)
_2_216:
XOR  EAX,EAX 	; return 0;
MOV  ESP,EBP
POP  EBP
RETN
_2_211:
LEA  EBX,[EBP-4] ; return k;
MOV  EAX,[EBX]
MOV  ESP,EBP
POP  EBP
RETN

_nextop:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
XOR EAX,EAX
MOV DWORD [_opindex],EAX
XOR CL,CL
CALL _blanks
_2_218:
XOR EAX,EAX
MOV DWORD [_opsize],EAX
_2_220:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,32
CALL __gt
OR EAX,EAX
JNE _2_222
JMP _2_221
_2_222:
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_opsize]
INC EAX
MOV DWORD [_opsize],EAX
DEC EAX
POP EBX
ADD EAX,EBX
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
JMP _2_220
_2_221:
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_opsize]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
MOV EAX,[_lptr]
PUSH EAX
LEA EAX,[EBP-4]
PUSH EAX
MOV CL,2
CALL _streq
ADD ESP,8
MOV DWORD [_opsize],EAX
OR EAX,EAX
JNE _2_224
JMP _2_223
_2_224:
MOV EAX,[_lptr]
PUSH EAX
MOV EAX,[_opsize]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,61
CALL __ne
OR EAX,EAX
JNE _2_228
JMP _2_226
_2_228:
MOV EAX,[_lptr]
PUSH EAX
MOV EAX,[_opsize]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV EAX,[_lptr]
PUSH EAX
MOV EAX,[_opsize]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOV EAX,1
XCHG EAX,EBX
SUB EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
CALL __ne
OR EAX,EAX
JNE _2_229
JMP _2_226
_2_229:
MOV EAX,1
JMP _2_227
_2_226:
XOR EAX,EAX
_2_227:
OR EAX,EAX
JNE _2_230
JMP _2_225
_2_230:
MOV EAX,1
MOV ESP,EBP
POP EBP
RET
_2_225:
_2_223:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _2_232
JMP _2_231
_2_232:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
MOV EAX,[_opindex]
INC EAX
MOV DWORD [_opindex],EAX
JMP _2_233
_2_231:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET
_2_233:
JMP _2_218
_2_219:
MOV ESP,EBP
POP EBP
RET

_blanks:
PUSH EBP
MOV  EBP,ESP
_2_235:		; while(1) {
_2_237:		; while(ch) {
MOV  EAX,[_ch]
OR   EAX,EAX
JZ   short _2_238
_2_239:		; if(white()) gch();
XOR  CL,CL
CALL _white
OR   EAX,EAX
JZ   short _2_240 ; else return;
_2_241:
XOR  CL,CL
CALL _gch
JMP  short _2_237
_2_240:
POP  EBP
RETN
_2_238:		; if(line == mline) return;
MOV  EBX,[_line]
MOV  EAX,[_mline]
CALL __eq
OR   EAX,EAX
JNZ  short _2_240
_2_243:
XOR  CL,CL
CALL _preprocess ; preprocess();
MOV  EAX,[_eof]	; if(eof) break;
OR   EAX,EAX	
JZ   short _2_235 ; jump to while(1)
_2_236:
POP  EBP
RETN

_white:		; return (*lptr <= ' ' && *lptr);
PUSH EBP
MOV  EBP,ESP
MOV  EAX,[_lptr]
MOVSX EBX,BYTE [EAX]
MOV  EAX,32	; ' '
CALL __le	; *lptr <= ' '
OR   EAX,EAX
JZ   short _2_248 ; false
_2_250:		; condition 1 is true and
MOV  EBX,[_lptr] ; condition 2 is
MOVSX EAX,BYTE [EBX]
OR   EAX,EAX
JZ   short _2_248 ; not true
_2_251:		; true
MOV  EAX,1	; && *lptr > 0
;JMP short _2_249
_2_248:
;XOR EAX,EAX
_2_249:
POP  EBP
RETN

_gch:
PUSH EBP
MOV  EBP,ESP
ADD  ESP,-4		; int c;
;LEA EAX,[EBP-4]
;PUSH EAX
LEA  EBX,[EBP-4]
MOV  EAX,[_ch]		; if(c = ch)
;POP EBX
MOV  [EBX],EAX
OR   EAX,EAX
JZ   short _2_253	; false
_2_254:			; true
MOV  EAX,1		; bump(1)
PUSH EAX
MOV  CL,1
CALL _bump
;ADD ESP,4
POP  EAX
_2_253:
LEA  EBX,[EBP-4]	; return c;
MOV  EAX,[EBX]
MOV  ESP,EBP
POP  EBP
RETN

_bump:
PUSH EBP		; bump(n) int n; {
MOV  EBP,ESP
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]		; n
OR   EAX,EAX		; if(n) lptr += n;
JZ   short _2_256	; false, else lptr = line;
_2_257:			; true, lptr += n;
MOV  EBX,[_lptr]
ADD  EBX,EAX		; lptr += n;
;MOV DWORD [_lptr],EBX
JMP  short _2_258
_2_256:
MOV  EBX,[_line]	; lptr = line;
;MOV DWORD [_lptr],EBX
_2_258:
MOV  DWORD [_lptr],EBX
;MOV EBX,[_lptr]
MOVSX EAX,BYTE [EBX]	; nch = *lptr
MOV  DWORD [_nch],EAX
MOV  DWORD [_ch],EAX	; ch = nch = *lptr
OR   EAX,EAX		; if(ch = nch = *lptr)
JZ   short _2_259	; false
_2_260:			; true
;MOV EBX,[_lptr]	; nch = *(lptr+1);
INC  EBX
MOVSX EAX,BYTE [EBX]	; *(lptr+1)
MOV DWORD [_nch],EAX
_2_259:
POP  EBP
RETN

_kill:
;PUSH EBP
;MOV EBP,ESP
MOV  EBX,[_line]
XOR  EAX,EAX
MOV  [EBX],AL		; *line = 0;
;XOR EAX,EAX
PUSH EAX ; 0
MOV  CL,1
CALL _bump		; bump(0);
ADD  ESP,4
;POP EBP
RETN

_skip:
PUSH EBP
MOV EBP,ESP
XOR CL,CL
CALL _inbyte
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_264
JMP _2_263
_2_264:
_2_265:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_267
JMP _2_266
_2_267:
XOR CL,CL
CALL _gch
JMP _2_265
_2_266:
JMP _2_268
_2_263:
_2_269:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JE _2_271
JMP _2_270
_2_271:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_273
JMP _2_272
_2_273:
JMP _2_270
_2_272:
XOR CL,CL
CALL _gch
JMP _2_269
_2_270:
_2_268:
XOR CL,CL
CALL _blanks
POP EBP
RET

_endst:
PUSH EBP
MOV EBP,ESP
XOR CL,CL
CALL _blanks	; blanks();
	; return (streq(lptr, ";") || ch == 0);
MOV EAX,[_lptr] 
PUSH EAX
MOV EAX,SEMICOLON ; _2_274+0
PUSH EAX
MOV CL,2
CALL _streq	; streq(lptr, ";")
ADD ESP,8
OR EAX,EAX
JNZ short _2_275
_2_277:
MOV EBX,[_ch]
XOR EAX,EAX	; is ch == 0 ?
CALL __eq
;OR EAX,EAX
;JNZ short _2_275 ; eax = 1
_2_278:
;XOR EAX,EAX	; return(false);
JMP short _2_276
_2_275:
MOV EAX,1	; return(true);
_2_276:
POP EBP
RETN

_2_274:
;SEMICOLON: DB ";",0 ; DB 59,0

_addsym:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,_glbptr
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_281
JMP _2_280
_2_281:
LEA EAX,[EBP+32]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _findglb
ADD ESP,4
MOV DWORD [_cptr2],EAX
OR EAX,EAX
JNE _2_283
JMP _2_282
_2_283:
MOV EAX,[_cptr2]
POP EBP
RET
_2_282:
MOV EAX,[_cptr]
OR EAX,EAX
JE _2_285
JMP _2_284
_2_285:
MOV EAX,_2_279+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
XOR EAX,EAX
POP EBP
RET
_2_284:
JMP _2_286
_2_280:
MOV EAX,[_locptr]
PUSH EAX
MOV EAX,[_symtab]
MOV EBX,400
ADD EAX,EBX
MOV EBX,EAX
MOV EAX,20
XCHG EAX,EBX
SUB EAX,EBX
POP EBX
CALL __ugt
OR EAX,EAX
JNE _2_288
JMP _2_287
_2_288:
MOV EAX,_2_279+29
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
MOV EAX,7
PUSH EAX
MOV CL,1
CALL _OS_exit
ADD ESP,4
_2_287:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX, [EBX]
MOV DWORD [_cptr],EAX
_2_286:
MOV EAX,[_cptr]
PUSH EAX
LEA EAX,[EBP+28]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
MOV EAX,[_cptr]
MOV EBX,1
ADD EAX,EBX
PUSH EAX
LEA EAX,[EBP+24]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
MOV EAX,[_cptr]
MOV EBX,2
ADD EAX,EBX
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],AL
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_cptr]
MOV EBX,3
ADD EAX,EBX
PUSH EAX
MOV EAX,4
PUSH EAX
MOV CL,3
CALL _putint
ADD ESP,12
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_cptr]
MOV EBX,5
ADD EAX,EBX
MOV EBX,2
ADD EAX,EBX
PUSH EAX
MOV EAX,4
PUSH EAX
MOV CL,3
CALL _putint
ADD ESP,12
MOV EAX,[_cptr]
MOV EBX,11
ADD EAX,EBX
MOV DWORD [_cptr2],EAX
MOV DWORD [_cptr3],EAX
_2_289:
LEA EAX,[EBP+32]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_291
JMP _2_290
_2_291:
MOV EAX,[_cptr2]
INC EAX
MOV DWORD [_cptr2],EAX
DEC EAX
PUSH EAX
LEA EAX,[EBP+32]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
JMP _2_289
_2_290:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,_locptr
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_293
JMP _2_292
_2_293:
MOV EAX,[_cptr2]
PUSH EAX
MOV EAX,[_cptr2]
PUSH EAX
MOV EAX,[_cptr3]
POP EBX
XCHG EAX,EBX
SUB EAX,EBX
POP EBX
MOV [EBX],AL
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_cptr2]
INC EAX
MOV DWORD [_cptr2],EAX
POP EBX
MOV [EBX],EAX
_2_292:
MOV EAX,[_cptr]
POP EBP
RET
_2_279 DB 103,108,111,98,97,108,32,115,121,109
 DB 98,111,108,32,116,97,98,108,101,32
 DB 111,118,101,114,102,108,111,119,0,108
 DB 111,99,97,108,32,115,121,109,98,111
 DB 108,32,116,97,98,108,101,32,111,118
 DB 101,114,102,108,111,119,0

_search:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+24]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+28]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _hash
ADD ESP,4
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,1
XCHG EAX,EBX
SUB EAX,EBX
POP EBX
XCHG EAX,EBX
CDQ
IDIV EBX
MOV EAX,EDX
PUSH EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
IMUL EBX
POP EBX
ADD EAX,EBX
MOV DWORD [_cptr2],EAX
MOV DWORD [_cptr],EAX
_2_295:
MOV EAX,[_cptr]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _2_297
JMP _2_296
_2_297:
LEA EAX,[EBP+28]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_cptr]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
PUSH EAX
MOV EAX,8
PUSH EAX
MOV CL,3
CALL _astreq
ADD ESP,12
OR EAX,EAX
JNE _2_299
JMP _2_298
_2_299:
MOV EAX,1
POP EBP
RET
_2_298:
MOV EAX,[_cptr]
PUSH EAX
LEA EAX,[EBP+20]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV DWORD [_cptr],EAX
PUSH EAX
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
CALL __uge
OR EAX,EAX
JNE _2_301
JMP _2_300
_2_301:
LEA EAX,[EBP+24]
MOV EBX,EAX
MOV EAX, [EBX]
MOV DWORD [_cptr],EAX
_2_300:
MOV EAX,[_cptr]
PUSH EAX
MOV EAX,[_cptr2]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_303
JMP _2_302
_2_303:
XOR EAX,EAX
MOV DWORD [_cptr],EAX
POP EBP
RET
_2_302:
JMP _2_295
_2_296:
XOR EAX,EAX
POP EBP
RET

_hash:
PUSH EBP
MOV EBP,ESP
ADD ESP,-8
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_305:
LEA EAX,[EBP-8]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],EAX
OR EAX,EAX
JNE _2_307
JMP _2_306
_2_307:
LEA EAX,[EBP-4]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,1
MOV ECX,EAX
MOV EAX,EBX
SAL EAX,CL
PUSH EAX
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
POP EBX
MOV [EBX],EAX
JMP _2_305
_2_306:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET

_findglb:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_symtab]
MOV EBX,400
ADD EAX,EBX
PUSH EAX
MOV EAX,20
PUSH EAX
MOV EAX,[_symtab]
MOV EBX,400
ADD EAX,EBX
MOV EBX,3980
ADD EAX,EBX
PUSH EAX
MOV EAX,200
PUSH EAX
MOV EAX,11
PUSH EAX
MOV CL,6
CALL _search
ADD ESP,24
OR EAX,EAX
JNE _2_310
JMP _2_309
_2_310:
MOV EAX,[_cptr]
POP EBP
RET
_2_309:
XOR EAX,EAX
POP EBP
RET

_findloc:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_locptr]
MOV EBX,EAX
MOV EAX,1
XCHG EAX,EBX
SUB EAX,EBX
MOV DWORD [_cptr],EAX
_2_312:
MOV EAX,[_cptr]
PUSH EAX
MOV EAX,[_symtab]
POP EBX
CALL __ugt
OR EAX,EAX
JNE _2_314
JMP _2_313
_2_314:
MOV EAX,[_cptr]
PUSH EAX
MOV EAX,[_cptr]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
XCHG EAX,EBX
SUB EAX,EBX
MOV DWORD [_cptr],EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_cptr]
PUSH EAX
MOV EAX,8
PUSH EAX
MOV CL,3
CALL _astreq
ADD ESP,12
OR EAX,EAX
JNE _2_316
JMP _2_315
_2_316:
MOV EAX,[_cptr]
MOV EBX,EAX
MOV EAX,11
XCHG EAX,EBX
SUB EAX,EBX
POP EBP
RET
_2_315:
MOV EAX,[_cptr]
MOV EBX,EAX
MOV EAX,11
XCHG EAX,EBX
SUB EAX,EBX
MOV EBX,EAX
MOV EAX,1
XCHG EAX,EBX
SUB EAX,EBX
MOV DWORD [_cptr],EAX
JMP _2_312
_2_313:
XOR EAX,EAX
POP EBP
RET

_nextsym:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,11
ADD EAX,EBX
POP EBX
MOV [EBX],EAX
_2_318:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,32
CALL __ge
OR EAX,EAX
JNE _2_320
JMP _2_319
_2_320:
JMP _2_318
_2_319:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBP
RET

_addwhile:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_csp]
POP EBX
MOV [EBX],EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,4
ADD EAX,EBX
PUSH EAX
XOR CL,CL
CALL _getlabel
POP EBX
MOV [EBX],EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,8
ADD EAX,EBX
PUSH EAX
XOR CL,CL
CALL _getlabel
POP EBX
MOV [EBX],EAX
MOV EAX,[_wqptr]
PUSH EAX
MOV EAX,[_wq]
MOV EBX,120
ADD EAX,EBX
MOV EBX,EAX
MOV EAX,12
XCHG EAX,EBX
SUB EAX,EBX
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_323
JMP _2_322
_2_323:
MOV EAX,_2_321+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
MOV EAX,7
PUSH EAX
MOV CL,1
CALL _OS_exit
ADD ESP,4
_2_322:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_324:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,3
CALL __lt
OR EAX,EAX
JNE _2_326
JMP _2_325
_2_326:
MOV EAX,[_wqptr]
INC EAX
INC EAX
INC EAX
INC EAX
MOV DWORD [_wqptr],EAX
DEC EAX
DEC EAX
DEC EAX
DEC EAX
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
POP EBX
SHL EAX,1
SHL EAX,1
ADD EAX,EBX
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],EAX
JMP _2_324
_2_325:
MOV ESP,EBP
POP EBP
RET
_2_321 DB 99,111,110,116,114,111,108,32,115,116
 DB 97,116,101,109,101,110,116,32,110,101
 DB 115,116,105,110,103,32,108,105,109,105
 DB 116,0

_readwhil:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_wq]
POP EBX
CALL __ule
OR EAX,EAX
JNE _2_329
JMP _2_328
_2_329:
MOV EAX,_2_327+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
XOR EAX,EAX
POP EBP
RET
_2_328:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,12
XCHG EAX,EBX
SUB EAX,EBX
POP EBP
RET
_2_330:
POP EBP
RET
_2_327 DB 111,117,116,32,111,102,32,99,111,110
 DB 116,101,120,116,0

_delwhile:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_wqptr]
PUSH EAX
MOV EAX,[_wq]
POP EBX
CALL __ugt
OR EAX,EAX
JNE _2_333
JMP _2_332
_2_333:
MOV EAX,[_wqptr]
MOV EBX,EAX
MOV EAX,12
XCHG EAX,EBX
SUB EAX,EBX
MOV DWORD [_wqptr],EAX
_2_332:
POP EBP
RET

_alpha:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _isalpha
ADD ESP,4
OR EAX,EAX
JE _2_337
JMP _2_335
_2_337:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,95
CALL __eq
OR EAX,EAX
JE _2_338
JMP _2_335
_2_338:
XOR EAX,EAX
JMP _2_336
_2_335:
MOV EAX,1
_2_336:
POP EBP
RETN

_an:
PUSH EBP
MOV EBP,ESP
LEA EBX,[EBP+8]
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _alpha
ADD ESP,4
OR EAX,EAX
JE _2_342
JMP _2_340
_2_342:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _isdigit
ADD ESP,4
OR EAX,EAX
JE _2_343
JMP _2_340
_2_343:
XOR EAX,EAX
JMP _2_341
_2_340:
MOV EAX,1
_2_341:
POP EBP
RETN

_getlabel:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_nxtlab]
INC EAX
MOV DWORD [_nxtlab],EAX
POP EBP
RETN

_getint:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP-4]
PUSH EAX
LEA EBX,[EBP+12]
MOV EAX,[EBX]
PUSH EAX
LEA EBX,[EBP+8]
MOV EAX,[EBX]
DEC EAX
MOV [EBX],EAX
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],EAX
_2_346:
LEA EBX,[EBP+8]
MOV EAX,[EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
;OR EAX,EAX
JZ  short _2_347
_2_348:
LEA EAX,[EBP-4]
PUSH EAX
LEA EBX,[EBP-4]
MOV EAX,[EBX]
MOV ECX,8
SAL EAX,CL
PUSH EAX
LEA EBX,[EBP+12]
MOV EAX,[EBX]
PUSH EAX
LEA EBX,[EBP+8]
MOV EAX,[EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,255
AND EAX,EBX
POP EBX
OR  EAX,EBX
POP EBX
MOV [EBX],EAX
JMP short _2_346
_2_347:
LEA EBX,[EBP-4]
MOV EAX,[EBX]
MOV ESP,EBP
POP EBP
RETN

_putint:
PUSH EBP
MOV  EBP,ESP
_2_350:
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]
DEC  EAX
MOV  [EBX],EAX
INC  EAX
;OR  EAX,EAX
JZ   short _2_351
_2_352:
LEA  EBX,[EBP+12]
MOV  EAX,[EBX]
INC  DWORD [EBX]
LEA  EBX,[EBP+16]
PUSH EBX ; *
PUSH EAX
MOV  EAX,[EBX]
POP  EBX
MOV  [EBX],AL
;LEA EBX,[EBP+16]
POP EBX ; *
;LEA EBX,[EBP+16]
MOV  EAX,[EBX]
MOV  ECX,8
SAR  EAX,CL
MOV  [EBX],EAX
JMP  short _2_350
_2_351:
POP  EBP
RETN

_lout:		; lout(line, fd)
PUSH EBP
MOV EBP,ESP
LEA EBX,[EBP+12] ; line address
MOV EAX,[EBX]	; line
PUSH EAX
LEA EBX,[EBP+8]	; fd address
MOV EAX,[EBX]	; fd (file number)
; TRDOS 386
CMP EAX, -1 ; is STDOUT/STDERR ?
JE short _lout_@  ;yes
;
PUSH EAX
MOV CL,2
CALL _fputs	; fputs(line, fd);
ADD ESP,8
MOV EAX,10	; LF (not CRLF !)
PUSH EAX
LEA EBX,[EBP+8]
MOV EAX,[EBX]	; fd
PUSH EAX
MOV CL,2
CALL _OS_fputc	; fputc(NEWLINE, fd);
ADD ESP,8
POP EBP
RETN
_lout_@:	; TRDOS 386
MOV CL,1
CALL _puts	; puts(line);
;ADD ESP,4
POP EAX
MOV EAX,NEWLINE ; crlf
PUSH EAX
CALL _puts	; puts(crlf);
POP EAX
POP EBP
RETN

_illname:
PUSH EBP
MOV  EBP,ESP
MOV  EAX,err_ils ; _2_354+0
PUSH EAX
MOV  CL,1
CALL _error	; error("illegal symbol");
ADD  ESP,4
XOR  CL,CL
CALL _skip	; skip();
POP  EBP
RETN
_2_354:
err_ils: DB "illegal symbol",0

_multidef:
PUSH EBP
MOV  EBP,ESP
MOV  EAX,err_alrd ; _2_355+0
PUSH EAX
MOV  CL,1
CALL _error	; error("already defined");
ADD  ESP,4
POP  EBP
RETN

_2_355:
err_alrd: DB "already defined",0

_needlval:
PUSH EBP
MOV  EBP,ESP
MOV  EAX,err_mblv ; _2_356+0
PUSH EAX
MOV  CL,1
CALL _error	; error("must be lvalue");
ADD  ESP,4
POP  EBP
RETN

_2_356:
err_mblv: DB "must be lvalue",0

_noiferr:
PUSH EBP
MOV  EBP,ESP
MOV  EAX,err_nmif ; _2_357+0
PUSH EAX
MOV  CL,1
CALL _error ; error("no matching #if...");
;ADD ESP,4
POP  EAX
XOR  EAX,EAX 	; errflag = 0;
MOV  DWORD [_errflag],EAX
POP  EBP
RETN

_2_357:
err_nmif: DB "no matching #if...",0

; TRDOS 386 modification 

_error:		; error(msg)
PUSH EBP
MOV  EBP,ESP
MOV  EAX,[_errflag] ; if(errflag)
OR   EAX,EAX
JZ   short _2_359 ; false
_2_360:		; return;
POP  EBP
RETN
_2_359:		; else
MOV  EAX,1	; errflag = 1;	
MOV  DWORD [_errflag],EAX
_2_361:
MOV  EAX,[_line] ; lout(line, stderr);
PUSH EAX
MOV  EAX,-1	; write to STDERR/STDOUT (TRDOS 386)
PUSH EAX
MOV  CL,2
CALL _lout	; lout(line, -1);
ADD  ESP,8
LEA  EBX,[EBP+8] ; errout(msg, stderr);
MOV  EAX,[EBX]
PUSH EAX
MOV  EAX,-1	; write to STDERR/STDOUT (TRDOS 386)
PUSH EAX
MOV  CL,2
CALL _errout	; errout(msg, -1);	
ADD  ESP,8
MOVSX EAX,BYTE [_alarm] ; if(alarm)
OR   EAX,EAX
JZ   short _2_362 ;false
_2_363:
MOV  EAX,7
PUSH EAX
MOV  CL,1
CALL _OS_putc	; putc(7); (TRDOS 386)
;ADD ESP,4
POP  EAX
_2_362:
;MOVSX EAX,BYTE [_pause]
MOV  AL,BYTE [_pause]
OR   EAX,EAX	; if(pause)
JZ   short _2_364 ; false
_2_365:		; true
_2_366:		; while(fgetc(stderr) != NEWLINE);
XOR  CL,CL	
CALL _OS_getc	; while(getc() != 13); (TRDOS 386)
;ADD ESP,4
;MOV EBX,EAX
;MOV EAX,10
MOV  EBX,13	; TRDOS 386 Modification
CALL __ne
OR   EAX,EAX
JNZ  short _2_366 ; jump to while(getc() != 13)
_2_367:
_2_364:
MOV  EAX,[_listfp] ; if(listfp > 0)
OR   EAX,EAX
JNG  short _2_369
;JZ  short _2_369 ; TRDOS 386
_2_370:		; errout(msg, listfp);
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]
PUSH EAX
MOV  EAX,[_listfp]
PUSH EAX
MOV  CL,2
CALL _errout
ADD  ESP,8
_2_369:
POP  EBP
RETN

_errout: 	; errout(msg, fp)
PUSH EBP
MOV  EBP,ESP
ADD  ESP,-4	; int k;
LEA  EAX,[EBP-4]
PUSH EAX
MOV  EAX,[_line]
MOV  EBX,2
ADD  EAX,EBX
POP  EBX
MOV  [EBX],EAX
_2_372:
LEA  EAX,[EBP-4] ; while(k++ <= lptr)
MOV  EBX,[EAX]
INC  DWORD [EAX]
MOV  EAX,[_lptr]
CALL __ule
OR   EAX,EAX
JZ   short _2_373 ; false
_2_374:
MOV  EAX,32	; ' '
PUSH EAX
LEA  EBX,[EBP+8] ; fp address
MOV  EAX,[EBX]	; fp
PUSH EAX
MOV  CL,2
; (if fp = -1, _OS_fputc will be redirected to _OS_putc)
; (_OS_putc writes char to STDOUT/STDERR)
CALL _OS_fputc
ADD  ESP,8
JMP  short _2_372
_2_373:
MOV  EAX,fsbs	; _2_371+0 ; "/\" 	
PUSH EAX
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]	; fp
PUSH EAX
MOV  CL,2
CALL _lout	; lout("/\\", fp);
ADD  ESP,8
MOV  EAX,fsas	; _2_371+3 ; "**** "
PUSH EAX
LEA  EBX,[EBP+8]
MOV  EAX,[EBX]
; (if fp = -1, _OS_fputc in _fputs 
;  will be redirected to _OS_putc -in OSFUNCS.ASM-)
; (_OS_putc writes char to STDOUT/STDERR)
PUSH EAX
MOV  CL,2
CALL _fputs	; fputs("**** ", fp);
ADD  ESP,8
_2_377:		; TRDOS 386
LEA  EBX,[EBP+12] ; address of msg address
MOV  EAX,[EBX]	; msg address (message's itself)
PUSH EAX
LEA  EBX,[EBP+8] ; fp address
MOV  EAX,[EBX]	; fp (file number)
PUSH EAX
MOV  CL,2
CALL _lout	; lout(msg, fp);
ADD  ESP,8
MOV  ESP,EBP
POP  EBP
RETN

_2_371:
fsbs: DB "/\",0 ; 47,92,0
fsas: DB "**** ",0 ; 42,42,42,42,32,0

