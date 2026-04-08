; <><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
; <><><><><>   CP/M Large String Space Version   <><><><><>
; <><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
; 
; /* -----------------------------------------------------------
;  * Small C Compiler (Roy Cain) for TRDOS 386 (v2.0.9 & later)
;  * Erdogan Tan - 2026 !!! Modified for FASM syntax !!!
;  * Beginning: 27/03/2026
;  * Last Update: 05/04/2026
;  * -----------------------------------------------------------
;  * Derived from 'smc386c.c' file 
;  *	of adamsch1's 'scc' repository in GitHub
;  *
;  * https://github.com/adamsch1/scc (smc386c.c)
; */
; /* SMALLC Self Compiler Version - 28/03/2026 */
; /************************************************/
; /*                                              */
; /*    small-c compiler                          */
; /*                                              */
; /*      by Ron Cain                             */
; /*                                              */
; /************************************************/
; /* with minor mods by RDK */
; /* Hacked for IA32/Linux by Evgueniy Vitchev - 
;    provided 'for' and 'do' statements */
; /*
; This fella outpus GAS assembler suitable for GNU toolchain - nice!
; http://www.physics.rutgers.edu/~vitchev/smallc-i386.html
; The compiler can be bootstrapped by using gcc in the following way:
;     Build a stage 1 compiler:
;     gcc -o smc386c1 smc386c.c
;     Using the stage 1 compiler build a stage 2 compiler:
;     ./smc386c1
;     Output filename? smc386c2.s
;     Input filename? smc386c.c
;     Input filename? <enter>
;     There were 0 errors in compilation.
;     gcc -o smc386c2 smc386c2.s
;     In order to make sure everything went properly, go to stage 3:
;     ./smc386c2
;     Output filename? smc386c3.s
;     Input filename? smc386c.c
;     Input filename? <enter>
;     diff smc386c2.s smc386c3.s
;     If diff doesn't produce output, this means the bootstrap was successful,
;        and you can use the stage 2 compiler smc386c2.
; */
; #define BANNER  "<><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>"
; #define VERSION "<><><><><>   CP/M Large String Space Version   <><><><><>"
; #define AUTHOR  "<><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>"
; #define HCK     "<><><> Hacked for IA32/Linux by Evgueniy Vitchev <><><><>"
; #define LINE    "<><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>"
; #define IDNT    "Small C"
; /*#asm
;   DB  'SMALL-C COMPILER V.1.2 DOS--CP/M CROSS COMPILER',0
;   #endasm*/
; /*  Define system dependent parameters  */
; /*  Stand-alone definitions      */
; /* INCLUDE THE LIBRARY TO COMPILE THE COMPILER (RDK) */
; /* #include smallc.lib */ /* small-c library included in source now */
; /* IN DOS USE THE SMALL-C OBJ LIBRARY RATHER THAN IN-LINE ASSEMBLER */
; #define NULL 0
; #define EOL 10 /* was 13 */
; /* 28/03/2026 - TRDOS 386 v2 Modification */
; #define CR 13
; #define LF 10
; /*  UNIX definitions (if not stand-alone)  */
; /* #include "stdio.h"  /* was <stdio.h> */
; /* #define EOL 10  */
; /*  Define the symbol table parameters  */
; #define  SYMSIZ  14
; #define  SYMTBSZ  5040
; #define  NUMGLBS 300
; #define  STARTGLB SYMTAB
; #define  ENDGLB  STARTGLB+NUMGLBS*SYMSIZ
; #define  STARTLOC ENDGLB+SYMSIZ
; #define  ENDLOC  SYMTAB+SYMTBSZ-SYMSIZ
; /*  Define symbol table entry format  */
; #define  NAME  0
; #define  IDENT  9
; #define  TYPE  10
; #define  STORAGE  11
; #define  OFFSET  12
; /*  System wide NAME size (for symbols)  */
; #define  NAMESIZE 9
; #define  NAMEMAX  8
; /*  Define possible entries for "IDENT"  */
; #define  VARIABLE 1
; #define  ARRAY  2
; #define  POINTER  3
; #define  FUNCTION 4
; #define  STRUCT   5
; /*  Define possible entries for "TYPE"  */
; #define  CCHAR   1
; #define  CINT    2
; #define  CSTRUCT 3
; /*  Define possible entries for "STORAGE"  */
; #define  STATIK  1
; #define  STKLOC  2
; /*  Define the "while" statement queue  */
; #define  WQTABSZ  300
; #define  WQSIZ  4
; #define  WQMAX  wq+WQTABSZ-WQSIZ
; /*  Define entry OFFSETs in while queue  */
; #define  WQSYM  0
; #define  WQSP  1
; #define  WQLOOP  2
; #define  WQLAB  3
; /*  Define the literal pool      */
; #define  LITABSZ  8000
; #define  LITMAX  LITABSZ-1
; /*  Define the input line      */
; #define  LINESIZE 80
; #define  LINEMAX  LINESIZE-1
; #define  MPMAX  LINEMAX
; /*  Define the macro (define) pool    */
; #define  MACQSIZE 3000
; #define  MACMAX  MACQSIZE-1
; /*  Define statement TYPEs (tokens)    */
; #define  STIF  1
; #define  STWHILE  2
; #define  STRETURN 3
; #define  STBREAK  4
; #define  STCONT  5
; #define  STASM  6
; #define  STEXP  7
; #define  STFOR   9
; #define  STDO    10
; /* Define how to carve up a NAME too long for the assembler */
; #define ASMPREF  7
; #define ASMSUFF  7
; /*Added by E.V.*/
; #define LITSTKSZ 5000
; #define LITSTKNUM 10
; int tolitstk;
; char litstk[LITSTKSZ];
; char litstk2[LITSTKSZ];
; int litstklens[LITSTKNUM];
; int litstkptrs[LITSTKNUM];/*0 is reserved for the file output!*/
; putlitstk(c)
	;;;; section '.text' code
	; FUNCTION: _putlitst
_putlitst:
;    char c;
	push ebp
	mov ebp,esp
; {
;   if(litstkptrs[tolitstk]+litstklens[tolitstk]>=LITSTKSZ-1)
	mov eax,_litstkpt
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	add eax,edx
	push eax
	mov eax,5000
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc2
;   {error("too large code from FUNCTION arguments");return 0;}
	mov eax,cc1+0
	push eax
	call _error
	pop edx
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   /*litstk[litstkptrs[tolitstk]+litstklens[tolitstk]++]=c;*/
;   litstk[litstkptrs[tolitstk]+litstklens[tolitstk]]=c;
cc2:
	mov eax,_litstk
	push eax
	mov eax,_litstkpt
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   litstklens[tolitstk]=litstklens[tolitstk]+1;
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;   return c;
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; getlitstk()
	;;;; section '.text' code
	; FUNCTION: _getlitst
_getlitst:
; {
	push ebp
	mov ebp,esp
;   if(tolitstk>=LITSTKNUM-1)
	mov eax,[_tolitstk]
	push eax
	mov eax,10
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc3
;   {error("too many FUNCTION arguments");return 0;}
	mov eax,cc1+39
	push eax
	call _error
	pop edx
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   tolitstk++;
cc3:
	mov eax,[_tolitstk]
	inc eax
	mov [_tolitstk],eax
	dec eax
;   litstklens[tolitstk]=0;
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   litstkptrs[tolitstk]=litstkptrs[tolitstk-1]+litstklens[tolitstk-1];
	mov eax,_litstkpt
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,_litstkpt
	push eax
	mov eax,[_tolitstk]
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;   return tolitstk;
	mov eax,[_tolitstk]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; dumpltstk(tl)
	;;;; section '.text' code
	; FUNCTION: _dumpltst
_dumpltst:
;    int tl;
	push ebp
	mov ebp,esp
; {
;   int i,p;
	push edx
	push edx
;   char*q;
	push edx
;   q=litstk2;
	lea eax,[ebp-12]
	push eax
	mov eax,_litstk2
	pop edx
	mov [edx],eax
;   while(tolitstk>=tl)
cc4:
	mov eax,[_tolitstk]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc5
;   {
;     i=litstklens[tolitstk];
	lea eax,[ebp-4]
	push eax
	mov eax,_litstkle
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;     p=litstkptrs[tolitstk];
	lea eax,[ebp-8]
	push eax
	mov eax,_litstkpt
	push eax
	mov eax,[_tolitstk]
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;     while(i--)
cc6:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	dec eax
	pop edx
	mov [edx],eax
	inc eax
	test eax,eax
	je cc7
;     {
;       /*printf("litstk[p]=%c,%d\n",litstk[p],litstk[p]);*/
;       *q++=litstk[p++];
	lea eax,[ebp-12]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	push eax
	mov eax,_litstk
	push eax
	lea eax,[ebp-8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;       /*outbyte1(litstk[p++]);*/
;     }
	jmp cc6
cc7:
;     tolitstk--;
	mov eax,[_tolitstk]
	dec eax
	mov [_tolitstk],eax
	inc eax
;   }
	jmp cc4
cc5:
;   /*printf("tolitstk=%d\n",tolitstk);*/
;   p=q;
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp-12]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;   q=litstk2;
	lea eax,[ebp-12]
	push eax
	mov eax,_litstk2
	pop edx
	mov [edx],eax
;   while(q<p)
cc8:
	lea eax,[ebp-12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	pop edx
	cmp edx,eax
	setb al
	movzx eax,al
	test eax,eax
	je cc9
;   {
;     /*printf("*q=%c,%d\n",*q,*q);*/
;     outbyte(*q);
	lea eax,[ebp-12]
	mov eax,[eax]
	movsx eax,byte [eax]
	push eax
	call _outbyte
	pop edx
;     q++;
	lea eax,[ebp-12]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
;   }
	jmp cc8
cc9:
; }
	mov esp,ebp
	pop ebp
	retn
; /*End- Added by E.V.*/
; /*  Now reserve some STORAGE words    */
; char  SYMTAB[SYMTBSZ];  /* symbol table */
; char  *glbptr,*locptr;    /* ptrs to next entries */
; int  wq[WQTABSZ];    /* while queue */
; int  *wqptr;      /* ptr to next entry */
; char  litq[LITABSZ];    /* literal pool */
; int  litptr;      /* ptr to next entry */
; char  macq[MACQSIZE];    /* macro string buffer */
; int  macptr;      /* and its index */
; char  line[LINESIZE];    /* parsing buffer */
; char  mline[LINESIZE];  /* temp macro buffer */
; int  lptr,mptr;    /* ptrs into each */
; int field_of; /* field offset in struct */
; /*  Misc STORAGE  */
; int  nxtlab,    /* next avail label # */
;   litlab,    /* label # assigned to literal pool */
;   Zsp,    /* compiler relative stk ptr */
;   argstk,    /* FUNCTION arg sp */
;   argtop, /*added by E.V.*/
;   ncmp,    /* # open compound statements */
;   errcnt,    /* # errors in compilation */
;   errstop,  /* stop on error      gtf 7/17/80 */
;   eof,    /* set non-zero on final input eof */
;   input,    /* iob # for input file */
;   output,    /* iob # for output file (if any) */
;   input2,    /* iob # for "incude" file */
;   glbflag,  /* non-zero if internal globals */
;   ctext,    /* non-zero to intermix c-source */
;   cmode,    /* non-zero while parsing c-code */
;       /* zero when passing assembly code */
;   lastst,    /* last executed statement TYPE */
;   mainflg,  /* output is to be first asm file  gtf 4/9/80 */
;   saveout,  /* holds output ptr when diverted to console     */
;       /*          gtf 7/16/80 */
;   kandr,    /* Current function decl K&R style? */
;   fnstart,  /* line# of start of current fn.  gtf 7/2/80 */
;   lineno,    /* line# in current file    gtf 7/2/80 */
;   infunc,    /* "inside FUNCTION" flag    gtf 7/2/80 */
;   savestart,  /* copy of fnstart "  "    gtf 7/16/80 */
;   saveline,  /* copy of lineno  "  "    gtf 7/16/80 */
;   saveinfn;  /* copy of infunc  "  "    gtf 7/16/80 */
; char   *currfn,    /* ptr to SYMTAB entry for current fn.  gtf 7/17/80 */
;        *savecurr;  /* copy of currfn for #include    gtf 7/17/80 */
; char  quote[2];  /* literal string for '"' */
; char  *cptr;    /* work ptr to any char buffer */
; int  *iptr;    /* work ptr to any int buffer */
; /*  >>>>> start cc1 <<<<<<    */
; /*          */
; /*  Compiler begins execution here  */
; /*          */
; main( int argc, char *argv[]) {
	;;;; section '.text' code
	; FUNCTION: _main
_main:
	push ebp
	mov ebp,esp
;   glbptr=STARTGLB;  /* clear global symbols */
	mov eax,_SYMTAB
	mov [_glbptr],eax
;   locptr=STARTLOC;  /* clear local symbols */
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   wqptr=wq;    /* clear while queue */
	mov eax,_wq
	mov [_wqptr],eax
;   tolitstk=
;   litstkptrs[0]=
	mov eax,_litstkpt
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
;   litstklens[0]=
	mov eax,_litstkle
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
;   macptr=    /* clear the macro pool */
;   litptr=    /* clear literal pool */
;     Zsp =    /* stack ptr (relative) */
;   errcnt=    /* no errors */
;   errstop=  /* keep going after an error    gtf 7/17/80 */
;   eof=    /* not eof yet */
;   input=    /* no input file */
;   input2=    /* or include file */
;   output=    /* no open units */
;   saveout=  /* no diverted output */
;   ncmp=    /* no open compound states */
;   lastst=    /* no last statement yet */
;   mainflg=  /* not first file to asm     gtf 4/9/80 */
;   fnstart=  /* current "FUNCTION" started at line 0 gtf 7/2/80 */
;   lineno=    /* no lines read from file    gtf 7/2/80 */
;   infunc=    /* not in FUNCTION now      gtf 7/2/80 */
;   quote[1]=
	mov eax,_quote
	push eax
	mov eax,1
	pop edx
	add eax,edx
	push eax
;   0;    /*  ...all set to zero.... */
	mov eax,0
	pop edx
	mov [edx],al
	mov [_infunc],eax
	mov [_lineno],eax
	mov [_fnstart],eax
	mov [_mainflg],eax
	mov [_lastst],eax
	mov [_ncmp],eax
	mov [_saveout],eax
	mov [_output],eax
	mov [_input2],eax
	mov [_input],eax
	mov [_eof],eax
	mov [_errstop],eax
	mov [_errcnt],eax
	mov [_Zsp],eax
	mov [_litptr],eax
	mov [_macptr],eax
	pop edx
	mov [edx],eax
	pop edx
	mov [edx],eax
	mov [_tolitstk],eax
;   quote[0]='"';    /* fake a quote literal */
	mov eax,_quote
	push eax
	mov eax,0
	pop edx
	add eax,edx
	push eax
	mov eax,34
	pop edx
	mov [edx],al
;   currfn=NULL;  /* no FUNCTION yet      gtf 7/2/80 */
	mov eax,0
	mov [_currfn],eax
;   cmode=1;  /* enable preprocessing */
	mov eax,1
	mov [_cmode],eax
;   /*        */
;   /*  compiler body    */
;   /*        */
;   ask();      /* get user options */
	call _ask
;   openout();    /* get an output file */
	call _openout
;   openin();    /* and initial input file */
	call _openin
;   header();    /* intro code */
	call _header
;   parse();     /* process ALL input */
	call _parse
;   dumplits();    /* then dump literal pool */
	call _dumplits
;   dumpglbs();    /* and all static memory */
	call _dumpglbs
;   trailer();    /* follow-up code */
	call _trailer
;   closeout();    /* close the output (if any) */
	call _closeout
;   errorsummary();    /* summarize errors (on console!) */
	call _errorsum
;   return;      /* then exit to system */
	mov esp,ebp
	pop ebp
	retn
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Abort compilation    */
; /*    gtf 7/17/80    */
; zabort()
	;;;; section '.text' code
	; FUNCTION: _zabort
_zabort:
; {
	push ebp
	mov ebp,esp
;   if(input2)
	mov eax,[_input2]
	test eax,eax
	je cc10
;     endinclude();
	call _endinclu
;   if(input)
cc10:
	mov eax,[_input]
	test eax,eax
	je cc11
;     fclose(input);
	mov eax,[_input]
	push eax
	call _fclose
	pop edx
;   closeout();
cc11:
	call _closeout
;   toconsole();
	call _toconsol
;   pl("Compilation aborted.");  nl();
	mov eax,cc1+67
	push eax
	call _pl
	pop edx
	call _nl
;   exit(0);
	mov eax,0
	push eax
	call _exit
	pop edx
; /* end zabort */}
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Process all input text    */
; /*          */
; /* At this level, only static declarations, */
; /*  defines, includes, and FUNCTION */
; /*  definitions are legal...  */
; parse()
	;;;; section '.text' code
	; FUNCTION: _parse
_parse:
;   {
	push ebp
	mov ebp,esp
;   while (eof==0)    /* do until no more input */
cc12:
	mov eax,[_eof]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc13
;     {
;     if(amatch("char",4)){declglb(CCHAR);ns();}
	mov eax,4
	push eax
	mov eax,cc1+88
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc14
	mov eax,1
	push eax
	call _declglb
	pop edx
	call _ns
;     else if(amatch("int",3)){declglb(CINT);ns();}
	jmp cc15
cc14:
	mov eax,3
	push eax
	mov eax,cc1+93
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc16
	mov eax,2
	push eax
	call _declglb
	pop edx
	call _ns
;     else if(amatch("struct",6)){newstruct();}
	jmp cc17
cc16:
	mov eax,6
	push eax
	mov eax,cc1+97
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc18
	call _newstruc
;     else if(match("#asm"))doasm();
	jmp cc19
cc18:
	mov eax,cc1+104
	push eax
	call _match
	pop edx
	test eax,eax
	je cc20
	call _doasm
;     else if(match("#include"))doinclude();
	jmp cc21
cc20:
	mov eax,cc1+109
	push eax
	call _match
	pop edx
	test eax,eax
	je cc22
	call _doinclud
;     else if(match("#define"))addmac();
	jmp cc23
cc22:
	mov eax,cc1+118
	push eax
	call _match
	pop edx
	test eax,eax
	je cc24
	call _addmac
;     else newfunc();
	jmp cc25
cc24:
	call _newfunc
cc25:
cc23:
cc21:
cc19:
cc17:
cc15:
;     blanks();  /* force eof if pending */
	call _blanks
;     }
	jmp cc12
cc13:
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Dump the literal pool    */
; /*          */
; dumplits()
	;;;; section '.text' code
	; FUNCTION: _dumplits
_dumplits:
;   {int j,k;
	push ebp
	mov ebp,esp
	push edx
	push edx
;   if (litptr==0) return;  /* if nothing there, exit...*/
	mov eax,[_litptr]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc26
	mov esp,ebp
	pop ebp
	retn
;   ot(";;;; section '.data' data");nl();
cc26:
	mov eax,cc1+126
	push eax
	call _ot
	pop edx
	call _nl
;   printlabel(litlab);col();nl(); /* print literal label */
	mov eax,[_litlab]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   k=0;      /* init an index... */
	lea eax,[ebp-8]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while (k<litptr)  /*   to loop with */
cc27:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,[_litptr]
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc28
;     {defbyte();  /* pseudo-op to define byte */
	call _defbyte
;     j=10;    /* max bytes per line */
	lea eax,[ebp-4]
	push eax
	mov eax,10
	pop edx
	mov [edx],eax
;     while(j--)
cc29:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	dec eax
	pop edx
	mov [edx],eax
	inc eax
	test eax,eax
	je cc30
;       {outdec((litq[k++]&127));
	mov eax,_litq
	push eax
	lea eax,[ebp-8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	push eax
	call _outdec
	pop edx
;       if ((j==0) | (k>=litptr))
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,[_litptr]
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc31
;         {nl();    /* need <cr> */
	call _nl
;         break;
	jmp cc30
;         }
;       outbyte(',');  /* separate bytes */
cc31:
	mov eax,44
	push eax
	call _outbyte
	pop edx
;       }
	jmp cc29
cc30:
;     }
	jmp cc27
cc28:
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Dump all static VARIABLEs  */
; /*          */
; dumpglbs()
	;;;; section '.text' code
	; FUNCTION: _dumpglbs
_dumpglbs:
;   {
	push ebp
	mov ebp,esp
;   int j;
	push edx
;   if(glbflag==0)return;  /* don't if user said no */
	mov eax,[_glbflag]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc32
	mov esp,ebp
	pop ebp
	retn
;   cptr=STARTGLB;
cc32:
	mov eax,_SYMTAB
	mov [_cptr],eax
;   while(cptr<glbptr)
cc33:
	mov eax,[_cptr]
	push eax
	mov eax,[_glbptr]
	pop edx
	cmp edx,eax
	setb al
	movzx eax,al
	test eax,eax
	je cc34
;     {
;      if(cptr[IDENT]==STRUCT ) {
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,5
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc35
;        cptr=cptr+SYMSIZ;
	mov eax,[_cptr]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_cptr],eax
;      } else if(cptr[IDENT]!=FUNCTION)
	jmp cc36
cc35:
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc37
;       /* do if anything but FUNCTION */
;       {/*col();*/
;         /* output NAME as label... */
;       tab();outname(cptr);  /* define STORAGE */
	call _tab
	mov eax,[_cptr]
	push eax
	call _outname
	pop edx
;       outasm (": ");
	mov eax,cc1+152
	push eax
	call _outasm
	pop edx
;       j=((cptr[OFFSET]&255)+
	lea eax,[ebp-4]
	push eax
	mov eax,[_cptr]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,255
	pop edx
	and eax,edx
	push eax
;         ((cptr[OFFSET+1]&255)<<8));
	mov eax,[_cptr]
	push eax
	mov eax,12
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,255
	pop edx
	and eax,edx
	push eax
	mov eax,8
	pop edx
	mov ecx,eax
	mov eax,edx
	sal eax,cl
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;           /* calc # bytes */
;       if(cptr[TYPE]==CINT|cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc38
;         outasm("rd ");
	mov eax,cc1+155
	push eax
	call _outasm
	pop edx
;       else
	jmp cc39
cc38:
;         outasm("rb ");
	mov eax,cc1+159
	push eax
	call _outasm
	pop edx
cc39:
;       outdec(j);
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _outdec
	pop edx
;       nl();
	call _nl
;         cptr=cptr+SYMSIZ;
	mov eax,[_cptr]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_cptr],eax
;       } else {
	jmp cc40
cc37:
;         cptr=cptr+SYMSIZ;
	mov eax,[_cptr]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_cptr],eax
;       }
cc40:
cc36:
;     }
	jmp cc33
cc34:
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Report errors for user    */
; /*          */
; errorsummary()
	;;;; section '.text' code
	; FUNCTION: _errorsum
_errorsum:
;   {
	push ebp
	mov ebp,esp
;   /* see if anything left hanging... */
;   if (ncmp) error("missing closing bracket");
	mov eax,[_ncmp]
	test eax,eax
	je cc41
	mov eax,cc1+163
	push eax
	call _error
	pop edx
;     /* open compound statement ... */
;   nl();
cc41:
	call _nl
;   outstr("There were ");
	mov eax,cc1+187
	push eax
	call _outstr
	pop edx
;   outdec(errcnt);  /* total # errors */
	mov eax,[_errcnt]
	push eax
	call _outdec
	pop edx
;   outstr(" errors in compilation.");
	mov eax,cc1+199
	push eax
	call _outstr
	pop edx
;   nl();
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Get options from user    */
; /*          */
; ask() {
	;;;; section '.text' code
	; FUNCTION: _ask
_ask:
	push ebp
	mov ebp,esp
;   int k,num[1];
	push edx
	push edx
;   kill();      /* clear input line */
	call _kill
;   outbyte(12);    /* clear the screen */
	mov eax,12
	push eax
	call _outbyte
	pop edx
;   nl();nl();    /* print banner */
	call _nl
	call _nl
;   pl(LINE);
	mov eax,cc1+223
	push eax
	call _pl
	pop edx
;   pl(BANNER);
	mov eax,cc1+281
	push eax
	call _pl
	pop edx
;   pl(AUTHOR);
	mov eax,cc1+339
	push eax
	call _pl
	pop edx
;   /*pl(VERSION);*/
;   pl(HCK);
	mov eax,cc1+397
	push eax
	call _pl
	pop edx
;   pl(LINE);
	mov eax,cc1+455
	push eax
	call _pl
	pop edx
;   nl();nl();
	call _nl
	call _nl
;   ctext=1;    /* assume yes */
	mov eax,1
	mov [_ctext],eax
;   glbflag=1;  /* define globals */
	mov eax,1
	mov [_glbflag],eax
;   mainflg=1;  /* first file to assembler */
	mov eax,1
	mov [_mainflg],eax
;   nxtlab =0;  /* start numbers at lowest possible */
	mov eax,0
	mov [_nxtlab],eax
;   errstop=0;
	mov eax,0
	mov [_errstop],eax
;   litlab=getlabel();  /* first label=literal pool */ 
	call _getlabel
	mov [_litlab],eax
;   kill();      /* erase line */
	call _kill
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Get output filename    */
; /*          */
; openout()
	;;;; section '.text' code
	; FUNCTION: _openout
_openout:
;   {
	push ebp
	mov ebp,esp
;   kill();      /* erase line */
	call _kill
;   output=0;    /* start with none */
	mov eax,0
	mov [_output],eax
;   pl("Output filename? "); /* ask...*/
	mov eax,cc1+513
	push eax
	call _pl
	pop edx
;   gets(line);  /* get a filename */
	mov eax,_line
	push eax
	call _gets
	pop edx
;   if(ch()==0)return;  /* none given... */
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc42
	mov esp,ebp
	pop ebp
	retn
;   /* if((output=fopen(line,"w"))==NULL) */
;   if((output=fopen(line,"w"))==NULL) /* if given, open */ /* SMALLC */
cc42:
	mov eax,cc1+531
	push eax
	mov eax,_line
	push eax
	call _fopen
	add esp,8
	mov [_output],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc43
;     {output=0;  /* can't open */
	mov eax,0
	mov [_output],eax
;     error("Open failure!");
	mov eax,cc1+533
	push eax
	call _error
	pop edx
;     }
;   kill();      /* erase line */
cc43:
	call _kill
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Get (next) input file    */
; /*          */
; openin()
	;;;; section '.text' code
	; FUNCTION: _openin
_openin:
; {
	push ebp
	mov ebp,esp
;   input=0;    /* none to start with */
	mov eax,0
	mov [_input],eax
;   while(input==0){  /* any above 1 allowed */
cc44:
	mov eax,[_input]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc45
;     kill();    /* clear line */
	call _kill
;     if(eof)break;  /* if user said none */
	mov eax,[_eof]
	test eax,eax
	je cc46
	jmp cc45
;     pl("Input filename? ");
cc46:
	mov eax,cc1+547
	push eax
	call _pl
	pop edx
;     gets(line);  /* get a NAME */
	mov eax,_line
	push eax
	call _gets
	pop edx
;     if(ch()==0)
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc47
;       {eof=1;break;} /* none given... */ 
	mov eax,1
	mov [_eof],eax
	jmp cc45
;     /* if((input=fopen(line,"r"))!=NULL) */	
;     if((input=fopen(line,"r"))!=NULL) /* SMALLC */
cc47:
	mov eax,cc1+564
	push eax
	mov eax,_line
	push eax
	call _fopen
	add esp,8
	mov [_input],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc48
;       newfile();      /* gtf 7/16/80 */
	call _newfile
;     else {  input=0;  /* can't open it */
	jmp cc49
cc48:
	mov eax,0
	mov [_input],eax
;       pl("Open failure");
	mov eax,cc1+566
	push eax
	call _pl
	pop edx
;       }
cc49:
;     }
	jmp cc44
cc45:
;   kill();    /* erase line */
	call _kill
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Reset line count, etc.    */
; /*      gtf 7/16/80  */
; newfile()
	;;;; section '.text' code
	; FUNCTION: _newfile
_newfile:
; {
	push ebp
	mov ebp,esp
;   lineno  = 0;  /* no lines read */
	mov eax,0
	mov [_lineno],eax
;   fnstart = 0;  /* no fn. start yet. */
	mov eax,0
	mov [_fnstart],eax
;   currfn  = NULL;  /* because no fn. yet */
	mov eax,0
	mov [_currfn],eax
;   infunc  = 0;  /* therefore not in fn. */
	mov eax,0
	mov [_infunc],eax
; /* end newfile */}
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Open an include file    */
; /*          */
; doinclude()
	;;;; section '.text' code
	; FUNCTION: _doinclud
_doinclud:
; {
	push ebp
	mov ebp,esp
;   blanks();  /* skip over to NAME */
	call _blanks
;   toconsole();          /* gtf 7/16/80 */
	call _toconsol
;   outstr("#include "); outstr(line+lptr); nl();
	mov eax,cc1+579
	push eax
	call _outstr
	pop edx
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _outstr
	pop edx
	call _nl
;   tofile();
	call _tofile
;   if(input2)          /* gtf 7/16/80 */
	mov eax,[_input2]
	test eax,eax
	je cc50
;     error("Cannot nest include files");
	mov eax,cc1+589
	push eax
	call _error
	pop edx
;   else if((input2=fopen(line+lptr,"r"))==NULL)
	jmp cc51
cc50:
	mov eax,cc1+615
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _fopen
	add esp,8
	mov [_input2],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc52
;     {input2=0;
	mov eax,0
	mov [_input2],eax
;     error("Open failure on include file");
	mov eax,cc1+617
	push eax
	call _error
	pop edx
;     }
;   else {  saveline = lineno;
	jmp cc53
cc52:
	mov eax,[_lineno]
	mov [_saveline],eax
;     savecurr = currfn;
	mov eax,[_currfn]
	mov [_savecurr],eax
;     saveinfn = infunc;
	mov eax,[_infunc]
	mov [_saveinfn],eax
;     savestart= fnstart;
	mov eax,[_fnstart]
	mov [_savestar],eax
;     newfile();
	call _newfile
;     }
cc53:
cc51:
;   kill();    /* clear rest of line */
	call _kill
;       /* so next read will come from */
;       /* new file (if open */
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Close an include file    */
; /*      gtf 7/16/80  */
; endinclude()
	;;;; section '.text' code
	; FUNCTION: _endinclu
_endinclu:
; {
	push ebp
	mov ebp,esp
;   toconsole();
	call _toconsol
;   outstr("#end include"); nl();
	mov eax,cc1+646
	push eax
	call _outstr
	pop edx
	call _nl
;   tofile();
	call _tofile
;   input2  = 0;
	mov eax,0
	mov [_input2],eax
;   lineno  = saveline;
	mov eax,[_saveline]
	mov [_lineno],eax
;   currfn  = savecurr;
	mov eax,[_savecurr]
	mov [_currfn],eax
;   infunc  = saveinfn;
	mov eax,[_saveinfn]
	mov [_infunc],eax
;   fnstart = savestart;
	mov eax,[_savestar]
	mov [_fnstart],eax
; /* end endinclude */}
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Close the output file    */
; /*          */
; closeout()
	;;;; section '.text' code
	; FUNCTION: _closeout
_closeout:
; {
	push ebp
	mov ebp,esp
;   tofile();  /* if diverted, return to file */
	call _tofile
;   if(output)fclose(output); /* if open, close it */
	mov eax,[_output]
	test eax,eax
	je cc54
	mov eax,[_output]
	push eax
	call _fclose
	pop edx
;   output=0;    /* mark as closed */
cc54:
	mov eax,0
	mov [_output],eax
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Declare a static VARIABLE  */
; /*    (i.e. define for use)    */
; /*          */
; /* makes an entry in the symbol table so subsequent */
; /*  references can call symbol by NAME  */
; declglb(typ)    /* typ is CCHAR or CINT */
	;;;; section '.text' code
	; FUNCTION: _declglb
_declglb:
;   int typ;
	push ebp
	mov ebp,esp
; {  int k,j;char sname[NAMESIZE];
	push edx
	push edx
	sub esp,12
;   while(1)
cc55:
	mov eax,1
	test eax,eax
	je cc56
;     {while(1)
cc57:
	mov eax,1
	test eax,eax
	je cc58
;       {if(endst())return;  /* do line */
	call _endst
	test eax,eax
	je cc59
	mov esp,ebp
	pop ebp
	retn
;       k=1;    /* assume 1 element */
cc59:
	lea eax,[ebp-4]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
;       if(match("*"))  /* POINTER ? */
	mov eax,cc1+659
	push eax
	call _match
	pop edx
	test eax,eax
	je cc60
;         j=POINTER;  /* yes */
	lea eax,[ebp-8]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;         else j=VARIABLE; /* no */
	jmp cc61
cc60:
	lea eax,[ebp-8]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
cc61:
;        if (symname(sname)==0) /* NAME ok? */
	lea eax,[ebp-20]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc62
;         illname(); /* no... */
	call _illname
;       if(findglb(sname)) /* already there? */
cc62:
	lea eax,[ebp-20]
	push eax
	call _findglb
	pop edx
	test eax,eax
	je cc63
;         multidef(sname);
	lea eax,[ebp-20]
	push eax
	call _multidef
	pop edx
;       if (match("["))    /* ARRAY? */
cc63:
	mov eax,cc1+661
	push eax
	call _match
	pop edx
	test eax,eax
	je cc64
;         {k=needsub();  /* get size */
	lea eax,[ebp-4]
	push eax
	call _needsub
	pop edx
	mov [edx],eax
;         if(k)j=ARRAY;  /* !0=ARRAY */
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc65
	lea eax,[ebp-8]
	push eax
	mov eax,2
	pop edx
	mov [edx],eax
;         else j=POINTER; /* 0=ptr */
	jmp cc66
cc65:
	lea eax,[ebp-8]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
cc66:
;         }
;       addglb(sname,j,typ,k); /* add symbol */
cc64:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-20]
	push eax
	call _addglb
	add esp,16
;       break;
	jmp cc58
;       }
	jmp cc57
cc58:
;     if (match(",")==0) return; /* more? */
	mov eax,cc1+663
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc67
	mov esp,ebp
	pop ebp
	retn
;     }
cc67:
	jmp cc55
cc56:
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Declare local VARIABLEs    */
; /*  (i.e. define for use)    */
; /*          */
; /* works just like "decglb" but modifies machine stack */
; /*  and adds symbol table entry with appropriate */
; /*  stack OFFSET to find it again      */
; declloc(typ)    /* typ is CCHAR or CINT */
	;;;; section '.text' code
	; FUNCTION: _declloc
_declloc:
;   int typ;
	push ebp
	mov ebp,esp
;   {
;   int k,j;char sname[NAMESIZE];
	push edx
	push edx
	sub esp,12
;   while(1)
cc68:
	mov eax,1
	test eax,eax
	je cc69
;     {while(1)
cc70:
	mov eax,1
	test eax,eax
	je cc71
;       {if(endst())return;
	call _endst
	test eax,eax
	je cc72
	mov esp,ebp
	pop ebp
	retn
;       if(match("*"))
cc72:
	mov eax,cc1+665
	push eax
	call _match
	pop edx
	test eax,eax
	je cc73
;         j=POINTER;
	lea eax,[ebp-8]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;         else j=VARIABLE;
	jmp cc74
cc73:
	lea eax,[ebp-8]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
cc74:
;       if (symname(sname)==0)
	lea eax,[ebp-20]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc75
;         illname();
	call _illname
;       if(findloc(sname))
cc75:
	lea eax,[ebp-20]
	push eax
	call _findloc
	pop edx
	test eax,eax
	je cc76
;         multidef(sname);
	lea eax,[ebp-20]
	push eax
	call _multidef
	pop edx
;       if (match("["))
cc76:
	mov eax,cc1+667
	push eax
	call _match
	pop edx
	test eax,eax
	je cc77
;         {k=needsub();
	lea eax,[ebp-4]
	push eax
	call _needsub
	pop edx
	mov [edx],eax
;         if(k)
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc78
;           {j=ARRAY;
	lea eax,[ebp-8]
	push eax
	mov eax,2
	pop edx
	mov [edx],eax
;           if(typ==CINT)k=4*k;/*modifyed by E.V.*/
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc79
	lea eax,[ebp-4]
	push eax
	mov eax,4
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	imul edx
	pop edx
	mov [edx],eax
;           }
cc79:
;         else
	jmp cc80
cc78:
;           {j=POINTER;
	lea eax,[ebp-8]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;           k=4;/*modified by E.V.*/
	lea eax,[ebp-4]
	push eax
	mov eax,4
	pop edx
	mov [edx],eax
;           }
cc80:
;         }
;       else
	jmp cc81
cc77:
;         if((typ==CCHAR)
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
;           &(j!=POINTER))
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc82
;           k=1;else k=4;/*modified by E.V.*/
	lea eax,[ebp-4]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
	jmp cc83
cc82:
	lea eax,[ebp-4]
	push eax
	mov eax,4
	pop edx
	mov [edx],eax
cc83:
cc81:
;       if(k&3)k=k+4-(k&3);/*align, by E.V.*/
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,3
	pop edx
	and eax,edx
	test eax,eax
	je cc84
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,3
	pop edx
	and eax,edx
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	mov [edx],eax
;       /* change machine stack */
;       Zsp=modstk(Zsp-k);
cc84:
	mov eax,[_Zsp]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
;       addloc(sname,j,typ,Zsp);
	mov eax,[_Zsp]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-20]
	push eax
	call _addloc
	add esp,16
;       break;
	jmp cc71
;       }
	jmp cc70
cc71:
;     if (match(",")==0) return;
	mov eax,cc1+669
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc85
	mov esp,ebp
	pop ebp
	retn
;     }
cc85:
	jmp cc68
cc69:
;   }
	mov esp,ebp
	pop ebp
	retn
; /*  >>>>>> start of cc2 <<<<<<<<  */
; /*          */
; /*  Get required ARRAY size    */
; /*          */
; /* invoked when declared VARIABLE is followed by "[" */
; /*  this routine makes subscript the absolute */
; /*  size of the ARRAY. */
; needsub()
	;;;; section '.text' code
	; FUNCTION: _needsub
_needsub:
;   {
	push ebp
	mov ebp,esp
;   int num[1];
	push edx
;   if(match("]"))return 0;  /* null size */
	mov eax,cc1+671
	push eax
	call _match
	pop edx
	test eax,eax
	je cc86
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   if (number(num)==0)  /* go after a number */
cc86:
	lea eax,[ebp-4]
	push eax
	call _number
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc87
;     {error("must be constant");  /* it isn't */
	mov eax,cc1+673
	push eax
	call _error
	pop edx
;     num[0]=1;    /* so force one */
	lea eax,[ebp-4]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
;     }
;   if (num[0]<0)
cc87:
	lea eax,[ebp-4]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc88
;     {error("negative size illegal");
	mov eax,cc1+690
	push eax
	call _error
	pop edx
;     num[0]=(-num[0]);
	lea eax,[ebp-4]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	neg eax
	pop edx
	mov [edx],eax
;     }
;   needbrack("]");    /* force single dimension */
cc88:
	mov eax,cc1+712
	push eax
	call _needbrac
	pop edx
;   return num[0];    /* and return size */
	lea eax,[ebp-4]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   }
	mov esp,ebp
	pop ebp
	retn
; newstruct() {
	;;;; section '.text' code
	; FUNCTION: _newstruc
_newstruc:
	push ebp
	mov ebp,esp
;   char n[NAMESIZE];  /* ptr => currfn,  gtf 7/16/80 */
	sub esp,12
;   char m[NAMESIZE];  /* ptr => currfn,  gtf 7/16/80 */
	sub esp,12
;   int  tidx;
	push edx
;   if (symname(n)==0) {
	lea eax,[ebp-12]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc89
;     error("illegal STRUCT or declaration");
	mov eax,cc1+714
	push eax
	call _error
	pop edx
;     kill();  /* invalidate line */
	call _kill
;     return;
	mov esp,ebp
	pop ebp
	retn
;   }
;   fnstart=lineno;    /* remember where fn began  gtf 7/2/80 */
cc89:
	mov eax,[_lineno]
	mov [_fnstart],eax
;   infunc=1;    /* note, in FUNCTION now.  gtf 7/16/80 */
	mov eax,1
	mov [_infunc],eax
;   /* already in symbol table ? */
;   if(currfn=findglb(n))  {
	lea eax,[ebp-12]
	push eax
	call _findglb
	pop edx
	mov [_currfn],eax
	test eax,eax
	je cc90
;     /* Declaration ?? */
;     if( match("{")  == 0 ) {
	mov eax,cc1+744
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc91
;       symname(m);
	lea eax,[ebp-24]
	push eax
	call _symname
	pop edx
;       addglb(m, CSTRUCT, CINT, STRUCT );
	mov eax,5
	push eax
	mov eax,2
	push eax
	mov eax,3
	push eax
	lea eax,[ebp-24]
	push eax
	call _addglb
	add esp,16
;       nl();
	call _nl
;       return;
	mov esp,ebp
	pop ebp
	retn
;     }
;     
;     if(currfn[IDENT]!=FUNCTION)multidef(n);
cc91:
	mov eax,[_currfn]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc92
	lea eax,[ebp-12]
	push eax
	call _multidef
	pop edx
;       /* already VARIABLE by that NAME */
;     else if(currfn[OFFSET]==FUNCTION)multidef(n);
	jmp cc93
cc92:
	mov eax,[_currfn]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc94
	lea eax,[ebp-12]
	push eax
	call _multidef
	pop edx
;       /* already FUNCTION by that NAME */
;     else currfn[OFFSET]=FUNCTION;
	jmp cc95
cc94:
	mov eax,[_currfn]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	push eax
	mov eax,4
	pop edx
	mov [edx],al
cc95:
cc93:
;       /* otherwise we have what was earlier*/
;       /*  assumed to be a FUNCTION */
;   } else {
	jmp cc96
cc90:
;     /* if not in table, define as a FUNCTION now */
;     currfn=addglb(n,STRUCT,CINT,STRUCT);
	mov eax,5
	push eax
	mov eax,2
	push eax
	mov eax,5
	push eax
	lea eax,[ebp-12]
	push eax
	call _addglb
	add esp,16
	mov [_currfn],eax
;   }
cc96:
;   toconsole();          /* gtf 7/16/80 */
	call _toconsol
;   /*outstr("====== "); outstr(currfn+NAME); outstr("()"); nl();*/
;   tofile();
	call _tofile
;   /* we had better see open paren for args... */
;   if(match("{")==0)error("missing open { ");
	mov eax,cc1+746
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc97
	mov eax,cc1+748
	push eax
	call _error
	pop edx
;   ol(";;;; section '.text' code");
cc97:
	mov eax,cc1+764
	push eax
	call _ol
	pop edx
;   ot("; OBJECT: ");outname(n);nl();
	mov eax,cc1+790
	push eax
	call _ot
	pop edx
	lea eax,[ebp-12]
	push eax
	call _outname
	pop edx
	call _nl
;   outname(n);col();nl();  /* print FUNCTION NAME */
	lea eax,[ebp-12]
	push eax
	call _outname
	pop edx
	call _col
	call _nl
;   argstk=0;    /* init arg count */
	mov eax,0
	mov [_argstk],eax
;   locptr=STARTLOC;  /* "clear" local symbol table*/
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   Zsp=0;      /* preset stack ptr */
	mov eax,0
	mov [_Zsp],eax
;  
;   /* Parse twice, once for arg count so second pass we can pass proper 
;      stack offsets in emitted asm code - SA */ 
;   tidx=lptr;
	lea eax,[ebp-28]
	push eax
	mov eax,[_lptr]
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   
;   /* Assume K&R style  - SA */
;   kandr = 1;
	mov eax,1
	mov [_kandr],eax
;   /* Record stack depth based on # of parameters */
;   argtop = argstk;
	mov eax,[_argstk]
	mov [_argtop],eax
;   /* Refill buffer */
;   blanks();
	call _blanks
;   /* "clear" local symbol table*/ 
;   locptr=STARTLOC; 
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   Zsp=0;      /* preset stack ptr */
	mov eax,0
	mov [_Zsp],eax
;   argtop=argstk;
	mov eax,[_argstk]
	mov [_argtop],eax
;   while( match("}") == 0 )  {
cc98:
	mov eax,cc1+801
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc99
;     /* now let user declare what TYPEs of things */
;     field_of = field_of+4;
	mov eax,[_field_of]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	mov [_field_of],eax
;     argstk = argstk+4;
	mov eax,[_argstk]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	mov [_argstk],eax
;     if(amatch("char",4)){getfield(CCHAR, currfn, field_of);ns();}
	mov eax,4
	push eax
	mov eax,cc1+803
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc100
	mov eax,[_field_of]
	push eax
	mov eax,[_currfn]
	push eax
	mov eax,1
	push eax
	call _getfield
	add esp,12
	call _ns
;     else if(amatch("int",3)){getfield(CINT, currfn, field_of);ns();}
	jmp cc101
cc100:
	mov eax,3
	push eax
	mov eax,cc1+808
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc102
	mov eax,[_field_of]
	push eax
	mov eax,[_currfn]
	push eax
	mov eax,2
	push eax
	call _getfield
	add esp,12
	call _ns
;     else{error("wrong number args");break;}
	jmp cc103
cc102:
	mov eax,cc1+812
	push eax
	call _error
	pop edx
	jmp cc99
cc103:
cc101:
;   }
	jmp cc98
cc99:
;   ns();
	call _ns
;   ol("push ebp");
	mov eax,cc1+830
	push eax
	call _ol
	pop edx
;   ol("mov ebp,esp");
	mov eax,cc1+839
	push eax
	call _ol
	pop edx
;   Zsp=0;      /* reset stack ptr again */
	mov eax,0
	mov [_Zsp],eax
;   locptr=STARTLOC;  /* deallocate all locals */
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   infunc=0;    /* not in fn. any more    gtf 7/2/80 */
	mov eax,0
	mov [_infunc],eax
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Begin a FUNCTION    */
; /*          */
; /* Called from "parse" this routine tries to make a FUNCTION */
; /*  out of what follows.  */
; newfunc() {
	;;;; section '.text' code
	; FUNCTION: _newfunc
_newfunc:
	push ebp
	mov ebp,esp
;   char n[NAMESIZE];  /* ptr => currfn,  gtf 7/16/80 */
	sub esp,12
;   int  tidx;
	push edx
;   if (symname(n)==0) {
	lea eax,[ebp-12]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc104
;     error("illegal FUNCTION or declaration");
	mov eax,cc1+851
	push eax
	call _error
	pop edx
;     kill();  /* invalidate line */
	call _kill
;     return;
	mov esp,ebp
	pop ebp
	retn
;   }
;   fnstart=lineno;    /* remember where fn began  gtf 7/2/80 */
cc104:
	mov eax,[_lineno]
	mov [_fnstart],eax
;   infunc=1;    /* note, in FUNCTION now.  gtf 7/16/80 */
	mov eax,1
	mov [_infunc],eax
;   /* already in symbol table ? */
;   if(currfn=findglb(n))  {
	lea eax,[ebp-12]
	push eax
	call _findglb
	pop edx
	mov [_currfn],eax
	test eax,eax
	je cc105
;     if(currfn[IDENT]!=FUNCTION)multidef(n);
	mov eax,[_currfn]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc106
	lea eax,[ebp-12]
	push eax
	call _multidef
	pop edx
;       /* already VARIABLE by that NAME */
;     else if(currfn[OFFSET]==FUNCTION)multidef(n);
	jmp cc107
cc106:
	mov eax,[_currfn]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc108
	lea eax,[ebp-12]
	push eax
	call _multidef
	pop edx
;       /* already FUNCTION by that NAME */
;     else currfn[OFFSET]=FUNCTION;
	jmp cc109
cc108:
	mov eax,[_currfn]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	push eax
	mov eax,4
	pop edx
	mov [edx],al
cc109:
cc107:
;       /* otherwise we have what was earlier*/
;       /*  assumed to be a FUNCTION */
;   } else {
	jmp cc110
cc105:
;     /* if not in table, define as a FUNCTION now */
;     currfn=addglb(n,FUNCTION,CINT,FUNCTION);
	mov eax,4
	push eax
	mov eax,2
	push eax
	mov eax,4
	push eax
	lea eax,[ebp-12]
	push eax
	call _addglb
	add esp,16
	mov [_currfn],eax
;   }
cc110:
;   toconsole();          /* gtf 7/16/80 */
	call _toconsol
;   /*outstr("====== "); outstr(currfn+NAME); outstr("()"); nl();*/
;   tofile();
	call _tofile
;   /* we had better see open paren for args... */
;   if(match("(")==0)error("missing open paren");
	mov eax,cc1+883
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc111
	mov eax,cc1+885
	push eax
	call _error
	pop edx
;   ol(";;;; section '.text' code");
cc111:
	mov eax,cc1+904
	push eax
	call _ol
	pop edx
;   ot("; FUNCTION: ");outname(n);nl();
	mov eax,cc1+930
	push eax
	call _ot
	pop edx
	lea eax,[ebp-12]
	push eax
	call _outname
	pop edx
	call _nl
;   outname(n);col();nl();  /* print FUNCTION NAME */
	lea eax,[ebp-12]
	push eax
	call _outname
	pop edx
	call _col
	call _nl
;   argstk=0;    /* init arg count */
	mov eax,0
	mov [_argstk],eax
;   locptr=STARTLOC;  /* "clear" local symbol table*/
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   Zsp=0;      /* preset stack ptr */
	mov eax,0
	mov [_Zsp],eax
;  
;   /* Parse twice, once for arg count so second pass we can pass proper 
;      stack offsets in emitted asm code - SA */ 
;   tidx=lptr;
	lea eax,[ebp-16]
	push eax
	mov eax,[_lptr]
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   
;   /* Assume K&R style  - SA */
;   kandr = 1;
	mov eax,1
	mov [_kandr],eax
;   while( match(")" ) == 0 ) {
cc112:
	mov eax,cc1+943
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc113
;     /* Found a type? we now treat this function as a non K&R style */
;     if( match("int",3) ) { kandr = 0; }
	mov eax,3
	push eax
	mov eax,cc1+945
	push eax
	call _match
	add esp,8
	test eax,eax
	je cc114
	mov eax,0
	mov [_kandr],eax
;     else if( match("char", 4) ) { kandr = 0; }
	jmp cc115
cc114:
	mov eax,4
	push eax
	mov eax,cc1+949
	push eax
	call _match
	add esp,8
	test eax,eax
	je cc116
	mov eax,0
	mov [_kandr],eax
;     if( streq(line+lptr, ",") ) {
cc116:
cc115:
	mov eax,cc1+954
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	test eax,eax
	je cc117
;       /* Still our goal is to find the number of arguments  */
;       argstk = argstk + 4;
	mov eax,[_argstk]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	mov [_argstk],eax
;     }
;     lptr++;
cc117:
	mov eax,[_lptr]
	inc eax
	mov [_lptr],eax
	dec eax
;     if( argstk == 0 ) argstk = argstk + 4;
	mov eax,[_argstk]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc118
	mov eax,[_argstk]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	mov [_argstk],eax
;   }
cc118:
	jmp cc112
cc113:
;   /* Record stack depth based on # of parameters */
;   argtop = argstk;
	mov eax,[_argstk]
	mov [_argtop],eax
;   /* If we are not K&R re-parse the params, we needed an arg count for this 
;      parse code to work however so we are doing it twice */
;   if( !kandr ) {
	mov eax,[_kandr]
	test eax,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc119
;       /* Reset lptr so we can reparse - SA */
;       lptr=tidx;  
	lea eax,[ebp-16]
	mov eax,[eax]
	mov [_lptr],eax
;       while(match(")")==0) {
cc120:
	mov eax,cc1+956
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc121
;         if( amatch("int",3) ) {
	mov eax,3
	push eax
	mov eax,cc1+958
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc122
;           getarg(CINT);
	mov eax,2
	push eax
	call _getarg
	pop edx
;         } else if( amatch("char", 4) ) {
	jmp cc123
cc122:
	mov eax,4
	push eax
	mov eax,cc1+962
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc124
;           getarg(CINT);
	mov eax,2
	push eax
	call _getarg
	pop edx
;         } else if(streq(line+lptr,")")==0) {
	jmp cc125
cc124:
	mov eax,cc1+967
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc126
;           if(match(",")==0) { 
	mov eax,cc1+969
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc127
;             error("expected comma");
	mov eax,cc1+971
	push eax
	call _error
	pop edx
;             break;
	jmp cc121
;           }
;         }
cc127:
;       }
cc126:
cc125:
cc123:
	jmp cc120
cc121:
;   } else {
	jmp cc128
cc119:
;       /* Refill buffer */
;       blanks();
	call _blanks
;       /* We are K&R - parse arg name and types after the ) and before the { */
;       locptr=STARTLOC;  /* "clear" local symbol table*/ 
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;       Zsp=0;      /* preset stack ptr */
	mov eax,0
	mov [_Zsp],eax
;       argtop=argstk;
	mov eax,[_argstk]
	mov [_argtop],eax
;       while(argstk)  {
cc129:
	mov eax,[_argstk]
	test eax,eax
	je cc130
;         /* now let user declare what TYPEs of things */
;         /*  those arguments were */
;         if(amatch("char",4)){getarg(CCHAR);ns();}
	mov eax,4
	push eax
	mov eax,cc1+986
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc131
	mov eax,1
	push eax
	call _getarg
	pop edx
	call _ns
;         else if(amatch("int",3)){getarg(CINT);ns();}
	jmp cc132
cc131:
	mov eax,3
	push eax
	mov eax,cc1+991
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc133
	mov eax,2
	push eax
	call _getarg
	pop edx
	call _ns
;         else{error("wrong number args");break;}
	jmp cc134
cc133:
	mov eax,cc1+995
	push eax
	call _error
	pop edx
	jmp cc130
cc134:
cc132:
;       }
	jmp cc129
cc130:
;   }
cc128:
;   ol("push ebp");
	mov eax,cc1+1013
	push eax
	call _ol
	pop edx
;   ol("mov ebp,esp");
	mov eax,cc1+1022
	push eax
	call _ol
	pop edx
;   if(statement()!=STRETURN) /* do a statement, but if */
	call _statemen
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc135
;     ;
;         /* it's a return, skip */
;         /* cleaning up the stack */
;   {/*modstk(0);*/
cc135:
;     ol("mov esp,ebp");
	mov eax,cc1+1034
	push eax
	call _ol
	pop edx
;     ol("pop ebp");
	mov eax,cc1+1046
	push eax
	call _ol
	pop edx
;     zret();
	call _zret
;     }
;   Zsp=0;      /* reset stack ptr again */
	mov eax,0
	mov [_Zsp],eax
;   locptr=STARTLOC;  /* deallocate all locals */
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   infunc=0;    /* not in fn. any more    gtf 7/2/80 */
	mov eax,0
	mov [_infunc],eax
;   }
	mov esp,ebp
	pop ebp
	retn
; /* T=Type, sidx=Struct pointer, Offset = offset in struct */
; getfield(t,sidx, offst) int t,sidx,offst;
	;;;; section '.text' code
	; FUNCTION: _getfield
_getfield:
	push ebp
	mov ebp,esp
; {
;   char n[NAMESIZE], c; int j;
	sub esp,12
	push edx
	push edx
;   if(match("*"))j=POINTER;
	mov eax,cc1+1054
	push eax
	call _match
	pop edx
	test eax,eax
	je cc136
	lea eax,[ebp-20]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;   else j=VARIABLE;
	jmp cc137
cc136:
	lea eax,[ebp-20]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
cc137:
;   if(symname(n)==0) illname();
	lea eax,[ebp-12]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc138
	call _illname
;   if(findloc(n))multidef(n);
cc138:
	lea eax,[ebp-12]
	push eax
	call _findloc
	pop edx
	test eax,eax
	je cc139
	lea eax,[ebp-12]
	push eax
	call _multidef
	pop edx
;   if(match("["))  {
cc139:
	mov eax,cc1+1056
	push eax
	call _match
	pop edx
	test eax,eax
	je cc140
;     /* Skip stuff between [ ] */
;     while(inbyte()!=']')  {
cc141:
	call _inbyte
	push eax
	mov eax,93
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc142
;       if(endst())break;
	call _endst
	test eax,eax
	je cc143
	jmp cc142
;     }
cc143:
	jmp cc141
cc142:
;     j=POINTER;
	lea eax,[ebp-20]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;     /* add entry as POINTER */
;   }
;   addloc(n,j,t,8+argtop-argstk);
cc140:
	mov eax,8
	push eax
	mov eax,[_argtop]
	pop edx
	add eax,edx
	push eax
	mov eax,[_argstk]
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-20]
	mov eax,[eax]
	push eax
	lea eax,[ebp-12]
	push eax
	call _addloc
	add esp,16
;   if(endst())return;
	call _endst
	test eax,eax
	je cc144
	mov esp,ebp
	pop ebp
	retn
; }
cc144:
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Declare argument TYPEs    */
; /*          */
; /* called from "newfunc" this routine adds an entry in the */
; /*  local symbol table for each NAMEd argument */
; getarg(t)    /* t = CCHAR or CINT */
	;;;; section '.text' code
	; FUNCTION: _getarg
_getarg:
;   int t;
	push ebp
	mov ebp,esp
;   {
;   char n[NAMESIZE],c;int j;
	sub esp,12
	push edx
	push edx
;   while(1)
cc145:
	mov eax,1
	test eax,eax
	je cc146
;     {if(argstk==0)return;  /* no more args */
	mov eax,[_argstk]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc147
	mov esp,ebp
	pop ebp
	retn
;     if(match("*"))j=POINTER;
cc147:
	mov eax,cc1+1058
	push eax
	call _match
	pop edx
	test eax,eax
	je cc148
	lea eax,[ebp-20]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;       else j=VARIABLE;
	jmp cc149
cc148:
	lea eax,[ebp-20]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
cc149:
;     if(symname(n)==0) illname();
	lea eax,[ebp-12]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc150
	call _illname
;     if(findloc(n))multidef(n);
cc150:
	lea eax,[ebp-12]
	push eax
	call _findloc
	pop edx
	test eax,eax
	je cc151
	lea eax,[ebp-12]
	push eax
	call _multidef
	pop edx
;     if(match("["))  /* POINTER ? */
cc151:
	mov eax,cc1+1060
	push eax
	call _match
	pop edx
	test eax,eax
	je cc152
;     /* it is a POINTER, so skip all */
;     /* stuff between "[]" */
;       {while(inbyte()!=']')
cc153:
	call _inbyte
	push eax
	mov eax,93
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc154
;         if(endst())break;
	call _endst
	test eax,eax
	je cc155
	jmp cc154
;       j=POINTER;
cc155:
	jmp cc153
cc154:
	lea eax,[ebp-20]
	push eax
	mov eax,3
	pop edx
	mov [edx],eax
;       /* add entry as POINTER */
;       }
;     addloc(n,j,t,8+argtop-argstk);
cc152:
	mov eax,8
	push eax
	mov eax,[_argtop]
	pop edx
	add eax,edx
	push eax
	mov eax,[_argstk]
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-20]
	mov eax,[eax]
	push eax
	lea eax,[ebp-12]
	push eax
	call _addloc
	add esp,16
;     argstk=argstk-4;  /* cnt down *//*modified by E.V.*/
	mov eax,[_argstk]
	push eax
	mov eax,4
	pop edx
	sub edx,eax
	mov eax,edx
	mov [_argstk],eax
;     /* K&R handling conditionally - SA */
;     if( kandr ) {
	mov eax,[_kandr]
	test eax,eax
	je cc156
;       if(endst())return;
	call _endst
	test eax,eax
	je cc157
	mov esp,ebp
	pop ebp
	retn
;       if(match(",")==0)error("expected comma"); 
cc157:
	mov eax,cc1+1062
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc158
	mov eax,cc1+1064
	push eax
	call _error
	pop edx
;     } else {
cc158:
	jmp cc159
cc156:
;       return;
	mov esp,ebp
	pop ebp
	retn
;     }
cc159:
;     }
	jmp cc145
cc146:
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Statement parser    */
; /*          */
; /* called whenever syntax requires  */
; /*  a statement.        */
; /*  this routine performs that statement */
; /*  and returns a number telling which one */
; statement()
	;;;; section '.text' code
	; FUNCTION: _statemen
_statemen:
; {
	push ebp
	mov ebp,esp
;         /* NOTE (RDK) --- On DOS there is no CPM FUNCTION so just try */
;         /* commenting it out for the first test compilation to see if */
;         /* the compiler basic framework works OK in the DOS environment */
;   /* if(cpm(11,0) & 1)  /* check for ctrl-C gtf 7/17/80 */
;     /* if(getchar()==3) */
;       /* zabort(); */
;   if ((ch()==0) & (eof)) return;
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	mov eax,[_eof]
	pop edx
	and eax,edx
	test eax,eax
	je cc160
	mov esp,ebp
	pop ebp
	retn
;   else if(amatch("char",4))
	jmp cc161
cc160:
	mov eax,4
	push eax
	mov eax,cc1+1079
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc162
;     {declloc(CCHAR);ns();}
	mov eax,1
	push eax
	call _declloc
	pop edx
	call _ns
;   else if(amatch("int",3))
	jmp cc163
cc162:
	mov eax,3
	push eax
	mov eax,cc1+1084
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc164
;     {declloc(CINT);ns();}
	mov eax,2
	push eax
	call _declloc
	pop edx
	call _ns
;   else if(amatch("struct",6))
	jmp cc165
cc164:
	mov eax,6
	push eax
	mov eax,cc1+1088
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc166
;     {newstruct();}
	call _newstruc
;   else if(match("{"))compound();
	jmp cc167
cc166:
	mov eax,cc1+1095
	push eax
	call _match
	pop edx
	test eax,eax
	je cc168
	call _compound
;   else if(amatch("if",2))
	jmp cc169
cc168:
	mov eax,2
	push eax
	mov eax,cc1+1097
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc170
;     {doif();lastst=STIF;}
	call _doif
	mov eax,1
	mov [_lastst],eax
;   else if(amatch("while",5))
	jmp cc171
cc170:
	mov eax,5
	push eax
	mov eax,cc1+1100
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc172
;     {dowhile();lastst=STWHILE;}
	call _dowhile
	mov eax,2
	mov [_lastst],eax
;   else if(amatch("for",3))
	jmp cc173
cc172:
	mov eax,3
	push eax
	mov eax,cc1+1106
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc174
;     {dofor();lastst=STFOR;}
	call _dofor
	mov eax,9
	mov [_lastst],eax
;   else if(amatch("do", 2))
	jmp cc175
cc174:
	mov eax,2
	push eax
	mov eax,cc1+1110
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc176
;     {dodo();lastst=STDO;}
	call _dodo
	mov eax,10
	mov [_lastst],eax
;   else if(amatch("return",6))
	jmp cc177
cc176:
	mov eax,6
	push eax
	mov eax,cc1+1113
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc178
;     {doreturn();ns();lastst=STRETURN;}
	call _doreturn
	call _ns
	mov eax,3
	mov [_lastst],eax
;   else if(amatch("break",5))
	jmp cc179
cc178:
	mov eax,5
	push eax
	mov eax,cc1+1120
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc180
;     {dobreak();ns();lastst=STBREAK;}
	call _dobreak
	call _ns
	mov eax,4
	mov [_lastst],eax
;   else if(amatch("continue",8))
	jmp cc181
cc180:
	mov eax,8
	push eax
	mov eax,cc1+1126
	push eax
	call _amatch
	add esp,8
	test eax,eax
	je cc182
;     {docont();ns();lastst=STCONT;}
	call _docont
	call _ns
	mov eax,5
	mov [_lastst],eax
;   else if(match(";"));
	jmp cc183
cc182:
	mov eax,cc1+1135
	push eax
	call _match
	pop edx
	test eax,eax
	je cc184
;   else if(match("#asm"))
	jmp cc185
cc184:
	mov eax,cc1+1137
	push eax
	call _match
	pop edx
	test eax,eax
	je cc186
;     {doasm();lastst=STASM;}
	call _doasm
	mov eax,6
	mov [_lastst],eax
;   /* if nothing else, assume it's an expression */
;   else{expression();ns();lastst=STEXP;}
	jmp cc187
cc186:
	call _expressi
	call _ns
	mov eax,7
	mov [_lastst],eax
cc187:
cc185:
cc183:
cc181:
cc179:
cc177:
cc175:
cc173:
cc171:
cc169:
cc167:
cc165:
cc163:
cc161:
;   return lastst;
	mov eax,[_lastst]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Semicolon enforcer    */
; /*          */
; /* called whenever syntax requires a semicolon */
; ns()  {if(match(";")==0)error("missing semicolon");}
	;;;; section '.text' code
	; FUNCTION: _ns
_ns:
	push ebp
	mov ebp,esp
	mov eax,cc1+1142
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc188
	mov eax,cc1+1144
	push eax
	call _error
	pop edx
cc188:
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  Compound statement    */
; /*          */
; /* allow any number of statements to fall between "{}" */
; compound()
	;;;; section '.text' code
	; FUNCTION: _compound
_compound:
;   {
	push ebp
	mov ebp,esp
;   ++ncmp;    /* new level open */
	mov eax,[_ncmp]
	inc eax
	mov [_ncmp],eax
;   while (match("}")==0) statement(); /* do one */
cc189:
	mov eax,cc1+1162
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc190
	call _statemen
	jmp cc189
cc190:
;   --ncmp;    /* close current level */
	mov eax,[_ncmp]
	dec eax
	mov [_ncmp],eax
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*    "if" statement    */
; /*          */
; doif()
	;;;; section '.text' code
	; FUNCTION: _doif
_doif:
;   {
	push ebp
	mov ebp,esp
;   int flev,fsp,flab1,flab2;
	push edx
	push edx
	push edx
	push edx
;   flev=locptr;  /* record current local level */
	lea eax,[ebp-4]
	push eax
	mov eax,[_locptr]
	pop edx
	mov [edx],eax
;   fsp=Zsp;    /* record current stk ptr */
	lea eax,[ebp-8]
	push eax
	mov eax,[_Zsp]
	pop edx
	mov [edx],eax
;   flab1=getlabel(); /* get label for false branch */
	lea eax,[ebp-12]
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   test(flab1);  /* get expression, and branch false */
	lea eax,[ebp-12]
	mov eax,[eax]
	push eax
	call _test
	pop edx
;   statement();  /* if true, do a statement */
	call _statemen
;   Zsp=modstk(fsp);  /* then clean up the stack */
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
;   locptr=flev;  /* and deallocate any locals */
	lea eax,[ebp-4]
	mov eax,[eax]
	mov [_locptr],eax
;   if (amatch("else",4)==0)  /* if...else ? */
	mov eax,4
	push eax
	mov eax,cc1+1164
	push eax
	call _amatch
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc191
;     /* simple "if"...print false label */
;     {printlabel(flab1);col();nl();
	lea eax,[ebp-12]
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;     return;    /* and exit */
	mov esp,ebp
	pop ebp
	retn
;     }
;   /* an "if...else" statement. */
;   jump(flab2=getlabel());  /* jump around false code */
cc191:
	lea eax,[ebp-16]
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
	push eax
	call _jump
	pop edx
;   printlabel(flab1);col();nl();  /* print false label */
	lea eax,[ebp-12]
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   statement();    /* and do "else" clause */
	call _statemen
;   Zsp=modstk(fsp);    /* then clean up stk ptr */
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
;   locptr=flev;    /* and deallocate locals */
	lea eax,[ebp-4]
	mov eax,[eax]
	mov [_locptr],eax
;   printlabel(flab2);col();nl();  /* print true label */
	lea eax,[ebp-16]
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  "while" statement    */
; /*          */
; dowhile()
	;;;; section '.text' code
	; FUNCTION: _dowhile
_dowhile:
;   {
	push ebp
	mov ebp,esp
;   int wq[4];    /* allocate local queue */
	sub esp,16
;   wq[WQSYM]=locptr;  /* record local level */
	lea eax,[ebp-16]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_locptr]
	pop edx
	mov [edx],eax
;   wq[WQSP]=Zsp;    /* and stk ptr */
	lea eax,[ebp-16]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_Zsp]
	pop edx
	mov [edx],eax
;   wq[WQLOOP]=getlabel();  /* and looping label */
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   wq[WQLAB]=getlabel();  /* and exit label */
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   addwhile(wq);    /* add entry to queue */
	lea eax,[ebp-16]
	push eax
	call _addwhile
	pop edx
;         /* (for "break" statement) */
;   printlabel(wq[WQLOOP]);col();nl(); /* loop label */
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   test(wq[WQLAB]);  /* see if true */
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _test
	pop edx
;   statement();    /* if so, do a statement */
	call _statemen
;   Zsp = modstk(wq[WQSP]);  /* zap local vars: 9/25/80 gtf */
	lea eax,[ebp-16]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
;   jump(wq[WQLOOP]);  /* loop to label */
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _jump
	pop edx
;   printlabel(wq[WQLAB]);col();nl(); /* exit label */
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   locptr=wq[WQSYM];  /* deallocate locals */
	lea eax,[ebp-16]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_locptr],eax
;   delwhile();    /* delete queue entry */
	call _delwhile
;   }
	mov esp,ebp
	pop ebp
	retn
; dodo()
	;;;; section '.text' code
	; FUNCTION: _dodo
_dodo:
; {
	push ebp
	mov ebp,esp
;   int wq[4];
	sub esp,16
;   wq[WQSYM]=locptr;
	lea eax,[ebp-16]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_locptr]
	pop edx
	mov [edx],eax
;   wq[WQSP]=Zsp;
	lea eax,[ebp-16]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_Zsp]
	pop edx
	mov [edx],eax
;   wq[WQLOOP]=getlabel();
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   wq[WQLAB]=getlabel();
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   addwhile(wq);
	lea eax,[ebp-16]
	push eax
	call _addwhile
	pop edx
;   printlabel(wq[WQLOOP]);col();nl();
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   statement();
	call _statemen
;   Zsp = modstk(wq[WQSP]);
	lea eax,[ebp-16]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
;   if(amatch("while",5)==0)
	mov eax,5
	push eax
	mov eax,cc1+1169
	push eax
	call _amatch
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc192
;   {error("'while' needed");}
	mov eax,cc1+1175
	push eax
	call _error
	pop edx
;   needbrack("(");
cc192:
	mov eax,cc1+1190
	push eax
	call _needbrac
	pop edx
;   expression();
	call _expressi
;   ol("test eax,eax");
	mov eax,cc1+1192
	push eax
	call _ol
	pop edx
;   ot("jne ");
	mov eax,cc1+1205
	push eax
	call _ot
	pop edx
;   printlabel(wq[WQLOOP]);nl();
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _nl
;   printlabel(wq[WQLAB]);col();nl();
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   
;   needbrack(")");
	mov eax,cc1+1210
	push eax
	call _needbrac
	pop edx
;   ns();
	call _ns
;   locptr=wq[WQSYM];
	lea eax,[ebp-16]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_locptr],eax
;   delwhile();
	call _delwhile
; }
	mov esp,ebp
	pop ebp
	retn
; dofor()
	;;;; section '.text' code
	; FUNCTION: _dofor
_dofor:
; {
	push ebp
	mov ebp,esp
;   int wq[4];
	sub esp,16
;   int bl;
	push edx
;   int tl,tl1;
	push edx
	push edx
;   bl=getlabel();
	lea eax,[ebp-20]
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   wq[WQSYM]=locptr;
	lea eax,[ebp-16]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_locptr]
	pop edx
	mov [edx],eax
;   wq[WQSP]=Zsp;
	lea eax,[ebp-16]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_Zsp]
	pop edx
	mov [edx],eax
;   wq[WQLOOP]=getlabel();
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   wq[WQLAB]=getlabel();
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	push eax
	call _getlabel
	pop edx
	mov [edx],eax
;   addwhile(wq);
	lea eax,[ebp-16]
	push eax
	call _addwhile
	pop edx
;   
;   needbrack("(");
	mov eax,cc1+1212
	push eax
	call _needbrac
	pop edx
;   expression();/*i=0*/
	call _expressi
;   ns();
	call _ns
;   printlabel(wq[WQLOOP]);col();nl();
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   expression();/*i<N*/
	call _expressi
;   testjump(wq[WQLAB]);
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _testjump
	pop edx
;   ns();
	call _ns
;   tl=getlitstk();
	lea eax,[ebp-24]
	push eax
	call _getlitst
	pop edx
	mov [edx],eax
;   expression();/*i++*/
	call _expressi
;   getlitstk();
	call _getlitst
;   needbrack(")");
	mov eax,cc1+1214
	push eax
	call _needbrac
	pop edx
;   statement();
	call _statemen
;   Zsp = modstk(wq[WQSP]);  /* zap local vars: 9/25/80 gtf */
	lea eax,[ebp-16]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
;   printf("dumpltstk...\n");
	mov eax,cc1+1216
	push eax
	call _printf
	pop edx
;   /*dumpltstk(tl1);*/
;   dumpltstk(tl);
	lea eax,[ebp-24]
	mov eax,[eax]
	push eax
	call _dumpltst
	pop edx
;   jump(wq[WQLOOP]);  /* loop to label */
	lea eax,[ebp-16]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _jump
	pop edx
;   printlabel(wq[WQLAB]);col();nl(); /* exit label */
	lea eax,[ebp-16]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
	call _col
	call _nl
;   locptr=wq[WQSYM];  /* deallocate locals */
	lea eax,[ebp-16]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_locptr],eax
;   delwhile();    /* delete queue entry */
	call _delwhile
; }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  "return" statement    */
; /*          */
; doreturn()
	;;;; section '.text' code
	; FUNCTION: _doreturn
_doreturn:
;   {
	push ebp
	mov ebp,esp
;   /* if not end of statement, get an expression */
;   if(endst()==0)expression();
	call _endst
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc193
	call _expressi
;   /*modstk(0);*/  /* clean up stk */
;   ol("mov esp,ebp");
cc193:
	mov eax,cc1+1230
	push eax
	call _ol
	pop edx
;   ol("pop ebp");
	mov eax,cc1+1242
	push eax
	call _ol
	pop edx
;   zret();    /* and exit FUNCTION */
	call _zret
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  "break" statement    */
; /*          */
; dobreak()
	;;;; section '.text' code
	; FUNCTION: _dobreak
_dobreak:
;   {
	push ebp
	mov ebp,esp
;   int *ptr;
	push edx
;   /* see if any "whiles" are open */
;   if ((ptr=readwhile())==0) return;  /* no */
	lea eax,[ebp-4]
	push eax
	call _readwhil
	pop edx
	mov [edx],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc194
	mov esp,ebp
	pop ebp
	retn
;   modstk((ptr[WQSP]));  /* else clean up stk ptr */
cc194:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
;   jump(ptr[WQLAB]);  /* jump to exit label */
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,3
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _jump
	pop edx
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  "continue" statement    */
; /*          */
; docont()
	;;;; section '.text' code
	; FUNCTION: _docont
_docont:
;   {
	push ebp
	mov ebp,esp
;   int *ptr;
	push edx
;   /* see if any "whiles" are open */
;   if ((ptr=readwhile())==0) return;  /* no */
	lea eax,[ebp-4]
	push eax
	call _readwhil
	pop edx
	mov [edx],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc195
	mov esp,ebp
	pop ebp
	retn
;   modstk((ptr[WQSP]));  /* else clean up stk ptr */
cc195:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _modstk
	pop edx
;   jump(ptr[WQLOOP]);  /* jump to loop label */
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,2
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _jump
	pop edx
;   }
	mov esp,ebp
	pop ebp
	retn
; /*          */
; /*  "asm" pseudo-statement    */
; /*          */
; /* enters mode where assembly language statement are */
; /*  passed intact through parser  */
; doasm()
	;;;; section '.text' code
	; FUNCTION: _doasm
_doasm:
;   {
	push ebp
	mov ebp,esp
;   cmode=0;    /* mark mode as "asm" */
	mov eax,0
	mov [_cmode],eax
;   while (1)
cc196:
	mov eax,1
	test eax,eax
	je cc197
;     {insline();  /* get and print lines */
	call _insline
;     if (match("#endasm")) break;  /* until... */
	mov eax,cc1+1250
	push eax
	call _match
	pop edx
	test eax,eax
	je cc198
	jmp cc197
;     if(eof)break;
cc198:
	mov eax,[_eof]
	test eax,eax
	je cc199
	jmp cc197
;     outstr(line);
cc199:
	mov eax,_line
	push eax
	call _outstr
	pop edx
;     nl();
	call _nl
;     }
	jmp cc196
cc197:
;   kill();    /* invalidate line */
	call _kill
;   cmode=1;    /* then back to parse level */
	mov eax,1
	mov [_cmode],eax
;   }
	mov esp,ebp
	pop ebp
	retn
; /*  >>>>> start of cc3 <<<<<<<<<  */
; /*          */
; /*  Perform a FUNCTION call    */
; /*          */
; /* called from heir11, this routine will either call */
; /*  the NAMEd FUNCTION, or if the supplied ptr is */
; /*  zero, will call the contents of HL    */
; callfunction(ptr)
	;;;; section '.text' code
	; FUNCTION: _callfunc
_callfunc:
;   char *ptr;  /* symbol table entry (or 0) */
	push ebp
	mov ebp,esp
; {  int nargs,tl;
	push edx
	push edx
;   nargs=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   tl=getlitstk();
	lea eax,[ebp-8]
	push eax
	call _getlitst
	pop edx
	mov [edx],eax
;   blanks();  /* already saw open paren */
	call _blanks
;   if(ptr==0)zpush();  /* calling HL */
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc200
	call _zpush
;   while(streq(line+lptr,")")==0)
cc200:
cc201:
	mov eax,cc1+1258
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc202
;     {if(endst())break;
	call _endst
	test eax,eax
	je cc203
	jmp cc202
;     expression();  /* get an argument */
cc203:
	call _expressi
;     /*if(ptr==0)swapstk();*/ /* don't push addr */
;     zpush();  /* push argument */
	call _zpush
;     getlitstk();
	call _getlitst
;     nargs=nargs+4;  /* count args*2 *//*4, modified by E.V.*/
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;     if (match(",")==0) break;
	mov eax,cc1+1260
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc204
	jmp cc202
;     }
cc204:
	jmp cc201
cc202:
;   needbrack(")");
	mov eax,cc1+1262
	push eax
	call _needbrac
	pop edx
;   dumpltstk(tl);
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _dumpltst
	pop edx
;   if(ptr)zcall(ptr);
	lea eax,[ebp+8]
	mov eax,[eax]
	test eax,eax
	je cc205
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _zcall
	pop edx
;   else callstk(nargs);
	jmp cc206
cc205:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _callstk
	pop edx
cc206:
;   Zsp=modstk(Zsp+nargs);  /* clean up arguments */
	mov eax,[_Zsp]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	push eax
	call _modstk
	pop edx
	mov [_Zsp],eax
; }
	mov esp,ebp
	pop ebp
	retn
; junk()
	;;;; section '.text' code
	; FUNCTION: _junk
_junk:
; {  if(an(inbyte()))
	push ebp
	mov ebp,esp
	call _inbyte
	push eax
	call _an
	pop edx
	test eax,eax
	je cc207
;     while(an(ch()))gch();
cc208:
	call _ch
	push eax
	call _an
	pop edx
	test eax,eax
	je cc209
	call _gch
	jmp cc208
cc209:
;   else while(an(ch())==0)
	jmp cc210
cc207:
cc211:
	call _ch
	push eax
	call _an
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc212
;     {if(ch()==0)break;
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc213
	jmp cc212
;     gch();
cc213:
	call _gch
;     }
	jmp cc211
cc212:
cc210:
;   blanks();
	call _blanks
; }
	mov esp,ebp
	pop ebp
	retn
; endst()
	;;;; section '.text' code
	; FUNCTION: _endst
_endst:
; {  blanks();
	push ebp
	mov ebp,esp
	call _blanks
;   return ((streq(line+lptr,";")|(ch()==0)));
	mov eax,cc1+1264
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; illname()
	;;;; section '.text' code
	; FUNCTION: _illname
_illname:
; {  error("illegal symbol NAME");junk();}
	push ebp
	mov ebp,esp
	mov eax,cc1+1266
	push eax
	call _error
	pop edx
	call _junk
	mov esp,ebp
	pop ebp
	retn
; multidef(sname)
	;;;; section '.text' code
	; FUNCTION: _multidef
_multidef:
;   char *sname;
	push ebp
	mov ebp,esp
; {  error("already defined");
	mov eax,cc1+1286
	push eax
	call _error
	pop edx
;   comment();
	call _comment
;   outstr(sname);nl();
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outstr
	pop edx
	call _nl
; }
	mov esp,ebp
	pop ebp
	retn
; needbrack(str)
	;;;; section '.text' code
	; FUNCTION: _needbrac
_needbrac:
;   char *str;
	push ebp
	mov ebp,esp
; {  if (match(str)==0)
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc214
;     {error("missing bracket");
	mov eax,cc1+1302
	push eax
	call _error
	pop edx
;     comment();outstr(str);nl();
	call _comment
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outstr
	pop edx
	call _nl
;     }
; }
cc214:
	mov esp,ebp
	pop ebp
	retn
; needlval()
	;;;; section '.text' code
	; FUNCTION: _needlval
_needlval:
; {  error("must be lvalue");
	push ebp
	mov ebp,esp
	mov eax,cc1+1318
	push eax
	call _error
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; findglb(sname)
	;;;; section '.text' code
	; FUNCTION: _findglb
_findglb:
;   char *sname;
	push ebp
	mov ebp,esp
; {  char *ptr;
	push edx
;   ptr=STARTGLB;
	lea eax,[ebp-4]
	push eax
	mov eax,_SYMTAB
	pop edx
	mov [edx],eax
;   while(ptr!=glbptr)
cc215:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,[_glbptr]
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc216
;     {if(astreq(sname,ptr,NAMEMAX))return ptr;
	mov eax,8
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _astreq
	add esp,12
	test eax,eax
	je cc217
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;     ptr=ptr+SYMSIZ;
cc217:
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;     }
	jmp cc215
cc216:
;   return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; findloc(sname)
	;;;; section '.text' code
	; FUNCTION: _findloc
_findloc:
;   char *sname;
	push ebp
	mov ebp,esp
; {  char *ptr;
	push edx
;   ptr=STARTLOC;
	lea eax,[ebp-4]
	push eax
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;   while(ptr!=locptr)
cc218:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,[_locptr]
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc219
;     {if(astreq(sname,ptr,NAMEMAX))return ptr;
	mov eax,8
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _astreq
	add esp,12
	test eax,eax
	je cc220
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;     ptr=ptr+SYMSIZ;
cc220:
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;     }
	jmp cc218
cc219:
;   return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; addglb(sname,id,typ,value)
	;;;; section '.text' code
	; FUNCTION: _addglb
_addglb:
;   char *sname,id,typ;
;   int value;
	push ebp
	mov ebp,esp
; {  char *ptr;
	push edx
;   if(cptr=findglb(sname))return cptr;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _findglb
	pop edx
	mov [_cptr],eax
	test eax,eax
	je cc221
	mov eax,[_cptr]
	mov esp,ebp
	pop ebp
	retn
;   if(glbptr>=ENDGLB)
cc221:
	mov eax,[_glbptr]
	push eax
	mov eax,_SYMTAB
	push eax
	mov eax,300
	push eax
	mov eax,14
	pop edx
	imul edx
	pop edx
	add eax,edx
	pop edx
	cmp edx,eax
	setae al
	movzx eax,al
	test eax,eax
	je cc222
;     {error("global symbol table overflow");
	mov eax,cc1+1333
	push eax
	call _error
	pop edx
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   cptr=ptr=glbptr;
cc222:
	lea eax,[ebp-4]
	push eax
	mov eax,[_glbptr]
	pop edx
	mov [edx],eax
	mov [_cptr],eax
;   while(an(*ptr++ = *sname++));  /* copy NAME */
cc223:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	push eax
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
	push eax
	call _an
	pop edx
	test eax,eax
	je cc224
	jmp cc223
cc224:
;   cptr[IDENT]=id;
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+12]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   cptr[TYPE]=typ;
	mov eax,[_cptr]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+16]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   cptr[STORAGE]=STATIK;
	mov eax,[_cptr]
	push eax
	mov eax,11
	pop edx
	add eax,edx
	push eax
	mov eax,1
	pop edx
	mov [edx],al
;   cptr[OFFSET]=value;
	mov eax,[_cptr]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+20]
	mov eax,[eax]
	pop edx
	mov [edx],al
;   cptr[OFFSET+1]=value>>8;
	mov eax,[_cptr]
	push eax
	mov eax,12
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+20]
	mov eax,[eax]
	push eax
	mov eax,8
	pop edx
	mov ecx,eax
	mov eax,edx
	sar eax,cl
	pop edx
	mov [edx],al
;   glbptr=glbptr+SYMSIZ;
	mov eax,[_glbptr]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_glbptr],eax
;   return cptr;
	mov eax,[_cptr]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; addloc(sname,id,typ,value)
	;;;; section '.text' code
	; FUNCTION: _addloc
_addloc:
;   char *sname,id,typ;
;   int value;
	push ebp
	mov ebp,esp
; {  char *ptr;
	push edx
;   if(cptr=findloc(sname))return cptr;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _findloc
	pop edx
	mov [_cptr],eax
	test eax,eax
	je cc225
	mov eax,[_cptr]
	mov esp,ebp
	pop ebp
	retn
;   if(locptr>=ENDLOC)
cc225:
	mov eax,[_locptr]
	push eax
	mov eax,_SYMTAB
	push eax
	mov eax,5040
	pop edx
	add eax,edx
	push eax
	mov eax,14
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setae al
	movzx eax,al
	test eax,eax
	je cc226
;     {error("local symbol table overflow");
	mov eax,cc1+1362
	push eax
	call _error
	pop edx
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   cptr=ptr=locptr;
cc226:
	lea eax,[ebp-4]
	push eax
	mov eax,[_locptr]
	pop edx
	mov [edx],eax
	mov [_cptr],eax
;   while(an(*ptr++ = *sname++));  /* copy NAME */
cc227:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	push eax
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
	push eax
	call _an
	pop edx
	test eax,eax
	je cc228
	jmp cc227
cc228:
;   cptr[IDENT]=id;
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+12]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   cptr[TYPE]=typ;
	mov eax,[_cptr]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+16]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   cptr[STORAGE]=STKLOC;
	mov eax,[_cptr]
	push eax
	mov eax,11
	pop edx
	add eax,edx
	push eax
	mov eax,2
	pop edx
	mov [edx],al
;   cptr[OFFSET]=value;
	mov eax,[_cptr]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+20]
	mov eax,[eax]
	pop edx
	mov [edx],al
;   cptr[OFFSET+1]=value>>8;
	mov eax,[_cptr]
	push eax
	mov eax,12
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+20]
	mov eax,[eax]
	push eax
	mov eax,8
	pop edx
	mov ecx,eax
	mov eax,edx
	sar eax,cl
	pop edx
	mov [edx],al
;   locptr=locptr+SYMSIZ;
	mov eax,[_locptr]
	push eax
	mov eax,14
	pop edx
	add eax,edx
	mov [_locptr],eax
;   return cptr;
	mov eax,[_cptr]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test if next input string is legal symbol NAME */
; symname(sname)
	;;;; section '.text' code
	; FUNCTION: _symname
_symname:
;   char *sname;
	push ebp
	mov ebp,esp
; {  int k;char c;
	push edx
	push edx
;   blanks();
	call _blanks
;   if(alpha(ch())==0)return 0;
	call _ch
	push eax
	call _alpha
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc229
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   k=0;
cc229:
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while(an(ch()))sname[k++]=gch();
cc230:
	call _ch
	push eax
	call _an
	pop edx
	test eax,eax
	je cc231
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	call _gch
	pop edx
	mov [edx],al
	jmp cc230
cc231:
;   sname[k]=0;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],al
;   return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;   }
	mov esp,ebp
	pop ebp
	retn
; /* Return next avail internal label number */
; getlabel()
	;;;; section '.text' code
	; FUNCTION: _getlabel
_getlabel:
; {  return(++nxtlab);
	push ebp
	mov ebp,esp
	mov eax,[_nxtlab]
	inc eax
	mov [_nxtlab],eax
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* Print specified number as label */
; printlabel(label)
	;;;; section '.text' code
	; FUNCTION: _printlab
_printlab:
;   int label;
	push ebp
	mov ebp,esp
; {  outasm("cc");
	mov eax,cc1+1390
	push eax
	call _outasm
	pop edx
;   outdec(label);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outdec
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test if given character is alpha */
; alpha(c)
	;;;; section '.text' code
	; FUNCTION: _alpha
_alpha:
;   char c;
	push ebp
	mov ebp,esp
; {  c=c&127;
	lea eax,[ebp+8]
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	pop edx
	mov [edx],al
;   return(((c>='a')&(c<='z'))|
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,97
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,122
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	push eax
;     ((c>='A')&(c<='Z'))|
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,65
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,90
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	pop edx
	or eax,edx
	push eax
;     (c=='_'));
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,95
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test if given character is numeric */
; numeric(c)
	;;;; section '.text' code
	; FUNCTION: _numeric
_numeric:
;   char c;
	push ebp
	mov ebp,esp
; {  c=c&127;
	lea eax,[ebp+8]
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	pop edx
	mov [edx],al
;   return((c>='0')&(c<='9'));
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,48
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,57
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test if given character is alphanumeric */
; an(c)
	;;;; section '.text' code
	; FUNCTION: _an
_an:
;   char c;
	push ebp
	mov ebp,esp
; {  return((alpha(c))|(numeric(c)));
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _alpha
	pop edx
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _numeric
	pop edx
	pop edx
	or eax,edx
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* Print a carriage return and a string only to console */
; pl(str)
	;;;; section '.text' code
	; FUNCTION: _pl
_pl:
;   char *str;
	push ebp
	mov ebp,esp
; {  int k;
	push edx
;   k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   /* putchar(EOL); */
;   putchar(CR);	/* 28/03/2026 - CRLF (TRDOS 386 & Windows) */
	mov eax,13
	push eax
	call _putchar
	pop edx
;   putchar(LF);
	mov eax,10
	push eax
	call _putchar
	pop edx
;   while(str[k])putchar(str[k++]);
cc232:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	test eax,eax
	je cc233
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	call _putchar
	pop edx
	jmp cc232
cc233:
; }
	mov esp,ebp
	pop ebp
	retn
; addwhile(ptr)
	;;;; section '.text' code
	; FUNCTION: _addwhile
_addwhile:
;   int ptr[];
	push ebp
	mov ebp,esp
;  {
;   int k;
	push edx
;   if (wqptr==WQMAX)
	mov eax,[_wqptr]
	push eax
	mov eax,_wq
	push eax
	mov eax,300
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,4
	sal eax,2
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc234
;     {error("too many active whiles");return;}
	mov eax,cc1+1393
	push eax
	call _error
	pop edx
	mov esp,ebp
	pop ebp
	retn
;   k=0;
cc234:
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while (k<WQSIZ)
cc235:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc236
;     {*wqptr++ = ptr[k++];}
	mov eax,[_wqptr]
	inc eax
	inc eax
	inc eax
	inc eax
	mov [_wqptr],eax
	dec eax
	dec eax
	dec eax
	dec eax
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
	jmp cc235
cc236:
; }
	mov esp,ebp
	pop ebp
	retn
; delwhile()
	;;;; section '.text' code
	; FUNCTION: _delwhile
_delwhile:
;   {if(readwhile()) wqptr=wqptr-WQSIZ;
	push ebp
	mov ebp,esp
	call _readwhil
	test eax,eax
	je cc237
	mov eax,[_wqptr]
	push eax
	mov eax,4
	sal eax,2
	pop edx
	sub edx,eax
	mov eax,edx
	mov [_wqptr],eax
;   }
cc237:
	mov esp,ebp
	pop ebp
	retn
; readwhile()
	;;;; section '.text' code
	; FUNCTION: _readwhil
_readwhil:
;  {
	push ebp
	mov ebp,esp
;   if (wqptr==wq){error("no active whiles");return 0;}
	mov eax,[_wqptr]
	push eax
	mov eax,_wq
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc238
	mov eax,cc1+1416
	push eax
	call _error
	pop edx
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   else return (wqptr-WQSIZ);
	jmp cc239
cc238:
	mov eax,[_wqptr]
	push eax
	mov eax,4
	sal eax,2
	pop edx
	sub edx,eax
	mov eax,edx
	mov esp,ebp
	pop ebp
	retn
cc239:
;  }
	mov esp,ebp
	pop ebp
	retn
; ch()
	;;;; section '.text' code
	; FUNCTION: _ch
_ch:
; {  return(line[lptr]&127);
	push ebp
	mov ebp,esp
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; nch()
	;;;; section '.text' code
	; FUNCTION: _nch
_nch:
; {  if(ch()==0)return 0;
	push ebp
	mov ebp,esp
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc240
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     else return(line[lptr+1]&127);
	jmp cc241
cc240:
	mov eax,_line
	push eax
	mov eax,[_lptr]
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	mov esp,ebp
	pop ebp
	retn
cc241:
; }
	mov esp,ebp
	pop ebp
	retn
; gch()
	;;;; section '.text' code
	; FUNCTION: _gch
_gch:
; {  if(ch()==0)return 0;
	push ebp
	mov ebp,esp
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc242
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     else return(line[lptr++]&127);
	jmp cc243
cc242:
	mov eax,_line
	push eax
	mov eax,[_lptr]
	inc eax
	mov [_lptr],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	mov esp,ebp
	pop ebp
	retn
cc243:
; }
	mov esp,ebp
	pop ebp
	retn
; kill()
	;;;; section '.text' code
	; FUNCTION: _kill
_kill:
; {  lptr=0;
	push ebp
	mov ebp,esp
	mov eax,0
	mov [_lptr],eax
;   line[lptr]=0;
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],al
; }
	mov esp,ebp
	pop ebp
	retn
; inbyte()
	;;;; section '.text' code
	; FUNCTION: _inbyte
_inbyte:
; {
	push ebp
	mov ebp,esp
;   while(ch()==0)
cc244:
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc245
;     {if (eof) return 0;
	mov eax,[_eof]
	test eax,eax
	je cc246
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     insline();
cc246:
	call _insline
;     preprocess();
	call _preproce
;     }
	jmp cc244
cc245:
;   return gch();
	call _gch
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; inchar()
	;;;; section '.text' code
	; FUNCTION: _inchar
_inchar:
; {
	push ebp
	mov ebp,esp
;   if(ch()==0)insline();
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc247
	call _insline
;   if(eof)return 0;
cc247:
	mov eax,[_eof]
	test eax,eax
	je cc248
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   return(gch());
cc248:
	call _gch
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; insline()
	;;;; section '.text' code
	; FUNCTION: _insline
_insline:
; {
	push ebp
	mov ebp,esp
;   int k,unit;
	push edx
	push edx
;   while(1)
cc249:
	mov eax,1
	test eax,eax
	je cc250
;     {if (input==0)openin();
	mov eax,[_input]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc251
	call _openin
;     if(eof)return;
cc251:
	mov eax,[_eof]
	test eax,eax
	je cc252
	mov esp,ebp
	pop ebp
	retn
;     if((unit=input2)==0)unit=input;
cc252:
	lea eax,[ebp-8]
	push eax
	mov eax,[_input2]
	pop edx
	mov [edx],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc253
	lea eax,[ebp-8]
	push eax
	mov eax,[_input]
	pop edx
	mov [edx],eax
;     kill();
cc253:
	call _kill
;     while((k=getc(unit))>0)
cc254:
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _getc
	pop edx
	pop edx
	mov [edx],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc255
;       /* {if((k==EOL)|(lptr>=LINEMAX))break; */
;       { if(lptr>=LINEMAX)break;
	mov eax,[_lptr]
	push eax
	mov eax,80
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc256
	jmp cc255
;         if((k==LF)|(k==CR))break; /* 30/03/2026 */
cc256:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,13
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc257
	jmp cc255
;         line[lptr++]=k;
cc257:
	mov eax,_line
	push eax
	mov eax,[_lptr]
	inc eax
	mov [_lptr],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],al
;       }
	jmp cc254
cc255:
;     line[lptr]=0;  /* append null */
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],al
;     lineno++;  /* read one more line gtf 7/2/80 */
	mov eax,[_lineno]
	inc eax
	mov [_lineno],eax
	dec eax
;     if(k<=0)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	test eax,eax
	je cc258
;       {fclose(unit);
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _fclose
	pop edx
;       if(input2)endinclude();    /* gtf 7/16/80 */
	mov eax,[_input2]
	test eax,eax
	je cc259
	call _endinclu
;         else input=0;
	jmp cc260
cc259:
	mov eax,0
	mov [_input],eax
cc260:
;       }
;     if(lptr)
cc258:
	mov eax,[_lptr]
	test eax,eax
	je cc261
;       {if((ctext)&(cmode))
	mov eax,[_ctext]
	push eax
	mov eax,[_cmode]
	pop edx
	and eax,edx
	test eax,eax
	je cc262
;         {comment();
	call _comment
;         outstr(line);
	mov eax,_line
	push eax
	call _outstr
	pop edx
;         nl();
	call _nl
;         }
;       lptr=0;
cc262:
	mov eax,0
	mov [_lptr],eax
;       return;
	mov esp,ebp
	pop ebp
	retn
;       }
;     }
cc261:
	jmp cc249
cc250:
; }
	mov esp,ebp
	pop ebp
	retn
; /*  >>>>>> start of cc4 <<<<<<<  */
; keepch(c)
	;;;; section '.text' code
	; FUNCTION: _keepch
_keepch:
;   char c;
	push ebp
	mov ebp,esp
; {  mline[mptr]=c;
	mov eax,_mline
	push eax
	mov eax,[_mptr]
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   if(mptr<MPMAX)mptr++;
	mov eax,[_mptr]
	push eax
	mov eax,80
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc263
	mov eax,[_mptr]
	inc eax
	mov [_mptr],eax
	dec eax
;   return c;
cc263:
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; preprocess()
	;;;; section '.text' code
	; FUNCTION: _preproce
_preproce:
; {  int k;
	push ebp
	mov ebp,esp
	push edx
;   char c,sname[NAMESIZE];
	push edx
	sub esp,12
;   if(cmode==0)return;
	mov eax,[_cmode]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc264
	mov esp,ebp
	pop ebp
	retn
;   mptr=lptr=0;
cc264:
	mov eax,0
	mov [_lptr],eax
	mov [_mptr],eax
;   while(ch())
cc265:
	call _ch
	test eax,eax
	je cc266
;     {if((ch()==' ')|(ch()==9))
	call _ch
	push eax
	mov eax,32
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,9
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc267
;       {keepch(' ');
	mov eax,32
	push eax
	call _keepch
	pop edx
;       while((ch()==' ')|
cc268:
	call _ch
	push eax
	mov eax,32
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;         (ch()==9))
	call _ch
	push eax
	mov eax,9
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc269
;         gch();
	call _gch
	jmp cc268
cc269:
;       }
;     else if(ch()=='"')
	jmp cc270
cc267:
	call _ch
	push eax
	mov eax,34
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc271
;       {keepch(ch());
	call _ch
	push eax
	call _keepch
	pop edx
;       gch();
	call _gch
;       while(ch()!='"')
cc272:
	call _ch
	push eax
	mov eax,34
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc273
;         {if(ch()==0)
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc274
;           {error("missing quote");
	mov eax,cc1+1433
	push eax
	call _error
	pop edx
;           break;
	jmp cc273
;           }
;         keepch(gch());
cc274:
	call _gch
	push eax
	call _keepch
	pop edx
;         }
	jmp cc272
cc273:
;       gch();
	call _gch
;       keepch('"');
	mov eax,34
	push eax
	call _keepch
	pop edx
;       }
;     else if(ch()==39)
	jmp cc275
cc271:
	call _ch
	push eax
	mov eax,39
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc276
;       {keepch(39);
	mov eax,39
	push eax
	call _keepch
	pop edx
;       gch();
	call _gch
;       while(ch()!=39)
cc277:
	call _ch
	push eax
	mov eax,39
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc278
;         {if(ch()==0)
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc279
;           {error("missing apostrophe");
	mov eax,cc1+1447
	push eax
	call _error
	pop edx
;           break;
	jmp cc278
;           }
;         keepch(gch());
cc279:
	call _gch
	push eax
	call _keepch
	pop edx
;         }
	jmp cc277
cc278:
;       gch();
	call _gch
;       keepch(39);
	mov eax,39
	push eax
	call _keepch
	pop edx
;       }
;     else if((ch()=='/')&(nch()=='*'))
	jmp cc280
cc276:
	call _ch
	push eax
	mov eax,47
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	call _nch
	push eax
	mov eax,42
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc281
;       {inchar();inchar();
	call _inchar
	call _inchar
;       while(((ch()=='*')&
cc282:
	call _ch
	push eax
	mov eax,42
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;         (nch()=='/'))==0)
	call _nch
	push eax
	mov eax,47
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc283
;         {if(ch()==0)insline();
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc284
	call _insline
;           else inchar();
	jmp cc285
cc284:
	call _inchar
cc285:
;         if(eof)break;
	mov eax,[_eof]
	test eax,eax
	je cc286
	jmp cc283
;         }
cc286:
	jmp cc282
cc283:
;       inchar();inchar();
	call _inchar
	call _inchar
;       }
;     else if((ch()=='0')&(nch()=='x'))/*added by E.V.*/
	jmp cc287
cc281:
	call _ch
	push eax
	mov eax,48
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	call _nch
	push eax
	mov eax,120
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc288
;       {
;       keepch(gch());keepch(gch());
	call _gch
	push eax
	call _keepch
	pop edx
	call _gch
	push eax
	call _keepch
	pop edx
;       while(an(ch())|((ch()>='a')&(ch()<='f')))
cc289:
	call _ch
	push eax
	call _an
	pop edx
	push eax
	call _ch
	push eax
	mov eax,97
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,102
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	pop edx
	or eax,edx
	test eax,eax
	je cc290
;           keepch(gch());
	call _gch
	push eax
	call _keepch
	pop edx
	jmp cc289
cc290:
;       }
;     else if(alpha(ch()))  /* from an(): 9/22/80 gtf */
	jmp cc291
cc288:
	call _ch
	push eax
	call _alpha
	pop edx
	test eax,eax
	je cc292
;       {k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;       while(an(ch()))
cc293:
	call _ch
	push eax
	call _an
	pop edx
	test eax,eax
	je cc294
;         {if(k<NAMEMAX)sname[k++]=ch();
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,8
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc295
	lea eax,[ebp-20]
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	call _ch
	pop edx
	mov [edx],al
;         gch();
cc295:
	call _gch
;         }
	jmp cc293
cc294:
;       sname[k]=0;
	lea eax,[ebp-20]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],al
;       if(k=findmac(sname))
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-20]
	push eax
	call _findmac
	pop edx
	pop edx
	mov [edx],eax
	test eax,eax
	je cc296
;         while(c=macq[k++])
cc297:
	lea eax,[ebp-8]
	push eax
	mov eax,_macq
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
	test eax,eax
	je cc298
;           keepch(c);
	lea eax,[ebp-8]
	movsx eax,byte [eax]
	push eax
	call _keepch
	pop edx
	jmp cc297
cc298:
;       else
	jmp cc299
cc296:
;         {k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;         while(c=sname[k++])
cc300:
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp-20]
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
	test eax,eax
	je cc301
;           keepch(c);
	lea eax,[ebp-8]
	movsx eax,byte [eax]
	push eax
	call _keepch
	pop edx
	jmp cc300
cc301:
;         }
cc299:
;       }
;     else keepch(gch());
	jmp cc302
cc292:
	call _gch
	push eax
	call _keepch
	pop edx
cc302:
cc291:
cc287:
cc280:
cc275:
cc270:
;     }
	jmp cc265
cc266:
;   keepch(0);
	mov eax,0
	push eax
	call _keepch
	pop edx
;   if(mptr>=MPMAX)error("line too long");
	mov eax,[_mptr]
	push eax
	mov eax,80
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc303
	mov eax,cc1+1466
	push eax
	call _error
	pop edx
;   lptr=mptr=0;
cc303:
	mov eax,0
	mov [_mptr],eax
	mov [_lptr],eax
;   while(line[lptr++]=mline[mptr++]);
cc304:
	mov eax,_line
	push eax
	mov eax,[_lptr]
	inc eax
	mov [_lptr],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	mov eax,_mline
	push eax
	mov eax,[_mptr]
	inc eax
	mov [_mptr],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
	test eax,eax
	je cc305
	jmp cc304
cc305:
;   lptr=0;
	mov eax,0
	mov [_lptr],eax
;   }
	mov esp,ebp
	pop ebp
	retn
; addmac()
	;;;; section '.text' code
	; FUNCTION: _addmac
_addmac:
; {  char sname[NAMESIZE];
	push ebp
	mov ebp,esp
	sub esp,12
;   int k;
	push edx
;   if(symname(sname)==0)
	lea eax,[ebp-12]
	push eax
	call _symname
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc306
;     {illname();
	call _illname
;     kill();
	call _kill
;     return;
	mov esp,ebp
	pop ebp
	retn
;     }
;   k=0;
cc306:
	lea eax,[ebp-16]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while(putmac(sname[k++]));
cc307:
	lea eax,[ebp-12]
	push eax
	lea eax,[ebp-16]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	call _putmac
	pop edx
	test eax,eax
	je cc308
	jmp cc307
cc308:
;   while(ch()==' ' | ch()==9) gch();
cc309:
	call _ch
	push eax
	mov eax,32
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,9
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc310
	call _gch
	jmp cc309
cc310:
;   while(putmac(gch()));
cc311:
	call _gch
	push eax
	call _putmac
	pop edx
	test eax,eax
	je cc312
	jmp cc311
cc312:
;   if(macptr>=MACMAX)error("macro table full");
	mov eax,[_macptr]
	push eax
	mov eax,3000
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc313
	mov eax,cc1+1480
	push eax
	call _error
	pop edx
;   }
cc313:
	mov esp,ebp
	pop ebp
	retn
; putmac(c)
	;;;; section '.text' code
	; FUNCTION: _putmac
_putmac:
;   char c;
	push ebp
	mov ebp,esp
; {  macq[macptr]=c;
	mov eax,_macq
	push eax
	mov eax,[_macptr]
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;   if(macptr<MACMAX)macptr++;
	mov eax,[_macptr]
	push eax
	mov eax,3000
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc314
	mov eax,[_macptr]
	inc eax
	mov [_macptr],eax
	dec eax
;   return c;
cc314:
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; findmac(sname)
	;;;; section '.text' code
	; FUNCTION: _findmac
_findmac:
;   char *sname;
	push ebp
	mov ebp,esp
; {  int k;
	push edx
;   k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while(k<macptr)
cc315:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,[_macptr]
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc316
;     {if(astreq(sname,macq+k,NAMEMAX))
	mov eax,8
	push eax
	mov eax,_macq
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _astreq
	add esp,12
	test eax,eax
	je cc317
;       {while(macq[k++]);
cc318:
	mov eax,_macq
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	test eax,eax
	je cc319
	jmp cc318
cc319:
;       return k;
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;       }
;     while(macq[k++]);
cc317:
cc320:
	mov eax,_macq
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	test eax,eax
	je cc321
	jmp cc320
cc321:
;     while(macq[k++]);
cc322:
	mov eax,_macq
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	test eax,eax
	je cc323
	jmp cc322
cc323:
;     }
	jmp cc315
cc316:
;   return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* direct output to console    gtf 7/16/80 */
; toconsole()
	;;;; section '.text' code
	; FUNCTION: _toconsol
_toconsol:
; {
	push ebp
	mov ebp,esp
;   saveout = output;
	mov eax,[_output]
	mov [_saveout],eax
;   output = 0;
	mov eax,0
	mov [_output],eax
; /* end toconsole */}
	mov esp,ebp
	pop ebp
	retn
; /* direct output back to file    gtf 7/16/80 */
; tofile()
	;;;; section '.text' code
	; FUNCTION: _tofile
_tofile:
; {
	push ebp
	mov ebp,esp
;   if(saveout)
	mov eax,[_saveout]
	test eax,eax
	je cc324
;     output = saveout;
	mov eax,[_saveout]
	mov [_output],eax
;   saveout = 0;
cc324:
	mov eax,0
	mov [_saveout],eax
; /* end tofile */}
	mov esp,ebp
	pop ebp
	retn
; outbyte(c)
	;;;; section '.text' code
	; FUNCTION: _outbyte
_outbyte:
;    char c;
	push ebp
	mov ebp,esp
; {
;   if(output==0)
	mov eax,[_output]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc325
;   {putchar(c);return c;}
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _putchar
	pop edx
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	mov esp,ebp
	pop ebp
	retn
;   if(tolitstk==0)
cc325:
	mov eax,[_tolitstk]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc326
;   return outbyte1(c);
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _outbyte1
	pop edx
	mov esp,ebp
	pop ebp
	retn
;   return putlitstk(c);
cc326:
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _putlitst
	pop edx
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; outbyte1(c)
	;;;; section '.text' code
	; FUNCTION: _outbyte1
_outbyte1:
;   char c;
	push ebp
	mov ebp,esp
; {
;   if(c==0)return 0;
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc327
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   if(output)
cc327:
	mov eax,[_output]
	test eax,eax
	je cc328
; 	/* {if((putc(c,output))<=0) */
;     {if((putc(c,output))<=0)	/* SMALLC */
	mov eax,[_output]
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _putc
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	test eax,eax
	je cc329
;       {closeout();
	call _closeout
;       error("Output file error");
	mov eax,cc1+1497
	push eax
	call _error
	pop edx
;       zabort();      /* gtf 7/17/80 */
	call _zabort
;       }
;     }
cc329:
;   else putchar(c);
	jmp cc330
cc328:
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	call _putchar
	pop edx
cc330:
;   return c;
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; outstr(ptr)
	;;;; section '.text' code
	; FUNCTION: _outstr
_outstr:
;   char ptr[];
	push ebp
	mov ebp,esp
;  {
;   int k;
	push edx
;   k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while(outbyte(ptr[k++]));
cc331:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	call _outbyte
	pop edx
	test eax,eax
	je cc332
	jmp cc331
cc332:
;  }
	mov esp,ebp
	pop ebp
	retn
; /* write text destined for the assembler to read */
; /* (i.e. stuff not in comments)      */
; /*  gtf  6/26/80 */
; outasm(ptr)
	;;;; section '.text' code
	; FUNCTION: _outasm
_outasm:
; char *ptr;
	push ebp
	mov ebp,esp
; {
;   while(outbyte(*ptr++));
cc333:
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	movsx eax,byte [eax]
	push eax
	call _outbyte
	pop edx
	test eax,eax
	je cc334
	jmp cc333
cc334:
; /* end outasm */}
	mov esp,ebp
	pop ebp
	retn
; outasm1(ptr)
	;;;; section '.text' code
	; FUNCTION: _outasm1
_outasm1:
; char *ptr;
	push ebp
	mov ebp,esp
; {
;   while(outbyte1(*ptr++));
cc335:
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	movsx eax,byte [eax]
	push eax
	call _outbyte1
	pop edx
	test eax,eax
	je cc336
	jmp cc335
cc336:
; }
	mov esp,ebp
	pop ebp
	retn
; /* nl(){outbyte(EOL);}
;    nl1(){outbyte1(EOL);}
; */
; /* 28/03/2026 - CRLF (TRDOS 386 and Windows) */
; nl(){outbyte(CR);outbyte(LF);}
	;;;; section '.text' code
	; FUNCTION: _nl
_nl:
	push ebp
	mov ebp,esp
	mov eax,13
	push eax
	call _outbyte
	pop edx
	mov eax,10
	push eax
	call _outbyte
	pop edx
	mov esp,ebp
	pop ebp
	retn
; /* nl1(){outbyte(CR);putbyte(LF);} */
; tab(){outbyte(9);}
	;;;; section '.text' code
	; FUNCTION: _tab
_tab:
	push ebp
	mov ebp,esp
	mov eax,9
	push eax
	call _outbyte
	pop edx
	mov esp,ebp
	pop ebp
	retn
; col(){outbyte(58);}
	;;;; section '.text' code
	; FUNCTION: _col
_col:
	push ebp
	mov ebp,esp
	mov eax,58
	push eax
	call _outbyte
	pop edx
	mov esp,ebp
	pop ebp
	retn
; /* col1(){outbyte1(58);} */
; /* comma(){outbyte(',');} */
; /* comma1(){outbyte1(',');} */
; bell()        /* gtf 7/16/80 */
	;;;; section '.text' code
	; FUNCTION: _bell
_bell:
;   {outbyte(7);}
	push ebp
	mov ebp,esp
	mov eax,7
	push eax
	call _outbyte
	pop edx
	mov esp,ebp
	pop ebp
	retn
; /*        replaced 7/2/80 gtf
;  * error(ptr)
;  *  char ptr[];
;  * {
;  *  int k;
;  *  comment();outstr(line);nl();comment();
;  *  k=0;
;  *  while(k<lptr)
;  *    {if(line[k]==9) tab();
;  *      else outbyte(' ');
;  *    ++k;
;  *    }
;  *  outbyte('^');
;  *  nl();comment();outstr("******  ");
;  *  outstr(ptr);
;  *  outstr("  ******");
;  *  nl();
;  *  ++errcnt;
;  * }
;  */
; error(ptr)
	;;;; section '.text' code
	; FUNCTION: _error
_error:
; char ptr[];
	push ebp
	mov ebp,esp
; {  int k;
	push edx
;   char junk[81];
	sub esp,84
;   toconsole();
	call _toconsol
;   bell();
	call _bell
;   outstr("Line "); outdec(lineno); outstr(", ");
	mov eax,cc1+1515
	push eax
	call _outstr
	pop edx
	mov eax,[_lineno]
	push eax
	call _outdec
	pop edx
	mov eax,cc1+1521
	push eax
	call _outstr
	pop edx
;   if(infunc==0)
	mov eax,[_infunc]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc337
;     outbyte('(');
	mov eax,40
	push eax
	call _outbyte
	pop edx
;   if(currfn==NULL)
cc337:
	mov eax,[_currfn]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc338
;     outstr("start of file");
	mov eax,cc1+1524
	push eax
	call _outstr
	pop edx
;   else  outstr(currfn+NAME);
	jmp cc339
cc338:
	mov eax,[_currfn]
	push eax
	mov eax,0
	pop edx
	add eax,edx
	push eax
	call _outstr
	pop edx
cc339:
;   if(infunc==0)
	mov eax,[_infunc]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc340
;     outbyte(')');
	mov eax,41
	push eax
	call _outbyte
	pop edx
;   outstr(" + ");
cc340:
	mov eax,cc1+1538
	push eax
	call _outstr
	pop edx
;   outdec(lineno-fnstart);
	mov eax,[_lineno]
	push eax
	mov eax,[_fnstart]
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	call _outdec
	pop edx
;   outstr(": ");  outstr(ptr);  nl();
	mov eax,cc1+1542
	push eax
	call _outstr
	pop edx
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outstr
	pop edx
	call _nl
;   outstr(line); nl();
	mov eax,_line
	push eax
	call _outstr
	pop edx
	call _nl
;   k=0;  /* skip to error position */
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while(k<lptr){
cc341:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,[_lptr]
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc342
;     if(line[k++]==9)
	mov eax,_line
	push eax
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,9
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc343
;       tab();
	call _tab
;     else  outbyte(' ');
	jmp cc344
cc343:
	mov eax,32
	push eax
	call _outbyte
	pop edx
cc344:
;     }
	jmp cc341
cc342:
;   outbyte('^');  nl();
	mov eax,94
	push eax
	call _outbyte
	pop edx
	call _nl
;   ++errcnt;
	mov eax,[_errcnt]
	inc eax
	mov [_errcnt],eax
;   if(errstop){
	mov eax,[_errstop]
	test eax,eax
	je cc345
;     pl("Continue (Y,n,g) ? ");
	mov eax,cc1+1545
	push eax
	call _pl
	pop edx
;     gets(junk);    
	lea eax,[ebp-88]
	push eax
	call _gets
	pop edx
;     k=junk[0];
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-88]
	push eax
	mov eax,0
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],eax
;     if((k=='N') | (k=='n'))
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,78
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,110
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc346
;       zabort();
	call _zabort
;     if((k=='G') | (k=='g'))
cc346:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,71
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,103
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc347
;       errstop=0;
	mov eax,0
	mov [_errstop],eax
;     }
cc347:
;   tofile();
cc345:
	call _tofile
; /* end error */}
	mov esp,ebp
	pop ebp
	retn
; ol(ptr)
	;;;; section '.text' code
	; FUNCTION: _ol
_ol:
;   char ptr[];
	push ebp
	mov ebp,esp
; {
;   ot(ptr);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _ot
	pop edx
;   nl();
	call _nl
; }
	mov esp,ebp
	pop ebp
	retn
; ot(ptr)
	;;;; section '.text' code
	; FUNCTION: _ot
_ot:
;   char ptr[];
	push ebp
	mov ebp,esp
; {
;   tab();
	call _tab
;   outasm(ptr);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outasm
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; streq(str1,str2)
	;;;; section '.text' code
	; FUNCTION: _streq
_streq:
;   char str1[],str2[];
	push ebp
	mov ebp,esp
;  {
;   int k;
	push edx
;   k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while (str2[k])
cc348:
	lea eax,[ebp+12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	test eax,eax
	je cc349
;     {if ((str1[k])!=(str2[k])) return 0;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	lea eax,[ebp+12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc350
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     k++;
cc350:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
;     }
	jmp cc348
cc349:
;   return k;
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;  }
	mov esp,ebp
	pop ebp
	retn
; astreq(str1,str2,len)
	;;;; section '.text' code
	; FUNCTION: _astreq
_astreq:
;   char str1[],str2[];int len;
	push ebp
	mov ebp,esp
;  {
;   int k;
	push edx
;   k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   while (k<len)
cc351:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	lea eax,[ebp+16]
	mov eax,[eax]
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc352
;     {if ((str1[k])!=(str2[k]))break;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	lea eax,[ebp+12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc353
	jmp cc352
;     if(str1[k]==0)break;
cc353:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc354
	jmp cc352
;     if(str2[k]==0)break;
cc354:
	lea eax,[ebp+12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc355
	jmp cc352
;     k++;
cc355:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
;     }
	jmp cc351
cc352:
;   if (an(str1[k]))return 0;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	call _an
	pop edx
	test eax,eax
	je cc356
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   if (an(str2[k]))return 0;
cc356:
	lea eax,[ebp+12]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	call _an
	pop edx
	test eax,eax
	je cc357
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   return k;
cc357:
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;  }
	mov esp,ebp
	pop ebp
	retn
; match(lit)
	;;;; section '.text' code
	; FUNCTION: _match
_match:
;   char *lit;
	push ebp
	mov ebp,esp
; {
;   int k;
	push edx
;   blanks();
	call _blanks
;   if (k=streq(line+lptr,lit))
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	pop edx
	mov [edx],eax
	test eax,eax
	je cc358
;     {lptr=lptr+k;
	mov eax,[_lptr]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	mov [_lptr],eax
;     return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;     }
;    return 0;
cc358:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; amatch(lit,len)
	;;;; section '.text' code
	; FUNCTION: _amatch
_amatch:
;   char *lit;int len;
	push ebp
	mov ebp,esp
;  {
;   int k;
	push edx
;   blanks();
	call _blanks
;   if (k=astreq(line+lptr,lit,len))
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+12]
	mov eax,[eax]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _astreq
	add esp,12
	pop edx
	mov [edx],eax
	test eax,eax
	je cc359
;     {lptr=lptr+k;
	mov eax,[_lptr]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	add eax,edx
	mov [_lptr],eax
;     while(an(ch())) inbyte();
cc360:
	call _ch
	push eax
	call _an
	pop edx
	test eax,eax
	je cc361
	call _inbyte
	jmp cc360
cc361:
;     return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;     }
;   return 0;
cc359:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;  }
	mov esp,ebp
	pop ebp
	retn
; blanks()
	;;;; section '.text' code
	; FUNCTION: _blanks
_blanks:
;   {while(1)
	push ebp
	mov ebp,esp
cc362:
	mov eax,1
	test eax,eax
	je cc363
;     {while(ch()==0)
cc364:
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc365
;       {insline();
	call _insline
;       preprocess();
	call _preproce
;       if(eof)break;
	mov eax,[_eof]
	test eax,eax
	je cc366
	jmp cc365
;       }
cc366:
	jmp cc364
cc365:
;     if(ch()==' ')gch();
	call _ch
	push eax
	mov eax,32
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc367
	call _gch
;     else if(ch()==9)gch();
	jmp cc368
cc367:
	call _ch
	push eax
	mov eax,9
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc369
	call _gch
;     else return;
	jmp cc370
cc369:
	mov esp,ebp
	pop ebp
	retn
cc370:
cc368:
;     }
	jmp cc362
cc363:
;   }
	mov esp,ebp
	pop ebp
	retn
; /* output a decimal number - rewritten 4/1/81 gtf */
; outdec(n)
	;;;; section '.text' code
	; FUNCTION: _outdec
_outdec:
; int n;
	push ebp
	mov ebp,esp
; {
;   if(n<0)
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc371
;     outbyte('-');
	mov eax,45
	push eax
	call _outbyte
	pop edx
;   else  n = -n;
	jmp cc372
cc371:
	lea eax,[ebp+8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	neg eax
	pop edx
	mov [edx],eax
cc372:
;   outint(n);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outint
	pop edx
; /* end outdec */}
	mov esp,ebp
	pop ebp
	retn
; outint(n)  /* added 4/1/81 */
	;;;; section '.text' code
	; FUNCTION: _outint
_outint:
; int n;
	push ebp
	mov ebp,esp
; {  int q;
	push edx
;   q = n/10;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	xchg edx,eax
	mov ecx,edx
	cdq
	idiv ecx
	pop edx
	mov [edx],eax
;   if(q) outint(q);
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc373
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _outint
	pop edx
;   outbyte('0'-(n-q*10));
cc373:
	mov eax,48
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	imul edx
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	call _outbyte
	pop edx
; /* end outint */}
	mov esp,ebp
	pop ebp
	retn

if 0	; 05/04/2026

; /* return the length of a string */
; /* gtf 4/8/80 */
; strlen(s)
	;;;; section '.text' code
	; FUNCTION: _strlen
_strlen:
; char *s;
	push ebp
	mov ebp,esp
; {  char *t;
	push edx
;   t = s;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;   while(*s) s++;
cc374:
	lea eax,[ebp+8]
	mov eax,[eax]
	movsx eax,byte [eax]
	test eax,eax
	je cc375
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	jmp cc374
cc375:
;   return(s-t);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	sub edx,eax
	mov eax,edx
	mov esp,ebp
	pop ebp
	retn
; /* end strlen */}
	mov esp,ebp
	pop ebp
	retn
end if

; /* convert lower case to upper */
; /* gtf 6/26/80 */
; raise(c)
	;;;; section '.text' code
	; FUNCTION: _raise
_raise:
; char c;
	push ebp
	mov ebp,esp
; {
;   if((c>='a') & (c<='z'))
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,97
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,122
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc376
;     c = c - 'a' + 'A';
	lea eax,[ebp+8]
	push eax
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,97
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	mov eax,65
	pop edx
	add eax,edx
	pop edx
	mov [edx],al
;   return(c);
cc376:
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	mov esp,ebp
	pop ebp
	retn
; /* end raise */}
	mov esp,ebp
	pop ebp
	retn
; /* ------------------------------------------------------------- */
; /*  >>>>>>> start of cc5 <<<<<<<  */
; /* as of 5/5/81 rj */
; expression()
	;;;; section '.text' code
	; FUNCTION: _expressi
_expressi:
; {
	push ebp
	mov ebp,esp
;   int lval[2];
	sub esp,8
;   if(heir1(lval))rvalue(lval);
	lea eax,[ebp-8]
	push eax
	call _heir1
	pop edx
	test eax,eax
	je cc377
	lea eax,[ebp-8]
	push eax
	call _rvalue
	pop edx
; }
cc377:
	mov esp,ebp
	pop ebp
	retn
; heir1(lval)
	;;;; section '.text' code
	; FUNCTION: _heir1
_heir1:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k,lval2[2];
	push edx
	sub esp,8
;   k=heir2(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir2
	pop edx
	pop edx
	mov [edx],eax
;   if (match("=")) {
	mov eax,cc1+1565
	push eax
	call _match
	pop edx
	test eax,eax
	je cc378
;     if(k==0){needlval();return 0;}
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc379
	call _needlval
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     if (lval[1])zpush();
cc379:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	test eax,eax
	je cc380
	call _zpush
;     if(heir1(lval2))rvalue(lval2);
cc380:
	lea eax,[ebp-12]
	push eax
	call _heir1
	pop edx
	test eax,eax
	je cc381
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;     store(lval);
cc381:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _store
	pop edx
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   }
;   else return k;
	jmp cc382
cc378:
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
cc382:
; }
	mov esp,ebp
	pop ebp
	retn
; heir2(lval)
	;;;; section '.text' code
	; FUNCTION: _heir2
_heir2:
;   int lval[];
	push ebp
	mov ebp,esp
; {  int k,lval2[2];
	push edx
	sub esp,8
;   k=heir3(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir3
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if(ch()!='|')return k;
	call _ch
	push eax
	mov eax,124
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc383
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc383:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc384
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc384:
cc385:
	mov eax,1
	test eax,eax
	je cc386
;     {if (match("|"))
	mov eax,cc1+1567
	push eax
	call _match
	pop edx
	test eax,eax
	je cc387
;       {zpush();
	call _zpush
;       if(heir3(lval2)) rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir3
	pop edx
	test eax,eax
	je cc388
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc388:
	call _zpop
;       zor();
	call _zor
;       }
;     else return 0;
	jmp cc389
cc387:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc389:
;     }
	jmp cc385
cc386:
; }
	mov esp,ebp
	pop ebp
	retn
; heir3(lval)
	;;;; section '.text' code
	; FUNCTION: _heir3
_heir3:
;   int lval[];
	push ebp
	mov ebp,esp
; {  int k,lval2[2];
	push edx
	sub esp,8
;   k=heir4(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir4
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if(ch()!='^')return k;
	call _ch
	push eax
	mov eax,94
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc390
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc390:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc391
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc391:
cc392:
	mov eax,1
	test eax,eax
	je cc393
;     {if (match("^"))
	mov eax,cc1+1569
	push eax
	call _match
	pop edx
	test eax,eax
	je cc394
;       {zpush();
	call _zpush
;       if(heir4(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir4
	pop edx
	test eax,eax
	je cc395
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc395:
	call _zpop
;       zxor();
	call _zxor
;       }
;     else return 0;
	jmp cc396
cc394:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc396:
;     }
	jmp cc392
cc393:
; }
	mov esp,ebp
	pop ebp
	retn
; heir4(lval)
	;;;; section '.text' code
	; FUNCTION: _heir4
_heir4:
;   int lval[];
	push ebp
	mov ebp,esp
; {  int k,lval2[2];
	push edx
	sub esp,8
;   k=heir5(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir5
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if(ch()!='&')return k;
	call _ch
	push eax
	mov eax,38
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc397
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc397:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc398
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc398:
cc399:
	mov eax,1
	test eax,eax
	je cc400
;     {if (match("&"))
	mov eax,cc1+1571
	push eax
	call _match
	pop edx
	test eax,eax
	je cc401
;       {zpush();
	call _zpush
;       if(heir5(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir5
	pop edx
	test eax,eax
	je cc402
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc402:
	call _zpop
;       zand();
	call _zand
;       }
;     else return 0;
	jmp cc403
cc401:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc403:
;     }
	jmp cc399
cc400:
; }
	mov esp,ebp
	pop ebp
	retn
; heir5(lval)
	;;;; section '.text' code
	; FUNCTION: _heir5
_heir5:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k,lval2[2];
	push edx
	sub esp,8
;   k=heir6(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir6
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if((streq(line+lptr,"==")==0)&
	mov eax,cc1+1573
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;     (streq(line+lptr,"!=")==0))return k;
	mov eax,cc1+1576
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc404
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc404:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc405
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc405:
cc406:
	mov eax,1
	test eax,eax
	je cc407
;     {if (match("=="))
	mov eax,cc1+1579
	push eax
	call _match
	pop edx
	test eax,eax
	je cc408
;       {zpush();
	call _zpush
;       if(heir6(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir6
	pop edx
	test eax,eax
	je cc409
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc409:
	call _zpop
;       zeq();
	call _zeq
;       }
;     else if (match("!="))
	jmp cc410
cc408:
	mov eax,cc1+1582
	push eax
	call _match
	pop edx
	test eax,eax
	je cc411
;       {zpush();
	call _zpush
;       if(heir6(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir6
	pop edx
	test eax,eax
	je cc412
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc412:
	call _zpop
;       zne();
	call _zne
;       }
;     else return 0;
	jmp cc413
cc411:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc413:
cc410:
;     }
	jmp cc406
cc407:
; }
	mov esp,ebp
	pop ebp
	retn
; heir6(lval)
	;;;; section '.text' code
	; FUNCTION: _heir6
_heir6:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k,lval2[2];
	push edx
	sub esp,8
;   k=heir7(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir7
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if((streq(line+lptr,"<")==0)&
	mov eax,cc1+1585
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;     (streq(line+lptr,">")==0)&
	mov eax,cc1+1587
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	push eax
;     (streq(line+lptr,"<=")==0)&
	mov eax,cc1+1589
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	push eax
;     (streq(line+lptr,">=")==0))return k;
	mov eax,cc1+1592
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc414
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;     if(streq(line+lptr,">>"))return k;
cc414:
	mov eax,cc1+1595
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	test eax,eax
	je cc415
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;     if(streq(line+lptr,"<<"))return k;
cc415:
	mov eax,cc1+1598
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	test eax,eax
	je cc416
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc416:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc417
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc417:
cc418:
	mov eax,1
	test eax,eax
	je cc419
;     {if (match("<="))
	mov eax,cc1+1601
	push eax
	call _match
	pop edx
	test eax,eax
	je cc420
;       {zpush();
	call _zpush
;       if(heir7(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir7
	pop edx
	test eax,eax
	je cc421
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc421:
	call _zpop
;       if(cptr=lval[0])
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc422
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc423
;         {ule();
	call _ule
;         continue;
	jmp cc418
;         }
;       if(cptr=lval2[0])
cc423:
cc422:
	lea eax,[ebp-12]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc424
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc425
;         {ule();
	call _ule
;         continue;
	jmp cc418
;         }
;       zle();
cc425:
cc424:
	call _zle
;       }
;     else if (match(">="))
	jmp cc426
cc420:
	mov eax,cc1+1604
	push eax
	call _match
	pop edx
	test eax,eax
	je cc427
;       {zpush();
	call _zpush
;       if(heir7(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir7
	pop edx
	test eax,eax
	je cc428
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc428:
	call _zpop
;       if(cptr=lval[0])
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc429
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc430
;         {uge();
	call _uge
;         continue;
	jmp cc418
;         }
;       if(cptr=lval2[0])
cc430:
cc429:
	lea eax,[ebp-12]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc431
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc432
;         {uge();
	call _uge
;         continue;
	jmp cc418
;         }
;       zge();
cc432:
cc431:
	call _zge
;       }
;     else if((streq(line+lptr,"<"))&
	jmp cc433
cc427:
	mov eax,cc1+1607
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
;       (streq(line+lptr,"<<")==0))
	mov eax,cc1+1609
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc434
;       {inbyte();
	call _inbyte
;       zpush();
	call _zpush
;       if(heir7(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir7
	pop edx
	test eax,eax
	je cc435
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc435:
	call _zpop
;       if(cptr=lval[0])
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc436
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc437
;         {ult();
	call _ult
;         continue;
	jmp cc418
;         }
;       if(cptr=lval2[0])
cc437:
cc436:
	lea eax,[ebp-12]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc438
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc439
;         {ult();
	call _ult
;         continue;
	jmp cc418
;         }
;       zlt();
cc439:
cc438:
	call _zlt
;       }
;     else if((streq(line+lptr,">"))&
	jmp cc440
cc434:
	mov eax,cc1+1612
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
;       (streq(line+lptr,">>")==0))
	mov eax,cc1+1614
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc441
;       {inbyte();
	call _inbyte
;       zpush();
	call _zpush
;       if(heir7(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir7
	pop edx
	test eax,eax
	je cc442
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc442:
	call _zpop
;       if(cptr=lval[0])
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc443
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc444
;         {ugt();
	call _ugt
;         continue;
	jmp cc418
;         }
;       if(cptr=lval2[0])
cc444:
cc443:
	lea eax,[ebp-12]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc445
;         if(cptr[IDENT]==POINTER)
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc446
;         {ugt();
	call _ugt
;         continue;
	jmp cc418
;         }
;       zgt();
cc446:
cc445:
	call _zgt
;       }
;     else return 0;
	jmp cc447
cc441:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc447:
cc440:
cc433:
cc426:
;     }
	jmp cc418
cc419:
; }
	mov esp,ebp
	pop ebp
	retn
; /*  >>>>>> start of cc6 <<<<<<  */
; heir7(lval)
	;;;; section '.text' code
	; FUNCTION: _heir7
_heir7:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k,lval2[2];
	push edx
	sub esp,8
;   k=heir8(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir8
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if((streq(line+lptr,">>")==0)&
	mov eax,cc1+1617
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;     (streq(line+lptr,"<<")==0))return k;
	mov eax,cc1+1620
	push eax
	mov eax,_line
	push eax
	mov eax,[_lptr]
	pop edx
	add eax,edx
	push eax
	call _streq
	add esp,8
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc448
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc448:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc449
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc449:
cc450:
	mov eax,1
	test eax,eax
	je cc451
;     {if (match(">>"))
	mov eax,cc1+1623
	push eax
	call _match
	pop edx
	test eax,eax
	je cc452
;       {zpush();
	call _zpush
;       if(heir8(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir8
	pop edx
	test eax,eax
	je cc453
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc453:
	call _zpop
;       asr();
	call _asr
;       }
;     else if (match("<<"))
	jmp cc454
cc452:
	mov eax,cc1+1626
	push eax
	call _match
	pop edx
	test eax,eax
	je cc455
;       {zpush();
	call _zpush
;       if(heir8(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir8
	pop edx
	test eax,eax
	je cc456
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc456:
	call _zpop
;       asl();
	call _asl
;       }
;     else return 0;
	jmp cc457
cc455:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc457:
cc454:
;     }
	jmp cc450
cc451:
; }
	mov esp,ebp
	pop ebp
	retn
; heir8(lval)
	;;;; section '.text' code
	; FUNCTION: _heir8
_heir8:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k,lval2[2];
	push edx
	sub esp,8
;   k=heir9(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir9
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if((ch()!='+')&(ch()!='-'))return k;
	call _ch
	push eax
	mov eax,43
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,45
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc458
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc458:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc459
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc459:
cc460:
	mov eax,1
	test eax,eax
	je cc461
;     {if (match("+"))
	mov eax,cc1+1629
	push eax
	call _match
	pop edx
	test eax,eax
	je cc462
;       {zpush();
	call _zpush
;       if(heir9(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir9
	pop edx
	test eax,eax
	je cc463
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       if(cptr=lval[0])
cc463:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc464
;         if((
;           (cptr[IDENT]==ARRAY)|
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;            (cptr[IDENT]==POINTER))&
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	push eax
;          (cptr[TYPE]==CINT))/* modified by E.V. */
	mov eax,[_cptr]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc465
;           /*doublereg();*/ ol("sal eax,2");
	mov eax,cc1+1631
	push eax
	call _ol
	pop edx
;       zpop();
cc465:
cc464:
	call _zpop
;       zadd();
	call _zadd
;       }
;     else if (match("-"))
	jmp cc466
cc462:
	mov eax,cc1+1641
	push eax
	call _match
	pop edx
	test eax,eax
	je cc467
;       {zpush();
	call _zpush
;       if(heir9(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir9
	pop edx
	test eax,eax
	je cc468
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       if(cptr=lval[0])
cc468:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	mov [_cptr],eax
	test eax,eax
	je cc469
;         if(((cptr[IDENT]==POINTER)|(cptr[IDENT]==ARRAY))&
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	mov eax,[_cptr]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	push eax
;         (cptr[TYPE]==CINT))
	mov eax,[_cptr]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc470
;           /*doublereg();*/ ol("sal eax,2");
	mov eax,cc1+1643
	push eax
	call _ol
	pop edx
;       zpop();
cc470:
cc469:
	call _zpop
;       zsub();
	call _zsub
;       }
;     else return 0;
	jmp cc471
cc467:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc471:
cc466:
;     }
	jmp cc460
cc461:
; }
	mov esp,ebp
	pop ebp
	retn
; heir9(lval)
	;;;; section '.text' code
	; FUNCTION: _heir9
_heir9:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k,lval2[2];
	push edx
	sub esp,8
;   k=heir10(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if((ch()!='*')&(ch()!='/')&
	call _ch
	push eax
	mov eax,42
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,47
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	pop edx
	and eax,edx
	push eax
;     (ch()!='%'))return k;
	call _ch
	push eax
	mov eax,37
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc472
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k)rvalue(lval);
cc472:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc473
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;   while(1)
cc473:
cc474:
	mov eax,1
	test eax,eax
	je cc475
;     {if (match("*"))
	mov eax,cc1+1653
	push eax
	call _match
	pop edx
	test eax,eax
	je cc476
;       {zpush();
	call _zpush
;       if(heir9(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir9
	pop edx
	test eax,eax
	je cc477
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc477:
	call _zpop
;       mult();
	call _mult
;       }
;     else if (match("/"))
	jmp cc478
cc476:
	mov eax,cc1+1655
	push eax
	call _match
	pop edx
	test eax,eax
	je cc479
;       {zpush();
	call _zpush
;       if(heir10(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir10
	pop edx
	test eax,eax
	je cc480
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc480:
	call _zpop
;       div();
	call _div
;       }
;     else if (match("%"))
	jmp cc481
cc479:
	mov eax,cc1+1657
	push eax
	call _match
	pop edx
	test eax,eax
	je cc482
;       {zpush();
	call _zpush
;       if(heir10(lval2))rvalue(lval2);
	lea eax,[ebp-12]
	push eax
	call _heir10
	pop edx
	test eax,eax
	je cc483
	lea eax,[ebp-12]
	push eax
	call _rvalue
	pop edx
;       zpop();
cc483:
	call _zpop
;       zmod();
	call _zmod
;       }
;     else return 0;
	jmp cc484
cc482:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc484:
cc481:
cc478:
;     }
	jmp cc474
cc475:
; }
	mov esp,ebp
	pop ebp
	retn
; heir10(lval)
	;;;; section '.text' code
	; FUNCTION: _heir10
_heir10:
;   int lval[];
	push ebp
	mov ebp,esp
; {
;   int k;
	push edx
;   char *ptr;
	push edx
;   if(match("++"))
	mov eax,cc1+1659
	push eax
	call _match
	pop edx
	test eax,eax
	je cc485
;     {if((k=heir10(lval))==0)
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc486
;       {needlval();
	call _needlval
;       return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
;     if(lval[1])zpush();
cc486:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	test eax,eax
	je cc487
	call _zpush
;     rvalue(lval);
cc487:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;     inc();
	call _inc
;     ptr=lval[0];
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;     if((ptr[IDENT]==POINTER)&
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;       (ptr[TYPE]==CINT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc488
;       {inc();inc();inc();}
	call _inc
	call _inc
	call _inc
;     store(lval);
cc488:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _store
	pop edx
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   else if(match("--"))
	jmp cc489
cc485:
	mov eax,cc1+1662
	push eax
	call _match
	pop edx
	test eax,eax
	je cc490
;     {if((k=heir10(lval))==0)
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc491
;       {needlval();
	call _needlval
;       return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
;     if(lval[1])zpush();
cc491:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	test eax,eax
	je cc492
	call _zpush
;     rvalue(lval);
cc492:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;     dec();
	call _dec
;     ptr=lval[0];
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;     if((ptr[IDENT]==POINTER)&
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;       (ptr[TYPE]==CINT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc493
;       {dec();dec();dec();}
	call _dec
	call _dec
	call _dec
;     store(lval);
cc493:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _store
	pop edx
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   else if (match("-"))
	jmp cc494
cc490:
	mov eax,cc1+1665
	push eax
	call _match
	pop edx
	test eax,eax
	je cc495
;     {k=heir10(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
;     if (k) rvalue(lval);
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc496
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;     neg();
cc496:
	call _neg
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   else if(match("*"))
	jmp cc497
cc495:
	mov eax,cc1+1667
	push eax
	call _match
	pop edx
	test eax,eax
	je cc498
;     {k=heir10(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
;     if(k)rvalue(lval);
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc499
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;     lval[1]=CINT;
cc499:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,2
	pop edx
	mov [edx],eax
;     if(ptr=lval[0])lval[1]=ptr[TYPE];
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
	test eax,eax
	je cc500
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],eax
;     lval[0]=0;
cc500:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;     return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;     }
;   else if(match("!"))/*added by E.V.*/
	jmp cc501
cc498:
	mov eax,cc1+1669
	push eax
	call _match
	pop edx
	test eax,eax
	je cc502
;     {
;     k=heir10(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
;     if(k)rvalue(lval);
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc503
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;     lnot();
cc503:
	call _lnot
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   else if(match("~"))/*added by E.V.*/
	jmp cc504
cc502:
	mov eax,cc1+1671
	push eax
	call _match
	pop edx
	test eax,eax
	je cc505
;     {
;     k=heir10(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
;     if(k)rvalue(lval);
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc506
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;     bnot();
cc506:
	call _bnot
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   else if(match("&"))
	jmp cc507
cc505:
	mov eax,cc1+1673
	push eax
	call _match
	pop edx
	test eax,eax
	je cc508
;     {
;     k=heir10(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir10
	pop edx
	pop edx
	mov [edx],eax
;     if(k==0)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc509
;       {
;       error("illegal address");
	mov eax,cc1+1675
	push eax
	call _error
	pop edx
;       return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
;     else if(lval[1])return 0;
	jmp cc510
cc509:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	test eax,eax
	je cc511
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     else
	jmp cc512
cc511:
;       {
;         ot("mov eax,");
	mov eax,cc1+1691
	push eax
	call _ot
	pop edx
;         lval[1]=ptr[TYPE];
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],eax
; 	if ((ptr[IDENT]==FUNCTION)|(ptr[TYPE]!=CSTRUCT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc513
; 		outbyte("_");
	mov eax,cc1+1700
	push eax
	call _outbyte
	pop edx
;         outasm(ptr=lval[0]);
cc513:
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
	push eax
	call _outasm
	pop edx
;         nl();
	call _nl
;         return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
cc512:
cc510:
;     }
;   else 
	jmp cc514
cc508:
;     {k=heir11(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir11
	pop edx
	pop edx
	mov [edx],eax
;     if(match("++"))
	mov eax,cc1+1702
	push eax
	call _match
	pop edx
	test eax,eax
	je cc515
;       {if(k==0)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc516
;         {needlval();
	call _needlval
;         return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;         }
;       if(lval[1])zpush();
cc516:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	test eax,eax
	je cc517
	call _zpush
;       rvalue(lval);
cc517:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;       inc();
	call _inc
;       ptr=lval[0];
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;       if(ptr)
	lea eax,[ebp-8]
	mov eax,[eax]
	test eax,eax
	je cc518
;         if((ptr[IDENT]==POINTER)&
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;          (ptr[TYPE]==CINT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc519
;         {inc();inc();inc();}
	call _inc
	call _inc
	call _inc
;       store(lval);
cc519:
cc518:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _store
	pop edx
;       dec();
	call _dec
;       if(ptr)
	lea eax,[ebp-8]
	mov eax,[eax]
	test eax,eax
	je cc520
;         if((ptr[IDENT]==POINTER)&
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;          (ptr[TYPE]==CINT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc521
;         {dec();dec();dec();}
	call _dec
	call _dec
	call _dec
;       return 0;
cc521:
cc520:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
;     else if(match("--"))
	jmp cc522
cc515:
	mov eax,cc1+1705
	push eax
	call _match
	pop edx
	test eax,eax
	je cc523
;       {if(k==0)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc524
;         {needlval();
	call _needlval
;         return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;         }
;       if(lval[1])zpush();
cc524:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	test eax,eax
	je cc525
	call _zpush
;       rvalue(lval);
cc525:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;       dec();
	call _dec
;       ptr=lval[0];
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;       if(ptr)
	lea eax,[ebp-8]
	mov eax,[eax]
	test eax,eax
	je cc526
;         if((ptr[IDENT]==POINTER)&
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;          (ptr[TYPE]==CINT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc527
;         {dec();dec();dec();}
	call _dec
	call _dec
	call _dec
;       store(lval);
cc527:
cc526:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _store
	pop edx
;       inc();
	call _inc
;       if(ptr)
	lea eax,[ebp-8]
	mov eax,[eax]
	test eax,eax
	je cc528
;         if((ptr[IDENT]==POINTER)&
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
;          (ptr[TYPE]==CINT))
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc529
;         {inc();inc();inc();}
	call _inc
	call _inc
	call _inc
;       return 0;
cc529:
cc528:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
;     else return k;
	jmp cc530
cc523:
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
cc530:
cc522:
;     }
cc514:
cc507:
cc504:
cc501:
cc497:
cc494:
cc489:
;   }
	mov esp,ebp
	pop ebp
	retn
; /*  >>>>>> start of cc7 <<<<<<  */
; heir11(lval)
	;;;; section '.text' code
	; FUNCTION: _heir11
_heir11:
;   int *lval;
	push ebp
	mov ebp,esp
; {  int k;char *ptr;
	push edx
	push edx
;   k=primary(lval);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _primary
	pop edx
	pop edx
	mov [edx],eax
;   ptr=lval[0];
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	pop edx
	mov [edx],eax
;   blanks();
	call _blanks
;   if((ch()=='[')|(ch()=='('))
	call _ch
	push eax
	mov eax,91
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,40
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	or eax,edx
	test eax,eax
	je cc531
;   while(1)
cc532:
	mov eax,1
	test eax,eax
	je cc533
;     {if(match("["))
	mov eax,cc1+1708
	push eax
	call _match
	pop edx
	test eax,eax
	je cc534
;       {if(ptr==0)
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc535
;         {error("can't subscript");
	mov eax,cc1+1710
	push eax
	call _error
	pop edx
;         junk();
	call _junk
;         needbrack("]");
	mov eax,cc1+1726
	push eax
	call _needbrac
	pop edx
;         return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;         }
;       else if(ptr[IDENT]==POINTER)rvalue(lval);
	jmp cc536
cc535:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc537
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;       else if(ptr[IDENT]!=ARRAY)
	jmp cc538
cc537:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc539
;         {error("can't subscript");
	mov eax,cc1+1728
	push eax
	call _error
	pop edx
;         k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;         }
;       zpush();
cc539:
cc538:
cc536:
	call _zpush
;       expression();
	call _expressi
;       needbrack("]");
	mov eax,cc1+1744
	push eax
	call _needbrac
	pop edx
;       if(ptr[TYPE]==CINT)/*doublereg();*/ ol("sal eax,2");
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc540
	mov eax,cc1+1746
	push eax
	call _ol
	pop edx
;       zpop();
cc540:
	call _zpop
;       zadd();
	call _zadd
;       lval[1]=ptr[TYPE];
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],eax
;         /* 4/1/81 - after subscripting, not ptr anymore */
;       lval[0]=0;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;       k=1;
	lea eax,[ebp-4]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
;       }
;     else if(match("("))
	jmp cc541
cc534:
	mov eax,cc1+1756
	push eax
	call _match
	pop edx
	test eax,eax
	je cc542
;       {if(ptr==0)
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc543
;         {callfunction(0);
	mov eax,0
	push eax
	call _callfunc
	pop edx
;         }
;       else if(ptr[IDENT]!=FUNCTION)
	jmp cc544
cc543:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc545
;         {rvalue(lval);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _rvalue
	pop edx
;         callfunction(0);
	mov eax,0
	push eax
	call _callfunc
	pop edx
;         }
;       else callfunction(ptr);
	jmp cc546
cc545:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _callfunc
	pop edx
cc546:
cc544:
;       k=lval[0]=0;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
	pop edx
	mov [edx],eax
;       }
;     else return k;
	jmp cc547
cc542:
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
cc547:
cc541:
;     }
	jmp cc532
cc533:
;   if(ptr==0)return k;
cc531:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc548
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(ptr[IDENT]==FUNCTION)
cc548:
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc549
;     {ot("mov eax,[");
	mov eax,cc1+1758
	push eax
	call _ot
	pop edx
;     outname(ptr);
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	call _outname
	pop edx
;     outasm("]");
	mov eax,cc1+1768
	push eax
	call _outasm
	pop edx
;     nl();
	call _nl
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   return k;
cc549:
	lea eax,[ebp-4]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; primary(lval)
	;;;; section '.text' code
	; FUNCTION: _primary
_primary:
;   int *lval;
	push ebp
	mov ebp,esp
; {  char *ptr,sname[NAMESIZE];int num[1];
	push edx
	sub esp,12
	push edx
;   int k;
	push edx
;   if(match("("))
	mov eax,cc1+1770
	push eax
	call _match
	pop edx
	test eax,eax
	je cc550
;     {k=heir1(lval);
	lea eax,[ebp-24]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _heir1
	pop edx
	pop edx
	mov [edx],eax
;     needbrack(")");
	mov eax,cc1+1772
	push eax
	call _needbrac
	pop edx
;     return k;
	lea eax,[ebp-24]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;     }
;   if(symname(sname))
cc550:
	lea eax,[ebp-16]
	push eax
	call _symname
	pop edx
	test eax,eax
	je cc551
;     {if(ptr=findloc(sname))
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-16]
	push eax
	call _findloc
	pop edx
	pop edx
	mov [edx],eax
	test eax,eax
	je cc552
;       {getloc(ptr);
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _getloc
	pop edx
;       lval[0]=ptr;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;       lval[1]=ptr[TYPE];
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],eax
;       if(ptr[IDENT]==POINTER)lval[1]=CINT;
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,3
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc553
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,2
	pop edx
	mov [edx],eax
;       if(ptr[IDENT]==ARRAY)return 0;
cc553:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc554
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;         else return 1;
	jmp cc555
cc554:
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
cc555:
;       }
;     if(ptr=findglb(sname))
cc552:
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-16]
	push eax
	call _findglb
	pop edx
	pop edx
	mov [edx],eax
	test eax,eax
	je cc556
;       if(ptr[IDENT]!=FUNCTION)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,4
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc557
;       {lval[0]=ptr;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;       lval[1]=0;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;       if(ptr[IDENT]!=ARRAY)return 1;
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,9
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc558
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;       
;       ot("mov eax,_");/*handling the ARRAY address- by E.V.*/
cc558:
	mov eax,cc1+1774
	push eax
	call _ot
	pop edx
;       outasm(ptr);
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _outasm
	pop edx
;       nl();
	call _nl
;       lval[1]=ptr[TYPE];
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	pop edx
	mov [edx],eax
;       return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;       }
;     ptr=addglb(sname,FUNCTION,CINT,0);
cc557:
cc556:
	lea eax,[ebp-4]
	push eax
	mov eax,0
	push eax
	mov eax,2
	push eax
	mov eax,4
	push eax
	lea eax,[ebp-16]
	push eax
	call _addglb
	add esp,16
	pop edx
	mov [edx],eax
;     lval[0]=ptr;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;     lval[1]=0;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
;   if(constant(num))
cc551:
	lea eax,[ebp-20]
	push eax
	call _constant
	pop edx
	test eax,eax
	je cc559
;     return(lval[0]=lval[1]=0);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
	pop edx
	mov [edx],eax
	mov esp,ebp
	pop ebp
	retn
;   else
	jmp cc560
cc559:
;     {error("invalid expression");
	mov eax,cc1+1784
	push eax
	call _error
	pop edx
;     ot("mov eax,");outdec(0);
	mov eax,cc1+1803
	push eax
	call _ot
	pop edx
	mov eax,0
	push eax
	call _outdec
	pop edx
;     nl();
	call _nl
;     junk();
	call _junk
;     return 0;
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;     }
cc560:
;   }
	mov esp,ebp
	pop ebp
	retn
; store(lval)
	;;;; section '.text' code
	; FUNCTION: _store
_store:
;   int *lval;
	push ebp
	mov ebp,esp
; {  if (lval[1]==0)putmem(lval[0]);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc561
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _putmem
	pop edx
;   else putstk(lval[1]);
	jmp cc562
cc561:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _putstk
	pop edx
cc562:
; }
	mov esp,ebp
	pop ebp
	retn
; rvalue(lval)
	;;;; section '.text' code
	; FUNCTION: _rvalue
_rvalue:
;   int *lval;
	push ebp
	mov ebp,esp
; {  if((lval[0] != 0) & (lval[1] == 0))
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc563
;     getmem(lval[0]);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _getmem
	pop edx
;     else indirect(lval[1]);
	jmp cc564
cc563:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,1
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _indirect
	pop edx
cc564:
; }
	mov esp,ebp
	pop ebp
	retn
; test(label)
	;;;; section '.text' code
	; FUNCTION: _test
_test:
;   int label;
	push ebp
	mov ebp,esp
; {
;   needbrack("(");
	mov eax,cc1+1812
	push eax
	call _needbrac
	pop edx
;   expression();
	call _expressi
;   needbrack(")");
	mov eax,cc1+1814
	push eax
	call _needbrac
	pop edx
;   testjump(label);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _testjump
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; constant(val)
	;;;; section '.text' code
	; FUNCTION: _constant
_constant:
;   int val[];
	push ebp
	mov ebp,esp
; { 
;   int a;	
	push edx
;   if (qstr(val))
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _qstr
	pop edx
	test eax,eax
	je cc565
;      a = 2;
	lea eax,[ebp-4]
	push eax
	mov eax,2
	pop edx
	mov [edx],eax
;   else if(number(val)|pstr(val))
	jmp cc566
cc565:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _number
	pop edx
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _pstr
	pop edx
	pop edx
	or eax,edx
	test eax,eax
	je cc567
;      a = 1;
	lea eax,[ebp-4]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
;   else return 0;
	jmp cc568
cc567:
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
cc568:
cc566:
;   ot("mov eax,");
	mov eax,cc1+1816
	push eax
	call _ot
	pop edx
;   if (a == 2) {
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc569
;      printlabel(litlab);
	mov eax,[_litlab]
	push eax
	call _printlab
	pop edx
;      outbyte('+'); }
	mov eax,43
	push eax
	call _outbyte
	pop edx
;   outdec(val[0]);
cc569:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	mov eax,[eax]
	push eax
	call _outdec
	pop edx
;   nl();
	call _nl
;   return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; number(val)
	;;;; section '.text' code
	; FUNCTION: _number
_number:
;   int val[];
	push ebp
	mov ebp,esp
; { int k,minus;char c;
	push edx
	push edx
	push edx
;   int d;
	push edx
;   k=minus=1;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-8]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
	pop edx
	mov [edx],eax
;   if(match("0x")) /* hexadecimal */
	mov eax,cc1+1825
	push eax
	call _match
	pop edx
	test eax,eax
	je cc570
;     {
;     k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;     while(numeric(ch())|((ch()>='a')&(ch()<='f')))
cc571:
	call _ch
	push eax
	call _numeric
	pop edx
	push eax
	call _ch
	push eax
	mov eax,97
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	call _ch
	push eax
	mov eax,102
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	pop edx
	or eax,edx
	test eax,eax
	je cc572
;       {
;       c=inbyte();
	lea eax,[ebp-12]
	push eax
	call _inbyte
	pop edx
	mov [edx],al
;       if(numeric(c))
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	call _numeric
	pop edx
	test eax,eax
	je cc573
;         {
;         k=(k<<4)+(c-'0');
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	mov ecx,eax
	mov eax,edx
	sal eax,cl
	push eax
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	mov eax,48
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;         }
;       else
	jmp cc574
cc573:
;         {
;         k=(k<<4)+(c-'a'+10);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	mov ecx,eax
	mov eax,edx
	sal eax,cl
	push eax
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	mov eax,97
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	mov eax,10
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;         }
cc574:
;       }
	jmp cc571
cc572:
;     val[0]=k;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;     return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;     }
;   while(k)
cc570:
cc575:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc576
;     {k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;     if (match("+")) k=1;
	mov eax,cc1+1828
	push eax
	call _match
	pop edx
	test eax,eax
	je cc577
	lea eax,[ebp-4]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
;     if (match("-")) {minus=(-minus);k=1;}
cc577:
	mov eax,cc1+1830
	push eax
	call _match
	pop edx
	test eax,eax
	je cc578
	lea eax,[ebp-8]
	push eax
	lea eax,[ebp-8]
	mov eax,[eax]
	neg eax
	pop edx
	mov [edx],eax
	lea eax,[ebp-4]
	push eax
	mov eax,1
	pop edx
	mov [edx],eax
;     }
cc578:
	jmp cc575
cc576:
;   /* 05/04/2026 - Erdogan Tan */
;   /* k=0; */
;   if(numeric(ch())==0) return 0;
	call _ch
	push eax
	call _numeric
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc579
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   if(match("0")) { /* Octal */
cc579:
	mov eax,cc1+1832
	push eax
	call _match
	pop edx
	test eax,eax
	je cc580
;      while (numeric(ch())) {
cc581:
	call _ch
	push eax
	call _numeric
	pop edx
	test eax,eax
	je cc582
;          c=inbyte();
	lea eax,[ebp-12]
	push eax
	call _inbyte
	pop edx
	mov [edx],al
;      	 if(c >= '0' & c <= '7')
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	mov eax,48
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	push eax
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	mov eax,55
	pop edx
	cmp edx,eax
	setle al
	movzx eax,al
	pop edx
	and eax,edx
	test eax,eax
	je cc583
;     	   k=k*8+(c-'0');
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,8
	pop edx
	imul edx
	push eax
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	mov eax,48
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
; 	 else
	jmp cc584
cc583:
;            break;
	jmp cc582
cc584:
;          }
	jmp cc581
cc582:
;       }
;   else
	jmp cc585
cc580:
;       {
;         while (numeric(ch())) /* decimal */
cc586:
	call _ch
	push eax
	call _numeric
	pop edx
	test eax,eax
	je cc587
;             { c=inbyte();
	lea eax,[ebp-12]
	push eax
	call _inbyte
	pop edx
	mov [edx],al
;               k=k*10+(c-'0');
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,10
	pop edx
	imul edx
	push eax
	lea eax,[ebp-12]
	movsx eax,byte [eax]
	push eax
	mov eax,48
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;             }
	jmp cc586
cc587:
;       }
cc585:
;   if(minus<0) k=(-k);
	lea eax,[ebp-8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc588
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	neg eax
	pop edx
	mov [edx],eax
;   val[0]=k;
cc588:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;   return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; pstr(val)
	;;;; section '.text' code
	; FUNCTION: _pstr
_pstr:
;   int val[];
	push ebp
	mov ebp,esp
; {  int k;char c;
	push edx
	push edx
;   k=0;
	lea eax,[ebp-4]
	push eax
	mov eax,0
	pop edx
	mov [edx],eax
;   if (match("'")==0) return 0;
	mov eax,cc1+1834
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc589
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   while((c=gch())!=39)
cc589:
cc590:
	lea eax,[ebp-8]
	push eax
	call _gch
	pop edx
	mov [edx],al
	push eax
	mov eax,39
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc591
;     k=(k&255)*256 + (c&127);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,255
	pop edx
	and eax,edx
	push eax
	mov eax,256
	pop edx
	imul edx
	push eax
	lea eax,[ebp-8]
	movsx eax,byte [eax]
	push eax
	mov eax,127
	pop edx
	and eax,edx
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
	jmp cc590
cc591:
;   val[0]=k;
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	pop edx
	mov [edx],eax
;   return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; qstr(val)
	;;;; section '.text' code
	; FUNCTION: _qstr
_qstr:
;   int val[];
	push ebp
	mov ebp,esp
; {  char c;
	push edx
;   if (match(quote)==0) return 0;
	mov eax,_quote
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc592
	mov eax,0
	mov esp,ebp
	pop ebp
	retn
;   val[0]=litptr;
cc592:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	sal eax,2
	pop edx
	add eax,edx
	push eax
	mov eax,[_litptr]
	pop edx
	mov [edx],eax
;   while (ch()!='"')
cc593:
	call _ch
	push eax
	mov eax,34
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc594
;     {if(ch()==0)break;
	call _ch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc595
	jmp cc594
;     if(litptr>=LITMAX)
cc595:
	mov eax,[_litptr]
	push eax
	mov eax,8000
	push eax
	mov eax,1
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc596
;       {error("string space exhausted");
	mov eax,cc1+1836
	push eax
	call _error
	pop edx
;       while(match(quote)==0)
cc597:
	mov eax,_quote
	push eax
	call _match
	pop edx
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc598
;         if(gch()==0)break;
	call _gch
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc599
	jmp cc598
;       return 1;
cc599:
	jmp cc597
cc598:
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
;       }
;     c=gch();
cc596:
	lea eax,[ebp-4]
	push eax
	call _gch
	pop edx
	mov [edx],al
;     if(c!=92)
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,92
	pop edx
	cmp edx,eax
	setne al
	movzx eax,al
	test eax,eax
	je cc600
;       litq[litptr++]=c;
	mov eax,_litq
	push eax
	mov eax,[_litptr]
	inc eax
	mov [_litptr],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;     else
	jmp cc601
cc600:
;       {
;       c=gch();
	lea eax,[ebp-4]
	push eax
	call _gch
	pop edx
	mov [edx],al
;       if(c==0)break;
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc602
	jmp cc594
;       if(c=='n')c=10;
cc602:
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,110
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc603
	lea eax,[ebp-4]
	push eax
	mov eax,10
	pop edx
	mov [edx],al
;       else if(c=='t')c=9;
	jmp cc604
cc603:
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,116
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc605
	lea eax,[ebp-4]
	push eax
	mov eax,9
	pop edx
	mov [edx],al
;       else if(c=='b')c=8;
	jmp cc606
cc605:
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,98
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc607
	lea eax,[ebp-4]
	push eax
	mov eax,8
	pop edx
	mov [edx],al
;       else if(c=='f')c==12;
	jmp cc608
cc607:
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,102
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc609
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	push eax
	mov eax,12
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
;       litq[litptr++]=c;
cc609:
cc608:
cc606:
cc604:
	mov eax,_litq
	push eax
	mov eax,[_litptr]
	inc eax
	mov [_litptr],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	lea eax,[ebp-4]
	movsx eax,byte [eax]
	pop edx
	mov [edx],al
;       }
cc601:
;     }
	jmp cc593
cc594:
;   gch();
	call _gch
;   litq[litptr++]=0;
	mov eax,_litq
	push eax
	mov eax,[_litptr]
	inc eax
	mov [_litptr],eax
	dec eax
	pop edx
	add eax,edx
	push eax
	mov eax,0
	pop edx
	mov [edx],al
;   return 1;
	mov eax,1
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /*  >>>>>> start of cc8 <<<<<<<  */
; /* Begin a comment line for the assembler */
; comment()
	;;;; section '.text' code
	; FUNCTION: _comment
_comment:
; {  outbyte(';');outbyte(' ');
	push ebp
	mov ebp,esp
	mov eax,59
	push eax
	call _outbyte
	pop edx
	mov eax,32
	push eax
	call _outbyte
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Put out assembler info before any code is generated */
; header()
	;;;; section '.text' code
	; FUNCTION: _header
_header:
; {  comment();
	push ebp
	mov ebp,esp
	call _comment
;   outstr(BANNER);
	mov eax,cc1+1859
	push eax
	call _outstr
	pop edx
;   nl();
	call _nl
;   comment();
	call _comment
;   outstr(VERSION);
	mov eax,cc1+1917
	push eax
	call _outstr
	pop edx
;   nl();
	call _nl
;   comment();
	call _comment
;   outstr(AUTHOR);
	mov eax,cc1+1975
	push eax
	call _outstr
	pop edx
;   nl();
	call _nl
;   comment();
	call _comment
;   nl();
	call _nl
;   /*(if(mainflg){*/    /* do stuff needed for first */
;   /*ol("ORG 100h");*/ /* assembler file. */       
;   /*ol("LHLD 6");*/  /* set up stack */
;   /*ol("SPHL");*/
;   /*callrts("ccgo");*/  /* set default drive for CP/M */
;   /*zcall("main");*/  /* call the code generated by small-c */
;   /*zcall("exit");*/  /* do an exit    gtf 7/16/80 */
;   /*}*/
; }
	mov esp,ebp
	pop ebp
	retn
; /* Print any assembler stuff needed after all code */
; trailer()
	;;;; section '.text' code
	; FUNCTION: _trailer
_trailer:
; {  /* ol("END"); */  /*...note: commented out! */
	push ebp
	mov ebp,esp
;   nl();      /* 6 May 80 rj errorsummary() now goes to console */
	call _nl
;   comment();
	call _comment
;   outstr(" --- End of Compilation ---");
	mov eax,cc1+2033
	push eax
	call _outstr
	pop edx
;   nl();
	call _nl
;   tab();outasm("; ");outstr(quote);
	call _tab
	mov eax,cc1+2061
	push eax
	call _outasm
	pop edx
	mov eax,_quote
	push eax
	call _outstr
	pop edx
;   outstr(IDNT);outstr(quote);
	mov eax,cc1+2064
	push eax
	call _outstr
	pop edx
	mov eax,_quote
	push eax
	call _outstr
	pop edx
;   nl();
	call _nl
; }
	mov esp,ebp
	pop ebp
	retn
; /* Print out a NAME such that it won't annoy the assembler */
; /*  (by matching anything reserved, like opcodes.) */
; /*  gtf 4/7/80 */
; outname(sname)
	;;;; section '.text' code
	; FUNCTION: _outname
_outname:
; char *sname;
	push ebp
	mov ebp,esp
; {  int len, i,j;
	push edx
	push edx
	push edx
;   outasm("_");	
	mov eax,cc1+2072
	push eax
	call _outasm
	pop edx
; /*outasm("qz");*/
;   len = strlen(sname);
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _strlen
	pop edx
	pop edx
	mov [edx],eax
;   if(len>(ASMPREF+ASMSUFF)){
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,7
	push eax
	mov eax,7
	pop edx
	add eax,edx
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc610
;     i = ASMPREF;
	lea eax,[ebp-8]
	push eax
	mov eax,7
	pop edx
	mov [edx],eax
;     len = len-ASMPREF-ASMSUFF;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,7
	pop edx
	sub edx,eax
	mov eax,edx
	push eax
	mov eax,7
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	mov [edx],eax
;     while(i-- > 0)
cc611:
	lea eax,[ebp-8]
	push eax
	mov eax,[eax]
	dec eax
	pop edx
	mov [edx],eax
	inc eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc612
;       outbyte(raise(*sname++));
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	movsx eax,byte [eax]
	push eax
	call _raise
	pop edx
	push eax
	call _outbyte
	pop edx
	jmp cc611
cc612:
;     while(len-- > 0)
cc613:
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	dec eax
	pop edx
	mov [edx],eax
	inc eax
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc614
;       sname++;
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	jmp cc613
cc614:
;     while(*sname)
cc615:
	lea eax,[ebp+8]
	mov eax,[eax]
	movsx eax,byte [eax]
	test eax,eax
	je cc616
;       outbyte(raise(*sname++));
	lea eax,[ebp+8]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
	movsx eax,byte [eax]
	push eax
	call _raise
	pop edx
	push eax
	call _outbyte
	pop edx
	jmp cc615
cc616:
;     }
;   else  outasm(sname);
	jmp cc617
cc610:
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outasm
	pop edx
cc617:
; /* end outname */}
	mov esp,ebp
	pop ebp
	retn
; /* Fetch a static memory cell into the primary register */
; getmem(sym)
	;;;; section '.text' code
	; FUNCTION: _getmem
_getmem:
;   char *sym;
	push ebp
	mov ebp,esp
;   {ot("mov eax,[");
	mov eax,cc1+2074
	push eax
	call _ot
	pop edx
;    outname(sym+NAME);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	add eax,edx
	push eax
	call _outname
	pop edx
;    outasm("]");
	mov eax,cc1+2084
	push eax
	call _outasm
	pop edx
;    nl();
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /* Fetch the address of the specified symbol */
; /*  into the primary register */
; getloc(sym)
	;;;; section '.text' code
	; FUNCTION: _getloc
_getloc:
;   char *sym;
	push ebp
	mov ebp,esp
; {
;   int t;
	push edx
;   t=(sym[OFFSET]&255)+
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,12
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,255
	pop edx
	and eax,edx
	push eax
;   ((sym[OFFSET+1]&255)<<8);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,12
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,255
	pop edx
	and eax,edx
	push eax
	mov eax,8
	pop edx
	mov ecx,eax
	mov eax,edx
	sal eax,cl
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;   if(sym[OFFSET+1]&0x80)
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,12
	push eax
	mov eax,1
	pop edx
	add eax,edx
	pop edx
	add eax,edx
	movsx eax,byte [eax]
	push eax
	mov eax,128
	pop edx
	and eax,edx
	test eax,eax
	je cc618
;   t=t|0xffff0000;/*patched for 32 bits by E.V.*/
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,-65536
	pop edx
	or eax,edx
	pop edx
	mov [edx],eax
;   /*ot("getloc ");*/
;   ot("lea eax,[ebp");
cc618:
	mov eax,cc1+2086
	push eax
	call _ot
	pop edx
;   if (t>0) outasm("+");
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc619
	mov eax,cc1+2099
	push eax
	call _outasm
	pop edx
;   outdec(t);outasm("]");nl();
cc619:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _outdec
	pop edx
	mov eax,cc1+2101
	push eax
	call _outasm
	pop edx
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /* Store the primary register into the specified */
; /*  static memory cell */
; putmem(sym)
	;;;; section '.text' code
	; FUNCTION: _putmem
_putmem:
;   char *sym;
	push ebp
	mov ebp,esp
;   {
;   ot("mov [");
	mov eax,cc1+2103
	push eax
	call _ot
	pop edx
;   outname(sym+NAME);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	add eax,edx
	push eax
	call _outname
	pop edx
;   outasm("],eax");
	mov eax,cc1+2109
	push eax
	call _outasm
	pop edx
;   nl();
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /* Store the specified object TYPE in the primary register */
; /*  at the address on the top of the stack */
; putstk(typeobj)
	;;;; section '.text' code
	; FUNCTION: _putstk
_putstk:
; char typeobj;
	push ebp
	mov ebp,esp
; { zpop();
	call _zpop
;   if(typeobj==CINT)
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,2
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc620
;     {/*callrts("ccpint");*/
;       ol("mov [edx],eax");
	mov eax,cc1+2115
	push eax
	call _ol
	pop edx
;     }
;   else
	jmp cc621
cc620:
;     {/*ol("MOV A,L");*/    /* per Ron Cain: gtf 9/25/80 */
;     /*ol("STAX D");*/
;     ol("mov [edx],al");
	mov eax,cc1+2129
	push eax
	call _ol
	pop edx
;     }
cc621:
; }
	mov esp,ebp
	pop ebp
	retn
; /* Fetch the specified object TYPE indirect through the */
; /*  primary register into the primary register */
; indirect(typeobj)
	;;;; section '.text' code
	; FUNCTION: _indirect
_indirect:
;   char typeobj;
	push ebp
	mov ebp,esp
; {
;   if(typeobj==CCHAR)
	lea eax,[ebp+8]
	movsx eax,byte [eax]
	push eax
	mov eax,1
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc622
;   {/*callrts("ccgchar");*/
;     ol("movsx eax,byte [eax]");
	mov eax,cc1+2142
	push eax
	call _ol
	pop edx
;   }
;   else 
	jmp cc623
cc622:
;   {/*callrts("ccgint");*/
;     ol("mov eax,[eax]");
	mov eax,cc1+2163
	push eax
	call _ol
	pop edx
;   }
cc623:
; }
	mov esp,ebp
	pop ebp
	retn
; /* Swap the primary and secondary registers */
; swap()
	;;;; section '.text' code
	; FUNCTION: _swap
_swap:
; { ol("TTTTTxchgl edx,eax");
	push ebp
	mov ebp,esp
	mov eax,cc1+2177
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Print partial instruction to get an immediate value */
; /*  into the primary register */
; immed()
	;;;; section '.text' code
	; FUNCTION: _immed
_immed:
; { ot("mov ");
	push ebp
	mov ebp,esp
	mov eax,cc1+2196
	push eax
	call _ot
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Push the primary register onto the stack */
; zpush()
	;;;; section '.text' code
	; FUNCTION: _zpush
_zpush:
; {  ol("push eax");
	push ebp
	mov ebp,esp
	mov eax,cc1+2201
	push eax
	call _ol
	pop edx
;  Zsp=Zsp-4;/*modified by E.V.*/
	mov eax,[_Zsp]
	push eax
	mov eax,4
	pop edx
	sub edx,eax
	mov eax,edx
	mov [_Zsp],eax
; }
	mov esp,ebp
	pop ebp
	retn
; /* Pop the top of the stack into the secondary register */
; zpop()
	;;;; section '.text' code
	; FUNCTION: _zpop
_zpop:
; { ol("pop edx");
	push ebp
	mov ebp,esp
	mov eax,cc1+2210
	push eax
	call _ol
	pop edx
;  Zsp=Zsp+4;/*modified by E.V.*/
	mov eax,[_Zsp]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	mov [_Zsp],eax
; }
	mov esp,ebp
	pop ebp
	retn
; /* Swap the primary register and the top of the stack */
; swapstk()
	;;;; section '.text' code
	; FUNCTION: _swapstk
_swapstk:
; { ol("XTHL");
	push ebp
	mov ebp,esp
	mov eax,cc1+2218
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Call the specified subroutine NAME */
; zcall(sname)
	;;;; section '.text' code
	; FUNCTION: _zcall
_zcall:
;   char *sname;
	push ebp
	mov ebp,esp
; { ot("call ");
	mov eax,cc1+2223
	push eax
	call _ot
	pop edx
;   outname(sname);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outname
	pop edx
;   nl();
	call _nl
; }
	mov esp,ebp
	pop ebp
	retn
; /* Call a run-time library routine */
; callrts(sname)
	;;;; section '.text' code
	; FUNCTION: _callrts
_callrts:
; char *sname;
	push ebp
	mov ebp,esp
; {
;   ot("call ");
	mov eax,cc1+2229
	push eax
	call _ot
	pop edx
;   outasm(sname);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outasm
	pop edx
;   nl();
	call _nl
; /*end callrts*/}
	mov esp,ebp
	pop ebp
	retn
; /* Return from subroutine */
; zret()
	;;;; section '.text' code
	; FUNCTION: _zret
_zret:
; { ol("retn");
	push ebp
	mov ebp,esp
	mov eax,cc1+2235
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Perform subroutine call to value on top of stack */
; callstk(nargs)
	;;;; section '.text' code
	; FUNCTION: _callstk
_callstk:
;    int nargs;
	push ebp
	mov ebp,esp
; {
;   ot("mov eax,[esp+");outdec(nargs);outasm("]");nl();
	mov eax,cc1+2240
	push eax
	call _ot
	pop edx
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _outdec
	pop edx
	mov eax,cc1+2254
	push eax
	call _outasm
	pop edx
	call _nl
;   ol("call dword [eax]");
	mov eax,cc1+2256
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Jump to specified internal label number */
; jump(label)
	;;;; section '.text' code
	; FUNCTION: _jump
_jump:
;   int label;
	push ebp
	mov ebp,esp
; { ot("jmp ");
	mov eax,cc1+2273
	push eax
	call _ot
	pop edx
;   printlabel(label);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
;   nl();
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /* Test the primary register and jump if false to label */
; testjump(label)
	;;;; section '.text' code
	; FUNCTION: _testjump
_testjump:
;   int label;
	push ebp
	mov ebp,esp
; { ol("test eax,eax");
	mov eax,cc1+2278
	push eax
	call _ol
	pop edx
;   ot("je ");
	mov eax,cc1+2291
	push eax
	call _ot
	pop edx
;   printlabel(label);
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	call _printlab
	pop edx
;   nl();
	call _nl
;   }
	mov esp,ebp
	pop ebp
	retn
; /* Print pseudo-op to define a byte */
; defbyte()
	;;;; section '.text' code
	; FUNCTION: _defbyte
_defbyte:
; { ot("db ");
	push ebp
	mov ebp,esp
	mov eax,cc1+2295
	push eax
	call _ot
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Print pseudo-op to define a word */
; defword()
	;;;; section '.text' code
	; FUNCTION: _defword
_defword:
; { ot("dw ");
	push ebp
	mov ebp,esp
	mov eax,cc1+2299
	push eax
	call _ot
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Modify the stack POINTER to the new value indicated */
; modstk(newsp)
	;;;; section '.text' code
	; FUNCTION: _modstk
_modstk:
;   int newsp;
	push ebp
	mov ebp,esp
;  {  int k;
	push edx
;   k=newsp-Zsp;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp+8]
	mov eax,[eax]
	push eax
	mov eax,[_Zsp]
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	mov [edx],eax
;   if(k==0)return newsp;
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	sete al
	movzx eax,al
	test eax,eax
	je cc624
	lea eax,[ebp+8]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;   if(k>=0)
cc624:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setge al
	movzx eax,al
	test eax,eax
	je cc625
;     {if(k<7)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,7
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc626
;       { while(k&3)
cc627:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,3
	pop edx
	and eax,edx
	test eax,eax
	je cc628
;         { ol("inc esp");
	mov eax,cc1+2303
	push eax
	call _ol
	pop edx
;           k--;
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	dec eax
	pop edx
	mov [edx],eax
	inc eax
;         }
	jmp cc627
cc628:
;       while(k)
cc629:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc630
;         { ol("pop edx");
	mov eax,cc1+2311
	push eax
	call _ol
	pop edx
;           k=k-4;
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	sub edx,eax
	mov eax,edx
	pop edx
	mov [edx],eax
;         }
	jmp cc629
cc630:
;       return newsp;
	lea eax,[ebp+8]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;       }
;     }
cc626:
;   if(k<0)
cc625:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setl al
	movzx eax,al
	test eax,eax
	je cc631
;     {
;       /*ot("sub $");outdec(-k);outasm(", %esp");nl();*/
;       if(k>-7)
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,7
	neg eax
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc632
;       {
;         while(k&3)
cc633:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,3
	pop edx
	and eax,edx
	test eax,eax
	je cc634
;         {
;           ol("dec esp");
	mov eax,cc1+2319
	push eax
	call _ol
	pop edx
;           k++;
	lea eax,[ebp-4]
	push eax
	mov eax,[eax]
	inc eax
	pop edx
	mov [edx],eax
	dec eax
;         }
	jmp cc633
cc634:
;         while(k)
cc635:
	lea eax,[ebp-4]
	mov eax,[eax]
	test eax,eax
	je cc636
;         {
;           ol("push edx");
	mov eax,cc1+2327
	push eax
	call _ol
	pop edx
;           k=k+4;/*modified by E.V.*/
	lea eax,[ebp-4]
	push eax
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,4
	pop edx
	add eax,edx
	pop edx
	mov [edx],eax
;         }
	jmp cc635
cc636:
;         return newsp;
	lea eax,[ebp+8]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
;         }
;     }
cc632:
;   if(k>0)
cc631:
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	mov eax,0
	pop edx
	cmp edx,eax
	setg al
	movzx eax,al
	test eax,eax
	je cc637
;     {ot("add esp,");outdec(k);nl();}
	mov eax,cc1+2336
	push eax
	call _ot
	pop edx
	lea eax,[ebp-4]
	mov eax,[eax]
	push eax
	call _outdec
	pop edx
	call _nl
;   else
	jmp cc638
cc637:
;     {ot("sub esp,");outdec(-k);nl();}
	mov eax,cc1+2345
	push eax
	call _ot
	pop edx
	lea eax,[ebp-4]
	mov eax,[eax]
	neg eax
	push eax
	call _outdec
	pop edx
	call _nl
cc638:
;   return newsp;
	lea eax,[ebp+8]
	mov eax,[eax]
	mov esp,ebp
	pop ebp
	retn
; }
	mov esp,ebp
	pop ebp
	retn
; /* Double the primary register */
; doublereg()
	;;;; section '.text' code
	; FUNCTION: _doublere
_doublere:
; { ol("DAD H");
	push ebp
	mov ebp,esp
	mov eax,cc1+2354
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Add the primary and secondary registers */
; /*  (results in primary) */
; zadd()
	;;;; section '.text' code
	; FUNCTION: _zadd
_zadd:
; { ol("add eax,edx");
	push ebp
	mov ebp,esp
	mov eax,cc1+2360
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Subtract the primary register from the secondary */
; /*  (results in primary) */
; zsub()
	;;;; section '.text' code
	; FUNCTION: _zsub
_zsub:
; {  /*callrts("ccsub");*/
	push ebp
	mov ebp,esp
;   ol("sub edx,eax");
	mov eax,cc1+2372
	push eax
	call _ol
	pop edx
;   ol("mov eax,edx");
	mov eax,cc1+2384
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Multiply the primary and secondary registers */
; /*  (results in primary */
; mult()
	;;;; section '.text' code
	; FUNCTION: _mult
_mult:
; {  /*callrts("ccmult");*/
	push ebp
	mov ebp,esp
;   ol("imul edx");
	mov eax,cc1+2396
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Divide the secondary register by the primary */
; /*  (quotient in primary, remainder in secondary) */
; div()
	;;;; section '.text' code
	; FUNCTION: _div
_div:
; {/*callrts("ccdiv");*/
	push ebp
	mov ebp,esp
;   ol("xchg edx,eax");
	mov eax,cc1+2405
	push eax
	call _ol
	pop edx
;   ol("mov ecx,edx");
	mov eax,cc1+2418
	push eax
	call _ol
	pop edx
;   ol("cdq");
	mov eax,cc1+2430
	push eax
	call _ol
	pop edx
;   ol("idiv ecx");
	mov eax,cc1+2434
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Compute remainder (mod) of secondary register divided */
; /*  by the primary */
; /*  (remainder in primary, quotient in secondary) */
; zmod()
	;;;; section '.text' code
	; FUNCTION: _zmod
_zmod:
; {
	push ebp
	mov ebp,esp
;   div();
	call _div
;   ol("mov eax,edx");
	mov eax,cc1+2443
	push eax
	call _ol
	pop edx
;   /*swap();*/
; }
	mov esp,ebp
	pop ebp
	retn
; /* Inclusive 'or' the primary and the secondary registers */
; /*  (results in primary) */
; zor()
	;;;; section '.text' code
	; FUNCTION: _zor
_zor:
; {/*callrts("ccor");*/
	push ebp
	mov ebp,esp
;   ol("or eax,edx");
	mov eax,cc1+2455
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Exclusive 'or' the primary and seconday registers */
; /*  (results in primary) */
; zxor()
	;;;; section '.text' code
	; FUNCTION: _zxor
_zxor:
; {/*callrts("ccxor");*/
	push ebp
	mov ebp,esp
;   ol("xor eax,edx");
	mov eax,cc1+2466
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* 'And' the primary and secondary registers */
; /*  (results in primary) */
; zand()
	;;;; section '.text' code
	; FUNCTION: _zand
_zand:
; {/*callrts("ccand");*/
	push ebp
	mov ebp,esp
;   ol("and eax,edx");
	mov eax,cc1+2478
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Arithmetic shift right the secondary register number of */
; /*  times in primary (results in primary) */
; asr()
	;;;; section '.text' code
	; FUNCTION: _asr
_asr:
; {/*callrts("ccasr");*/
	push ebp
	mov ebp,esp
;   ol("mov ecx,eax");
	mov eax,cc1+2490
	push eax
	call _ol
	pop edx
;   ol("mov eax,edx");
	mov eax,cc1+2502
	push eax
	call _ol
	pop edx
;   ol("sar eax,cl");
	mov eax,cc1+2514
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Arithmetic left shift the secondary register number of */
; /*  times in primary (results in primary) */
; asl()
	;;;; section '.text' code
	; FUNCTION: _asl
_asl:
; {/*callrts("ccasl");*/
	push ebp
	mov ebp,esp
;   ol("mov ecx,eax");
	mov eax,cc1+2525
	push eax
	call _ol
	pop edx
;   ol("mov eax,edx");
	mov eax,cc1+2537
	push eax
	call _ol
	pop edx
;   ol("sal eax,cl");
	mov eax,cc1+2549
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Form two's complement of primary register */
; neg()
	;;;; section '.text' code
	; FUNCTION: _neg
_neg:
; {/*callrts("ccneg");*/
	push ebp
	mov ebp,esp
;   ol("neg eax");
	mov eax,cc1+2560
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; lnot()/*added by E.V.*/
	;;;; section '.text' code
	; FUNCTION: _lnot
_lnot:
; {
	push ebp
	mov ebp,esp
;   ol("test eax,eax");
	mov eax,cc1+2568
	push eax
	call _ol
	pop edx
;   ol("sete al");
	mov eax,cc1+2581
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2589
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; bnot()/*added by E.V.*/
	;;;; section '.text' code
	; FUNCTION: _bnot
_bnot:
; {
	push ebp
	mov ebp,esp
;   ol("not eax");
	mov eax,cc1+2602
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Form one's complement of primary register */
; com()
	;;;; section '.text' code
	; FUNCTION: _com
_com:
;   {callrts("cccom");}
	push ebp
	mov ebp,esp
	mov eax,cc1+2610
	push eax
	call _callrts
	pop edx
	mov esp,ebp
	pop ebp
	retn
; /* Increment the primary register by one */
; inc()
	;;;; section '.text' code
	; FUNCTION: _inc
_inc:
;   {ol("inc eax");}
	push ebp
	mov ebp,esp
	mov eax,cc1+2616
	push eax
	call _ol
	pop edx
	mov esp,ebp
	pop ebp
	retn
; /* Decrement the primary register by one */
; dec()
	;;;; section '.text' code
	; FUNCTION: _dec
_dec:
;   {ol("dec eax");}
	push ebp
	mov ebp,esp
	mov eax,cc1+2624
	push eax
	call _ol
	pop edx
	mov esp,ebp
	pop ebp
	retn
; /* Following are the conditional operators */
; /* They compare the secondary register against the primary */
; /* and put a literal 1 in the primary if the condition is */
; /* true, otherwise they clear the primary register */
; /* Test for equal */
; zeq()
	;;;; section '.text' code
	; FUNCTION: _zeq
_zeq:
; {/*callrts("cceq");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2632
	push eax
	call _ol
	pop edx
;   ol("sete al");
	mov eax,cc1+2644
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2652
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for not equal */
; zne()
	;;;; section '.text' code
	; FUNCTION: _zne
_zne:
; {/*callrts("ccne");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2665
	push eax
	call _ol
	pop edx
;   ol("setne al");
	mov eax,cc1+2677
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2686
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for less than (signed) */
; zlt()
	;;;; section '.text' code
	; FUNCTION: _zlt
_zlt:
; {/*callrts("cclt");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2699
	push eax
	call _ol
	pop edx
;   ol("setl al");
	mov eax,cc1+2711
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2719
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for less than or equal to (signed) */
; zle()
	;;;; section '.text' code
	; FUNCTION: _zle
_zle:
; {/*callrts("ccle");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2732
	push eax
	call _ol
	pop edx
;   ol("setle al");
	mov eax,cc1+2744
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2753
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for greater than (signed) */
; zgt()
	;;;; section '.text' code
	; FUNCTION: _zgt
_zgt:
; {/*callrts("ccgt");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2766
	push eax
	call _ol
	pop edx
;   ol("setg al");
	mov eax,cc1+2778
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2786
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for greater than or equal to (signed) */
; zge()
	;;;; section '.text' code
	; FUNCTION: _zge
_zge:
; {/*callrts("ccge");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2799
	push eax
	call _ol
	pop edx
;   ol("setge al");
	mov eax,cc1+2811
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2820
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for less than (unsigned) */
; ult()
	;;;; section '.text' code
	; FUNCTION: _ult
_ult:
; {/*callrts("ccult");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2833
	push eax
	call _ol
	pop edx
;   ol("setb al");
	mov eax,cc1+2845
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2853
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for less than or equal to (unsigned) */
; ule()
	;;;; section '.text' code
	; FUNCTION: _ule
_ule:
; {/*callrts("ccule");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2866
	push eax
	call _ol
	pop edx
;   ol("setbe al");
	mov eax,cc1+2878
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2887
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for greater than (unsigned) */
; ugt()
	;;;; section '.text' code
	; FUNCTION: _ugt
_ugt:
; {/*callrts("ccugt");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2900
	push eax
	call _ol
	pop edx
;   ol("seta al");
	mov eax,cc1+2912
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2920
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /* Test for greater than or equal to (unsigned) */
; uge()
	;;;; section '.text' code
	; FUNCTION: _uge
_uge:
; {/*callrts("ccuge");*/
	push ebp
	mov ebp,esp
;   ol("cmp edx,eax");
	mov eax,cc1+2933
	push eax
	call _ol
	pop edx
;   ol("setae al");
	mov eax,cc1+2945
	push eax
	call _ol
	pop edx
;   ol("movzx eax,al");
	mov eax,cc1+2954
	push eax
	call _ol
	pop edx
; }
	mov esp,ebp
	pop ebp
	retn
; /*  <<<<<  End of small-c compiler  >>>>>  */
	;;;; section '.data' data
cc1:
	db 116,111,111,32,108,97,114,103,101,32
	db 99,111,100,101,32,102,114,111,109,32
	db 70,85,78,67,84,73,79,78,32,97
	db 114,103,117,109,101,110,116,115,0,116
	db 111,111,32,109,97,110,121,32,70,85
	db 78,67,84,73,79,78,32,97,114,103
	db 117,109,101,110,116,115,0,67,111,109
	db 112,105,108,97,116,105,111,110,32,97
	db 98,111,114,116,101,100,46,0,99,104
	db 97,114,0,105,110,116,0,115,116,114
	db 117,99,116,0,35,97,115,109,0,35
	db 105,110,99,108,117,100,101,0,35,100
	db 101,102,105,110,101,0,59,59,59,59
	db 32,115,101,99,116,105,111,110,32,39
	db 46,100,97,116,97,39,32,100,97,116
	db 97,0,58,32,0,114,100,32,0,114
	db 98,32,0,109,105,115,115,105,110,103
	db 32,99,108,111,115,105,110,103,32,98
	db 114,97,99,107,101,116,0,84,104,101
	db 114,101,32,119,101,114,101,32,0,32
	db 101,114,114,111,114,115,32,105,110,32
	db 99,111,109,112,105,108,97,116,105,111
	db 110,46,0,60,62,60,62,60,62,60
	db 62,60,62,60,62,60,62,60,62,60
	db 62,60,62,60,62,60,62,60,62,60
	db 62,88,60,62,60,62,60,62,60,62
	db 60,62,60,62,60,62,60,62,60,62
	db 60,62,60,62,60,62,60,62,60,62
	db 0,60,62,60,62,60,62,32,32,32
	db 83,109,97,108,108,45,67,32,32,86
	db 49,46,50,32,32,68,79,83,45,45
	db 67,80,47,77,32,67,114,111,115,115
	db 32,67,111,109,112,105,108,101,114,32
	db 32,32,60,62,60,62,60,62,0,60
	db 62,60,62,60,62,60,62,60,62,60
	db 62,60,62,60,62,60,62,60,62,32
	db 32,32,66,121,32,82,111,110,32,67
	db 97,105,110,32,32,32,60,62,60,62
	db 60,62,60,62,60,62,60,62,60,62
	db 60,62,60,62,60,62,0,60,62,60
	db 62,60,62,32,72,97,99,107,101,100
	db 32,102,111,114,32,73,65,51,50,47
	db 76,105,110,117,120,32,98,121,32,69
	db 118,103,117,101,110,105,121,32,86,105
	db 116,99,104,101,118,32,60,62,60,62
	db 60,62,60,62,0,60,62,60,62,60
	db 62,60,62,60,62,60,62,60,62,60
	db 62,60,62,60,62,60,62,60,62,60
	db 62,60,62,88,60,62,60,62,60,62
	db 60,62,60,62,60,62,60,62,60,62
	db 60,62,60,62,60,62,60,62,60,62
	db 60,62,0,79,117,116,112,117,116,32
	db 102,105,108,101,110,97,109,101,63,32
	db 0,119,0,79,112,101,110,32,102,97
	db 105,108,117,114,101,33,0,73,110,112
	db 117,116,32,102,105,108,101,110,97,109
	db 101,63,32,0,114,0,79,112,101,110
	db 32,102,97,105,108,117,114,101,0,35
	db 105,110,99,108,117,100,101,32,0,67
	db 97,110,110,111,116,32,110,101,115,116
	db 32,105,110,99,108,117,100,101,32,102
	db 105,108,101,115,0,114,0,79,112,101
	db 110,32,102,97,105,108,117,114,101,32
	db 111,110,32,105,110,99,108,117,100,101
	db 32,102,105,108,101,0,35,101,110,100
	db 32,105,110,99,108,117,100,101,0,42
	db 0,91,0,44,0,42,0,91,0,44
	db 0,93,0,109,117,115,116,32,98,101
	db 32,99,111,110,115,116,97,110,116,0
	db 110,101,103,97,116,105,118,101,32,115
	db 105,122,101,32,105,108,108,101,103,97
	db 108,0,93,0,105,108,108,101,103,97
	db 108,32,83,84,82,85,67,84,32,111
	db 114,32,100,101,99,108,97,114,97,116
	db 105,111,110,0,123,0,123,0,109,105
	db 115,115,105,110,103,32,111,112,101,110
	db 32,123,32,0,59,59,59,59,32,115
	db 101,99,116,105,111,110,32,39,46,116
	db 101,120,116,39,32,99,111,100,101,0
	db 59,32,79,66,74,69,67,84,58,32
	db 0,125,0,99,104,97,114,0,105,110
	db 116,0,119,114,111,110,103,32,110,117
	db 109,98,101,114,32,97,114,103,115,0
	db 112,117,115,104,32,101,98,112,0,109
	db 111,118,32,101,98,112,44,101,115,112
	db 0,105,108,108,101,103,97,108,32,70
	db 85,78,67,84,73,79,78,32,111,114
	db 32,100,101,99,108,97,114,97,116,105
	db 111,110,0,40,0,109,105,115,115,105
	db 110,103,32,111,112,101,110,32,112,97
	db 114,101,110,0,59,59,59,59,32,115
	db 101,99,116,105,111,110,32,39,46,116
	db 101,120,116,39,32,99,111,100,101,0
	db 59,32,70,85,78,67,84,73,79,78
	db 58,32,0,41,0,105,110,116,0,99
	db 104,97,114,0,44,0,41,0,105,110
	db 116,0,99,104,97,114,0,41,0,44
	db 0,101,120,112,101,99,116,101,100,32
	db 99,111,109,109,97,0,99,104,97,114
	db 0,105,110,116,0,119,114,111,110,103
	db 32,110,117,109,98,101,114,32,97,114
	db 103,115,0,112,117,115,104,32,101,98
	db 112,0,109,111,118,32,101,98,112,44
	db 101,115,112,0,109,111,118,32,101,115
	db 112,44,101,98,112,0,112,111,112,32
	db 101,98,112,0,42,0,91,0,42,0
	db 91,0,44,0,101,120,112,101,99,116
	db 101,100,32,99,111,109,109,97,0,99
	db 104,97,114,0,105,110,116,0,115,116
	db 114,117,99,116,0,123,0,105,102,0
	db 119,104,105,108,101,0,102,111,114,0
	db 100,111,0,114,101,116,117,114,110,0
	db 98,114,101,97,107,0,99,111,110,116
	db 105,110,117,101,0,59,0,35,97,115
	db 109,0,59,0,109,105,115,115,105,110
	db 103,32,115,101,109,105,99,111,108,111
	db 110,0,125,0,101,108,115,101,0,119
	db 104,105,108,101,0,39,119,104,105,108
	db 101,39,32,110,101,101,100,101,100,0
	db 40,0,116,101,115,116,32,101,97,120
	db 44,101,97,120,0,106,110,101,32,0
	db 41,0,40,0,41,0,100,117,109,112
	db 108,116,115,116,107,46,46,46,10,0
	db 109,111,118,32,101,115,112,44,101,98
	db 112,0,112,111,112,32,101,98,112,0
	db 35,101,110,100,97,115,109,0,41,0
	db 44,0,41,0,59,0,105,108,108,101
	db 103,97,108,32,115,121,109,98,111,108
	db 32,78,65,77,69,0,97,108,114,101
	db 97,100,121,32,100,101,102,105,110,101
	db 100,0,109,105,115,115,105,110,103,32
	db 98,114,97,99,107,101,116,0,109,117
	db 115,116,32,98,101,32,108,118,97,108
	db 117,101,0,103,108,111,98,97,108,32
	db 115,121,109,98,111,108,32,116,97,98
	db 108,101,32,111,118,101,114,102,108,111
	db 119,0,108,111,99,97,108,32,115,121
	db 109,98,111,108,32,116,97,98,108,101
	db 32,111,118,101,114,102,108,111,119,0
	db 99,99,0,116,111,111,32,109,97,110
	db 121,32,97,99,116,105,118,101,32,119
	db 104,105,108,101,115,0,110,111,32,97
	db 99,116,105,118,101,32,119,104,105,108
	db 101,115,0,109,105,115,115,105,110,103
	db 32,113,117,111,116,101,0,109,105,115
	db 115,105,110,103,32,97,112,111,115,116
	db 114,111,112,104,101,0,108,105,110,101
	db 32,116,111,111,32,108,111,110,103,0
	db 109,97,99,114,111,32,116,97,98,108
	db 101,32,102,117,108,108,0,79,117,116
	db 112,117,116,32,102,105,108,101,32,101
	db 114,114,111,114,0,76,105,110,101,32
	db 0,44,32,0,115,116,97,114,116,32
	db 111,102,32,102,105,108,101,0,32,43
	db 32,0,58,32,0,67,111,110,116,105
	db 110,117,101,32,40,89,44,110,44,103
	db 41,32,63,32,0,61,0,124,0,94
	db 0,38,0,61,61,0,33,61,0,61
	db 61,0,33,61,0,60,0,62,0,60
	db 61,0,62,61,0,62,62,0,60,60
	db 0,60,61,0,62,61,0,60,0,60
	db 60,0,62,0,62,62,0,62,62,0
	db 60,60,0,62,62,0,60,60,0,43
	db 0,115,97,108,32,101,97,120,44,50
	db 0,45,0,115,97,108,32,101,97,120
	db 44,50,0,42,0,47,0,37,0,43
	db 43,0,45,45,0,45,0,42,0,33
	db 0,126,0,38,0,105,108,108,101,103
	db 97,108,32,97,100,100,114,101,115,115
	db 0,109,111,118,32,101,97,120,44,0
	db 95,0,43,43,0,45,45,0,91,0
	db 99,97,110,39,116,32,115,117,98,115
	db 99,114,105,112,116,0,93,0,99,97
	db 110,39,116,32,115,117,98,115,99,114
	db 105,112,116,0,93,0,115,97,108,32
	db 101,97,120,44,50,0,40,0,109,111
	db 118,32,101,97,120,44,91,0,93,0
	db 40,0,41,0,109,111,118,32,101,97
	db 120,44,95,0,105,110,118,97,108,105
	db 100,32,101,120,112,114,101,115,115,105
	db 111,110,0,109,111,118,32,101,97,120
	db 44,0,40,0,41,0,109,111,118,32
	db 101,97,120,44,0,48,120,0,43,0
	db 45,0,48,0,39,0,115,116,114,105
	db 110,103,32,115,112,97,99,101,32,101
	db 120,104,97,117,115,116,101,100,0,60
	db 62,60,62,60,62,32,32,32,83,109
	db 97,108,108,45,67,32,32,86,49,46
	db 50,32,32,68,79,83,45,45,67,80
	db 47,77,32,67,114,111,115,115,32,67
	db 111,109,112,105,108,101,114,32,32,32
	db 60,62,60,62,60,62,0,60,62,60
	db 62,60,62,60,62,60,62,32,32,32
	db 67,80,47,77,32,76,97,114,103,101
	db 32,83,116,114,105,110,103,32,83,112
	db 97,99,101,32,86,101,114,115,105,111
	db 110,32,32,32,60,62,60,62,60,62
	db 60,62,60,62,0,60,62,60,62,60
	db 62,60,62,60,62,60,62,60,62,60
	db 62,60,62,60,62,32,32,32,66,121
	db 32,82,111,110,32,67,97,105,110,32
	db 32,32,60,62,60,62,60,62,60,62
	db 60,62,60,62,60,62,60,62,60,62
	db 60,62,0,32,45,45,45,32,69,110
	db 100,32,111,102,32,67,111,109,112,105
	db 108,97,116,105,111,110,32,45,45,45
	db 0,59,32,0,83,109,97,108,108,32
	db 67,0,95,0,109,111,118,32,101,97
	db 120,44,91,0,93,0,108,101,97,32
	db 101,97,120,44,91,101,98,112,0,43
	db 0,93,0,109,111,118,32,91,0,93
	db 44,101,97,120,0,109,111,118,32,91
	db 101,100,120,93,44,101,97,120,0,109
	db 111,118,32,91,101,100,120,93,44,97
	db 108,0,109,111,118,115,120,32,101,97
	db 120,44,98,121,116,101,32,91,101,97
	db 120,93,0,109,111,118,32,101,97,120
	db 44,91,101,97,120,93,0,84,84,84
	db 84,84,120,99,104,103,108,32,101,100
	db 120,44,101,97,120,0,109,111,118,32
	db 0,112,117,115,104,32,101,97,120,0
	db 112,111,112,32,101,100,120,0,88,84
	db 72,76,0,99,97,108,108,32,0,99
	db 97,108,108,32,0,114,101,116,110,0
	db 109,111,118,32,101,97,120,44,91,101
	db 115,112,43,0,93,0,99,97,108,108
	db 32,100,119,111,114,100,32,91,101,97
	db 120,93,0,106,109,112,32,0,116,101
	db 115,116,32,101,97,120,44,101,97,120
	db 0,106,101,32,0,100,98,32,0,100
	db 119,32,0,105,110,99,32,101,115,112
	db 0,112,111,112,32,101,100,120,0,100
	db 101,99,32,101,115,112,0,112,117,115
	db 104,32,101,100,120,0,97,100,100,32
	db 101,115,112,44,0,115,117,98,32,101
	db 115,112,44,0,68,65,68,32,72,0
	db 97,100,100,32,101,97,120,44,101,100
	db 120,0,115,117,98,32,101,100,120,44
	db 101,97,120,0,109,111,118,32,101,97
	db 120,44,101,100,120,0,105,109,117,108
	db 32,101,100,120,0,120,99,104,103,32
	db 101,100,120,44,101,97,120,0,109,111
	db 118,32,101,99,120,44,101,100,120,0
	db 99,100,113,0,105,100,105,118,32,101
	db 99,120,0,109,111,118,32,101,97,120
	db 44,101,100,120,0,111,114,32,101,97
	db 120,44,101,100,120,0,120,111,114,32
	db 101,97,120,44,101,100,120,0,97,110
	db 100,32,101,97,120,44,101,100,120,0
	db 109,111,118,32,101,99,120,44,101,97
	db 120,0,109,111,118,32,101,97,120,44
	db 101,100,120,0,115,97,114,32,101,97
	db 120,44,99,108,0,109,111,118,32,101
	db 99,120,44,101,97,120,0,109,111,118
	db 32,101,97,120,44,101,100,120,0,115
	db 97,108,32,101,97,120,44,99,108,0
	db 110,101,103,32,101,97,120,0,116,101
	db 115,116,32,101,97,120,44,101,97,120
	db 0,115,101,116,101,32,97,108,0,109
	db 111,118,122,120,32,101,97,120,44,97
	db 108,0,110,111,116,32,101,97,120,0
	db 99,99,99,111,109,0,105,110,99,32
	db 101,97,120,0,100,101,99,32,101,97
	db 120,0,99,109,112,32,101,100,120,44
	db 101,97,120,0,115,101,116,101,32,97
	db 108,0,109,111,118,122,120,32,101,97
	db 120,44,97,108,0,99,109,112,32,101
	db 100,120,44,101,97,120,0,115,101,116
	db 110,101,32,97,108,0,109,111,118,122
	db 120,32,101,97,120,44,97,108,0,99
	db 109,112,32,101,100,120,44,101,97,120
	db 0,115,101,116,108,32,97,108,0,109
	db 111,118,122,120,32,101,97,120,44,97
	db 108,0,99,109,112,32,101,100,120,44
	db 101,97,120,0,115,101,116,108,101,32
	db 97,108,0,109,111,118,122,120,32,101
	db 97,120,44,97,108,0,99,109,112,32
	db 101,100,120,44,101,97,120,0,115,101
	db 116,103,32,97,108,0,109,111,118,122
	db 120,32,101,97,120,44,97,108,0,99
	db 109,112,32,101,100,120,44,101,97,120
	db 0,115,101,116,103,101,32,97,108,0
	db 109,111,118,122,120,32,101,97,120,44
	db 97,108,0,99,109,112,32,101,100,120
	db 44,101,97,120,0,115,101,116,98,32
	db 97,108,0,109,111,118,122,120,32,101
	db 97,120,44,97,108,0,99,109,112,32
	db 101,100,120,44,101,97,120,0,115,101
	db 116,98,101,32,97,108,0,109,111,118
	db 122,120,32,101,97,120,44,97,108,0
	db 99,109,112,32,101,100,120,44,101,97
	db 120,0,115,101,116,97,32,97,108,0
	db 109,111,118,122,120,32,101,97,120,44
	db 97,108,0,99,109,112,32,101,100,120
	db 44,101,97,120,0,115,101,116,97,101
	db 32,97,108,0,109,111,118,122,120,32
	db 101,97,120,44,97,108,0
	_tolitstk: rd 1
	_litstk: rb 5000
	_litstk2: rb 5000
	_litstkle: rd 10
	_litstkpt: rd 10
	_SYMTAB: rb 5040
	_glbptr: rd 1
	_locptr: rd 1
	_wq: rd 300
	_wqptr: rd 1
	_litq: rb 8000
	_litptr: rd 1
	_macq: rb 3000
	_macptr: rd 1
	_line: rb 80
	_mline: rb 80
	_lptr: rd 1
	_mptr: rd 1
	_field_of: rd 1
	_nxtlab: rd 1
	_litlab: rd 1
	_Zsp: rd 1
	_argstk: rd 1
	_argtop: rd 1
	_ncmp: rd 1
	_errcnt: rd 1
	_errstop: rd 1
	_eof: rd 1
	_input: rd 1
	_output: rd 1
	_input2: rd 1
	_glbflag: rd 1
	_ctext: rd 1
	_cmode: rd 1
	_lastst: rd 1
	_mainflg: rd 1
	_saveout: rd 1
	_kandr: rd 1
	_fnstart: rd 1
	_lineno: rd 1
	_infunc: rd 1
	_savestar: rd 1
	_saveline: rd 1
	_saveinfn: rd 1
	_currfn: rd 1
	_savecurr: rd 1
	_quote: rb 2
	_cptr: rd 1
	_iptr: rd 1

;  --- End of Compilation ---
	; "Small C"
