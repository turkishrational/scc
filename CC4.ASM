; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 17/03/2026
; -----------------------------------------------------------
; Derived from 'cc4.asm' file of KolibriOS SCC source code
; 2024

; /*
; ** p-code symbols
; **
; ** legend:
; **  1 = primary register (pr in comments)
; **  2 = secondary register (sr in comments)
; **  b = byte
; **  f = jump on false condition
; **  l = current literal pool label number
; **  m = memory reference by label
; **  n = numeric constant
; **  p = indirect reference thru pointer in sr
; **  r = repeated r times
; **  s = stack frame reference
; **  u = unsigned
; **  w = word
; **  _ (tail) = another p-code completes this one
; */

	; /* compiler-generated */
ADD12	equ	1	; /* add sr to pr */
ADDSP	equ	2	; /* add to stack pointer */
AND12	equ	3	; /* AND sr to pr */
ANEG1 	equ	4	; /* arith negate pr */
ARGCNTn	equ	5	; /* pass arg count to function */
ASL12 	equ	6	; /* arith shift left sr by pr into pr */
ASR12	equ	7	; /* arith shift right sr by pr into pr */
CALL1	equ	8	; /* call function thru pr */
CALLm	equ	9	; /* call function directly */
BYTE_   equ	10	; /* define bytes (part 1) */
BYTEn   equ	11	; /* define byte of value n */
BYTEr0  equ	12	; /* define r bytes of value 0 */
COM1	equ	13	; /* ones complement pr */
DBL1	equ	14	; /* double pr */
DBL2	equ	15	; /* double sr */
DIV12   equ	16	; /* div pr by sr */
DIV12u  equ	17	; /* div pr by sr unsigned */

DWORD_	equ	111	; /* define dword (part 1) */
DWORDn	equ	112	; /* define dword of value n */
DWORDr0	equ	113	; /* define r dwords of value 0 */

ENTER   equ	18	; /* set stack frame on function entry */
EQ10f   equ	19	; /* jump if (pr == 0) is false */
EQ12	equ	20	; /* set pr TRUE if (sr == pr) */
GE10f	equ	21	; /* jump if (pr >= 0) is false */
GE12	equ	22	; /* set pr TRUE if (sr >= pr) */
GE12u	equ	23	; /* set pr TRUE if (sr >= pr) unsigned */
POINT1l	equ	24	; /* point pr to function's literal pool */
POINT1m	equ	25	; /* point pr to mem item thru label */
GETb1m	equ	26	; /* get byte into pr from mem thru label */
GETb1mu	equ	27	; /* get unsigned byte into pr from mem thru label */
GETb1p	equ	28	; /* get byte into pr from mem thru sr ptr */
GETb1pu	equ	29	; /* get unsigned byte into pr from mem thru sr ptr */

GETd1m	equ	107	; /* get dword into pr from mem thru label */
GETd1n	equ	108	; /* get dword of value n into pr */
GETd1p	equ	109	; /* get dword into pr from mem thru sr ptr */
GETd2n	equ	110	; /* get word of value n into sr */

GETw1m	equ	30	; /* get word into pr from mem thru label */
GETw1n	equ	31	; /* get word of value n into pr */
GETw1p	equ	32	; /* get word into pr from mem thru sr ptr */
GETw2n	equ	33	; /* get word of value n into sr */
GT10f	equ	34	; /* jump if (pr > 0) is false */
GT12	equ	35	; /* set pr TRUE if (sr > pr) */
GT12u	equ	36	; /* set pr TRUE if (sr > pr) unsigned */
WORD_	equ	37	; /* define word (part 1) */
WORDn	equ	38	; /* define word of value n */
WORDr0	equ	39	; /* define r words of value 0 */
JMPm 	equ	40	; /* jump to label */
LABm 	equ	41	; /* define label m */
LE10f	equ	42	; /* jump if (pr <= 0) is false */
LE12 	equ	43	; /* set pr TRUE if (sr <= pr) */
LE12u	equ	44	; /* set pr TRUE if (sr <= pr) unsigned */
LNEG1	equ	45	; /* logical negate pr */
LT10f	equ	46	; /* jump if (pr < 0) is false */
LT12 	equ	47	; /* set pr TRUE if (sr < pr) */
LT12u	equ	48	; /* set pr TRUE if (sr < pr) unsigned */
MOD12	equ	49	; /* modulo pr by sr */
MOD12u 	equ	50	; /* modulo pr by sr unsigned */
MOVE21	equ	51	; /* move pr to sr */
MUL12	equ	52	; /* multiply pr by sr */
MUL12u	equ	53	; /* multiply pr by sr unsigned */
NE10f	equ	54	; /* jump if (pr != 0) is false */
NE12 	equ	55	; /* set pr TRUE if (sr != pr) */
NEARm	equ	56	; /* define near pointer thru label */
OR12 	equ	57	; /* OR sr onto pr */
POINT1s	equ	58	; /* point pr to stack item */
POP2 	equ	59	; /* pop stack into sr */
PUSH1	equ	60	; /* push pr onto stack */
PUTbm1	equ	61	; /* put pr byte in mem thru label */
PUTbp1	equ	62	; /* put pr byte in mem thru sr ptr */

PUTdm1	equ	114	; /* put pr dword in mem thru label */
PUTdp1	equ	115	; /* put pr dword in mem thru sr ptr */

PUTwm1	equ	63	; /* put pr word in mem thru label */
PUTwp1	equ	64	; /* put pr word in mem thru sr ptr */
rDEC1	equ	65	; /* dec pr (may repeat) */
REFm 	equ	66	; /* finish instruction with label */
RETURN	equ	67	; /* restore stack and return */
rINC1	equ	68	; /* inc pr (may repeat) */
SUB12	equ	69	; /* sub sr from pr */
SWAP12	equ	70	; /* swap pr and sr */
SWAP1s	equ	71	; /* swap pr and top of stack */
SWITCH	equ	72	; /* find switch case */
XOR12	equ	73	; /* XOR pr with sr */

	; /* optimizer-generated */
ADD1n	equ	74	; /* add n to pr */
ADD21	equ	75	; /* add pr to sr */
ADD2n	equ	76	; /* add immediate to sr */
ADDbpn	equ	77	; /* add n to mem byte thru sr ptr */
ADDwpn	equ	78	; /* add n to mem word thru sr ptr */
ADDm_	equ	79	; /* add n to mem byte/word thru label (part 1) */
COMMAn	equ	80	; /* finish instruction with ,n */
DECbp	equ	81	; /* dec mem byte thru sr ptr */
DECwp	equ	82	; /* dec mem word thru sr ptr */
POINT2m	equ	83	; /* point sr to mem thru label */
POINT2m_ equ	84	; /* point sr to mem thru label (part 1) */
GETb1s	equ	85	; /* get byte into pr from stack */
GETb1su	equ	86	; /* get unsigned byte into pr from stack */
GETw1m_	equ	87	; /* get word into pr from mem thru label (part 1) */
GETw1s	equ	88	; /* get word into pr from stack */
GETw2m	equ	89	; /* get word into sr from mem (label) */
GETw2p	equ	90	; /* get word into sr thru sr ptr */
GETw2s	equ	91	; /* get word into sr from stack */
INCbp	equ	92	; /* inc byte in mem thru sr ptr */
INCwp	equ	93	; /* inc word in mem thru sr ptr */
PLUSn 	equ	94	; /* finish instruction with +n */
POINT2s	equ	95	; /* point sr to stack */
PUSH2	equ	96	; /* push sr */
PUSHm	equ	97	; /* push word from mem thru label */
PUSHp	equ	98	; /* push word from mem thru sr ptr */
PUSHs	equ	99	; /* push word from stack */
PUT_m_	equ	100	; /* put byte/word into mem thru label (part 1) */
rDEC2   equ	101	; /* dec sr (may repeat) */
rINC2   equ	102	; /* inc sr (may repeat) */
SUB_m_	equ	103	; /* sub from mem byte/word thru label (part 1) */
SUB1n   equ	104	; /* sub n from pr */
SUBbpn	equ	105	; /* sub n from mem byte thru sr ptr */
SUBwpn	equ	106	; /* sub n from mem word thru sr ptr */

; /***************** optimizer command definitions ******************/

pfree	equ	0FDh	; /* matches if pri register free */
comm	equ	0FBh	; /* matches if registers are commutative */
_pop	equ	0FEh	; /* matches if corresponding POP2 exists */
sfree	equ	0FCh	; /* matches if sec register free */
any	equ	0FFh	; /* matches any p-code */

go      equ	100h	; /* go n entries */
gc      equ	200h	; /* get code from n entries away */
gv      equ	300h	; /* get value from n entries away */
sum     equ	400h	; /* add value from nth entry away */
neg     equ	500h	; /* negate the value */
ife     equ	600h	; /* if value == n do commands to next 0 */
ifl     equ	700h	; /* if value <  n do commands to next 0 */
swv     equ	800h	; /* swap value with value n entries away */
topop   equ	900h	; /* moves |code and current value to POP2 */

p1      equ	001h	; /* plus 1 */
p2      equ	002h	; /* plus 2 */
p3      equ	003h	; /* plus 3 */
p4      equ	004h	; /* plus 4 */
m1      equ	0FFh	; /* minus 1 */
m2      equ	0FEh	; /* minus 2 */
m3      equ	0FDh	; /* minus 3 */
m4      equ	0FCh	; /* minus 4 */

align 4

; /******************** optimizer command lists *********************/

_seq00:	DD 0,ADD12,MOVE21,0,go+p1,ADD21,0				; /* ADD21 */
_seq01:	DD 0,ADD1n,0,ifl+m2,0,ifl+0,rDEC1,neg,0,ifl+p3,rINC1,0,0	; /* rINC1 or rDEC1 ? */
_seq02:	DD 0,ADD2n,0,ifl+m2,0,ifl+0,rDEC2,neg,0,ifl+p3,rINC2,0,0	; /* rINC2 or rDEC2 ? */
_seq03:	DD 0,rDEC1,PUTbp1,rINC1,0,go+p2,ife+p1,DECbp,0,SUBbpn,0		; /* SUBbpn or DECbp */
_seq04:	DD 0,rDEC1,PUTwp1,rINC1,0,go+p2,ife+p1,DECwp,0,SUBwpn,0		; /* SUBwpn or DECwp */
_seq05:	DD 0,rDEC1,PUTbm1,rINC1,0,go+p1,SUB_m_,go+p1,COMMAn,go+m1,0	; /* SUB_m_ COMMAn */
_seq06:	DD 0,rDEC1,PUTwm1,rINC1,0,go+p1,SUB_m_,go+p1,COMMAn,go+m1,0	; /* SUB_m_ COMMAn */
_seq07:	DD 0,GETw1m,GETw2n,ADD12,MOVE21,GETb1p,0,go+p4,gv+m3,go+m1,GETw2m,gv+m3,0 ; /* GETw2m GETb1p */
_seq08:	DD 0,GETw1m,GETw2n,ADD12,MOVE21,GETb1pu,0,go+p4,gv+m3,go+m1,GETw2m,gv+m3,0 ; /* GETw2m GETb1pu */
_seq09:	DD 0,GETw1m,GETw2n,ADD12,MOVE21,GETw1p,0,go+p4,gv+m3,go+m1,GETw2m,gv+m3,0 ; /* GETw2m GETw1p */
_seq10:	DD 0,GETw1m,GETw2m,SWAP12,0,go+p2,GETw1m,gv+m1,go+m1,gv+m1,0	; /* GETw2m GETw1m */
_seq11:	DD 0,GETw1m,MOVE21,0,go+p1,GETw2m,gv+m1,0			; /* GETw2m */
_seq12:	DD 0,GETw1m,PUSH1,pfree,0,go+p1,PUSHm,gv+m1,0			; /* PUSHm */
_seq13:	DD 0,GETw1n,PUTbm1,pfree,0,PUT_m_,go+p1,COMMAn,go+m1,swv+p1,0	; /* PUT_m_ COMMAn */
_seq14:	DD 0,GETw1n,PUTwm1,pfree,0,PUT_m_,go+p1,COMMAn,go+m1,swv+p1,0	; /* PUT_m_ COMMAn */
_seq15:	DD 0,GETw1p,PUSH1,pfree,0,go+p1,PUSHp,gv+m1,0			; /* PUSHp */
_seq16:	DD 0,GETw1s,GETw2n,ADD12,MOVE21,0,go+p3,ADD2n,gv+m2,go+m1,GETw2s,gv+m2,0 ; /* GETw2s ADD2n */
_seq17:	DD 0,GETw1s,GETw2s,SWAP12,0,go+p2,GETw1s,gv+m1,go+m1,GETw2s,gv+m1,0 ; /* GETw2s GETw1s */
_seq18:	DD 0,GETw1s,MOVE21,0,go+p1,GETw2s,gv+m1,0			; /* GETw2s */
_seq19:	DD 0,GETw2m,GETw1n,SWAP12,SUB12,0,go+p3,SUB1n,gv+m2,go+m1,GETw1m,gv+m2,0 ; /* GETw1m SUB1n */
_seq20:	DD 0,GETw2n,ADD12,0,go+p1,ADD1n,gv+m1,0				; /* ADD1n */
_seq21:	DD 0,GETw2s,GETw1n,SWAP12,SUB12,0,go+p3,SUB1n,gv+m2,go+m1,GETw1s,gv+m2,0 ; /* GETw1s SUB1n */
_seq22:	DD 0,rINC1,PUTbm1,rDEC1,0,go+p1,ADDm_,go+p1,COMMAn,go+m1,0	; /* ADDm_ COMMAn */
_seq23:	DD 0,rINC1,PUTwm1,rDEC1,0,go+p1,ADDm_,go+p1,COMMAn,go+m1,0	; /* ADDm_ COMMAn */
_seq24:	DD 0,rINC1,PUTbp1,rDEC1,0,go+p2,ife+p1,INCbp,0,ADDbpn,0		; /* ADDbpn or INCbp */
_seq25:	DD 0,rINC1,PUTwp1,rDEC1,0,go+p2,ife+p1,INCwp,0,ADDwpn,0 	; /* ADDwpn or INCwp */
_seq26:	DD 0,MOVE21,GETw1n,SWAP12,SUB12,0,go+p3,SUB1n,gv+m2,0		; /* SUB1n */
_seq27:	DD 0,MOVE21,GETw1n,comm,0,go+p1,GETw2n,0			; /* GETw2n comm */
_seq28:	DD 0,POINT1m,GETw2n,ADD12,MOVE21,0,go+p3,PLUSn,gv+m2,go+m1,POINT2m_,gv+m2,0 ; /* POINT2m_ PLUSn */
_seq29:	DD 0,POINT1m,MOVE21,pfree,0,go+p1,POINT2m,gv+m1,0		; /* POINT2m */
_seq30:	DD 0,POINT1m,PUSH1,pfree,_pop,0,topop+POINT2m,go+p2,0		; /* ... POINT2m */
_seq31:	DD 0,POINT1s,GETw2n,ADD12,MOVE21,0,sum+p1,go+p3,POINT2s,gv+m3,0	; /* POINT2s */
_seq32:	DD 0,POINT1s,PUSH1,MOVE21,0,go+p1,POINT2s,gv+m1,go+p1,PUSH2,go+m1,0 ; /* POINT2s PUSH2 */
_seq33:	DD 0,POINT1s,PUSH1,pfree,_pop,0,topop+POINT2s,go+p2,0		; /* ... POINT2s */
_seq34:	DD 0,POINT1s,MOVE21,0,go+p1,POINT2s,gv+m1,0			; /* POINT2s */
_seq35:	DD 0,POINT2m,GETb1p,sfree,0,go+p1,GETb1m,gv+m1,0		; /* GETb1m */
_seq36:	DD 0,POINT2m,GETb1pu,sfree,0,go+p1,GETb1mu,gv+m1,0		; /* GETb1mu */
_seq37:	DD 0,POINT2m,GETw1p,sfree,0,go+p1,GETw1m,gv+m1,0		; /* GETw1m */
_seq38:	DD 0,POINT2m_,PLUSn,GETw1p,sfree,0,go+p2,gc+m1,gv+m1,go+m1,GETw1m_,gv+m1,0 ; /* GETw1m_ PLUSn */
_seq39:	DD 0,POINT2s,GETb1p,sfree,0,sum+p1,go+p1,GETb1s,gv+m1,0		; /* GETb1s */
_seq40:	DD 0,POINT2s,GETb1pu,sfree,0,sum+p1,go+p1,GETb1su,gv+m1,0	; /* GETb1su */
_seq41:	DD 0,POINT2s,GETw1p,PUSH1,pfree,0,sum+p1,go+p2,PUSHs,gv+m2,0	; /* PUSHs */
_seq42:	DD 0,POINT2s,GETw1p,sfree,0,sum+p1,go+p1,GETw1s,gv+m1,0		; /* GETw1s */
_seq43:	DD 0,PUSH1,any,POP2,0,go+p2,gc+m1,gv+m1,go+m1,MOVE21,0		; /* MOVE21 any */
_seq44:	DD 0,PUSHm,_pop,0,topop+GETw2m,go+p1,0				; /* ... GETw2m */
_seq45:	DD 0,PUSHp,any,POP2,0,go+p2,gc+m1,gv+m1,go+m1,GETw2p,gv+m1,0	; /* GETw2p ... */
_seq46:	DD 0,PUSHs,_pop,0,topop+GETw2s,go+p1,0				; /* ... GETw2s */
_seq47:	DD 0,SUB1n,0,ifl+m2,0,ifl+0,rINC1,neg,0,ifl+p3,rDEC1,0,0	; /* rDEC1 or rINC1 ? */

HIGH_SEQ equ 47

	; int seq[HIGH_SEQ + 1];
;_seq: TIMES 48 DD 0 ; TIMES HIGH_SEQ+1 DD 0

;_setseq:	; setseq() {
;PUSH	EDI
;MOV	EDI,_seq
;MOV	EAX,_seq00	; seq[ 0] = seq00;
;STOSD
;MOV	EAX,_seq01
;STOSD
;MOV	EAX,_seq02
;STOSD
;MOV	EAX,_seq03
;STOSD
;MOV	EAX,_seq04	; seq[ 4] = seq04;
;STOSD
;MOV	EAX,_seq05
;STOSD
;MOV	EAX,_seq06
;STOSD
;MOV	EAX,_seq07
;STOSD
;MOV	EAX,_seq08	; seq[ 8] = seq08;
;STOSD
;MOV	EAX,_seq09
;STOSD
;MOV	EAX,_seq10
;STOSD
;MOV	EAX,_seq11
;STOSD
;MOV	EAX,_seq12
;STOSD
;MOV	EAX,_seq13
;STOSD
;MOV	EAX,_seq14
;STOSD
;MOV	EAX,_seq15	; seq[15] = seq15;
;STOSD
;MOV	EAX,_seq16
;STOSD
;MOV	EAX,_seq17
;STOSD
;MOV	EAX,_seq18
;STOSD
;MOV	EAX,_seq19
;STOSD
;MOV	EAX,_seq20
;STOSD
;MOV	EAX,_seq21	; seq[21] = seq21;
;STOSD
;MOV	EAX,_seq22
;STOSD
;MOV	EAX,_seq23
;STOSD
;MOV	EAX,_seq24
;STOSD
;MOV	EAX,_seq25	; seq[25] = seq25;
;STOSD
;MOV	EAX,_seq26
;STOSD
;MOV	EAX,_seq27
;STOSD
;MOV	EAX,_seq28
;STOSD
;MOV	EAX,_seq29
;STOSD
;MOV	EAX,_seq30	; seq[30] = seq30;
;STOSD
;MOV	EAX,_seq31
;STOSD
;MOV	EAX,_seq32
;STOSD
;MOV	EAX,_seq33
;STOSD
;MOV	EAX,_seq34
;STOSD
;MOV	EAX,_seq35
;STOSD
;MOV	EAX,_seq36
;STOSD
;MOV	EAX,_seq37
;STOSD
;MOV	EAX,_seq38	;  seq[38] = seq38;
;STOSD
;MOV	EAX,_seq39
;STOSD
;MOV	EAX,_seq40
;STOSD
;MOV	EAX,_seq41
;STOSD
;MOV	EAX,_seq42	; seq[42] = seq42;
;STOSD
;MOV	EAX,_seq43
;STOSD
;MOV	EAX,_seq44
;STOSD
;MOV	EAX,_seq45
;STOSD
;MOV	EAX,_seq46
;STOSD
;MOV	EAX,_seq47	; seq[47] = seq47;
;STOSD
;POP	EDI
;RETN

  ; Not necessary...
  DD	0	; end of optimizer command lists (Erdogan Tan)

align 4

_seq:
  DD _seq00	; seq[ 0] = seq00;
  DD _seq01
  DD _seq02
  DD _seq03
  DD _seq04	; seq[ 4] = seq04;
  DD _seq05
  DD _seq06
  DD _seq07
  DD _seq08	; seq[ 8] = seq08;
  DD _seq09
  DD _seq10
  DD _seq11
  DD _seq12
  DD _seq13
  DD _seq14
  DD _seq15	; seq[15] = seq15;
  DD _seq16
  DD _seq17
  DD _seq18
  DD _seq19
  DD _seq20
  DD _seq21	; seq[21] = seq21;
  DD _seq22
  DD _seq23
  DD _seq24
  DD _seq25	; seq[25] = seq25;
  DD _seq26
  DD _seq27
  DD _seq28
  DD _seq29
  DD _seq30	; seq[30] = seq30;
  DD _seq31
  DD _seq32
  DD _seq33
  DD _seq34	; seq[34] = seq34;
  DD _seq35
  DD _seq36
  DD _seq37
  DD _seq38	; seq[38] = seq38;
  DD _seq39
  DD _seq40
  DD _seq41
  DD _seq42	; seq[42] = seq42;
  DD _seq43
  DD _seq44
  DD _seq45
  DD _seq46
  DD _seq47	; seq[47] = seq47;

  ; Not necessary...
  DD	0	; end of _seq array (Erdogan Tan)

; /***************** assembly-code strings ******************/

;/*
;** First byte contains flag bits indicating:
;**    the value in ax is needed (010) or zapped (020)
;**    the value in bx is needed (001) or zapped (002)
;*/

; code[ADD12] = "\211ADD EAX,EBX\15\n";
_code_ADD12:	DB 211o,"ADD EAX,EBX",13,10,0
_code_ADDSP:	DB 000o,"?ADD ESP,<n>",13,10,"??",0
_code_AND12:	DB 211o,"AND EAX,EBX",13,10,0
_code_ANEG1:	DB 010o,"NEG EAX",13,10,0
_code_ARGCNTn:	DB 000o,"?MOV CL,<n>?XOR CL,CL?",13,10,0
_code_ASL12:	DB 011o,"MOV ECX,EAX",13,10,"MOV EAX,EBX",13,10,"SAL EAX,CL",13,10,0
_code_ASR12:	DB 011o,"MOV ECX,EAX",13,10,"MOV EAX,EBX",13,10,"SAR EAX,CL",13,10,0
_code_CALL1:	DB 010o,"CALL EAX",13,10,0
_code_CALLm:	DB 020o,"CALL <m>",13,10,0
_code_BYTE_:	DB 000o," DB ",0
_code_BYTEn:	DB 000o," RESB <n>",13,10,0
_code_BYTEr0:	DB 000o," TIMES <n> DB 0",13,10,0
_code_COM1:	DB 010o,"NOT EAX",13,10,0
_code_DBL1:	DB 010o,"SHL EAX,1",13,10,0
_code_DBL2:	DB 001o,"SHL EBX,1",13,10,0
_code_DIV12:	DB 011o,"CDQ",13,10,"IDIV EBX",13,10,0			; /* see gen() */
_code_DIV12u:	DB 011o,"XOR EDX,EDX",13,10,"DIV EBX",13,10,0 		; /* see gen() */
;code[ENTER]	= "\100PUSH EBP\15\nMOV EBP,ESP\15\n";
_code_ENTER:	DB 100o,"PUSH EBP",13,10,"MOV EBP,ESP",13,10,0
_code_EQ10f:	DB 010o,"<g>OR EAX,EAX",13,10,"JE _<d>",13,10,"JMP _<n>",13,10,"_<d>:",13,10,0
_code_EQ12:	DB 211o,"CALL __eq",13,10,0
_code_GE10f:	DB 010o,"<g>OR EAX,EAX",13,10,"JGE _<d>",13,10,"JMP _<n>",13,10,"_<d>:",13,10,0
_code_GE12:	DB 011o,"CALL __ge",13,10,0
_code_GE12u:	DB 011o,"CALL __uge",13,10,0
_code_POINT1l:	DB 020o,"MOV EAX,_<l>+<n>",13,10,0
_code_POINT1m:	DB 020o,"MOV EAX,<m>",13,10,0
_code_GETb1m:	DB 020o,"MOVSX EAX,BYTE [<m>]",13,10,0
_code_GETb1mu:	DB 020o,"MOVZX EAX,BYTE [<m>]",13,10,0
_code_GETb1p:	DB 021o,"MOVSX EAX,BYTE [EBX?<o>??]",13,10,0		; /* see gen() */
_code_GETb1pu:	DB 021o,"MOVZX EAX,BYTE [EBX?<o>??]",13,10,0		; /* see gen() */
; code[GETw1m]	= "\020MOVSX EAX,WORD [<m>]\15\n";
_code_GETw1m:	DB 020o,"MOVSX EAX,WORD [<m>]",13,10,0
_code_GETw1n:	DB 020o,"?MOV EAX,<n>?XOR EAX,EAX?",13,10,0
_code_GETw1p:	DB 021o,"MOVSX EAX,WORD [EBX?<o>??]",13,10,0		; /* see gen() */
_code_GETw2n:	DB 002o,"?MOV EBX,<n>?XOR EBX,EBX?",13,10,0
_code_GT10f:	DB 010o,"<g>OR EAX,EAX",13,10,"JG _<d>",13,10,"JMP _<n>",13,10,"_<d>:",13,10,0
_code_GT12:	DB 010o,"CALL __gt",13,10,0
_code_GT12u:	DB 011o,"CALL __ugt",13,10,0
_code_WORD_:	DB 000o," DW ",0
_code_WORDn:	DB 000o," RESW <n>",13,10,0
_code_WORDr0:	DB 000o," TIMES <n> DW 0",13,10,0
_code_JMPm:	DB 000o,"JMP _<n>",13,10,0
_code_LABm:	DB 000o,"_<n>:",13,10,0
_code_LE10f:	DB 010o,"<g>OR EAX,EAX",13,10,"JLE _<d>",13,10,"JMP _<n>",13,10,"_<d>:",13,10,0
_code_LE12:	DB 011o,"CALL __le",13,10,0
_code_LE12u:	DB 011o,"CALL __ule",13,10,0
_code_LNEG1:	DB 010o,"CALL __lneg",13,10,0
_code_LT10f:	DB 010o,"<g>OR EAX,EAX",13,10,"JL _<d>",13,10,"JMP _<n>",13,10,"_<d>:",13,10,0
_code_LT12:	DB 011o,"CALL __lt",13,10,0
_code_LT12u:	DB 011o,"CALL __ult",13,10,0
_code_MOD12:	DB 011o,"CDQ",13,10,"IDIV EBX",13,10,"MOV EAX,EDX",13,10,0 	; /* see gen() */
_code_MOD12u:	DB 011o,"XOR EDX,EDX",13,10,"DIV EBX",13,10,"MOV EAX,EDX",13,10,0	; /* see gen() */
_code_MOVE21:	DB 012o,"MOV EBX,EAX",13,10,0
_code_MUL12:	DB 211o,"IMUL EBX",13,10,0
_code_MUL12u:	DB 211o,"MUL EBX",13,10,0
_code_NE10f:	DB 010o,"<g>OR EAX,EAX",13,10,"JNE _<d>",13,10,"JMP _<n>",13,10,"_<d>:",13,10,0
_code_NE12:	DB 211o,"CALL __ne",13,10,0
_code_NEARm:	DB 000o," DD _<n>",13,10,0
_code_OR12:	DB 211o,"OR EAX,EBX",13,10,0
_code_POINT1s:	DB 020o,"LEA EAX,[EBP<o>]",13,10,0
_code_POP2:	DB 002o,"POP EBX",13,10,0
_code_PUSH1:	DB 110o,"PUSH EAX",13,10,0
_code_PUTbm1:	DB 010o,"MOV BYTE [<m>],AL",13,10,0
_code_PUTbp1:	DB 011o,"MOV [EBX],AL",13,10,0
_code_PUTwm1:	DB 010o,"MOV WORD [<m>],AX",13,10,0
_code_PUTwp1:	DB 011o,"MOV [EBX],AX",13,10,0
_code_rDEC1:	DB 010o,"#DEC EAX",13,10,"#",0
_code_REFm:	DB 000o,"_<n>",0
_code_RETURN:	DB 000o,"?MOV ESP,EBP",13,10,"??POP EBP",13,10,"RETN",13,10,0
_code_rINC1:	DB 010o,"#INC EAX",13,10,"#",0
;code[SUB12] 	= "\011SUB EAX,EBX\15\n";
_code_SUB12:	DB 011o,"SUB EAX,EBX",13,10,0				; /* see gen() */
_code_SWAP12:	DB 011o,"XCHG EAX,EBX",13,10,0
_code_SWAP1s:	DB 012o,"POP EBX",13,10,"XCHG EAX,EBX",13,10,"PUSH EBX",13,10,0
_code_SWITCH:	DB 012o,"CALL __switch",13,10,0
_code_XOR12:	DB 211o,"XOR EAX,EBX",13,10,0
_code_ADD1n:	DB 010o,"?ADD EAX,<n>",13,10,"??",0
_code_ADD21:	DB 211o,"ADD EBX,EAX",13,10,0
_code_ADD2n:	DB 010o,"?ADD EBX,<n>",13,10,"??",0
_code_ADDbpn:	DB 001o,"ADD BYTE [EBX],<n>",13,10,0
_code_ADDwpn:	DB 001o,"ADD WORD [EBX],<n>",13,10,0
_code_ADDm_:	DB 000o,"ADD <m>",0
_code_COMMAn:	DB 000o,",<n>",13,10,0
_code_DECbp:	DB 001o,"DEC BYTE [EBX]",13,10,0
_code_DECwp:	DB 001o,"DEC WORD [EBX]",13,10,0
_code_POINT2m:	DB 002o,"MOV EBX,<m>",13,10,0
_code_POINT2m_:	DB 002o,"MOV EBX,<m>",0
_code_GETb1s:	DB 020o,"MOVSX EAX,BYTE [EBP<o>]",13,10,0
_code_GETb1su:	DB 020o,"MOVZX EAX,BYTE [EBP<o>]",13,10,0
_code_GETw1m_:	DB 020o,"MOVSX EAX,WORD [<m>]",0
_code_GETw1s:	DB 020o,"MOVSX EAX,WORD [EBP<o>]",13,10,0
_code_GETw2m:	DB 002o,"MOVSX EBX,WORD <m>",13,10,0
_code_GETw2p:	DB 021o,"MOVSX EBX,WORD [EBX?<o>??]",13,10,0
_code_GETw2s:	DB 002o,"MOVSX EBX,WORD [EBP<o>]",13,10,0
_code_INCbp:	DB 001o,"INC BYTE [EBX]",13,10,0
_code_INCwp:	DB 001o,"INC WORD [EBX]",13,10,0
_code_PLUSn:	DB 000o,"?+<n>??",13,10,0
_code_POINT2s:	DB 002o,"LEA EBX,[EBP<o>]",13,10,0
_code_PUSH2:	DB 101o,"PUSH EBX",13,10,0
_code_PUSHm:	DB 100o,"PUSH <m>",13,10,0
;code[PUSHp]	= "\100PUSH [EBX?<o>??]\15\n";
_code_PUSHp:	DB 100o,"PUSH [EBX?<o>??]",13,10,0
_code_PUSHs:	DB 100o,"PUSH [EBP?<o>??]",13,10,0
_code_PUT_m_:	DB 000o,"MOV <m>",0
_code_rDEC2:	DB 010o,"#DEC EBX",13,10,"#",0
_code_rINC2:	DB 010o,"#INC EBX",13,10,"#",0
_code_SUB_m_:	DB 000o,"SUB <m>",0
_code_SUB1n:	DB 010o,"?SUB EAX,<n>",13,10,"??",0
_code_SUBbpn:	DB 001o,"SUB [EBX],<n>",13,10,0
_code_SUBwpn:	DB 001o,"SUB [EBX],<n>",13,10,0
; code[GETd1m]	= "\020MOV EAX,[<m>]\15\n";
_code_GETd1m:	DB 020o,"MOV EAX,[<m>]",13,10,0
_code_GETd1n:	DB 020o,"?MOV EAX,<n>?XOR EAX,EAX?",13,10,0
_code_GETd1p:	DB 021o,"MOV EAX,[EBX?<o>??]",13,10,0			; /* see gen() */
_code_GETd2n:	DB 002o,"?MOV EBX,<n>?XOR EBX,EBX?",13,10,0
; code[DWORD_]   = "\000 DD ";
_code_DWORD_:	DB 000o," DD ",0
_code_DWORDn:	DB 000o," DD <n>",13,10,0
_code_DWORDr0:	DB 000o," TIMES <n> DD 0",13,10,0
_code_PUTdm1:	DB 010o,"MOV DWORD [<m>],EAX",13,10,0
_code_PUTdp1:	DB 011o,"MOV [EBX],EAX",13,10,0

  ; Not necessary...
  DD	0	; end of assembly code strings (Erdogan Tan)

;PCODES  equ 116 ; /* size of code[] (it's a [+ 1]) */

	; int code[PCODES];
;_code: TIMES PCODES DD 0 ; TIMES 116 DD 0

;_setcodes:	; setcodes() {
;CALL	_setseq	; setseq();
;PUSH	EDI
;MOV	EDI,_code
;XOR	EAX, EAX
;STOSD
;MOV	EDI,_code+4
;MOV	EAX,_code_ADD12
;STOSD
;MOV	EAX,_code_ADDSP
;STOSD
;MOV	EAX,_code_AND12
;STOSD
;MOV	EAX,_code_ANEG1
;STOSD
;MOV	EAX,_code_ARGCNTn
;STOSD
;MOV	EAX,_code_ASL12
;STOSD
;MOV	EAX,_code_ASR12
;STOSD
;MOV	EAX,_code_CALL1
;STOSD
;MOV	EAX,_code_CALLm
;STOSD
;MOV	EAX,_code_BYTE_
;STOSD
;MOV	EAX,_code_BYTEn
;STOSD
;MOV	EAX,_code_BYTEr0
;STOSD
;MOV	EAX,_code_COM1
;STOSD
;MOV	EAX,_code_DBL1
;STOSD
;MOV	EAX,_code_DBL2
;STOSD
;MOV	EAX,_code_DIV12
;STOSD
;MOV	EAX,_code_DIV12u
;STOSD
;MOV	EAX,_code_ENTER
;STOSD
;MOV	EAX,_code_EQ10f
;STOSD
;MOV	EAX,_code_EQ12
;STOSD
;MOV	EAX,_code_GE10f
;STOSD
;MOV	EAX,_code_GE12
;STOSD
;MOV	EAX,_code_GE12u
;STOSD
;MOV	EAX,_code_POINT1l
;STOSD
;MOV	EAX,_code_POINT1m
;STOSD
;MOV	EAX,_code_GETb1m
;STOSD
;MOV	EAX,_code_GETb1mu
;STOSD
;MOV	EAX,_code_GETb1p
;STOSD
;MOV	EAX,_code_GETb1pu
;STOSD
;MOV	EAX,_code_GETw1m
;STOSD
;MOV	EAX,_code_GETw1n
;STOSD
;MOV	EAX,_code_GETw1p
;STOSD
;MOV	EAX,_code_GETw2n
;STOSD
;MOV	EAX,_code_GT10f
;STOSD
;MOV	EAX,_code_GT12
;STOSD
;MOV	EAX,_code_GT12u
;STOSD
;MOV	EAX,_code_WORD_
;STOSD
;MOV	EAX,_code_WORDn
;STOSD
;MOV	EAX,_code_WORDr0
;STOSD
;MOV	EAX,_code_JMPm
;STOSD
;MOV	EAX,_code_LABm
;STOSD
;MOV	EAX,_code_LE10f
;STOSD
;MOV	EAX,_code_LE12
;STOSD
;MOV	EAX,_code_LE12u
;STOSD
;MOV	EAX,_code_LNEG1
;STOSD
;MOV	EAX,_code_LT10f
;STOSD
;MOV	EAX,_code_LT12
;STOSD
;MOV	EAX,_code_LT12u
;STOSD
;MOV	EAX,_code_MOD12
;STOSD
;MOV	EAX,_code_MOD12u
;STOSD
;MOV	EAX,_code_MOVE21
;STOSD
;MOV	EAX,_code_MUL12
;STOSD
;MOV	EAX,_code_MUL12u
;STOSD
;MOV	EAX,_code_NE10f
;STOSD
;MOV	EAX,_code_NE12
;STOSD
;MOV	EAX,_code_NEARm
;STOSD
;MOV	EAX,_code_OR12
;STOSD
;MOV	EAX,_code_POINT1s
;STOSD
;MOV	EAX,_code_POP2
;STOSD
;MOV	EAX,_code_PUSH1
;STOSD
;MOV	EAX,_code_PUTbm1
;STOSD
;MOV	EAX,_code_PUTbp1
;STOSD
;MOV	EAX,_code_PUTwm1
;STOSD
;MOV	EAX,_code_PUTwp1
;STOSD
;MOV	EAX,_code_rDEC1
;STOSD
;MOV	EAX,_code_REFm
;STOSD
;MOV	EAX,_code_RETURN
;STOSD
;MOV	EAX,_code_rINC1
;STOSD
;MOV	EAX,_code_SUB12
;STOSD
;MOV	EAX,_code_SWAP12
;STOSD
;MOV	EAX,_code_SWAP1s
;STOSD
;MOV	EAX,_code_SWITCH
;STOSD
;MOV	EAX,_code_XOR12
;STOSD
;MOV	EAX,_code_ADD1n
;STOSD
;MOV	EAX,_code_ADD21
;STOSD
;MOV	EAX,_code_ADD2n
;STOSD
;MOV	EAX,_code_ADDbpn
;STOSD
;MOV	EAX,_code_ADDwpn
;STOSD
;MOV	EAX,_code_ADDm_
;STOSD
;MOV	EAX,_code_COMMAn
;STOSD
;MOV	EAX,_code_DECbp
;STOSD
;MOV	EAX,_code_DECwp
;STOSD
;MOV	EAX,_code_POINT2m
;STOSD
;MOV	EAX,_code_POINT2m_
;STOSD
;MOV	EAX,_code_GETb1s
;STOSD
;MOV	EAX,_code_GETb1su
;STOSD
;MOV	EAX,_code_GETw1m_
;STOSD
;MOV	EAX,_code_GETw1s
;STOSD
;MOV	EAX,_code_GETw2m
;STOSD
;MOV	EAX,_code_GETw2p
;STOSD
;MOV	EAX,_code_GETw2s
;STOSD
;MOV	EAX,_code_INCbp
;STOSD
;MOV	EAX,_code_INCwp
;STOSD
;MOV	EAX,_code_PLUSn
;STOSD
;MOV	EAX,_code_POINT2s
;STOSD
;MOV	EAX,_code_PUSH2
;STOSD
;MOV	EAX,_code_PUSHm
;STOSD
;MOV	EAX,_code_PUSHp
;STOSD
;MOV	EAX,_code_PUSHs
;STOSD
;MOV	EAX,_code_PUT_m_
;STOSD
;MOV	EAX,_code_rDEC2
;STOSD
;MOV	EAX,_code_rINC2
;STOSD
;MOV	EAX,_code_SUB_m_
;STOSD
;MOV	EAX,_code_SUB1n
;STOSD
;MOV	EAX,_code_SUBbpn
;STOSD
;MOV	EAX,_code_SUBwpn
;STOSD
;MOV	EAX,_code_GETd1m
;STOSD
;MOV	EAX,_code_GETd1n
;STOSD
;MOV	EAX,_code_GETd1p
;STOSD
;MOV	EAX,_code_GETd2n
;STOSD
;MOV	EAX,_code_DWORD_
;STOSD
;MOV	EAX,_code_DWORDn
;STOSD
;MOV	EAX,_code_DWORDr0
;STOSD
;MOV	EAX,_code_PUTdm1
;STOSD
;MOV	EAX,_code_PUTdp1
;STOSD
;XOR	EAX, EAX ; 0
;STOSD
;POP	EDI
;RETN

align 4

_code:	; code[...]
  DD 	0
  DD	_code_ADD12	; code[ADD12] = "\211ADD EAX,EBX\15\n";
  DD	_code_ADDSP	; code[ADDSP]
  DD	_code_AND12
  DD	_code_ANEG1
  DD	_code_ARGCNTn
  DD	_code_ASL12
  DD	_code_ASR12	; code[ASR12]
  DD	_code_CALL1
  DD	_code_CALLm
  DD	_code_BYTE_
  DD	_code_BYTEn
  DD	_code_BYTEr0
  DD	_code_COM1
  DD	_code_DBL1
  DD	_code_DBL2
  DD	_code_DIV12
  DD	_code_DIV12u
  DD	_code_ENTER
  DD	_code_EQ10f
  DD	_code_EQ12
  DD	_code_GE10f
  DD	_code_GE12
  DD	_code_GE12u
  DD	_code_POINT1l
  DD	_code_POINT1m
  DD	_code_GETb1m	; code[GETb1m]
  DD	_code_GETb1mu
  DD	_code_GETb1p
  DD	_code_GETb1pu
  DD	_code_GETw1m	; code[GETw1m]
  DD	_code_GETw1n
  DD	_code_GETw1p
  DD	_code_GETw2n
  DD	_code_GT10f	; code[GT10f]
  DD	_code_GT12
  DD	_code_GT12u
  DD	_code_WORD_
  DD	_code_WORDn
  DD	_code_WORDr0
  DD	_code_JMPm	; code[JMPm]
  DD	_code_LABm
  DD	_code_LE10f
  DD	_code_LE12
  DD	_code_LE12u
  DD	_code_LNEG1	; code[LNEG1] = "\010CALL __lneg\15\n";
  DD	_code_LT10f
  DD	_code_LT12
  DD	_code_LT12u
  DD	_code_MOD12
  DD	_code_MOD12u
  DD	_code_MOVE21	; code[MOVE21]
  DD	_code_MUL12
  DD	_code_MUL12u
  DD	_code_NE10f
  DD	_code_NE12
  DD	_code_NEARm
  DD	_code_OR12	; code[OR12] = "\211OR EAX,EBX\15\n";
  DD	_code_POINT1s
  DD	_code_POP2
  DD	_code_PUSH1
  DD	_code_PUTbm1
  DD	_code_PUTbp1
  DD	_code_PUTwm1	; code[PUTwm1]
  DD	_code_PUTwp1
  DD	_code_rDEC1
  DD	_code_REFm
  DD	_code_RETURN
  DD	_code_rINC1
  DD	_code_SUB12
  DD	_code_SWAP12	; code[SWAP12] = "\011XCHG EAX,EBX\15\n";
  DD	_code_SWAP1s
  DD	_code_SWITCH
  DD	_code_XOR12
  DD	_code_ADD1n
  DD	_code_ADD21
  DD	_code_ADD2n
  DD	_code_ADDbpn
  DD	_code_ADDwpn
  DD	_code_ADDm_
  DD	_code_COMMAn
  DD	_code_DECbp	; code[DECbp]
  DD	_code_DECwp
  DD	_code_POINT2m
  DD	_code_POINT2m_	; code[POINT2m_]
  DD	_code_GETb1s
  DD	_code_GETb1su
  DD	_code_GETw1m_
  DD	_code_GETw1s
  DD	_code_GETw2m
  DD	_code_GETw2p
  DD	_code_GETw2s
  DD	_code_INCbp
  DD	_code_INCwp
  DD	_code_PLUSn
  DD	_code_POINT2s
  DD	_code_PUSH2
  DD	_code_PUSHm
  DD	_code_PUSHp	; code[PUSHp] = "\100PUSH [EBX?<o>??]\15\n";
  DD	_code_PUSHs
  DD	_code_PUT_m_
  DD	_code_rDEC2
  DD	_code_rINC2
  DD	_code_SUB_m_
  DD	_code_SUB1n
  DD	_code_SUBbpn
  DD	_code_SUBwpn
  DD	_code_GETd1m	; code[GETd1m] = "\020MOV EAX,[<m>]\15\n";
  DD	_code_GETd1n
  DD	_code_GETd1p
  DD	_code_GETd2n
  DD	_code_DWORD_
  DD	_code_DWORDn	; code[DWORDn] = "\000 DD <n>\15\n";
  DD	_code_DWORDr0
  DD	_code_PUTdm1
  DD	_code_PUTdp1

  ; Not necessary...
  ;DD	0	; end of _code  array (Erdogan Tan)

_header:	; header() {
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,2	; CODESEG
	PUSH	EAX
	;MOV	CL,1
	CALL	_toseg	; toseg(CODESEG);
	;ADD	ESP,4
	POP	EAX
	;MOV	EAX,1	; DATASEG
	MOV	AL,1
	PUSH	EAX
	;MOV	CL,1
	CALL	_toseg	; toseg(DATASEG);
	;ADD	ESP,4
	POP	EAX
	;POP	EBP
	RETN

_trailer:	; trailer() {
	;PUSH	EBP	; STARTGLB = symtab+25*16
	;MOV	EBP,ESP
	;ADD	ESP,-4	; char *cp; (is not used)
	MOV	EAX,[_symtab] ; cptr = STARTGLB;
	;MOV	EBX,400
	;ADD	EAX,EBX
	ADD	EAX,400
	MOV	DWORD [_cptr],EAX
_4_5:		; while(cptr < ENDGLB) {
	MOV	EBX,[_cptr] ; ENDGLB = STARTGLB+199*20
	;PUSH	EBX
	MOV	EAX,[_symtab]
	;;MOV	EBX,400
	;;ADD	EAX,EBX
	;ADD	EAX,400
	;;MOV	EBX,3980
	;;ADD	EAX,EBX
	;ADD	EAX,3980
	ADD	EAX,400+3980
	;POP	EBX
	CALL	__ult
	OR	EAX,EAX
	JZ	short _4_6 ; false
_4_7:		; if(cptr[IDENT] == FUNCTION
	;MOV	EBX,[_cptr]
	; ebx = [_cptr]	; IDENT = 0
	MOVSX	EAX,BYTE [EBX]
	;MOV	EBX,EAX
	;MOV	EAX,4
	MOV	EBX,4	; FUNCTION (ident value)
	CALL	__eq
	OR	EAX,EAX
	;JZ	short _4_9
	JZ	short _4_8 ; false
;_4_11:
	MOV	EAX,[_cptr]  ; && cptr[CLASS] == AUTOEXT)
	;MOV	EBX,2
	;ADD	EAX,EBX
	;MOV	EBX,EAX
	;MOVSX	EAX,BYTE [EBX]
	;MOV	EBX,EAX
	;*ADD	EAX,2;;;
	INC	EAX
	INC	EAX	 ; CLASS = 2
	;MOVSX	EBX,BYTE [EAX]
	MOV	BL,[EAX]
	; ebx = [eax]
	MOV	EAX,4	 ; AUTOEXT (class value)
	CALL	__eq
	;OR	EAX,EAX
	;JZ	short _4_9
;_4_12:
	;MOV	EAX,1
	;JMP	short _4_10
;_4_9:
	;XOR	EAX,EAX
_4_10:
	OR	EAX,EAX
	JZ	short _4_8
_4_13:
	MOV	EAX,[_cptr]
	;MOV	EBX,11
	;ADD	EAX,EBX
	ADD	EAX,11
	PUSH	EAX
	XOR	EAX,EAX
	PUSH	EAX
	;MOV	EAX,4
	MOV	AL,4
	PUSH	EAX
	;MOV	CL,3
	CALL	_external ; external(cptr + NAME, 0, FUNCTION);
	ADD	ESP,12
_4_8:
	MOV	EAX,[_cptr] ; cptr += SYMMAX;
	;MOV	EBX,20
	;ADD	EAX,EBX
	ADD	EAX,20	; SYMMAX = 16+4
	MOV	DWORD [_cptr],EAX
	JMP	short _4_5
_4_6:
	;XOR	EAX,EAX
	; eax = 0
	PUSH	EAX
	;MOV	CL,1
	CALL	_toseg	; toseg(NULL);
	;ADD	ESP,4
	POP	EAX
	;MOV	ESP,EBP
	;POP	EBP
	RETN

_setstage:	; setstage(before, start)
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]	; *before
	MOV	EAX,[_snext]
	MOV	[EBX],EAX	; *before = snext
	OR	EAX,EAX	; if((*before = snext) == 0)
	JNZ	short _4_15 ; false
_4_16:		; snext = stage;
	MOV	EAX,[_stage]
	MOV	DWORD [_snext],EAX
_4_15:		; *start = snext;
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	;MOV	EAX,[_snext]
	MOV	[EBX],EAX
	POP	EBP
	RETN

_gen:		; gen(pcode, value)
	PUSH	EBP	; int pcode, value;
	MOV	EBP,ESP
	ADD	ESP,-4	; int newcsp;
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	JMP	short _4_20
_4_21:		; case GETb1pu:
_4_22:		; case GETb1p:
_4_23:		; case GETw1p:
_4_24:		; case GETd1p:
	MOV	EAX,51	; MOVE21
	PUSH	EAX
	XOR	EAX,EAX	; 0
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(MOVE21, 0);
	ADD	ESP,8
	JMP	_4_19
_4_25:		; case SUB12:
_4_26:		; case MOD12:
_4_27:		; case MOD12u:
_4_28:		; case DIV12:
_4_29:		; case DIV12u:
	MOV	EAX,70	; SWAP12
	PUSH	EAX
	XOR	EAX,EAX	; 0
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen	; gen(SWAP12, 0);
	ADD	ESP,8
	JMP	_4_19
_4_30:		; case PUSH1:
	MOV	EAX,[_csp] ; #ifdef INT32, csp -= BPD;
	;MOV	EBX,4	; BPD (bytes per dword)
	;SUB	EAX,EBX
	SUB	EAX,4	; - BPD
	MOV	DWORD [_csp],EAX
	JMP	_4_19
_4_31:		; case POP2:
	MOV	EAX,[_csp] ; #ifdef INT32, csp += BPD;
	;MOV	EBX,4
	;ADD	EAX,EBX
	ADD	EAX,4	; + BPD
	MOV	DWORD [_csp],EAX
	JMP	_4_19
_4_32:		
_4_33:		; case ADDSP:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]	; value
	LEA	EDX,[EBP-4]
	MOV	[EDX],EAX	; newcsp = value;
	MOV	EAX,[_csp] ; csp;
	SUB	[EBX],EAX	; value -= csp;
	LEA	EBX,[EBP-4] ; csp = newcsp;
	MOV	EAX,[EBX]
	MOV	DWORD [_csp],EAX
	JMP	short _4_19
_4_20:
	CALL	__switch

 DD  _4_21	; case GETb1pu:
 DD  29
 DD  _4_22	; case GETb1p:
 DD  28
 DD  _4_23	; case GETw1p:
 DD  32
 DD  _4_24	; case GETd1p:
 DD  109
 DD  _4_25	; case SUB12;
 DD  69
 DD  _4_26	; case MOD12:
 DD  49
 DD  _4_27	; case MOD12u:
 DD  50
 DD  _4_28	; case DIV12:
 DD  16
 DD  _4_29	; case DIV12u:
 DD  17
 DD  _4_30	; case PUSH1:
 DD  60
 DD  _4_31	; case POP2:
 DD  59
 DD  _4_32	; case ADDSP:
 DD  2
 DD  _4_33	; case RETURN:
 DD  67
 DD  0		; end (of switch/case options)

_4_19:
	MOV	EBX,[_snext] ; if(snext == 0)
	OR	EBX,EBX
	JNZ	short _4_34 ; false
_4_35:		; true
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	PUSH	EAX	; pcode
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX	; value
	;MOV	CL,2
	CALL	_outcode ; outcode(pcode, value);
	;ADD	ESP,8
	MOV	ESP,EBP	; return;
	POP	EBP
	RETN
_4_34:		; if(snext >= slast)
	MOV	EBX,[_snext]
	MOV	EAX,[_slast]
	CALL	__uge
	OR	EAX,EAX
	JZ	short _4_36 ; false
_4_37:		; error("staging buffer overflow");
	MOV	EAX,err_sbowf ; _4_17+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_error
	;ADD	ESP,4
	MOV	ESP,EBP	; return;
	POP	EBP
	RETN
_4_36:
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	MOV	EBX,[_snext]
	PUSH	EBX ; *
	MOV	[EBX],EAX ; snext[0] = pcode;
	;MOV	EAX,[_snext]
	;MOV	EBX,4
	;ADD	EAX,EBX
	ADD	EBX,4
	PUSH	EBX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	POP	EBX
	MOV	[EBX],EAX ; snext[1] = value;
	;MOV	EAX,[_snext]
	POP	EAX ; *
	; eax = [_snext]
	;MOV	EBX,8
	;ADD	EAX,EBX
	ADD	EAX,8	; snext += 2;
	MOV	DWORD [_snext],EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_4_17:
err_sbowf: DB "staging buffer overflow",0

_clearsta:	; clearstage(before, start)
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+12] ; if(before)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _4_39  ; false
_4_40:
	;LEA	EBX,[EBP+12] ; snext = before;
	;MOV	EAX,[EBX]
_4_41:
	MOV	DWORD [_snext],EAX
	POP	EBP	; return;
	RETN
_4_39:
	LEA	EBX,[EBP+8] ; if(start)
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _4_41 ; false
_4_42:		; true
	;XOR	CL,CL
	CALL	_dumpstag   ; dumpstage();
	; eax = 0
;_4_41:
	;;XOR	EAX,EAX	; snext = 0;
	;; eax = 0
	;MOV	DWORD [_snext],EAX
	;POP	EBP
	;RETN
	JMP	short _4_41

_dumpstag:	; dumpstage()
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; int i;
	MOV	EAX,[_snext]
	MOV	DWORD [_stail],EAX ; stail = snext;
	MOV	EAX,[_stage]
_4_44:
	MOV	DWORD [_snext],EAX ; snext = stage;

;_4_44:		; while(snext < stail)
	MOV	EBX,[_snext]
	MOV	EAX,[_stail]
	CALL	__ult
	OR	EAX,EAX
	JNZ	short _4_46 ; true
	;JMP	short _4_45
_4_45:		; false
	; eax = 0
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_46:		; if(optimize)
	MOVSX	EAX,BYTE [_optimize]
	OR	EAX,EAX
	JZ	short _4_47 ; false
_4_48:		; true
_4_49:		; restart:
	LEA	EBX,[EBP-4]
	MOV	EAX,-1	; i = -1;
	MOV	[EBX],EAX
_4_50:		; while(++i <= HIGH_SEQ)
	LEA	EAX,[EBP-4]
	;MOV	EBX,[EAX]
	;INC	EBX
	;MOV	[EAX],EBX
	INC	DWORD [EAX]
	MOV	EBX,[EAX]
	MOV	EAX,47	; HIGH_SEQ
	CALL	__le
	OR	EAX,EAX
	JZ	short _4_51 ; false
_4_52:
	LEA	EAX,[EBP-4] ; if(peep(seq[i]))
	MOV	EBX,[EAX]
	SHL	EBX,1
	SHL	EBX,1
	ADD	EBX,_seq 
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_peep
	ADD	ESP,4
	OR	EAX,EAX
	JNZ	short _4_49 ; goto restart;
	JMP	short _4_50 ; jump to while(++i
_4_51:
_4_47:		; outcode(snext[0], snext[1]);
	MOV	EBX,[_snext]
	PUSH	EBX ; *
	MOV	EAX,[EBX]
	PUSH	EAX	; snext[0]
	;MOV	EBX,[_snext]
	;MOV	EAX,4
	;ADD	EBX,EAX
	ADD	EBX,4
	MOV	EAX,[EBX]
	PUSH	EAX	; snext[1]
	;MOV	CL,2
	CALL	_outcode
	ADD	ESP,8
	;MOV	EAX,[_snext]
	POP	EAX ; *
	;MOV	EBX,8
	;ADD	EAX,EBX
	ADD	EAX,8
	;MOV	DWORD [_snext],EAX
	JMP	_4_44

_toseg:
	PUSH	EBP
	MOV	EBP,ESP
	; not necessary (Erdogan Tan - 21/09/2024)
	;MOV	EAX,[_oldseg] 
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;POP	EBX
	;CALL	__eq
	;OR	EAX,EAX
	;JNZ	short _4_57
_4_56:
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	DWORD [_oldseg],EAX
_4_57:
	POP	EBP
	RETN

_public:	; public(ident) int ident;{
	PUSH	EBP
	MOV	EBP,ESP
		; if(ident == FUNCTION)
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,4
	CALL	__eq
	;OR	EAX,EAX
	;JNZ	short _4_60 ; eax = 1
_4_59:		; else toseg(DATASEG); 1
	; eax = 0
	;INC	EAX ; eax = 1
	;JMP	short _4_59_@
_4_60:		; toseg(CODESEG); 2
	; eax = 1
	;MOV	EAX,2
	INC	EAX ; eax = 2
;_4_59_@:
	PUSH	EAX
	CALL	_toseg
	ADD	ESP,4
_4_61:
	CALL	_newline ; newline();
	MOV	EAX,_ssname
	PUSH	EAX
	CALL	_outname ; outname(ssname);
	;ADD	ESP,4
	POP	EAX
		; if(ident == FUNCTION) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,4
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_62
_4_63:
	CALL	_colon ; colon();
	CALL	_newline ; newline();
_4_62:
	POP	EBP
	RETN

_external:	; external(name, size, ident)
	PUSH	EBP
	MOV	EBP,ESP
	LEA 	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	EBX,4
	CALL	__eq
	;OR	EAX,EAX
	;JZ	short _4_65
_4_66:		; if(ident == FUNCTION)
	;;MOV	EAX,2
	;INC	EAX ; eax = 2
	;CALL	_toseg ; toseg(CODESEG);
	;;ADD	ESP,4
	;JMP	short _4_67
_4_65:
	;MOV	EAX,1
	INC	EAX ; eax = 1
	PUSH	EAX
	CALL	_toseg ; else toseg(DATASEG);
_4_67:
	ADD	ESP,4
	POP	EBP
	RETN

_outsize:	; outsize(size, ident)
	PUSH	EBP
	MOV	EBP,ESP
		; if (ident == FUNCTION)
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX] ; ident
	MOV	EAX,4	; FUNCTION
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_69
_4_70:
	MOV	EAX,_NEAR_ ; _4_68+0
	;PUSH	EAX
	;MOV	CL,1
	;CALL	_outstr	; outstr("NEAR");
	;ADD	ESP,4
	JMP	short _4_71
_4_69:		; else if (ident == POINTER)
	;LEA	EAX,[EBP+8]
	;MOV	EBX,[EAX]
	MOV	EAX,3	; POINTER
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_72
_4_73:
	MOV	EAX,_DWORD_ ; _4_68+5
	;PUSH	EAX
	;;MOV	CL,1
	;CALL	_outstr	; outstr("DWORD"); 
	;ADD	ESP,4
	;JMP	short _4_74
	JMP	short _4_71
_4_72:		; else if(size == 1)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_75
_4_76:
	MOV	EAX,_BYTE_ ; _4_68+11
	;PUSH	EAX
	;;MOV	CL,1
	;CALL	_outstr	; outstr("BYTE");
	;ADD	ESP,4
	;JMP	short _4_77
	JMP	short _4_71
_4_75:		; else if(size == 2)
	;LEA	EAX,[EBP+12]
	;MOV	EBX,[EAX]
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_78
_4_79:
	MOV	EAX,_WORD_ ; _4_68+16
	;PUSH	EAX
	;;MOV	CL,1
	;CALL	_outstr	; outstr("WORD");
	;ADD	ESP,4
	;JMP	short _4_80
	JMP	short _4_71
_4_78:		; else	
	;MOV	EAX,_DWORD2 ; _4_68+21
	MOV	EAX,_DWORD_
_4_71:
	PUSH	EAX
	;MOV	CL,1
	CALL	_outstr	; outstr("DWORD");
	ADD	ESP,4
_4_80:
_4_77:
_4_74:
;_4_71:
	POP	EBP
	RETN

_4_68:
_NEAR_:	  DB "NEAR",0
_DWORD_:  DB "DWORD",0
_BYTE_:   DB "BYTE",0
_WORD_:   DB "WORD",0
;_DWORD2: DB "DWORD",0

_point:		; point() {
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,_DW_2 ; _4_81+0
	PUSH	EAX
	CALL	_outline ; outline(" DW $+2");
	ADD	ESP,4
	POP	EBP
	RETN

_4_81:
_DW_2: DB " DW $+2"
       ; (DB 32,68,87,32,36,43,50,0)

_dumplits:	; dumplits(size)
	PUSH	EBP
	MOV	EBP,ESP
	;ADD	ESP,-8	; int j, k;
	;LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	;MOV	[EBX],EAX ; k = 0;
	PUSH	EAX
	PUSH	EAX
_4_83:		; while (k < litptr)
	LEA	EAX,[EBP-8]
	MOV	EBX,[EAX]
	MOV	EAX,[_litptr]
	CALL	__lt
	OR	EAX,EAX
	JNZ	short _4_85 ; true
_4_84:
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_85:		; if(size == 1)
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_86
_4_87:		; gen(BYTE_, NULL);
	MOV	EAX,10
	;PUSH	EAX
	;XOR	EAX,EAX ; 0
	;PUSH	EAX
	;;MOV	CL,2
	;CALL	_gen
	;ADD	ESP,8
	;JMP	short _4_88
	JMP	short _4_91
_4_86:		; else if (size == 2)
	;LEA	EAX,[EBP+8]
	;MOV	EBX,[EAX]
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_89
_4_90:		; gen(WORD_, NULL);
	MOV	EAX,37
	;PUSH	EAX
	;XOR	EAX,EAX ; 0
	;PUSH	EAX
	;;MOV	CL,2
	;CALL	_gen
	;ADD	ESP,8
	JMP	short _4_91
_4_89:		; else
	MOV	EAX,111	; gen(DWORD_,NULL);
_4_91:
	PUSH	EAX
	XOR	EAX,EAX ; 0 ; NULL
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen
	ADD	ESP,8
;_4_91:
_4_88:		; j = 10;
	LEA	EBX,[EBP-4]
	;MOV	EAX,10
	;MOV	[EBX],EAX
	MOV	DWORD [EBX],10
_4_92:		; while(j--)
	;LEA	EBX,[EBP-4] ; *
	MOV	EAX,[EBX]
	;DEC	EAX
	;MOV	[EBX],EAX
	;INC	EAX
	DEC	DWORD [EBX]
	OR	EAX,EAX
	;JNZ	short _4_94
	;JMP	short _4_83 ; jump to while (k < litptr)
	JZ	short _4_83
_4_94:		; outdec(getint(litq + k, size));
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX] ; k
	MOV	EBX,[_litq]
	ADD	EAX,EBX
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; size
	PUSH	EAX
	;MOV 	CL,2
	CALL	 _getint ; getint(litq + k, size)
	ADD	ESP,8
	PUSH	EAX
	;MOV	CL,1
	CALL	_outdec
	;ADD	ESP,4
	POP	EAX
	LEA	EBX,[EBP-8]
	PUSH	EBX	; k address
	;MOV	EAX,[EBX]
	;PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX] ; size
	;POP	EBX
	;ADD	EAX,EBX
	POP	EBX
	;MOV	[EBX],EAX  ; k += size;
	ADD	[EBX],EAX  ; k value = k value + size
		;  ; if(j == 0 || k >= litptr)
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]	; j
	XOR	EAX,EAX
	CALL	__eq
	OR	EAX,EAX
	JNZ	short _4_100 ; true (j = 0)
_4_98:
	LEA	EAX,[EBP-8]
	MOV	EBX,[EAX]   ; k value
	MOV	EAX,[_litptr]
	CALL	__ge
	OR	EAX,EAX
	JZ	short _4_95 ; false (k < litptr)
_4_100:		; true 
	;XOR	CL,CL
	CALL	_newline ; newline();
	JMP	_4_83	 ; break; (while(j--))
_4_95:
	MOV	EAX,44	; ','
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc ; fputc(',', output);
	ADD	ESP,8
	LEA	EBX,[EBP-4] ; *
	JMP	short _4_92 ; jump to while(j--)

_dumpzero:	; dumpzero(size, count)
	PUSH	EBP
	MOV	EBP,ESP
		; if(count > 0)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNG	short _4_102
_4_103:		; if(size == 1)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_104 ; false, return
_4_105:		; gen(BYTEr0, count);
	MOV	EAX,12
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;;MOV	CL,2
	;CALL	_gen
	;ADD	ESP,8
	JMP	short _4_106
_4_104:		; else if (size == 2)
	LEA	EAX,[EBP+12]
	MOV	EBX,[EAX]
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_107
_4_108:		; gen(WORDr0, count);
	MOV	EAX,39
	;PUSH	EAX
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;PUSH	EAX
	;;MOV	CL,2
	;CALL	_gen
	;ADD	ESP,8
	;JMP	short _4_109
	JMP	short _4_106
_4_107:		 ; else
	MOV	EAX,113
_4_106:		; gen(DWORDr0, count);
	PUSH	EAX
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,2
	CALL	_gen
	ADD	ESP,8
_4_109:
;_4_106:
_4_102:
	POP	EBP
	RETN

_peep:		; peep(seq) int *seq; {
	PUSH	EBP
	MOV	EBP,ESP
	; int *next,*count,*pop,n,skip,tmp,reply;char c;
	ADD	ESP,-32
		; next = snext;
	MOV	EAX,[_snext]
	LEA	EBX,[EBP-4]
	MOV	[EBX],EAX
		; count = seq++;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	DWORD [EBX],4
	LEA	EBX,[EBP-8]
	MOV	[EBX],EAX
_4_111:		; while(*seq) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JZ	short _4_112
	JNZ	short _4_113
	JMP	_4_112
_4_113:		; switch(*seq) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	JMP	_4_116
_4_117:	; case any:
	; if(next < stail) break; return (NO);
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,[_stail]
	CALL	__ult
	OR	EAX,EAX
	JE	short _4_130
	JMP	_4_119
_4_127:
_4_124:
_4_121:
_4_118:		; return (NO);
	XOR	EAX,EAX ; 0
_4_130:
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_120:	; case pfree:
	; if(isfree(PRI, next)) break; return (NO);
	MOV	EAX,24
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_isfree
	ADD	ESP,8
	OR	EAX,EAX
	;JNE	short _4_122
;_4_121:	; return (NO);
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	;JMP	short _4_121
	JZ	short _4_130
	JMP	_4_122
_4_123: ; case sfree:
	; if(isfree(SEC, next)) break; return (NO);
	MOV	EAX,3
	PUSH	EAX
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_isfree
	ADD	ESP,8
	OR	EAX,EAX
	;JNE	short _4_125
;_4_124:	; return (NO);
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	;JMP	short _4_124
	JZ	short _4_130
	JMP	_4_125
_4_126:	; case comm:
	; if(*next & COMMUTES) break; return (NO);
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	AND 	EAX,128 ; 80h
	;OR	EAX,EAX
	JNZ	short _4_128
;_4_127:	; return (NO);
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _4_127
_4_129:	; case _pop:
	; if(pop = getpop(next)) break; return (NO);
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_getpop
	ADD	ESP,4
	LEA	EBX,[EBP-12]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JNE	short _4_131
;_4_130:	; return (NO);
	;XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _4_130
_4_132:	; default:
	; if(next >= stail || *next != *seq) return (NO);
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,[_stail]
	CALL	__uge
	OR	EAX,EAX
	JNE	short _4_134
_4_136:
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	MOV	EBX,[EAX] ; *next
	LEA	EAX,[EBP+8]
	MOV	EDX,[EAX]
	MOV	EAX,[EDX] ; *seq
	CALL	__ne
	OR	EAX,EAX
	JE	short _4_137
_4_134:
_4_138:		; return (NO);
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN

_4_116:		; switch(*seq) {
	CALL	__switch

 DD _4_117 ; case any:
 DD 255
 DD _4_120 ; case pfree:
 DD 253
 DD _4_123 ; case sfree:
 DD 252
 DD _4_126 ; case comm:
 DD 251
 DD _4_129 ; case _pop:
 DD 254
 DD 0	   ; default:
	JMP	short _4_132
_4_137:
_4_133:
_4_131:
_4_128:
_4_125:
_4_122:
_4_119:
_4_115:		; next += 2; ++seq;
	LEA	EBX,[EBP-4]
	;MOV	EAX,[EBX]
	;ADD	EAX,8
	;MOV	[EBX],EAX
	ADD	DWORD [EBX],8
	LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;ADD	EAX,4
	;MOV	[EBX],EAX
	ADD	DWORD [EBX],4
	JMP	_4_111	; while

_4_112:		; *count += 1;
	LEA	EAX,[EBP-8]
	MOV	EBX,[EAX]
	;MOV	EAX,[EBX]
	;INC	EAX ; +1
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
		; reply = skip = NO;
	LEA	EBX,[EBP-28]
	LEA	EDX,[EBP-20]
	XOR	EAX,EAX ; 0
	MOV	[EDX],EAX
	MOV	[EBX],EAX
_4_156:
_4_153:
_4_169:
_4_148:
_4_139:		; while(*(++seq) || skip) {
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	ADD	EBX,4
	MOV	[EAX],EBX
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNZ	short _4_141
_4_143:
	LEA	EBX,[EBP-20] ; skip
	MOV	EAX,[EBX]
	OR	EAX,EAX
	;JNZ	short _4_141
	JNZ	short _4_147
_4_144:
_4_142:
_4_140:		; return (reply);
	LEA	EBX,[EBP-28]
	MOV	EAX,[EBX]
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_141:
_4_145:		; if(skip) {
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _4_146
_4_147:		; if(*seq == 0) skip = NO;
	LEA	EAX,[EBP+8]
	MOV	EDX,[EAX]
	MOV	EAX,[EDX]
	OR	EAX,EAX
	JNZ	short _4_148
_4_149:		; skip = NO
	;LEA	EBX,[EBP-20]
	;XOR	EAX,EAX ; 0
	MOV	[EBX],EAX
;_4_148:	; continue; 
	JMP	short _4_139 ; while
_4_146:		; if(*seq >= PCODES) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	MOV	EBX,[EAX]
	MOV	EAX,116
	CALL	__ge
	OR	EAX,EAX
	;JZ	short _4_150
	JNZ	short _4_151
	JMP	_4_150
_4_151:		; c = *seq & 0xFF;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	;AND	EAX,255
	AND	EAX,0FFh
		; n = c;
	LEA	EBX,[EBP-32]
	MOV	[EBX],AL
		; switch(*seq & 0xFF00) {
	;LEA	EBX,[EBP-32]
	;MOVSX	EAX,BYTE [EBX]
	LEA	EBX,[EBP-16]
	MOV	[EBX],EAX
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	;AND	EAX,65280
	AND	EAX,0FF00h
	JMP	_4_154
_4_155:	; case ife:
	; if(snext[1] != n) skip = YES; break;
	MOV	EAX,[_snext]
	ADD	EAX,4
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-16]
	MOV	EAX,[EDX]
	CALL	__ne
_4_159: ; *
	OR	EAX,EAX
	;JE	short _4_156
	JNE	short _4_157
	JMP	_4_156
_4_157:		; skip = YES;
	LEA	EBX,[EBP-20]
	MOV	EAX,1
	MOV	[EBX],EAX
	JMP	_4_153	; break;
_4_158:	; case ifl: 
	; if(snext[1] >= n) skip = YES; break;
	MOV	EAX,[_snext]
	ADD	EAX,4
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-16]
	MOV	EAX,[EDX]
	CALL	__ge
	JMP	short _4_159 ; *
	;OR	EAX,EAX
	;;JE	short _4_159
	;JE	short _4_156
;_4_160:
	;LEA	EBX,[EBP-20]
	;MOV	EAX,1
	;MOV	[EBX],EAX
;_4_159:
	;JMP	short _4_153
_4_161: ; case go:
	; snext += (n<<1); break;
	MOV	EBX,[_snext]
	LEA	EDX,[EBP-16]
	MOV	EAX,[EDX]
	;MOV	ECX,1
	;SAL	EAX,CL
	SAL	EAX,1 ; (n<<1)
	SHL	EAX,1
	SHL	EAX,1 ; * 4 (int size)	
	ADD	EAX,EBX
	MOV	DWORD [_snext],EAX
	JMP	_4_153
_4_162: ; case gc:
	; snext[0] = snext[(n<<1)]; goto done;
	MOV	EDX,[_snext]
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX]
	SAL	EBX,1	; (n<<1)
	SHL	EBX,1
	SHL	EBX,1	; * 4 (int size)
	ADD	EBX,EDX
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
		; goto done;
	JMP	_4_163
_4_164: ; case gv:
	; snext[1] = snext[(n<<1)+1]; goto done;
	MOV	EDX,[_snext]
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX]
	SAL	EBX,1  ; (n<<1)
	;ADD	EBX,1  ; +1
	INC	EBX
	SHL	EBX,1
	SHL	EBX,1  ; * 4 (int size)
	ADD	EBX,EDX
	ADD	EDX,4	; snext[1]
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
	JMP	short _4_163
_4_165:	; case sum:
	; snext[1] += snext[(n<<1)+1]; goto done;
	MOV	EDX,[_snext]
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX]
	SAL	EBX,CL ; (n<<1)
	;ADD	EBX,1  ; +1
	INC	EBX
	SHL	EBX,1
	SHL	EBX,1  ; * 4 (int size)
	ADD	EBX,EDX
	ADD	EDX,4	; snext[1]
	MOV	EAX,[EBX]
	MOV	EBX,[EDX]
	ADD	EAX,EBX	; + snext[1]
	MOV	[EDX],EAX
		; goto done;
	JMP	short _4_163
_4_166:	; case neg:
	; snext[1] = -snext[1]; goto done;
	MOV	EDX,[_snext]
	ADD	EDX,4
	MOV	EAX,[EDX]
	NEG	EAX
	MOV	[EDX],EAX
	JMP	short _4_163
_4_167: ; case topop:
	; pop[0] = n; pop[1] = snext[1]; goto done;
	LEA	EBX,[EBP-12] ; pop[0]
	MOV	EDX,[EBX]
	LEA	EBX,[EBP-16] ; n
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
	ADD	EDX,4	; pop[1
	MOV	EBX,[_snext]
	ADD	EBX,4	; snext[1]
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
		; goto done;
	JMP	short _4_163
_4_168:	; case swv:
	; tmp = snext[1];
	MOV	EDX,[_snext]
	ADD	EDX,4
	MOV	EAX,[EDX]
	LEA	ECX,[EBP-24] ; tmp
	MOV	[ECX],EAX
		; snext[1] = snext[(n<<1)+1];
	LEA	EAX,[EBP-16]
	MOV	EBX,[EAX] ; n
	SAL	EBX,1
	;ADD	EAX,1
	INC	EBX
	SHL	EBX,1
	SHL	EBX,1
	ADD	EBX,[_snext]
	MOV	EAX,[EBX]
	MOV	[EDX],EAX
		; snext[(n<<1)+1] = tmp;
	;LEA	EAX,[EBP-16]
	;MOV	EBX,[EAX] ; n
	;SAL	EBX,1
	;;ADD	EAX,1
	;INC	EBX
	;SHL	EBX,1
	;SHL	EBX,1
	;ADD	EBX,[_snext]
	;LEA	ECX,[EBP-24]
	MOV	EAX,[ECX]
	MOV	[EBX],EAX
_4_163:	; done:
		; reply = YES;
	LEA	EBX,[EBP-28]
	MOV	EAX,1
	MOV	[EBX],EAX
		; break;
	JMP	_4_153
_4_154:
		; switch(*seq & 0xFF00) {
	CALL	__switch

 DD _4_155 ; case ife:
 DD 1536
 DD _4_158 ; case ifl:
 DD 1792
 DD _4_161 ; case go:
 DD 256
 DD _4_162 ; case gc:
 DD 512
 DD _4_164 ; case gv:
 DD 768
 DD _4_165 ; case sum:
 DD 1024
 DD _4_166 ; case neg:
 DD 1280
 DD _4_167 ; case topop:
 DD 2304
 DD _4_168 ; case swv:
 DD 2048
 DD 0

;_4_153:	; while while(*(++seq) || skip)
	;JMP	short _4_169
	JMP	_4_139
_4_150:		; else snext[0] = *seq;
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	MOV	EBX,[_snext]
	MOV	[EBX],EAX
;_4_169:
	JMP	_4_139

_isfree:	; isfree(reg, pp) int reg, *pp; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-4	; char *cp;
_4_171:		; while(pp < stail) {
	LEA	EBX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[_stail]
	CALL	__ult
	OR	EAX,EAX
	JZ	short _4_172
_4_173:		; cp = code[*pp];
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	MOV	EAX,[EBX]
	SHL	EAX,1
	SHL	EAX,1
	ADD	EAX,_code
	MOV	EBX,[EAX]
	LEA	EDX,[EBP-4]
	MOV	[EDX],EBX
		; if(*cp & USES & reg) return (NO);
	;LEA	EDX,[EBP-4]
	;MOV	EBX,[EDX]
	MOVSX	EAX,BYTE [EBX]
	AND	EAX,9 ; USES
	LEA	EDX,[EBP+12] ; reg
	MOV	ECX,[EDX]
	AND	EAX,ECX
	OR	EAX,EAX
	JZ	short _4_174
_4_175:		; return (NO);
	XOR	EAX,EAX
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _4_180
_4_174:		; if(*cp & ZAPS & reg) return (YES);
	;LEA	EDX,[EBP-4]
	;MOV	EBX,[EDX]
	MOVSX	EAX,BYTE [EBX]
	AND	EAX,18 ; ZAPS
	;LEA	EDX,[EBP+12] ; regs
	;MOV	ECX,[EDX]
	AND	EAX,ECX
	OR	EAX,EAX
	JZ	short _4_176
_4_177:
_4_178:		; return (YES);
	MOV	EAX,1
_4_180:
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_176:		; pp += 2;
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	ADD	EAX,8	; 2 * int size
	MOV	[EBX],EAX
	JMP	short _4_171 ; while
_4_172:		; if(usexpr) return (reg & 001);
	MOV	EAX,[_usexpr]
	OR	EAX,EAX
	JZ	short _4_178 ; else return (YES);
_4_179:
	LEA	EBX,[EBP+12]
	MOV	EAX,[EBX]
	AND	EAX,1
	;MOV	ESP,EBP
	;POP	EBP
	;RETN
	JMP	short _4_180

_getpop:	; getpop(next) int *next; {
	PUSH	EBP
	MOV	EBP,ESP
	ADD	ESP,-8 ; char *cp; int level
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX	; level = 0;
	MOV	[EBX],EAX
_4_182:		; while(YES) {
		; if(next >= stail)
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	MOV	EAX,[_stail]
	CALL	__uge
	OR	EAX,EAX
	JE	short _4_184
_4_195:
_4_185:		; return 0;
	XOR	EAX,EAX
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_184:		; if(*next == POP2)
	;LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	MOV	EBX,[EAX]
	MOV	EAX,59	; POP2
	CALL	__eq
	OR	EAX,EAX
	JE	short _4_186
_4_187:		; if(level) --level;
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JE	short _4_188
_4_189:
	;LEA	EBX,[EBP-8]
	;MOV	EAX,[EBX]
	DEC	EAX
	MOV	[EBX],EAX
	JMP	short _4_190
_4_188:		; else return next;
	;LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
_4_183:
	MOV	ESP,EBP
	POP	EBP
	RETN
;_4_190:
	;JMP	short _4_191
_4_186:		; else if(*next == ADDSP) {
	;LEA	EDX,[EBP+8]
	;MOV	EAX,[EDX]
	;MOV	EBX,[EAX]
	MOV	EAX,2
	CALL	__eq
	OR	EAX,EAX
	JE	short _4_192
_4_193:	; if((level -= (next[1]>>LBPW)) < 0)
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	PUSH	EAX ; *
	;LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	ADD	EAX,4
	MOV	ECX,[EAX] ; next[1]
	SAR	ECX,1 ; LBPW = 1
	POP	EAX ; *
	; eax = level
	; ebx = (next[1] >> 1)
	SUB	EAX,ECX
	;LEA	EBX,[EBP-8]
	MOV	[EBX],EAX
	OR	EAX,EAX
	JL	short _4_195 ; return 0;
_4_194:
_4_197:
_4_196:
_4_190:
_4_191:		; next += 2;
	;LEA	EDX,[EBP+8]
	MOV	EAX,[EDX]
	ADD	EAX,8 ; 2 * int size
	MOV	[EDX],EAX
	JMP	short _4_182 ; while
_4_192:
	; else {
		; cp = code[*next];
	;LEA	EDX,[EBP+8] ; next
	;MOV	EAX,[EDX]
	;MOV	EBX,[EAX] ; *next
	SHL	EBX,1
	SHL	EBX,1	; * int size
	ADD	EBX,_code
	MOV	ECX,[EBX]
	LEA	EBX,[EBP-4] ; cp
	MOV	[EBX],ECX
		; if(*cp & PUSHES) ++level;
	;LEA	EBX,[EBP-4]
	;MOV	ECX,[EBX]
	MOVSX	EAX,BYTE [ECX]
	AND	EAX,64 ; PUSHES
	OR	EAX,EAX
	JZ	short _4_197
_4_198:		; ++level;
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _4_197

_colon:		; colon() {
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,58	; ':'
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc ; fputc(':', output);
	ADD	ESP,8
	;POP	EBP
	RETN

_newline:	; newline() {
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,13	; CR
	PUSH	EAX
	MOV	EAX,[_output] ; fputc('\15', output);
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
	MOV	EAX,10	; LF
	PUSH	EAX
	MOV	EAX,[_output] ; fputc(NEWLINE, output);
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
	;POP	EBP
	RETN

_outcode:	; outcode(pcode, value)
	PUSH	EBP
	MOV	EBP,ESP
		; int part, skip, count; byte_opt; 
		; char *cp, *back;
    		; int loc_label;
	;ADD	ESP,-28
	;	; part = back = 0;
	;LEA	EBX,[EBP-4]
	;LEA	EDX,[EBP-24]
	XOR	EAX,EAX
	;MOV	[EDX],EAX ; back = 0
	;MOV	[EBX],EAX ; part = 0
	;	; skip = NO;
	;LEA	EBX,[EBP-8]
	;;XOR	EAX,EAX
	;MOV	[EBX],EAX ; 0 (NO)
	;	; byte_opt = 0;
	;LEA	EBX,[EBP-16]
	;;XOR	EAX,EAX
	;MOV	[EBX],EAX
	PUSH	EAX ; [EBP-4] = part = 0
	PUSH	EAX ; [EBP-8] = skip = 0
	PUSH	EAX ; [EBP-12] = count = 0
	PUSH	EAX ; [EBP-16] = byte_opt = 0
	PUSH	EAX ; [EBP-20] = cp = 0
	PUSH	EAX ; [EBP-24] = back = 0
	PUSH	EAX ; [EBP-28] = loc_label = 0
		; cp = code[pcode] + 1;
	LEA	EDX,[EBP-20] ; cp
	MOV	ECX,_code
	LEA	EBX,[EBP+12] ; pcode
	MOV	EAX,[EBX]
	PUSH	EAX ; *
	SHL	EAX,1
	SHL	EAX,1	; * 4 (int size)
	ADD	ECX,EAX
	MOV	EAX,[ECX]
	INC	EAX ; +1
	MOV	[EDX],EAX
		; if (pcode == ADD1n)
	;LEA	EAX,[EBP+12]
	;MOV	EBX,[EAX]
	POP	EBX ; *
	MOV	EAX,74 ; ADD1n
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_202
_4_203:		; if (value < 0)
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	OR	EBX,EBX
	JNL	short _4_204
_4_205:		; pcode = SUB1n;
	LEA	ECX,[EBP+12]
	MOV	EAX,104 ; SUB1n;
	MOV	[ECX],EAX
		; value = -value;
	;LEA	EDX,[EBP+8]
	;MOV	EBX,[EDX]
	NEG	EBX
	MOV	[EDX],EBX
_4_204:		; if (value < 128)
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;MOV	EBX,EAX
	MOV	EAX,128
	CALL	__lt
	OR	EAX,EAX
	JZ	short _4_206
	; eax = 1
_4_207:		; byte_opt = 1;
	LEA	EBX,[EBP-16]
	;MOV	EAX,1
	MOV	[EBX],EAX
_4_206:
_4_202:
_4_257:
_4_254:
_4_237:
_4_226:
_4_208:		; while(*cp) {
	LEA	EDX,[EBP-20]
	MOV	EBX,[EDX]
	MOVSX	EAX,BYTE [EBX]
	OR	EAX,EAX
	JNZ	short _4_210
_4_209:
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_210:		; if(*cp == '<')
	;LEA	EDX,[EBP-20]
	;MOV	EBX,[EDX]
	;MOVSX	EAX,BYTE [EBX]
	MOV	EBX,EAX
	MOV	EAX,60	; '<'
	CALL	__eq
	OR	EAX,EAX
	;JZ	short _4_211 ; else
	JNZ	short _4_212
	JMP	_4_211
_4_212:		; ++cp;
	;LEA	EDX,[EBP-20]
	MOV	ECX,[EDX]
	INC	ECX ; +1
	MOV	[EDX],ECX
		; if(skip == NO)
	LEA	EBX,[EBP-8] ; skip
	MOV	EAX,[EBX]
	OR	EAX,EAX ; NO = 0
	;JNZ	short _4_213
	JZ	short _4_214
	JMP	_4_213
_4_214:		; switch(*cp)
	;LEA	EDX,[EBP-20]
	;MOV	ECX,[EDX]
	MOVSX	EAX,BYTE [ECX]
	JMP	short _4_217
_4_218: ; case 'm':
		; outname(value+NAME);
	LEA	EBX,[EBP+8] ; value
	MOV	EAX,[EBX]
	ADD	EAX,11 ; + NAME
	PUSH	EAX
	CALL	_outname
	;ADD	ESP,4
	POP	EAX
	JMP	_4_216	; break;
_4_219: ; case 'n':
		; if (byte_opt)
	LEA	EBX,[EBP-16]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JZ	short _4_220
_4_221:		; outstr ("BYTE ");
	;MOV	EAX,_4_201+0
	MOV	EAX,_BYTE_
	PUSH	EAX
	CALL	_outstr
	;ADD	ESP,4
	POP	EAX
_4_220:		; outdec(value);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_outdec
	;ADD	ESP,4
	POP	EAX
	JMP	short _4_216 ; break;
_4_222:	; case 'o':
		; offset(value);
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_offset
	;ADD	ESP,4
	POP	EAX
	JMP	short _4_216 ; break;
_4_223:	; case 'l':
		; outdec(litlab);
	MOV	EAX,[_litlab]
	PUSH	EAX
	CALL	_outdec
	;ADD	ESP,4
	POP	EAX
	JMP	short _4_216 ; break;
_4_224:	; case 'g':
		; loc_label = getlabel ();
	CALL	_getlabel
	LEA	EBX,[EBP-28]
	MOV	[EBX],EAX
	JMP	short _4_216 ; break;
_4_225:	; case 'd':
		; outdec(loc_label);
	LEA	EBX,[EBP-28]
	MOV	EAX,[EBX]
	PUSH	EAX
	CALL	_outdec	; outdec(loc_label);
	;ADD	ESP,4
	POP	EAX
	JMP	short _4_216 ; break;
_4_217:
		; switch(*cp)
	CALL	__switch

 DD _4_218 ; case 'm':	; /* mem ref by label */
 DD 109
 DD _4_219 ; case 'n':	; /* numeric constant */
 DD 110
 DD _4_222 ; case 'o':	; /* numeric constant */
 DD 111
 DD _4_223 ; case 'l':	; /* current literal label */
 DD 108
 DD _4_224 ; case 'g':	; /* generate local label */
 DD 103
 DD _4_225 ; case 'd':	; /* dump local label */
 DD 100
 DD 0

_4_216:
_4_213:		; cp += 2;  ; /* skip past > */
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX]
	ADD	EAX,2
	MOV	[EBX],EAX
	JMP	_4_226	; while
_4_211:	
		; else if(*cp == '?')
	;LEA	EDX,[EBP-20]
	; edx = [EBP-20]
	MOV	EAX,[EDX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,63  ; '?'
	CALL	__eq
	OR	EAX,EAX
	JZ	short _4_227 ; else
_4_228:
		; switch(++part)
	LEA	EBX,[EBP-4]
	MOV	EAX,[EBX]
	INC	EAX
	MOV	[EBX],EAX
	JMP	short _4_231
_4_232: ; case 1:
		; if(value == 0)
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNZ	short _4_233 ; break;
_4_234:		; skip = YES;
	LEA	EBX,[EBP-8]
	;MOV	EAX,1 ; YES
	;MOV	[EBX],EAX
	MOV	DWORD [EBX],1
	JMP	short _4_230 ; break;
_4_235:	; case 2:
		; skip = !skip;
	LEA	EBX,[EBP-8]
	;PUSH	EBX
	MOV	EAX,[EBX]
	CALL	__lneg
	;POP	EBX
	MOV	[EBX],EAX
	JMP	short _4_230 ; break;
_4_236: ; case 3:
		; part = 0;
	LEA	EBX,[EBP-4]
	XOR	EAX,EAX
	MOV	[EBX],EAX ; 0
		; skip = NO;
	LEA	EBX,[EBP-8]
	;XOR	EAX,EAX
	MOV	[EBX],EAX ; 0 ; NO
	JMP	short _4_230 ; break;
_4_231:
		; switch(++part) {
	CALL	__switch

 DD _4_232 ; case 1:
 DD 1
 DD _4_235 ; case 2:
 DD 2
 DD _4_236 ; case 3:
 DD 3
 DD 0

_4_233:
_4_230:		; ++cp; ; /* skip past ? */
	LEA	EBX,[EBP-20]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
	JMP	_4_237	; while
_4_227:		
		; else if(*cp == '#')
	LEA	EDX,[EBP-20]
	MOV	EAX,[EDX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,35 ; '#'
	CALL	__eq
	OR	EAX,EAX
	;JE	short _4_238 ; else
	JNE	short _4_239
	JMP	_4_238
_4_239:		; ++cp;
	;LEA	EDX,[EBP-20]
	;MOV	EAX,[EDX]
	;INC	EAX
	;MOV	[EDX],EAX
	INC	DWORD [EDX]
		; if(back == 0)
	LEA	EBX,[EBP-24]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNE	short _4_240
_4_241:		; if((count = value) < 1)
	LEA	EDX,[EBP+8] ; value
	MOV	EBX,[EDX]
	LEA	EDX,[EBP-12] ; count
	MOV	[EDX],EBX
	MOV	EAX,1
	CALL	__lt
	OR	EAX,EAX
	JZ	short _4_242
_4_243:
_4_247: ; (*)
_4_250:
_4_244:		; while(*cp && *cp++ != '#')
	LEA	EAX,[EBP-20]
	MOV	EDX,[EAX]
	MOVSX	EBX,BYTE [EDX] ; *cp
	OR	EBX,EBX
	;JZ	short _4_246
		 ; continue;
	;JZ	short _4_208 ; while
	JNZ	short _4_248
	JMP	_4_208
_4_248:		; &&
	;LEA	EAX,[EBP-20]
	;MOV	EDX,[EAX]
	;;INC	EDX
	;;MOV	[EAX],EDX
	;;DEC	EDX
	;MOVSX	EBX,BYTE [EDX]
	INC	DWORD [EAX] ;;
	MOV	EAX,35	; '#'
	CALL	__ne
	OR	EAX,EAX
	;;JZ	short _4_246
	;JZ	short _4_208 ; while
	JNZ	short _4_249
	JMP	_4_208
		; ;
_4_249:		; while (*)
	;MOV	EAX,1
	JMP	short _4_247 ; while (*)
_4_242:		; back = cp;
	LEA	EBX,[EBP-20] ; cp
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-24]; back
	MOV	[EBX],EAX
		; continue;
_4_246:
_4_245:
	JMP	_4_208	; while
_4_240:		; if(--count > 0)
	LEA	EBX,[EBP-12]
	;MOV	EAX,[EBX]
	;DEC	EAX
	;MOV	[EBX],EAX
	DEC	DWORD [EBX]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNG	short _4_251
_4_252:		; cp = back;
	LEA	EBX,[EBP-24] ; back
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-20] ; cp
	MOV	[EBX],EAX
	;JMP	short _4_253
	JMP	_4_254	; while
_4_251: ; else
		; back = 0;
	LEA	EBX,[EBP-24]
	XOR	EAX,EAX ; 0
	MOV	[EBX],EAX
_4_253:
	JMP	_4_254
_4_238:		; else if(skip == NO)
	LEA	EBX,[EBP-8]
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-20] ; *
	OR	EAX,EAX
	JNZ	short _4_255 ; else
_4_256:		; fputc(*cp++, output);
	;LEA	EBX,[EBP-20] ; *
	MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	;DEC	EAX
	MOVSX	ECX,BYTE [EAX]
	INC	DWORD [EBX]
	PUSH	ECX
	MOV	EAX,[_output]
	PUSH	EAX
	CALL	_OS_fputc
	ADD	ESP,8
	JMP	_4_257	; while
_4_255:	; else
	;	; ++cp;
	;LEA	EBX,[EBP-20] ; *
	; ebx = [EBP-20]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
	JMP	_4_208	; while

;_4_201:
;_BYTE_: DB "BYTE ",0 ; DB 66,89,84,69,32,0

_outdec:	; outdec(number) int number; {
	PUSH	EBP
	MOV	EBP,ESP
		; int k, zs; char c, *q, *r;
	ADD	ESP,-20
		; zs = 0;
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	MOV	[EBX],EAX
		; k = 1000000000;
	LEA	EBX,[EBP-4]
	MOV	EAX,1000000000
	MOV	[EBX],EAX
		; if(number < 0) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNL	short _4_259
_4_260:
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
		; fputc('-', output);
	MOV	EAX,45 ; '-'
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
_4_259:
_4_261:		; while (k >= 1) {
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__ge
	OR	EAX,EAX
	JNZ	short _4_263
_4_262:
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_263:		; q = 0;
	LEA	EBX,[EBP-16]
	XOR	EAX,EAX
	MOV	[EBX],EAX
		; r = number;
	LEA	EBX,[EBP+8] ; number
	MOV	EAX,[EBX]
	LEA	EBX,[EBP-20] ; r
	MOV	[EBX],EAX
_4_264:	; (*)	; while(r >= k) {++q; r = r - k;}
	;LEA	EAX,[EBP-20]
	;MOV	EBX,[EAX] ; r
	MOV	EBX,EAX ; **
	LEA	EDX,[EBP-4]
	MOV	EAX,[EDX] ; k
	CALL	__uge
	OR	EAX,EAX
	JE	short _4_265
_4_266:		; {++q; r = r - k;}
	LEA	EBX,[EBP-16]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC	DWORD [EBX]
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX] ; r
	LEA	EDX,[EBP-4]
	MOV	ECX,[EDX] ; k
	SUB	EAX,ECX
	MOV	[EBX],EAX ; **
	JMP	short _4_264 ; while (*)
_4_265:		; c = q + '0';
	LEA	EBX,[EBP-16] ; q
	MOV	ECX,[EBX]
	MOV	EAX,48	;'0'
	ADD	ECX,EAX
	LEA	EDX,[EBP-12] ; c
	MOV	[EDX],CL
		; if(c != '0' || k == 1 || zs) {
	MOVSX	EBX,BYTE [EDX] ; c
	CALL	__ne
	LEA	EDX,[EBP-8] ; *
	OR	EAX,EAX
	JNE	short _4_273
_4_270:		; k == 1;
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__eq
	OR	EAX,EAX
	JNE	short _4_273
_4_271:
	;LEA	EDX,[EBP-8] ; *
	MOV	EAX,[EDX] ; zs
	OR	EAX,EAX
	JE	short _4_272
_4_268:
_4_273:		; zs = 1;
	;LEA	EDX,[EBP-8] ; *
	MOV	EAX,1
	MOV	[EDX],EAX
		; fputc(c, output);
	LEA	EBX,[EBP-12]
	MOVSX	EAX,BYTE [EBX] ; c
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
_4_272:
_4_269:
_4_267:		; number = r;
	LEA	EBX,[EBP-20]
	MOV	EAX,[EBX] ; r
	LEA	EBX,[EBP+8]
	MOV	[EBX],EAX
		; k /= 10;
	LEA	EBX,[EBP-4] ; k
	MOV	EAX,[EBX]
	MOV	ECX,10
	CDQ
	IDIV	ECX
	MOV	[EBX],EAX
	JMP	_4_261	; while

_offset:	; offset(number)
	PUSH	EBP
	MOV	EBP,ESP
		; int k, zs; char c, *q, *r;
	ADD	ESP,-20
		; zs = 0;
	LEA	EBX,[EBP-8]
	XOR	EAX,EAX
	MOV	[EBX],EAX
		; k = 1000000000;
	LEA	EBX,[EBP-4]
	MOV	EAX,1000000000
	MOV	[EBX],EAX
		; if(number < 0) {
	LEA	EBX,[EBP+8]
	MOV	EAX,[EBX]
	OR	EAX,EAX
	JNL	short _4_275 ; else
_4_276:		; number = -number;
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	NEG	EAX
	MOV	[EBX],EAX
		; fputc('-', output);
	MOV	EAX,45 ; '-'
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
	JMP	short _4_277
_4_275:	; else {
		; fputc('+',output);
	MOV	EAX,43 ; '+'
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
_4_277:
_4_278:		; while (k >= 1) {
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__ge
	OR	EAX,EAX
	JNE	short _4_280
_4_279:
	MOV	ESP,EBP
	POP	EBP
	RETN
_4_280:		; q = 0;
	LEA	EBX,[EBP-16]
	XOR	EAX,EAX
	MOV	[EBX],EAX
		; r = number;
	LEA	EDX,[EBP+8]
	MOV	EBX,[EDX]
	LEA	EDX,[EBP-20] ; r
	MOV	[EDX],EBX
_4_281:		; while(r >= k) {++q; r = r - k;}
	;LEA	EDX,[EBP-20]
	MOV	EBX,[EDX]
	LEA	ECX,[EBP-4]
	MOV	EAX,[ECX]
_4_281_@:
	CALL	__uge
	OR	EAX,EAX
	JE	short _4_282
_4_283:		; {++q; r = r - k;}
	LEA	EBX,[EBP-16]
	;MOV	EAX,[EBX]
	;INC	EAX
	;MOV	[EBX],EAX
	INC 	DWORD [EBX]
	;LEA	EDX,[EBP-20]
	; edx = [EBP-20]
	MOV	EBX,[EDX] ; r
	LEA	ECX,[EBP-4]
	MOV	EAX,[ECX] ; k
	SUB	EBX,EAX	; r - k
	MOV	[EDX],EBX
	;JMP	short _4_281
	JMP	short _4_281_@
_4_282:		; c = q + '0';
	LEA	EDX,[EBP-12] ; c
	LEA	EAX,[EBP-16] ; q
	MOV	EBX,[EAX]
	;ADD	EBX,48 ; '0'
	;;ADD	BL,48
	MOV	EAX,48
	ADD	EBX,EAX
	MOV	[EDX],BL
		; if(c != '0' || k == 1 || zs) {
	;LEA	EDX,[EBP-12]
	MOVSX	EBX,BYTE [EDX] ; c
	;MOV	EAX,48 ; '0'
	CALL	__ne
	LEA	EDX,[EBP-8] ; *
	OR	EAX,EAX
	JNE	short _4_285
_4_287:		; k == 1;
	LEA	EAX,[EBP-4]
	MOV	EBX,[EAX]
	MOV	EAX,1
	CALL	__eq
	OR	EAX,EAX
	JNE	short _4_285
_4_288:
	;LEA	EDX,[EBP-8] ; *
	MOV	EAX,[EDX] ; zs
	OR	EAX,EAX
	JZ	short _4_289
_4_285:
_4_290:		; zs = 1;
	;LEA	EDX,[EBP-8] ; *
	MOV	EAX,1
	MOV	[EDX],EAX
		; fputc(c, output);
	LEA	EBX,[EBP-12]
	MOVSX	EAX,BYTE [EBX] ; c
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	CALL	_OS_fputc
	ADD	ESP,8
_4_289:
_4_286:
_4_284:		; number = r;
	LEA	EBX,[EBP+8]
	LEA	EDX,[EBP-20]
	MOV	EAX,[EDX] ; r
	MOV	[EBX],EAX
		; k /= 10;
	LEA	EBX,[EBP-4] ; k
	MOV	EAX,[EBX]
	MOV	ECX,10
	CDQ
	IDIV	ECX
	MOV	[EBX],EAX
	JMP	_4_278	; while

_outline:	; outline(ptr)
	PUSH	EBP
	MOV	EBP,ESP
	LEA	EBX,[EBP+8]	; char ptr[];
	MOV	EAX,[EBX]
	PUSH	EAX
	;MOV	CL,1
	CALL	_outstr		; outstr(ptr);
	ADD	ESP,4
	XOR	CL,CL
	CALL	_newline	; newline();
	POP	EBP
	RETN

_outname:	; outname(ptr)
	PUSH	EBP
	MOV	EBP,ESP
	MOV	EAX,UNDERSCORE	; _4_292+0
	PUSH	EAX
	;MOV	CL,1
	CALL	_outstr		; outstr("_");
	;ADD	ESP,4
	POP	EAX
_4_293:		; while(*ptr >= ' ')
	LEA	EBX,[EBP+8]	; char ptr[];
	MOV	EAX,[EBX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32		; SPACE
	CALL	__ge
	OR	EAX,EAX
	JZ	short _4_294
_4_295:		; fputc(*ptr++, output);
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	INC	DWORD [EAX]	; *ptr++
	MOVSX	EAX,BYTE [EBX]	; char = *ptr
	PUSH	EAX
	MOV	EAX,[_output]	; file handle
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc
	ADD	ESP,8
	JMP	short _4_293
_4_294:
	POP	EBP
	RETN

_4_292:
UNDERSCORE: DB "_",0 ; DB 95,0

_outstr:	; outstr(ptr)
	PUSH	EBP
	MOV	EBP,ESP
_4_297:		; while(*ptr == '\t' || *ptr >= ' ')
	LEA	EBX,[EBP+8]	; char ptr[];
	MOV	EAX,[EBX]
	MOVSX	EBX,BYTE [EAX]
	MOV	EAX,9		; '\t' ; TAB
	CALL	__eq
	OR	EAX,EAX
	JNZ	short _4_303	; condition 1 = true
	;LEA	EBX,[EBP+8]
	;MOV	EAX,[EBX]
	;MOVSX	EBX,BYTE [EAX]
	MOV	EAX,32		; SPACE
	CALL	__ge
	OR	EAX,EAX
	JZ	short _4_298	; condition 2 = false
_4_303:	
	LEA	EAX,[EBP+8]
	MOV	EBX,[EAX]
	INC	DWORD [EAX]	; *ptr++
	MOVSX	EAX,BYTE [EBX]	; char = *ptr
	PUSH	EAX
	MOV	EAX,[_output]	; file handle
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc	; fputc(*ptr++, output);
	ADD	ESP,8
	JMP	short _4_297
_4_298:
	POP	EBP
	RETN

_outtab:	; outtab ()
	;PUSH	EBP
	;MOV	EBP,ESP
	MOV	EAX,9
	PUSH	EAX
	MOV	EAX,[_output]
	PUSH	EAX
	;MOV	CL,2
	CALL	_OS_fputc ; fputc ('\t', output);
	ADD	ESP,8
	;POP	EBP
	RETN
   