#:<><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
#:<><><><><>   CP/M Large String Space Version   <><><><><>
#:<><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
#:
#:/************************************************/
#:/*            */
#:/*    small-c compiler    */
#:/*            */
#:/*      by Ron Cain      */
#:/*            */
#:/************************************************/
#:/* with minor mods by RDK */
#:/* Hacked for IA32/Linux by Evgueniy Vitchev - 
#:   provided 'for' and 'do' statements */
#:/*
#:This fella outpus GAS assembler suitable for GNU toolchain - nice!
#:http://www.physics.rutgers.edu/~vitchev/smallc-i386.html
#:The compiler can be bootstrapped by using gcc in the following way:
#:    Build a stage 1 compiler:
#:    gcc -o smc386c1 smc386c.c
#:    Using the stage 1 compiler build a stage 2 compiler:
#:    ./smc386c1
#:    Output filename? smc386c2.s
#:    Input filename? smc386c.c
#:    Input filename? <enter>
#:    There were 0 errors in compilation.
#:    gcc -o smc386c2 smc386c2.s
#:    In order to make sure everything went properly, go to stage 3:
#:    ./smc386c2
#:    Output filename? smc386c3.s
#:    Input filename? smc386c.c
#:    Input filename? <enter>
#:    diff smc386c2.s smc386c3.s
#:    If diff doesn't produce output, this means the bootstrap was successful, an
#: you can use the stage 2 compiler smc386c2.
#:*/
#:#define BANNER  "<><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>"
#:#define VERSION "<><><><><>   CP/M Large String Space Version   <><><><><>"
#:#define AUTHOR  "<><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>"
#:#define HCK     "<><><> Hacked for IA32/Linux by Evgueniy Vitchev <><><><>"
#:#define LINE    "<><><><><><><><><><><><><><>X<><><><><><><><><><><><><><>"
#:#define IDNT    "Small C"
#:/*#asm
#:  DB  'SMALL-C COMPILER V.1.2 DOS--CP/M CROSS COMPILER',0
#:  #endasm*/
#:/*  Define system dependent parameters  */
#:/*  Stand-alone definitions      */
#:/* INCLUDE THE LIBRARY TO COMPILE THE COMPILER (RDK) */
#:/* #include smallc.lib */ /* small-c library included in source now */
#:/* IN DOS USE THE SMALL-C OBJ LIBRARY RATHER THAN IN-LINE ASSEMBLER */
#:#define NULL 0
#:#define EOL 10 /* was 13 */
#:/*  UNIX definitions (if not stand-alone)  */
#:/* #include "stdio.h"  /* was <stdio.h> */
#:/* #define EOL 10  */
#:/*  Define the symbol table parameters  */
#:#define  SYMSIZ  14
#:#define  SYMTBSZ  5040
#:#define NUMGLBS 300
#:#define  STARTGLB SYMTAB
#:#define  ENDGLB  STARTGLB+NUMGLBS*SYMSIZ
#:#define  STARTLOC ENDGLB+SYMSIZ
#:#define  ENDLOC  SYMTAB+SYMTBSZ-SYMSIZ
#:/*  Define symbol table entry format  */
#:#define  NAME  0
#:#define  IDENT  9
#:#define  TYPE  10
#:#define  STORAGE  11
#:#define  OFFSET  12
#:/*  System wide NAME size (for symbols)  */
#:#define  NAMESIZE 9
#:#define NAMEMAX  8
#:/*  Define possible entries for "IDENT"  */
#:#define  VARIABLE 1
#:#define  ARRAY  2
#:#define  POINTER  3
#:#define  FUNCTION 4
#:#define  STRUCT   5
#:/*  Define possible entries for "TYPE"  */
#:#define  CCHAR   1
#:#define  CINT    2
#:#define  CSTRUCT 3
#:/*  Define possible entries for "STORAGE"  */
#:#define  STATIK  1
#:#define  STKLOC  2
#:/*  Define the "while" statement queue  */
#:#define  WQTABSZ  300
#:#define  WQSIZ  4
#:#define  WQMAX  wq+WQTABSZ-WQSIZ
#:/*  Define entry OFFSETs in while queue  */
#:#define  WQSYM  0
#:#define  WQSP  1
#:#define  WQLOOP  2
#:#define  WQLAB  3
#:/*  Define the literal pool      */
#:#define  LITABSZ  8000
#:#define  LITMAX  LITABSZ-1
#:/*  Define the input line      */
#:#define  LINESIZE 80
#:#define  LINEMAX  LINESIZE-1
#:#define  MPMAX  LINEMAX
#:/*  Define the macro (define) pool    */
#:#define  MACQSIZE 3000
#:#define  MACMAX  MACQSIZE-1
#:/*  Define statement TYPEs (tokens)    */
#:#define  STIF  1
#:#define  STWHILE  2
#:#define  STRETURN 3
#:#define  STBREAK  4
#:#define  STCONT  5
#:#define  STASM  6
#:#define  STEXP  7
#:#define  STFOR   9
#:#define  STDO    10
#:/* Define how to carve up a NAME too long for the assembler */
#:#define ASMPREF  7
#:#define ASMSUFF  7
#:/*Added by E.V.*/
#:#define LITSTKSZ 5000
#:#define LITSTKNUM 10
#:int tolitstk;
#:char litstk[LITSTKSZ];
#:char litstk2[LITSTKSZ];
#:int litstklens[LITSTKNUM];
#:int litstkptrs[LITSTKNUM];/*0 is reserved for the file output!*/
#:putlitstk(c)
	.text
	.align 16
.globl putlitst
	.TYPE	putlitst,@function
putlitst:
#:   char c;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  if(litstkptrs[tolitstk]+litstklens[tolitstk]>=LITSTKSZ-1)
	movl 	$litstkpt, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $5000, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc2
#:  {error("too large code from FUNCTION arguments");return 0;}
	movl $cc1+0, %eax
	pushl %eax
	call error
	popl %edx
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  /*litstk[litstkptrs[tolitstk]+litstklens[tolitstk]++]=c;*/
#:  litstk[litstkptrs[tolitstk]+litstklens[tolitstk]]=c;
cc2:
	movl 	$litstk, %eax
	pushl %eax
	movl 	$litstkpt, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  litstklens[tolitstk]=litstklens[tolitstk]+1;
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:  return c;
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:getlitstk()
	.text
	.align 16
.globl getlitst
	.TYPE	getlitst,@function
getlitst:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  if(tolitstk>=LITSTKNUM-1)
	movl tolitstk, %eax
	pushl %eax
	movl $10, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc3
#:  {error("too many FUNCTION arguments");return 0;}
	movl $cc1+39, %eax
	pushl %eax
	call error
	popl %edx
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  tolitstk++;
cc3:
	movl tolitstk, %eax
	incl %eax
	movl %eax, tolitstk
	decl %eax
#:  litstklens[tolitstk]=0;
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  litstkptrs[tolitstk]=litstkptrs[tolitstk-1]+litstklens[tolitstk-1];
	movl 	$litstkpt, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl 	$litstkpt, %eax
	pushl %eax
	movl tolitstk, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:  return tolitstk;
	movl tolitstk, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:dumpltstk(tl)
	.text
	.align 16
.globl dumpltst
	.TYPE	dumpltst,@function
dumpltst:
#:   int tl;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int i,p;
	pushl %edx
	pushl %edx
#:  char*q;
	pushl %edx
#:  q=litstk2;
	leal	-12(%ebp), %eax
	pushl %eax
	movl 	$litstk2, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(tolitstk>=tl)
cc4:
	movl tolitstk, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc5
#:  {
#:    i=litstklens[tolitstk];
	leal	-4(%ebp), %eax
	pushl %eax
	movl 	$litstkle, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:    p=litstkptrs[tolitstk];
	leal	-8(%ebp), %eax
	pushl %eax
	movl 	$litstkpt, %eax
	pushl %eax
	movl tolitstk, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:    while(i--)
cc6:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	decl %eax
	popl %edx
	movl %eax, (%edx)
	incl %eax
	testl %eax, %eax
	je	cc7
#:    {
#:      /*printf("litstk[p]=%c,%d\n",litstk[p],litstk[p]);*/
#:      *q++=litstk[p++];
	leal	-12(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	pushl %eax
	movl 	$litstk, %eax
	pushl %eax
	leal	-8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:      /*outbyte1(litstk[p++]);*/
#:    }
	jmp cc6
cc7:
#:    tolitstk--;
	movl tolitstk, %eax
	decl %eax
	movl %eax, tolitstk
	incl %eax
#:  }
	jmp cc4
cc5:
#:  /*printf("tolitstk=%d\n",tolitstk);*/
#:  p=q;
	leal	-8(%ebp), %eax
	pushl %eax
	leal	-12(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:  q=litstk2;
	leal	-12(%ebp), %eax
	pushl %eax
	movl 	$litstk2, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(q<p)
cc8:
	leal	-12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	cmpl	%eax, %edx
	setb	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc9
#:  {
#:    /*printf("*q=%c,%d\n",*q,*q);*/
#:    outbyte(*q);
	leal	-12(%ebp), %eax
	movl (%eax), %eax
	movsbl (%eax),%eax
	pushl %eax
	call outbyte
	popl %edx
#:    q++;
	leal	-12(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
#:  }
	jmp cc8
cc9:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*End- Added by E.V.*/
#:/*  Now reserve some STORAGE words    */
#:char  SYMTAB[SYMTBSZ];  /* symbol table */
#:char  *glbptr,*locptr;    /* ptrs to next entries */
#:int  wq[WQTABSZ];    /* while queue */
#:int  *wqptr;      /* ptr to next entry */
#:char  litq[LITABSZ];    /* literal pool */
#:int  litptr;      /* ptr to next entry */
#:char  macq[MACQSIZE];    /* macro string buffer */
#:int  macptr;      /* and its index */
#:char  line[LINESIZE];    /* parsing buffer */
#:char  mline[LINESIZE];  /* temp macro buffer */
#:int  lptr,mptr;    /* ptrs into each */
#:int field_offset; /* field offset in struct */
#:/*  Misc STORAGE  */
#:int  nxtlab,    /* next avail label # */
#:  litlab,    /* label # assigned to literal pool */
#:  Zsp,    /* compiler relative stk ptr */
#:  argstk,    /* FUNCTION arg sp */
#:  field_offset,
#:field_of
#:  argtop,/*added by E.V.*/
#:  ncmp,    /* # open compound statements */
#:  errcnt,    /* # errors in compilation */
#:  errstop,  /* stop on error      gtf 7/17/80 */
#:  eof,    /* set non-zero on final input eof */
#:  input,    /* iob # for input file */
#:  output,    /* iob # for output file (if any) */
#:  input2,    /* iob # for "include" file */
#:  glbflag,  /* non-zero if internal globals */
#:  ctext,    /* non-zero to intermix c-source */
#:  cmode,    /* non-zero while parsing c-code */
#:      /* zero when passing assembly code */
#:  lastst,    /* last executed statement TYPE */
#:  mainflg,  /* output is to be first asm file  gtf 4/9/80 */
#:  saveout,  /* holds output ptr when diverted to console     */
#:      /*          gtf 7/16/80 */
#:  kandr,    /* Current function decl K&R style? */
#:  fnstart,  /* line# of start of current fn.  gtf 7/2/80 */
#:  lineno,    /* line# in current file    gtf 7/2/80 */
#:  infunc,    /* "inside FUNCTION" flag    gtf 7/2/80 */
#:  savestart,  /* copy of fnstart "  "    gtf 7/16/80 */
#:  saveline,  /* copy of lineno  "  "    gtf 7/16/80 */
#:  saveinfn;  /* copy of infunc  "  "    gtf 7/16/80 */
#:char   *currfn,    /* ptr to SYMTAB entry for current fn.  gtf 7/17/80 */
#:       *savecurr;  /* copy of currfn for #include    gtf 7/17/80 */
#:char  quote[2];  /* literal string for '"' */
#:char  *cptr;    /* work ptr to any char buffer */
#:int  *iptr;    /* work ptr to any int buffer */
#:/*  >>>>> start cc1 <<<<<<    */
#:/*          */
#:/*  Compiler begins execution here  */
#:/*          */
#:main( int argc, char *argv[]) {
	.text
	.align 16
.globl main
	.TYPE	main,@function
main:
	pushl %ebp
	movl %esp, %ebp
#:  glbptr=STARTGLB;  /* clear global symbols */
	movl 	$SYMTAB, %eax
	movl %eax, glbptr
#:  locptr=STARTLOC;  /* clear local symbols */
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  wqptr=wq;    /* clear while queue */
	movl 	$wq, %eax
	movl %eax, wqptr
#:  tolitstk=
#:  litstkptrs[0]=
	movl 	$litstkpt, %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
#:  litstklens[0]=
	movl 	$litstkle, %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
#:  macptr=    /* clear the macro pool */
#:  litptr=    /* clear literal pool */
#:    Zsp =    /* stack ptr (relative) */
#:  errcnt=    /* no errors */
#:  errstop=  /* keep going after an error    gtf 7/17/80 */
#:  eof=    /* not eof yet */
#:  input=    /* no input file */
#:  input2=    /* or include file */
#:  output=    /* no open units */
#:  saveout=  /* no diverted output */
#:  ncmp=    /* no open compound states */
#:  lastst=    /* no last statement yet */
#:  mainflg=  /* not first file to asm     gtf 4/9/80 */
#:  fnstart=  /* current "FUNCTION" started at line 0 gtf 7/2/80 */
#:  lineno=    /* no lines read from file    gtf 7/2/80 */
#:  infunc=    /* not in FUNCTION now      gtf 7/2/80 */
#:  quote[1]=
	movl 	$quote, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
#:  0;    /*  ...all set to zero.... */
	movl $0, %eax
	popl %edx
	movb %al, (%edx)
	movl %eax, infunc
	movl %eax, lineno
	movl %eax, fnstart
	movl %eax, mainflg
	movl %eax, lastst
	movl %eax, ncmp
	movl %eax, saveout
	movl %eax, output
	movl %eax, input2
	movl %eax, input
	movl %eax, eof
	movl %eax, errstop
	movl %eax, errcnt
	movl %eax, Zsp
	movl %eax, litptr
	movl %eax, macptr
	popl %edx
	movl %eax, (%edx)
	popl %edx
	movl %eax, (%edx)
	movl %eax, tolitstk
#:  quote[0]='"';    /* fake a quote literal */
	movl 	$quote, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $34, %eax
	popl %edx
	movb %al, (%edx)
#:  currfn=NULL;  /* no FUNCTION yet      gtf 7/2/80 */
	movl $0, %eax
	movl %eax, currfn
#:  cmode=1;  /* enable preprocessing */
	movl $1, %eax
	movl %eax, cmode
#:  /*        */
#:  /*  compiler body    */
#:  /*        */
#:  ask();      /* get user options */
	call ask
#:  openout();    /* get an output file */
	call openout
#:  openin();    /* and initial input file */
	call openin
#:  header();    /* intro code */
	call header
#:  parse();     /* process ALL input */
	call parse
#:  dumplits();    /* then dump literal pool */
	call dumplits
#:  dumpglbs();    /* and all static memory */
	call dumpglbs
#:  trailer();    /* follow-up code */
	call trailer
#:  closeout();    /* close the output (if any) */
	call closeout
#:  errorsummary();    /* summarize errors (on console!) */
	call errorsum
#:  return;      /* then exit to system */
	movl %ebp, %esp
	popl %ebp
	ret
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Abort compilation    */
#:/*    gtf 7/17/80    */
#:zabort()
	.text
	.align 16
.globl zabort
	.TYPE	zabort,@function
zabort:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  if(input2)
	movl input2, %eax
	testl %eax, %eax
	je	cc10
#:    endinclude();
	call endinclu
#:  if(input)
cc10:
	movl input, %eax
	testl %eax, %eax
	je	cc11
#:    fclose(input);
	movl input, %eax
	pushl %eax
	call fclose
	popl %edx
#:  closeout();
cc11:
	call closeout
#:  toconsole();
	call toconsol
#:  pl("Compilation aborted.");  nl();
	movl $cc1+67, %eax
	pushl %eax
	call pl
	popl %edx
	call nl
#:  exit(0);
	movl $0, %eax
	pushl %eax
	call exit
	popl %edx
#:/* end zabort */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Process all input text    */
#:/*          */
#:/* At this level, only static declarations, */
#:/*  defines, includes, and FUNCTION */
#:/*  definitions are legal...  */
#:parse()
	.text
	.align 16
.globl parse
	.TYPE	parse,@function
parse:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  while (eof==0)    /* do until no more input */
cc12:
	movl eof, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc13
#:    {
#:    if(amatch("char",4)){declglb(CCHAR);ns();}
	movl $4, %eax
	pushl %eax
	movl $cc1+88, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc14
	movl $1, %eax
	pushl %eax
	call declglb
	popl %edx
	call ns
#:    else if(amatch("int",3)){declglb(CINT);ns();}
	jmp cc15
cc14:
	movl $3, %eax
	pushl %eax
	movl $cc1+93, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc16
	movl $2, %eax
	pushl %eax
	call declglb
	popl %edx
	call ns
#:    else if(amatch("struct",6)){newstruct();}
	jmp cc17
cc16:
	movl $6, %eax
	pushl %eax
	movl $cc1+97, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc18
	call newstruc
#:    else if(match("#asm"))doasm();
	jmp cc19
cc18:
	movl $cc1+104, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc20
	call doasm
#:    else if(match("#include"))doinclude();
	jmp cc21
cc20:
	movl $cc1+109, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc22
	call doinclud
#:    else if(match("#define"))addmac();
	jmp cc23
cc22:
	movl $cc1+118, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc24
	call addmac
#:    else newfunc();
	jmp cc25
cc24:
	call newfunc
cc25:
cc23:
cc21:
cc19:
cc17:
cc15:
#:    blanks();  /* force eof if pending */
	call blanks
#:    }
	jmp cc12
cc13:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Dump the literal pool    */
#:/*          */
#:dumplits()
	.text
	.align 16
.globl dumplits
	.TYPE	dumplits,@function
dumplits:
#:  {int j,k;
	pushl %ebp
	movl %esp, %ebp
	pushl %edx
	pushl %edx
#:  if (litptr==0) return;  /* if nothing there, exit...*/
	movl litptr, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc26
	movl %ebp, %esp
	popl %ebp
	ret
#:  ot(".section");ot(".rodata");nl();
cc26:
	movl $cc1+126, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+135, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  printlabel(litlab);col();nl(); /* print literal label */
	movl litlab, %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  k=0;      /* init an index... */
	leal	-8(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while (k<litptr)  /*   to loop with */
cc27:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl litptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc28
#:    {defbyte();  /* pseudo-op to define byte */
	call defbyte
#:    j=10;    /* max bytes per line */
	leal	-4(%ebp), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	movl %eax, (%edx)
#:    while(j--)
cc29:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	decl %eax
	popl %edx
	movl %eax, (%edx)
	incl %eax
	testl %eax, %eax
	je	cc30
#:      {outdec((litq[k++]&127));
	movl 	$litq, %eax
	pushl %eax
	leal	-8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
	call outdec
	popl %edx
#:      if ((j==0) | (k>=litptr))
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl litptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc31
#:        {nl();    /* need <cr> */
	call nl
#:        break;
	jmp cc30
#:        }
#:      outbyte(',');  /* separate bytes */
cc31:
	movl $44, %eax
	pushl %eax
	call outbyte
	popl %edx
#:      }
	jmp cc29
cc30:
#:    }
	jmp cc27
cc28:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Dump all static VARIABLEs  */
#:/*          */
#:dumpglbs()
	.text
	.align 16
.globl dumpglbs
	.TYPE	dumpglbs,@function
dumpglbs:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  int j;
	pushl %edx
#:  if(glbflag==0)return;  /* don't if user said no */
	movl glbflag, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc32
	movl %ebp, %esp
	popl %ebp
	ret
#:  cptr=STARTGLB;
cc32:
	movl 	$SYMTAB, %eax
	movl %eax, cptr
#:  while(cptr<glbptr)
cc33:
	movl cptr, %eax
	pushl %eax
	movl glbptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setb	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc34
#:    {
#:     if(cptr[IDENT]==STRUCT ) {
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $5, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc35
#:       cptr=cptr+SYMSIZ;
	movl cptr, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, cptr
#:     } else if(cptr[IDENT]!=FUNCTION)
	jmp cc36
cc35:
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc37
#:      /* do if anything but FUNCTION */
#:      {/*col();*/
#:        /* output NAME as label... */
#:      defstorage();outname(cptr);  /* define STORAGE */
	call defstora
	movl cptr, %eax
	pushl %eax
	call outname
	popl %edx
#:      comma();
	call comma
#:      j=((cptr[OFFSET]&255)+
	leal	-4(%ebp), %eax
	pushl %eax
	movl cptr, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $255, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
#:        ((cptr[OFFSET+1]&255)<<8));
	movl cptr, %eax
	pushl %eax
	movl $12, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $255, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
	movl $8, %eax
	popl %edx
	movl %eax, %ecx
	movl %edx, %eax
	sall %cl, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:          /* calc # bytes */
#:      if((cptr[TYPE]==CINT)|
	movl cptr, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:        (cptr[IDENT]==POINTER))
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc38
#:        j=j*4;/*modified by E.V.*/
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	imull %edx
	popl %edx
	movl %eax, (%edx)
#:      outdec(j);  /* need that many */
cc38:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outdec
	popl %edx
#:      if(cptr[TYPE]==CINT|cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc39
#:        outasm(",4");
	movl $cc1+143, %eax
	pushl %eax
	call outasm
	popl %edx
#:      else
	jmp cc40
cc39:
#:        outasm(",1");
	movl $cc1+146, %eax
	pushl %eax
	call outasm
	popl %edx
cc40:
#:      nl();
	call nl
#:        cptr=cptr+SYMSIZ;
	movl cptr, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, cptr
#:      } else {
	jmp cc41
cc37:
#:        cptr=cptr+SYMSIZ;
	movl cptr, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, cptr
#:      }
cc41:
cc36:
#:    }
	jmp cc33
cc34:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Report errors for user    */
#:/*          */
#:errorsummary()
	.text
	.align 16
.globl errorsum
	.TYPE	errorsum,@function
errorsum:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  /* see if anything left hanging... */
#:  if (ncmp) error("missing closing bracket");
	movl ncmp, %eax
	testl %eax, %eax
	je	cc42
	movl $cc1+149, %eax
	pushl %eax
	call error
	popl %edx
#:    /* open compound statement ... */
#:  nl();
cc42:
	call nl
#:  outstr("There were ");
	movl $cc1+173, %eax
	pushl %eax
	call outstr
	popl %edx
#:  outdec(errcnt);  /* total # errors */
	movl errcnt, %eax
	pushl %eax
	call outdec
	popl %edx
#:  outstr(" errors in compilation.");
	movl $cc1+185, %eax
	pushl %eax
	call outstr
	popl %edx
#:  nl();
	call nl
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Get options from user    */
#:/*          */
#:ask() {
	.text
	.align 16
.globl ask
	.TYPE	ask,@function
ask:
	pushl %ebp
	movl %esp, %ebp
#:  int k,num[1];
	pushl %edx
	pushl %edx
#:  kill();      /* clear input line */
	call kill
#:  outbyte(12);    /* clear the screen */
	movl $12, %eax
	pushl %eax
	call outbyte
	popl %edx
#:  nl();nl();    /* print banner */
	call nl
	call nl
#:  pl(LINE);
	movl $cc1+209, %eax
	pushl %eax
	call pl
	popl %edx
#:  pl(BANNER);
	movl $cc1+267, %eax
	pushl %eax
	call pl
	popl %edx
#:  pl(AUTHOR);
	movl $cc1+325, %eax
	pushl %eax
	call pl
	popl %edx
#:  /*pl(VERSION);*/
#:  pl(HCK);
	movl $cc1+383, %eax
	pushl %eax
	call pl
	popl %edx
#:  pl(LINE);
	movl $cc1+441, %eax
	pushl %eax
	call pl
	popl %edx
#:  nl();nl();
	call nl
	call nl
#:  ctext=1;    /* assume yes */
	movl $1, %eax
	movl %eax, ctext
#:  glbflag=1;  /* define globals */
	movl $1, %eax
	movl %eax, glbflag
#:  mainflg=1;  /* first file to assembler */
	movl $1, %eax
	movl %eax, mainflg
#:  nxtlab =0;  /* start numbers at lowest possible */
	movl $0, %eax
	movl %eax, nxtlab
#:  errstop=0;
	movl $0, %eax
	movl %eax, errstop
#:  litlab=getlabel();  /* first label=literal pool */ 
	call getlabel
	movl %eax, litlab
#:  kill();      /* erase line */
	call kill
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Get output filename    */
#:/*          */
#:openout()
	.text
	.align 16
.globl openout
	.TYPE	openout,@function
openout:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  kill();      /* erase line */
	call kill
#:  output=0;    /* start with none */
	movl $0, %eax
	movl %eax, output
#:  pl("Output filename? "); /* ask...*/
	movl $cc1+499, %eax
	pushl %eax
	call pl
	popl %edx
#:  gets(line);  /* get a filename */
	movl 	$line, %eax
	pushl %eax
	call gets
	popl %edx
#:  if(ch()==0)return;  /* none given... */
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc43
	movl %ebp, %esp
	popl %ebp
	ret
#:  if((output=fopen(line,"w"))==NULL) /* if given, open */
cc43:
	movl $cc1+517, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	call fopen
	addl $8, %esp
	movl %eax, output
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc44
#:    {output=0;  /* can't open */
	movl $0, %eax
	movl %eax, output
#:    error("Open failure!");
	movl $cc1+519, %eax
	pushl %eax
	call error
	popl %edx
#:    }
#:  kill();      /* erase line */
cc44:
	call kill
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Get (next) input file    */
#:/*          */
#:openin()
	.text
	.align 16
.globl openin
	.TYPE	openin,@function
openin:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  input=0;    /* none to start with */
	movl $0, %eax
	movl %eax, input
#:  while(input==0){  /* any above 1 allowed */
cc45:
	movl input, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc46
#:    kill();    /* clear line */
	call kill
#:    if(eof)break;  /* if user said none */
	movl eof, %eax
	testl %eax, %eax
	je	cc47
	jmp cc46
#:    pl("Input filename? ");
cc47:
	movl $cc1+533, %eax
	pushl %eax
	call pl
	popl %edx
#:    gets(line);  /* get a NAME */
	movl 	$line, %eax
	pushl %eax
	call gets
	popl %edx
#:    if(ch()==0)
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc48
#:      {eof=1;break;} /* none given... */
	movl $1, %eax
	movl %eax, eof
	jmp cc46
#:    if((input=fopen(line,"r"))!=NULL)
cc48:
	movl $cc1+550, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	call fopen
	addl $8, %esp
	movl %eax, input
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc49
#:      newfile();      /* gtf 7/16/80 */
	call newfile
#:    else {  input=0;  /* can't open it */
	jmp cc50
cc49:
	movl $0, %eax
	movl %eax, input
#:      pl("Open failure");
	movl $cc1+552, %eax
	pushl %eax
	call pl
	popl %edx
#:      }
cc50:
#:    }
	jmp cc45
cc46:
#:  kill();    /* erase line */
	call kill
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Reset line count, etc.    */
#:/*      gtf 7/16/80  */
#:newfile()
	.text
	.align 16
.globl newfile
	.TYPE	newfile,@function
newfile:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  lineno  = 0;  /* no lines read */
	movl $0, %eax
	movl %eax, lineno
#:  fnstart = 0;  /* no fn. start yet. */
	movl $0, %eax
	movl %eax, fnstart
#:  currfn  = NULL;  /* because no fn. yet */
	movl $0, %eax
	movl %eax, currfn
#:  infunc  = 0;  /* therefore not in fn. */
	movl $0, %eax
	movl %eax, infunc
#:/* end newfile */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Open an include file    */
#:/*          */
#:doinclude()
	.text
	.align 16
.globl doinclud
	.TYPE	doinclud,@function
doinclud:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  blanks();  /* skip over to NAME */
	call blanks
#:  toconsole();          /* gtf 7/16/80 */
	call toconsol
#:  outstr("#include "); outstr(line+lptr); nl();
	movl $cc1+565, %eax
	pushl %eax
	call outstr
	popl %edx
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call outstr
	popl %edx
	call nl
#:  tofile();
	call tofile
#:  if(input2)          /* gtf 7/16/80 */
	movl input2, %eax
	testl %eax, %eax
	je	cc51
#:    error("Cannot nest include files");
	movl $cc1+575, %eax
	pushl %eax
	call error
	popl %edx
#:  else if((input2=fopen(line+lptr,"r"))==NULL)
	jmp cc52
cc51:
	movl $cc1+601, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call fopen
	addl $8, %esp
	movl %eax, input2
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc53
#:    {input2=0;
	movl $0, %eax
	movl %eax, input2
#:    error("Open failure on include file");
	movl $cc1+603, %eax
	pushl %eax
	call error
	popl %edx
#:    }
#:  else {  saveline = lineno;
	jmp cc54
cc53:
	movl lineno, %eax
	movl %eax, saveline
#:    savecurr = currfn;
	movl currfn, %eax
	movl %eax, savecurr
#:    saveinfn = infunc;
	movl infunc, %eax
	movl %eax, saveinfn
#:    savestart= fnstart;
	movl fnstart, %eax
	movl %eax, savestar
#:    newfile();
	call newfile
#:    }
cc54:
cc52:
#:  kill();    /* clear rest of line */
	call kill
#:      /* so next read will come from */
#:      /* new file (if open */
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Close an include file    */
#:/*      gtf 7/16/80  */
#:endinclude()
	.text
	.align 16
.globl endinclu
	.TYPE	endinclu,@function
endinclu:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  toconsole();
	call toconsol
#:  outstr("#end include"); nl();
	movl $cc1+632, %eax
	pushl %eax
	call outstr
	popl %edx
	call nl
#:  tofile();
	call tofile
#:  input2  = 0;
	movl $0, %eax
	movl %eax, input2
#:  lineno  = saveline;
	movl saveline, %eax
	movl %eax, lineno
#:  currfn  = savecurr;
	movl savecurr, %eax
	movl %eax, currfn
#:  infunc  = saveinfn;
	movl saveinfn, %eax
	movl %eax, infunc
#:  fnstart = savestart;
	movl savestar, %eax
	movl %eax, fnstart
#:/* end endinclude */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Close the output file    */
#:/*          */
#:closeout()
	.text
	.align 16
.globl closeout
	.TYPE	closeout,@function
closeout:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  tofile();  /* if diverted, return to file */
	call tofile
#:  if(output)fclose(output); /* if open, close it */
	movl output, %eax
	testl %eax, %eax
	je	cc55
	movl output, %eax
	pushl %eax
	call fclose
	popl %edx
#:  output=0;    /* mark as closed */
cc55:
	movl $0, %eax
	movl %eax, output
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Declare a static VARIABLE  */
#:/*    (i.e. define for use)    */
#:/*          */
#:/* makes an entry in the symbol table so subsequent */
#:/*  references can call symbol by NAME  */
#:declglb(typ)    /* typ is CCHAR or CINT */
	.text
	.align 16
.globl declglb
	.TYPE	declglb,@function
declglb:
#:  int typ;
	pushl %ebp
	movl %esp, %ebp
#:{  int k,j;char sname[NAMESIZE];
	pushl %edx
	pushl %edx
	subl $12, %esp
#:  while(1)
cc56:
	movl $1, %eax
	testl %eax, %eax
	je	cc57
#:    {while(1)
cc58:
	movl $1, %eax
	testl %eax, %eax
	je	cc59
#:      {if(endst())return;  /* do line */
	call endst
	testl %eax, %eax
	je	cc60
	movl %ebp, %esp
	popl %ebp
	ret
#:      k=1;    /* assume 1 element */
cc60:
	leal	-4(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
#:      if(match("*"))  /* POINTER ? */
	movl $cc1+645, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc61
#:        j=POINTER;  /* yes */
	leal	-8(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:        else j=VARIABLE; /* no */
	jmp cc62
cc61:
	leal	-8(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
cc62:
#:       if (symname(sname)==0) /* NAME ok? */
	leal	-20(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc63
#:        illname(); /* no... */
	call illname
#:      if(findglb(sname)) /* already there? */
cc63:
	leal	-20(%ebp), %eax
	pushl %eax
	call findglb
	popl %edx
	testl %eax, %eax
	je	cc64
#:        multidef(sname);
	leal	-20(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:      if (match("["))    /* ARRAY? */
cc64:
	movl $cc1+647, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc65
#:        {k=needsub();  /* get size */
	leal	-4(%ebp), %eax
	pushl %eax
	call needsub
	popl %edx
	movl %eax, (%edx)
#:        if(k)j=ARRAY;  /* !0=ARRAY */
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc66
	leal	-8(%ebp), %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	movl %eax, (%edx)
#:        else j=POINTER; /* 0=ptr */
	jmp cc67
cc66:
	leal	-8(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
cc67:
#:        }
#:      addglb(sname,j,typ,k); /* add symbol */
cc65:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-20(%ebp), %eax
	pushl %eax
	call addglb
	addl $16, %esp
#:      break;
	jmp cc59
#:      }
	jmp cc58
cc59:
#:    if (match(",")==0) return; /* more? */
	movl $cc1+649, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc68
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
cc68:
	jmp cc56
cc57:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Declare local VARIABLEs    */
#:/*  (i.e. define for use)    */
#:/*          */
#:/* works just like "declglb" but modifies machine stack */
#:/*  and adds symbol table entry with appropriate */
#:/*  stack OFFSET to find it again      */
#:declloc(typ)    /* typ is CCHAR or CINT */
	.text
	.align 16
.globl declloc
	.TYPE	declloc,@function
declloc:
#:  int typ;
	pushl %ebp
	movl %esp, %ebp
#:  {
#:  int k,j;char sname[NAMESIZE];
	pushl %edx
	pushl %edx
	subl $12, %esp
#:  while(1)
cc69:
	movl $1, %eax
	testl %eax, %eax
	je	cc70
#:    {while(1)
cc71:
	movl $1, %eax
	testl %eax, %eax
	je	cc72
#:      {if(endst())return;
	call endst
	testl %eax, %eax
	je	cc73
	movl %ebp, %esp
	popl %ebp
	ret
#:      if(match("*"))
cc73:
	movl $cc1+651, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc74
#:        j=POINTER;
	leal	-8(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:        else j=VARIABLE;
	jmp cc75
cc74:
	leal	-8(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
cc75:
#:      if (symname(sname)==0)
	leal	-20(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc76
#:        illname();
	call illname
#:      if(findloc(sname))
cc76:
	leal	-20(%ebp), %eax
	pushl %eax
	call findloc
	popl %edx
	testl %eax, %eax
	je	cc77
#:        multidef(sname);
	leal	-20(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:      if (match("["))
cc77:
	movl $cc1+653, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc78
#:        {k=needsub();
	leal	-4(%ebp), %eax
	pushl %eax
	call needsub
	popl %edx
	movl %eax, (%edx)
#:        if(k)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc79
#:          {j=ARRAY;
	leal	-8(%ebp), %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	movl %eax, (%edx)
#:          if(typ==CINT)k=4*k;/*modifyed by E.V.*/
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc80
	leal	-4(%ebp), %eax
	pushl %eax
	movl $4, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	imull %edx
	popl %edx
	movl %eax, (%edx)
#:          }
cc80:
#:        else
	jmp cc81
cc79:
#:          {j=POINTER;
	leal	-8(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:          k=4;/*modified by E.V.*/
	leal	-4(%ebp), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	movl %eax, (%edx)
#:          }
cc81:
#:        }
#:      else
	jmp cc82
cc78:
#:        if((typ==CCHAR)
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
#:          &(j!=POINTER))
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc83
#:          k=1;else k=4;/*modified by E.V.*/
	leal	-4(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
	jmp cc84
cc83:
	leal	-4(%ebp), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	movl %eax, (%edx)
cc84:
cc82:
#:      if(k&3)k=k+4-(k&3);/*align, by E.V.*/
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc85
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:      /* change machine stack */
#:      Zsp=modstk(Zsp-k);
cc85:
	movl Zsp, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:      addloc(sname,j,typ,Zsp);
	movl Zsp, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-20(%ebp), %eax
	pushl %eax
	call addloc
	addl $16, %esp
#:      break;
	jmp cc72
#:      }
	jmp cc71
cc72:
#:    if (match(",")==0) return;
	movl $cc1+655, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc86
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
cc86:
	jmp cc69
cc70:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*  >>>>>> start of cc2 <<<<<<<<  */
#:/*          */
#:/*  Get required ARRAY size    */
#:/*          */
#:/* invoked when declared VARIABLE is followed by "[" */
#:/*  this routine makes subscript the absolute */
#:/*  size of the ARRAY. */
#:needsub()
	.text
	.align 16
.globl needsub
	.TYPE	needsub,@function
needsub:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  int num[1];
	pushl %edx
#:  if(match("]"))return 0;  /* null size */
	movl $cc1+657, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc87
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if (number(num)==0)  /* go after a number */
cc87:
	leal	-4(%ebp), %eax
	pushl %eax
	call number
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc88
#:    {error("must be constant");  /* it isn't */
	movl $cc1+659, %eax
	pushl %eax
	call error
	popl %edx
#:    num[0]=1;    /* so force one */
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
#:    }
#:  if (num[0]<0)
cc88:
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc89
#:    {error("negative size illegal");
	movl $cc1+676, %eax
	pushl %eax
	call error
	popl %edx
#:    num[0]=(-num[0]);
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	negl %eax
	popl %edx
	movl %eax, (%edx)
#:    }
#:  needbrack("]");    /* force single dimension */
cc89:
	movl $cc1+698, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  return num[0];    /* and return size */
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:newstruct() {
	.text
	.align 16
.globl newstruc
	.TYPE	newstruc,@function
newstruc:
	pushl %ebp
	movl %esp, %ebp
#:  char n[NAMESIZE];  /* ptr => currfn,  gtf 7/16/80 */
	subl $12, %esp
#:  char m[NAMESIZE];  /* ptr => currfn,  gtf 7/16/80 */
	subl $12, %esp
#:  int  tidx;
	pushl %edx
#:  if (symname(n)==0) {
	leal	-12(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc90
#:    error("illegal STRUCT or declaration");
	movl $cc1+700, %eax
	pushl %eax
	call error
	popl %edx
#:    kill();  /* invalidate line */
	call kill
#:    return;
	movl %ebp, %esp
	popl %ebp
	ret
#:  }
#:  fnstart=lineno;    /* remember where fn began  gtf 7/2/80 */
cc90:
	movl lineno, %eax
	movl %eax, fnstart
#:  infunc=1;    /* note, in FUNCTION now.  gtf 7/16/80 */
	movl $1, %eax
	movl %eax, infunc
#:  /* already in symbol table ? */
#:  if(currfn=findglb(n))  {
	leal	-12(%ebp), %eax
	pushl %eax
	call findglb
	popl %edx
	movl %eax, currfn
	testl %eax, %eax
	je	cc91
#:    /* Declaration ?? */
#:    if( match("{")  == 0 ) {
	movl $cc1+730, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc92
#:      symname(m);
	leal	-24(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
#:      addglb(m, CSTRUCT, CINT, STRUCT );
	movl $5, %eax
	pushl %eax
	movl $2, %eax
	pushl %eax
	movl $3, %eax
	pushl %eax
	leal	-24(%ebp), %eax
	pushl %eax
	call addglb
	addl $16, %esp
#:      nl();
	call nl
#:      return;
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:    
#:    if(currfn[IDENT]!=FUNCTION)multidef(n);
cc92:
	movl currfn, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc93
	leal	-12(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:      /* already VARIABLE by that NAME */
#:    else if(currfn[OFFSET]==FUNCTION)multidef(n);
	jmp cc94
cc93:
	movl currfn, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc95
	leal	-12(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:      /* already FUNCTION by that NAME */
#:    else currfn[OFFSET]=FUNCTION;
	jmp cc96
cc95:
	movl currfn, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	movb %al, (%edx)
cc96:
cc94:
#:      /* otherwise we have what was earlier*/
#:      /*  assumed to be a FUNCTION */
#:  } else {
	jmp cc97
cc91:
#:    /* if not in table, define as a FUNCTION now */
#:    currfn=addglb(n,STRUCT,CINT,STRUCT);
	movl $5, %eax
	pushl %eax
	movl $2, %eax
	pushl %eax
	movl $5, %eax
	pushl %eax
	leal	-12(%ebp), %eax
	pushl %eax
	call addglb
	addl $16, %esp
	movl %eax, currfn
#:  }
cc97:
#:  toconsole();          /* gtf 7/16/80 */
	call toconsol
#:  /*outstr("====== "); outstr(currfn+NAME); outstr("()"); nl();*/
#:  tofile();
	call tofile
#:  /* we had better see open paren for args... */
#:  if(match("{")==0)error("missing open { ");
	movl $cc1+732, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc98
	movl $cc1+734, %eax
	pushl %eax
	call error
	popl %edx
#:  ol(".text");
cc98:
	movl $cc1+750, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol(".align 16");
	movl $cc1+756, %eax
	pushl %eax
	call ol
	popl %edx
#:  outasm(".globl ");outname(n);nl();
	movl $cc1+766, %eax
	pushl %eax
	call outasm
	popl %edx
	leal	-12(%ebp), %eax
	pushl %eax
	call outname
	popl %edx
	call nl
#:  ot(".TYPE");tab();outname(n);outasm(",@object");nl();
	movl $cc1+774, %eax
	pushl %eax
	call ot
	popl %edx
	call tab
	leal	-12(%ebp), %eax
	pushl %eax
	call outname
	popl %edx
	movl $cc1+780, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:  outname(n);col();nl();  /* print FUNCTION NAME */
	leal	-12(%ebp), %eax
	pushl %eax
	call outname
	popl %edx
	call col
	call nl
#:  argstk=0;    /* init arg count */
	movl $0, %eax
	movl %eax, argstk
#:  locptr=STARTLOC;  /* "clear" local symbol table*/
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  Zsp=0;      /* preset stack ptr */
	movl $0, %eax
	movl %eax, Zsp
#: 
#:  /* Parse twice, once for arg count so second pass we can pass proper 
#:     stack offsets in emitted asm code - SA */ 
#:  tidx=lptr;
	leal	-28(%ebp), %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  
#:  /* Assume K&R style  - SA */
#:  kandr = 1;
	movl $1, %eax
	movl %eax, kandr
#:  /* Record stack depth based on # of parameters */
#:  argtop = argstk;
	movl argstk, %eax
	movl %eax, argtop
#:  /* Refill buffer */
#:  blanks();
	call blanks
#:  /* "clear" local symbol table*/ 
#:  locptr=STARTLOC; 
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  Zsp=0;      /* preset stack ptr */
	movl $0, %eax
	movl %eax, Zsp
#:  argtop=argstk;
	movl argstk, %eax
	movl %eax, argtop
#:  while( match("}") == 0 )  {
cc99:
	movl $cc1+789, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc100
#:    /* now let user declare what TYPEs of things */
#:    field_offset += 4;
	movl field_of, %eax
	pushl %eax
	movl 0,, %eax
	popl %edx
	addl %edx, %eax
	movl $4, %eax
#:    argstk += 4;
	movl argstk, %eax
	pushl %eax
	movl 0,, %eax
	popl %edx
	addl %edx, %eax
	movl $4, %eax
#:    if(amatch("char",4)){getfield(CCHAR, currfn, field_offset);ns();}
	movl $4, %eax
	pushl %eax
	movl $cc1+791, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc101
	movl field_of, %eax
	pushl %eax
	movl currfn, %eax
	pushl %eax
	movl $1, %eax
	pushl %eax
	call getfield
	addl $12, %esp
	call ns
#:    else if(amatch("int",3)){getfield(CINT, currfn, field_offset);ns();}
	jmp cc102
cc101:
	movl $3, %eax
	pushl %eax
	movl $cc1+796, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc103
	movl field_of, %eax
	pushl %eax
	movl currfn, %eax
	pushl %eax
	movl $2, %eax
	pushl %eax
	call getfield
	addl $12, %esp
	call ns
#:    else{error("wrong number args");break;}
	jmp cc104
cc103:
	movl $cc1+800, %eax
	pushl %eax
	call error
	popl %edx
	jmp cc100
cc104:
cc102:
#:  }
	jmp cc99
cc100:
#:  ns();
	call ns
#:  ol("pushl %ebp");
	movl $cc1+818, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movl %esp, %ebp");
	movl $cc1+829, %eax
	pushl %eax
	call ol
	popl %edx
#:  Zsp=0;      /* reset stack ptr again */
	movl $0, %eax
	movl %eax, Zsp
#:  locptr=STARTLOC;  /* deallocate all locals */
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  infunc=0;    /* not in fn. any more    gtf 7/2/80 */
	movl $0, %eax
	movl %eax, infunc
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Begin a FUNCTION    */
#:/*          */
#:/* Called from "parse" this routine tries to make a FUNCTION */
#:/*  out of what follows.  */
#:newfunc() {
	.text
	.align 16
.globl newfunc
	.TYPE	newfunc,@function
newfunc:
	pushl %ebp
	movl %esp, %ebp
#:  char n[NAMESIZE];  /* ptr => currfn,  gtf 7/16/80 */
	subl $12, %esp
#:  int  tidx;
	pushl %edx
#:  if (symname(n)==0) {
	leal	-12(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc105
#:    error("illegal FUNCTION or declaration");
	movl $cc1+845, %eax
	pushl %eax
	call error
	popl %edx
#:    kill();  /* invalidate line */
	call kill
#:    return;
	movl %ebp, %esp
	popl %ebp
	ret
#:  }
#:  fnstart=lineno;    /* remember where fn began  gtf 7/2/80 */
cc105:
	movl lineno, %eax
	movl %eax, fnstart
#:  infunc=1;    /* note, in FUNCTION now.  gtf 7/16/80 */
	movl $1, %eax
	movl %eax, infunc
#:  /* already in symbol table ? */
#:  if(currfn=findglb(n))  {
	leal	-12(%ebp), %eax
	pushl %eax
	call findglb
	popl %edx
	movl %eax, currfn
	testl %eax, %eax
	je	cc106
#:    if(currfn[IDENT]!=FUNCTION)multidef(n);
	movl currfn, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc107
	leal	-12(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:      /* already VARIABLE by that NAME */
#:    else if(currfn[OFFSET]==FUNCTION)multidef(n);
	jmp cc108
cc107:
	movl currfn, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc109
	leal	-12(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:      /* already FUNCTION by that NAME */
#:    else currfn[OFFSET]=FUNCTION;
	jmp cc110
cc109:
	movl currfn, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	movb %al, (%edx)
cc110:
cc108:
#:      /* otherwise we have what was earlier*/
#:      /*  assumed to be a FUNCTION */
#:  } else {
	jmp cc111
cc106:
#:    /* if not in table, define as a FUNCTION now */
#:    currfn=addglb(n,FUNCTION,CINT,FUNCTION);
	movl $4, %eax
	pushl %eax
	movl $2, %eax
	pushl %eax
	movl $4, %eax
	pushl %eax
	leal	-12(%ebp), %eax
	pushl %eax
	call addglb
	addl $16, %esp
	movl %eax, currfn
#:  }
cc111:
#:  toconsole();          /* gtf 7/16/80 */
	call toconsol
#:  /*outstr("====== "); outstr(currfn+NAME); outstr("()"); nl();*/
#:  tofile();
	call tofile
#:  /* we had better see open paren for args... */
#:  if(match("(")==0)error("missing open paren");
	movl $cc1+877, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc112
	movl $cc1+879, %eax
	pushl %eax
	call error
	popl %edx
#:  ol(".text");
cc112:
	movl $cc1+898, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol(".align 16");
	movl $cc1+904, %eax
	pushl %eax
	call ol
	popl %edx
#:  outasm(".globl ");outname(n);nl();
	movl $cc1+914, %eax
	pushl %eax
	call outasm
	popl %edx
	leal	-12(%ebp), %eax
	pushl %eax
	call outname
	popl %edx
	call nl
#:  ot(".TYPE");tab();outname(n);outasm(",@function");nl();
	movl $cc1+922, %eax
	pushl %eax
	call ot
	popl %edx
	call tab
	leal	-12(%ebp), %eax
	pushl %eax
	call outname
	popl %edx
	movl $cc1+928, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:  outname(n);col();nl();  /* print FUNCTION NAME */
	leal	-12(%ebp), %eax
	pushl %eax
	call outname
	popl %edx
	call col
	call nl
#:  argstk=0;    /* init arg count */
	movl $0, %eax
	movl %eax, argstk
#:  locptr=STARTLOC;  /* "clear" local symbol table*/
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  Zsp=0;      /* preset stack ptr */
	movl $0, %eax
	movl %eax, Zsp
#: 
#:  /* Parse twice, once for arg count so second pass we can pass proper 
#:     stack offsets in emitted asm code - SA */ 
#:  tidx=lptr;
	leal	-16(%ebp), %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  
#:  /* Assume K&R style  - SA */
#:  kandr = 1;
	movl $1, %eax
	movl %eax, kandr
#:  while( match(")" ) == 0 ) {
cc113:
	movl $cc1+939, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc114
#:    /* Found a type? we now treat this function as a non K&R style */
#:    if( match("int",3) ) { kandr = 0; }
	movl $3, %eax
	pushl %eax
	movl $cc1+941, %eax
	pushl %eax
	call match
	addl $8, %esp
	testl %eax, %eax
	je	cc115
	movl $0, %eax
	movl %eax, kandr
#:    else if( match("char", 4) ) { kandr = 0; }
	jmp cc116
cc115:
	movl $4, %eax
	pushl %eax
	movl $cc1+945, %eax
	pushl %eax
	call match
	addl $8, %esp
	testl %eax, %eax
	je	cc117
	movl $0, %eax
	movl %eax, kandr
#:    if( streq(line+lptr, ",") ) {
cc117:
cc116:
	movl $cc1+950, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	testl %eax, %eax
	je	cc118
#:      /* Still our goal is to find the number of arguments  */
#:      argstk = argstk + 4;
	movl argstk, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, argstk
#:    }
#:    lptr++;
cc118:
	movl lptr, %eax
	incl %eax
	movl %eax, lptr
	decl %eax
#:    if( argstk == 0 ) argstk = argstk + 4;
	movl argstk, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc119
	movl argstk, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, argstk
#:  }
cc119:
	jmp cc113
cc114:
#:  /* Record stack depth based on # of parameters */
#:  argtop = argstk;
	movl argstk, %eax
	movl %eax, argtop
#:  /* If we are not K&R re-parse the params, we needed an arg count for this 
#:     parse code to work however so we are doing it twice */
#:  if( !kandr ) {
	movl kandr, %eax
	testl %eax,%eax
	sete %al
	movzbl %al, %eax
	testl %eax, %eax
	je	cc120
#:      /* Reset lptr so we can reparse - SA */
#:      lptr=tidx;  
	leal	-16(%ebp), %eax
	movl (%eax), %eax
	movl %eax, lptr
#:      while(match(")")==0) {
cc121:
	movl $cc1+952, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc122
#:        if( amatch("int",3) ) {
	movl $3, %eax
	pushl %eax
	movl $cc1+954, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc123
#:          getarg(CINT);
	movl $2, %eax
	pushl %eax
	call getarg
	popl %edx
#:        } else if( amatch("char", 4) ) {
	jmp cc124
cc123:
	movl $4, %eax
	pushl %eax
	movl $cc1+958, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc125
#:          getarg(CINT);
	movl $2, %eax
	pushl %eax
	call getarg
	popl %edx
#:        } else if(streq(line+lptr,")")==0) {
	jmp cc126
cc125:
	movl $cc1+963, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc127
#:          if(match(",")==0) { 
	movl $cc1+965, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc128
#:            error("expected comma");
	movl $cc1+967, %eax
	pushl %eax
	call error
	popl %edx
#:            break;
	jmp cc122
#:          }
#:        }
cc128:
#:      }
cc127:
cc126:
cc124:
	jmp cc121
cc122:
#:  } else {
	jmp cc129
cc120:
#:      /* Refill buffer */
#:      blanks();
	call blanks
#:      /* We are K&R - parse arg name and types after the ) and before the { */
#:      locptr=STARTLOC;  /* "clear" local symbol table*/ 
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:      Zsp=0;      /* preset stack ptr */
	movl $0, %eax
	movl %eax, Zsp
#:      argtop=argstk;
	movl argstk, %eax
	movl %eax, argtop
#:      while(argstk)  {
cc130:
	movl argstk, %eax
	testl %eax, %eax
	je	cc131
#:        /* now let user declare what TYPEs of things */
#:        /*  those arguments were */
#:        if(amatch("char",4)){getarg(CCHAR);ns();}
	movl $4, %eax
	pushl %eax
	movl $cc1+982, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc132
	movl $1, %eax
	pushl %eax
	call getarg
	popl %edx
	call ns
#:        else if(amatch("int",3)){getarg(CINT);ns();}
	jmp cc133
cc132:
	movl $3, %eax
	pushl %eax
	movl $cc1+987, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc134
	movl $2, %eax
	pushl %eax
	call getarg
	popl %edx
	call ns
#:        else{error("wrong number args");break;}
	jmp cc135
cc134:
	movl $cc1+991, %eax
	pushl %eax
	call error
	popl %edx
	jmp cc131
cc135:
cc133:
#:      }
	jmp cc130
cc131:
#:  }
cc129:
#:  ol("pushl %ebp");
	movl $cc1+1009, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movl %esp, %ebp");
	movl $cc1+1020, %eax
	pushl %eax
	call ol
	popl %edx
#:  if(statement()!=STRETURN) /* do a statement, but if */
	call statemen
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc136
#:    ;
#:        /* it's a return, skip */
#:        /* cleaning up the stack */
#:  {/*modstk(0);*/
cc136:
#:    ol("movl %ebp, %esp");
	movl $cc1+1036, %eax
	pushl %eax
	call ol
	popl %edx
#:    ol("popl %ebp");
	movl $cc1+1052, %eax
	pushl %eax
	call ol
	popl %edx
#:    zret();
	call zret
#:    }
#:  Zsp=0;      /* reset stack ptr again */
	movl $0, %eax
	movl %eax, Zsp
#:  locptr=STARTLOC;  /* deallocate all locals */
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  infunc=0;    /* not in fn. any more    gtf 7/2/80 */
	movl $0, %eax
	movl %eax, infunc
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* T=Type, sidx=Struct poitner, Offset =offseti n struct */
#:getfield(t,sidx, offset) {
	.text
	.align 16
.globl getfield
	.TYPE	getfield,@function
getfield:
	pushl %ebp
	movl %esp, %ebp
#:  char n[NAMESIZE], c; int j;
	subl $12, %esp
	pushl %edx
	pushl %edx
#:  if(match("*"))j=POINTER;
	movl $cc1+1062, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc137
	leal	-20(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:  else j=VARIABLE;
	jmp cc138
cc137:
	leal	-20(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
cc138:
#:  if(symname(n)==0) illname();
	leal	-12(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc139
	call illname
#:  if(findloc(n))multidef(n);
cc139:
	leal	-12(%ebp), %eax
	pushl %eax
	call findloc
	popl %edx
	testl %eax, %eax
	je	cc140
	leal	-12(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:  if(match("["))  {
cc140:
	movl $cc1+1064, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc141
#:    /* Skip stuff between [ ] */
#:    while(inbyte()!=']')  {
cc142:
	call inbyte
	pushl %eax
	movl $93, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc143
#:      if(endst())break;
	call endst
	testl %eax, %eax
	je	cc144
	jmp cc143
#:    }
cc144:
	jmp cc142
cc143:
#:    j=POINTER;
	leal	-20(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:    /* add entry as POINTER */
#:  }
#:  addloc(n,j,t,8+argtop-argstk);
cc141:
	movl $8, %eax
	pushl %eax
	movl argtop, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl argstk, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	movl t, %eax
	pushl %eax
	leal	-20(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-12(%ebp), %eax
	pushl %eax
	call addloc
	addl $16, %esp
#:  if(endst())return;
	call endst
	testl %eax, %eax
	je	cc145
	movl %ebp, %esp
	popl %ebp
	ret
#:}
cc145:
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Declare argument TYPEs    */
#:/*          */
#:/* called from "newfunc" this routine adds an entry in the */
#:/*  local symbol table for each NAMEd argument */
#:getarg(t)    /* t = CCHAR or CINT */
	.text
	.align 16
.globl getarg
	.TYPE	getarg,@function
getarg:
#:  int t;
	pushl %ebp
	movl %esp, %ebp
#:  {
#:  char n[NAMESIZE],c;int j;
	subl $12, %esp
	pushl %edx
	pushl %edx
#:  while(1)
cc146:
	movl $1, %eax
	testl %eax, %eax
	je	cc147
#:    {if(argstk==0)return;  /* no more args */
	movl argstk, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc148
	movl %ebp, %esp
	popl %ebp
	ret
#:    if(match("*"))j=POINTER;
cc148:
	movl $cc1+1066, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc149
	leal	-20(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:      else j=VARIABLE;
	jmp cc150
cc149:
	leal	-20(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
cc150:
#:    if(symname(n)==0) illname();
	leal	-12(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc151
	call illname
#:    if(findloc(n))multidef(n);
cc151:
	leal	-12(%ebp), %eax
	pushl %eax
	call findloc
	popl %edx
	testl %eax, %eax
	je	cc152
	leal	-12(%ebp), %eax
	pushl %eax
	call multidef
	popl %edx
#:    if(match("["))  /* POINTER ? */
cc152:
	movl $cc1+1068, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc153
#:    /* it is a POINTER, so skip all */
#:    /* stuff between "[]" */
#:      {while(inbyte()!=']')
cc154:
	call inbyte
	pushl %eax
	movl $93, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc155
#:        if(endst())break;
	call endst
	testl %eax, %eax
	je	cc156
	jmp cc155
#:      j=POINTER;
cc156:
	jmp cc154
cc155:
	leal	-20(%ebp), %eax
	pushl %eax
	movl $3, %eax
	popl %edx
	movl %eax, (%edx)
#:      /* add entry as POINTER */
#:      }
#:    addloc(n,j,t,8+argtop-argstk);
cc153:
	movl $8, %eax
	pushl %eax
	movl argtop, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl argstk, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-20(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-12(%ebp), %eax
	pushl %eax
	call addloc
	addl $16, %esp
#:    argstk=argstk-4;  /* cnt down *//*modified by E.V.*/
	movl argstk, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	movl %eax, argstk
#:    /* K&R handling conditionally - SA */
#:    if( kandr ) {
	movl kandr, %eax
	testl %eax, %eax
	je	cc157
#:      if(endst())return;
	call endst
	testl %eax, %eax
	je	cc158
	movl %ebp, %esp
	popl %ebp
	ret
#:      if(match(",")==0)error("expected comma"); 
cc158:
	movl $cc1+1070, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc159
	movl $cc1+1072, %eax
	pushl %eax
	call error
	popl %edx
#:    } else {
cc159:
	jmp cc160
cc157:
#:      return;
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
cc160:
#:    }
	jmp cc146
cc147:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Statement parser    */
#:/*          */
#:/* called whenever syntax requires  */
#:/*  a statement.        */
#:/*  this routine performs that statement */
#:/*  and returns a number telling which one */
#:statement()
	.text
	.align 16
.globl statemen
	.TYPE	statemen,@function
statemen:
#:{
	pushl %ebp
	movl %esp, %ebp
#:        /* NOTE (RDK) --- On DOS there is no CPM FUNCTION so just try */
#:        /* commenting it out for the first test compilation to see if */
#:        /* the compiler basic framework works OK in the DOS environment */
#:  /* if(cpm(11,0) & 1)  /* check for ctrl-C gtf 7/17/80 */
#:    /* if(getchar()==3) */
#:      /* zabort(); */
#:  if ((ch()==0) & (eof)) return;
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	movl eof, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc161
	movl %ebp, %esp
	popl %ebp
	ret
#:  else if(amatch("char",4))
	jmp cc162
cc161:
	movl $4, %eax
	pushl %eax
	movl $cc1+1087, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc163
#:    {declloc(CCHAR);ns();}
	movl $1, %eax
	pushl %eax
	call declloc
	popl %edx
	call ns
#:  else if(amatch("int",3))
	jmp cc164
cc163:
	movl $3, %eax
	pushl %eax
	movl $cc1+1092, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc165
#:    {declloc(CINT);ns();}
	movl $2, %eax
	pushl %eax
	call declloc
	popl %edx
	call ns
#:  else if(amatch("struct",6))
	jmp cc166
cc165:
	movl $6, %eax
	pushl %eax
	movl $cc1+1096, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc167
#:    {newstruct();}
	call newstruc
#:  else if(match("{"))compound();
	jmp cc168
cc167:
	movl $cc1+1103, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc169
	call compound
#:  else if(amatch("if",2))
	jmp cc170
cc169:
	movl $2, %eax
	pushl %eax
	movl $cc1+1105, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc171
#:    {doif();lastst=STIF;}
	call doif
	movl $1, %eax
	movl %eax, lastst
#:  else if(amatch("while",5))
	jmp cc172
cc171:
	movl $5, %eax
	pushl %eax
	movl $cc1+1108, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc173
#:    {dowhile();lastst=STWHILE;}
	call dowhile
	movl $2, %eax
	movl %eax, lastst
#:  else if(amatch("for",3))
	jmp cc174
cc173:
	movl $3, %eax
	pushl %eax
	movl $cc1+1114, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc175
#:    {dofor();lastst=STFOR;}
	call dofor
	movl $9, %eax
	movl %eax, lastst
#:  else if(amatch("do", 2))
	jmp cc176
cc175:
	movl $2, %eax
	pushl %eax
	movl $cc1+1118, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc177
#:    {dodo();lastst=STDO;}
	call dodo
	movl $10, %eax
	movl %eax, lastst
#:  else if(amatch("return",6))
	jmp cc178
cc177:
	movl $6, %eax
	pushl %eax
	movl $cc1+1121, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc179
#:    {doreturn();ns();lastst=STRETURN;}
	call doreturn
	call ns
	movl $3, %eax
	movl %eax, lastst
#:  else if(amatch("break",5))
	jmp cc180
cc179:
	movl $5, %eax
	pushl %eax
	movl $cc1+1128, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc181
#:    {dobreak();ns();lastst=STBREAK;}
	call dobreak
	call ns
	movl $4, %eax
	movl %eax, lastst
#:  else if(amatch("continue",8))
	jmp cc182
cc181:
	movl $8, %eax
	pushl %eax
	movl $cc1+1134, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	testl %eax, %eax
	je	cc183
#:    {docont();ns();lastst=STCONT;}
	call docont
	call ns
	movl $5, %eax
	movl %eax, lastst
#:  else if(match(";"));
	jmp cc184
cc183:
	movl $cc1+1143, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc185
#:  else if(match("#asm"))
	jmp cc186
cc185:
	movl $cc1+1145, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc187
#:    {doasm();lastst=STASM;}
	call doasm
	movl $6, %eax
	movl %eax, lastst
#:  /* if nothing else, assume it's an expression */
#:  else{expression();ns();lastst=STEXP;}
	jmp cc188
cc187:
	call expressi
	call ns
	movl $7, %eax
	movl %eax, lastst
cc188:
cc186:
cc184:
cc182:
cc180:
cc178:
cc176:
cc174:
cc172:
cc170:
cc168:
cc166:
cc164:
cc162:
#:  return lastst;
	movl lastst, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Semicolon enforcer    */
#:/*          */
#:/* called whenever syntax requires a semicolon */
#:ns()  {if(match(";")==0)error("missing semicolon");}
	.text
	.align 16
.globl ns
	.TYPE	ns,@function
ns:
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+1150, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc189
	movl $cc1+1152, %eax
	pushl %eax
	call error
	popl %edx
cc189:
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  Compound statement    */
#:/*          */
#:/* allow any number of statements to fall between "{}" */
#:compound()
	.text
	.align 16
.globl compound
	.TYPE	compound,@function
compound:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  ++ncmp;    /* new level open */
	movl ncmp, %eax
	incl %eax
	movl %eax, ncmp
#:  while (match("}")==0) statement(); /* do one */
cc190:
	movl $cc1+1170, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc191
	call statemen
	jmp cc190
cc191:
#:  --ncmp;    /* close current level */
	movl ncmp, %eax
	decl %eax
	movl %eax, ncmp
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*    "if" statement    */
#:/*          */
#:doif()
	.text
	.align 16
.globl doif
	.TYPE	doif,@function
doif:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  int flev,fsp,flab1,flab2;
	pushl %edx
	pushl %edx
	pushl %edx
	pushl %edx
#:  flev=locptr;  /* record current local level */
	leal	-4(%ebp), %eax
	pushl %eax
	movl locptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  fsp=Zsp;    /* record current stk ptr */
	leal	-8(%ebp), %eax
	pushl %eax
	movl Zsp, %eax
	popl %edx
	movl %eax, (%edx)
#:  flab1=getlabel(); /* get label for false branch */
	leal	-12(%ebp), %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  test(flab1);  /* get expression, and branch false */
	leal	-12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call test
	popl %edx
#:  statement();  /* if true, do a statement */
	call statemen
#:  Zsp=modstk(fsp);  /* then clean up the stack */
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:  locptr=flev;  /* and deallocate any locals */
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %eax, locptr
#:  if (amatch("else",4)==0)  /* if...else ? */
	movl $4, %eax
	pushl %eax
	movl $cc1+1172, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc192
#:    /* simple "if"...print false label */
#:    {printlabel(flab1);col();nl();
	leal	-12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:    return;    /* and exit */
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  /* an "if...else" statement. */
#:  jump(flab2=getlabel());  /* jump around false code */
cc192:
	leal	-16(%ebp), %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	call jump
	popl %edx
#:  printlabel(flab1);col();nl();  /* print false label */
	leal	-12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  statement();    /* and do "else" clause */
	call statemen
#:  Zsp=modstk(fsp);    /* then clean up stk ptr */
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:  locptr=flev;    /* and deallocate locals */
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %eax, locptr
#:  printlabel(flab2);col();nl();  /* print true label */
	leal	-16(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  "while" statement    */
#:/*          */
#:dowhile()
	.text
	.align 16
.globl dowhile
	.TYPE	dowhile,@function
dowhile:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  int wq[4];    /* allocate local queue */
	subl $16, %esp
#:  wq[WQSYM]=locptr;  /* record local level */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl locptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  wq[WQSP]=Zsp;    /* and stk ptr */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl Zsp, %eax
	popl %edx
	movl %eax, (%edx)
#:  wq[WQLOOP]=getlabel();  /* and looping label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  wq[WQLAB]=getlabel();  /* and exit label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  addwhile(wq);    /* add entry to queue */
	leal	-16(%ebp), %eax
	pushl %eax
	call addwhile
	popl %edx
#:        /* (for "break" statement) */
#:  printlabel(wq[WQLOOP]);col();nl(); /* loop label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  test(wq[WQLAB]);  /* see if true */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call test
	popl %edx
#:  statement();    /* if so, do a statement */
	call statemen
#:  Zsp = modstk(wq[WQSP]);  /* zap local vars: 9/25/80 gtf */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:  jump(wq[WQLOOP]);  /* loop to label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call jump
	popl %edx
#:  printlabel(wq[WQLAB]);col();nl(); /* exit label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  locptr=wq[WQSYM];  /* deallocate locals */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, locptr
#:  delwhile();    /* delete queue entry */
	call delwhile
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:dodo()
	.text
	.align 16
.globl dodo
	.TYPE	dodo,@function
dodo:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  int wq[4];
	subl $16, %esp
#:  wq[WQSYM]=locptr;
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl locptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  wq[WQSP]=Zsp;
	leal	-16(%ebp), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl Zsp, %eax
	popl %edx
	movl %eax, (%edx)
#:  wq[WQLOOP]=getlabel();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  wq[WQLAB]=getlabel();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  addwhile(wq);
	leal	-16(%ebp), %eax
	pushl %eax
	call addwhile
	popl %edx
#:  printlabel(wq[WQLOOP]);col();nl();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  statement();
	call statemen
#:  Zsp = modstk(wq[WQSP]);
	leal	-16(%ebp), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:  if(amatch("while",5)==0)
	movl $5, %eax
	pushl %eax
	movl $cc1+1177, %eax
	pushl %eax
	call amatch
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc193
#:  {error("'while' needed");}
	movl $cc1+1183, %eax
	pushl %eax
	call error
	popl %edx
#:  needbrack("(");
cc193:
	movl $cc1+1198, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  expression();
	call expressi
#:  ol("testl %eax, %eax");
	movl $cc1+1200, %eax
	pushl %eax
	call ol
	popl %edx
#:  ot("jne");tab();
	movl $cc1+1217, %eax
	pushl %eax
	call ot
	popl %edx
	call tab
#:  printlabel(wq[WQLOOP]);nl();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call nl
#:  printlabel(wq[WQLAB]);col();nl();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  
#:  needbrack(")");
	movl $cc1+1221, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  ns();
	call ns
#:  locptr=wq[WQSYM];
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, locptr
#:  delwhile();
	call delwhile
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:dofor()
	.text
	.align 16
.globl dofor
	.TYPE	dofor,@function
dofor:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  int wq[4];
	subl $16, %esp
#:  int bl;
	pushl %edx
#:  int tl,tl1;
	pushl %edx
	pushl %edx
#:  bl=getlabel();
	leal	-20(%ebp), %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  wq[WQSYM]=locptr;
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl locptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  wq[WQSP]=Zsp;
	leal	-16(%ebp), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl Zsp, %eax
	popl %edx
	movl %eax, (%edx)
#:  wq[WQLOOP]=getlabel();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  wq[WQLAB]=getlabel();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call getlabel
	popl %edx
	movl %eax, (%edx)
#:  addwhile(wq);
	leal	-16(%ebp), %eax
	pushl %eax
	call addwhile
	popl %edx
#:  
#:  needbrack("(");
	movl $cc1+1223, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  expression();/*i=0*/
	call expressi
#:  ns();
	call ns
#:  printlabel(wq[WQLOOP]);col();nl();
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  expression();/*i<N*/
	call expressi
#:  testjump(wq[WQLAB]);
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call testjump
	popl %edx
#:  ns();
	call ns
#:  tl=getlitstk();
	leal	-24(%ebp), %eax
	pushl %eax
	call getlitst
	popl %edx
	movl %eax, (%edx)
#:  expression();/*i++*/
	call expressi
#:  getlitstk();
	call getlitst
#:  needbrack(")");
	movl $cc1+1225, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  statement();
	call statemen
#:  Zsp = modstk(wq[WQSP]);  /* zap local vars: 9/25/80 gtf */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:  printf("dumpltstk...\n");
	movl $cc1+1227, %eax
	pushl %eax
	call printf
	popl %edx
#:  /*dumpltstk(tl1);*/
#:  dumpltstk(tl);
	leal	-24(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call dumpltst
	popl %edx
#:  jump(wq[WQLOOP]);  /* loop to label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call jump
	popl %edx
#:  printlabel(wq[WQLAB]);col();nl(); /* exit label */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
	call col
	call nl
#:  locptr=wq[WQSYM];  /* deallocate locals */
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, locptr
#:  delwhile();    /* delete queue entry */
	call delwhile
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  "return" statement    */
#:/*          */
#:doreturn()
	.text
	.align 16
.globl doreturn
	.TYPE	doreturn,@function
doreturn:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  /* if not end of statement, get an expression */
#:  if(endst()==0)expression();
	call endst
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc194
	call expressi
#:  /*modstk(0);*/  /* clean up stk */
#:  ol("movl %ebp, %esp");
cc194:
	movl $cc1+1241, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("popl %ebp");
	movl $cc1+1257, %eax
	pushl %eax
	call ol
	popl %edx
#:  zret();    /* and exit FUNCTION */
	call zret
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  "break" statement    */
#:/*          */
#:dobreak()
	.text
	.align 16
.globl dobreak
	.TYPE	dobreak,@function
dobreak:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  int *ptr;
	pushl %edx
#:  /* see if any "whiles" are open */
#:  if ((ptr=readwhile())==0) return;  /* no */
	leal	-4(%ebp), %eax
	pushl %eax
	call readwhil
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc195
	movl %ebp, %esp
	popl %ebp
	ret
#:  modstk((ptr[WQSP]));  /* else clean up stk ptr */
cc195:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
#:  jump(ptr[WQLAB]);  /* jump to exit label */
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $3, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call jump
	popl %edx
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  "continue" statement    */
#:/*          */
#:docont()
	.text
	.align 16
.globl docont
	.TYPE	docont,@function
docont:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  int *ptr;
	pushl %edx
#:  /* see if any "whiles" are open */
#:  if ((ptr=readwhile())==0) return;  /* no */
	leal	-4(%ebp), %eax
	pushl %eax
	call readwhil
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc196
	movl %ebp, %esp
	popl %ebp
	ret
#:  modstk((ptr[WQSP]));  /* else clean up stk ptr */
cc196:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call modstk
	popl %edx
#:  jump(ptr[WQLOOP]);  /* jump to loop label */
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $2, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call jump
	popl %edx
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*          */
#:/*  "asm" pseudo-statement    */
#:/*          */
#:/* enters mode where assembly language statement are */
#:/*  passed intact through parser  */
#:doasm()
	.text
	.align 16
.globl doasm
	.TYPE	doasm,@function
doasm:
#:  {
	pushl %ebp
	movl %esp, %ebp
#:  cmode=0;    /* mark mode as "asm" */
	movl $0, %eax
	movl %eax, cmode
#:  while (1)
cc197:
	movl $1, %eax
	testl %eax, %eax
	je	cc198
#:    {insline();  /* get and print lines */
	call insline
#:    if (match("#endasm")) break;  /* until... */
	movl $cc1+1267, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc199
	jmp cc198
#:    if(eof)break;
cc199:
	movl eof, %eax
	testl %eax, %eax
	je	cc200
	jmp cc198
#:    outstr(line);
cc200:
	movl 	$line, %eax
	pushl %eax
	call outstr
	popl %edx
#:    nl();
	call nl
#:    }
	jmp cc197
cc198:
#:  kill();    /* invalidate line */
	call kill
#:  cmode=1;    /* then back to parse level */
	movl $1, %eax
	movl %eax, cmode
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*  >>>>> start of cc3 <<<<<<<<<  */
#:/*          */
#:/*  Perform a FUNCTION call    */
#:/*          */
#:/* called from heir11, this routine will either call */
#:/*  the NAMEd FUNCTION, or if the supplied ptr is */
#:/*  zero, will call the contents of HL    */
#:callfunction(ptr)
	.text
	.align 16
.globl callfunc
	.TYPE	callfunc,@function
callfunc:
#:  char *ptr;  /* symbol table entry (or 0) */
	pushl %ebp
	movl %esp, %ebp
#:{  int nargs,tl;
	pushl %edx
	pushl %edx
#:  nargs=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  tl=getlitstk();
	leal	-8(%ebp), %eax
	pushl %eax
	call getlitst
	popl %edx
	movl %eax, (%edx)
#:  blanks();  /* already saw open paren */
	call blanks
#:  if(ptr==0)zpush();  /* calling HL */
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc201
	call zpush
#:  while(streq(line+lptr,")")==0)
cc201:
cc202:
	movl $cc1+1275, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc203
#:    {if(endst())break;
	call endst
	testl %eax, %eax
	je	cc204
	jmp cc203
#:    expression();  /* get an argument */
cc204:
	call expressi
#:    /*if(ptr==0)swapstk();*/ /* don't push addr */
#:    zpush();  /* push argument */
	call zpush
#:    getlitstk();
	call getlitst
#:    nargs=nargs+4;  /* count args*2 *//*4, modified by E.V.*/
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:    if (match(",")==0) break;
	movl $cc1+1277, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc205
	jmp cc203
#:    }
cc205:
	jmp cc202
cc203:
#:  needbrack(")");
	movl $cc1+1279, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  dumpltstk(tl);
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call dumpltst
	popl %edx
#:  if(ptr)zcall(ptr);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc206
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call zcall
	popl %edx
#:  else callstk(nargs);
	jmp cc207
cc206:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call callstk
	popl %edx
cc207:
#:  Zsp=modstk(Zsp+nargs);  /* clean up arguments */
	movl Zsp, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call modstk
	popl %edx
	movl %eax, Zsp
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:junk()
	.text
	.align 16
.globl junk
	.TYPE	junk,@function
junk:
#:{  if(an(inbyte()))
	pushl %ebp
	movl %esp, %ebp
	call inbyte
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc208
#:    while(an(ch()))gch();
cc209:
	call ch
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc210
	call gch
	jmp cc209
cc210:
#:  else while(an(ch())==0)
	jmp cc211
cc208:
cc212:
	call ch
	pushl %eax
	call an
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc213
#:    {if(ch()==0)break;
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc214
	jmp cc213
#:    gch();
cc214:
	call gch
#:    }
	jmp cc212
cc213:
cc211:
#:  blanks();
	call blanks
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:endst()
	.text
	.align 16
.globl endst
	.TYPE	endst,@function
endst:
#:{  blanks();
	pushl %ebp
	movl %esp, %ebp
	call blanks
#:  return ((streq(line+lptr,";")|(ch()==0)));
	movl $cc1+1281, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:illname()
	.text
	.align 16
.globl illname
	.TYPE	illname,@function
illname:
#:{  error("illegal symbol NAME");junk();}
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+1283, %eax
	pushl %eax
	call error
	popl %edx
	call junk
	movl %ebp, %esp
	popl %ebp
	ret
#:multidef(sname)
	.text
	.align 16
.globl multidef
	.TYPE	multidef,@function
multidef:
#:  char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  error("already defined");
	movl $cc1+1303, %eax
	pushl %eax
	call error
	popl %edx
#:  comment();
	call comment
#:  outstr(sname);nl();
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outstr
	popl %edx
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:needbrack(str)
	.text
	.align 16
.globl needbrac
	.TYPE	needbrac,@function
needbrac:
#:  char *str;
	pushl %ebp
	movl %esp, %ebp
#:{  if (match(str)==0)
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc215
#:    {error("missing bracket");
	movl $cc1+1319, %eax
	pushl %eax
	call error
	popl %edx
#:    comment();outstr(str);nl();
	call comment
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outstr
	popl %edx
	call nl
#:    }
#:}
cc215:
	movl %ebp, %esp
	popl %ebp
	ret
#:needlval()
	.text
	.align 16
.globl needlval
	.TYPE	needlval,@function
needlval:
#:{  error("must be lvalue");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+1335, %eax
	pushl %eax
	call error
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:findglb(sname)
	.text
	.align 16
.globl findglb
	.TYPE	findglb,@function
findglb:
#:  char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  char *ptr;
	pushl %edx
#:  ptr=STARTGLB;
	leal	-4(%ebp), %eax
	pushl %eax
	movl 	$SYMTAB, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(ptr!=glbptr)
cc216:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl glbptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc217
#:    {if(astreq(sname,ptr,NAMEMAX))return ptr;
	movl $8, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call astreq
	addl $12, %esp
	testl %eax, %eax
	je	cc218
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    ptr=ptr+SYMSIZ;
cc218:
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:    }
	jmp cc216
cc217:
#:  return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:findloc(sname)
	.text
	.align 16
.globl findloc
	.TYPE	findloc,@function
findloc:
#:  char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  char *ptr;
	pushl %edx
#:  ptr=STARTLOC;
	leal	-4(%ebp), %eax
	pushl %eax
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(ptr!=locptr)
cc219:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl locptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc220
#:    {if(astreq(sname,ptr,NAMEMAX))return ptr;
	movl $8, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call astreq
	addl $12, %esp
	testl %eax, %eax
	je	cc221
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    ptr=ptr+SYMSIZ;
cc221:
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:    }
	jmp cc219
cc220:
#:  return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:addglb(sname,id,typ,value)
	.text
	.align 16
.globl addglb
	.TYPE	addglb,@function
addglb:
#:  char *sname,id,typ;
#:  int value;
	pushl %ebp
	movl %esp, %ebp
#:{  char *ptr;
	pushl %edx
#:  if(cptr=findglb(sname))return cptr;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call findglb
	popl %edx
	movl %eax, cptr
	testl %eax, %eax
	je	cc222
	movl cptr, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(glbptr>=ENDGLB)
cc222:
	movl glbptr, %eax
	pushl %eax
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $300, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	imull %edx
	popl %edx
	addl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setae	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc223
#:    {error("global symbol table overflow");
	movl $cc1+1350, %eax
	pushl %eax
	call error
	popl %edx
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  cptr=ptr=glbptr;
cc223:
	leal	-4(%ebp), %eax
	pushl %eax
	movl glbptr, %eax
	popl %edx
	movl %eax, (%edx)
	movl %eax, cptr
#:  while(an(*ptr++ = *sname++));  /* copy NAME */
cc224:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	pushl %eax
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc225
	jmp cc224
cc225:
#:  cptr[IDENT]=id;
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	12(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  cptr[TYPE]=typ;
	movl cptr, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	16(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  cptr[STORAGE]=STATIK;
	movl cptr, %eax
	pushl %eax
	movl $11, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movb %al, (%edx)
#:  cptr[OFFSET]=value;
	movl cptr, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	20(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movb %al, (%edx)
#:  cptr[OFFSET+1]=value>>8;
	movl cptr, %eax
	pushl %eax
	movl $12, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	20(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $8, %eax
	popl %edx
	movl %eax, %ecx
	movl %edx, %eax
	sarl %cl, %eax
	popl %edx
	movb %al, (%edx)
#:  glbptr=glbptr+SYMSIZ;
	movl glbptr, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, glbptr
#:  return cptr;
	movl cptr, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:addloc(sname,id,typ,value)
	.text
	.align 16
.globl addloc
	.TYPE	addloc,@function
addloc:
#:  char *sname,id,typ;
#:  int value;
	pushl %ebp
	movl %esp, %ebp
#:{  char *ptr;
	pushl %edx
#:  if(cptr=findloc(sname))return cptr;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call findloc
	popl %edx
	movl %eax, cptr
	testl %eax, %eax
	je	cc226
	movl cptr, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(locptr>=ENDLOC)
cc226:
	movl locptr, %eax
	pushl %eax
	movl 	$SYMTAB, %eax
	pushl %eax
	movl $5040, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setae	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc227
#:    {error("local symbol table overflow");
	movl $cc1+1379, %eax
	pushl %eax
	call error
	popl %edx
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  cptr=ptr=locptr;
cc227:
	leal	-4(%ebp), %eax
	pushl %eax
	movl locptr, %eax
	popl %edx
	movl %eax, (%edx)
	movl %eax, cptr
#:  while(an(*ptr++ = *sname++));  /* copy NAME */
cc228:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	pushl %eax
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc229
	jmp cc228
cc229:
#:  cptr[IDENT]=id;
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	12(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  cptr[TYPE]=typ;
	movl cptr, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	16(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  cptr[STORAGE]=STKLOC;
	movl cptr, %eax
	pushl %eax
	movl $11, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	movb %al, (%edx)
#:  cptr[OFFSET]=value;
	movl cptr, %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	20(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movb %al, (%edx)
#:  cptr[OFFSET+1]=value>>8;
	movl cptr, %eax
	pushl %eax
	movl $12, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	20(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $8, %eax
	popl %edx
	movl %eax, %ecx
	movl %edx, %eax
	sarl %cl, %eax
	popl %edx
	movb %al, (%edx)
#:  locptr=locptr+SYMSIZ;
	movl locptr, %eax
	pushl %eax
	movl $14, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, locptr
#:  return cptr;
	movl cptr, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test if next input string is legal symbol NAME */
#:symname(sname)
	.text
	.align 16
.globl symname
	.TYPE	symname,@function
symname:
#:  char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  int k;char c;
	pushl %edx
	pushl %edx
#:  blanks();
	call blanks
#:  if(alpha(ch())==0)return 0;
	call ch
	pushl %eax
	call alpha
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc230
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  k=0;
cc230:
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(an(ch()))sname[k++]=gch();
cc231:
	call ch
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc232
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call gch
	popl %edx
	movb %al, (%edx)
	jmp cc231
cc232:
#:  sname[k]=0;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movb %al, (%edx)
#:  return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Return next avail internal label number */
#:getlabel()
	.text
	.align 16
.globl getlabel
	.TYPE	getlabel,@function
getlabel:
#:{  return(++nxtlab);
	pushl %ebp
	movl %esp, %ebp
	movl nxtlab, %eax
	incl %eax
	movl %eax, nxtlab
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print specified number as label */
#:printlabel(label)
	.text
	.align 16
.globl printlab
	.TYPE	printlab,@function
printlab:
#:  int label;
	pushl %ebp
	movl %esp, %ebp
#:{  outasm("cc");
	movl $cc1+1407, %eax
	pushl %eax
	call outasm
	popl %edx
#:  outdec(label);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outdec
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test if given character is alpha */
#:alpha(c)
	.text
	.align 16
.globl alpha
	.TYPE	alpha,@function
alpha:
#:  char c;
	pushl %ebp
	movl %esp, %ebp
#:{  c=c&127;
	leal	8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	movb %al, (%edx)
#:  return(((c>='a')&(c<='z'))|
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $97, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $122, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
#:    ((c>='A')&(c<='Z'))|
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $65, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $90, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	orl %edx, %eax
	pushl %eax
#:    (c=='_'));
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $95, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test if given character is numeric */
#:numeric(c)
	.text
	.align 16
.globl numeric
	.TYPE	numeric,@function
numeric:
#:  char c;
	pushl %ebp
	movl %esp, %ebp
#:{  c=c&127;
	leal	8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	movb %al, (%edx)
#:  return((c>='0')&(c<='9'));
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $48, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $57, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test if given character is alphanumeric */
#:an(c)
	.text
	.align 16
.globl an
	.TYPE	an,@function
an:
#:  char c;
	pushl %ebp
	movl %esp, %ebp
#:{  return((alpha(c))|(numeric(c)));
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call alpha
	popl %edx
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call numeric
	popl %edx
	popl %edx
	orl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print a carriage return and a string only to console */
#:pl(str)
	.text
	.align 16
.globl pl
	.TYPE	pl,@function
pl:
#:  char *str;
	pushl %ebp
	movl %esp, %ebp
#:{  int k;
	pushl %edx
#:  k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  putchar(EOL);
	movl $10, %eax
	pushl %eax
	call putchar
	popl %edx
#:  while(str[k])putchar(str[k++]);
cc233:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc234
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	call putchar
	popl %edx
	jmp cc233
cc234:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:addwhile(ptr)
	.text
	.align 16
.globl addwhile
	.TYPE	addwhile,@function
addwhile:
#:  int ptr[];
	pushl %ebp
	movl %esp, %ebp
#: {
#:  int k;
	pushl %edx
#:  if (wqptr==WQMAX)
	movl wqptr, %eax
	pushl %eax
	movl 	$wq, %eax
	pushl %eax
	movl $300, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $4, %eax
	sall $2, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc235
#:    {error("too many active whiles");return;}
	movl $cc1+1410, %eax
	pushl %eax
	call error
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:  k=0;
cc235:
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while (k<WQSIZ)
cc236:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc237
#:    {*wqptr++ = ptr[k++];}
	movl wqptr, %eax
	incl %eax
	incl %eax
	incl %eax
	incl %eax
	movl %eax, wqptr
	decl %eax
	decl %eax
	decl %eax
	decl %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
	jmp cc236
cc237:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:delwhile()
	.text
	.align 16
.globl delwhile
	.TYPE	delwhile,@function
delwhile:
#:  {if(readwhile()) wqptr=wqptr-WQSIZ;
	pushl %ebp
	movl %esp, %ebp
	call readwhil
	testl %eax, %eax
	je	cc238
	movl wqptr, %eax
	pushl %eax
	movl $4, %eax
	sall $2, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	movl %eax, wqptr
#:  }
cc238:
	movl %ebp, %esp
	popl %ebp
	ret
#:readwhile()
	.text
	.align 16
.globl readwhil
	.TYPE	readwhil,@function
readwhil:
#: {
	pushl %ebp
	movl %esp, %ebp
#:  if (wqptr==wq){error("no active whiles");return 0;}
	movl wqptr, %eax
	pushl %eax
	movl 	$wq, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc239
	movl $cc1+1433, %eax
	pushl %eax
	call error
	popl %edx
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  else return (wqptr-WQSIZ);
	jmp cc240
cc239:
	movl wqptr, %eax
	pushl %eax
	movl $4, %eax
	sall $2, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc240:
#: }
	movl %ebp, %esp
	popl %ebp
	ret
#:ch()
	.text
	.align 16
.globl ch
	.TYPE	ch,@function
ch:
#:{  return(line[lptr]&127);
	pushl %ebp
	movl %esp, %ebp
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:nch()
	.text
	.align 16
.globl nch
	.TYPE	nch,@function
nch:
#:{  if(ch()==0)return 0;
	pushl %ebp
	movl %esp, %ebp
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc241
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    else return(line[lptr+1]&127);
	jmp cc242
cc241:
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc242:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:gch()
	.text
	.align 16
.globl gch
	.TYPE	gch,@function
gch:
#:{  if(ch()==0)return 0;
	pushl %ebp
	movl %esp, %ebp
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc243
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    else return(line[lptr++]&127);
	jmp cc244
cc243:
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	incl %eax
	movl %eax, lptr
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc244:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:kill()
	.text
	.align 16
.globl kill
	.TYPE	kill,@function
kill:
#:{  lptr=0;
	pushl %ebp
	movl %esp, %ebp
	movl $0, %eax
	movl %eax, lptr
#:  line[lptr]=0;
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movb %al, (%edx)
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:inbyte()
	.text
	.align 16
.globl inbyte
	.TYPE	inbyte,@function
inbyte:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  while(ch()==0)
cc245:
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc246
#:    {if (eof) return 0;
	movl eof, %eax
	testl %eax, %eax
	je	cc247
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    insline();
cc247:
	call insline
#:    preprocess();
	call preproce
#:    }
	jmp cc245
cc246:
#:  return gch();
	call gch
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:inchar()
	.text
	.align 16
.globl inchar
	.TYPE	inchar,@function
inchar:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  if(ch()==0)insline();
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc248
	call insline
#:  if(eof)return 0;
cc248:
	movl eof, %eax
	testl %eax, %eax
	je	cc249
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  return(gch());
cc249:
	call gch
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:insline()
	.text
	.align 16
.globl insline
	.TYPE	insline,@function
insline:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  int k,unit;
	pushl %edx
	pushl %edx
#:  while(1)
cc250:
	movl $1, %eax
	testl %eax, %eax
	je	cc251
#:    {if (input==0)openin();
	movl input, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc252
	call openin
#:    if(eof)return;
cc252:
	movl eof, %eax
	testl %eax, %eax
	je	cc253
	movl %ebp, %esp
	popl %ebp
	ret
#:    if((unit=input2)==0)unit=input;
cc253:
	leal	-8(%ebp), %eax
	pushl %eax
	movl input2, %eax
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc254
	leal	-8(%ebp), %eax
	pushl %eax
	movl input, %eax
	popl %edx
	movl %eax, (%edx)
#:    kill();
cc254:
	call kill
#:    while((k=getc(unit))>0)
cc255:
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call getc
	popl %edx
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setg	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc256
#:      {if((k==EOL)|(lptr>=LINEMAX))break;
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	movl lptr, %eax
	pushl %eax
	movl $80, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc257
	jmp cc256
#:      line[lptr++]=k;
cc257:
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	incl %eax
	movl %eax, lptr
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movb %al, (%edx)
#:      }
	jmp cc255
cc256:
#:    line[lptr]=0;  /* append null */
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movb %al, (%edx)
#:    lineno++;  /* read one more line    gtf 7/2/80 */
	movl lineno, %eax
	incl %eax
	movl %eax, lineno
	decl %eax
#:    if(k<=0)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc258
#:      {fclose(unit);
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call fclose
	popl %edx
#:      if(input2)endinclude();    /* gtf 7/16/80 */
	movl input2, %eax
	testl %eax, %eax
	je	cc259
	call endinclu
#:        else input=0;
	jmp cc260
cc259:
	movl $0, %eax
	movl %eax, input
cc260:
#:      }
#:    if(lptr)
cc258:
	movl lptr, %eax
	testl %eax, %eax
	je	cc261
#:      {if((ctext)&(cmode))
	movl ctext, %eax
	pushl %eax
	movl cmode, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc262
#:        {comment();
	call comment
#:        outstr(line);
	movl 	$line, %eax
	pushl %eax
	call outstr
	popl %edx
#:        nl();
	call nl
#:        }
#:      lptr=0;
cc262:
	movl $0, %eax
	movl %eax, lptr
#:      return;
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    }
cc261:
	jmp cc250
cc251:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*  >>>>>> start of cc4 <<<<<<<  */
#:keepch(c)
	.text
	.align 16
.globl keepch
	.TYPE	keepch,@function
keepch:
#:  char c;
	pushl %ebp
	movl %esp, %ebp
#:{  mline[mptr]=c;
	movl 	$mline, %eax
	pushl %eax
	movl mptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  if(mptr<MPMAX)mptr++;
	movl mptr, %eax
	pushl %eax
	movl $80, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc263
	movl mptr, %eax
	incl %eax
	movl %eax, mptr
	decl %eax
#:  return c;
cc263:
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:preprocess()
	.text
	.align 16
.globl preproce
	.TYPE	preproce,@function
preproce:
#:{  int k;
	pushl %ebp
	movl %esp, %ebp
	pushl %edx
#:  char c,sname[NAMESIZE];
	pushl %edx
	subl $12, %esp
#:  if(cmode==0)return;
	movl cmode, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc264
	movl %ebp, %esp
	popl %ebp
	ret
#:  mptr=lptr=0;
cc264:
	movl $0, %eax
	movl %eax, lptr
	movl %eax, mptr
#:  while(ch())
cc265:
	call ch
	testl %eax, %eax
	je	cc266
#:    {if((ch()==' ')|(ch()==9))
	call ch
	pushl %eax
	movl $32, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $9, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc267
#:      {keepch(' ');
	movl $32, %eax
	pushl %eax
	call keepch
	popl %edx
#:      while((ch()==' ')|
cc268:
	call ch
	pushl %eax
	movl $32, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:        (ch()==9))
	call ch
	pushl %eax
	movl $9, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc269
#:        gch();
	call gch
	jmp cc268
cc269:
#:      }
#:    else if(ch()=='"')
	jmp cc270
cc267:
	call ch
	pushl %eax
	movl $34, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc271
#:      {keepch(ch());
	call ch
	pushl %eax
	call keepch
	popl %edx
#:      gch();
	call gch
#:      while(ch()!='"')
cc272:
	call ch
	pushl %eax
	movl $34, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc273
#:        {if(ch()==0)
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc274
#:          {error("missing quote");
	movl $cc1+1450, %eax
	pushl %eax
	call error
	popl %edx
#:          break;
	jmp cc273
#:          }
#:        keepch(gch());
cc274:
	call gch
	pushl %eax
	call keepch
	popl %edx
#:        }
	jmp cc272
cc273:
#:      gch();
	call gch
#:      keepch('"');
	movl $34, %eax
	pushl %eax
	call keepch
	popl %edx
#:      }
#:    else if(ch()==39)
	jmp cc275
cc271:
	call ch
	pushl %eax
	movl $39, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc276
#:      {keepch(39);
	movl $39, %eax
	pushl %eax
	call keepch
	popl %edx
#:      gch();
	call gch
#:      while(ch()!=39)
cc277:
	call ch
	pushl %eax
	movl $39, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc278
#:        {if(ch()==0)
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc279
#:          {error("missing apostrophe");
	movl $cc1+1464, %eax
	pushl %eax
	call error
	popl %edx
#:          break;
	jmp cc278
#:          }
#:        keepch(gch());
cc279:
	call gch
	pushl %eax
	call keepch
	popl %edx
#:        }
	jmp cc277
cc278:
#:      gch();
	call gch
#:      keepch(39);
	movl $39, %eax
	pushl %eax
	call keepch
	popl %edx
#:      }
#:    else if((ch()=='/')&(nch()=='*'))
	jmp cc280
cc276:
	call ch
	pushl %eax
	movl $47, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	call nch
	pushl %eax
	movl $42, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc281
#:      {inchar();inchar();
	call inchar
	call inchar
#:      while(((ch()=='*')&
cc282:
	call ch
	pushl %eax
	movl $42, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:        (nch()=='/'))==0)
	call nch
	pushl %eax
	movl $47, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc283
#:        {if(ch()==0)insline();
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc284
	call insline
#:          else inchar();
	jmp cc285
cc284:
	call inchar
cc285:
#:        if(eof)break;
	movl eof, %eax
	testl %eax, %eax
	je	cc286
	jmp cc283
#:        }
cc286:
	jmp cc282
cc283:
#:      inchar();inchar();
	call inchar
	call inchar
#:      }
#:    else if((ch()=='0')&(nch()=='x'))/*added by E.V.*/
	jmp cc287
cc281:
	call ch
	pushl %eax
	movl $48, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	call nch
	pushl %eax
	movl $120, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc288
#:      {
#:      keepch(gch());keepch(gch());
	call gch
	pushl %eax
	call keepch
	popl %edx
	call gch
	pushl %eax
	call keepch
	popl %edx
#:      while(an(ch())|((ch()>='a')&(ch()<='f')))
cc289:
	call ch
	pushl %eax
	call an
	popl %edx
	pushl %eax
	call ch
	pushl %eax
	movl $97, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $102, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc290
#:          keepch(gch());
	call gch
	pushl %eax
	call keepch
	popl %edx
	jmp cc289
cc290:
#:      }
#:    else if(alpha(ch()))  /* from an(): 9/22/80 gtf */
	jmp cc291
cc288:
	call ch
	pushl %eax
	call alpha
	popl %edx
	testl %eax, %eax
	je	cc292
#:      {k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:      while(an(ch()))
cc293:
	call ch
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc294
#:        {if(k<NAMEMAX)sname[k++]=ch();
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $8, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc295
	leal	-20(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call ch
	popl %edx
	movb %al, (%edx)
#:        gch();
cc295:
	call gch
#:        }
	jmp cc293
cc294:
#:      sname[k]=0;
	leal	-20(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movb %al, (%edx)
#:      if(k=findmac(sname))
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-20(%ebp), %eax
	pushl %eax
	call findmac
	popl %edx
	popl %edx
	movl %eax, (%edx)
	testl %eax, %eax
	je	cc296
#:        while(c=macq[k++])
cc297:
	leal	-8(%ebp), %eax
	pushl %eax
	movl 	$macq, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
	testl %eax, %eax
	je	cc298
#:          keepch(c);
	leal	-8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call keepch
	popl %edx
	jmp cc297
cc298:
#:      else
	jmp cc299
cc296:
#:        {k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:        while(c=sname[k++])
cc300:
	leal	-8(%ebp), %eax
	pushl %eax
	leal	-20(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
	testl %eax, %eax
	je	cc301
#:          keepch(c);
	leal	-8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call keepch
	popl %edx
	jmp cc300
cc301:
#:        }
cc299:
#:      }
#:    else keepch(gch());
	jmp cc302
cc292:
	call gch
	pushl %eax
	call keepch
	popl %edx
cc302:
cc291:
cc287:
cc280:
cc275:
cc270:
#:    }
	jmp cc265
cc266:
#:  keepch(0);
	movl $0, %eax
	pushl %eax
	call keepch
	popl %edx
#:  if(mptr>=MPMAX)error("line too long");
	movl mptr, %eax
	pushl %eax
	movl $80, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc303
	movl $cc1+1483, %eax
	pushl %eax
	call error
	popl %edx
#:  lptr=mptr=0;
cc303:
	movl $0, %eax
	movl %eax, mptr
	movl %eax, lptr
#:  while(line[lptr++]=mline[mptr++]);
cc304:
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	incl %eax
	movl %eax, lptr
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl 	$mline, %eax
	pushl %eax
	movl mptr, %eax
	incl %eax
	movl %eax, mptr
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
	testl %eax, %eax
	je	cc305
	jmp cc304
cc305:
#:  lptr=0;
	movl $0, %eax
	movl %eax, lptr
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:addmac()
	.text
	.align 16
.globl addmac
	.TYPE	addmac,@function
addmac:
#:{  char sname[NAMESIZE];
	pushl %ebp
	movl %esp, %ebp
	subl $12, %esp
#:  int k;
	pushl %edx
#:  if(symname(sname)==0)
	leal	-12(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc306
#:    {illname();
	call illname
#:    kill();
	call kill
#:    return;
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  k=0;
cc306:
	leal	-16(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(putmac(sname[k++]));
cc307:
	leal	-12(%ebp), %eax
	pushl %eax
	leal	-16(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	call putmac
	popl %edx
	testl %eax, %eax
	je	cc308
	jmp cc307
cc308:
#:  while(ch()==' ' | ch()==9) gch();
cc309:
	call ch
	pushl %eax
	movl $32, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $9, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc310
	call gch
	jmp cc309
cc310:
#:  while(putmac(gch()));
cc311:
	call gch
	pushl %eax
	call putmac
	popl %edx
	testl %eax, %eax
	je	cc312
	jmp cc311
cc312:
#:  if(macptr>=MACMAX)error("macro table full");
	movl macptr, %eax
	pushl %eax
	movl $3000, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc313
	movl $cc1+1497, %eax
	pushl %eax
	call error
	popl %edx
#:  }
cc313:
	movl %ebp, %esp
	popl %ebp
	ret
#:putmac(c)
	.text
	.align 16
.globl putmac
	.TYPE	putmac,@function
putmac:
#:  char c;
	pushl %ebp
	movl %esp, %ebp
#:{  macq[macptr]=c;
	movl 	$macq, %eax
	pushl %eax
	movl macptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:  if(macptr<MACMAX)macptr++;
	movl macptr, %eax
	pushl %eax
	movl $3000, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc314
	movl macptr, %eax
	incl %eax
	movl %eax, macptr
	decl %eax
#:  return c;
cc314:
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:findmac(sname)
	.text
	.align 16
.globl findmac
	.TYPE	findmac,@function
findmac:
#:  char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  int k;
	pushl %edx
#:  k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(k<macptr)
cc315:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl macptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc316
#:    {if(astreq(sname,macq+k,NAMEMAX))
	movl $8, %eax
	pushl %eax
	movl 	$macq, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call astreq
	addl $12, %esp
	testl %eax, %eax
	je	cc317
#:      {while(macq[k++]);
cc318:
	movl 	$macq, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc319
	jmp cc318
cc319:
#:      return k;
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    while(macq[k++]);
cc317:
cc320:
	movl 	$macq, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc321
	jmp cc320
cc321:
#:    while(macq[k++]);
cc322:
	movl 	$macq, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc323
	jmp cc322
cc323:
#:    }
	jmp cc315
cc316:
#:  return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* direct output to console    gtf 7/16/80 */
#:toconsole()
	.text
	.align 16
.globl toconsol
	.TYPE	toconsol,@function
toconsol:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  saveout = output;
	movl output, %eax
	movl %eax, saveout
#:  output = 0;
	movl $0, %eax
	movl %eax, output
#:/* end toconsole */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* direct output back to file    gtf 7/16/80 */
#:tofile()
	.text
	.align 16
.globl tofile
	.TYPE	tofile,@function
tofile:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  if(saveout)
	movl saveout, %eax
	testl %eax, %eax
	je	cc324
#:    output = saveout;
	movl saveout, %eax
	movl %eax, output
#:  saveout = 0;
cc324:
	movl $0, %eax
	movl %eax, saveout
#:/* end tofile */}
	movl %ebp, %esp
	popl %ebp
	ret
#:outbyte(c)
	.text
	.align 16
.globl outbyte
	.TYPE	outbyte,@function
outbyte:
#:   char c;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  if(output==0)
	movl output, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc325
#:  {putchar(c);return c;}
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call putchar
	popl %edx
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(tolitstk==0)
cc325:
	movl tolitstk, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc326
#:  return outbyte1(c);
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call outbyte1
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:  return putlitstk(c);
cc326:
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call putlitst
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:outbyte1(c)
	.text
	.align 16
.globl outbyte1
	.TYPE	outbyte1,@function
outbyte1:
#:  char c;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  if(c==0)return 0;
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc327
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(output)
cc327:
	movl output, %eax
	testl %eax, %eax
	je	cc328
#:    {if((putc(c,output))<=0)
	movl output, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call putc
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc329
#:      {closeout();
	call closeout
#:      error("Output file error");
	movl $cc1+1514, %eax
	pushl %eax
	call error
	popl %edx
#:      zabort();      /* gtf 7/17/80 */
	call zabort
#:      }
#:    }
cc329:
#:  else putchar(c);
	jmp cc330
cc328:
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call putchar
	popl %edx
cc330:
#:  return c;
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:outstr(ptr)
	.text
	.align 16
.globl outstr
	.TYPE	outstr,@function
outstr:
#:  char ptr[];
	pushl %ebp
	movl %esp, %ebp
#: {
#:  int k;
	pushl %edx
#:  k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(outbyte(ptr[k++]));
cc331:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	call outbyte
	popl %edx
	testl %eax, %eax
	je	cc332
	jmp cc331
cc332:
#: }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* write text destined for the assembler to read */
#:/* (i.e. stuff not in comments)      */
#:/*  gtf  6/26/80 */
#:outasm(ptr)
	.text
	.align 16
.globl outasm
	.TYPE	outasm,@function
outasm:
#:char *ptr;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  while(outbyte(*ptr++));
cc333:
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	movsbl (%eax),%eax
	pushl %eax
	call outbyte
	popl %edx
	testl %eax, %eax
	je	cc334
	jmp cc333
cc334:
#:/* end outasm */}
	movl %ebp, %esp
	popl %ebp
	ret
#:outasm1(ptr)
	.text
	.align 16
.globl outasm1
	.TYPE	outasm1,@function
outasm1:
#:char *ptr;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  while(outbyte1(*ptr++));
cc335:
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	movsbl (%eax),%eax
	pushl %eax
	call outbyte1
	popl %edx
	testl %eax, %eax
	je	cc336
	jmp cc335
cc336:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:nl(){outbyte(EOL);}
	.text
	.align 16
.globl nl
	.TYPE	nl,@function
nl:
	pushl %ebp
	movl %esp, %ebp
	movl $10, %eax
	pushl %eax
	call outbyte
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:nl1(){outbyte1(EOL);}
	.text
	.align 16
.globl nl1
	.TYPE	nl1,@function
nl1:
	pushl %ebp
	movl %esp, %ebp
	movl $10, %eax
	pushl %eax
	call outbyte1
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:tab(){outbyte(9);}
	.text
	.align 16
.globl tab
	.TYPE	tab,@function
tab:
	pushl %ebp
	movl %esp, %ebp
	movl $9, %eax
	pushl %eax
	call outbyte
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:col(){outbyte(58);}
	.text
	.align 16
.globl col
	.TYPE	col,@function
col:
	pushl %ebp
	movl %esp, %ebp
	movl $58, %eax
	pushl %eax
	call outbyte
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:col1(){outbyte1(58);}
	.text
	.align 16
.globl col1
	.TYPE	col1,@function
col1:
	pushl %ebp
	movl %esp, %ebp
	movl $58, %eax
	pushl %eax
	call outbyte1
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:comma(){outbyte(',');}
	.text
	.align 16
.globl comma
	.TYPE	comma,@function
comma:
	pushl %ebp
	movl %esp, %ebp
	movl $44, %eax
	pushl %eax
	call outbyte
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:comma1(){outbyte1(',');}
	.text
	.align 16
.globl comma1
	.TYPE	comma1,@function
comma1:
	pushl %ebp
	movl %esp, %ebp
	movl $44, %eax
	pushl %eax
	call outbyte1
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:bell()        /* gtf 7/16/80 */
	.text
	.align 16
.globl bell
	.TYPE	bell,@function
bell:
#:  {outbyte(7);}
	pushl %ebp
	movl %esp, %ebp
	movl $7, %eax
	pushl %eax
	call outbyte
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:/*        replaced 7/2/80 gtf
#: * error(ptr)
#: *  char ptr[];
#: * {
#: *  int k;
#: *  comment();outstr(line);nl();comment();
#: *  k=0;
#: *  while(k<lptr)
#: *    {if(line[k]==9) tab();
#: *      else outbyte(' ');
#: *    ++k;
#: *    }
#: *  outbyte('^');
#: *  nl();comment();outstr("******  ");
#: *  outstr(ptr);
#: *  outstr("  ******");
#: *  nl();
#: *  ++errcnt;
#: * }
#: */
#:error(ptr)
	.text
	.align 16
.globl error
	.TYPE	error,@function
error:
#:char ptr[];
	pushl %ebp
	movl %esp, %ebp
#:{  int k;
	pushl %edx
#:  char junk[81];
	subl $84, %esp
#:  toconsole();
	call toconsol
#:  bell();
	call bell
#:  outstr("Line "); outdec(lineno); outstr(", ");
	movl $cc1+1532, %eax
	pushl %eax
	call outstr
	popl %edx
	movl lineno, %eax
	pushl %eax
	call outdec
	popl %edx
	movl $cc1+1538, %eax
	pushl %eax
	call outstr
	popl %edx
#:  if(infunc==0)
	movl infunc, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc337
#:    outbyte('(');
	movl $40, %eax
	pushl %eax
	call outbyte
	popl %edx
#:  if(currfn==NULL)
cc337:
	movl currfn, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc338
#:    outstr("start of file");
	movl $cc1+1541, %eax
	pushl %eax
	call outstr
	popl %edx
#:  else  outstr(currfn+NAME);
	jmp cc339
cc338:
	movl currfn, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call outstr
	popl %edx
cc339:
#:  if(infunc==0)
	movl infunc, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc340
#:    outbyte(')');
	movl $41, %eax
	pushl %eax
	call outbyte
	popl %edx
#:  outstr(" + ");
cc340:
	movl $cc1+1555, %eax
	pushl %eax
	call outstr
	popl %edx
#:  outdec(lineno-fnstart);
	movl lineno, %eax
	pushl %eax
	movl fnstart, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	call outdec
	popl %edx
#:  outstr(": ");  outstr(ptr);  nl();
	movl $cc1+1559, %eax
	pushl %eax
	call outstr
	popl %edx
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outstr
	popl %edx
	call nl
#:  outstr(line); nl();
	movl 	$line, %eax
	pushl %eax
	call outstr
	popl %edx
	call nl
#:  k=0;  /* skip to error position */
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while(k<lptr){
cc341:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc342
#:    if(line[k++]==9)
	movl 	$line, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $9, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc343
#:      tab();
	call tab
#:    else  outbyte(' ');
	jmp cc344
cc343:
	movl $32, %eax
	pushl %eax
	call outbyte
	popl %edx
cc344:
#:    }
	jmp cc341
cc342:
#:  outbyte('^');  nl();
	movl $94, %eax
	pushl %eax
	call outbyte
	popl %edx
	call nl
#:  ++errcnt;
	movl errcnt, %eax
	incl %eax
	movl %eax, errcnt
#:  if(errstop){
	movl errstop, %eax
	testl %eax, %eax
	je	cc345
#:    pl("Continue (Y,n,g) ? ");
	movl $cc1+1562, %eax
	pushl %eax
	call pl
	popl %edx
#:    gets(junk);    
	leal	-88(%ebp), %eax
	pushl %eax
	call gets
	popl %edx
#:    k=junk[0];
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-88(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movl %eax, (%edx)
#:    if((k=='N') | (k=='n'))
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $78, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $110, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc346
#:      zabort();
	call zabort
#:    if((k=='G') | (k=='g'))
cc346:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $71, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $103, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc347
#:      errstop=0;
	movl $0, %eax
	movl %eax, errstop
#:    }
cc347:
#:  tofile();
cc345:
	call tofile
#:/* end error */}
	movl %ebp, %esp
	popl %ebp
	ret
#:ol(ptr)
	.text
	.align 16
.globl ol
	.TYPE	ol,@function
ol:
#:  char ptr[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  ot(ptr);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call ot
	popl %edx
#:  nl();
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:ot(ptr)
	.text
	.align 16
.globl ot
	.TYPE	ot,@function
ot:
#:  char ptr[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  tab();
	call tab
#:  outasm(ptr);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outasm
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:streq(str1,str2)
	.text
	.align 16
.globl streq
	.TYPE	streq,@function
streq:
#:  char str1[],str2[];
	pushl %ebp
	movl %esp, %ebp
#: {
#:  int k;
	pushl %edx
#:  k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while (str2[k])
cc348:
	leal	12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc349
#:    {if ((str1[k])!=(str2[k])) return 0;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	leal	12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc350
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    k++;
cc350:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
#:    }
	jmp cc348
cc349:
#:  return k;
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#: }
	movl %ebp, %esp
	popl %ebp
	ret
#:astreq(str1,str2,len)
	.text
	.align 16
.globl astreq
	.TYPE	astreq,@function
astreq:
#:  char str1[],str2[];int len;
	pushl %ebp
	movl %esp, %ebp
#: {
#:  int k;
	pushl %edx
#:  k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  while (k<len)
cc351:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	16(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc352
#:    {if ((str1[k])!=(str2[k]))break;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	leal	12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc353
	jmp cc352
#:    if(str1[k]==0)break;
cc353:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc354
	jmp cc352
#:    if(str2[k]==0)break;
cc354:
	leal	12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc355
	jmp cc352
#:    k++;
cc355:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
#:    }
	jmp cc351
cc352:
#:  if (an(str1[k]))return 0;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc356
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if (an(str2[k]))return 0;
cc356:
	leal	12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc357
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  return k;
cc357:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#: }
	movl %ebp, %esp
	popl %ebp
	ret
#:match(lit)
	.text
	.align 16
.globl match
	.TYPE	match,@function
match:
#:  char *lit;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k;
	pushl %edx
#:  blanks();
	call blanks
#:  if (k=streq(line+lptr,lit))
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	popl %edx
	movl %eax, (%edx)
	testl %eax, %eax
	je	cc358
#:    {lptr=lptr+k;
	movl lptr, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movl %eax, lptr
#:    return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:   return 0;
cc358:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:amatch(lit,len)
	.text
	.align 16
.globl amatch
	.TYPE	amatch,@function
amatch:
#:  char *lit;int len;
	pushl %ebp
	movl %esp, %ebp
#: {
#:  int k;
	pushl %edx
#:  blanks();
	call blanks
#:  if (k=astreq(line+lptr,lit,len))
	leal	-4(%ebp), %eax
	pushl %eax
	leal	12(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call astreq
	addl $12, %esp
	popl %edx
	movl %eax, (%edx)
	testl %eax, %eax
	je	cc359
#:    {lptr=lptr+k;
	movl lptr, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	addl %edx, %eax
	movl %eax, lptr
#:    while(an(ch())) inbyte();
cc360:
	call ch
	pushl %eax
	call an
	popl %edx
	testl %eax, %eax
	je	cc361
	call inbyte
	jmp cc360
cc361:
#:    return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  return 0;
cc359:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#: }
	movl %ebp, %esp
	popl %ebp
	ret
#:blanks()
	.text
	.align 16
.globl blanks
	.TYPE	blanks,@function
blanks:
#:  {while(1)
	pushl %ebp
	movl %esp, %ebp
cc362:
	movl $1, %eax
	testl %eax, %eax
	je	cc363
#:    {while(ch()==0)
cc364:
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc365
#:      {insline();
	call insline
#:      preprocess();
	call preproce
#:      if(eof)break;
	movl eof, %eax
	testl %eax, %eax
	je	cc366
	jmp cc365
#:      }
cc366:
	jmp cc364
cc365:
#:    if(ch()==' ')gch();
	call ch
	pushl %eax
	movl $32, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc367
	call gch
#:    else if(ch()==9)gch();
	jmp cc368
cc367:
	call ch
	pushl %eax
	movl $9, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc369
	call gch
#:    else return;
	jmp cc370
cc369:
	movl %ebp, %esp
	popl %ebp
	ret
cc370:
cc368:
#:    }
	jmp cc362
cc363:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* output a decimal number - rewritten 4/1/81 gtf */
#:outdec(n)
	.text
	.align 16
.globl outdec
	.TYPE	outdec,@function
outdec:
#:int n;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  if(n<0)
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc371
#:    outbyte('-');
	movl $45, %eax
	pushl %eax
	call outbyte
	popl %edx
#:  else  n = -n;
	jmp cc372
cc371:
	leal	8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	negl %eax
	popl %edx
	movl %eax, (%edx)
cc372:
#:  outint(n);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outint
	popl %edx
#:/* end outdec */}
	movl %ebp, %esp
	popl %ebp
	ret
#:outint(n)  /* added 4/1/81 */
	.text
	.align 16
.globl outint
	.TYPE	outint,@function
outint:
#:int n;
	pushl %ebp
	movl %esp, %ebp
#:{  int q;
	pushl %edx
#:  q = n/10;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	popl %edx
	movl %eax, (%edx)
#:  if(q) outint(q);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc373
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outint
	popl %edx
#:  outbyte('0'-(n-q*10));
cc373:
	movl $48, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	imull %edx
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	call outbyte
	popl %edx
#:/* end outint */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* return the length of a string */
#:/* gtf 4/8/80 */
#:strlen(s)
	.text
	.align 16
.globl strlen
	.TYPE	strlen,@function
strlen:
#:char *s;
	pushl %ebp
	movl %esp, %ebp
#:{  char *t;
	pushl %edx
#:  t = s;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:  while(*s) s++;
cc374:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc375
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	jmp cc374
cc375:
#:  return(s-t);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:/* end strlen */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* convert lower case to upper */
#:/* gtf 6/26/80 */
#:raise(c)
	.text
	.align 16
.globl raise
	.TYPE	raise,@function
raise:
#:char c;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  if((c>='a') & (c<='z'))
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $97, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $122, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc376
#:    c = c - 'a' + 'A';
	leal	8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $97, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	movl $65, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movb %al, (%edx)
#:  return(c);
cc376:
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	movl %ebp, %esp
	popl %ebp
	ret
#:/* end raise */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* ------------------------------------------------------------- */
#:/*  >>>>>>> start of cc5 <<<<<<<  */
#:/* as of 5/5/81 rj */
#:expression()
	.text
	.align 16
.globl expressi
	.TYPE	expressi,@function
expressi:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  int lval[2];
	subl $8, %esp
#:  if(heir1(lval))rvalue(lval);
	leal	-8(%ebp), %eax
	pushl %eax
	call heir1
	popl %edx
	testl %eax, %eax
	je	cc377
	leal	-8(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:}
cc377:
	movl %ebp, %esp
	popl %ebp
	ret
#:heir1(lval)
	.text
	.align 16
.globl heir1
	.TYPE	heir1,@function
heir1:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir2(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir2
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  if (match("=")) {
	movl $cc1+1582, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc378
#:    if(k==0){needlval();return 0;}
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc379
	call needlval
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    if (lval[1])zpush();
cc379:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc380
	call zpush
#:    if(heir1(lval2))rvalue(lval2);
cc380:
	leal	-12(%ebp), %eax
	pushl %eax
	call heir1
	popl %edx
	testl %eax, %eax
	je	cc381
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    store(lval);
cc381:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call store
	popl %edx
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  }
#:  else return k;
	jmp cc382
cc378:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc382:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir2(lval)
	.text
	.align 16
.globl heir2
	.TYPE	heir2,@function
heir2:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir3(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir3
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if(ch()!='|')return k;
	call ch
	pushl %eax
	movl $124, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc383
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc383:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc384
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc384:
cc385:
	movl $1, %eax
	testl %eax, %eax
	je	cc386
#:    {if (match("|"))
	movl $cc1+1584, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc387
#:      {zpush();
	call zpush
#:      if(heir3(lval2)) rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir3
	popl %edx
	testl %eax, %eax
	je	cc388
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc388:
	call zpop
#:      zor();
	call zor
#:      }
#:    else return 0;
	jmp cc389
cc387:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc389:
#:    }
	jmp cc385
cc386:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir3(lval)
	.text
	.align 16
.globl heir3
	.TYPE	heir3,@function
heir3:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir4(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir4
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if(ch()!='^')return k;
	call ch
	pushl %eax
	movl $94, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc390
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc390:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc391
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc391:
cc392:
	movl $1, %eax
	testl %eax, %eax
	je	cc393
#:    {if (match("^"))
	movl $cc1+1586, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc394
#:      {zpush();
	call zpush
#:      if(heir4(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir4
	popl %edx
	testl %eax, %eax
	je	cc395
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc395:
	call zpop
#:      zxor();
	call zxor
#:      }
#:    else return 0;
	jmp cc396
cc394:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc396:
#:    }
	jmp cc392
cc393:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir4(lval)
	.text
	.align 16
.globl heir4
	.TYPE	heir4,@function
heir4:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir5(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir5
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if(ch()!='&')return k;
	call ch
	pushl %eax
	movl $38, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc397
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc397:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc398
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc398:
cc399:
	movl $1, %eax
	testl %eax, %eax
	je	cc400
#:    {if (match("&"))
	movl $cc1+1588, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc401
#:      {zpush();
	call zpush
#:      if(heir5(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir5
	popl %edx
	testl %eax, %eax
	je	cc402
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc402:
	call zpop
#:      zand();
	call zand
#:      }
#:    else return 0;
	jmp cc403
cc401:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc403:
#:    }
	jmp cc399
cc400:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir5(lval)
	.text
	.align 16
.globl heir5
	.TYPE	heir5,@function
heir5:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir6(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir6
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if((streq(line+lptr,"==")==0)&
	movl $cc1+1590, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:    (streq(line+lptr,"!=")==0))return k;
	movl $cc1+1593, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc404
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc404:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc405
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc405:
cc406:
	movl $1, %eax
	testl %eax, %eax
	je	cc407
#:    {if (match("=="))
	movl $cc1+1596, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc408
#:      {zpush();
	call zpush
#:      if(heir6(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir6
	popl %edx
	testl %eax, %eax
	je	cc409
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc409:
	call zpop
#:      zeq();
	call zeq
#:      }
#:    else if (match("!="))
	jmp cc410
cc408:
	movl $cc1+1599, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc411
#:      {zpush();
	call zpush
#:      if(heir6(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir6
	popl %edx
	testl %eax, %eax
	je	cc412
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc412:
	call zpop
#:      zne();
	call zne
#:      }
#:    else return 0;
	jmp cc413
cc411:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc413:
cc410:
#:    }
	jmp cc406
cc407:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir6(lval)
	.text
	.align 16
.globl heir6
	.TYPE	heir6,@function
heir6:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir7(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir7
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if((streq(line+lptr,"<")==0)&
	movl $cc1+1602, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:    (streq(line+lptr,">")==0)&
	movl $cc1+1604, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
#:    (streq(line+lptr,"<=")==0)&
	movl $cc1+1606, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
#:    (streq(line+lptr,">=")==0))return k;
	movl $cc1+1609, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc414
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    if(streq(line+lptr,">>"))return k;
cc414:
	movl $cc1+1612, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	testl %eax, %eax
	je	cc415
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    if(streq(line+lptr,"<<"))return k;
cc415:
	movl $cc1+1615, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	testl %eax, %eax
	je	cc416
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc416:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc417
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc417:
cc418:
	movl $1, %eax
	testl %eax, %eax
	je	cc419
#:    {if (match("<="))
	movl $cc1+1618, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc420
#:      {zpush();
	call zpush
#:      if(heir7(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir7
	popl %edx
	testl %eax, %eax
	je	cc421
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc421:
	call zpop
#:      if(cptr=lval[0])
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc422
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc423
#:        {ule();
	call ule
#:        continue;
	jmp cc418
#:        }
#:      if(cptr=lval2[0])
cc423:
cc422:
	leal	-12(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc424
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc425
#:        {ule();
	call ule
#:        continue;
	jmp cc418
#:        }
#:      zle();
cc425:
cc424:
	call zle
#:      }
#:    else if (match(">="))
	jmp cc426
cc420:
	movl $cc1+1621, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc427
#:      {zpush();
	call zpush
#:      if(heir7(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir7
	popl %edx
	testl %eax, %eax
	je	cc428
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc428:
	call zpop
#:      if(cptr=lval[0])
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc429
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc430
#:        {uge();
	call uge
#:        continue;
	jmp cc418
#:        }
#:      if(cptr=lval2[0])
cc430:
cc429:
	leal	-12(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc431
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc432
#:        {uge();
	call uge
#:        continue;
	jmp cc418
#:        }
#:      zge();
cc432:
cc431:
	call zge
#:      }
#:    else if((streq(line+lptr,"<"))&
	jmp cc433
cc427:
	movl $cc1+1624, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
#:      (streq(line+lptr,"<<")==0))
	movl $cc1+1626, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc434
#:      {inbyte();
	call inbyte
#:      zpush();
	call zpush
#:      if(heir7(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir7
	popl %edx
	testl %eax, %eax
	je	cc435
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc435:
	call zpop
#:      if(cptr=lval[0])
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc436
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc437
#:        {ult();
	call ult
#:        continue;
	jmp cc418
#:        }
#:      if(cptr=lval2[0])
cc437:
cc436:
	leal	-12(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc438
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc439
#:        {ult();
	call ult
#:        continue;
	jmp cc418
#:        }
#:      zlt();
cc439:
cc438:
	call zlt
#:      }
#:    else if((streq(line+lptr,">"))&
	jmp cc440
cc434:
	movl $cc1+1629, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
#:      (streq(line+lptr,">>")==0))
	movl $cc1+1631, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc441
#:      {inbyte();
	call inbyte
#:      zpush();
	call zpush
#:      if(heir7(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir7
	popl %edx
	testl %eax, %eax
	je	cc442
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc442:
	call zpop
#:      if(cptr=lval[0])
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc443
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc444
#:        {ugt();
	call ugt
#:        continue;
	jmp cc418
#:        }
#:      if(cptr=lval2[0])
cc444:
cc443:
	leal	-12(%ebp), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc445
#:        if(cptr[IDENT]==POINTER)
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc446
#:        {ugt();
	call ugt
#:        continue;
	jmp cc418
#:        }
#:      zgt();
cc446:
cc445:
	call zgt
#:      }
#:    else return 0;
	jmp cc447
cc441:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc447:
cc440:
cc433:
cc426:
#:    }
	jmp cc418
cc419:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*  >>>>>> start of cc6 <<<<<<  */
#:heir7(lval)
	.text
	.align 16
.globl heir7
	.TYPE	heir7,@function
heir7:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir8(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir8
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if((streq(line+lptr,">>")==0)&
	movl $cc1+1634, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:    (streq(line+lptr,"<<")==0))return k;
	movl $cc1+1637, %eax
	pushl %eax
	movl 	$line, %eax
	pushl %eax
	movl lptr, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call streq
	addl $8, %esp
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc448
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc448:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc449
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc449:
cc450:
	movl $1, %eax
	testl %eax, %eax
	je	cc451
#:    {if (match(">>"))
	movl $cc1+1640, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc452
#:      {zpush();
	call zpush
#:      if(heir8(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir8
	popl %edx
	testl %eax, %eax
	je	cc453
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc453:
	call zpop
#:      asr();
	call asr
#:      }
#:    else if (match("<<"))
	jmp cc454
cc452:
	movl $cc1+1643, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc455
#:      {zpush();
	call zpush
#:      if(heir8(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir8
	popl %edx
	testl %eax, %eax
	je	cc456
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc456:
	call zpop
#:      asl();
	call asl
#:      }
#:    else return 0;
	jmp cc457
cc455:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc457:
cc454:
#:    }
	jmp cc450
cc451:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir8(lval)
	.text
	.align 16
.globl heir8
	.TYPE	heir8,@function
heir8:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir9(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir9
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if((ch()!='+')&(ch()!='-'))return k;
	call ch
	pushl %eax
	movl $43, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $45, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc458
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc458:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc459
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc459:
cc460:
	movl $1, %eax
	testl %eax, %eax
	je	cc461
#:    {if (match("+"))
	movl $cc1+1646, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc462
#:      {zpush();
	call zpush
#:      if(heir9(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir9
	popl %edx
	testl %eax, %eax
	je	cc463
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      if(cptr=lval[0])
cc463:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc464
#:        if((
#:          (cptr[IDENT]==ARRAY)|
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:           (cptr[IDENT]==POINTER))&
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	pushl %eax
#:         (cptr[TYPE]==CINT))/* modified by E.V. */
	movl cptr, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc465
#:          /*doublereg();*/ol("sall $2, %eax");
	movl $cc1+1648, %eax
	pushl %eax
	call ol
	popl %edx
#:      zpop();
cc465:
cc464:
	call zpop
#:      zadd();
	call zadd
#:      }
#:    else if (match("-"))
	jmp cc466
cc462:
	movl $cc1+1662, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc467
#:      {zpush();
	call zpush
#:      if(heir9(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir9
	popl %edx
	testl %eax, %eax
	je	cc468
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      if(cptr=lval[0])
cc468:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	movl %eax, cptr
	testl %eax, %eax
	je	cc469
#:        if(((cptr[IDENT]==POINTER)|(cptr[IDENT]==ARRAY))&
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	movl cptr, %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	pushl %eax
#:        (cptr[TYPE]==CINT))
	movl cptr, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc470
#:          /*doublereg();*/ol("sall $2, %eax");
	movl $cc1+1664, %eax
	pushl %eax
	call ol
	popl %edx
#:      zpop();
cc470:
cc469:
	call zpop
#:      zsub();
	call zsub
#:      }
#:    else return 0;
	jmp cc471
cc467:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc471:
cc466:
#:    }
	jmp cc460
cc461:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir9(lval)
	.text
	.align 16
.globl heir9
	.TYPE	heir9,@function
heir9:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k,lval2[2];
	pushl %edx
	subl $8, %esp
#:  k=heir10(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if((ch()!='*')&(ch()!='/')&
	call ch
	pushl %eax
	movl $42, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $47, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
#:    (ch()!='%'))return k;
	call ch
	pushl %eax
	movl $37, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc472
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k)rvalue(lval);
cc472:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc473
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:  while(1)
cc473:
cc474:
	movl $1, %eax
	testl %eax, %eax
	je	cc475
#:    {if (match("*"))
	movl $cc1+1678, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc476
#:      {zpush();
	call zpush
#:      if(heir9(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir9
	popl %edx
	testl %eax, %eax
	je	cc477
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc477:
	call zpop
#:      mult();
	call mult
#:      }
#:    else if (match("/"))
	jmp cc478
cc476:
	movl $cc1+1680, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc479
#:      {zpush();
	call zpush
#:      if(heir10(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir10
	popl %edx
	testl %eax, %eax
	je	cc480
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc480:
	call zpop
#:      div();
	call div
#:      }
#:    else if (match("%"))
	jmp cc481
cc479:
	movl $cc1+1682, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc482
#:      {zpush();
	call zpush
#:      if(heir10(lval2))rvalue(lval2);
	leal	-12(%ebp), %eax
	pushl %eax
	call heir10
	popl %edx
	testl %eax, %eax
	je	cc483
	leal	-12(%ebp), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      zpop();
cc483:
	call zpop
#:      zmod();
	call zmod
#:      }
#:    else return 0;
	jmp cc484
cc482:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc484:
cc481:
cc478:
#:    }
	jmp cc474
cc475:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:heir10(lval)
	.text
	.align 16
.globl heir10
	.TYPE	heir10,@function
heir10:
#:  int lval[];
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int k;
	pushl %edx
#:  char *ptr;
	pushl %edx
#:  if(match("++"))
	movl $cc1+1684, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc485
#:    {if((k=heir10(lval))==0)
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc486
#:      {needlval();
	call needlval
#:      return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    if(lval[1])zpush();
cc486:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc487
	call zpush
#:    rvalue(lval);
cc487:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    inc();
	call inc
#:    ptr=lval[0];
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:    if((ptr[IDENT]==POINTER)&
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:      (ptr[TYPE]==CINT))
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc488
#:      {inc();inc();inc();}
	call inc
	call inc
	call inc
#:    store(lval);
cc488:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call store
	popl %edx
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  else if(match("--"))
	jmp cc489
cc485:
	movl $cc1+1687, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc490
#:    {if((k=heir10(lval))==0)
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc491
#:      {needlval();
	call needlval
#:      return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    if(lval[1])zpush();
cc491:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc492
	call zpush
#:    rvalue(lval);
cc492:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    dec();
	call dec
#:    ptr=lval[0];
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:    if((ptr[IDENT]==POINTER)&
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:      (ptr[TYPE]==CINT))
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc493
#:      {dec();dec();dec();}
	call dec
	call dec
	call dec
#:    store(lval);
cc493:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call store
	popl %edx
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  else if (match("-"))
	jmp cc494
cc490:
	movl $cc1+1690, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc495
#:    {k=heir10(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    if (k) rvalue(lval);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc496
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    neg();
cc496:
	call neg
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  else if(match("*"))
	jmp cc497
cc495:
	movl $cc1+1692, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc498
#:    {k=heir10(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    if(k)rvalue(lval);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc499
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    lval[1]=CINT;
cc499:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	movl %eax, (%edx)
#:    if(ptr=lval[0])lval[1]=ptr[TYPE];
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
	testl %eax, %eax
	je	cc500
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movl %eax, (%edx)
#:    lval[0]=0;
cc500:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:    return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  else if(match("!"))/*added by E.V.*/
	jmp cc501
cc498:
	movl $cc1+1694, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc502
#:    {
#:    k=heir10(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    if(k)rvalue(lval);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc503
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    lnot();
cc503:
	call lnot
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  else if(match("~"))/*added by E.V.*/
	jmp cc504
cc502:
	movl $cc1+1696, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc505
#:    {
#:    k=heir10(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    if(k)rvalue(lval);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc506
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:    bnot();
cc506:
	call bnot
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  else if(match("&"))
	jmp cc507
cc505:
	movl $cc1+1698, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc508
#:    {
#:    k=heir10(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir10
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    if(k==0)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc509
#:      {
#:      error("illegal address");
	movl $cc1+1700, %eax
	pushl %eax
	call error
	popl %edx
#:      return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    else if(lval[1])return 0;
	jmp cc510
cc509:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc511
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    else
	jmp cc512
cc511:
#:      {
#:        immed();
	call immed
#:        ot("$");
	movl $cc1+1716, %eax
	pushl %eax
	call ot
	popl %edx
#:        outasm(ptr=lval[0]);
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
	pushl %eax
	call outasm
	popl %edx
#:        outasm(", %eax");
	movl $cc1+1718, %eax
	pushl %eax
	call outasm
	popl %edx
#:        nl();
	call nl
#:        lval[1]=ptr[TYPE];
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movl %eax, (%edx)
#:        return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
cc512:
cc510:
#:    }
#:  else 
	jmp cc513
cc508:
#:    {k=heir11(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir11
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    if(match("++"))
	movl $cc1+1725, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc514
#:      {if(k==0)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc515
#:        {needlval();
	call needlval
#:        return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:        }
#:      if(lval[1])zpush();
cc515:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc516
	call zpush
#:      rvalue(lval);
cc516:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      inc();
	call inc
#:      ptr=lval[0];
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:      if(ptr)
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc517
#:        if((ptr[IDENT]==POINTER)&
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:         (ptr[TYPE]==CINT))
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc518
#:        {inc();inc();inc();}
	call inc
	call inc
	call inc
#:      store(lval);
cc518:
cc517:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call store
	popl %edx
#:      dec();
	call dec
#:      if(ptr)
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc519
#:        if((ptr[IDENT]==POINTER)&
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:         (ptr[TYPE]==CINT))
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc520
#:        {dec();dec();dec();}
	call dec
	call dec
	call dec
#:      return 0;
cc520:
cc519:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    else if(match("--"))
	jmp cc521
cc514:
	movl $cc1+1728, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc522
#:      {if(k==0)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc523
#:        {needlval();
	call needlval
#:        return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:        }
#:      if(lval[1])zpush();
cc523:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc524
	call zpush
#:      rvalue(lval);
cc524:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      dec();
	call dec
#:      ptr=lval[0];
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:      if(ptr)
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc525
#:        if((ptr[IDENT]==POINTER)&
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:         (ptr[TYPE]==CINT))
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc526
#:        {dec();dec();dec();}
	call dec
	call dec
	call dec
#:      store(lval);
cc526:
cc525:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call store
	popl %edx
#:      inc();
	call inc
#:      if(ptr)
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc527
#:        if((ptr[IDENT]==POINTER)&
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
#:         (ptr[TYPE]==CINT))
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc528
#:        {inc();inc();inc();}
	call inc
	call inc
	call inc
#:      return 0;
cc528:
cc527:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    else return k;
	jmp cc529
cc522:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc529:
cc521:
#:    }
cc513:
cc507:
cc504:
cc501:
cc497:
cc494:
cc489:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/*  >>>>>> start of cc7 <<<<<<  */
#:heir11(lval)
	.text
	.align 16
.globl heir11
	.TYPE	heir11,@function
heir11:
#:  int *lval;
	pushl %ebp
	movl %esp, %ebp
#:{  int k;char *ptr;
	pushl %edx
	pushl %edx
#:  k=primary(lval);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call primary
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  ptr=lval[0];
	leal	-8(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:  blanks();
	call blanks
#:  if((ch()=='[')|(ch()=='('))
	call ch
	pushl %eax
	movl $91, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $40, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc530
#:  while(1)
cc531:
	movl $1, %eax
	testl %eax, %eax
	je	cc532
#:    {if(match("["))
	movl $cc1+1731, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc533
#:      {if(ptr==0)
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc534
#:        {error("can't subscript");
	movl $cc1+1733, %eax
	pushl %eax
	call error
	popl %edx
#:        junk();
	call junk
#:        needbrack("]");
	movl $cc1+1749, %eax
	pushl %eax
	call needbrac
	popl %edx
#:        return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:        }
#:      else if(ptr[IDENT]==POINTER)rvalue(lval);
	jmp cc535
cc534:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc536
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:      else if(ptr[IDENT]!=ARRAY)
	jmp cc537
cc536:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc538
#:        {error("can't subscript");
	movl $cc1+1751, %eax
	pushl %eax
	call error
	popl %edx
#:        k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:        }
#:      zpush();
cc538:
cc537:
cc535:
	call zpush
#:      expression();
	call expressi
#:      needbrack("]");
	movl $cc1+1767, %eax
	pushl %eax
	call needbrac
	popl %edx
#:      if(ptr[TYPE]==CINT)/*doublereg();*/ol("sall $2, %eax");
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc539
	movl $cc1+1769, %eax
	pushl %eax
	call ol
	popl %edx
#:      zpop();
cc539:
	call zpop
#:      zadd();
	call zadd
#:      lval[1]=ptr[TYPE];
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movl %eax, (%edx)
#:        /* 4/1/81 - after subscripting, not ptr anymore */
#:      lval[0]=0;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:      k=1;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
#:      }
#:    else if(match("("))
	jmp cc540
cc533:
	movl $cc1+1783, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc541
#:      {if(ptr==0)
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc542
#:        {callfunction(0);
	movl $0, %eax
	pushl %eax
	call callfunc
	popl %edx
#:        }
#:      else if(ptr[IDENT]!=FUNCTION)
	jmp cc543
cc542:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc544
#:        {rvalue(lval);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call rvalue
	popl %edx
#:        callfunction(0);
	movl $0, %eax
	pushl %eax
	call callfunc
	popl %edx
#:        }
#:      else callfunction(ptr);
	jmp cc545
cc544:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call callfunc
	popl %edx
cc545:
cc543:
#:      k=lval[0]=0;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
	popl %edx
	movl %eax, (%edx)
#:      }
#:    else return k;
	jmp cc546
cc541:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc546:
cc540:
#:    }
	jmp cc531
cc532:
#:  if(ptr==0)return k;
cc530:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc547
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(ptr[IDENT]==FUNCTION)
cc547:
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc548
#:    {immed();
	call immed
#:    outname(ptr);
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outname
	popl %edx
#:    outasm(", %eax");
	movl $cc1+1785, %eax
	pushl %eax
	call outasm
	popl %edx
#:    nl();
	call nl
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  return k;
cc548:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:primary(lval)
	.text
	.align 16
.globl primary
	.TYPE	primary,@function
primary:
#:  int *lval;
	pushl %ebp
	movl %esp, %ebp
#:{  char *ptr,sname[NAMESIZE];int num[1];
	pushl %edx
	subl $12, %esp
	pushl %edx
#:  int k;
	pushl %edx
#:  if(match("("))
	movl $cc1+1792, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc549
#:    {k=heir1(lval);
	leal	-24(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call heir1
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:    needbrack(")");
	movl $cc1+1794, %eax
	pushl %eax
	call needbrac
	popl %edx
#:    return k;
	leal	-24(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  if(symname(sname))
cc549:
	leal	-16(%ebp), %eax
	pushl %eax
	call symname
	popl %edx
	testl %eax, %eax
	je	cc550
#:    {if(ptr=findloc(sname))
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-16(%ebp), %eax
	pushl %eax
	call findloc
	popl %edx
	popl %edx
	movl %eax, (%edx)
	testl %eax, %eax
	je	cc551
#:      {getloc(ptr);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call getloc
	popl %edx
#:      lval[0]=ptr;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:      lval[1]=ptr[TYPE];
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movl %eax, (%edx)
#:      if(ptr[IDENT]==POINTER)lval[1]=CINT;
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc552
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	movl %eax, (%edx)
#:      if(ptr[IDENT]==ARRAY)return 0;
cc552:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc553
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:        else return 1;
	jmp cc554
cc553:
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc554:
#:      }
#:    if(ptr=findglb(sname))
cc551:
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-16(%ebp), %eax
	pushl %eax
	call findglb
	popl %edx
	popl %edx
	movl %eax, (%edx)
	testl %eax, %eax
	je	cc555
#:      if(ptr[IDENT]!=FUNCTION)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $4, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc556
#:      {lval[0]=ptr;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:      lval[1]=0;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:      if(ptr[IDENT]!=ARRAY)return 1;
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc557
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      
#:      immed();ot("$");/*handling the ARRAY address- by E.V.*/
cc557:
	call immed
	movl $cc1+1796, %eax
	pushl %eax
	call ot
	popl %edx
#:      outasm(ptr);
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outasm
	popl %edx
#:      outasm(", %eax");nl();
	movl $cc1+1798, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:      lval[1]=ptr[TYPE];
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	popl %edx
	movl %eax, (%edx)
#:      return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    ptr=addglb(sname,FUNCTION,CINT,0);
cc556:
cc555:
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	pushl %eax
	movl $2, %eax
	pushl %eax
	movl $4, %eax
	pushl %eax
	leal	-16(%ebp), %eax
	pushl %eax
	call addglb
	addl $16, %esp
	popl %edx
	movl %eax, (%edx)
#:    lval[0]=ptr;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:    lval[1]=0;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  if(constant(num))
cc550:
	leal	-20(%ebp), %eax
	pushl %eax
	call constant
	popl %edx
	testl %eax, %eax
	je	cc558
#:    return(lval[0]=lval[1]=0);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
	popl %edx
	movl %eax, (%edx)
	movl %ebp, %esp
	popl %ebp
	ret
#:  else
	jmp cc559
cc558:
#:    {error("invalid expression");
	movl $cc1+1805, %eax
	pushl %eax
	call error
	popl %edx
#:    immed();outdec(0);
	call immed
	movl $0, %eax
	pushl %eax
	call outdec
	popl %edx
#:    comma();outasm(", %eax");nl();
	call comma
	movl $cc1+1824, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:    junk();
	call junk
#:    return 0;
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
cc559:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:store(lval)
	.text
	.align 16
.globl store
	.TYPE	store,@function
store:
#:  int *lval;
	pushl %ebp
	movl %esp, %ebp
#:{  if (lval[1]==0)putmem(lval[0]);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc560
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call putmem
	popl %edx
#:  else putstk(lval[1]);
	jmp cc561
cc560:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call putstk
	popl %edx
cc561:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:rvalue(lval)
	.text
	.align 16
.globl rvalue
	.TYPE	rvalue,@function
rvalue:
#:  int *lval;
	pushl %ebp
	movl %esp, %ebp
#:{  if((lval[0] != 0) & (lval[1] == 0))
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc562
#:    getmem(lval[0]);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call getmem
	popl %edx
#:    else indirect(lval[1]);
	jmp cc563
cc562:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call indirect
	popl %edx
cc563:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:test(label)
	.text
	.align 16
.globl test
	.TYPE	test,@function
test:
#:  int label;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  needbrack("(");
	movl $cc1+1831, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  expression();
	call expressi
#:  needbrack(")");
	movl $cc1+1833, %eax
	pushl %eax
	call needbrac
	popl %edx
#:  testjump(label);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call testjump
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:constant(val)
	.text
	.align 16
.globl constant
	.TYPE	constant,@function
constant:
#:  int val[];
	pushl %ebp
	movl %esp, %ebp
#:{  if (number(val))
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call number
	popl %edx
	testl %eax, %eax
	je	cc564
#:  {immed();outasm("$");}
	call immed
	movl $cc1+1835, %eax
	pushl %eax
	call outasm
	popl %edx
#:  else if (pstr(val))
	jmp cc565
cc564:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call pstr
	popl %edx
	testl %eax, %eax
	je	cc566
#:    {immed();outasm("$");}
	call immed
	movl $cc1+1837, %eax
	pushl %eax
	call outasm
	popl %edx
#:  else if (qstr(val))
	jmp cc567
cc566:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call qstr
	popl %edx
	testl %eax, %eax
	je	cc568
#:    {immed();outasm("$");printlabel(litlab);
	call immed
	movl $cc1+1839, %eax
	pushl %eax
	call outasm
	popl %edx
	movl litlab, %eax
	pushl %eax
	call printlab
	popl %edx
#:    outbyte('+');/*outasm("$");*/}
	movl $43, %eax
	pushl %eax
	call outbyte
	popl %edx
#:  else return 0;  
	jmp cc569
cc568:
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
cc569:
cc567:
cc565:
#:  outdec(val[0]);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	movl (%eax), %eax
	pushl %eax
	call outdec
	popl %edx
#:  outasm(", %eax");
	movl $cc1+1841, %eax
	pushl %eax
	call outasm
	popl %edx
#:  nl();
	call nl
#:  return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:number(val)
	.text
	.align 16
.globl number
	.TYPE	number,@function
number:
#:  int val[];
	pushl %ebp
	movl %esp, %ebp
#:{  int k,minus;char c;
	pushl %edx
	pushl %edx
	pushl %edx
#: int d; 
	pushl %edx
#:  k=minus=1;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-8(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
	popl %edx
	movl %eax, (%edx)
#:  if(match("0x"))
	movl $cc1+1848, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc570
#:    {
#:    k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:    while(numeric(ch())|((ch()>='a')&(ch()<='f')))
cc571:
	call ch
	pushl %eax
	call numeric
	popl %edx
	pushl %eax
	call ch
	pushl %eax
	movl $97, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	pushl %eax
	call ch
	pushl %eax
	movl $102, %eax
	popl %edx
	cmpl	%eax, %edx
	setle	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	orl %edx, %eax
	testl %eax, %eax
	je	cc572
#:      {
#:      c=inbyte();
	leal	-12(%ebp), %eax
	pushl %eax
	call inbyte
	popl %edx
	movb %al, (%edx)
#:      if(numeric(c))
	leal	-12(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	call numeric
	popl %edx
	testl %eax, %eax
	je	cc573
#:        {
#:        k=(k<<4)+(c-'0');
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	movl %eax, %ecx
	movl %edx, %eax
	sall %cl, %eax
	pushl %eax
	leal	-12(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $48, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:        }
#:      else
	jmp cc574
cc573:
#:        {
#:        k=(k<<4)+(c-'a'+10);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	movl %eax, %ecx
	movl %edx, %eax
	sall %cl, %eax
	pushl %eax
	leal	-12(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $97, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:        }
cc574:
#:      }
	jmp cc571
cc572:
#:    val[0]=k;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:    return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:    }
#:  while(k)
cc570:
cc575:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc576
#:    {k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:    if (match("+")) k=1;
	movl $cc1+1851, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc577
	leal	-4(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
#:    if (match("-")) {minus=(-minus);k=1;}
cc577:
	movl $cc1+1853, %eax
	pushl %eax
	call match
	popl %edx
	testl %eax, %eax
	je	cc578
	leal	-8(%ebp), %eax
	pushl %eax
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	negl %eax
	popl %edx
	movl %eax, (%edx)
	leal	-4(%ebp), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	movl %eax, (%edx)
#:    }
cc578:
	jmp cc575
cc576:
#:  if(numeric(ch())==0)return 0;
	call ch
	pushl %eax
	call numeric
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc579
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  while (numeric(ch()))
cc579:
cc580:
	call ch
	pushl %eax
	call numeric
	popl %edx
	testl %eax, %eax
	je	cc581
#:    {c=inbyte();
	leal	-12(%ebp), %eax
	pushl %eax
	call inbyte
	popl %edx
	movb %al, (%edx)
#:    k=k*10+(c-'0');
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	imull %edx
	pushl %eax
	leal	-12(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $48, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:    }
	jmp cc580
cc581:
#:  if (minus<0) k=(-k);
	leal	-8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc582
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	negl %eax
	popl %edx
	movl %eax, (%edx)
#:  val[0]=k;
cc582:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:  return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:pstr(val)
	.text
	.align 16
.globl pstr
	.TYPE	pstr,@function
pstr:
#:  int val[];
	pushl %ebp
	movl %esp, %ebp
#:{  int k;char c;
	pushl %edx
	pushl %edx
#:  k=0;
	leal	-4(%ebp), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movl %eax, (%edx)
#:  if (match("'")==0) return 0;
	movl $cc1+1855, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc583
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  while((c=gch())!=39)
cc583:
cc584:
	leal	-8(%ebp), %eax
	pushl %eax
	call gch
	popl %edx
	movb %al, (%edx)
	pushl %eax
	movl $39, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc585
#:    k=(k&255)*256 + (c&127);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $255, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
	movl $256, %eax
	popl %edx
	imull %edx
	pushl %eax
	leal	-8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $127, %eax
	popl %edx
	andl %edx, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
	jmp cc584
cc585:
#:  val[0]=k;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	popl %edx
	movl %eax, (%edx)
#:  return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:qstr(val)
	.text
	.align 16
.globl qstr
	.TYPE	qstr,@function
qstr:
#:  int val[];
	pushl %ebp
	movl %esp, %ebp
#:{  char c;
	pushl %edx
#:  if (match(quote)==0) return 0;
	movl 	$quote, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc586
	movl $0, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  val[0]=litptr;
cc586:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	sall $2, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl litptr, %eax
	popl %edx
	movl %eax, (%edx)
#:  while (ch()!='"')
cc587:
	call ch
	pushl %eax
	movl $34, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc588
#:    {if(ch()==0)break;
	call ch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc589
	jmp cc588
#:    if(litptr>=LITMAX)
cc589:
	movl litptr, %eax
	pushl %eax
	movl $8000, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc590
#:      {error("string space exhausted");
	movl $cc1+1857, %eax
	pushl %eax
	call error
	popl %edx
#:      while(match(quote)==0)
cc591:
	movl 	$quote, %eax
	pushl %eax
	call match
	popl %edx
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc592
#:        if(gch()==0)break;
	call gch
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc593
	jmp cc592
#:      return 1;
cc593:
	jmp cc591
cc592:
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    c=gch();
cc590:
	leal	-4(%ebp), %eax
	pushl %eax
	call gch
	popl %edx
	movb %al, (%edx)
#:    if(c!=92)
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $92, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc594
#:      litq[litptr++]=c;
	movl 	$litq, %eax
	pushl %eax
	movl litptr, %eax
	incl %eax
	movl %eax, litptr
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:    else
	jmp cc595
cc594:
#:      {
#:      c=gch();
	leal	-4(%ebp), %eax
	pushl %eax
	call gch
	popl %edx
	movb %al, (%edx)
#:      if(c==0)break;
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc596
	jmp cc588
#:      if(c=='n')c=10;
cc596:
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $110, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc597
	leal	-4(%ebp), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	movb %al, (%edx)
#:      else if(c=='t')c=9;
	jmp cc598
cc597:
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $116, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc599
	leal	-4(%ebp), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	movb %al, (%edx)
#:      else if(c=='b')c=8;
	jmp cc600
cc599:
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $98, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc601
	leal	-4(%ebp), %eax
	pushl %eax
	movl $8, %eax
	popl %edx
	movb %al, (%edx)
#:      else if(c=='f')c==12;
	jmp cc602
cc601:
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $102, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc603
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $12, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
#:      litq[litptr++]=c;
cc603:
cc602:
cc600:
cc598:
	movl 	$litq, %eax
	pushl %eax
	movl litptr, %eax
	incl %eax
	movl %eax, litptr
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movsbl (%eax),%eax
	popl %edx
	movb %al, (%edx)
#:      }
cc595:
#:    }
	jmp cc587
cc588:
#:  gch();
	call gch
#:  litq[litptr++]=0;
	movl 	$litq, %eax
	pushl %eax
	movl litptr, %eax
	incl %eax
	movl %eax, litptr
	decl %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	movb %al, (%edx)
#:  return 1;
	movl $1, %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*  >>>>>> start of cc8 <<<<<<<  */
#:/* Begin a comment line for the assembler */
#:comment()
	.text
	.align 16
.globl comment
	.TYPE	comment,@function
comment:
#:{  outbyte('#');outbyte(':');
	pushl %ebp
	movl %esp, %ebp
	movl $35, %eax
	pushl %eax
	call outbyte
	popl %edx
	movl $58, %eax
	pushl %eax
	call outbyte
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Put out assembler info before any code is generated */
#:header()
	.text
	.align 16
.globl header
	.TYPE	header,@function
header:
#:{  comment();
	pushl %ebp
	movl %esp, %ebp
	call comment
#:  outstr(BANNER);
	movl $cc1+1880, %eax
	pushl %eax
	call outstr
	popl %edx
#:  nl();
	call nl
#:  comment();
	call comment
#:  outstr(VERSION);
	movl $cc1+1938, %eax
	pushl %eax
	call outstr
	popl %edx
#:  nl();
	call nl
#:  comment();
	call comment
#:  outstr(AUTHOR);
	movl $cc1+1996, %eax
	pushl %eax
	call outstr
	popl %edx
#:  nl();
	call nl
#:  comment();
	call comment
#:  nl();
	call nl
#:  /*(if(mainflg){*/    /* do stuff needed for first */
#:  /*ol("ORG 100h");*/ /* assembler file. */       
#:  /*ol("LHLD 6");*/  /* set up stack */
#:  /*ol("SPHL");*/
#:  /*callrts("ccgo");*/  /* set default drive for CP/M */
#:  /*zcall("main");*/  /* call the code generated by small-c */
#:  /*zcall("exit");*/  /* do an exit    gtf 7/16/80 */
#:  /*}*/
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print any assembler stuff needed after all code */
#:trailer()
	.text
	.align 16
.globl trailer
	.TYPE	trailer,@function
trailer:
#:{  /* ol("END"); */  /*...note: commented out! */
	pushl %ebp
	movl %esp, %ebp
#:  nl();      /* 6 May 80 rj errorsummary() now goes to console */
	call nl
#:  comment();
	call comment
#:  outstr(" --- End of Compilation ---");
	movl $cc1+2054, %eax
	pushl %eax
	call outstr
	popl %edx
#:  nl();
	call nl
#:  ot(".IDENT");tab();outstr(quote);
	movl $cc1+2082, %eax
	pushl %eax
	call ot
	popl %edx
	call tab
	movl 	$quote, %eax
	pushl %eax
	call outstr
	popl %edx
#:  outstr(IDNT);outstr(quote);
	movl $cc1+2089, %eax
	pushl %eax
	call outstr
	popl %edx
	movl 	$quote, %eax
	pushl %eax
	call outstr
	popl %edx
#:  nl();
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print out a NAME such that it won't annoy the assembler */
#:/*  (by matching anything reserved, like opcodes.) */
#:/*  gtf 4/7/80 */
#:outname(sname)
	.text
	.align 16
.globl outname
	.TYPE	outname,@function
outname:
#:char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  int len, i,j;
	pushl %edx
	pushl %edx
	pushl %edx
#:/*outasm("qz");*/
#:  len = strlen(sname);
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call strlen
	popl %edx
	popl %edx
	movl %eax, (%edx)
#:  if(len>(ASMPREF+ASMSUFF)){
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $7, %eax
	pushl %eax
	movl $7, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	cmpl	%eax, %edx
	setg	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc604
#:    i = ASMPREF;
	leal	-8(%ebp), %eax
	pushl %eax
	movl $7, %eax
	popl %edx
	movl %eax, (%edx)
#:    len = len-ASMPREF-ASMSUFF;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $7, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	pushl %eax
	movl $7, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:    while(i-- > 0)
cc605:
	leal	-8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	decl %eax
	popl %edx
	movl %eax, (%edx)
	incl %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setg	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc606
#:      outbyte(raise(*sname++));
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	movsbl (%eax),%eax
	pushl %eax
	call raise
	popl %edx
	pushl %eax
	call outbyte
	popl %edx
	jmp cc605
cc606:
#:    while(len-- > 0)
cc607:
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	decl %eax
	popl %edx
	movl %eax, (%edx)
	incl %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setg	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc608
#:      sname++;
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	jmp cc607
cc608:
#:    while(*sname)
cc609:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	movsbl (%eax),%eax
	testl %eax, %eax
	je	cc610
#:      outbyte(raise(*sname++));
	leal	8(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
	movsbl (%eax),%eax
	pushl %eax
	call raise
	popl %edx
	pushl %eax
	call outbyte
	popl %edx
	jmp cc609
cc610:
#:    }
#:  else  outasm(sname);
	jmp cc611
cc604:
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outasm
	popl %edx
cc611:
#:/* end outname */}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Fetch a static memory cell into the primary register */
#:getmem(sym)
	.text
	.align 16
.globl getmem
	.TYPE	getmem,@function
getmem:
#:  char *sym;
	pushl %ebp
	movl %esp, %ebp
#:{  if((sym[IDENT]!=POINTER)&(sym[TYPE]==CCHAR))
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $1, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc612
#:    {ot("LDA ");
	movl $cc1+2097, %eax
	pushl %eax
	call ot
	popl %edx
#:    outname(sym+NAME);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call outname
	popl %edx
#:    nl();
	call nl
#:    callrts("ccsxt");
	movl $cc1+2102, %eax
	pushl %eax
	call callrts
	popl %edx
#:    }
#:  else
	jmp cc613
cc612:
#:    {ot("movl ");
	movl $cc1+2108, %eax
	pushl %eax
	call ot
	popl %edx
#:    outname(sym+NAME);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call outname
	popl %edx
#:    outasm(", %eax");
	movl $cc1+2114, %eax
	pushl %eax
	call outasm
	popl %edx
#:    nl();
	call nl
#:    }
cc613:
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Fetch the address of the specified symbol */
#:/*  into the primary register */
#:getloc(sym)
	.text
	.align 16
.globl getloc
	.TYPE	getloc,@function
getloc:
#:  char *sym;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  int t;
	pushl %edx
#:  t=(sym[OFFSET]&255)+
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $12, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $255, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
#:  ((sym[OFFSET+1]&255)<<8);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $12, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $255, %eax
	popl %edx
	andl %edx, %eax
	pushl %eax
	movl $8, %eax
	popl %edx
	movl %eax, %ecx
	movl %edx, %eax
	sall %cl, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:  if(sym[OFFSET+1]&0x80)
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $12, %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $128, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc614
#:  t=t|0xffff0000;/*patched for 32 bits by E.V.*/
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $-65536, %eax
	popl %edx
	orl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:  /*ot("getloc ");*/
#:  ot("leal");tab();
cc614:
	movl $cc1+2121, %eax
	pushl %eax
	call ot
	popl %edx
	call tab
#:  outdec(t);outasm("(%ebp), %eax");nl();
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outdec
	popl %edx
	movl $cc1+2126, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:  /*
#:  immed();
#: 
#:  outdec(((sym[OFFSET]&255)+
#:    ((sym[OFFSET+1]&255)<<8))-
#:    Zsp);
#:  outasm(", %eax");
#:  nl();
#:  ol("DAD SP");
#:  */
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Store the primary register into the specified */
#:/*  static memory cell */
#:putmem(sym)
	.text
	.align 16
.globl putmem
	.TYPE	putmem,@function
putmem:
#:  char *sym;
	pushl %ebp
	movl %esp, %ebp
#:{  if((sym[IDENT]!=POINTER)&(sym[TYPE]==CCHAR))
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $9, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $3, %eax
	popl %edx
	cmpl	%eax, %edx
	setne	%al
	movzbl	%al, %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $10, %eax
	popl %edx
	addl %edx, %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $1, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc615
#:  {/*ol("MOV A,L");*/
#:    ot("movb %al, ");
	movl $cc1+2139, %eax
	pushl %eax
	call ot
	popl %edx
#:    }
#:  else ot("movl %eax, ");
	jmp cc616
cc615:
	movl $cc1+2150, %eax
	pushl %eax
	call ot
	popl %edx
cc616:
#:  outname(sym+NAME);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	addl %edx, %eax
	pushl %eax
	call outname
	popl %edx
#:  nl();
	call nl
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Store the specified object TYPE in the primary register */
#:/*  at the address on the top of the stack */
#:putstk(typeobj)
	.text
	.align 16
.globl putstk
	.TYPE	putstk,@function
putstk:
#:char typeobj;
	pushl %ebp
	movl %esp, %ebp
#:{  zpop();
	call zpop
#:  if(typeobj==CINT)
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $2, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc617
#:    {/*callrts("ccpint");*/
#:      ol("movl %eax, (%edx)");
	movl $cc1+2162, %eax
	pushl %eax
	call ol
	popl %edx
#:    }
#:  else
	jmp cc618
cc617:
#:    {/*ol("MOV A,L");*/    /* per Ron Cain: gtf 9/25/80 */
#:    /*ol("STAX D");*/
#:    ol("movb %al, (%edx)");
	movl $cc1+2180, %eax
	pushl %eax
	call ol
	popl %edx
#:    }
cc618:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Fetch the specified object TYPE indirect through the */
#:/*  primary register into the primary register */
#:indirect(typeobj)
	.text
	.align 16
.globl indirect
	.TYPE	indirect,@function
indirect:
#:  char typeobj;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  if(typeobj==CCHAR)
	leal	8(%ebp), %eax
	movsbl (%eax),%eax
	pushl %eax
	movl $1, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc619
#:  {/*callrts("ccgchar");*/
#:    ol("movsbl (%eax),%eax");
	movl $cc1+2197, %eax
	pushl %eax
	call ol
	popl %edx
#:  }
#:  else 
	jmp cc620
cc619:
#:  {/*callrts("ccgint");*/
#:    ol("movl (%eax), %eax");
	movl $cc1+2216, %eax
	pushl %eax
	call ol
	popl %edx
#:  }
cc620:
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Swap the primary and secondary registers */
#:swap()
	.text
	.align 16
.globl swap
	.TYPE	swap,@function
swap:
#:{  ol("TTTTTxchgl %eax, %edx");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2234, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print partial instruction to get an immediate value */
#:/*  into the primary register */
#:immed()
	.text
	.align 16
.globl immed
	.TYPE	immed,@function
immed:
#:{  ot("movl ");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2256, %eax
	pushl %eax
	call ot
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Push the primary register onto the stack */
#:zpush()
	.text
	.align 16
.globl zpush
	.TYPE	zpush,@function
zpush:
#:{  ol("pushl %eax");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2262, %eax
	pushl %eax
	call ol
	popl %edx
#: Zsp=Zsp-4;/*modified by E.V.*/
	movl Zsp, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	movl %eax, Zsp
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Pop the top of the stack into the secondary register */
#:zpop()
	.text
	.align 16
.globl zpop
	.TYPE	zpop,@function
zpop:
#:{  ol("popl %edx");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2273, %eax
	pushl %eax
	call ol
	popl %edx
#: Zsp=Zsp+4;/*modified by E.V.*/
	movl Zsp, %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	addl %edx, %eax
	movl %eax, Zsp
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Swap the primary register and the top of the stack */
#:swapstk()
	.text
	.align 16
.globl swapstk
	.TYPE	swapstk,@function
swapstk:
#:{  ol("XTHL");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2283, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Call the specified subroutine NAME */
#:zcall(sname)
	.text
	.align 16
.globl zcall
	.TYPE	zcall,@function
zcall:
#:  char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{  ot("call ");
	movl $cc1+2288, %eax
	pushl %eax
	call ot
	popl %edx
#:  outname(sname);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outname
	popl %edx
#:  nl();
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Call a run-time library routine */
#:callrts(sname)
	.text
	.align 16
.globl callrts
	.TYPE	callrts,@function
callrts:
#:char *sname;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  ot("call ");
	movl $cc1+2294, %eax
	pushl %eax
	call ot
	popl %edx
#:  outasm(sname);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outasm
	popl %edx
#:  nl();
	call nl
#:/*end callrts*/}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Return from subroutine */
#:zret()
	.text
	.align 16
.globl zret
	.TYPE	zret,@function
zret:
#:{  ol("ret");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2300, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Perform subroutine call to value on top of stack */
#:callstk(nargs)
	.text
	.align 16
.globl callstk
	.TYPE	callstk,@function
callstk:
#:   int nargs;
	pushl %ebp
	movl %esp, %ebp
#:{
#:  immed();outdec(nargs);outasm("(%esp), %eax");nl();
	call immed
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outdec
	popl %edx
	movl $cc1+2304, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:  ol("call *%eax");
	movl $cc1+2317, %eax
	pushl %eax
	call ol
	popl %edx
#:  /*immed();
#:  outasm("$+5");
#:  nl();
#:  swapstk();
#:  ol("PCHL");
#:  Zsp=Zsp+2;*/ /* corrected 5 May 81 rj */
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Jump to specified internal label number */
#:jump(label)
	.text
	.align 16
.globl jump
	.TYPE	jump,@function
jump:
#:  int label;
	pushl %ebp
	movl %esp, %ebp
#:{  ot("jmp ");
	movl $cc1+2328, %eax
	pushl %eax
	call ot
	popl %edx
#:  printlabel(label);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
#:  nl();
	call nl
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test the primary register and jump if false to label */
#:testjump(label)
	.text
	.align 16
.globl testjump
	.TYPE	testjump,@function
testjump:
#:  int label;
	pushl %ebp
	movl %esp, %ebp
#:{  /*ol("MOV A,H");
#:  ol("ORA L");
#:  ot("JZ ");*/
#:  ol("testl %eax, %eax");
	movl $cc1+2333, %eax
	pushl %eax
	call ol
	popl %edx
#:  ot("je");tab();
	movl $cc1+2350, %eax
	pushl %eax
	call ot
	popl %edx
	call tab
#:  printlabel(label);
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call printlab
	popl %edx
#:  nl();
	call nl
#:  }
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print pseudo-op to define a byte */
#:defbyte()
	.text
	.align 16
.globl defbyte
	.TYPE	defbyte,@function
defbyte:
#:{  ot(".byte ");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2353, %eax
	pushl %eax
	call ot
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/*Print pseudo-op to define STORAGE */
#:defstorage()
	.text
	.align 16
.globl defstora
	.TYPE	defstora,@function
defstora:
#:{  ot(".comm ");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2360, %eax
	pushl %eax
	call ot
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Print pseudo-op to define a word */
#:defword()
	.text
	.align 16
.globl defword
	.TYPE	defword,@function
defword:
#:{  ot("DW ");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2367, %eax
	pushl %eax
	call ot
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Modify the stack POINTER to the new value indicated */
#:modstk(newsp)
	.text
	.align 16
.globl modstk
	.TYPE	modstk,@function
modstk:
#:  int newsp;
	pushl %ebp
	movl %esp, %ebp
#: {  int k;
	pushl %edx
#:  k=newsp-Zsp;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	8(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl Zsp, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:  if(k==0)return newsp;
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc621
	leal	8(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:  if(k>=0)
cc621:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setge	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc622
#:    {if(k<7)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $7, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc623
#:      {if(k&1)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc624
#:        {ol("INX SP");
	movl $cc1+2371, %eax
	pushl %eax
	call ol
	popl %edx
#:        k--;
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	decl %eax
	popl %edx
	movl %eax, (%edx)
	incl %eax
#:        }
#:      while(k)
cc624:
cc625:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc626
#:        {ol("popl %edx");
	movl $cc1+2378, %eax
	pushl %eax
	call ol
	popl %edx
#:        k=k-4;
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	subl %eax, %edx
	movl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:        }
	jmp cc625
cc626:
#:      return newsp;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:      }
#:    }
cc623:
#:  if(k<0)
cc622:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setl	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc627
#:    {
#:      /*ot("subl $");outdec(-k);outasm(", %esp");nl();*/
#:      if(k>-7)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $7, %eax
	negl %eax
	popl %edx
	cmpl	%eax, %edx
	setg	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc628
#:      {
#:        if(k&1)
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $1, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc629
#:        {
#:          ol("decl %esp");
	movl $cc1+2388, %eax
	pushl %eax
	call ol
	popl %edx
#:          k++;
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
#:        }
#:        if(k&2)
cc629:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $2, %eax
	popl %edx
	andl %edx, %eax
	testl %eax, %eax
	je	cc630
#:        {
#:          ol("decl %esp");
	movl $cc1+2398, %eax
	pushl %eax
	call ol
	popl %edx
#:          k++;
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
#:          ol("decl %esp");
	movl $cc1+2408, %eax
	pushl %eax
	call ol
	popl %edx
#:          k++;
	leal	-4(%ebp), %eax
	pushl %eax
	movl (%eax), %eax
	incl %eax
	popl %edx
	movl %eax, (%edx)
	decl %eax
#:        }
#:        while(k)
cc630:
cc631:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	testl %eax, %eax
	je	cc632
#:        {
#:          ol("pushl %edx");
	movl $cc1+2418, %eax
	pushl %eax
	call ol
	popl %edx
#:          k=k+4;/*modified by E.V.*/
	leal	-4(%ebp), %eax
	pushl %eax
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $4, %eax
	popl %edx
	addl %edx, %eax
	popl %edx
	movl %eax, (%edx)
#:        }
	jmp cc631
cc632:
#:        return newsp;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:        }
#:    }
cc628:
#:  /*swap();
#:  immed();outdec(k);outasm(", %eax");nl();
#:  ol("DAD SP");
#:  ol("SPHL");
#:  swap();*/
#:  if(k>0)
cc627:
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	movl $0, %eax
	popl %edx
	cmpl	%eax, %edx
	setg	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc633
#:    {ot("addl $");outdec(k);outasm(", %esp");nl();}
	movl $cc1+2429, %eax
	pushl %eax
	call ot
	popl %edx
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	pushl %eax
	call outdec
	popl %edx
	movl $cc1+2436, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
#:  else
	jmp cc634
cc633:
#:    {ot("subl $");outdec(-k);outasm(", %esp");nl();}
	movl $cc1+2443, %eax
	pushl %eax
	call ot
	popl %edx
	leal	-4(%ebp), %eax
	movl (%eax), %eax
	negl %eax
	pushl %eax
	call outdec
	popl %edx
	movl $cc1+2450, %eax
	pushl %eax
	call outasm
	popl %edx
	call nl
cc634:
#:  return newsp;
	leal	8(%ebp), %eax
	movl (%eax), %eax
	movl %ebp, %esp
	popl %ebp
	ret
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Double the primary register */
#:doublereg()
	.text
	.align 16
.globl doublere
	.TYPE	doublere,@function
doublere:
#:{  ol("DAD H");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2457, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Add the primary and secondary registers */
#:/*  (results in primary) */
#:zadd()
	.text
	.align 16
.globl zadd
	.TYPE	zadd,@function
zadd:
#:{  ol("addl %edx, %eax");
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2463, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Subtract the primary register from the secondary */
#:/*  (results in primary) */
#:zsub()
	.text
	.align 16
.globl zsub
	.TYPE	zsub,@function
zsub:
#:{  /*callrts("ccsub");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("subl %eax, %edx");
	movl $cc1+2479, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movl %edx, %eax");
	movl $cc1+2495, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Multiply the primary and secondary registers */
#:/*  (results in primary */
#:mult()
	.text
	.align 16
.globl mult
	.TYPE	mult,@function
mult:
#:{  /*callrts("ccmult");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("imull %edx");
	movl $cc1+2511, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Divide the secondary register by the primary */
#:/*  (quotient in primary, remainder in secondary) */
#:div()
	.text
	.align 16
.globl div
	.TYPE	div,@function
div:
#:{/*callrts("ccdiv");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("xchgl %eax, %edx");
	movl $cc1+2522, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movl %edx, %ecx");
	movl $cc1+2539, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("cltd");
	movl $cc1+2555, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("idivl %ecx");
	movl $cc1+2560, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Compute remainder (mod) of secondary register divided */
#:/*  by the primary */
#:/*  (remainder in primary, quotient in secondary) */
#:zmod()
	.text
	.align 16
.globl zmod
	.TYPE	zmod,@function
zmod:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  div();
	call div
#:  ol("movl %edx, %eax");
	movl $cc1+2571, %eax
	pushl %eax
	call ol
	popl %edx
#:  /*swap();*/
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Inclusive 'or' the primary and the secondary registers */
#:/*  (results in primary) */
#:zor()
	.text
	.align 16
.globl zor
	.TYPE	zor,@function
zor:
#:{/*callrts("ccor");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("orl %edx, %eax");
	movl $cc1+2587, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Exclusive 'or' the primary and seconday registers */
#:/*  (results in primary) */
#:zxor()
	.text
	.align 16
.globl zxor
	.TYPE	zxor,@function
zxor:
#:{/*callrts("ccxor");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("xorl %edx, %eax");
	movl $cc1+2602, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* 'And' the primary and secondary registers */
#:/*  (results in primary) */
#:zand()
	.text
	.align 16
.globl zand
	.TYPE	zand,@function
zand:
#:{/*callrts("ccand");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("andl %edx, %eax");
	movl $cc1+2618, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Arithmetic shift right the secondary register number of */
#:/*  times in primary (results in primary) */
#:asr()
	.text
	.align 16
.globl asr
	.TYPE	asr,@function
asr:
#:{/*callrts("ccasr");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("movl %eax, %ecx");
	movl $cc1+2634, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movl %edx, %eax");
	movl $cc1+2650, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("sarl %cl, %eax");
	movl $cc1+2666, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Arithmetic left shift the secondary register number of */
#:/*  times in primary (results in primary) */
#:asl()
	.text
	.align 16
.globl asl
	.TYPE	asl,@function
asl:
#:{/*callrts("ccasl");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("movl %eax, %ecx");
	movl $cc1+2681, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movl %edx, %eax");
	movl $cc1+2697, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("sall %cl, %eax");
	movl $cc1+2713, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Form two's complement of primary register */
#:neg()
	.text
	.align 16
.globl neg
	.TYPE	neg,@function
neg:
#:{/*callrts("ccneg");*/
	pushl %ebp
	movl %esp, %ebp
#:  ol("negl %eax");
	movl $cc1+2728, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:lnot()/*added by E.V.*/
	.text
	.align 16
.globl lnot
	.TYPE	lnot,@function
lnot:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  ol("testl %eax,%eax");
	movl $cc1+2738, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("sete %al");
	movl $cc1+2754, %eax
	pushl %eax
	call ol
	popl %edx
#:  ol("movzbl %al, %eax");
	movl $cc1+2763, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:bnot()/*added by E.V.*/
	.text
	.align 16
.globl bnot
	.TYPE	bnot,@function
bnot:
#:{
	pushl %ebp
	movl %esp, %ebp
#:  ol("notl %eax");
	movl $cc1+2780, %eax
	pushl %eax
	call ol
	popl %edx
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Form one's complement of primary register */
#:com()
	.text
	.align 16
.globl com
	.TYPE	com,@function
com:
#:  {callrts("cccom");}
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2790, %eax
	pushl %eax
	call callrts
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Increment the primary register by one */
#:inc()
	.text
	.align 16
.globl inc
	.TYPE	inc,@function
inc:
#:  {ol("incl %eax");}
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2796, %eax
	pushl %eax
	call ol
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Decrement the primary register by one */
#:dec()
	.text
	.align 16
.globl dec
	.TYPE	dec,@function
dec:
#:  {ol("decl %eax");}
	pushl %ebp
	movl %esp, %ebp
	movl $cc1+2806, %eax
	pushl %eax
	call ol
	popl %edx
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Following are the conditional operators */
#:/* They compare the secondary register against the primary */
#:/* and put a literal 1 in the primary if the condition is */
#:/* true, otherwise they clear the primary register */
#:/* Test for equal */
#:zeq()
	.text
	.align 16
.globl zeq
	.TYPE	zeq,@function
zeq:
#:{/*callrts("cceq");*/
	pushl %ebp
	movl %esp, %ebp
#:  ot("cmpl");ot("%eax, %edx");nl();
	movl $cc1+2816, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2821, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("sete");ot("%al");nl();
	movl $cc1+2832, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2837, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("movzbl");ot("%al, %eax");nl();
	movl $cc1+2841, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2848, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test for not equal */
#:zne()
	.text
	.align 16
.globl zne
	.TYPE	zne,@function
zne:
#:{/*callrts("ccne");*/
	pushl %ebp
	movl %esp, %ebp
#:  ot("cmpl");ot("%eax, %edx");nl();
	movl $cc1+2858, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2863, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("setne");ot("%al");nl();
	movl $cc1+2874, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2880, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("movzbl");ot("%al, %eax");nl();
	movl $cc1+2884, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2891, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test for less than (signed) */
#:zlt()
	.text
	.align 16
.globl zlt
	.TYPE	zlt,@function
zlt:
#:{/*callrts("cclt");*/
	pushl %ebp
	movl %esp, %ebp
#:  ot("cmpl");ot("%eax, %edx");nl();
	movl $cc1+2901, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2906, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("setl");ot("%al");nl();
	movl $cc1+2917, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2922, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("movzbl");ot("%al, %eax");nl();
	movl $cc1+2926, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2933, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test for less than or equal to (signed) */
#:zle()
	.text
	.align 16
.globl zle
	.TYPE	zle,@function
zle:
#:{/*callrts("ccle");*/
	pushl %ebp
	movl %esp, %ebp
#:  ot("cmpl");ot("%eax, %edx");nl();
	movl $cc1+2943, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2948, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("setle");ot("%al");nl();
	movl $cc1+2959, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2965, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:  ot("movzbl");ot("%al, %eax");nl();
	movl $cc1+2969, %eax
	pushl %eax
	call ot
	popl %edx
	movl $cc1+2976, %eax
	pushl %eax
	call ot
	popl %edx
	call nl
#:}
	movl %ebp, %esp
	popl %ebp
	ret
#:/* Test for greater than (signed) */
#:zgt()
	.text
	.align 16
.globl zgt
	.TYPE	zgt,@function
zgt:
#:{/*callrts("ccgt");*/
	pushl %ebp
	movl %esp, %ebp
#:  ot("cmpl");ot("%eax, %e