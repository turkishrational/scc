; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 26/09/2024
; -----------------------------------------------------------
; Derived from 'intrins.asm' file of KolibriOS SCC source code
; 2024

;
; Small-C Run Time Library for Win NT
;
; Nasm version  17/Nov/98  H T Walheim
; Revised:	20/Nov/98  HTW [Bugs in switch]
;

_CCARGC:
;B+ Ellipses arguments ( ,...)
  ;cl - argument count

  xor  eax,eax
  movzx eax,cl  ; No sign-extension
  retn
;E:.

;B+ Compare

__ult:
;B+ ???
  cmp  eax,ebx
  ja   short true
  xor  eax,eax
  retn
;E:.

__ugt:
;B+ ???
  cmp  eax,ebx
  jb   short true
  xor  eax,eax
  retn
;E:.

__ule:
;B+ ???
  cmp  eax,ebx
  jae  short true
  xor  eax,eax
  retn
;E:.

__uge:
;B+ ???
  cmp  eax,ebx
  jbe  short true
  xor  eax,eax
  retn
;E:.

__eq:
;B+ ???
  cmp  eax,ebx
  je   short true
  xor  eax,eax
  retn
;E:.

__ne:
;B+ ???
  cmp  eax,ebx
  jne  short true
  xor  eax,eax
  retn
;E:.

__lt:
;B+ ???
  cmp  eax,ebx
  jg   short true
  xor  eax,eax
  retn
;E:.

__gt:
;B+ ???
  cmp  eax,ebx
  jl   short true
  xor  eax,eax
  retn
;E:.

__le:
;B+ ???
  cmp  eax,ebx
  jge  short true
  xor  eax,eax
  retn
;E:.

__ge:
;B+ ???
  cmp  eax,ebx
  jle  short true
  xor  eax,eax
  retn
;E:.

;E:.

__lneg:
;B+ Logical Negate of Primary
  or   eax,eax
  jnz  short false
true:
  mov  eax,1
  retn

false:
  xor  eax,eax
  retn
;E:.

__switch:
;B+ Execute "switch" statement

 ;eax   - switch value
 ;[esp] - pointer to switch table
 ;   dd addr1,value1
 ;         ...
 ;   dd 0
 ;   [jmp default]
 ;   continuation
 ;
 ; Revised: 20/Nov/98 [JECXZ needed]

  pop  ebx
  jmp  short skip
back:
  add  ebx,8        ;next case-pair
skip:
  mov  ecx,[ebx]    ;case-label location (adress)
  jecxz default
  cmp  eax,[ebx+4]  ;test case-value
  jnz  short back
  jmp  ecx          ;match -- jump to case
default:
  add  ebx,4
  jmp  ebx          ;jump to default/continuation
;E:.
