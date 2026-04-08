; <><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
; <><><><><>   CP/M Large String Space Version   <><><><><>
; <><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
; 
; /* TRDOS 386 - Small C Compiler - 'lidstd.asm' */
; /* "printf" test */
; /* Erdogan Tan - 04/04/2026 */
; main()
	;;;; section '.text' code
	; FUNCTION: _main
_main:
; {
	push ebp
	mov ebp,esp
;   int a,b,d;
	push edx
	push edx
	push edx
;   char c;
	push edx
;   char *str;
	push edx
;   str = "TRDOS 386";
	lea eax,[ebp-20]
	push eax
	mov eax,cc1+0
	pop edx
	mov [edx],eax
;   a = 0x1a1;
	lea eax,[ebp-4]
	push eax
	mov eax,417
	pop edx
	mov [edx],eax
;   b = 417;
	lea eax,[ebp-8]
	push eax
	mov eax,417
	pop edx
	mov [edx],eax
;   c = 34;
	lea eax,[ebp-16]
	push eax
	mov eax,34
	pop edx
	mov [edx],al
;   d = 0641;
	lea eax,[ebp-12]
	push eax
	mov eax,641
	pop edx
	mov [edx],eax
;   printf("%s %cLIBSTD.C%c Test\n\nDecimal num: %d\n",str,c,c,b);
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-16]
	movsx eax,byte [eax]
	push eax
	lea eax,[ebp-16]
	movsx eax,byte [eax]
	push eax
	lea eax,[ebp-20]
	mov eax,[eax]
	push eax
	mov eax,cc1+10
	push eax
	mov cl,5 ; 04/04/2026 
	call _printf
	add esp,20
;   printf("Hexadecimal num: %x\nOctal: %o\nBinary num: %b\n",a,d,b);
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,cc1+49
	push eax
	mov cl,4 ; 04/04/2026
	call _printf
	add esp,16
; }
	mov esp,ebp
	pop ebp
	retn
	;;;; section '.data' data
cc1:
	db 84,82,68,79,83,32,51,56,54,0
	db 37,115,32,37,99,76,73,66,83,84
	db 68,46,67,37,99,32,84,101,115,116
	db 10,10,68,101,99,105,109,97,108,32
	db 110,117,109,58,32,37,100,10,0,72
	db 101,120,97,100,101,99,105,109,97,108
	db 32,110,117,109,58,32,37,120,10,79
	db 99,116,97,108,58,32,37,111,10,66
	db 105,110,97,114,121,32,110,117,109,58
	db 32,37,98,10,0

;  --- End of Compilation ---
	; "Small C"
