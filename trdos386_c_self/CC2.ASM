
_preproce:
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
MOV EAX,13
CALL __ne
OR EAX,EAX
JNE _2_11
JMP _2_9
_2_11:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,10
CALL __ne
OR EAX,EAX
JNE _2_12
JMP _2_9
_2_12:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_13
JMP _2_9
_2_13:
MOV EAX,1
JMP _2_10
_2_9:
XOR EAX,EAX
_2_10:
OR EAX,EAX
JNE _2_14
JMP _2_8
_2_14:
XOR CL,CL
CALL _white
OR EAX,EAX
JNE _2_16
JMP _2_15
_2_16:
MOV EAX,32
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
_2_17:
XOR CL,CL
CALL _white
OR EAX,EAX
JNE _2_19
JMP _2_18
_2_19:
XOR CL,CL
CALL _gch
JMP _2_17
_2_18:
JMP _2_20
_2_15:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,34
CALL __eq
OR EAX,EAX
JNE _2_22
JMP _2_21
_2_22:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
XOR CL,CL
CALL _gch
_2_23:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,34
CALL __ne
OR EAX,EAX
JE _2_29
JMP _2_25
_2_29:
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
JNE _2_30
JMP _2_26
_2_30:
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
JNE _2_31
JMP _2_26
_2_31:
MOV EAX,1
JMP _2_27
_2_26:
XOR EAX,EAX
_2_27:
OR EAX,EAX
JE _2_32
JMP _2_25
_2_32:
XOR EAX,EAX
JMP _2_28
_2_25:
MOV EAX,1
_2_28:
OR EAX,EAX
JNE _2_33
JMP _2_24
_2_33:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_35
JMP _2_34
_2_35:
MOV EAX,_2_1+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
JMP _2_24
_2_34:
XOR CL,CL
CALL _gch
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_23
_2_24:
XOR CL,CL
CALL _gch
MOV EAX,34
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_36
_2_21:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,39
CALL __eq
OR EAX,EAX
JNE _2_38
JMP _2_37
_2_38:
MOV EAX,39
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
XOR CL,CL
CALL _gch
_2_39:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,39
CALL __ne
OR EAX,EAX
JE _2_45
JMP _2_41
_2_45:
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
JNE _2_46
JMP _2_42
_2_46:
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
JNE _2_47
JMP _2_42
_2_47:
MOV EAX,1
JMP _2_43
_2_42:
XOR EAX,EAX
_2_43:
OR EAX,EAX
JE _2_48
JMP _2_41
_2_48:
XOR EAX,EAX
JMP _2_44
_2_41:
MOV EAX,1
_2_44:
OR EAX,EAX
JNE _2_49
JMP _2_40
_2_49:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_51
JMP _2_50
_2_51:
MOV EAX,_2_1+9
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
JMP _2_40
_2_50:
XOR CL,CL
CALL _gch
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_39
_2_40:
XOR CL,CL
CALL _gch
MOV EAX,39
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_52
_2_37:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_56
JMP _2_54
_2_56:
MOV EAX,[_nch]
MOV EBX,EAX
MOV EAX,42
CALL __eq
OR EAX,EAX
JNE _2_57
JMP _2_54
_2_57:
MOV EAX,1
JMP _2_55
_2_54:
XOR EAX,EAX
_2_55:
OR EAX,EAX
JNE _2_58
JMP _2_53
_2_58:
MOV EAX,2
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
_2_59:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,42
CALL __eq
OR EAX,EAX
JNE _2_63
JMP _2_61
_2_63:
MOV EAX,[_nch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_64
JMP _2_61
_2_64:
MOV EAX,1
JMP _2_62
_2_61:
XOR EAX,EAX
_2_62:
OR EAX,EAX
JE _2_65
JMP _2_60
_2_65:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_67
JMP _2_66
_2_67:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_68
_2_66:
XOR CL,CL
CALL _ifline
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_70
JMP _2_69
_2_70:
JMP _2_60
_2_69:
_2_68:
JMP _2_59
_2_60:
MOV EAX,2
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_71
_2_53:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_75
JMP _2_73
_2_75:
MOV EAX,[_nch]
MOV EBX,EAX
MOV EAX,47
CALL __eq
OR EAX,EAX
JNE _2_76
JMP _2_73
_2_76:
MOV EAX,1
JMP _2_74
_2_73:
XOR EAX,EAX
_2_74:
OR EAX,EAX
JNE _2_77
JMP _2_72
_2_77:
MOV EAX,2
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
_2_78:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,13
CALL __ne
OR EAX,EAX
JNE _2_82
JMP _2_80
_2_82:
MOV EAX,[_ch]
MOV EBX,EAX
MOV EAX,10
CALL __ne
OR EAX,EAX
JNE _2_83
JMP _2_80
_2_83:
MOV EAX,1
JMP _2_81
_2_80:
XOR EAX,EAX
_2_81:
OR EAX,EAX
JNE _2_84
JMP _2_79
_2_84:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_86
JMP _2_85
_2_86:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_87
_2_85:
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_89
JMP _2_88
_2_89:
JMP _2_79
_2_88:
_2_87:
JMP _2_78
_2_79:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
JMP _2_90
_2_72:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_92
JMP _2_91
_2_92:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_93:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_97
JMP _2_95
_2_97:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,8
CALL __lt
OR EAX,EAX
JNE _2_98
JMP _2_95
_2_98:
MOV EAX,1
JMP _2_96
_2_95:
XOR EAX,EAX
_2_96:
OR EAX,EAX
JNE _2_99
JMP _2_94
_2_99:
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
JMP _2_93
_2_94:
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
JNE _2_101
JMP _2_100
_2_101:
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
_2_102:
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
JNE _2_104
JMP _2_103
_2_104:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_102
_2_103:
_2_105:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_107
JMP _2_106
_2_107:
XOR CL,CL
CALL _gch
JMP _2_105
_2_106:
JMP _2_108
_2_100:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_109:
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
JNE _2_111
JMP _2_110
_2_111:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
JMP _2_109
_2_110:
_2_108:
JMP _2_112
_2_91:
XOR CL,CL
CALL _gch
PUSH EAX
MOV CL,1
CALL _keepch
ADD ESP,4
_2_112:
_2_90:
_2_71:
_2_52:
_2_36:
_2_20:
JMP _2_7
_2_8:
MOV EAX,[_pptr]
MOV EBX,EAX
MOV EAX,127
CALL __ge
OR EAX,EAX
JNE _2_114
JMP _2_113
_2_114:
MOV EAX,_2_1+23
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
_2_113:
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

_keepch:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_pptr]
MOV EBX,EAX
MOV EAX,127
CALL __lt
OR EAX,EAX
JNE _2_117
JMP _2_116
_2_117:
MOV EAX,[_pline]
PUSH EAX
MOV EAX,[_pptr]
INC EAX
MOV DWORD [_pptr],EAX
POP EBX
ADD EAX,EBX
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],AL
_2_116:
POP EBP
RET

_ifline:
PUSH EBP
MOV EBP,ESP
_2_119:
XOR CL,CL
CALL _inline
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_122
JMP _2_121
_2_122:
POP EBP
RET
_2_121:
MOV EAX,_2_118+0
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_124
JMP _2_123
_2_124:
MOV EAX,[_iflevel]
INC EAX
MOV DWORD [_iflevel],EAX
MOV EAX,[_skipleve]
OR EAX,EAX
JNE _2_126
JMP _2_125
_2_126:
JMP _2_119
_2_125:
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
JE _2_128
JMP _2_127
_2_128:
MOV EAX,[_iflevel]
MOV DWORD [_skipleve],EAX
_2_127:
JMP _2_119
_2_123:
MOV EAX,_2_118+7
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_130
JMP _2_129
_2_130:
MOV EAX,[_iflevel]
INC EAX
MOV DWORD [_iflevel],EAX
MOV EAX,[_skipleve]
OR EAX,EAX
JNE _2_132
JMP _2_131
_2_132:
JMP _2_119
_2_131:
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
JNE _2_134
JMP _2_133
_2_134:
MOV EAX,[_iflevel]
MOV DWORD [_skipleve],EAX
_2_133:
JMP _2_119
_2_129:
MOV EAX,_2_118+15
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_136
JMP _2_135
_2_136:
MOV EAX,[_iflevel]
OR EAX,EAX
JNE _2_138
JMP _2_137
_2_138:
MOV EAX,[_skipleve]
PUSH EAX
MOV EAX,[_iflevel]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_140
JMP _2_139
_2_140:
XOR EAX,EAX
MOV DWORD [_skipleve],EAX
JMP _2_141
_2_139:
MOV EAX,[_skipleve]
OR EAX,EAX
JE _2_143
JMP _2_142
_2_143:
MOV EAX,[_iflevel]
MOV DWORD [_skipleve],EAX
_2_142:
_2_141:
JMP _2_144
_2_137:
XOR CL,CL
CALL _noiferr
_2_144:
JMP _2_119
_2_135:
MOV EAX,_2_118+21
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JNE _2_146
JMP _2_145
_2_146:
MOV EAX,[_iflevel]
OR EAX,EAX
JNE _2_148
JMP _2_147
_2_148:
MOV EAX,[_skipleve]
PUSH EAX
MOV EAX,[_iflevel]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_150
JMP _2_149
_2_150:
XOR EAX,EAX
MOV DWORD [_skipleve],EAX
_2_149:
MOV EAX,[_iflevel]
DEC EAX
MOV DWORD [_iflevel],EAX
JMP _2_151
_2_147:
XOR CL,CL
CALL _noiferr
_2_151:
JMP _2_119
_2_145:
MOV EAX,[_skipleve]
OR EAX,EAX
JNE _2_153
JMP _2_152
_2_153:
JMP _2_119
_2_152:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_155
JMP _2_154
_2_155:
JMP _2_119
_2_154:
JMP _2_120
JMP _2_119
_2_120:
POP EBP
RET
_2_118 DB 35,105,102,100,101,102,0,35,105,102
 DB 110,100,101,102,0,35,101,108,115,101
 DB 0,35,101,110,100,105,102,0

_inline:
PUSH EBP
MOV EBP,ESP
ADD ESP,-8
MOV EAX,[_input]
MOV EBX,EAX
MOV EAX,-1
CALL __eq
OR EAX,EAX
JNE _2_158
JMP _2_157
_2_158:
XOR CL,CL
CALL _openfile
_2_157:
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_160
JMP _2_159
_2_160:
MOV ESP,EBP
POP EBP
RET
_2_159:
LEA EAX,[EBP-8]
PUSH EAX
MOV EAX,[_input2]
POP EBX
MOV [EBX],EAX
MOV EBX,EAX
MOV EAX,-1
CALL __eq
OR EAX,EAX
JNE _2_162
JMP _2_161
_2_162:
LEA EAX,[EBP-8]
PUSH EAX
MOV EAX,[_input]
POP EBX
MOV [EBX],EAX
_2_161:
MOV EAX,[_line]
PUSH EAX
MOV EAX,127
PUSH EAX
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,3
CALL _fgets
ADD ESP,12
OR EAX,EAX
JE _2_164
JMP _2_163
_2_164:
LEA EAX,[EBP-8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _OS_fclos
ADD ESP,4
MOV EAX,[_input2]
MOV EBX,EAX
MOV EAX,-1
CALL __ne
OR EAX,EAX
JNE _2_166
JMP _2_165
_2_166:
MOV EAX,-1
MOV DWORD [_input2],EAX
JMP _2_167
_2_165:
MOV EAX,-1
MOV DWORD [_input],EAX
_2_167:
MOV EAX,[_line]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
JMP _2_168
_2_163:
MOV EAX,[_listfp]
OR EAX,EAX
JNE _2_170
JMP _2_169
_2_170:
MOV EAX,[_listfp]
PUSH EAX
MOV EAX,[_output]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_172
JMP _2_171
_2_172:
MOV EAX,59
PUSH EAX
MOV EAX,[_output]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
_2_171:
MOV EAX,[_line]
PUSH EAX
MOV EAX,[_listfp]
PUSH EAX
MOV CL,2
CALL _fputs
ADD ESP,8
_2_169:
_2_168:
XOR EAX,EAX
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
MOV ESP,EBP
POP EBP
RET

_inbyte:
PUSH EBP
MOV EBP,ESP
_2_174:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_176
JMP _2_175
_2_176:
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_178
JMP _2_177
_2_178:
XOR EAX,EAX
POP EBP
RET
_2_177:
XOR CL,CL
CALL _preproce
JMP _2_174
_2_175:
XOR CL,CL
CALL _gch
POP EBP
RET

_symname:
PUSH EBP
MOV EBP,ESP
ADD ESP,-8
XOR CL,CL
CALL _blanks
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _alpha
ADD ESP,4
OR EAX,EAX
JE _2_181
JMP _2_180
_2_181:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
MOV ESP,EBP
POP EBP
RET
_2_180:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_182:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_184
JMP _2_183
_2_184:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
PUSH EAX
XOR CL,CL
CALL _gch
POP EBX
MOV [EBX],AL
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,8
CALL __lt
OR EAX,EAX
JNE _2_186
JMP _2_185
_2_186:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
_2_185:
JMP _2_182
_2_183:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
MOV EAX,1
MOV ESP,EBP
POP EBP
RET

_need:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JE _2_189
JMP _2_188
_2_189:
MOV EAX,_2_187+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
_2_188:
POP EBP
RET
_2_187 DB 109,105,115,115,105,110,103,32,116,111
 DB 107,101,110,0

_ns:
PUSH EBP
MOV EBP,ESP
MOV EAX,_2_190+0
PUSH EAX
MOV CL,1
CALL _match
ADD ESP,4
OR EAX,EAX
JE _2_192
JMP _2_191
_2_192:
MOV EAX,_2_190+2
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
JMP _2_193
_2_191:
XOR EAX,EAX
MOV DWORD [_errflag],EAX
_2_193:
POP EBP
RET
_2_190 DB 59,0,110,111,32,115,101,109,105,99
 DB 111,108,111,110,0

_match:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
XOR CL,CL
CALL _blanks
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_lptr]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _streq
ADD ESP,8
POP EBX
MOV [EBX],EAX
OR EAX,EAX
JNE _2_196
JMP _2_195
_2_196:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
MOV EAX,1
MOV ESP,EBP
POP EBP
RET
_2_195:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET

_streq:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_198:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _2_200
JMP _2_199
_2_200:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
CALL __ne
OR EAX,EAX
JNE _2_202
JMP _2_201
_2_202:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET
_2_201:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _2_198
_2_199:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET

_amatch:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
XOR CL,CL
CALL _blanks
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_lptr]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,3
CALL _astreq
ADD ESP,12
POP EBX
MOV [EBX],EAX
OR EAX,EAX
JNE _2_205
JMP _2_204
_2_205:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
MOV EAX,1
MOV ESP,EBP
POP EBP
RET
_2_204:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET

_astreq:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_207:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
CALL __lt
OR EAX,EAX
JNE _2_209
JMP _2_208
_2_209:
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
CALL __ne
OR EAX,EAX
JNE _2_211
JMP _2_210
_2_211:
JMP _2_208
_2_210:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,32
CALL __lt
OR EAX,EAX
JNE _2_213
JMP _2_212
_2_213:
JMP _2_208
_2_212:
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,32
CALL __lt
OR EAX,EAX
JNE _2_215
JMP _2_214
_2_215:
JMP _2_208
_2_214:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
JMP _2_207
_2_208:
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JE _2_219
JMP _2_217
_2_219:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JE _2_220
JMP _2_217
_2_220:
XOR EAX,EAX
JMP _2_218
_2_217:
MOV EAX,1
_2_218:
OR EAX,EAX
JNE _2_221
JMP _2_216
_2_221:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET
_2_216:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET

_nextop:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
XOR EAX,EAX
MOV DWORD [_opindex],EAX
XOR CL,CL
CALL _blanks
_2_223:
XOR EAX,EAX
MOV DWORD [_opsize],EAX
_2_225:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,32
CALL __gt
OR EAX,EAX
JNE _2_227
JMP _2_226
_2_227:
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
JMP _2_225
_2_226:
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
JNE _2_229
JMP _2_228
_2_229:
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
JNE _2_233
JMP _2_231
_2_233:
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
JNE _2_234
JMP _2_231
_2_234:
MOV EAX,1
JMP _2_232
_2_231:
XOR EAX,EAX
_2_232:
OR EAX,EAX
JNE _2_235
JMP _2_230
_2_235:
MOV EAX,1
MOV ESP,EBP
POP EBP
RET
_2_230:
_2_228:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _2_237
JMP _2_236
_2_237:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
MOV EAX,[_opindex]
INC EAX
MOV DWORD [_opindex],EAX
JMP _2_238
_2_236:
XOR EAX,EAX
MOV ESP,EBP
POP EBP
RET
_2_238:
JMP _2_223
_2_224:
MOV ESP,EBP
POP EBP
RET

_blanks:
PUSH EBP
MOV EBP,ESP
_2_240:
_2_242:
MOV EAX,[_ch]
OR EAX,EAX
JNE _2_244
JMP _2_243
_2_244:
XOR CL,CL
CALL _white
OR EAX,EAX
JNE _2_246
JMP _2_245
_2_246:
XOR CL,CL
CALL _gch
JMP _2_247
_2_245:
POP EBP
RET
_2_247:
JMP _2_242
_2_243:
MOV EAX,[_line]
PUSH EAX
MOV EAX,[_mline]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_249
JMP _2_248
_2_249:
POP EBP
RET
_2_248:
XOR CL,CL
CALL _preproce
MOV EAX,[_eof]
OR EAX,EAX
JNE _2_251
JMP _2_250
_2_251:
JMP _2_241
_2_250:
JMP _2_240
_2_241:
POP EBP
RET

_white:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_lptr]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,32
CALL __le
OR EAX,EAX
JNE _2_255
JMP _2_253
_2_255:
MOV EAX,[_lptr]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _2_256
JMP _2_253
_2_256:
MOV EAX,1
JMP _2_254
_2_253:
XOR EAX,EAX
_2_254:
POP EBP
RET

_gch:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_ch]
POP EBX
MOV [EBX],EAX
OR EAX,EAX
JNE _2_259
JMP _2_258
_2_259:
MOV EAX,1
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
_2_258:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET

_bump:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
OR EAX,EAX
JNE _2_262
JMP _2_261
_2_262:
MOV EAX,[_lptr]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV DWORD [_lptr],EAX
JMP _2_263
_2_261:
MOV EAX,[_line]
MOV DWORD [_lptr],EAX
_2_263:
MOV EAX,[_lptr]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV DWORD [_nch],EAX
MOV DWORD [_ch],EAX
OR EAX,EAX
JNE _2_265
JMP _2_264
_2_265:
MOV EAX,[_lptr]
MOV EBX,1
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV DWORD [_nch],EAX
_2_264:
POP EBP
RET

_kill:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_line]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],AL
XOR EAX,EAX
PUSH EAX
MOV CL,1
CALL _bump
ADD ESP,4
POP EBP
RET

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
JNE _2_269
JMP _2_268
_2_269:
_2_270:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JNE _2_272
JMP _2_271
_2_272:
XOR CL,CL
CALL _gch
JMP _2_270
_2_271:
JMP _2_273
_2_268:
_2_274:
MOV EAX,[_ch]
PUSH EAX
MOV CL,1
CALL _an
ADD ESP,4
OR EAX,EAX
JE _2_276
JMP _2_275
_2_276:
MOV EAX,[_ch]
OR EAX,EAX
JE _2_278
JMP _2_277
_2_278:
JMP _2_275
_2_277:
XOR CL,CL
CALL _gch
JMP _2_274
_2_275:
_2_273:
XOR CL,CL
CALL _blanks
POP EBP
RET

_endst:
PUSH EBP
MOV EBP,ESP
XOR CL,CL
CALL _blanks
MOV EAX,[_lptr]
PUSH EAX
MOV EAX,_2_279+0
PUSH EAX
MOV CL,2
CALL _streq
ADD ESP,8
OR EAX,EAX
JE _2_282
JMP _2_280
_2_282:
MOV EAX,[_ch]
MOV EBX,EAX
XOR EAX,EAX
CALL __eq
OR EAX,EAX
JE _2_283
JMP _2_280
_2_283:
XOR EAX,EAX
JMP _2_281
_2_280:
MOV EAX,1
_2_281:
POP EBP
RET
_2_279 DB 59,0

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
JNE _2_286
JMP _2_285
_2_286:
LEA EAX,[EBP+32]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _findglb
ADD ESP,4
MOV DWORD [_cptr2],EAX
OR EAX,EAX
JNE _2_288
JMP _2_287
_2_288:
MOV EAX,[_cptr2]
POP EBP
RET
_2_287:
MOV EAX,[_cptr]
OR EAX,EAX
JE _2_290
JMP _2_289
_2_290:
MOV EAX,_2_284+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
XOR EAX,EAX
POP EBP
RET
_2_289:
JMP _2_291
_2_285:
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
JNE _2_293
JMP _2_292
_2_293:
MOV EAX,_2_284+29
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
MOV EAX,7
PUSH EAX
MOV CL,1
CALL _OS_exit
ADD ESP,4
_2_292:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX, [EBX]
MOV DWORD [_cptr],EAX
_2_291:
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
_2_294:
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
JNE _2_296
JMP _2_295
_2_296:
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
JMP _2_294
_2_295:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,_locptr
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_298
JMP _2_297
_2_298:
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
_2_297:
MOV EAX,[_cptr]
POP EBP
RET
_2_284 DB 103,108,111,98,97,108,32,115,121,109
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
_2_300:
MOV EAX,[_cptr]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
OR EAX,EAX
JNE _2_302
JMP _2_301
_2_302:
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
JNE _2_304
JMP _2_303
_2_304:
MOV EAX,1
POP EBP
RET
_2_303:
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
JNE _2_306
JMP _2_305
_2_306:
LEA EAX,[EBP+24]
MOV EBX,EAX
MOV EAX, [EBX]
MOV DWORD [_cptr],EAX
_2_305:
MOV EAX,[_cptr]
PUSH EAX
MOV EAX,[_cptr2]
POP EBX
CALL __eq
OR EAX,EAX
JNE _2_308
JMP _2_307
_2_308:
XOR EAX,EAX
MOV DWORD [_cptr],EAX
POP EBP
RET
_2_307:
JMP _2_300
_2_301:
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
_2_310:
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
JNE _2_312
JMP _2_311
_2_312:
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
JMP _2_310
_2_311:
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
JNE _2_315
JMP _2_314
_2_315:
MOV EAX,[_cptr]
POP EBP
RET
_2_314:
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
_2_317:
MOV EAX,[_cptr]
PUSH EAX
MOV EAX,[_symtab]
POP EBX
CALL __ugt
OR EAX,EAX
JNE _2_319
JMP _2_318
_2_319:
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
JNE _2_321
JMP _2_320
_2_321:
MOV EAX,[_cptr]
MOV EBX,EAX
MOV EAX,11
XCHG EAX,EBX
SUB EAX,EBX
POP EBP
RET
_2_320:
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
JMP _2_317
_2_318:
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
_2_323:
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
JNE _2_325
JMP _2_324
_2_325:
JMP _2_323
_2_324:
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
JNE _2_328
JMP _2_327
_2_328:
MOV EAX,_2_326+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
MOV EAX,7
PUSH EAX
MOV CL,1
CALL _OS_exit
ADD ESP,4
_2_327:
LEA EAX,[EBP-4]
MOV EBX,EAX
XOR EAX,EAX
MOV [EBX],EAX
_2_329:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,3
CALL __lt
OR EAX,EAX
JNE _2_331
JMP _2_330
_2_331:
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
JMP _2_329
_2_330:
MOV ESP,EBP
POP EBP
RET
_2_326 DB 99,111,110,116,114,111,108,32,115,116
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
JNE _2_334
JMP _2_333
_2_334:
MOV EAX,_2_332+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
XOR EAX,EAX
POP EBP
RET
_2_333:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,12
XCHG EAX,EBX
SUB EAX,EBX
POP EBP
RET
_2_335:
POP EBP
RET
_2_332 DB 111,117,116,32,111,102,32,99,111,110
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
JNE _2_338
JMP _2_337
_2_338:
MOV EAX,[_wqptr]
MOV EBX,EAX
MOV EAX,12
XCHG EAX,EBX
SUB EAX,EBX
MOV DWORD [_wqptr],EAX
_2_337:
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
JE _2_342
JMP _2_340
_2_342:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,95
CALL __eq
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
RET

_an:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _alpha
ADD ESP,4
OR EAX,EAX
JE _2_347
JMP _2_345
_2_347:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
PUSH EAX
MOV CL,1
CALL _isdigit
ADD ESP,4
OR EAX,EAX
JE _2_348
JMP _2_345
_2_348:
XOR EAX,EAX
JMP _2_346
_2_345:
MOV EAX,1
_2_346:
POP EBP
RET

_getlabel:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_nxtlab]
INC EAX
MOV DWORD [_nxtlab],EAX
POP EBP
RET

_getint:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP-4]
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
POP EBX
MOV [EBX],EAX
_2_351:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
OR EAX,EAX
JNE _2_353
JMP _2_352
_2_353:
LEA EAX,[EBP-4]
PUSH EAX
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,8
MOV ECX,EAX
MOV EAX,EBX
SAL EAX,CL
PUSH EAX
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
ADD EAX,EBX
MOV EBX,EAX
MOVSX EAX,BYTE [EBX]
MOV EBX,EAX
MOV EAX,255
AND EAX,EBX
POP EBX
OR EAX,EBX
POP EBX
MOV [EBX],EAX
JMP _2_351
_2_352:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
MOV ESP,EBP
POP EBP
RET

_putint:
PUSH EBP
MOV EBP,ESP
_2_355:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
DEC EAX
MOV [EBX],EAX
INC EAX
OR EAX,EAX
JNE _2_357
JMP _2_356
_2_357:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
PUSH EAX
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
POP EBX
MOV [EBX],AL
LEA EAX,[EBP+16]
PUSH EAX
LEA EAX,[EBP+16]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,8
MOV ECX,EAX
MOV EAX,EBX
SAR EAX,CL
POP EBX
MOV [EBX],EAX
JMP _2_355
_2_356:
POP EBP
RET

_lout:
PUSH EBP
MOV EBP,ESP
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
MOV EBX,EAX
MOV EAX,-1
CALL __ne
OR EAX,EAX
JNE _2_360
JMP _2_359
_2_360:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _fputs
ADD ESP,8
MOV EAX,10
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
JMP _2_361
_2_359:
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,1
CALL _puts
ADD ESP,4
MOV EAX,13
PUSH EAX
MOV CL,1
CALL _putc
ADD ESP,4
MOV EAX,10
PUSH EAX
MOV CL,1
CALL _putc
ADD ESP,4
_2_361:
POP EBP
RET

_illname:
PUSH EBP
MOV EBP,ESP
MOV EAX,_2_362+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
XOR CL,CL
CALL _skip
POP EBP
RET
_2_362 DB 105,108,108,101,103,97,108,32,115,121
 DB 109,98,111,108,0

_multidef:
PUSH EBP
MOV EBP,ESP
MOV EAX,_2_363+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
POP EBP
RET
_2_363 DB 97,108,114,101,97,100,121,32,100,101
 DB 102,105,110,101,100,0

_needlval:
PUSH EBP
MOV EBP,ESP
MOV EAX,_2_364+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
POP EBP
RET
_2_364 DB 109,117,115,116,32,98,101,32,108,118
 DB 97,108,117,101,0

_noiferr:
PUSH EBP
MOV EBP,ESP
MOV EAX,_2_365+0
PUSH EAX
MOV CL,1
CALL _error
ADD ESP,4
XOR EAX,EAX
MOV DWORD [_errflag],EAX
POP EBP
RET
_2_365 DB 110,111,32,109,97,116,99,104,105,110
 DB 103,32,35,105,102,46,46,46,0

_error:
PUSH EBP
MOV EBP,ESP
MOV EAX,[_errflag]
OR EAX,EAX
JNE _2_368
JMP _2_367
_2_368:
POP EBP
RET
_2_367:
MOV EAX,1
MOV DWORD [_errflag],EAX
_2_369:
MOV EAX,[_line]
PUSH EAX
MOV EAX,-1
PUSH EAX
MOV CL,2
CALL _lout
ADD ESP,8
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,-1
PUSH EAX
MOV CL,2
CALL _errout
ADD ESP,8
MOVSX EAX,BYTE [_alarm]
OR EAX,EAX
JNE _2_371
JMP _2_370
_2_371:
MOV EAX,7
PUSH EAX
MOV CL,1
CALL _putc
ADD ESP,4
_2_370:
MOVSX EAX,BYTE [_pause]
OR EAX,EAX
JNE _2_373
JMP _2_372
_2_373:
_2_374:
XOR CL,CL
CALL _getc
MOV EBX,EAX
MOV EAX,13
CALL __ne
OR EAX,EAX
JNE _2_376
JMP _2_375
_2_376:
JMP _2_374
_2_375:
_2_372:
MOV EAX,[_listfp]
OR EAX,EAX
JG _2_378
JMP _2_377
_2_378:
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV EAX,[_listfp]
PUSH EAX
MOV CL,2
CALL _errout
ADD ESP,8
_2_377:
POP EBP
RET

_errout:
PUSH EBP
MOV EBP,ESP
ADD ESP,-4
LEA EAX,[EBP-4]
PUSH EAX
MOV EAX,[_line]
MOV EBX,2
ADD EAX,EBX
POP EBX
MOV [EBX],EAX
_2_380:
LEA EAX,[EBP-4]
MOV EBX,EAX
MOV EAX, [EBX]
INC EAX
MOV [EBX],EAX
DEC EAX
PUSH EAX
MOV EAX,[_lptr]
POP EBX
CALL __ule
OR EAX,EAX
JNE _2_382
JMP _2_381
_2_382:
MOV EAX,32
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _OS_fputc
ADD ESP,8
JMP _2_380
_2_381:
MOV EAX,_2_379+0
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _lout
ADD ESP,8
MOV EAX,_2_379+3
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _fputs
ADD ESP,8
LEA EAX,[EBP+12]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
LEA EAX,[EBP+8]
MOV EBX,EAX
MOV EAX, [EBX]
PUSH EAX
MOV CL,2
CALL _lout
ADD ESP,8
MOV ESP,EBP
POP EBP
RET
_2_379 DB 47,92,0,42,42,42,42,32,0
