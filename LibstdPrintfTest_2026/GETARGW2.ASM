; Windows (32bit) Version - 12/03/2026
; -----------------------------------------------------------
; Small C Compiler for TRDOS 386 (v2.0.9 and later)
; Erdogan Tan - 2024
; Beginning: 05/09/2024
; Last Update: 14/09/2024
; -----------------------------------------------------------
; Derived from 'getarg.asm' file of KolibriOS SCC source code
; 2024

; Win32
; =============== S U B R O U T I N E =======================

get_commandline:
	call    [GetCommandLineA]
	mov     esi,eax
	mov     edi,cmdline_buf
	mov     ecx,256
.get_cmdline_lop:
	lodsb
	cmp     al,0
	stosb
	loopne  .get_cmdline_lop
	mov     byte [edi-1],0
	mov     esi,cmdline_buf
 	mov     edi,cmdline_buf
	mov	edx,argv	; & argv[0]
	mov	dword [argc],0
.get_items_lop:
	call    _@@get_item
	mov     al,[ebx]
	cmp     al,0
	jz      short .done
	inc	dword [argc]	; argument count
	mov	[edx],ebx	; argv[x]
	add	edx,4
	cmp	edx,argv+64	; max. 16 arguments
	jb	short .get_items_lop
.done:
	retn

; Win32
; =============== S U B R O U T I N E =======================

_@@get_item:
	lodsb
	dec	al
	cmp	al,1Fh		; 20-1
	jbe	short _@@get_item ; _@@skip_spc_lop
	dec	esi
	mov	ebx,edi
	mov	ah,0		; flag initially not quoted
.char_lop:
	lodsb
	cmp	al,'"'
	jnz	short .no_quote
	xor	ah,1
	jmp	short .char_lop
.no_quote:
	stosb
	cmp	al,0
	jz	short .src_end
	cmp	al,20h
	ja	short .char_lop
	cmp	ah,0	; ignore spaces if inside "quoted area"
	jnz	short .char_lop
	mov	byte [edi-1],0	; eol (replace space by 00h)
	retn
.src_end:
	dec	esi
	retn

