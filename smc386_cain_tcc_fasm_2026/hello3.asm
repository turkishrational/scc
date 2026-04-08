; <><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
; <><><><><>   CP/M Large String Space Version   <><><><><>
; <><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
; 
; #include stdio.h
; /*-----------------------------------------------------------
; * Small C Compiler for TRDOS 386 (v2.0.9 and later)
; * Erdogan Tan - 2024
; * Beginning: 05/09/2024
; * Last Update: 23/09/2024
; * -----------------------------------------------------------
; * Derived from 'stdio.h' file of KolibriOS SCC source code
; * 2024
; */
; /*
; ** STDIO.H -- Standard Small C Definitions.
; */
; /* TRDOS 386 Modification
; extern char _iob[];
; */
; #define exit	OS_exit
; #define fopen	OS_fopen
; #define fgetc	OS_fgetc
; #define fputc	OS_fputc
; #define fclose	OS_fclose
; #define calloc	OS_calloc	// stdlib.h
; #define SIZEOF_FILE 32		// sizeof (FILE)
; /* TRDOS 386 Modification
; #define stdin  (&_iob[0])
; #define stdout (&_iob[1*SIZEOF_FILE])
; #define stderr (&_iob[2*SIZEOF_FILE])
; */
; /* TRDOS 386 Modification */
; #define stdin  -1  /* sign for using '_OS_getc' instead of '_OS_fgetc' */
; #define stdout -1  /* sign for using '_OS_putc' instead of '_OS_fputc' */	
; #define stderr -1  /* sign for using '_OS_putc' instead of '_OS_fputc' */
; #define stdaux   3  /* file descriptor for standard auxiliary port */
; #define stdprn   4  /* file descriptor for standard printer */
; #define FILE  char  /* supports "FILE *fp;" declarations */
; #define ERR   (-2)  /* return value for errors */
; #define EOF   (-1)  /* return value for end-of-file */
; #define YES      1  /* true */
; #define NO       0  /* false */
; #define NULL     0  /* zero */
; #define CR      13  /* ASCII carriage return */
; #define LF      10  /* ASCII line feed */
; #define BELL     7  /* ASCII bell */
; #define SPACE  ' '  /* ASCII space */
; #define NEWLINE LF  /* Small C newline character */
; #define CVALUE 65536
; main()
	;;;; section '.text' code
	; FUNCTION: _main
_main:
; {
	push ebp
	mov ebp,esp
;   int a, b, c, d;
	push edx
	push edx
	push edx
	push edx
;   a = -1;
	lea eax,[ebp-4]
	push eax
	mov eax,1
	neg eax
	pop edx
	mov [edx],eax
;   b = 0;
	lea eax,[ebp-8]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   c = CVALUE;
	lea eax,[ebp-12]
	push eax
	mov eax,65536
	pop edx
	mov [edx],eax
;   d = 1000000;
	lea eax,[ebp-16]
	push eax
	mov eax,1000000
	pop edx
	mov [edx],eax
;   b = a*c; 		
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	lea eax,[ebp-12]
	mov eax,[eax]
	pop edx
	imul edx
	pop edx
	mov [edx],eax
;   printf("Hello, World!\n");
	mov eax,cc1+0
	push eax
	call _printf
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
	;;;; section '.data' data
cc1:
	db 72,101,108,108,111,44,32,87,111,114
	db 108,100,33,10,0

;  --- End of Compilation ---
	; "Small C"
