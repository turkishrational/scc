#:<><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
#:<><><><><>   CP/M Large String Space Version   <><><><><>
#:<><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
#:
#:#:<><><>   Small-C  V1.2  DOS--CP/M Cross Compiler   <><><>
#:#:<><><><><>   CP/M Large String Space Version   <><><><><>
#:#:<><><><><><><><><><>   By Ron Cain   <><><><><><><><><><>
#:#:
#:#:;main()
#:#:	.global main
#:#:main:
#:	.text
#:	.align 16
#:.globl main
#:	.TYPE	main,@function
#:main:
	.text
	.align 16
.globl main
	.TYPE	main,@function
main:
#:#:	LXI H,0
#:#:;{
#:#:	ret
#:#:;   int a, b, c, d;
#:#:;   char e, f, g, h;
#:#:;   char i[100];
#:#:;   int j[200];
#:#:;
#:#:;   a = b = c = 'a';
#:#:;a
#:#:	.global a
#:#:a:
#:#:;
#:#:;   if(a == 'a') {
	pushl %ebp
	movl %esp, %ebp
	movl a, %eax
	pushl %eax
	movl $97, %eax
	popl %edx
	cmpl	%eax, %edx
	sete	%al
	movzbl	%al, %eax
	testl %eax, %eax
	je	cc2
	movl 0,, %eax
#:	pushl %ebp
	movl pushl, %eax
	pushl %eax
#:	movl %esp, %ebp
	movl ebp, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl movl, %eax
	pushl %eax
	movl esp, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl 0,, %eax
#:	movl a, %eax
	movl ebp, %eax
	movl movl, %eax
	movl a, %eax
	movl 0,, %eax
#:	pushl %eax
	movl eax, %eax
	movl pushl, %eax
	pushl %eax
#:	movl $97, %eax
	movl eax, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl movl, %eax
	movl 0,, %eax
	movl $97, %eax
	movl 0,, %eax
#:	popl %edx
	movl eax, %eax
	movl popl, %eax
	pushl %eax
#:	cmpl	%eax, %edx
	movl edx, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl cmpl, %eax
	pushl %eax
	movl eax, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl 0,, %eax
#:	sete	%al
	movl edx, %eax
	movl sete, %eax
	pushl %eax
#:	movzbl	%al, %eax
	movl al, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl movzbl, %eax
	pushl %eax
	movl al, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl 0,, %eax
#:	movl a, %eax
	movl eax, %eax
	movl movl, %eax
	movl a, %eax
	movl 0,, %eax
#:	movl %ebp, %esp
	movl eax, %eax
	movl movl, %eax
	pushl %eax
	movl ebp, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
	movl 0,, %eax
#:	popl %ebp
	movl esp, %eax
	movl popl, %eax
	pushl %eax
#:	ret
	movl ebp, %eax
	popl %edx
	xchgl %eax, %edx
	movl %edx, %ecx
	cltd
	idivl %ecx
	movl %edx, %eax
#:#:;     printf("A = 1\n");
	movl ret, %eax
	movl 0,, %eax
	movl $cc1+0, %eax
	pushl %eax
	call printf
	popl %edx
	movl 0,, %eax
#:#:;   }
	movl 0,, %eax
#:#:;}
	movl 0,, %eax
#:#:	LXI H,0
	movl 0,, %eax
	movl LXI, %eax
	movl H, %eax
	movl 0,, %eax
	movl $0, %eax
#:	.text
	movl 0,, %eax
#:	.align 16
	movl text, %eax
	movl 0,, %eax
	movl align, %eax
	movl $16, %eax
#:.globl LXI
	movl 0,, %eax
	movl globl, %eax
#:	.TYPE	LXI,@function
	movl LXI, %eax
	movl 0,, %eax
	movl TYPE, %eax
	movl LXI, %eax
	movl 0,, %eax
#:LXI:
	movl function, %eax
	movl LXI, %eax
	movl 0,, %eax
#:#:	ret
	movl 0,, %eax
#:#:	.comm a,4,4
	movl ret, %eax
	movl 0,, %eax
	movl comm, %eax
	movl a, %eax
	movl 0,, %eax
	movl $4, %eax
	movl 0,, %eax
	movl $4, %eax
#:#:	.comm b,4,4
	movl 0,, %eax
	movl comm, %eax
	movl b, %eax
	movl 0,, %eax
	movl $4, %eax
	movl 0,, %eax
	movl $4, %eax
#:#:	.comm c,4,4
	movl 0,, %eax
	movl comm, %eax
	movl c, %eax
	movl 0,, %eax
	movl $4, %eax
	movl 0,, %eax
	movl $4, %eax
#:#:	.comm d,4,4
	movl 0,, %eax
	movl comm, %eax
	movl d, %eax
	movl 0,, %eax
	movl $4, %eax
	movl 0,, %eax
	movl $4, %eax
#:#:	.comm e,1,1
	movl 0,, %eax
	movl comm, %eax
	movl e, %eax
	movl 0,, %eax
	movl $1, %eax
	movl 0,, %eax
	movl $1, %eax
#:#:	.comm f,1,1
	movl 0,, %eax
	movl comm, %eax
	movl f, %eax
	movl 0,, %eax
	movl $1, %eax
	movl 0,, %eax
	movl $1, %eax
#:#:	.comm g,1,1
	movl 0,, %eax
	movl comm, %eax
	movl g, %eax
	movl 0,, %eax
	movl $1, %eax
	movl 0,, %eax
	movl $1, %eax
#:#:	.comm h,1,1
	movl 0,, %