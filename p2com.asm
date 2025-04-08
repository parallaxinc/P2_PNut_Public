;************************************************
;*						*
;*	       Spin2 Compiler v51a		*
;*						*
;*	     Written by Chip Gracey		*
;*	 (C) 2006-2025 by Parallax, Inc.	*
;*	    Last Updated: 2025/04/02		*
;*						*
;************************************************

			ideal
			p386
			model	flat
			%CREFUREF
;
;
; Public routines
;
			public	P2InitStruct
			public	P2Compile0
			public	P2Compile1
			public	P2Compile2
			public	P2InsertInterpreter
			public	P2InsertDebugger
			public	P2InsertClockSetter
			public	P2InsertFlashLoader
			public	P2MakeFlashFile
			public	P2ResetDebugSymbols
			public	P2ParseDebugString
			public	P2Disassemble
;
;
; Equates
;
spin2_version		=	51

obj_size_limit		=	100000h		;must be same in delphi
obj_data_limit		=	200000h		;must be same in delphi
files_limit		=	255		;must be same in delphi
pre_symbols_limit	=	16		;must be same in delphi
obj_params_limit	=	16		;must be same in delphi
info_limit		=	2000		;must be same in delphi
debug_data_limit	=	4000h		;must be same in delphi
debug_string_limit	=	8000h		;must be same in delphi
debug_display_limit	=	1100		;must be same in delphi

ddsymbols_limit_auto	=	1000h
ddsymbols_limit_name	=	1000h

symbols_limit_pre	=	1000h
symbols_limit_auto	=	10000h		;adjust as needed to accommodate auto symbols
symbols_limit_level	=	400h		;adjust as needed to accommodate level symbols
symbols_limit_param	=	400h
symbols_limit_main	=	40000h
symbols_limit_local	=	8000h
symbols_limit_inline	=	8000h

struct_id_limit		=	1000h		;cannot exceed $1000
struct_def_limit	=	20000h

symbol_size_limit	=	30
pubcon_list_limit	=	10000h

block_nest_limit	=	16
block_stack_limit	=	1000h
if_limit		=	256
case_limit		=	256
case_fast_limit		=	256		;cannot exceed 256

objs_limit		=	1024
methods_limit		=	1024

method_params_limit	=	127
method_results_limit	=	15
method_locals_limit	=	10000h + method_params_limit*4 + method_results_limit*4

distiller_limit		=	10000h

inline_org_limit	=	120h		;make sure these are current
taskhlt_reg		=	1CCh
mrecv_reg		=	1D1h
msend_reg		=	1D2h
prx_regs		=	1D8h
inline_locals_base	=	1E0h

debug_size_limit	=	2A00h

clkfreq_address		=	044h
;
;
; Macro for assigning ascending values
;
macro		count0	count_name
count_name	=	0
counter		=	1
		endm

macro		countn	count_name,n
count_name	=	n
counter		=	n+1
		endm

macro		count	count_name
count_name	=	counter
counter		=	counter+1
		endm

macro		counti	count_name,n
count_name	=	counter
counter		=	counter+n
		endm

macro		count2n	count_name,n
count_name	=	n
counter		=	n+2
		endm

macro		count2	count_name
count_name	=	counter
counter		=	counter+2
		endm
;
;
; Macro for non-word symbol checks
;
macro		syms	s,t,v
		local	no

		cmp	eax,s
		jne	no
		mov	eax,t
		mov	ebx,v
		ret
no:
		endm
;
;
; Macros for automatic symbols
;
macro		sym	t,v,s
		db	s,0
		dd	v
		db	t
		endm

macro		syml	t,v,l,s
		db	s,0
		dd	v shl l
		db	t
		endm
;
;
; Assembly operands
;
count0		operand_ds
count		operand_bitx
count		operand_testb
count		operand_du
count		operand_duii
count		operand_duiz
count		operand_ds3set
count		operand_ds3get
count		operand_ds2set
count		operand_ds2get
count		operand_ds1set
count		operand_ds1get
count		operand_dsj
count		operand_ls
count		operand_lsj
count		operand_dsp
count		operand_lsp
count		operand_rep
count		operand_jmp
count		operand_call
count		operand_calld
count		operand_jpoll
count		operand_loc
count		operand_aug
count		operand_d
count		operand_de
count		operand_l
count		operand_cz
count		operand_pollwait
count		operand_getbrk
count		operand_pinop
count		operand_testp
count		operand_pushpop
count		operand_xlat
count		operand_akpin
count		operand_asmclk
count		operand_nop
count		operand_debug
;
;
; Assembly push/pops
;
count0		pp_pusha	;	PUSHA	D/#	-->	WRLONG	D/#,PTRA++
count		pp_pushb	;	PUSHB	D/#	-->	WRLONG	D/#,PTRB++
count		pp_popa		;	POPA	D	-->	RDLONG	D,--PTRA
count		pp_popb		;	POPB	D	-->	RDLONG	D,--PTRB
;
;
; Assembly codes
;
macro		asmcode	symbol,v1,v2,v3
symbol		=	(v3 shl 11) + (v2 shl 9) + v1
		endm

asmcode		ac_ror,		000000000b,11b,operand_ds	;	ROR	D,S/#
asmcode		ac_rol,		000000100b,11b,operand_ds	;	ROL	D,S/#
asmcode		ac_shr,		000001000b,11b,operand_ds	;	SHR	D,S/#
asmcode		ac_shl,		000001100b,11b,operand_ds	;	SHL	D,S/#
asmcode		ac_rcr,		000010000b,11b,operand_ds	;	RCR	D,S/#
asmcode		ac_rcl,		000010100b,11b,operand_ds	;	RCL	D,S/#
asmcode		ac_sar,		000011000b,11b,operand_ds	;	SAR	D,S/#
asmcode		ac_sal,		000011100b,11b,operand_ds	;	SAL	D,S/#

asmcode		ac_add,		000100000b,11b,operand_ds	;	ADD	D,S/#
asmcode		ac_addx,	000100100b,11b,operand_ds	;	ADDX	D,S/#
asmcode		ac_adds,	000101000b,11b,operand_ds	;	ADDS	D,S/#
asmcode		ac_addsx,	000101100b,11b,operand_ds	;	ADDSX	D,S/#

asmcode		ac_sub,		000110000b,11b,operand_ds	;	SUB	D,S/#
asmcode		ac_subx,	000110100b,11b,operand_ds	;	SUBX	D,S/#
asmcode		ac_subs,	000111000b,11b,operand_ds	;	SUBS	D,S/#
asmcode		ac_subsx,	000111100b,11b,operand_ds	;	SUBSX	D,S/#

asmcode		ac_cmp,		001000000b,11b,operand_ds	;	CMP	D,S/#
asmcode		ac_cmpx,	001000100b,11b,operand_ds	;	CMPX	D,S/#
asmcode		ac_cmps,	001001000b,11b,operand_ds	;	CMPS	D,S/#
asmcode		ac_cmpsx,	001001100b,11b,operand_ds	;	CMPSX	D,S/#

asmcode		ac_cmpr,	001010000b,11b,operand_ds	;	CMPR	D,S/#
asmcode		ac_cmpm,	001010100b,11b,operand_ds	;	CMPM	D,S/#
asmcode		ac_subr,	001011000b,11b,operand_ds	;	SUBR	D,S/#
asmcode		ac_cmpsub,	001011100b,11b,operand_ds	;	CMPSUB	D,S/#

asmcode		ac_fge,		001100000b,11b,operand_ds	;	FGE	D,S/#
asmcode		ac_fle,		001100100b,11b,operand_ds	;	FLE	D,S/#
asmcode		ac_fges,	001101000b,11b,operand_ds	;	FGES	D,S/#
asmcode		ac_fles,	001101100b,11b,operand_ds	;	FLES	D,S/#

asmcode		ac_sumc,	001110000b,11b,operand_ds	;	SUMC	D,S/#
asmcode		ac_sumnc,	001110100b,11b,operand_ds	;	SUMNC	D,S/#
asmcode		ac_sumz,	001111000b,11b,operand_ds	;	SUMZ	D,S/#
asmcode		ac_sumnz,	001111100b,11b,operand_ds	;	SUMNZ	D,S/#

asmcode		ac_bitl,	010000000b,00b,operand_bitx	;	BITL	D,S/#
asmcode		ac_bith,	010000100b,00b,operand_bitx	;	BITH	D,S/#
asmcode		ac_bitc,	010001000b,00b,operand_bitx	;	BITC	D,S/#
asmcode		ac_bitnc,	010001100b,00b,operand_bitx	;	BITNC	D,S/#
asmcode		ac_bitz,	010010000b,00b,operand_bitx	;	BITZ	D,S/#
asmcode		ac_bitnz,	010010100b,00b,operand_bitx	;	BITNZ	D,S/#
asmcode		ac_bitrnd,	010011000b,00b,operand_bitx	;	BITRND	D,S/#
asmcode		ac_bitnot,	010011100b,00b,operand_bitx	;	BITNOT	D,S/#

asmcode		ac_testb,	010000000b,00b,operand_testb	;	TESTB	D,S/#
asmcode		ac_testbn,	010000100b,00b,operand_testb	;	TESTBN	D,S/#

asmcode		ac_and,		010100000b,11b,operand_ds	;	AND	D,S/#
asmcode		ac_andn,	010100100b,11b,operand_ds	;	ANDN	D,S/#
asmcode		ac_or,		010101000b,11b,operand_ds	;	OR	D,S/#
asmcode		ac_xor,		010101100b,11b,operand_ds	;	XOR	D,S/#

asmcode		ac_muxc,	010110000b,11b,operand_ds	;	MUXC	D,S/#
asmcode		ac_muxnc,	010110100b,11b,operand_ds	;	MUXNC	D,S/#
asmcode		ac_muxz,	010111000b,11b,operand_ds	;	MUXZ	D,S/#
asmcode		ac_muxnz,	010111100b,11b,operand_ds	;	MUXNZ	D,S/#

asmcode		ac_mov,		011000000b,11b,operand_ds	;	MOV	D,S/#
asmcode		ac_not,		011000100b,11b,operand_du	;	NOT	D{,S/#}
asmcode		ac_abs,		011001000b,11b,operand_du	;	ABS	D{,S/#}
asmcode		ac_neg,		011001100b,11b,operand_du	;	NEG	D{,S/#}

asmcode		ac_negc,	011010000b,11b,operand_du	;	NEGC	D{,S/#}
asmcode		ac_negnc,	011010100b,11b,operand_du	;	NEGNC	D{,S/#}
asmcode		ac_negz,	011011000b,11b,operand_du	;	NEGZ	D{,S/#}
asmcode		ac_negnz,	011011100b,11b,operand_du	;	NEGNZ	D{,S/#}

asmcode		ac_incmod,	011100000b,11b,operand_ds	;	INCMOD	D,S/#
asmcode		ac_decmod,	011100100b,11b,operand_ds	;	DECMOD	D,S/#
asmcode		ac_zerox,	011101000b,11b,operand_ds	;	ZEROX	D,S/#
asmcode		ac_signx,	011101100b,11b,operand_ds	;	SIGNX	D,S/#

asmcode		ac_encod,	011110000b,11b,operand_du	;	ENCOD	D{,S/#}
asmcode		ac_ones,	011110100b,11b,operand_du	;	ONES	D{,S/#}
asmcode		ac_test,	011111000b,11b,operand_du	;	TEST	D,{S/#}
asmcode		ac_testn,	011111100b,11b,operand_ds	;	TESTN	D,S/#

asmcode		ac_setnib,	100000000b,00b,operand_ds3set	;	SETNIB	{D,}S/#{,#0..7}
asmcode		ac_getnib,	100001000b,00b,operand_ds3get	;	GETNIB	D{,S/#,#0..7}
asmcode		ac_rolnib,	100010000b,00b,operand_ds3get	;	ROLNIB	D{,S/#,#0..7}

asmcode		ac_setbyte,	100011000b,00b,operand_ds2set	;	SETBYTE	{D,}S/#{,#0..3}
asmcode		ac_getbyte,	100011100b,00b,operand_ds2get	;	GETBYTE	D{,S/#,#0..3}
asmcode		ac_rolbyte,	100100000b,00b,operand_ds2get	;	ROLBYTE	D{,S/#,#0..3}

asmcode		ac_setword,	100100100b,00b,operand_ds1set	;	SETWORD	{D,}S/#{,#0..1}
asmcode		ac_getword,	100100110b,00b,operand_ds1get	;	GETWORD	D{,S/#,#0..1}
asmcode		ac_rolword,	100101000b,00b,operand_ds1get	;	ROLWORD	D{,S/#,#0..1}

asmcode		ac_altsn,	100101010b,00b,operand_duiz	;	ALTSN	D{,S/#}
asmcode		ac_altgn,	100101011b,00b,operand_duiz	;	ALTGN	D{,S/#}
asmcode		ac_altsb,	100101100b,00b,operand_duiz	;	ALTSB	D{,S/#}
asmcode		ac_altgb,	100101101b,00b,operand_duiz	;	ALTGB	D{,S/#}
asmcode		ac_altsw,	100101110b,00b,operand_duiz	;	ALTSW	D{,S/#}
asmcode		ac_altgw,	100101111b,00b,operand_duiz	;	ALTGW	D{,S/#}
asmcode		ac_altr,	100110000b,00b,operand_duiz	;	ALTR	D{,S/#}
asmcode		ac_altd,	100110001b,00b,operand_duiz	;	ALTD	D{,S/#}
asmcode		ac_alts,	100110010b,00b,operand_duiz	;	ALTS	D{,S/#}
asmcode		ac_altb,	100110011b,00b,operand_duiz	;	ALTB	D{,S/#}
asmcode		ac_alti,	100110100b,00b,operand_duii	;	ALTI	D{,S/#}
asmcode		ac_setr,	100110101b,00b,operand_ds	;	SETR	D,S/#
asmcode		ac_setd,	100110110b,00b,operand_ds	;	SETD	D,S/#
asmcode		ac_sets,	100110111b,00b,operand_ds	;	SETS	D,S/#
asmcode		ac_decod,	100111000b,00b,operand_du	;	DECOD	D{,S/#}
asmcode		ac_bmask,	100111001b,00b,operand_du	;	BMASK	D{,S/#}
asmcode		ac_crcbit,	100111010b,00b,operand_ds	;	CRCBIT	D,S/#
asmcode		ac_crcnib,	100111011b,00b,operand_ds	;	CRCNIB	D,S/#
asmcode		ac_muxnits,	100111100b,00b,operand_ds	;	MUXNITS	D,S/#
asmcode		ac_muxnibs,	100111101b,00b,operand_ds	;	MUXNIBS	D,S/#
asmcode		ac_muxq,	100111110b,00b,operand_ds	;	MUXQ	D,S/#
asmcode		ac_movbyts,	100111111b,00b,operand_ds	;	MOVBYTS	D,S/#

asmcode		ac_mul,		101000000b,01b,operand_ds	;	MUL	D,S/#
asmcode		ac_muls,	101000010b,01b,operand_ds	;	MULS	D,S/#
asmcode		ac_sca,		101000100b,01b,operand_ds	;	SCA	D,S/#
asmcode		ac_scas,	101000110b,01b,operand_ds	;	SCAS	D,S/#

asmcode		ac_addpix,	101001000b,00b,operand_ds	;	ADDPIX	D,S/#
asmcode		ac_mulpix,	101001001b,00b,operand_ds	;	MULPIX	D,S/#
asmcode		ac_blnpix,	101001010b,00b,operand_ds	;	BLNPIX	D,S/#
asmcode		ac_mixpix,	101001011b,00b,operand_ds	;	MIXPIX	D,S/#

asmcode		ac_addct1,	101001100b,00b,operand_ds	;	ADDCT1	D,S/#
asmcode		ac_addct2,	101001101b,00b,operand_ds	;	ADDCT2	D,S/#
asmcode		ac_addct3,	101001110b,00b,operand_ds	;	ADDCT3	D,S/#
asmcode		ac_wmlong,	101001111b,00b,operand_dsp	;	WMLONG_	D,S/#/PTRx

asmcode		ac_rqpin,	101010000b,10b,operand_ds	;	RQPIN	D,S/#
asmcode		ac_rdpin,	101010001b,10b,operand_ds	;	RDPIN	D,S/#
asmcode		ac_rdlut,	101010100b,11b,operand_dsp	;	RDLUT	D,S/#/PTRx

asmcode		ac_rdbyte,	101011000b,11b,operand_dsp	;	RDBYTE	D,S/#/PTRx
asmcode		ac_rdword,	101011100b,11b,operand_dsp	;	RDWORD	D,S/#/PTRx
asmcode		ac_rdlong,	101100000b,11b,operand_dsp	;	RDLONG	D,S/#/PTRx

asmcode		ac_callpa,	101101000b,00b,operand_lsj	;	CALLPA	D/#,S/#
asmcode		ac_callpb,	101101010b,00b,operand_lsj	;	CALLPB	D/#,S/#

asmcode		ac_djz,		101101100b,00b,operand_dsj	;	DJZ	D,S/#
asmcode		ac_djnz,	101101101b,00b,operand_dsj	;	DJNZ	D,S/#
asmcode		ac_djf,		101101110b,00b,operand_dsj	;	DJF	D,S/#
asmcode		ac_djnf,	101101111b,00b,operand_dsj	;	DJNF	D,S/#

asmcode		ac_ijz,		101110000b,00b,operand_dsj	;	IJZ	D,S/#
asmcode		ac_ijnz,	101110001b,00b,operand_dsj	;	IJNZ	D,S/#

asmcode		ac_tjz,		101110010b,00b,operand_dsj	;	TJZ	D,S/#
asmcode		ac_tjnz,	101110011b,00b,operand_dsj	;	TJNZ	D,S/#
asmcode		ac_tjf,		101110100b,00b,operand_dsj	;	TJF	D,S/#
asmcode		ac_tjnf,	101110101b,00b,operand_dsj	;	TJNF	D,S/#
asmcode		ac_tjs,		101110110b,00b,operand_dsj	;	TJS	D,S/#
asmcode		ac_tjns,	101110111b,00b,operand_dsj	;	TJNS	D,S/#
asmcode		ac_tjv,		101111000b,00b,operand_dsj	;	TJV	D,S/#

asmcode		ac_jint,	000000000b,00b,operand_jpoll	;	JINT	S/#
asmcode		ac_jct1,	000000001b,00b,operand_jpoll	;	JCT1	S/#
asmcode		ac_jct2,	000000010b,00b,operand_jpoll	;	JCT2	S/#
asmcode		ac_jct3,	000000011b,00b,operand_jpoll	;	JCT3	S/#
asmcode		ac_jse1,	000000100b,00b,operand_jpoll	;	JSE1	S/#
asmcode		ac_jse2,	000000101b,00b,operand_jpoll	;	JSE2	S/#
asmcode		ac_jse3,	000000110b,00b,operand_jpoll	;	JSE3	S/#
asmcode		ac_jse4,	000000111b,00b,operand_jpoll	;	JSE4	S/#
asmcode		ac_jpat,	000001000b,00b,operand_jpoll	;	JPAT	S/#
asmcode		ac_jfbw,	000001001b,00b,operand_jpoll	;	JFBW	S/#
asmcode		ac_jxmt,	000001010b,00b,operand_jpoll	;	JXMT	S/#
asmcode		ac_jxfi,	000001011b,00b,operand_jpoll	;	JXFI	S/#
asmcode		ac_jxro,	000001100b,00b,operand_jpoll	;	JXRO	S/#
asmcode		ac_jxrl,	000001101b,00b,operand_jpoll	;	JXRL	S/#
asmcode		ac_jatn,	000001110b,00b,operand_jpoll	;	JATN	S/#
asmcode		ac_jqmt,	000001111b,00b,operand_jpoll	;	JQMT	S/#

asmcode		ac_jnint,	000010000b,00b,operand_jpoll	;	JNINT	S/#
asmcode		ac_jnct1,	000010001b,00b,operand_jpoll	;	JNCT1	S/#
asmcode		ac_jnct2,	000010010b,00b,operand_jpoll	;	JNCT2	S/#
asmcode		ac_jnct3,	000010011b,00b,operand_jpoll	;	JNCT3	S/#
asmcode		ac_jnse1,	000010100b,00b,operand_jpoll	;	JNSE1	S/#
asmcode		ac_jnse2,	000010101b,00b,operand_jpoll	;	JNSE2	S/#
asmcode		ac_jnse3,	000010110b,00b,operand_jpoll	;	JNSE3	S/#
asmcode		ac_jnse4,	000010111b,00b,operand_jpoll	;	JNSE4	S/#
asmcode		ac_jnpat,	000011000b,00b,operand_jpoll	;	JNPAT	S/#
asmcode		ac_jnfbw,	000011001b,00b,operand_jpoll	;	JNFBW	S/#
asmcode		ac_jnxmt,	000011010b,00b,operand_jpoll	;	JNXMT	S/#
asmcode		ac_jnxfi,	000011011b,00b,operand_jpoll	;	JNXFI	S/#
asmcode		ac_jnxro,	000011100b,00b,operand_jpoll	;	JNXRO	S/#
asmcode		ac_jnxrl,	000011101b,00b,operand_jpoll	;	JNXRL	S/#
asmcode		ac_jnatn,	000011110b,00b,operand_jpoll	;	JNATN	S/#
asmcode		ac_jnqmt,	000011111b,00b,operand_jpoll	;	JNQMT	S/#

;asmcode	ac_empty,	101111010b,00b,operand_ls	;	<empty>	D/#,S/#
;asmcode	ac_empty,	101111100b,00b,operand_ls	;	<empty>	D/#,S/#
asmcode		ac_setpat,	101111110b,00b,operand_ls	;	SETPAT	D/#,S/#

asmcode		ac_wrpin,	110000000b,00b,operand_ls	;	WRPIN	D/#,S/#
asmcode		ac_wxpin,	110000010b,00b,operand_ls	;	WXPIN	D/#,S/#
asmcode		ac_wypin,	110000100b,00b,operand_ls	;	WYPIN	D/#,S/#
asmcode		ac_wrlut,	110000110b,00b,operand_lsp	;	WRLUT	D/#,S/#/PTRx

asmcode		ac_wrbyte,	110001000b,00b,operand_lsp	;	WRBYTE	D/#,S/#/PTRx
asmcode		ac_wrword,	110001010b,00b,operand_lsp	;	WRWORD	D/#,S/#/PTRx
asmcode		ac_wrlong,	110001100b,00b,operand_lsp	;	WRLONG	D/#,S/#/PTRx

asmcode		ac_rdfast,	110001110b,00b,operand_ls	;	RDFAST	D/#,S/#
asmcode		ac_wrfast,	110010000b,00b,operand_ls	;	WRFAST	D/#,S/#
asmcode		ac_fblock,	110010010b,00b,operand_ls	;	FBLOCK	D/#,S/#

asmcode		ac_xinit,	110010100b,00b,operand_ls	;	XINIT	D/#,S/#
asmcode		ac_xzero,	110010110b,00b,operand_ls	;	XZERO	D/#,S/#
asmcode		ac_xcont,	110011000b,00b,operand_ls	;	XCONT	D/#,S/#

asmcode		ac_rep,		110011010b,00b,operand_rep	;	REP	D/#/@,S/#

asmcode		ac_coginit,	110011100b,10b,operand_ls	;	COGINIT	D/#,S/#
asmcode		ac_qmul,	110100000b,00b,operand_ls	;	QMUL	D/#,S/#
asmcode		ac_qdiv,	110100010b,00b,operand_ls	;	QDIV	D/#,S/#
asmcode		ac_qfrac,	110100100b,00b,operand_ls	;	QFRAC	D/#,S/#
asmcode		ac_qsqrt,	110100110b,00b,operand_ls	;	QSQRT	D/#,S/#
asmcode		ac_qrotate,	110101000b,00b,operand_ls	;	QROTATE	D/#,S/#
asmcode		ac_qvector,	110101010b,00b,operand_ls	;	QVECTOR	D/#,S/#

asmcode		ac_hubset,	000000000b,00b,operand_l	;	HUBSET	D/#
asmcode		ac_cogid,	000000001b,10b,operand_l	;	COGID	D/#
asmcode		ac_cogstop,	000000011b,00b,operand_l	;	COGSTOP	D/#
asmcode		ac_locknew,	000000100b,10b,operand_d	;	LOCKNEW	D
asmcode		ac_lockret,	000000101b,00b,operand_l	;	LOCKRET	D/#
asmcode		ac_locktry,	000000110b,10b,operand_l	;	LOCKTRY	D/#
asmcode		ac_lockrel,	000000111b,10b,operand_l	;	LOCKREL	D/#
asmcode		ac_qlog,	000001110b,00b,operand_l	;	QLOG	D/#
asmcode		ac_qexp,	000001111b,00b,operand_l	;	QEXP	D/#

asmcode		ac_rfbyte,	000010000b,11b,operand_d	;	RFBYTE	D
asmcode		ac_rfword,	000010001b,11b,operand_d	;	RFWORD	D
asmcode		ac_rflong,	000010010b,11b,operand_d	;	RFLONG	D
asmcode		ac_rfvar,	000010011b,11b,operand_d	;	RFVAR	D
asmcode		ac_rfvars,	000010100b,11b,operand_d	;	RFVARS	D

asmcode		ac_wfbyte,	000010101b,00b,operand_l	;	WFBYTE	D/#
asmcode		ac_wfword,	000010110b,00b,operand_l	;	WFWORD	D/#
asmcode		ac_wflong,	000010111b,00b,operand_l	;	WFLONG	D/#

asmcode		ac_getqx,	000011000b,11b,operand_d	;	GETQX	D
asmcode		ac_getqy,	000011001b,11b,operand_d	;	GETQY	D

asmcode		ac_getct,	000011010b,10b,operand_d	;	GETCT	D
asmcode		ac_getrnd,	000011011b,11b,operand_de	;	GETRND	D

asmcode		ac_setdacs,	000011100b,00b,operand_l	;	SETDACS	D/#
asmcode		ac_setxfrq,	000011101b,00b,operand_l	;	SETXFRQ	D/#
asmcode		ac_getxacc,	000011110b,00b,operand_d	;	GETXACC	D
asmcode		ac_waitx,	000011111b,11b,operand_l	;	WAITX	D/#

asmcode		ac_setse1,	000100000b,00b,operand_l	;	SETSE1	D/#
asmcode		ac_setse2,	000100001b,00b,operand_l	;	SETSE2	D/#
asmcode		ac_setse3,	000100010b,00b,operand_l	;	SETSE3	D/#
asmcode		ac_setse4,	000100011b,00b,operand_l	;	SETSE4	D/#

asmcode		ac_pollint,	000000000b,11b,operand_pollwait	;	POLLINT
asmcode		ac_pollct1,	000000001b,11b,operand_pollwait	;	POLLCT1
asmcode		ac_pollct2,	000000010b,11b,operand_pollwait	;	POLLCT2
asmcode		ac_pollct3,	000000011b,11b,operand_pollwait	;	POLLCT3
asmcode		ac_pollse1,	000000100b,11b,operand_pollwait	;	POLLSE1
asmcode		ac_pollse2,	000000101b,11b,operand_pollwait	;	POLLSE2
asmcode		ac_pollse3,	000000110b,11b,operand_pollwait	;	POLLSE3
asmcode		ac_pollse4,	000000111b,11b,operand_pollwait	;	POLLSE4
asmcode		ac_pollpat,	000001000b,11b,operand_pollwait	;	POLLPAT
asmcode		ac_pollfbw,	000001001b,11b,operand_pollwait	;	POLLFBW
asmcode		ac_pollxmt,	000001010b,11b,operand_pollwait	;	POLLXMT
asmcode		ac_pollxfi,	000001011b,11b,operand_pollwait	;	POLLXFI
asmcode		ac_pollxro,	000001100b,11b,operand_pollwait	;	POLLXRO
asmcode		ac_pollxrl,	000001101b,11b,operand_pollwait	;	POLLXRL
asmcode		ac_pollatn,	000001110b,11b,operand_pollwait	;	POLLATN
asmcode		ac_pollqmt,	000001111b,11b,operand_pollwait	;	POLLQMT

asmcode		ac_waitint,	000010000b,11b,operand_pollwait	;	WAITINT
asmcode		ac_waitct1,	000010001b,11b,operand_pollwait	;	WAITCT1
asmcode		ac_waitct2,	000010010b,11b,operand_pollwait	;	WAITCT2
asmcode		ac_waitct3,	000010011b,11b,operand_pollwait	;	WAITCT3
asmcode		ac_waitse1,	000010100b,11b,operand_pollwait	;	WAITSE1
asmcode		ac_waitse2,	000010101b,11b,operand_pollwait	;	WAITSE2
asmcode		ac_waitse3,	000010110b,11b,operand_pollwait	;	WAITSE3
asmcode		ac_waitse4,	000010111b,11b,operand_pollwait	;	WAITSE4
asmcode		ac_waitpat,	000011000b,11b,operand_pollwait	;	WAITPAT
asmcode		ac_waitfbw,	000011001b,11b,operand_pollwait	;	WAITFBW
asmcode		ac_waitxmt,	000011010b,11b,operand_pollwait	;	WAITXMT
asmcode		ac_waitxfi,	000011011b,11b,operand_pollwait	;	WAITXFI
asmcode		ac_waitxro,	000011100b,11b,operand_pollwait	;	WAITXRO
asmcode		ac_waitxrl,	000011101b,11b,operand_pollwait	;	WAITXRL
asmcode		ac_waitatn,	000011110b,11b,operand_pollwait	;	WAITATN

asmcode		ac_allowi,	000100000b,00b,operand_pollwait	;	ALLOWI
asmcode		ac_stalli,	000100001b,00b,operand_pollwait	;	STALLI

asmcode		ac_trgint1,	000100010b,00b,operand_pollwait	;	TRGINT1
asmcode		ac_trgint2,	000100011b,00b,operand_pollwait	;	TRGINT2
asmcode		ac_trgint3,	000100100b,00b,operand_pollwait	;	TRGINT3

asmcode		ac_nixint1,	000100101b,00b,operand_pollwait	;	NIXINT1
asmcode		ac_nixint2,	000100110b,00b,operand_pollwait	;	NIXINT2
asmcode		ac_nixint3,	000100111b,00b,operand_pollwait	;	NIXINT3

asmcode		ac_setint1,	000100101b,00b,operand_l	;	SETINT1	D/#
asmcode		ac_setint2,	000100110b,00b,operand_l	;	SETINT2	D/#
asmcode		ac_setint3,	000100111b,00b,operand_l	;	SETINT3	D/#

asmcode		ac_setq,	000101000b,00b,operand_l	;	SETQ	D/#
asmcode		ac_setq2,	000101001b,00b,operand_l	;	SETQ2	D/#
asmcode		ac_push,	000101010b,00b,operand_l	;	PUSH	D/#
asmcode		ac_pop,		000101011b,11b,operand_d	;	POP	D

asmcode		ac_jmprel,	000110000b,00b,operand_l	;	JMPREL	D/#
asmcode		ac_skip,	000110001b,00b,operand_l	;	SKIP	D/#
asmcode		ac_skipf,	000110010b,00b,operand_l	;	SKIPF	D/#
asmcode		ac_execf,	000110011b,00b,operand_l	;	EXECF	D/#

asmcode		ac_getptr,	000110100b,00b,operand_d	;	GETPTR	D
asmcode		ac_getbrk,	000110101b,11b,operand_getbrk	;	GETBRK	D
asmcode		ac_cogbrk,	000110101b,00b,operand_l	;	COGBRK	D/#
asmcode		ac_brk,		000110110b,00b,operand_l	;	BRK	D/#

asmcode		ac_setluts,	000110111b,00b,operand_l	;	SETLUTS	D/#

asmcode		ac_setcy,	000111000b,00b,operand_l	;	SETCY	D/#
asmcode		ac_setci,	000111001b,00b,operand_l	;	SETCI	D/#
asmcode		ac_setcq,	000111010b,00b,operand_l	;	SETCQ	D/#
asmcode		ac_setcfrq,	000111011b,00b,operand_l	;	SETCFRQ	D/#
asmcode		ac_setcmod,	000111100b,00b,operand_l	;	SETCMOD	D/#

asmcode		ac_setpiv,	000111101b,00b,operand_l	;	SETPIV	D/#
asmcode		ac_setpix,	000111110b,00b,operand_l	;	SETPIX	D/#

asmcode		ac_cogatn,	000111111b,00b,operand_l	;	COGATN	D/#

asmcode		ac_testp,	001000000b,00b,operand_testp	;	TESTP	D/#
asmcode		ac_testpn,	001000001b,00b,operand_testp	;	TESTPN	D/#

asmcode		ac_dirl,	001000000b,00b,operand_pinop	;	DIRL	D/#
asmcode		ac_dirh,	001000001b,00b,operand_pinop	;	DIRH	D/#
asmcode		ac_dirc,	001000010b,00b,operand_pinop	;	DIRC	D/#
asmcode		ac_dirnc,	001000011b,00b,operand_pinop	;	DIRNC	D/#
asmcode		ac_dirz,	001000100b,00b,operand_pinop	;	DIRZ	D/#
asmcode		ac_dirnz,	001000101b,00b,operand_pinop	;	DIRNZ	D/#
asmcode		ac_dirrnd,	001000110b,00b,operand_pinop	;	DIRRND	D/#
asmcode		ac_dirnot,	001000111b,00b,operand_pinop	;	DIRNOT	D/#

asmcode		ac_outl,	001001000b,00b,operand_pinop	;	OUTL	D/#
asmcode		ac_outh,	001001001b,00b,operand_pinop	;	OUTH	D/#
asmcode		ac_outc,	001001010b,00b,operand_pinop	;	OUTC	D/#
asmcode		ac_outnc,	001001011b,00b,operand_pinop	;	OUTNC	D/#
asmcode		ac_outz,	001001100b,00b,operand_pinop	;	OUTZ	D/#
asmcode		ac_outnz,	001001101b,00b,operand_pinop	;	OUTNZ	D/#
asmcode		ac_outrnd,	001001110b,00b,operand_pinop	;	OUTRND	D/#
asmcode		ac_outnot,	001001111b,00b,operand_pinop	;	OUTNOT	D/#

asmcode		ac_fltl,	001010000b,00b,operand_pinop	;	FLTL	D/#
asmcode		ac_flth,	001010001b,00b,operand_pinop	;	FLTH	D/#
asmcode		ac_fltc,	001010010b,00b,operand_pinop	;	FLTC	D/#
asmcode		ac_fltnc,	001010011b,00b,operand_pinop	;	FLTNC	D/#
asmcode		ac_fltz,	001010100b,00b,operand_pinop	;	FLTZ	D/#
asmcode		ac_fltnz,	001010101b,00b,operand_pinop	;	FLTNZ	D/#
asmcode		ac_fltrnd,	001010110b,00b,operand_pinop	;	FLTRND	D/#
asmcode		ac_fltnot,	001010111b,00b,operand_pinop	;	FLTNOT	D/#

asmcode		ac_drvl,	001011000b,00b,operand_pinop	;	DRVL	D/#
asmcode		ac_drvh,	001011001b,00b,operand_pinop	;	DRVH	D/#
asmcode		ac_drvc,	001011010b,00b,operand_pinop	;	DRVC	D/#
asmcode		ac_drvnc,	001011011b,00b,operand_pinop	;	DRVNC	D/#
asmcode		ac_drvz,	001011100b,00b,operand_pinop	;	DRVZ	D/#
asmcode		ac_drvnz,	001011101b,00b,operand_pinop	;	DRVNZ	D/#
asmcode		ac_drvrnd,	001011110b,00b,operand_pinop	;	DRVRND	D/#
asmcode		ac_drvnot,	001011111b,00b,operand_pinop	;	DRVNOT	D/#

asmcode		ac_splitb,	001100000b,00b,operand_d	;	SPLITB	D
asmcode		ac_mergeb,	001100001b,00b,operand_d	;	MERGEB	D
asmcode		ac_splitw,	001100010b,00b,operand_d	;	SPLITW	D
asmcode		ac_mergew,	001100011b,00b,operand_d	;	MERGEW	D
asmcode		ac_seussf,	001100100b,00b,operand_d	;	SEUSSF	D
asmcode		ac_seussr,	001100101b,00b,operand_d	;	SEUSSR	D
asmcode		ac_rgbsqz,	001100110b,00b,operand_d	;	RGBSQZ	D
asmcode		ac_rgbexp,	001100111b,00b,operand_d	;	RGBEXP	D
asmcode		ac_xoro32,	001101000b,00b,operand_d	;	XORO32	D
asmcode		ac_rev,		001101001b,00b,operand_d	;	REV	D
asmcode		ac_rczr,	001101010b,11b,operand_d	;	RCZR	D
asmcode		ac_rczl,	001101011b,11b,operand_d	;	RCZL	D
asmcode		ac_wrc,		001101100b,00b,operand_d	;	WRC	D
asmcode		ac_wrnc,	001101101b,00b,operand_d	;	WRNC	D
asmcode		ac_wrz,		001101110b,00b,operand_d	;	WRZ	D
asmcode		ac_wrnz,	001101111b,00b,operand_d	;	WRNZ	D
asmcode		ac_modcz,	001101111b,11b,operand_cz	;	MODCZ	c,z
asmcode		ac_modc,	001101111b,10b,operand_cz	;	MODC	c
asmcode		ac_modz,	001101111b,01b,operand_cz	;	MODZ	z

asmcode		ac_setscp,	001110000b,00b,operand_l	;	SETSCP	D/#
asmcode		ac_getscp,	001110001b,00b,operand_d	;	GETSCP	D

asmcode		ac_jmp,		110110000b,00b,operand_jmp	;	JMP	# <or> D
asmcode		ac_call,	110110100b,00b,operand_call	;	CALL	# <or> D
asmcode		ac_calla,	110111000b,00b,operand_call	;	CALLA	# <or> D
asmcode		ac_callb,	110111100b,00b,operand_call	;	CALLB	# <or> D
asmcode		ac_calld,	111000000b,00b,operand_calld	;	CALLD	reg,# / D,S
asmcode		ac_loc,		111010000b,00b,operand_loc	;	LOC	reg,#

asmcode		ac_augs,	111100000b,00b,operand_aug	;	AUGS	#
asmcode		ac_augd,	111110000b,00b,operand_aug	;	AUGD	#


asmcode		ac_pusha,	pp_pusha,  00b,operand_pushpop	;	PUSHA	D/#	alias instructions
asmcode		ac_pushb,	pp_pushb,  00b,operand_pushpop	;	PUSHB	D/#
asmcode		ac_popa,	pp_popa,   11b,operand_pushpop	;	POPA	D
asmcode		ac_popb,	pp_popb,   11b,operand_pushpop	;	POPB	D

asmcode		ac_ret,		0,	   11b,operand_xlat	;	RET
asmcode		ac_reta,	1,	   11b,operand_xlat	;	RETA
asmcode		ac_retb,	2,	   11b,operand_xlat	;	RETB
asmcode		ac_reti0,	3,	   00b,operand_xlat	;	RETI0
asmcode		ac_reti1,	4,	   00b,operand_xlat	;	RETI1
asmcode		ac_reti2,	5,	   00b,operand_xlat	;	RETI2
asmcode		ac_reti3,	6,	   00b,operand_xlat	;	RETI3
asmcode		ac_resi0,	7,	   00b,operand_xlat	;	RESI0
asmcode		ac_resi1,	8,	   00b,operand_xlat	;	RESI1
asmcode		ac_resi2,	9,	   00b,operand_xlat	;	RESI2
asmcode		ac_resi3,	10,	   00b,operand_xlat	;	RESI3
asmcode		ac_xstop,	11,	   00b,operand_xlat	;	XSTOP

asmcode		ac_akpin,	0,	   00b,operand_akpin	;	AKPIN	S/#

asmcode		ac_asmclk,	0,	   00b,operand_asmclk	;	ASMCLK

asmcode		ac_nop,		000000000b,00b,operand_nop	;	NOP

asmcode		ac_debug,	000110110b,00b,operand_debug	;	DEBUG()
;
;
; Types
;
count0		type_undefined		;	(undefined symbol, must be 0)
count		type_pre_command	;	preprocessor commands DEFINE/UNDEF/IFDEF/IFNDEF/ELSEIFDEF/ELSEIFNDEF/ELSE/ENDIF
count		type_pre_symbol		;	preprocessor symbols
count		type_left		;	(
count		type_right		;	)
count		type_leftb		;	[
count		type_rightb		;	]
count		type_comma		;	,
count		type_equal		;	=
count		type_pound		;	#
count		type_colon		;	:
count		type_back		;	\
count		type_under		;	_
count		type_tick		;	`
count		type_dollar		;	$ (without a hex digit following)
count		type_dollar2		;	$$
count		type_percent		;	% (without a bin digit or quote following)
count		type_dot		;	.
count		type_dotdot		;	..
count		type_at			;	@
count		type_atat		;	@@
count		type_upat		;	^@
count		type_til		;	~
count		type_tiltil		;	~~
count		type_inc		;	++
count		type_dec		;	--
count		type_rnd		;	??
count		type_assign		;	:=
count		type_swap		;	:=:
count		type_op			;	!, -, ABS, ENC, etc.
count		type_float		;	FLOAT
count		type_round		;	ROUND
count		type_trunc		;	TRUNC
count		type_constr		;	STRING
count		type_conlstr		;	LSTRING
count		type_block		;	CON, VAR, DAT, OBJ, PUB, PRI
count		type_field		;	FIELD
count		type_struct		;	STRUCT
count		type_sizeof		;	SIZEOF
count		type_size		;	BYTE, WORD, LONG
count		type_size_fit		;	BYTEFIT, WORDFIT
count		type_fvar		;	FVAR, FVARS
count		type_file		;	FILE
count		type_if			;	IF
count		type_ifnot		;	IFNOT
count		type_elseif		;	ELSEIF
count		type_elseifnot		;	ELSEIFNOT
count		type_else		;	ELSE
count		type_case		;	CASE
count		type_case_fast		;	CASE_FAST
count		type_other		;	OTHER
count		type_repeat		;	REPEAT
count		type_repeat_var		;	REPEAT var		- different QUIT method
count		type_repeat_count	;	REPEAT count		- different QUIT method
count		type_repeat_count_var	;	REPEAT count WITH var	- different QUIT method
count		type_while		;	WHILE
count		type_until		;	UNTIL
count		type_from		;	FROM
count		type_to			;	TO
count		type_step		;	STEP
count		type_with		;	WITH
count		type_i_next_quit	;	NEXT/QUIT
count		type_i_return		;	RETURN
count		type_i_abort		;	ABORT
count		type_i_look		;	LOOKUPZ, LOOKUP, LOOKDOWNZ, LOOKDOWN
count		type_i_cogspin		;	COGSPIN
count		type_i_taskspin		;	TASKSPIN
count		type_i_flex		;	HUBSET, COGINIT, COGSTOP...
count		type_recv		;	RECV
count		type_send		;	SEND
count		type_debug		;	DEBUG
count		type_debug_cmd		;	DEBUG commands
count		type_asm_end		;	END
count		type_asm_dir		;	ORGH, ORG, ORGF, RES, FIT
count		type_asm_cond		;	IF_C, IF_Z, IF_NC, etc
count		type_asm_inst		;	RDBYTE, RDWORD, RDLONG, etc.
count		type_asm_effect		;	WC, WZ, WCZ
count		type_asm_effect2	;	ANDC, ANDZ, ORC, ORZ, XORC, XORZ
count		type_reg		;	REG
count		type_con_int		;C0	user constant integer		(C0..C2 must be contiguous)
count		type_con_float		;C1	user constant float
count		type_con_struct		;C2	user data structure
count		type_register		;	user register long
count		type_loc_byte		;L0	user loc byte			(L0..L11 must be contiguous)
count		type_loc_word		;L1	user loc word
count		type_loc_long		;L2	user loc long
count		type_loc_struct		;L3	user loc struct
count		type_loc_byte_ptr	;L4	user loc byte ptr
count		type_loc_word_ptr	;L5	user loc word ptr
count		type_loc_long_ptr	;L6	user loc long ptr
count		type_loc_struct_ptr	;L7	user loc struct ptr
count		type_loc_byte_ptr_val	;L8	internal loc byte ptr val
count		type_loc_word_ptr_val	;L9	internal loc word ptr val
count		type_loc_long_ptr_val	;L10	internal loc long ptr val
count		type_loc_struct_ptr_val	;L11	internal loc struct ptr val
count		type_var_byte		;V0	user var byte			(V0..V11 must be contiguous)
count		type_var_word		;V1	user var word
count		type_var_long		;V2	user var long
count		type_var_struct		;V3	user var struct
count		type_var_byte_ptr	;V4	user var byte ptr
count		type_var_word_ptr	;V5	user var word ptr
count		type_var_long_ptr	;V6	user var long ptr
count		type_var_struct_ptr	;V7	user var struct ptr
count		type_var_byte_ptr_val	;V8	internal var byte ptr val
count		type_var_word_ptr_val	;V9	internal var word ptr val
count		type_var_long_ptr_val	;V10	internal var long ptr val
count		type_var_struct_ptr_val	;V11	internal var struct ptr val
count		type_dat_byte		;D0	user dat byte			(D0..D3 must be contiguous)
count		type_dat_word		;D1	user dat word
count		type_dat_long		;D2	user dat long
count		type_dat_struct		;D3	user dat struct
count		type_dat_long_res	;(D2)	user dat long reserve
count		type_hub_byte		;H0	user hub byte (unused)		(H0..H2 must be contiguous)
count		type_hub_word		;H1	user hub word (unused)
count		type_hub_long		;H2	user hub long (CLKMODE, CLKFREQ)
count		type_obj		;	user object
count		type_obj_con_int	;O1	user object.constant integer	(O0..O2 must be contiguous)
count		type_obj_con_float	;O2	user object.constant float
count		type_obj_con_struct	;O3	user object.constant structure
count		type_obj_pub		;	user object.method()
count		type_method		;	user method
count		type_end		;	end-of-line c=0, end-of-file c=1
;
;
; Bytecodes
;
count0		bc_drop				;main bytecodes
count		bc_drop_push
count		bc_drop_trap
count		bc_drop_trap_push

count		bc_return_results
count		bc_return_args

count		bc_abort_0
count		bc_abort_arg

count		bc_call_obj_sub
count		bc_call_obji_sub
count		bc_call_sub
count		bc_call_ptr
count		bc_call_recv
count		bc_call_send
count		bc_call_send_bytes

count		bc_mptr_obj_sub
count		bc_mptr_obji_sub
count		bc_mptr_sub

count		bc_jmp
count		bc_jz
count		bc_jnz
count		bc_tjz
count		bc_djnz

count		bc_pop
count		bc_pop_rfvar

count		bc_hub_bytecode

count		bc_case_fast_init
count		bc_case_fast_done

count		bc_case_value
count		bc_case_range
count		bc_case_done

count		bc_lookup_value
count		bc_lookdown_value
count		bc_lookup_range
count		bc_lookdown_range
count		bc_look_done

count		bc_add_pbase

count		bc_coginit
count		bc_coginit_push
count		bc_cogstop
count		bc_cogid

count		bc_locknew
count		bc_lockret
count		bc_locktry
count		bc_lockrel
count		bc_lockchk

count		bc_cogatn
count		bc_pollatn
count		bc_waitatn

count		bc_getrnd
count		bc_getct
count		bc_pollct
count		bc_waitct

count		bc_pinlow
count		bc_pinhigh
count		bc_pintoggle
count		bc_pinfloat

count		bc_wrpin
count		bc_wxpin
count		bc_wypin
count		bc_akpin
count		bc_rdpin
count		bc_rqpin

count		bc_tasknext
count		bc_unused

count		bc_debug

count		bc_con_rfbyte
count		bc_con_rfbyte_not
count		bc_con_rfword
count		bc_con_rfword_not
count		bc_con_rflong
count		bc_con_rfbyte_decod
count		bc_con_rfbyte_decod_not
count		bc_con_rfbyte_bmask
count		bc_con_rfbyte_bmask_not

count		bc_setup_field_p
count		bc_setup_field_pi

count		bc_setup_reg
count		bc_setup_reg_pi

count		bc_setup_byte_pbase
count		bc_setup_byte_vbase
count		bc_setup_byte_dbase

count		bc_setup_byte_pbase_pi
count		bc_setup_byte_vbase_pi
count		bc_setup_byte_dbase_pi

count		bc_setup_word_pbase
count		bc_setup_word_vbase
count		bc_setup_word_dbase

count		bc_setup_word_pbase_pi
count		bc_setup_word_vbase_pi
count		bc_setup_word_dbase_pi

count		bc_setup_long_pbase
count		bc_setup_long_vbase
count		bc_setup_long_dbase

count		bc_setup_long_pbase_pi
count		bc_setup_long_vbase_pi
count		bc_setup_long_dbase_pi

count		bc_setup_byte_pa
count		bc_setup_word_pa
count		bc_setup_long_pa

count		bc_setup_byte_pb_pi
count		bc_setup_word_pb_pi
count		bc_setup_long_pb_pi

count		bc_setup_struct_pbase
count		bc_setup_struct_vbase
count		bc_setup_struct_dbase
count		bc_setup_struct_pop

count		bc_ternary

count		bc_lt
count		bc_ltu
count		bc_lte
count		bc_lteu
count		bc_e
count		bc_ne
count		bc_gte
count		bc_gteu
count		bc_gt
count		bc_gtu
count		bc_ltegt

count		bc_lognot
count		bc_bitnot
count		bc_neg
count		bc_abs
count		bc_encod
count		bc_decod
count		bc_bmask
count		bc_ones
count		bc_sqrt
count		bc_qlog
count		bc_qexp

count		bc_shr
count		bc_shl
count		bc_sar
count		bc_ror
count		bc_rol
count		bc_rev
count		bc_zerox
count		bc_signx
count		bc_add
count		bc_sub

count		bc_logand
count		bc_logxor
count		bc_logor
count		bc_bitand
count		bc_bitxor
count		bc_bitor
count		bc_fge
count		bc_fle
count		bc_addbits
count		bc_addpins

count		bc_mul
count		bc_div
count		bc_divu
count		bc_rem
count		bc_remu
count		bc_sca
count		bc_scas
count		bc_frac

count		bc_string
count		bc_bitrange

counti		bc_con_n		,16
counti		bc_setup_reg_1D8_1F8	,16
counti		bc_setup_var_0_15	,16
counti		bc_setup_local_0_15	,16
counti		bc_read_local_0_15	,16
counti		bc_write_local_0_15	,16


countn		bc_set_incdec		,79h	;variable operator bytecodes

count		bc_repeat_var_init_n
count		bc_repeat_var_init_1
count		bc_repeat_var_init
count		bc_repeat_var_loop

count		bc_get_field
count		bc_get_addr
count		bc_read
count		bc_write
count		bc_write_push

count		bc_var_inc
count		bc_var_dec
count		bc_var_preinc_push
count		bc_var_predec_push
count		bc_var_postinc_push
count		bc_var_postdec_push
count		bc_var_lognot
count		bc_var_lognot_push
count		bc_var_bitnot
count		bc_var_bitnot_push
count		bc_var_swap
count		bc_var_rnd
count		bc_var_rnd_push

count		bc_lognot_write
count		bc_bitnot_write
count		bc_neg_write
count		bc_abs_write
count		bc_encod_write
count		bc_decod_write
count		bc_bmask_write
count		bc_ones_write
count		bc_sqrt_write
count		bc_qlog_write
count		bc_qexp_write

count		bc_shr_write
count		bc_shl_write
count		bc_sar_write
count		bc_ror_write
count		bc_rol_write
count		bc_rev_write
count		bc_zerox_write
count		bc_signx_write
count		bc_add_write
count		bc_sub_write

count		bc_logand_write
count		bc_logxor_write
count		bc_logor_write
count		bc_bitand_write
count		bc_bitxor_write
count		bc_bitor_write
count		bc_fge_write
count		bc_fle_write
count		bc_addbits_write
count		bc_addpins_write

count		bc_mul_write
count		bc_div_write
count		bc_divu_write
count		bc_rem_write
count		bc_remu_write
count		bc_sca_write
count		bc_scas_write
count		bc_frac_write

count		bc_lognot_write_push
count		bc_bitnot_write_push
count		bc_neg_write_push
count		bc_abs_write_push
count		bc_encod_write_push
count		bc_decod_write_push
count		bc_bmask_write_push
count		bc_ones_write_push
count		bc_sqrt_write_push
count		bc_qlog_write_push
count		bc_qexp_write_push

count		bc_shr_write_push
count		bc_shl_write_push
count		bc_sar_write_push
count		bc_ror_write_push
count		bc_rol_write_push
count		bc_rev_write_push
count		bc_zerox_write_push
count		bc_signx_write_push
count		bc_add_write_push
count		bc_sub_write_push

count		bc_logand_write_push
count		bc_logxor_write_push
count		bc_logor_write_push
count		bc_bitand_write_push
count		bc_bitxor_write_push
count		bc_bitor_write_push
count		bc_fge_write_push
count		bc_fle_write_push
count		bc_addbits_write_push
count		bc_addpins_write_push

count		bc_mul_write_push
count		bc_div_write_push
count		bc_divu_write_push
count		bc_rem_write_push
count		bc_remu_write_push
count		bc_sca_write_push
count		bc_scas_write_push
count		bc_frac_write_push

count		bc_setup_bfield_pop
count		bc_setup_bfield_rfvar
counti		bc_setup_bfield_0_31,32


count2n		bc_hubset		,54h	;hub bytecodes, miscellaneous routines (step by 2)
count2		bc_clkset
count2		bc_cogspin
count2		bc_cogchk
count2		bc_org
count2		bc_orgh
count2		bc_regexec
count2		bc_regload
count2		bc_call
count2		bc_getregs
count2		bc_setregs
count2		bc_bytefill
count2		bc_bytemove
count2		bc_byteswap
count2		bc_bytecomp
count2		bc_wordfill
count2		bc_wordmove
count2		bc_wordswap
count2		bc_wordcomp
count2		bc_longfill
count2		bc_longmove
count2		bc_longswap
count2		bc_longcomp
count2		bc_strsize
count2		bc_strcomp
count2		bc_strcopy
count2		bc_getcrc
count2		bc_waitus
count2		bc_waitms
count2		bc_getms
count2		bc_getsec
count2		bc_muldiv64
count2		bc_qsin
count2		bc_qcos
count2		bc_rotxy
count2		bc_polxy
count2		bc_xypol
count2		bc_pinread
count2		bc_pinwrite
count2		bc_pinstart
count2		bc_pinclear

count2		bc_float			;hub bytecodes, floating point routines
count2		bc_round
count2		bc_trunc
count2		bc_nan
count2		bc_fneg
count2		bc_fabs
count2		bc_flt
count2		bc_fgt
count2		bc_fne
count2		bc_fe
count2		bc_flte
count2		bc_fgte
count2		bc_fadd
count2		bc_fsub
count2		bc_fmul
count2		bc_fdiv
count2		bc_pow
count2		bc_log2
count2		bc_log10
count2		bc_log
count2		bc_exp2
count2		bc_exp10
count2		bc_exp
count2		bc_fsqrt

count2		bc_taskspin			;hub bytecodes, multitasking routines
count2		bc_taskstop
count2		bc_taskhalt
count2		bc_taskcont
count2		bc_taskchk
count2		bc_taskid
count2		bc_task_return
;
;
; Flex codes
;
flex_params		=	07h
flex_results		=	38h
flex_results_shift	=	3
flex_pinfld		=	40h
flex_hubcode		=	80h

macro		flexcode	symbol,bytecode,params,results,pinfld,hubcode
symbol		=		bytecode + (params shl 8) + (results shl 11) + (pinfld shl 14) + (hubcode shl 15)
		endm

;		flexcode	bytecode	params	results	pinfld	hubcode
;		---------------------------------------------------------------------------------------
flexcode	fc_coginit,	bc_coginit,	3,	0,	0,	0	;(also asm instruction)
flexcode	fc_coginit_push,bc_coginit_push,3,	1,	0,	0
flexcode	fc_cogstop,	bc_cogstop,	1,	0,	0,	0	;(also asm instruction)
flexcode	fc_cogid,	bc_cogid,	0,	1,	0,	0	;(also asm instruction)
flexcode	fc_cogchk,	bc_cogchk,	1,	1,	0,	1

flexcode	fc_getrnd,	bc_getrnd,	0,	1,	0,	0	;(also asm instruction)
flexcode	fc_getct,	bc_getct,	0,	1,	0,	0	;(also asm instruction)
flexcode	fc_pollct,	bc_pollct,	1,	1,	0,	0
flexcode	fc_waitct,	bc_waitct,	1,	0,	0,	0

flexcode	fc_pinlow,	bc_pinlow,	1,	0,	1,	0
flexcode	fc_pinhigh,	bc_pinhigh,	1,	0,	1,	0
flexcode	fc_pintoggle,	bc_pintoggle,	1,	0,	1,	0
flexcode	fc_pinfloat,	bc_pinfloat,	1,	0,	1,	0
flexcode	fc_pinread,	bc_pinread,	1,	1,	1,	1
flexcode	fc_pinwrite,	bc_pinwrite,	2,	0,	1,	1
flexcode	fc_pinstart,	bc_pinstart,	4,	0,	1,	1
flexcode	fc_pinclear,	bc_pinclear,	1,	0,	1,	1

flexcode	fc_wrpin,	bc_wrpin,	2,	0,	1,	0	;(also asm instruction)
flexcode	fc_wxpin,	bc_wxpin,	2,	0,	1,	0	;(also asm instruction)
flexcode	fc_wypin,	bc_wypin,	2,	0,	1,	0	;(also asm instruction)
flexcode	fc_akpin,	bc_akpin,	1,	0,	1,	0	;(also asm instruction)
flexcode	fc_rdpin,	bc_rdpin,	1,	1,	0,	0	;(also asm instruction)
flexcode	fc_rqpin,	bc_rqpin,	1,	1,	0,	0	;(also asm instruction)

flexcode	fc_locknew,	bc_locknew,	0,	1,	0,	0	;(also asm instruction)
flexcode	fc_lockret,	bc_lockret,	1,	0,	0,	0	;(also asm instruction)
flexcode	fc_locktry,	bc_locktry,	1,	1,	0,	0	;(also asm instruction)
flexcode	fc_lockrel,	bc_lockrel,	1,	0,	0,	0	;(also asm instruction)
flexcode	fc_lockchk,	bc_lockchk,	1,	1,	0,	0

flexcode	fc_cogatn,	bc_cogatn,	1,	0,	0,	0	;(also asm instruction)
flexcode	fc_pollatn,	bc_pollatn,	0,	1,	0,	0	;(also asm instruction)
flexcode	fc_waitatn,	bc_waitatn,	0,	0,	0,	0	;(also asm instruction)

flexcode	fc_hubset,	bc_hubset,	1,	0,	0,	1	;(also asm instruction)
flexcode	fc_clkset,	bc_clkset,	2,	0,	0,	1
flexcode	fc_regexec,	bc_regexec,	1,	0,	0,	1
flexcode	fc_regload,	bc_regload,	1,	0,	0,	1
flexcode	fc_call,	bc_call,	1,	0,	0,	1	;(also asm instruction)
flexcode	fc_getregs,	bc_getregs,	3,	0,	0,	1
flexcode	fc_setregs,	bc_setregs,	3,	0,	0,	1

flexcode	fc_bytefill,	bc_bytefill,	3,	0,	0,	1
flexcode	fc_bytemove,	bc_bytemove,	3,	0,	0,	1
flexcode	fc_byteswap,	bc_byteswap,	3,	0,	0,	1
flexcode	fc_bytecomp,	bc_bytecomp,	3,	1,	0,	1
flexcode	fc_wordfill,	bc_wordfill,	3,	0,	0,	1
flexcode	fc_wordmove,	bc_wordmove,	3,	0,	0,	1
flexcode	fc_wordswap,	bc_wordswap,	3,	0,	0,	1
flexcode	fc_wordcomp,	bc_wordcomp,	3,	1,	0,	1
flexcode	fc_longfill,	bc_longfill,	3,	0,	0,	1
flexcode	fc_longmove,	bc_longmove,	3,	0,	0,	1
flexcode	fc_longswap,	bc_longswap,	3,	0,	0,	1
flexcode	fc_longcomp,	bc_longcomp,	3,	1,	0,	1

flexcode	fc_strsize,	bc_strsize,	1,	1,	0,	1
flexcode	fc_strcomp,	bc_strcomp,	2,	1,	0,	1
flexcode	fc_strcopy,	bc_strcopy,	3,	0,	0,	1

flexcode	fc_getcrc,	bc_getcrc,	3,	1,	0,	1

flexcode	fc_waitus,	bc_waitus,	1,	0,	0,	1
flexcode	fc_waitms,	bc_waitms,	1,	0,	0,	1
flexcode	fc_getms,	bc_getms,	0,	1,	0,	1
flexcode	fc_getsec,	bc_getsec,	0,	1,	0,	1
flexcode	fc_muldiv64,	bc_muldiv64,	3,	1,	0,	1
flexcode	fc_qsin,	bc_qsin,	3,	1,	0,	1
flexcode	fc_qcos,	bc_qcos,	3,	1,	0,	1
flexcode	fc_rotxy,	bc_rotxy,	3,	2,	0,	1
flexcode	fc_polxy,	bc_polxy,	2,	2,	0,	1
flexcode	fc_xypol,	bc_xypol,	2,	2,	0,	1

flexcode	fc_float,	bc_float,	1,	1,	0,	1
flexcode	fc_round,	bc_round,	1,	1,	0,	1
flexcode	fc_trunc,	bc_trunc,	1,	1,	0,	1
flexcode	fc_nan,		bc_nan,		1,	1,	0,	1

flexcode	fc_tasknext,	bc_tasknext,	0,	0,	0,	0
flexcode	fc_taskstop,	bc_taskstop,	1,	0,	0,	1
flexcode	fc_taskhalt,	bc_taskhalt,	1,	0,	0,	1
flexcode	fc_taskcont,	bc_taskcont,	1,	0,	0,	1
flexcode	fc_taskchk,	bc_taskchk,	1,	1,	0,	1
flexcode	fc_taskid,	bc_taskid,	0,	1,	0,	1
;
;
; Operators
;
;	Operator precedence (highest to lowest)
;
;	0	!, -, ABS, FABS, ENCOD, DECOD, BMASK, ONES, SQRT, FSQRT, QLOG, QEXP,...	(unary)
;	1	>>, <<, SAR, ROR, ROL, REV, ZEROX, SIGNX				(binary)
;	2	&									(binary)
;	3	^									(binary)
;	4	|									(binary)
;	5	*, *., /, /., +/, //, +//, SCA, SCAS, FRAC				(binary)
;	6	+, +., -, -., POW							(binary)
;	7	#>, <#									(binary)
;	8	ADDBITS, ADDPINS							(binary)
;	9	<, <., +<, <=, <=., +<=, ==, ==., <>, <>., >=, >=., +>=, >, >., +>, <=>	(binary)
;	10	!!, NOT									(unary)
;	11	&&, AND									(binary)
;	12	^^, XOR									(binary)
;	13	||, OR									(binary)
;	14	? :									(ternary)
;
;
;					oper		type		prec	float
;
count0		op_bitnot	;	!		unary		0	-
count		op_neg		;	-		unary		0	yes
count		op_fneg		;	-.		unary		0	-
count		op_abs		;	ABS		unary		0	yes
count		op_fabs		;	FABS		unary		0	-
count		op_encod	;	ENCOD		unary		0	-
count		op_decod	;	DECOD		unary		0	-
count		op_bmask	;	BMASK		unary		0	-
count		op_ones		;	ONES		unary		0	-
count		op_sqrt		;	SQRT		unary		0	-
count		op_fsqrt	;	FSQRT		unary		0	-
count		op_qlog		;	QLOG		unary		0	-
count		op_qexp		;	QEXP		unary		0	-
count		op_log2		;	LOG2		unary		0	-
count		op_log10	;	LOG10		unary		0	-
count		op_log		;	LOG		unary		0	-
count		op_exp2		;	EXP2		unary		0	-
count		op_exp10	;	EXP10		unary		0	-
count		op_exp		;	EXP		unary		0	-
count		op_shr		;	>>		binary		1	-
count		op_shl		;	<<		binary		1	-
count		op_sar		;	SAR		binary		1	-
count		op_ror		;	ROR		binary		1	-
count		op_rol		;	ROL		binary		1	-
count		op_rev		;	REV		binary		1	-
count		op_zerox	;	ZEROX		binary		1	-
count		op_signx	;	SIGNX		binary		1	-
count		op_bitand	;	&		binary		2	-
count		op_bitxor	;	^		binary		3	-
count		op_bitor	;	|		binary		4	-
count		op_mul		;	*		binary		5	yes
count		op_fmul		;	*.		binary		5	-
count		op_div		;	/		binary		5	yes
count		op_fdiv		;	/.		binary		5	-
count		op_divu		;	+/		binary		5	-
count		op_rem		;	//		binary		5	-
count		op_remu		;	+//		binary		5	-
count		op_sca		;	SCA		binary		5	-
count		op_scas		;	SCAS		binary		5	-
count		op_frac		;	FRAC		binary		5	-
count		op_add		;	+		binary		6	yes
count		op_fadd		;	+.		binary		6	-
count		op_sub		;	-		binary		6	yes
count		op_fsub		;	-.		binary		6	-
count		op_pow		;	POW		binary		6	yes
count		op_fge		;	#>		binary		7	yes
count		op_fle		;	<#		binary		7	yes
count		op_addbits	;	ADDBITS		binary		8	-
count		op_addpins	;	ADDPINS		binary		8	-
count		op_lt		;	<		binary		9	yes
count		op_flt		;	<.		binary		9	-
count		op_ltu		;	+<		binary		9	-
count		op_lte		;	<=		binary		9	yes
count		op_flte		;	<=.		binary		9	-
count		op_lteu		;	+<=		binary		9	-
count		op_e		;	==		binary		9	yes
count		op_fe		;	==.		binary		9	-
count		op_ne		;	<>		binary		9	yes
count		op_fne		;	<>.		binary		9	-
count		op_gte		;	>=		binary		9	yes
count		op_fgte		;	>=.		binary		9	-
count		op_gteu		;	+>=		binary		9	-
count		op_gt		;	>		binary		9	yes
count		op_fgt		;	>.		binary		9	-
count		op_gtu		;	+>		binary		9	-
count		op_ltegt	;	<=>		binary		9	yes
count		op_lognot	;	!!, NOT		unary		10	-
count		op_logand	;	&&, AND		binary		11	-
count		op_logxor	;	^^, XOR		binary		12	-
count		op_logor	;	||, OR		binary		13	-
count		op_ternary	;	? (:)		ternary		14	-

ternary_precedence	=	14


macro		opcode	symbol,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10
symbol		=	v1 + (v2 shl 8) + (v3 shl 16) + (v4 shl 24) + (v5 shl 25) + (v6 shl 26) + (v7 shl 27) + (v8 shl 28) + (v9 shl 29) + (v10 shl 30)
		endm

opc_ternary	=	1 shl 24
opc_binary	=	1 shl 25
opc_unary	=	1 shl 26
opc_assign	=	1 shl 27
opc_float	=	1 shl 28
opc_alias	=	1 shl 29
opc_hubcode	=	1 shl 30

;		oc		op		prec	bytecode	ternary	binary	unary	assign	float	alias	hubcode

opcode		oc_bitnot,	op_bitnot,	0,	bc_bitnot,	0,	0,	1,	1,	0,	0,	0	; !
opcode		oc_neg,		op_neg,		0,	bc_neg,		0,	0,	1,	1,	1,	0,	0	; -	(uses op_sub symbol)
opcode		oc_fneg,	op_fneg,	0,	bc_fneg,	0,	0,	1,	0,	1,	0,	1	; -.	(uses op_fsub symbol)
opcode		oc_abs,		op_abs,		0,	bc_abs,		0,	0,	1,	1,	1,	0,	0	; ABS
opcode		oc_fabs,	op_fabs,	0,	bc_fabs,	0,	0,	1,	0,	1,	0,	1	; FABS
opcode		oc_encod,	op_encod,	0,	bc_encod,	0,	0,	1,	1,	0,	0,	0	; ENCOD
opcode		oc_decod,	op_decod,	0,	bc_decod,	0,	0,	1,	1,	0,	0,	0	; DECOD
opcode		oc_bmask,	op_bmask,	0,	bc_bmask,	0,	0,	1,	1,	0,	0,	0	; BMASK
opcode		oc_ones,	op_ones,	0,	bc_ones,	0,	0,	1,	1,	0,	0,	0	; ONES
opcode		oc_sqrt,	op_sqrt,	0,	bc_sqrt,	0,	0,	1,	1,	0,	0,	0	; SQRT
opcode		oc_fsqrt,	op_fsqrt,	0,	bc_fsqrt,	0,	0,	1,	0,	1,	0,	1	; FSQRT
opcode		oc_qlog,	op_qlog,	0,	bc_qlog,	0,	0,	1,	1,	0,	0,	0	; QLOG
opcode		oc_qexp,	op_qexp,	0,	bc_qexp,	0,	0,	1,	1,	0,	0,	0	; QEXP
opcode		oc_log2,	op_log2,	0,	bc_log2,	0,	0,	1,	0,	1,	0,	1	; LOG2
opcode		oc_log10,	op_log10,	0,	bc_log10,	0,	0,	1,	0,	1,	0,	1	; LOG10
opcode		oc_log,		op_log,		0,	bc_log,		0,	0,	1,	0,	1,	0,	1	; LOG
opcode		oc_exp2,	op_exp2,	0,	bc_exp2,	0,	0,	1,	0,	1,	0,	1	; EXP2
opcode		oc_exp10,	op_exp10,	0,	bc_exp10,	0,	0,	1,	0,	1,	0,	1	; EXP10
opcode		oc_exp,		op_exp,		0,	bc_exp,		0,	0,	1,	0,	1,	0,	1	; EXP
opcode		oc_shr,		op_shr,		1,	bc_shr,		0,	1,	0,	1,	0,	0,	0	; >>
opcode		oc_shl,		op_shl,		1,	bc_shl,		0,	1,	0,	1,	0,	0,	0	; <<
opcode		oc_sar,		op_sar,		1,	bc_sar,		0,	1,	0,	1,	0,	0,	0	; SAR
opcode		oc_ror,		op_ror,		1,	bc_ror,		0,	1,	0,	1,	0,	0,	0	; ROR
opcode		oc_rol,		op_rol,		1,	bc_rol,		0,	1,	0,	1,	0,	0,	0	; ROL
opcode		oc_rev,		op_rev,		1,	bc_rev,		0,	1,	0,	1,	0,	0,	0	; REV
opcode		oc_zerox,	op_zerox,	1,	bc_zerox,	0,	1,	0,	1,	0,	0,	0	; ZEROX
opcode		oc_signx,	op_signx,	1,	bc_signx,	0,	1,	0,	1,	0,	0,	0	; SIGNX
opcode		oc_bitand,	op_bitand,	2,	bc_bitand,	0,	1,	0,	1,	0,	0,	0	; &
opcode		oc_bitxor,	op_bitxor,	3,	bc_bitxor,	0,	1,	0,	1,	0,	0,	0	; ^
opcode		oc_bitor,	op_bitor,	4,	bc_bitor,	0,	1,	0,	1,	0,	0,	0	; |
opcode		oc_mul,		op_mul,		5,	bc_mul,		0,	1,	0,	1,	1,	0,	0	; *
opcode		oc_fmul,	op_fmul,	5,	bc_fmul,	0,	1,	0,	0,	1,	0,	1	; *.
opcode		oc_div,		op_div,		5,	bc_div,		0,	1,	0,	1,	1,	0,	0	; /
opcode		oc_fdiv,	op_fdiv,	5,	bc_fdiv,	0,	1,	0,	0,	1,	0,	1	; /.
opcode		oc_divu,	op_divu,	5,	bc_divu,	0,	1,	0,	1,	0,	0,	0	; +/
opcode		oc_rem,		op_rem,		5,	bc_rem,		0,	1,	0,	1,	0,	0,	0	; //
opcode		oc_remu,	op_remu,	5,	bc_remu,	0,	1,	0,	1,	0,	0,	0	; +//
opcode		oc_sca,		op_sca,		5,	bc_sca,		0,	1,	0,	1,	0,	0,	0	; SCA
opcode		oc_scas,	op_scas,	5,	bc_scas,	0,	1,	0,	1,	0,	0,	0	; SCAS
opcode		oc_frac,	op_frac,	5,	bc_frac,	0,	1,	0,	1,	0,	0,	0	; FRAC
opcode		oc_add,		op_add,		6,	bc_add,		0,	1,	0,	1,	1,	0,	0	; +
opcode		oc_fadd,	op_fadd,	6,	bc_fadd,	0,	1,	0,	0,	1,	0,	1	; +.
opcode		oc_sub,		op_sub,		6,	bc_sub,		0,	1,	0,	1,	1,	0,	0	; -
opcode		oc_fsub,	op_fsub,	6,	bc_fsub,	0,	1,	0,	0,	1,	0,	1	; -.
opcode		oc_pow,		op_pow,		6,	bc_pow,		0,	1,	0,	0,	1,	0,	1	; POW
opcode		oc_fge,		op_fge,		7,	bc_fge,		0,	1,	0,	1,	1,	0,	0	; #>
opcode		oc_fle,		op_fle,		7,	bc_fle,		0,	1,	0,	1,	1,	0,	0	; <#
opcode		oc_addbits,	op_addbits,	8,	bc_addbits,	0,	1,	0,	1,	0,	0,	0	; ADDBITS
opcode		oc_addpins,	op_addpins,	8,	bc_addpins,	0,	1,	0,	1,	0,	0,	0	; ADDPINS
opcode		oc_lt,		op_lt,		9,	bc_lt,		0,	1,	0,	0,	1,	0,	0	; <
opcode		oc_flt,		op_flt,		9,	bc_flt,		0,	1,	0,	0,	1,	0,	1	; <.
opcode		oc_ltu,		op_ltu,		9,	bc_ltu,		0,	1,	0,	0,	0,	0,	0	; +<
opcode		oc_lte,		op_lte,		9,	bc_lte,		0,	1,	0,	0,	1,	0,	0	; <=
opcode		oc_flte,	op_flte,	9,	bc_flte,	0,	1,	0,	0,	1,	0,	1	; <=.
opcode		oc_lteu,	op_lteu,	9,	bc_lteu,	0,	1,	0,	0,	0,	0,	0	; +<=
opcode		oc_e,		op_e,		9,	bc_e,		0,	1,	0,	0,	1,	0,	0	; ==
opcode		oc_fe,		op_fe,		9,	bc_fe,		0,	1,	0,	0,	1,	0,	1	; ==.
opcode		oc_ne,		op_ne,		9,	bc_ne,		0,	1,	0,	0,	1,	0,	0	; <>
opcode		oc_fne,		op_fne,		9,	bc_fne,		0,	1,	0,	0,	1,	0,	1	; <>.
opcode		oc_gte,		op_gte,		9,	bc_gte,		0,	1,	0,	0,	1,	0,	0	; >=
opcode		oc_fgte,	op_fgte,	9,	bc_fgte,	0,	1,	0,	0,	1,	0,	1	; >=.
opcode		oc_gteu,	op_gteu,	9,	bc_gteu,	0,	1,	0,	0,	0,	0,	0	; +>=
opcode		oc_gt,		op_gt,		9,	bc_gt,		0,	1,	0,	0,	1,	0,	0	; >
opcode		oc_fgt,		op_fgt,		9,	bc_fgt,		0,	1,	0,	0,	1,	0,	1	; >.
opcode		oc_gtu,		op_gtu,		9,	bc_gtu,		0,	1,	0,	0,	0,	0,	0	; +>
opcode		oc_ltegt,	op_ltegt,	9,	bc_ltegt,	0,	1,	0,	0,	1,	0,	0	; <=>
opcode		oc_lognot,	op_lognot,	10,	bc_lognot,	0,	0,	1,	1,	0,	1,	0	; !!
opcode		oc_lognot_name,	op_lognot,	10,	bc_lognot,	0,	0,	1,	1,	0,	0,	0	; NOT
opcode		oc_logand,	op_logand,	11,	bc_logand,	0,	1,	0,	1,	0,	1,	0	; &&
opcode		oc_logand_name,	op_logand,	11,	bc_logand,	0,	1,	0,	1,	0,	0,	0	; AND
opcode		oc_logxor,	op_logxor,	12,	bc_logxor,	0,	1,	0,	1,	0,	1,	0	; ^^
opcode		oc_logxor_name,	op_logxor,	12,	bc_logxor,	0,	1,	0,	1,	0,	0,	0	; XOR
opcode		oc_logor,	op_logor,	13,	bc_logor,	0,	1,	0,	1,	0,	1,	0	; ||
opcode		oc_logor_name,	op_logor,	13,	bc_logor,	0,	1,	0,	1,	0,	0,	0	; OR
opcode		oc_ternary,	op_ternary,	14,	0,		1,	0,	0,	1,	0,	0,	0	; ?
;
;
; Blocks
;
count0		block_con
count		block_obj
count		block_var
count		block_pub
count		block_pri
count		block_dat
;
;
; Directives
;
count0		dir_orgh
count		dir_alignw
count		dir_alignl
count		dir_org
count		dir_orgf
count		dir_res
count		dir_fit
count		dir_ditto
;
;
; Ifs
;
count0		if_ret
count		if_nc_and_nz
count		if_nc_and_z
count		if_nc
count		if_c_and_nz
count		if_nz
count		if_c_ne_z
count		if_nc_or_nz
count		if_c_and_z
count		if_c_eq_z
count		if_z
count		if_nc_or_z
count		if_c
count		if_c_or_nz
count		if_c_or_z
count		if_always
;
;
; Info types
;
count0		info_con			;data0 = value (must be followed by info_con_float)
count		info_con_float			;data0 = value
count		info_dat			;data0/1 = obj start/finish
count		info_dat_symbol			;data0 = offset, data1 = size
count		info_pub			;data0/1 = obj start/finish, data2/3 = name start/finish
count		info_pri			;data0/1 = obj start/finish, data2/3 = name start/finish
;
;
; Object export/import types
;
objx_con_int		= 1 shl 5
objx_con_float		= 2 shl 5
objx_con_struct		= 3 shl 5
objx_pub		= 4 shl 5

objx_mask_type		= 0E0h
objx_mask_namelength	= 1Fh
;
;
; Macro to establish undefined byte(s)
;
; dbx		symbol(,count)
;
macro		dbx	symbol,count
		udataseg
		ifb	<count>
symbol		db	?
		else
symbol		db	count dup (?)
		endif
		codeseg
		endm
;
;
; Macro to establish undefined word(s)
;
; dwx		symbol(,count)
;
macro		dwx	symbol,count
		udataseg
		ifb	<count>
symbol		dw	?
		else
symbol		dw	count dup (?)
		endif
		codeseg
		endm
;
;
; Macro to establish undefined doubleword(s)
;
; ddx		symbol(,count)
;
macro		ddx	symbol,count
		udataseg
		ifb	<count>
symbol		dd	?
		else
symbol		dd	count dup (?)
		endif
		codeseg
		endm
;
;
;***********
;*  Start  *
;***********
;
		codeseg
;
;
;************************************************************************
;*  function P2InitStruct: pointer;					*
;************************************************************************
;
		proc	P2InitStruct

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		mov	[debug_display_ena],0	;reset debug display enables

		call	enter_symbols_auto	;enter auto symbols

		lea	eax,[error]		;return pointer to compiler data structure

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2InitStruct
;
;
; Compiler data structure
;
dbx		error						;error boolean
ddx		error_msg					;error message pointer

dbx		debug_mode					;debug mode
dbx		preprocessor_used				;preprocessor used
dbx		pasm_mode					;pasm mode

ddx		source						;source pointer
ddx		source_start					;source error start
ddx		source_finish					;source error finish

ddx		list						;list pointer (limit and length follow)
ddx		list_limit					;list limit
ddx		list_length					;list length

ddx		doc						;doc pointer (limit and length follow)
ddx		doc_limit					;doc limit
ddx		doc_length					;doc length

ddx		pre_symbols					;preprocessor symbols
dbx		pre_symbol_names,pre_symbols_limit*32		;preprocessor symbol names

ddx		params						;object parameters
dbx		param_names,obj_params_limit*32			;object parameter names
dbx		param_types,obj_params_limit			;object parameter types
ddx		param_values,obj_params_limit			;object parameter values

dbx		obj,obj_size_limit				;object buffer
ddx		obj_ptr						;object length

ddx		obj_files					;object file count
dbx		obj_filenames,files_limit*256			;object filenames
ddx		obj_name_start,files_limit			;object filenames source start
ddx		obj_name_finish,files_limit			;object filenames source finish
ddx		obj_params,files_limit				;object parameters
dbx		obj_param_names,files_limit*obj_params_limit*32	;object parameter names
dbx		obj_param_types,files_limit*obj_params_limit	;object parameter types
ddx		obj_param_values,files_limit*obj_params_limit	;object parameter values
ddx		obj_offsets,files_limit				;object offsets
ddx		obj_lengths,files_limit				;object lengths
dbx		obj_data,obj_data_limit				;object data
ddx		obj_instances,files_limit			;object instances
dbx		obj_title,256					;object title

ddx		dat_files					;data file count
dbx		dat_filenames,files_limit*256			;data filenames
ddx		dat_name_start,files_limit			;data filenames source start
ddx		dat_name_finish,files_limit			;data filenames source finish
ddx		dat_offsets,files_limit				;data offsets
ddx		dat_lengths,files_limit				;data lengths
dbx		dat_data,obj_size_limit				;data data

ddx		info_count					;info count	(used by PropellerTool)
ddx		info_start,info_limit				;info source start
ddx		info_finish,info_limit				;info source finish
ddx		info_type,info_limit				;info type
ddx		info_data0,info_limit				;info data0
ddx		info_data1,info_limit				;info data1
ddx		info_data2,info_limit				;info data2
ddx		info_data3,info_limit				;info data3

ddx		download_baud					;download baud

dbx		debug_pin_tx					;debug settings
dbx		debug_pin_rx
ddx		debug_baud
ddx		debug_left
ddx		debug_top
ddx		debug_width
ddx		debug_height
ddx		debug_display_left
ddx		debug_display_top
ddx		debug_log_size
ddx		debug_windows_off

dbx		debug_data,debug_data_limit			;debug buffer

ddx		debug_display_ena				;debug display
ddx		debug_display_new
dbx		debug_display_string,debug_string_limit
dbx		debug_display_type,debug_display_limit
ddx		debug_display_value,debug_display_limit
dbx		debug_display_targs

ddx		disassembler_inst				;disassembler
ddx		disassembler_addr
dbx		disassembler_string,256

ddx		distilled_bytes					;distilled bytes

ddx		clkmode						;clock mode
ddx		clkfreq						;clock frequency
ddx		xinfreq						;xin frequency

ddx		size_flash_loader				;size of flash loader
ddx		size_interpreter				;size of interpreter
ddx		size_obj					;size of object
ddx		size_var					;size of var

ddx		obj_stack_ptr					;recursion level
;
;
;************************************************************************
;*  procedure P2Compile0;						*
;************************************************************************
;
		proc	P2Compile0

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_compile0

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2Compile0
;
;
;************************************************************************
;*  procedure P2Compile1;						*
;************************************************************************
;
		proc	P2Compile1

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_compile1

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2Compile1
;
;
;************************************************************************
;*  procedure P2Compile2;						*
;************************************************************************
;
		proc	P2Compile2

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_compile2

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2Compile2
;
;
;************************************************************************
;*  procedure P2InsertInterpreter;					*
;************************************************************************
;
		proc	P2InsertInterpreter

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_insert_interpreter

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2InsertInterpreter
;
;
;************************************************************************
;*  procedure P2InsertDebugger;						*
;************************************************************************
;
		proc	P2InsertDebugger

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_insert_debugger

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2InsertDebugger
;
;
;************************************************************************
;*  procedure P2InsertClockSetter;					*
;************************************************************************
;
		proc	P2InsertClockSetter

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_insert_clock_setter

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2InsertClockSetter
;
;
;************************************************************************
;*  procedure P2InsertFlashLoader;					*
;************************************************************************
;
		proc	P2InsertFlashLoader

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_insert_flash_loader

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2InsertFlashLoader
;
;
;************************************************************************
;*  procedure P2MakeFlashFile;						*
;************************************************************************
;
		proc	P2MakeFlashFile

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_make_flash_file

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2MakeFlashFile
;
;
;************************************************************************
;*  procedure P2ResetDebugSymbols;					*
;************************************************************************
;
		proc	P2ResetDebugSymbols

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_reset_debug_symbols

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2ResetDebugSymbols
;
;
;************************************************************************
;*  procedure P2ParseDebugString;					*
;************************************************************************
;
		proc	P2ParseDebugString

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_parse_debug_string

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2ParseDebugString
;
;
;************************************************************************
;*  procedure P2Disassemble;						*
;************************************************************************
;
		proc	P2Disassemble

		cld
		push	ebx
		push	esi
		push	edi
		push	ebp

		call	_disassemble

		pop	ebp
		pop	edi
		pop	esi
		pop	ebx
		ret

		endp	P2Disassemble
;
;
;************************************************************************
;*  Error Handling							*
;************************************************************************
;
;
; Compiler errors
;
error_aanawiac:	call	set_error
		db	'ALIGNW/ALIGNL not allowed within inline assembly code',0

error_acobd:	call	set_error
		db	'_AUTOCLK can only be defined as an integer constant',0

error_ainafbf:	call	set_error
		db	'@ is not allowed for bitfields, use ^@ to get field pointer',0

error_amnex:	call	set_error
		db	'Address must not exceed $FFFFF',0

error_arina:	call	set_error
		db	'@register is not allowed, use ^@ to get field pointer',0

error_bmbpbb:	call	set_error
		db	'"}" must be preceeded by "{" to form a comment',0

error_bdmbifc:	call	set_error
		db	'Block designator must be in first column',0

error_bmbft:	call	set_error
		db	'BYTEFIT values must range from -$80 to $FF',0

error_bnso:	call	set_error
		db	'Blocknest stack overflow',0

error_bwldcx:	call	set_error
		db	'BYTE/WORD/LONG data cannot exceed 255 bytes',0

error_caefl:	call	set_error
		db	'Cog address exceeds FIT limit',0

error_cael:	call	set_error
		db	'Cog address exceeds limit',0

error_caexl:	call	set_error
		db	'Cog address exceeds $400 limit',0

error_cfcobd:	call	set_error
		db	'_CLKFREQ, _XTLFREQ, _XINFREQ, _ERRFREQ, _RCFAST, _RCSLOW can only be defined as integer constants',0

error_cccbd:	call	set_error
		db	'CLKMODE_ and CLKFREQ_ cannot be declared, since they are set by the compiler',0

error_ce32b:	call	set_error
		db	'Constant exceeds 32 bits',0

error_cfbex:	call	set_error
		db	'CASE_FAST block exceeds 64KB',0

error_cfiinu:	call	set_error
		db	'CASE_FAST index is not unique',0

error_cfvmbw:	call	set_error
		db	'CASE_FAST values must be within 255 of each other',0

error_cmbf0t255:call	set_error
		db	'Constant must be from 0 to 255',0

error_cmbf0t511:call	set_error
		db	'Constant must be from 0 to 511',0

error_cmbf1t15:	call	set_error
		db	'Constant must be from 1 to 15',0

error_codcssf:	call	set_error
		db	'Conflicting or deficient _CLKFREQ/_XTLFREQ/_XINFREQ/_RCFAST/_RCSLOW symbols found',0

error_csmbla:	call	set_error
		db	'Cog symbol must be long-aligned',0

error_dbz:	call	set_error
		db	'Divide by zero',0

error_dcmbapi:	call	set_error
		db	'DITTO count must be a positive integer or zero',0

error_ddcobd:	call	set_error
		db	'DEBUG_DISABLE can only be defined as an integer constant',0

error_dditl:	call	set_error
		db	'DEBUG data is too long',0

error_debugcog:	call	set_error
		db	'DEBUG_COGS can only be defined as an integer constant',0

error_debugdly:	call	set_error
		db	'DEBUG_DELAY can only be defined as an integer constant',0

error_debugpin:	call	set_error
		db	'DEBUG_PIN can only be defined as an integer constant',0

error_debugptx:	call	set_error
		db	'DEBUG_PIN_TX can only be defined as an integer constant',0

error_debugprx:	call	set_error
		db	'DEBUG_PIN_RX can only be defined as an integer constant',0

error_debugbaud:call	set_error
		db	'DEBUG_BAUD can only be defined as an integer constant',0

error_debugclk:	call	set_error
		db	'DEBUG requires at least 10 MHz of crystal/external clocking',0

error_dioa:	call	set_error
		db	'"$" (DAT origin) is only allowed in DAT blocks',0

error_diioa:	call	set_error
		db	'"$$" (DITTO index) is only allowed within a DITTO block, inside a DAT block',0

error_divo:	call	set_error
		db	'Division overflow',0

error_dmbmb:	call	set_error
		db	'DEBUG mask bit-number must be 0..31',0

error_dmcobd:	call	set_error
		db	'DEBUG_MASK can only be defined as an integer constant',0

error_dmmbd:	call	set_error
		db	'DEBUG_MASK symbol must be defined for DEBUG[0..31] usage',0

error_downbaud:	call	set_error
		db	'DOWNLOAD_BAUD can only be defined as an integer constant',0

error_drmbpppp:	call	set_error
		db	'D register must be PA/PB/PTRA/PTRB',0

error_dscobd:	call	set_error
		db	'DAT structures can only be declared in ORGH mode',0

error_dsdle:	call	set_error
		db	'Data structure-definitions limit exceeded',0

error_dsmbpbas:	call	set_error
		db	'DAT structure must be preceded by a symbol',0

error_eaaeoeol:	call	set_error
		db	'Expected an assembly effect or end of line',0

error_eaasmi:	call	set_error
		db	'Expected an assembly instruction',0

error_eacn:	call	set_error
		db	'Expected a constant name',0

error_eacuool:	call	set_error
		db	'Expected a constant, unary operator, or "("',0

error_eads:	call	set_error
		db	'Expected a DAT symbol',0

error_eaenop:	call	set_error
		db	'Expected an even number of parameters',0

error_eaesn:	call	set_error
		db	'Expected an existing STRUCT name',0

error_eaet:	call	set_error
		db	'Expected an expression term',0

error_eaiov:	call	set_error
		db	'Expected an instruction or variable',0

error_eals:	call	set_error
		db	'Expected a local symbol',0

error_eamn:	call	set_error
		db	'Expected a method name',0

error_eamomp:	call	set_error
		db	'Expected a method, object, or method pointer',0

error_eamoov:	call	set_error
		db	'Expected a method, object, or variable',0

error_eaocsom:	call	set_error
		db	'Expected an object constant, structure, or method',0

error_eas:	call	set_error
		db	'Expected a symbol',0

error_easmn:	call	set_error
		db	'Expected a structure member name',0

error_easn:	call	set_error
		db	'Expected a structure name',0

error_eassign:	call	set_error
		db	'Expected ":="',0

error_eastott:	call	set_error
		db	'Expected ":=", ":=:", "~", or "~~"',0

error_easvmoo:	call	set_error
		db	'Expected a string, variable, method, or object',0

error_eatq:	call	set_error
		db	'Expected a terminating quote',0

error_eaucnpos:	call	set_error
		db	'Expected a unique constant name, "#", or STRUCT',0

error_eaumn:	call	set_error
		db	'Expected a unique method name',0

error_eauon:	call	set_error
		db	'Expected a unique object name',0

error_eaunbwlo:	call	set_error
		db	'Expected a unique name, BYTE, WORD, LONG, or assembly instruction',0

error_eaupn:	call	set_error
		db	'Expected a unique parameter name',0

error_eaurn:	call	set_error
		db	'Expected a unique result name',0

error_eausn:	call	set_error
		db	'Expected a unique STRUCT name',0

error_eauvn:	call	set_error
		db	'Expected a unique variable name',0

error_eauvnsa:	call	set_error
		db	'Expected a unique variable name, STRUCT name, BYTE, WORD, LONG, "^", ALIGNW, or ALIGNL',0

error_eav:	call	set_error
		db	'Expected a variable',0

error_ebackcmd:	call	set_error
		db	'Expected "?", ".", "(", "$", "%", "#", or DEBUG command',0

error_ebwl:	call	set_error
		db	'Expected BYTE, WORD, or LONG',0

error_ebwls:	call	set_error
		db	'Expected BYTE, WORD, LONG, or STRUCT name',0

error_ecoeol:	call	set_error
		db	'Expected "," or end of line',0

error_ecolon:	call	set_error
		db	'Expected ":"',0

error_ecomma:	call	set_error
		db	'Expected ","',0

error_ecor:	call	set_error
		db	'Expected "," or ")"',0

error_edend:	call	set_error
		db	'Expected DITTO END',0

error_edot:	call	set_error
		db	'Expected "."',0

error_edotdot:	call	set_error
		db	'Expected ".."',0

error_eelcoeol:call	set_error
		db	'Expected "=" "[" "," "(" or end of line',0

error_eend:	call	set_error
		db	'Expected END',0

error_eeol:	call	set_error
		db	'Expected end of line',0

error_eeone:	call	set_error
		db	'Expected "==" or "<>"',0

error_eeqol:	call	set_error
		db	'Expected "=" or "("',0

error_eequal:	call	set_error
		db	'Expected "="',0

error_efrom:	call	set_error
		db	'Expected FROM',0

error_eicon:	call	set_error
		db	'Expected integer constant',0

error_eiconos:	call	set_error
		db	'Expected integer constant or structure (for size)',0

error_eidbwloe:	call	set_error
		db	'Expected instruction, directive, BYTE/WORD/LONG, or END',0

error_eitc:	call	set_error
		db	'Expression is too complex',0

error_eleft:	call	set_error
		db	'Expected "("',0

error_eleftb:	call	set_error
		db	'Expected "["',0

error_eloe:	call	set_error
		db	'Expected "(" or "="',0

error_enope:	call	set_error
		db	'Expected number of parameters exceeded',0

error_enopr:	call	set_error
		db	'Even number of parameters required for this DEBUG output command',0

error_epoa:	call	set_error
		db	'Expected PRECOMPILE or ARCHIVE',0

error_epoeol:	call	set_error
		db	'Expected "|" or end of line',0

error_epound:	call	set_error
		db	'Expected "#"',0

error_eptr:	call	set_error
		db	'Expected pointer variable',0

error_eptrid:	call	set_error
		db	'Expected pointer variable, "++", or "--"',0

error_erb:	call	set_error
		db	'Expected "}"',0

error_erbb:	call	set_error
		db	'Expected "}}"',0

error_eregsym:	call	set_error
		db	'Expected a register symbol',0

error_eright:	call	set_error
		db	'Expected ")"',0

error_erightb:	call	set_error
		db	'Expected "]"',0

error_es:	call	set_error
		db	'Empty string',0

error_esc:	call	set_error
		db	"Expected a string character",0

error_esendd:	call	set_error
		db	'Expected SEND data',0

error_esoeol:	call	set_error
		db	'Expected STEP or end of line',0

error_etmrasr:	call	set_error
		db	'Expression terms must return a single result',0

error_eto:	call	set_error
		db	'Expected TO',0

error_ewaox:	call	set_error
		db	'Expected WC, WZ, ANDC, ANDZ, ORC, ORZ, XORC, or XORZ',0

error_ewcwzwcz:	call	set_error
		db	'Expected WC, WZ, or WCZ',0

error_ewith:	call	set_error
		db	'Expected WITH',0

error_fpcmbp:	call	set_error
		db	'Floating-point constant must be positive',0

error_fpcmbw:	call	set_error
		db	'Floating-point constant must be within +/- 3.4e+38',0

error_fpnaiie:	call	set_error
		db	'Floating-point not allowed in integer expression',0

error_fpo:	call	set_error
		db	'Floating-point overflow',0

error_ftl:	call	set_error
		db	'Filename too long',0

error_fvar:	call	set_error
		db	'FVAR/FVARS data is too big',0

error_haefl:	call	set_error
		db	'Hub address exceeds FIT limit',0

error_habxl:	call	set_error
		db	'Hub address below $400 limit',0

error_hacd:	call	set_error
		db	'Hub address cannot decrease',0

error_haec:	call	set_error
		db	'Hub address exceeds $100000 ceiling',0

error_hael:	call	set_error
		db	'Hub address exceeds limit',0

error_hsvi:	call	set_error
		db	'Highest selectable Spin2 version is v', spin2_version / 10 + '0', spin2_version mod 10 + '0',0

error_icaexl:	call	set_error
		db	'Inline cog address exceeds $11F limit',0	;TESTT make sure address is up-to-date

error_iccbl:	call	set_error
		db	'Instance count cannot be less than 1',0

error_icce:	call	set_error
		db	'Instance count cannot exceed $10000',0

error_idbn:	call	set_error
		db	'Invalid double-binary number',0

error_iec:	call	set_error
		db	'Invalid escape character',0

error_idfnf:	call	set_error
		db	'Internal DAT file not found',0

error_ifc:	call	set_error
		db	'Invalid filename character',0

error_ifufiq:	call	set_error
		db	'Invalid filename, use "FilenameInQuotes"',0

error_inaifpe:	call	set_error
		db	'Integer not allowed in floating-point expression',0

error_internal:	call	set_error
		db	'Internal',0

error_ionaifpe:	call	set_error
		db	'Integer operator not allowed in floating-point expression',0

error_iscexb:	call	set_error
		db	"Indexed structures cannot exceed $FFFF bytes in size",0

error_isie:	call	set_error
		db	'ORG/ORGH inline block is empty',0

error_isil:	call	set_error
		db	'ORGH inline block exceeds $FFFF longs (including the added RET instruction)',0

error_level44:	call	set_error
		db	'{Spin2_v44} is no longer supported due to changes in data structures beginning in v45',0

error_litl:	call	set_error
		db	'List is too large',0

error_loxcase:	call	set_error
		db	'Limit of 256 CASE elements exceeded',0

error_loxcasef:	call	set_error
		db	'Limit of 256 CASE_FAST elements exceeded',0

error_loxoie:	call	set_error
		db	'Limit of 1024 OBJ instances exceeded',0

error_loxppme:	call	set_error
		db	'Limit of 1024 PUB/PRI methods exceeded',0

error_loxdsde:	call	set_error
		db	'Limit of 4096 data structure definitions exceeded',0

error_loxdse:	call	set_error
		db	'Limit of 10k DAT symbols exceeded',0

error_loxee:	call	set_error
		db	'Limit of 256 ELSEIF/ELSEIFNOTs exceeded',0

error_loxlve:	call	set_error
		db	'Limit of 64KB of local variables exceeded',0

error_loxnbe:	call	set_error
		db	'Limit of 16 nested blocks exceeded',0

error_loxpe:	call	set_error
		db	'Limit of 127 parameters exceeded',0

error_loxre:	call	set_error
		db	'Limit of 15 results exceeded',0

error_loxrs:	call	set_error
		db	'Limit of 3 runtime structure index expressions exceeded',0

error_loxuoe:	call	set_error
		db	'Limit of 32 unique objects exceeded',0

error_loxudfe:	call	set_error
		db	'Limit of 32 unique DAT files exceeded',0

error_loxupfe:	call	set_error
		db	'Limit of 32 unique PRECOMPILE files exceeded',0

error_lscmrf:	call	set_error
		db	'LSTRING characters must range from 0 to 255',0

error_lsvi:	call	set_error
		db	'Lowest selectable Spin2 version is v41',0

error_lvmb:	call	set_error
		db	'For access via inline assembly, a local variable must be either a long, a structure, or a pointer, and be both within the first 16 longs and long-aligned',0

error_mpmblv:	call	set_error
		db	'Method pointers must be long variables without bitfields',0

error_nce:	call	set_error
		db	'No cases encountered',0

error_nchcor:	call	set_error
		db	'NOP cannot have a condition or _RET_',0

error_nmt4c:	call	set_error
		db	'No more than 4 characters can be packed into a long',0

error_npmf:	call	set_error
		db	'No PUB method or DAT block found',0

error_oaet:	call	set_error
		db	'Origin already exceeds target',0

error_ocmbf1tx:	call	set_error
		db	'Object count must be from 1 to 255',0

error_odo:	call	set_error
		db	'Object distiller overflow',0

error_ohnawads:	call	set_error
		db	'ORGH not allowed within a DITTO block',0

error_ohnawiac:	call	set_error
		db	'ORGH not allowed within inline assembly code',0

error_oinaiom:	call	set_error
		db	'ORGF is not allowed in ORGH mode',0

error_omblc:	call	set_error
		db	'OTHER must be last case',0

error_os:	call	set_error
		db	'Open string',0

error_oaocbats:	call	set_error
		db	'Only @ operator can be applied to a structure',0

error_oiina:	call	set_error
		db	'Object index is not allowed before constants and structures',0

error_onawads:	call	set_error
		db	'ORG not allowed within a DITTO block',0

error_onawiac:	call	set_error
		db	'ORG not allowed within inline assembly code',0

error_pcba:	call	set_error
		db	'Pointers cannot be arrays',0

error_pclo:	call	set_error
		db	'PUB/CON list overflow',0

error_pex:	call	set_error
		db	'Program exceeds 1024KB',0

error_picmr6b:	call	set_error
		db	'PTRA/PTRB index constant must range from -32 to 31',0

error_picmr116:	call	set_error
		db	'PTRA/PTRB index constant must range from 1 to 16',0

error_pllscnba:	call	set_error
		db	'PLL settings could not be achieved per _CLKFREQ',0

error_pmbttsp:	call	set_error
		db	'Pins must belong to the same port',0

error_rainawi:	call	set_error
		db	'Relative address is not aligned with instruction',0

error_raioor:	call	set_error
		db	'Relative address is out of range',0

error_racc:	call	set_error
		db	'Relative addresses cannot cross between cog and hub domains',0

error_rbeiooa:	call	set_error
		db	'REP block end is out of alignment',0

error_rbeioor:	call	set_error
		db	'REP block end is out of range',0

error_rcex:	call	set_error
		db	'Register cannot exceed $1FF',0

error_recvcbu:	call	set_error
		db	'RECV() can be used only as a term and \RECV() is not allowed',0

error_rinah:	call	set_error
		db	'Register is not allowed here',0

error_rinaiom:	call	set_error
		db	'RES is not allowed in ORGH mode',0

error_rpcx:	call	set_error
		db	'Register parameter cannot exceed $3FF',0

error_scmrf:	call	set_error
		db	'STRING characters must range from 1 to 255',0

error_sdcobu:	call	set_error
		db	'Symbol _DEBUG can only be used as an integer constant',0

error_sdcx:	call	set_error
		db	'@"string"/STRING/LSTRING data cannot exceed 254 bytes',0

error_sdnctn:	call	set_error
		db	'Structure does not contain this name',0

error_sehr:	call	set_error
		db	'Structure exceeds hub range of $FFFFF',0

error_sendcbu:	call	set_error
		db	'SEND() can be used only as an instruction and \SEND() is not allowed',0

error_sexc:	call	set_error
		db	'Symbol exceeds 30 characters',0

error_siad:	call	set_error
		db	'Symbol is already defined',0

error_simbf:	call	set_error
		db	'Structure index must be from 0 to $FFFF',0

error_smb0t1:	call	set_error
		db	'Selector must be 0 to 1',0

error_smb0t3:	call	set_error
		db	'Selector must be 0 to 3',0

error_smb0t7:	call	set_error
		db	'Selector must be 0 to 7',0

error_smbss:	call	set_error
		db	'Structures must be same size',0

error_soioa:	call	set_error
		db	'SIZEOF() is only allowed in DAT, VAR, PUB, and PRI blocks',0

error_spmcrmv:	call	set_error
		db	'SEND parameter methods cannot return multiple values',0

error_stif:	call	set_error
		db	'Symbol table is full',0

error_stosmne:	call	set_error
		db	'Structures transferred on the stack must not exceed 15 longs',0

error_tdcbpbas:	call	set_error
		db	'This directive cannot be preceded by a symbol',0

error_teinafti:	call	set_error
		db	'This effect is not allowed for this instruction',0

error_ticobu:	call	set_error
		db	'This instruction can only be used as an expression term, since it returns results',0

error_tioawarb:	call	set_error
		db	'This instruction is only allowed within a REPEAT block',0

error_tmop:	call	set_error
		db	'Too many object parameters',0

error_tmpd:	call	set_error
		db	'Too much parameter data',0

error_tmrmr:	call	set_error
		db	'This method returns multiple result longs',0

error_tmrnr:	call	set_error
		db	'This method returns no results',0

error_tmvsid:	call	set_error
		db	'Too much variable space is declared',0

error_tocbufa:	call	set_error
		db	'This operator cannot be used for assignment',0

error_uc:	call	set_error
		db	'Unrecognized character',0

error_us:	call	set_error
		db	'Undefined symbol',0

error_vnao:	call	set_error
		db	'Variable needs an operator',0

error_wmbft:	call	set_error
		db	'WORDFIT values must range from -$8000 to $FFFF',0

error_int_ocs:	call	set_error
		db	'INTERNAL: object constant/structure should have already been resolved and handled',0
;
;
; Set error pointer and abort assembly
;
set_error:	pop	[error_msg]		;save error message pointer

abort:		mov	esp,[esp_save]		;restore stack pointer

		ret				;return to compiler caller


ddx		esp_save			;stack pointer for abort
;
;
; Make an error message to show symbol - just for development
;
error_inspect_symbol:

		push	ebx
		push	eax

		mov	[print_length],0

		call	print_string
		db	'Symbol: ',0

		lea	esi,[symbol]
@@error2a:	lodsb
		push	eax
		call	print_byte
		pop	eax
		cmp	al,0
		je	@@error2b
		mov	al,','
		call	print_chr
		jmp	@@error2a
@@error2b:
		call	print_string
		db	'   Type: ',0

		pop	eax
		call	print_byte

		call	print_string
		db	'   Value: ',0

		pop	eax
		call	print_long

		mov	al,0
		call	print_chr

		push	[list]
		pop	[error_msg]

		jmp	abort
;
;
; Make an error message to show ebx - just for development
;
error_inspect_value:

		push	ebx

		mov	[print_length],0

		call	print_string
		db	'Value: ',0

		pop	eax
		call	print_long

		mov	al,0
		call	print_chr

		push	[list]
		pop	[error_msg]

		jmp	abort
;
;
;************************************************************************
;*  Compiler								*
;************************************************************************
;
;
; Usage:
;
;	Call Compile1
;	Load any obj files
;	Call Compile2
;	Save new obj file
;
;
; OBJ structure:
;
;	(file only)	long	varsize,pgmsize
;
;	0/pbase:	long	$7FFF_FFFF & OBJn offset, OBJn var offset (0 = type only)
;			....
;			long	$8000_0000 | parameters << 24 | results << 20 | PUBn offset
;			....
;			long	$8000_0000 | parameters << 24 | results << 20 | PRIn offset
;			....
;			long	$7FFF_FFFF & objsize (past last PRIn)
;
;			byte	DAT data...
;			byte	PUB data...
;			byte	PRI data...
;	objsize:
;			/alignl
;			\long	OBJn data...
;			....
;	pgmsize:
;			byte	checksum
;			byte	'PUBn', 0..15 results, parameters	;PUB names and parameters
;			byte	'CONn', 16/17 int/float, long value	;CON names and values
; Compile0
;
_compile0:	mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	enter_symbols_pre	;enter preprocessor symbols
		call	preprocessor		;run preprocessor, only preprocessor symbols will be searched
		call	reset_symbols_pre	;reset preprocessor symbols

		jmp	compile_done		;exit
;
;
; Compile1
;
_compile1:	mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	enter_symbols_level	;enter level symbols after determining spin2 level
		call	enter_symbols_param	;enter parameter symbols
		call	reset_symbols_main	;reset main symbols
		call	reset_symbols_local	;reset local symbols
		call	reset_symbols_inline	;reset inline symbols
		call	write_symbols_main	;write main symbols
		mov	[con_block_flag],0	;reset con block flag
		mov	[obj_block_flag],0	;reset obj block flag
		mov	[asm_local],30303030h	;reset asm local to '0000'
		mov	[pubcon_list_size],0	;reset pub/con list
		mov	[list_length],0		;reset list length
		mov	[doc_length],0		;reset doc length
		mov	[doc_mode],0		;reset doc mode
		mov	[info_count],0		;reset info count
		mov	[obj_ptr],0		;reset object pointer

		lea	esi,[list]		;set print to list
		call	set_print

		call	determine_mode		;determine compiler mode (Spin/PASM)

		call	compile_con_blocks_1st	;compile con blocks, 1st pass
		call	compile_obj_blocks_id	;compile obj blocks, compile obj index, set obj symbols, get obj filenames
		call	compile_dat_blocks_fn	;compile dat blocks, get dat filenames

		jmp	compile_done		;exit to load obj and dat files
;
;
; Compile2
;
_compile2:	mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	compile_obj_symbols	;compile obj symbols, set obj-con integer/float/structure symbols
		call	determine_clock		;determine clock settings, set clkmode_/clkfreq_ symbols
		call	compile_con_blocks_2nd	;compile con blocks, 2nd pass, compile structures
		call	determine_bauds_pins	;determine bauds and debug pins
		call	determine_debug_enables	;determine debug enables
		call	compile_var_blocks	;compile var blocks, compile var index, set var symbols
		call	compile_sub_blocks_id	;compile sub blocks, compile pub/pri index, set pub/pri symbols
		call	compile_dat_blocks	;compile dat blocks, compile dat code, set dat symbols
		call	compile_sub_blocks	;compile sub blocks, compile pub/pri code
		call	compile_obj_blocks	;compile obj blocks
		call	distill_obj_blocks	;distill obj blocks

		call	point_to_con		;in case error occurs, point to first con block so 'con' will be highlighted

		call	collapse_debug_data	;collapse debug data if at top recursion level

		call	print_obj		;print obj data

		push	[print_length]		;set list length
		pop	[list_length]

		lea	esi,[doc]		;set print to doc
		call	set_print

		call	print_doc		;print doc data

		push	[print_length]		;set doc length
		pop	[doc_length]

		call	compile_final		;compile final touches for obj file

		jmp	compile_done		;exit
;
;
; InsertInterpreter
;
_insert_interpreter:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	insert_interpreter	;insert interpreter

		jmp	compile_done		;exit
;
;
; InsertDebugger
;
_insert_debugger:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	insert_debugger		;insert debugger

		jmp	compile_done		;exit
;
;
; InsertClockSetter
;
_insert_clock_setter:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	insert_clock_setter	;insert clock setter

		jmp	compile_done		;exit
;
;
; InsertFlashLoader
;
_insert_flash_loader:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	insert_flash_loader	;insert flash loader

		jmp	compile_done		;exit
;
;
; MakeFlashFile
;
_make_flash_file:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	make_flash_file		;make flash file

		jmp	compile_done		;exit
;
;
; ResetDebugSymbols
;
_reset_debug_symbols:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	reset_debug_symbols	;reset debug symbols

		jmp	compile_done		;exit
;
;
; ParseDebugString
;
_parse_debug_string:

		mov	[error],1		;init error to true
		mov	[esp_save],esp		;save esp in case of error

		call	parse_debug_string	;parse debug string

		jmp	compile_done		;exit
;
;
; Done
;
compile_done:	mov	[source_start],0	;reset source pointers
		mov	[source_finish],0

		dec	[error]			;successful, clear error

		ret
;
;
; Data
;
dbx		con_block_flag
dbx		obj_block_flag

ddx		struct_id_next
ddx		struct_id_to_def,struct_id_limit
ddx		struct_def_ptr
dbx		struct_def,struct_def_limit

ddx		var_ptr

ddx		obj_count

ddx		sub_results

ddx		asm_local
dbx		inline_flag

dbx		pubcon_list,pubcon_list_limit
ddx		pubcon_list_size

dbx		doc_flag
dbx		doc_mode
;
;
;************************************************************************
;*  Print Routines							*
;************************************************************************
;
;
; Print obj data
;
print_obj:	call	print_string		;print spin2 level
		db	13,'Spin2_v',0
		movzx	eax,[spin2_level]
		mov	dl,10
		div	dl
		add	al,'0'
		call	print_chr
		mov	al,ah
		add	al,'0'
		call	print_chr
		call	print_cr

		call	print_string		;print clk settings
		db	13,'CLKMODE:   $',0
		mov	eax,[clkmode]
		call	print_long
		call	print_string
		db	13,'CLKFREQ: ',0
		mov	eax,[clkfreq]
		call	print_decimal
		call	print_string
		db	13,'XINFREQ: ',0
		mov	eax,[xinfreq]
		call	print_decimal
		call	print_cr
		call	print_cr

		cmp	[pasm_mode],1		;spin or pasm?
		je	@@pasm

		mov	eax,[distilled_bytes]	;print distilled bytes
		or	eax,eax
		jz	@@nodistill
		call	print_string
		db	13,'Redundant OBJ bytes removed: ',0
		call	print_decimal
		call	print_cr
@@nodistill:
		call	print_string		;print obj size
		db	13,'OBJ bytes: ',0
		mov	eax,[obj_ptr]
		call	print_decimal
		call	print_string		;print var size
		db	13,'VAR bytes: ',0
		mov	eax,[var_ptr]
		call	print_decimal
		jmp	@@notpasm

@@pasm:		call	print_string		;print hub bytes
		db	13,'Hub bytes: ',0
		mov	eax,[obj_ptr]
		call	print_decimal
@@notpasm:

		call	print_cr
		call	print_cr

		xor	ebx,ebx			;print obj lines
		mov	edx,[obj_ptr]
@@objnext:	cmp	ebx,edx
		je	@@objdone
		mov	eax,edx
		sub	eax,ebx
		mov	ecx,16
		cmp	eax,ecx
		jae	@@objsize
		mov	ecx,eax
@@objsize:	lea	esi,[obj]
		call	@@listline
		jmp	@@objnext
@@objdone:

		cmp	[debug_mode],0		;debug data?
		je	@@debugdone

		call	print_string		;print debug header
		db	13,13,'DEBUG data',13,13,0

		xor	ebx,ebx			;print debug data lines
		movzx	edx,[word debug_data]
@@debugnext:	cmp	ebx,edx
		je	@@debugdone
		mov	eax,edx
		sub	eax,ebx
		mov	ecx,16
		cmp	eax,ecx
		jae	@@debugsize
		mov	ecx,eax
@@debugsize:	lea	esi,[debug_data]
		call	@@listline
		jmp	@@debugnext
@@debugdone:
		ret


@@listline:	mov	eax,ebx			;print obj line with ascii
		call	print_word5
		mov	al,'-'
		call	print_chr

		push	ebx
		push	ecx

@@hex:		mov	al,' '
		call	print_chr
		mov	al,[esi+ebx]
		call	print_byte
		inc	ebx
		loop	@@hex

		pop	ecx
		push	ecx

		neg	ecx
		add	ecx,16
		inc	ecx
@@spaces:	call	print_string
		db	'   ',0
		loop	@@spaces

		pop	ecx
		pop	ebx

		mov	al,27h
		call	print_chr

@@ascii:	mov	al,[esi+ebx]
		cmp	al,' '
		jb	@@notascii
		cmp	al,7Fh
		jb	@@isascii
@@notascii:	mov	al,'.'
@@isascii:	call	print_chr
		inc	ebx
		loop	@@ascii

		mov	al,27h
		call	print_chr

		jmp	print_cr
;
;
; Print symbol2
;
print_symbol2:	push	eax
		push	ebx
		push	esi

		call	print_string
		db	'TYPE: ',0

		cmp	al,type_con_int
		jb	@@notlist
		cmp	al,type_method
		ja	@@notlist
		sub	al,type_con_int
		mov	ah,@@list2-@@list
		mul	ah
		movzx	eax,ax
		lea	esi,[@@list+eax]
		call	print_string_esi
		jmp	@@typedone
@@notlist:
		call	print_byte
		call	print_string
		db	'           ',0
@@typedone:
		call	print_string
		db	'   VALUE: ',0
		mov	eax,ebx
		call	print_long

		call	print_string
		db	'          NAME: ',0
		lea	esi,[symbol2]
@@symchr:	lodsb
		cmp	al,0
		je	@@symdone
		cmp	al,' '
		jbe	@@symspcl
		call	print_chr
		jmp	@@symchr
@@symspcl:	mov	ah,al
		mov	al,','
		call	print_chr
		mov	al,ah
		call	print_byte
		jmp	@@symchr
@@symdone:
		call	print_cr

		pop	esi
		pop	ebx
		pop	eax
		ret


@@list:		db	'CON_INT        ',0
@@list2:	db	'CON_FLOAT      ',0
		db	'CON_STRUCT     ',0
		db	'REGISTER       ',0
		db	'LOC_BYTE       ',0
		db	'LOC_WORD       ',0
		db	'LOC_LONG       ',0
		db	'LOC_STRUCT     ',0
		db	'LOC_BYTE_PTR   ',0
		db	'LOC_WORD_PTR   ',0
		db	'LOC_LONG_PTR   ',0
		db	'LOC_STRUCT_PTR ',0
		db	'               ',0	;type_loc_byte_ptr_val
		db	'               ',0	;type_loc_word_ptr_val
		db	'               ',0	;type_loc_long_ptr_val
		db	'               ',0	;type_loc_struct_ptr_val
		db	'VAR_BYTE       ',0
		db	'VAR_WORD       ',0
		db	'VAR_LONG       ',0
		db	'VAR_STRUCT     ',0
		db	'VAR_BYTE_PTR   ',0
		db	'VAR_WORD_PTR   ',0
		db	'VAR_LONG_PTR   ',0
		db	'VAR_STRUCT_PTR ',0
		db	'               ',0	;type_var_byte_ptr_val
		db	'               ',0	;type_var_word_ptr_val
		db	'               ',0	;type_var_long_ptr_val
		db	'               ',0	;type_var_struct_ptr_val
		db	'DAT_BYTE       ',0
		db	'DAT_WORD       ',0
		db	'DAT_LONG       ',0
		db	'DAT_STRUCT     ',0
		db	'DAT_LONG_RES   ',0
		db	'HUB_BYTE       ',0
		db	'HUB_WORD       ',0
		db	'HUB_LONG       ',0
		db	'OBJ            ',0
		db	'OBJ_CON_INT    ',0
		db	'OBJ_CON_FLOAT  ',0
		db	'OBJ_CON_STRUCT ',0
		db	'OBJ_PUB        ',0
		db	'METHOD         ',0
;
;
; Print hex
;
print_long:	push	ecx			;print hex long in eax
		mov	ecx,8
		jmp	print_hex

print_word5:	push	ecx			;print hex word in eax
		rol	eax,32-20
		mov	ecx,5
		jmp	print_hex

print_byte:	push	ecx			;print hex byte in eax
		rol	eax,32-8
		mov	ecx,2

print_hex:	rol	eax,4			;print hex value
		push	eax
		and	al,0Fh			;convert nibble in al to hex
		add	al,'0'
		cmp	al,'9'
		jbe	@@got
		add	al,7
@@got:		call	print_chr
		pop	eax
		loop	print_hex

		pop	ecx
		ret
;
;
; Print decimal
;
print_decimal:	push	ebx
		push	ecx
		push	edx

		xor	ebx,ebx			;reset leading-space flag
		mov	ecx,9			;ready for 9 digits
@@digit:	xor	edx,edx			;get digit
		div	[dword @@tens-4+ecx*4]
		or	eax,eax			;if leading zero, print space
		jnz	@@print
		or	ebx,ebx
		jnz	@@print
		cmp	cl,1
		je	@@print
		mov	al,' '
		jmp	@@space
@@print:	inc	ebx			;else, set flag and print digit
		or	al,'0'
@@space:	call	print_chr
		cmp	cl,4			;comma position?
		je	@@comma
		cmp	cl,7
		je	@@comma
		cmp	cl,10			;comma position?
		jne	@@notcomma
@@comma:	or	ebx,ebx			;yes, if no digit printed, print space
		jz	@@space2
		mov	al,'_'			;else, print underscore
@@space2:	call	print_chr
@@notcomma:	mov	eax,edx
		loop	@@digit

		pop	edx
		pop	ecx
		pop	ebx
		ret


@@tens		dd	1,10,100,1000,10000,100000,1000000,10000000,100000000,1000000000
;
;
; Print string at esi
;
print_string_esi:

		push	eax

@@loop:		lodsb
		cmp	al,' '
		jb	@@done
		call	print_chr
		jmp	@@loop
@@done:
		pop	eax
		ret
;
; Print string after call
; zero-terminated string must follow call
;
print_string:	mov	[@@temp],esi

		pop	esi
		push	eax

@@loop:		lodsb
		cmp	al,0
		je	@@done
		call	print_chr
		jmp	@@loop

@@done:		pop	eax
		push	esi

		mov	esi,[@@temp]
		ret


ddx		@@temp
;
;
; Print al
;
print_cr:	mov	al,13

print_chr:	push	edi

		mov	edi,[print_length]	;full?
		cmp	edi,[print_limit]
		je	error_litl

		add	edi,[print]		;enter chr
		stosb

		inc	[print_length]		;inc length

		pop	edi
		ret
;
;
; Set print data
; esi must point to data
;
set_print:	lea	edi,[print]		;set pointer/limit/length
		movsd
		movsd
		xor	eax,eax
		stosd

		ret
;
;
; Print data
;
ddx		print
ddx		print_limit
ddx		print_length
;
;
;************************************************************************
;*  Info Routines							*
;************************************************************************
;
;
; Enter info
;
enter_info:	push	ebx

		mov	ebx,[info_count]	;get count and increment
		cmp	ebx,info_limit
		jne	@@ok
		dec	ebx
		jmp	@@limit
@@ok:		inc	[info_count]
@@limit:
		push	[inf_start]		;enter start
		pop	[info_start+ebx*4]
		push	[inf_finish]		;enter finish
		pop	[info_finish+ebx*4]
		push	[inf_type]		;enter type
		pop	[info_type+ebx*4]
		push	[inf_data0]		;enter data0
		pop	[info_data0+ebx*4]
		push	[inf_data1]		;enter data1
		pop	[info_data1+ebx*4]
		push	[inf_data2]		;enter data2
		pop	[info_data2+ebx*4]
		push	[inf_data3]		;enter data3
		pop	[info_data3+ebx*4]

		pop	ebx
		ret


ddx		inf_start
ddx		inf_finish
ddx		inf_type
ddx		inf_data0
ddx		inf_data1
ddx		inf_data2
ddx		inf_data3
;
;
;******************
;*  Preprocessor  *
;******************
;
; Preprocessor commands
;
pre_define	=	00000001b		;#DEFINE symbol
pre_undef	=	00000010b		;#UNDEF symbol
pre_ifdef	=	00000100b		;#IFDEF symbol
pre_ifndef	=	00001000b		;#IFNDEF symbol
pre_elseifdef	=	00010000b		;#ELSEIFDEF symbol
pre_elseifndef	=	00100000b		;#ELSEIFNDEF symbol
pre_else	=	01000000b		;#ELSE
pre_endif	=	10000000b		;#ENDIF


preprocessor:	mov	[preprocessor_used],0	;clear preprocessor-used flag
		call	reset_element		;point to start of source code
		xor	edx,edx			;reset preprocessor stack (8 nibbles/levels)

@@checkline:	call	get_element		;get element at start of line
		jc	@@done			;if eof, done
		cmp	al,type_pound		;if not '#', check if eol
		jne	@@checkeol
		mov	esi,[source_start]	;got '#', remember start of '#'
		call	get_element		;get element after '#'
		cmp	al,type_pre_command	;got preprocessor command?
		je	@@command
@@checkeol:	cmp	al,type_end		;if eol, check next line
		je	@@checkline
		call	get_element		;scan to eol
		jmp	@@checkeol

@@done:		test	dl,0Fh			;eof, error if open IFDEF/IFNDEF block
		jnz	error_eendif
		ret				;done


@@command:	mov	[preprocessor_used],1	;set preprocessor-used flag
		mov	[source_start],esi	;set source start to '#' in case error

		test	edx,0F0000000h		;if stack full, error if IFDEF/IFNDEF
		jz	@@notfull
		test	bl,pre_ifdef or pre_ifndef
		jnz	error_loxniie
@@notfull:
		test	dl,0Fh			;if unscoped, error if ELSEIFDEF/ELSEIFNDEF/ELSE/ENDIF
		jnz	@@inscope
		test	bl,pre_elseifdef or pre_elseifndef or pre_else or pre_endif
		jnz	error_mbpbi
@@inscope:
		test	dl,@@elsef		;if ELSE flag, error if ELSEIFDEF/ELSEIFNDEF/ELSE
		jz	@@notelse
		test	bl,pre_elseifdef or pre_elseifndef or pre_else
		jnz	error_eendif
@@notelse:
		mov	cl,dl			;get state before command

		cmp	bl,pre_define		;handle command
		je	@@define
		cmp	bl,pre_undef
		je	@@undef			;c=0
		cmp	bl,pre_ifdef
		je	@@ifdef			;c=0
		cmp	bl,pre_ifndef
		je	@@ifndef
		cmp	bl,pre_elseifdef
		je	@@elseifdef		;c=0
		cmp	bl,pre_elseifndef
		je	@@elseifndef
		cmp	bl,pre_else
		je	@@else
		jmp	@@endif

@@define:	stc				;DEFINE symbol
@@undef:	pushf				;UNDEF symbol (c=0)
		call	@@testsymbol		;test symbol
		popf
		mov	ah,0
		adc	ah,0			;ah=1 if DEFINE, ah=0 if UNDEF

		test	dl,@@inactivef		;if inactive, ignore
		jnz	@@getend

		cmp	al,type_pre_symbol	;if symbol, set it to 0 or 1
		jne	@@notint
		mov	ebx,[symbol_exists_ptr]
		mov	[ebx-1-4],ah
		jmp	@@getend
@@notint:
		call	backup_symbol		;undefined, enter new symbol
		mov	al,type_pre_symbol
		movzx	ebx,ah
		call	enter_symbol2
		jmp	@@getend

@@ifndef:	stc				;IFNDEF symbol
@@ifdef:	call	@@testsymbol		;IFDEF symbol (c=0)
		shl	edx,4			;push outer state
		or	dl,[@@ifdef_+ebx]	;get new state
		jmp	@@getend

@@elseifndef:	stc				;ELSEIFNDEF symbol
@@elseifdef:	call	@@testsymbol		;ELSEIFDEF symbol (c=0)
		and	dl,0F0h			;update current state
		or	dl,[@@elseifdef_+ebx-2]
		jmp	@@getend

@@else:		mov	bl,dl			;ELSE
		and	ebx,0110b		;update current state
		shr	ebx,1
		and	dl,0F0h
		or	dl,[@@else_+ebx-1]
		jmp	@@getend

@@endif:	shr	edx,4			;ENDIF, pop outer state

@@getend:	call	get_end			;get end of line

		xor	cl,dl			;active/inactive change?
		test	cl,@@inactivef
		jz	@@same
		test	dl,@@inactivef		;yes, which direction?
		jz	@@nowactive
		mov	edi,[source_ptr]	;active to inactive, remember start of inactive source
		jmp	@@same
@@nowactive:	mov	esi,edi			;inactive to active, clear from start of inactive source
@@same:
		mov	ecx,[source_start]	;clear inactive code and/or command from source
		sub	ecx,esi
		add	esi,[source]
@@clear:	lodsb				;get source character
		cmp	al,9			;tab?
		je	@@keep
		cmp	al,13			;eol?
		je	@@keep
		mov	[byte esi-1],' '	;else, change to space to clear source
@@keep:		loop	@@clear
		jmp	@@checkline


@@testsymbol:	pushf				;c=0 for IFDEF/ELSEIFDEF, c=1 for IFNDEF/ELSEIFNDEF
		call	get_element		;get symbol
		cmp	al,type_pre_symbol	;preprocessor symbol?
		je	@@testsymbol2
		cmp	al,type_undefined	;if not undefined, error, else value = 0
		jne	error_eapps
@@testsymbol2:	popf
		adc	bl,0			;toggle 0/1 value if IFNDEF/ELSEIFNDEF
		and	bl,1
		or	bl,dl			;get current state with 0/1 in lsb
		and	ebx,0111b
		ret				;al=type, ebx=offset into lookup table


@@planned	=	0010b			;preprocessor states
@@active	=	0100b
@@completed	=	0110b

@@elsef		=	1000b			;ELSE flag
@@inactivef	=	0010b			;inactive flag

@@ifdef_	db	@@planned		;unscoped  + false	--> planned
		db	@@active		;unscoped  + true	--> active
		db	@@completed		;planned   + false	--> completed
		db	@@completed		;planned   + true	--> completed
		db	@@planned		;active    + false	--> planned
		db	@@active		;active    + true	--> active
		db	@@completed		;completed + false	--> completed
		db	@@completed		;completed + true	--> completed

@@elseifdef_	db	@@planned		;planned   + false	--> planned
		db	@@active		;planned   + true	--> active
		db	@@completed		;active    + false	--> completed
		db	@@completed		;active    + true	--> completed
		db	@@completed		;completed + false	--> completed
		db	@@completed		;completed + true	--> completed

@@else_		db	@@elsef or @@active	;planned		--> active
		db	@@elsef or @@completed	;active			--> completed
		db	@@elsef or @@completed	;completed		--> completed


error_eendif:	call	set_error
		db	'Expected #ENDIF',0

error_loxniie:	call	set_error
		db	'Limit of 8 nested #IFDEF/#IFNDEFs exceeded',0

error_mbpbi:	call	set_error
		db	'Must be preceeded by #IFDEF or #IFNDEF',0

error_eapps:	call	set_error
		db	'Expected a preprocessor symbol',0
;
;
;************************************************************************
;*  High-Level Compiler Routines					*
;************************************************************************
;
;
; Determine compiler mode
; pasm_mode is set to 0 for Spin or 1 for PASM
;
determine_mode:	call	reset_element

		mov	cl,0			;reset DAT block flag

@@scan:		call	get_element		;get element
		jc	@@done			;if eof, cl holds mode

		cmp	al,type_block		;if not type_block, ignore
		jne	@@scan

		cmp	bl,block_con		;if CON, ignore
		je	@@scan

		cmp	bl,block_dat		;if not DAT, must be OBJ/VAR/PUB/PRI, set Spin mode
		jne	@@spin

		mov	cl,1			;DAT, set flag and continue
		jmp	@@scan


@@spin:		mov	cl,0			;Spin mode
@@done:		mov	[pasm_mode],cl		;Spin or PASM mode (DAT and no OBJ/VAR/PUB/PRI)

		ret
;
;
; Determine Spin2 level
;
determine_level:

		call	reset_element

@@scan:		call	get_element		;skip past comment lines
		mov	ecx,[source_finish]	;end of file?
		jc	@@end
		cmp	al,type_end		;end of initial comments?
		mov	ecx,[source_start]
		je	@@scan
@@end:
		or	ecx,ecx			;if position 0, done
		jz	@@none

		mov	esi,[source]		;point to start of file, ecx holds length
@@check:	mov	ebx,0			;reset offset

		mov	eax,esi			;set source_start in case error
		sub	eax,[source]
		mov	[source_start],eax

		call	@@chr			;check for '{spin2_v##}' at each offset
		cmp	al,'{'
		jne	@@not

		call	@@chr
		cmp	al,'S'
		jne	@@not

		call	@@chr
		cmp	al,'P'
		jne	@@not

		call	@@chr
		cmp	al,'I'
		jne	@@not

		call	@@chr
		cmp	al,'N'
		jne	@@not

		call	@@chr
		jnc	@@not
		cmp	al,2
		jne	@@not

		call	@@chr
		cmp	al,'_'
		jne	@@not

		call	@@chr
		cmp	al,'V'
		jne	@@not

		call	@@chr
		jnc	@@not
		mov	dl,10
		mul	dl
		mov	dl,al

		call	@@chr
		jnc	@@not
		add	dl,al

		call	@@chr
		cmp	al,'}'
		je	@@got

@@not:		inc	esi			;not '{spin2_v##}'
		loop	@@check			;check from next chr until out of chrs

@@none:		mov	dl,41			;default to earliest level

@@got:		add	[source_start],8	;set source_finish in case error
		mov	eax,[source_start]
		add	eax,2
		mov	[source_finish],eax

		cmp	dl,41			;validate level
		jb	error_lsvi
		cmp	dl,spin2_version
		ja	error_hsvi

		mov	[spin2_level],dl	;save it
		ret


@@chr:		mov	al,[byte esi+ebx]	;get next chr
		inc	ebx

		cmp	al,'a'			;make uppercase
		jb	@@case
		cmp	al,'z'
		ja	@@case
		sub	al,'a'-'A'
@@case:
		cmp	al,'0'			;check digit
		jb	@@ndig
		cmp	al,'9'
		ja	@@ndig
		sub	al,'0'
		stc				;digit in al, c=1
		ret

@@ndig:		clc				;chr in al, c=0
		ret


dbx		spin2_level
;
;
; Compile con blocks
;
compile_con_blocks_1st:

		mov	[struct_id_next],0	;reset data structures
		mov	[struct_def_ptr],0

		mov	al,001b			;resolve initial symbols, first pass
		call	compile_con_blocks
		mov	al,101b			;resolve more symbols (%101 avoids operand mode %x1x)
		jmp	compile_con_blocks

compile_con_blocks_2nd:

		mov	al,101b			;resolve more symbols, incorporates obj and clock symbols
		call	compile_con_blocks
		mov	al,000b			;resolve any remaining symbols, last pass

compile_con_blocks:

		mov	[con_block_flag],1	;set con block flag (enables registers as constants, inhibits SIZEOF use)

		mov	[@@pass],al		;set pass

		call	reset_element		;reset element
		jmp	@@autoblock

@@nextblock:	mov	dl,block_con		;scan for con block
		call	next_block

@@autoblock:	mov	[@@enum_valid],1	;reset enumeration
		mov	[@@enum_value],0
		mov	[@@enum_step],1

@@nextline:	call	get_element		;get element
		jc	@@done			;eof?
		cmp	al,type_end		;end?
		je	@@nextline

@@sameline:	mov	[@@assign_flag],1	;set assign flag

		cmp	al,type_con_int		;check for integer constant
		je	@@constant
		cmp	al,type_con_float	;check for float constant
		je	@@constant
		cmp	al,type_undefined	;check for undefined
		je	@@symbol
		cmp	al,type_pound		;check for '#'
		je	@@pound
		cmp	al,type_struct		;check for 'STRUCT'
		je	@@struct

		cmp	al,type_block		;block?
		jne	error_eaucnpos
		call	back_element		;yes, back up
		jmp	@@nextblock		;resume scan for next con block


@@constant:	cmp	[@@pass],001b		;constant, may be an already-assigned symbol (doesn't happen on %101)
		je	error_eaucnpos		;if first pass, error
		mov	[@@assign_flag],0	;not first pass, clear assign flag
		mov	[@@assign_type],al	;save assign type and value for verification
		mov	[@@assign_value],ebx

@@symbol:	push	[source_start]		;symbol, set info source ptrs
		pop	[inf_start]
		push	[source_finish]
		pop	[inf_finish]

		call	backup_symbol		;backup constant symbol

		mov	[@@float],0		;reset float flag

		call	get_element		;get '=', '[', ',', or end
		cmp	al,type_equal		;name = value
		je	@@equal
		cmp	al,type_leftb		;name[enum_advance]
		je	@@enumx
		cmp	al,type_comma		;name, (enum, more on line)
		je	@@enuma
		cmp	al,type_end		;name (enum, end of line)
		je	@@enuma
		jmp	error_eelcoeol


@@equal:	mov	bl,[@@pass]		;symbol = value
		call	try_value		;try to resolve value, errors if unresolved on last pass
		rcl	[@@float],1		;if float, set flag to 1
		test	[exp_flags],100b	;resolved?
		jz	@@assign		;if resolved, assign value to symbol
		jmp	@@next			;unresolved, next

@@enumx:	mov	bl,[@@pass]		;symbol[value], assign enumeration
		call	try_value_int		;try to resolve value, errors if unresolved on last pass
		call	get_rightb
		test	[exp_flags],100b	;if [value] resolved, check if current enumeration is valid
		jz	@@enumv
		mov	[@@enum_valid],0	;unresolved, cancel flag, next
		jmp	@@next

@@enuma:	call	back_element		;isolated symbol, back up before comma or eol
		mov	ebx,1
@@enumv:	cmp	[@@enum_valid],0	;if enumeration invalid, next
		je	@@next

		mov	eax,ebx			;enumeration valid, get current value and assign to symbol
		mul	[@@enum_step]
		mov	ebx,eax
		xchg	[@@enum_value],ebx
		add	[@@enum_value],ebx


@@assign:	call	@@checkparam		;if symbol is a parameter, substitute the parameter value

		cmp	[@@assign_flag],0	;if assign flag clear, verify assign type and value
		je	@@verify

		mov	al,info_con		;assign, set info
		add	al,[@@float]
		movzx	eax,al
		mov	[inf_type],eax
		mov	[inf_data0],ebx
		call	enter_info

		mov	al,objx_con_int		;enter constant symbol into pub/con list
		test	[@@float],1
		jz	@@conint
		mov	al,objx_con_float
@@conint:	call	pubcon_symbol2
		mov	eax,ebx			;enter long value
		call	pubcon_byte
		shr	eax,8
		call	pubcon_byte
		shr	eax,8
		call	pubcon_byte
		shr	eax,8
		call	pubcon_byte

		mov	al,type_con_int		;enter constant symbol
		add	al,[@@float]		;integer or float?
		call	enter_symbol2_print
		jmp	@@next

@@verify:	push	[inf_start]		;verify assign value and type (post-first pass)
		pop	[source_start]
		push	[inf_finish]
		pop	[source_finish]
		mov	al,type_con_int
		add	al,[@@float]
		cmp	[@@assign_type],al
		jne	error_siad
		cmp	[@@assign_value],ebx
		jne	error_siad
		jmp	@@next


@@pound:	mov	bl,[@@pass]		;#value, set enumeration start
		call	try_value_int		;try to resolve value, errors if unresolved on last pass
		mov	[@@enum_valid],0	;clear flag
		test	[exp_flags],100b	;if resolved, set flag, value, and default step
		jnz	@@poundleftb
		mov	[@@enum_valid],1
		mov	[@@enum_value],ebx
		mov	[@@enum_step],1
@@poundleftb:	call	check_leftb		;check for [step]
		jne	@@next
		mov	bl,[@@pass]		;try to get step value
		call	try_value_int		;errors if unresolved on last pass
		mov	[@@enum_step],ebx	;save step value
		test	[exp_flags],100b	;if unresolved, cancel flag
		jz	@@poundrightb
		mov	[@@enum_valid],0
@@poundrightb:	call	get_rightb
		jmp	@@next			;get comma or end of line


@@struct:	call	get_element		;'STRUCT', get structure name
		cmp	al,type_undefined	;symbol must be undefined
		jne	error_eausn
		cmp	[@@pass],000b		;if last pass, enter structure definition
		je	@@structenter
		call	check_left		;otherwise, if '(', scan to ')'
		je	@@structlskip
		call	check_equal		;otherwise, if '=', skip to comma or end of line
		je	@@structeskip
		jmp	error_eloe		;error, neither '(' or '=' found
@@structlskip:	call	scan_to_right		;scan to ')'
		jmp	@@next
@@structeskip:	call	skip_to_comma_or_end	;skip to comma or end of line
		jmp	@@next
@@structenter:
		call	backup_symbol		;backup symbol

		mov	ebx,[struct_id_next]	;is another structure definition allowed?
		cmp	ebx,struct_id_limit
		je	error_loxdsde

		mov	eax,[struct_def_ptr]	;set struct_id_to_def
		mov	[struct_id_to_def+ebx*4],eax

		call	build_struct_record	;build structure-definition record in structure buffer

		mov	al,type_con_struct	;enter structure symbol after build to avoid recursion
		mov	ebx,[struct_id_next]
		call	enter_symbol2_print

		mov	al,objx_con_struct	;enter struct symbol into pub/con list
		call	pubcon_symbol2

		mov	eax,[struct_id_next]	;get structure record start
		mov	esi,[struct_id_to_def+eax*4]
		add	esi,offset struct_def
		movzx	ecx,[word esi]		;get structure record size
@@structrec:	lodsb				;enter record
		call	pubcon_byte
		loop	@@structrec

		inc	[struct_id_next]	;ready next structure id


@@next:		call	get_comma_or_end	;get comma or end
		jne	@@nextline		;end, next line
		call	get_element		;comma, get next element, sameline
		jmp	@@sameline

@@done:		mov	[con_block_flag],0	;clear con block flag
		ret


@@checkparam:	push	ebx			;if symbol is a parameter, substitute the parameter value
		lea	esi,[symbol2]
		lea	edi,[symbol]
		mov	ecx,32
	rep	movsb
		call	find_param
		cmp	al,type_undefined
		jne	@@param
		pop	ebx
		ret

@@param:	mov	[@@float],0		;symbol is a parameter
		cmp	al,type_con_int
		je	@@paramint
		inc	[@@float]
@@paramint:	mov	[@@assign_type],al
		mov	[@@assign_value],ebx
		pop	eax
		ret


dbx		@@pass
dbx		@@float
dbx		@@enum_valid
ddx		@@enum_value
ddx		@@enum_step
dbx		@@assign_flag
dbx		@@assign_type
ddx		@@assign_value
;
;
; Compile obj blocks - get id's, filenames, and parameters
;
compile_obj_blocks_id:

		mov	[obj_block_flag],1	;set obj block flag (inhibits SIZEOF use)

		mov	[obj_ptr],0		;reset obj pointer
		mov	[obj_count],0		;reset obj count
		mov	[obj_files],0		;reset obj file count

		call	reset_element		;reset element

@@nextblock:	mov	dl,block_obj		;scan for obj block
		call	next_block

@@nextline:	call	get_element_obj		;get element, check for eof/end
		jc	@@done
		cmp	al,type_end
		je	@@nextline

		cmp	al,type_undefined	;check for new obj name
		je	@@newobj

		cmp	al,type_block		;block?
		jne	error_eauon
		call	back_element		;yes, back up
		jmp	@@nextblock		;resume scan for next obj block


@@newobj:	call	backup_symbol		;backup obj name

		mov	[@@count],1		;if no [count] specified, use 1
		call	check_leftb
		jne	@@nocount
		call	get_value_int		;make sure count valid
		or	ebx,ebx
		jz	@@counterror
		cmp	ebx,255
		jbe	@@countokay
@@counterror:	jmp	error_ocmbf1tx
@@countokay:	mov	[@@count],ebx
		call	get_rightb
@@nocount:
		call	get_colon		;get colon

		call	get_filename		;get filename with length
		inc	ecx			;include zero-terminator

		mov	edx,[obj_files]		;get file number and check limit
		cmp	edx,files_limit
		je	error_loxuoe

		mov	edi,edx			;enter filename
		shl	edi,8
		add	edi,offset obj_filenames
		lea	esi,[filename]
	rep	movsb

		mov	eax,[filename_start]	;enter filename source pointers
		mov	[obj_name_start+edx*4],eax
		mov	eax,[filename_finish]
		mov	[obj_name_finish+edx*4],eax

		mov	ebx,edx			;enter obj symbol
		shl	ebx,24
		or	ebx,[obj_count]		;ebx[31:24] = file number, ebx[23:0] = obj index
		mov	al,type_obj
		call	enter_symbol2_print

		mov	ecx,[@@count]		;enter instances
		mov	[obj_instances+edx*4],ecx

@@index:	mov	eax,[obj_count]		;enter file number into index
		cmp	eax,objs_limit		;object limit exceeded?
		je	error_loxoie
		mov	eax,edx
		call	enter_obj_long
		mov	eax,0
		call	enter_obj_long
		inc	[obj_count]
		loop	@@index


		mov	[obj_params+edx*4],0	;parameter list is empty by default

		call	get_pipe_or_end		;any parameters?
		jne	@@noparams

		mov	eax,obj_params_limit	;get parameter base
		mul	edx
		mov	edx,eax

@@param:	mov	eax,[obj_files]		;check param limit
		cmp	[obj_params+eax*4],obj_params_limit
		je	error_tmop

		call	get_element_obj		;get parameter name
		cmp	[symbol_flag],1
		jne	error_eas

		mov	edi,edx			;enter symbol into parameter names
		shl	edi,5			;multiply by 32 for parameter name size
		add	edi,offset obj_param_names
		lea	esi,[symbol]
		mov	ecx,32
	rep	movsb

		call	get_equal		;get '='

		call	get_value		;get type and value
		mov	al,type_con_int
		jnc	@@notfloat
		mov	al,type_con_float
@@notfloat:	mov	[obj_param_types+edx],al
		mov	[obj_param_values+edx*4],ebx

		inc	edx			;increment parameter index

		mov	eax,[obj_files]		;increment parameter count
		inc	[obj_params+eax*4]

		call	get_comma_or_end	;another parameter?
		je	@@param
@@noparams:

@@objdone:	inc	[obj_files]		;inc obj file number

		jmp	@@nextline

@@done:		mov	[obj_block_flag],0	;clear obj block flag
		ret


ddx		@@count
;
;
; Compile sub blocks - id only
;
compile_sub_blocks_id:

		cmp	[pasm_mode],1		;if pasm mode, done
		je	@@done

		mov	eax,[obj_ptr]		;record sub index base (after obj index)
		shr	eax,2
		mov	[@@base],eax

		mov	[@@first],0		;reset 'first' flag

		mov	dl,block_pub		;compile pub id's
		call	@@compile

		cmp	[@@first],0		;if no pubs, error
		je	error_npmf

		mov	dl,block_pri		;compile pri id's
		call	@@compile

		mov	eax,0			;enter 0 (future size) into index
		jmp	enter_obj_long		;(done)


@@compile:	call	reset_element		;reset element

@@nextblock:	call	next_block		;scan for pub/pri block
		jc	@@done

		call	get_element_obj		;get new sub name
		jc	@@error
		cmp	al,type_undefined
		je	@@newsub
@@error:	jmp	error_eaumn


@@newsub:	call	backup_symbol		;backup sub name

		mov	[@@params],0		;reset parameter count
		mov	[@@results],0		;reset result count


		call	get_left		;get '('
		call	check_right		;if ')', no parameters
		je	@@noparams

@@param:	mov	[@@size],1		;set default size
		call	get_element_obj		;get unique parameter name, struct, or '^'
		call	check_con_struct_size	;struct? (eax=size)
		jne	@@paramnstr
		add	eax,11b			;struct, set size by rounding up to next long
		shr	eax,2
		mov	[@@size],eax
		jmp	@@paramname
@@paramnstr:	call	check_ptr		;check for ^byte/word/long/struct
		jne	@@paramchk
@@paramname:	call	get_element_obj		;get unique structure parameter name
@@paramchk:	cmp	al,type_undefined
		jne	error_eaupn
		mov	eax,[@@size]		;advance parameter count
		add	[@@params],eax
		cmp	[@@params],method_params_limit
		ja	error_loxpe
		call	get_comma_or_right	;get comma or ')'
		je	@@param
@@noparams:

		call	check_colon		;check for ':' to signify result(s)
		jne	@@noresults

@@result:	mov	[@@size],1		;set default size
		call	get_element_obj		;get unique parameter name or struct
		call	check_con_struct_size	;struct? (eax=size)
		jne	@@resultnstr
		add	eax,11b			;struct, set size by rounding up to next long
		shr	eax,2
		mov	[@@size],eax
		jmp	@@resultname
@@resultnstr:	call	check_ptr		;check for ^byte/word/long/struct
		jne	@@resultchk
@@resultname:	call	get_element_obj		;get unique structure parameter name
@@resultchk:	cmp	al,type_undefined
		jne	error_eaurn
		mov	eax,[@@size]		;advance parameter count
		add	[@@results],eax
		cmp	[@@results],method_results_limit
		ja	error_loxre
		call	check_comma		;check for comma
		je	@@result
@@noresults:

		call	get_pipe_or_end		;get pipe or end
		jne	@@nolocals

@@local:	mov	[@@ptrflag],0		;clear ptr flag
		call	get_element_obj		;get alignw/alignl, {^}byte/word/long/struct, and/or variable name
		call	check_align		;skip alignw/alignl
		jne	@@noalign
		call	get_element_obj		;get {^}byte/word/long/struct, and/or variable name
@@noalign:	cmp	al,type_size		;byte/word/long?
		je	@@getvar
		call	check_con_struct_size	;struct?
		je	@@getvar
		call	check_ptr		;^byte/word/long/struct?
		jne	@@gotvar
		mov	[@@ptrflag],1		;set ptr flag
@@getvar:	call	get_element_obj		;{^}byte/word/long/struct, get a unique variable name
@@gotvar:	cmp	al,type_undefined
		jne	error_eauvnsa
		call	check_leftb		;check for '[' to signify array
		jne	@@noarray
		cmp	[@@ptrflag],1		;got '[', error if ptr flag set
		je	error_pcba
		call	scan_to_rightb		;array, scan to ']'
@@noarray:	call	get_comma_or_end	;get comma or end
		je	@@local			;if comma, get next local
@@nolocals:

		mov	ebx,[obj_ptr]		;get method index
		shr	ebx,2
		mov	eax,ebx
		sub	eax,[@@base]		;method limit exceeded?
		cmp	eax,methods_limit
		je	error_loxppme

		mov	eax,[@@params]		;get parameter count
		shl	eax,4
		or	eax,[@@results]		;get result count
		shl	eax,20
		or	ebx,eax
		mov	al,type_method		;enter method symbol
		call	enter_symbol2_print

		and	ebx,7FF00000h		;preserve parameter count and result count
		or	ebx,80000000h		;set pub/pri flag
		mov	eax,ebx
		call	enter_obj_long		;enter flag/params/results into index[31:20], index[19:0] will be set in future

		cmp	dl,block_pub		;if pub, enter symbol, parameters, and results into pub/con list
		jne	@@notpub
		mov	al,objx_pub
		call	pubcon_symbol2
		mov	eax,[@@params]
		call	pubcon_byte
		mov	eax,[@@results]
		call	pubcon_byte
@@notpub:
		mov	[@@first],1		;set first flag

		jmp	@@nextblock		;skip sub body, get next block

@@done:		ret


dbx		@@first
ddx		@@base
ddx		@@params
ddx		@@results
ddx		@@size
dbx		@@ptrflag
;
;
; Compile dat blocks - filenames only
;
compile_dat_blocks_fn:

		mov	[dat_files],0		;reset dat file count

		call	reset_element		;reset element

@@nextblock:	mov	dl,block_dat		;scan for dat block
		call	next_block

@@nextelement:	call	get_element		;get element, check for eof
		jc	@@done

		cmp	al,type_file		;check for 'file'
		je	@@gotfile

		cmp	al,type_block		;block?
		jne	@@nextelement

		call	back_element		;yes, back up
		jmp	@@nextblock		;resume scan for next dat block


@@gotfile:	call	get_filename		;'file', get filename with length
		inc	ecx			;include zero-terminator

		xor	ebx,ebx			;check against other filenames
@@check:	lea	esi,[filename]		;get pointers
		mov	edi,ebx
		shl	edi,8
		add	edi,offset dat_filenames

		cmp	ebx,[dat_files]		;if end of filenames, new
		je	@@new

		push	ecx			;compare filenames
	repe	cmpsb
		pop	ecx
		je	@@got			;if equal, got
		inc	ebx			;try next filename
		jmp	@@check

@@new:		inc	[dat_files]		;unique file, check files limit
		cmp	[dat_files],files_limit
		ja	error_loxudfe

	rep	movsb				;enter filename

		mov	eax,[filename_start]	;enter filename source pointers
		mov	[dat_name_start+ebx*4],eax
		mov	eax,[filename_finish]
		mov	[dat_name_finish+ebx*4],eax

@@got:		jmp	@@nextelement		;get next element

@@done:		ret
;
;
; Compile obj pub/con symbols, also validates obj files
;
compile_obj_symbols:

		mov	[@@file],0		;reset object file counter

@@nextfile:	mov	eax,[@@file]		;another file?
		cmp	eax,[obj_files]
		jne	@@getfile
		ret
@@getfile:
		lea	esi,[obj_data]		;get object start and length
		add	esi,[obj_offsets+eax*4]
		mov	ecx,[obj_lengths+eax*4]

		mov	edx,esi			;get eof in edx
		add	edx,ecx

		push	esi			;verify obj checksum
		mov	ah,0
@@checksum:	lodsb
		add	ah,al
		loop	@@checksum
		cmp	ah,0
		jne	@@error
		pop	esi

		lodsd				;get vsize
		test	eax,11b			;make sure long aligned
		jnz	@@error

		lodsd				;get psize
		test	eax,11b			;make sure long aligned
		jnz	@@error

		add	eax,esi			;skip past obj bytes
		inc	eax			;skip past checksum

		mov	[@@pub],0		;determine initial pub index
@@findpub:	test	[byte esi+3],80h	;if msb set, initial pub
		jnz	@@gotpub
		add	[@@pub],2		;msb clear, advance pub index by 2
		add	esi,8			;skip two obj longs
		jmp	@@findpub		;check next
@@gotpub:
		mov	esi,eax			;point past checksum


@@nextsymbol:	cmp	esi,edx			;check for next pub/con symbol
		jb	@@getsymbol		;if below eof, get symbol
		ja	@@error			;if beyond eof, error
		inc	[@@file]		;eof, next file
		jmp	@@nextfile

@@getsymbol:	lodsb				;get objx_??? type and symbol length
		mov	ah,al
		and	ah,objx_mask_type
		mov	cl,al
		and	ecx,objx_mask_namelength

		lea	edi,[symbol2]		;get symbol
@@chr:		lodsb
		call	check_word_chr
		jc	@@error
		stosb
		loop	@@chr
		mov	al,[byte @@file]	;add file+1 to symbol
		inc	al
		stosb
		mov	al,0			;zero-terminate symbol
		stosb

		cmp	ah,objx_con_int		;objx_cont_int?
		mov	al,type_obj_con_int
		je	@@iscon
		cmp	ah,objx_con_float	;objx_con_float?
		mov	al,type_obj_con_float
		je	@@iscon
		cmp	ah,objx_con_struct	;objx_con_struct?
		je	@@isstruct
		cmp	ah,objx_pub		;objx_pub?
		je	@@ispub
		jmp	@@error


@@iscon:	push	eax			;type_obj_con_int/type_obj_con_float
		lodsd				;get value
		mov	ebx,eax
		pop	eax
		jmp	@@enter			;enter symbol


@@isstruct:	mov	ebx,[struct_id_next]	;type_obj_con_struct
		cmp	ebx,struct_id_limit	;check struct limit
		je	error_loxdsde
		mov	edi,[struct_def_ptr]		;edi points to new record
		mov	[struct_id_to_def+ebx*4],edi	;set struct_id_to_def for new record
		movzx	ecx,[word esi]		;make sure enough room for new record
		mov	eax,ecx
		add	eax,edi
		cmp	eax,struct_def_limit
		ja	error_dsdle
		mov	[struct_def_ptr],eax	;point struct_def_ptr past new structure record
		add	edi,offset struct_def	;get struct_def address in edi
	rep	movsb				;copy structure record
		inc	[struct_id_next]	;ready next struct id
		mov	al,type_obj_con_struct	;set type_obj_con_struct, ebx = struct id
		jmp	@@enter			;enter symbol


@@ispub:	lodsb				;type_obj_pub, get param count into ebx[31:24]
		cmp	al,method_params_limit
		ja	@@error
		mov	bl,al
		shl	ebx,24
		lodsb				;get result count into ebx[23:20]
		cmp	al,method_results_limit
		ja	@@error
		movzx	eax,al
		shl	eax,20
		or	ebx,eax
		or	ebx,[@@pub]		;get pub index into ebx[19:0]
		inc	[@@pub]			;ready next pub index
		mov	al,type_obj_pub		;set type_obj_pub

@@enter:	call	enter_symbol2_print	;enter symbol
		jmp	@@nextsymbol		;next symbol


@@error:	mov	[print_length],0	;obj file error
		call	print_string
		db	'Invalid object file: ',0
		mov	esi,[@@file]
		shl	esi,8
		add	esi,offset obj_filenames
@@error2:	lodsb
		cmp	al,0
		je	@@error3
		call	print_chr
		jmp	@@error2
@@error3:	call	print_string
		db	'.obj',0
		mov	al,0
		call	print_chr
		push	[list]
		pop	[error_msg]

		jmp	abort


ddx		@@file
ddx		@@pub
;
;
; Compile var blocks
;
compile_var_blocks:

		cmp	[pasm_mode],1		;if pasm mode, done
		je	@@ret

		mov	[var_ptr],4		;start variable pointer at 4 to accommodate long pointer to object

		call	reset_element		;reset element

@@nextblock:	mov	dl,block_var		;scan for var block
		call	next_block

@@nextline:	call	get_element_obj		;get element, check for eof/end
		jc	@@done
		cmp	al,type_end
		je	@@nextline

@@checkalign:	call	check_align		;check for alignw/alignl
		jne	@@notalign
		call	@@align
		jmp	@@nextline
@@notalign:
		mov	[@@value_overlay],0	;reset symbol value overlay in case not {^}struct
		mov	[@@size],4		;set size to 4 in case long or ptr

		cmp	al,type_size		;byte/word/long?
		je	@@bwl
		call	check_con_struct_size	;struct? (eax=size)
		je	@@struct
		call	check_ptr		;ptr?
		je	@@ptr
		cmp	al,type_undefined	;if unique variable name, treat as long
		mov	[@@type],type_var_long
		je	@@newlong

		cmp	al,type_block		;block?
		jne	error_eauvnsa
		call	back_element		;yes, back up
		jmp	@@nextblock		;resume scan for next var block


@@bwl:		mov	al,type_var_byte	;byte/word/long, set type
		add	al,bl
		mov	[@@type],al
		mov	cl,bl			;set 1/2/4 size
		mov	eax,1
		shl	eax,cl
		mov	[@@size],eax
		jmp	@@newname

@@struct:	mov	[@@type],type_var_struct	;struct
		mov	[@@size],eax
		jmp	@@structid

@@ptr:		mov	ah,type_var_byte_ptr	;^byte/word/long/struct
		add	ah,bl
		mov	[@@type],ah
		cmp	al,type_size
		je	@@newname
		mov	[@@type],type_var_struct_ptr
@@structid:	shl	ebx,20
		mov	[@@value_overlay],ebx	;set symbol value overlay to structure index


@@newname:	call	get_element_obj		;get unique variable name
		cmp	al,type_undefined
		jne	error_eauvn
@@newlong:	call	backup_symbol

		mov	ebx,1			;if no [count] specified, use 1
		call	check_leftb		;check for '['
		jne	@@nocount
		mov	al,[@@type]		;pointer cannot have [count]
		call	is_ptr
		je	error_pcba
		call	get_value_int		;get count
		cmp	ebx,obj_size_limit
		ja	@@error_tmvsid
		call	get_rightb		;get ']'
@@nocount:
		mov	eax,[@@size]		;update var pointer
		mul	ebx
		or	edx,edx
		jnz	@@error_tmvsid
		cmp	eax,obj_size_limit
		jae	@@error_tmvsid
		xchg	[var_ptr],eax
		add	[var_ptr],eax
		cmp	[var_ptr],obj_size_limit
		jae	@@error_tmvsid
		cmp	eax,obj_size_limit
		jae	@@error_tmvsid

		mov	ebx,eax			;enter symbol
		or	ebx,[@@value_overlay]	;add any structure-index overlay data into symbol value
		mov	al,[@@type]
		call	enter_symbol2_print

		call	get_comma_or_end	;get comma or end of line
		jne	@@nextline		;if end of line, next line
		call	get_element_obj		;comma, get next element
		jc	error_eauvnsa		;if eof, error
		cmp	al,type_end		;if end, error
		je	error_eauvnsa
		cmp	al,type_undefined	;if unique variable name, enter as current type
		je	@@newlong
		jmp	@@checkalign		;else, get alignw/alignl or new type


@@done:		mov	ecx,11b			;done, align to long

@@align:	test	[var_ptr],ecx		;align to word or long
		jz	@@ret
		or	[var_ptr],ecx
		inc	[var_ptr]
@@check:	cmp	[var_ptr],obj_size_limit	;check size
		jae	@@error_tmvsid
@@ret:		ret


@@error_tmvsid:	jmp	error_tmvsid		;too much variable space declared


dbx		@@type
ddx		@@size
ddx		@@value_overlay
;
;
; Compile dat blocks
;
compile_dat_blocks:				;dat block mode
		mov	[inline_flag],0
		jmp	compile_dat

compile_inline_block:				;inline mode
		mov	[inline_flag],1
		call	write_symbols_inline	;start inline symbols


compile_dat:	mov	eax,[obj_ptr]		;save obj_ptr
		mov	[@@objptr],eax

		mov	eax,[asm_local]		;save asm_local
		mov	[@@local],eax

		mov	eax,[source_ptr]	;save source_ptr for inline mode
		mov	[@@sourceptr],eax

		mov	[@@pass],0		;reset pass

@@passloop:	mov	eax,[@@objptr]		;set obj_ptr
		mov	[obj_ptr],eax

		mov	eax,[@@local]		;set asm_local
		mov	[asm_local],eax

		mov	[hub_org],00000h	;reset hub org
		mov	[hub_org_limit],100000h	;reset hub org limit

		mov	[ditto_flag],0		;reset DITTO flag

		mov	[@@size],0		;reset size to byte

		cmp	[inline_flag],1		;block or inline mode?
		jne	@@passblock

		mov	eax,[inline_cog_org]		;inline mode, reset cog org
		mov	[cog_org],eax
		mov	eax,[inline_cog_org_limit]	;reset cog org limit
		mov	[cog_org_limit],eax
		mov	eax,00400h			;reset hub org
		mov	[hub_org],eax
		sub	eax,[obj_ptr]			;set orgh_offset
		mov	[orgh_offset],eax
		mov	[hub_org_limit],100000h		;reset hub org limit
		mov	eax,[@@sourceptr]		;reset source_ptr
		mov	[source_ptr],eax
		jmp	@@passprep

@@passblock:	mov	[orgh],1			;block mode, start in orgh mode
		mov	[cog_org],000h shl 2		;reset cog org
		mov	[cog_org_limit],1F8h shl 2	;reset cog org limit
		cmp	[pasm_mode],1			;set hub org according to pasm_mode
		mov	eax,[obj_ptr]			;use obj_ptr for pasm_mode
		je	@@passpasm
		mov	eax,00400h			;use $00400 for spin_mode
@@passpasm:	mov	[hub_org],eax
		sub	eax,[obj_ptr]			;set orgh_offset
		mov	[orgh_offset],eax
		mov	[hub_org_limit],100000h		;reset hub org limit
		call	reset_element			;reset element
@@nextblock:	mov	dl,block_dat			;scan for dat block
		call	next_block

@@passprep:	push	[source_start]		;prepare dat block info
		pop	[@@srcstart]
		push	[obj_ptr]
		pop	[@@objstart]
		mov	[@@infoflag],0

@@nextline:	call	get_element_obj		;get element, check for eof/end
		jc	@@eof
		mov	[@@infoflag],1		;not eof, set info flag
		cmp	al,type_end
		je	@@nextline

		mov	[@@sizefit],0		;clear size fit flag

		xor	edx,edx			;reset symbol flag
		push	[source_start]		;save info start in case symbol
		pop	[inf_start]
		call	check_local		;check for local symbol
		rcr	dl,1			;if not local, set dl.7 (inc asm local)
		push	[source_finish]		;save info finish in case (local) symbol
		pop	[inf_finish]
		cmp	al,type_undefined	;check for undefined symbol
		jne	@@notundef		;if not undefined symbol, skip
		call	@@asmlocal		;if not local symbol, inc asm local
		or	edx,80000000h		;symbol, set symbol flag
		call	backup_symbol		;backup symbol
		call	get_element_obj		;get next element
		cmp	al,type_end		;if not end, continue
		jne	@@continue
		call	@@entersymbol		;symbol only, enter symbol
		jmp	@@nextline		;..and check next line
@@notundef:
		cmp	al,type_dat_struct	;if type_dat_struct..
		je	@@gotres
		cmp	al,type_dat_long_res	;or type_dat_long_res..
		je	@@gotres
		cmp	al,type_dat_byte	;or type_dat_byte..type_dat_long..
		jb	@@continue		;..and second pass, okay
		cmp	al,type_dat_long
		ja	@@continue
@@gotres:	call	@@asmlocal		;if not local symbol, inc asm local
		cmp	[@@pass],0		;if pass 0, symbol redeclared
		je	error_siad
		call	get_element_obj		;get next element
		cmp	al,type_end		;if end, check next line
		je	@@nextline
@@continue:
		cmp	al,type_con_struct	;check for type_con_struct
		jne	@@notstruct
		cmp	[@@pass],0		;if not pass 0, skip symbol entry
		jne	@@structdone
		cmp	[orgh],1		;if not orgh mode, error
		jne	error_dscobd
		or	edx,edx			;must be preceded by a symbol
		jns	error_dsmbpbas
		mov	al,type_dat_struct	;type = type_dat_struct
		shl	ebx,32-12		;value = struct id in high bits and obj ptr in low bits
		or	ebx,[obj_ptr]
		mov	[inf_type],info_dat_symbol
		mov	[inf_data0],ebx
		mov	[byte inf_data1],3
		call	enter_info		;enter dat symbol info
		call	enter_symbol2_print	;enter symbol
@@structdone:	call	get_end			;get end
		jmp	@@nextline		;next line
@@notstruct:
		cmp	al,type_size		;check for size
		je	@@data
		cmp	al,type_size_fit	;check for size fit
		je	@@datachk
		cmp	al,type_asm_dir		;check for assembly directive
		je	@@dir
		cmp	al,type_asm_cond	;check for assembly condition
		je	@@cond
		call	@@checkinst		;check for assembly instruction
		je	@@instr

		cmp	[inline_flag],1		;block or inline mode?
		je	@@inlinechk

		cmp	al,type_file		;block, check for file
		je	@@file

		cmp	al,type_block		;block?
		jne	error_eaunbwlo
		call	back_element		;yes, back up
		cmp	[ditto_flag],1		;make sure DITTO block not left open
		je	error_edend
		call	@@enterinfo		;enter info
		jmp	@@nextblock		;continue scan for next dat block

@@inlinechk:	cmp	al,type_asm_end		;inline, must be 'end'
		jne	error_eidbwloe
		cmp	[ditto_flag],1		;make sure DITTO block not left open
		je	error_edend
		mov	ecx,0FD64002Dh		;enter RET instruction
		call	@@enterlong
		jmp	@@passdone

@@eof:		cmp	[inline_flag],1		;eof, error if inline mode
		je	error_eend
		cmp	[ditto_flag],1		;make sure DITTO block not left open
		je	error_edend

@@passdone:	call	@@enterinfo		;enter any info
		inc	[@@pass]		;next pass
		cmp	[@@pass],2
		jne	@@passloop

		cmp	[inline_flag],1		;done, inline mode?
		jne	@@done
		call	reset_symbols_inline	;cancel inline symbols
		call	write_symbols_local
@@done:		ret


@@datachk:	mov	[@@sizefit],1		;set size fit flag

@@data:		mov	[@@size],bl		;byte/word/long data, set size
		call	@@entersymbol		;enter any symbol

		call	check_end		;if end, check next line
		je	@@nextline

@@another:	call	get_element		;check for size override
		cmp	al,type_size
		jne	@@datansize
		mov	dl,bl			;size override
		jmp	@@dataor
@@datansize:	cmp	al,type_fvar		;check for fvar/fvars
		jne	@@datanor
		push	ebx			;fvar/fvars
		call	@@getvalueint
		mov	eax,ebx
		pop	ebx
		cmp	bl,1
		je	@@datafvars
		test	eax,0E0000000h		;fvar must have three msb's clear
		jnz	error_fvar
		lea	esi,[@@enterbyte]
		call	compile_rfvar_dat
		jmp	@@datanext
@@datafvars:	mov	ebx,eax			;fvars must have four msb's same
		sar	ebx,32-4
		jz	@@datafvarsok
		inc	ebx
		jnz	error_fvar
@@datafvarsok:	lea	esi,[@@enterbyte]
		call	compile_rfvars_dat
		jmp	@@datanext
@@datanor:	call	back_element		;no size override, back up
		mov	dl,[@@size]
@@dataor:	cmp	dl,2			;if long size, allow float
		jne	@@notlong
		call	@@tryvalue		;get value/value[count] - integer or float
		jmp	@@islong
@@notlong:	call	@@tryvalueint		;get value/value[count] - integer only
@@islong:	mov	ecx,1			;if no [count] specified, do once
		call	check_leftb
		jne	@@single
		push	ebx			;[count] specified, get count
		call	@@getvalueint
		mov	ecx,ebx
		pop	ebx
		call	get_rightb
@@single:	call	@@enter			;enter value once, or count times
@@datanext:	call	get_comma_or_end	;get comma or end
		jne	@@nextline		;if end, check next line
		jmp	@@another		;comma, get next element and process


@@file:		mov	[@@size],0		;file, set size to byte
		call	@@entersymbol		;enter any symbol
		call	get_filename		;get filename with length
		inc	ecx			;include zero-terminator
		xor	edx,edx			;check against other filenames
@@filefind:	cmp	edx,[dat_files]		;if end of filenames, internal error
		je	error_idfnf
		lea	esi,[filename]		;get filename pointers
		mov	edi,edx
		shl	edi,8
		add	edi,offset dat_filenames
		push	ecx			;compare filenames
	repe	cmpsb
		pop	ecx
		je	@@filefound		;if equal, got
		inc	edx			;try next filename
		jmp	@@filefind
@@filefound:	mov	esi,[dat_offsets+edx*4]
		add	esi,offset dat_data
		mov	ecx,[dat_lengths+edx*4]
		jecxz	@@filedone		;enter file bytes
@@filebyte:	lodsb
		call	@@enterbyte
		loop	@@filebyte
@@filedone:	call	get_end			;get end
		jmp	@@nextline		;next line


@@dir:		mov	[@@size],2		;set long size
		cmp	bl,dir_ditto		;handle directive
		je	@@dirditto
		cmp	bl,dir_fit
		je	@@dirfit
		cmp	bl,dir_res
		je	@@dirres
		cmp	bl,dir_orgf
		je	@@dirorgf
		cmp	bl,dir_org
		je	@@dirorg
		cmp	bl,dir_alignw
		je	@@diralignw
		cmp	bl,dir_alignl
		je	@@diralignl

		cmp	[inline_flag],1		;ORGH, make sure not inline mode
		je	error_ohnawiac
		cmp	[ditto_flag],1		;make sure not in a DITTO block
		je	error_ohnawads
		mov	[orgh],1		;set orgh mode
		call	@@nosymbol		;make sure no symbol
		call	get_element		;preview next element
		call	back_element
		mov	ecx,100000h		;ready default orgh limit
		cmp	al,type_end		;no argument?
		jne	@@dirorgho
		mov	ebx,[obj_ptr]		;no argument, if pasm mode set hub_org to obj_ptr
		cmp	[pasm_mode],1
		je	@@dirorghdef
		mov	ebx,400h		;no argument, spin mode, set hub_org to $400
		jmp	@@dirorghdef
@@dirorgho:	call	@@getvalueint		;argument, get value
		cmp	[pasm_mode],1		;if spin mode, make sure at least $400
		je	@@dirorghp
		cmp	ebx,400h
		jb	error_habxl
@@dirorghp:	cmp	ebx,obj_size_limit	;make sure within hard limit
		ja	error_haec
		mov	ecx,obj_size_limit	;ready default limit in case no comma
		call	check_comma
		jne	@@dirorghdef
		push	ebx			;comma, get limit value
		call	@@getvalueint
		mov	ecx,ebx
		pop	ebx
		cmp	ecx,ebx			;make sure limit at least new orgh
		jb	error_hael
		cmp	ecx,obj_size_limit	;make sure limit within hard limit
		ja	error_haec
@@dirorghdef:	mov	[hub_org],ebx		;update hub org
		mov	[hub_org_limit],ecx	;update hub org limit
		mov	eax,ebx			;set orgh_offset
		sub	eax,[obj_ptr]
		mov	[orgh_offset],eax
		cmp	[pasm_mode],1		;if pasm mode, fill to new orgh with $00 bytes
		jne	@@dirorghs
		sub	ebx,[obj_ptr]
		jc	error_hacd
		sub	[hub_org],ebx
		mov	ecx,ebx
		mov	ebx,0
		mov	dl,0
		call	@@enter
@@dirorghs:	call	get_end
		jmp	@@nextline

@@diralignw:	mov	ebx,01h			;ALIGN, get factor
		jmp	@@diralign
@@diralignl:	mov	ebx,03h
@@diralign:	cmp	[inline_flag],1		;make sure not inline mode
		je	error_aanawiac
		test	[obj_ptr],ebx		;fill with $00 bytes until aligned
		jz	@@diralignx
		push	ebx
		xor	ebx,ebx
		mov	ecx,1
		mov	dl,0
		call	@@enter
		pop	ebx
		jmp	@@diralign
@@diralignx:	call	get_end
		jmp	@@nextline

@@dirorg:	cmp	[inline_flag],1		;ORG, make sure not inline mode
		je	error_onawiac
		cmp	[ditto_flag],1		;make sure not in a DITTO block
		je	error_onawads
		call	@@nosymbol		;make sure no symbol
		call	get_element		;preview next element
		call	back_element
		mov	ebx,000h		;ready defaults in case no argument
		mov	ecx,1F8h
		cmp	al,type_end		;check for end
		je	@@dirorgdef
		call	@@getvalueint		;argument, get value
		cmp	ebx,400h
		ja	error_caexl
		mov	ecx,200h		;default to cog limit
		test	ebx,600h
		jz	@@dirorgcog
		shl	ecx,1			;set lut limit
@@dirorgcog:	call	check_comma		;check for comma
		jne	@@dirorgdef
		push	ebx
		call	@@getvalueint		;get limit value
		mov	ecx,ebx
		pop	ebx
		cmp	ebx,ecx
		ja	error_cael
		cmp	ecx,400h
		ja	error_caexl
@@dirorgdef:	shl	ebx,2
		mov	[cog_org],ebx		;update org
		shl	ecx,2
		mov	[cog_org_limit],ecx	;update org limit
		mov	[orgh],0		;clear orgh mode
		call	get_end
		jmp	@@nextline

@@dirorgf:	cmp	[orgh],0		;ORGF, not allowed in orgh mode
		jne	error_oinaiom
		call	@@nosymbol		;make sure no symbol
		call	@@getvalueint		;get value and end of line
		call	get_end
		shl	ebx,2
		cmp	ebx,[cog_org_limit]	;limit exceeded?
		ja	error_cael
		cmp	[cog_org],ebx		;already exceeded target?
		ja	error_oaet
		mov	ecx,ebx			;fill to target with $00 bytes
		sub	ecx,[cog_org]
		xor	ebx,ebx
		mov	dl,0
		call	@@enter
		jmp	@@nextline

@@dirres:	cmp	[orgh],0		;RES, not allowed in orgh mode
		jne	error_rinaiom
		call	@@coglong		;advance to next cog long
		or	edx,40000000h		;set res symbol flag
		call	@@entersymbol		;enter any symbol
		call	@@getvalueint		;get value
		cmp	ebx,400h		;make sure not negative
		ja	error_cael
		shl	ebx,2			;make byte address
		add	[cog_org],ebx		;update org
		mov	eax,[cog_org_limit]	;limit exceeded?
		cmp	[cog_org],eax
		ja	error_cael
		call	get_end
		jmp	@@nextline


@@dirfit:	call	@@nosymbol		;FIT, make sure no symbol
		call	@@getvalueint		;get fit limit
		cmp	[orgh],1		;handle hub/cog
		jne	@@fitcog
		cmp	[hub_org],ebx		;fit hub
		ja	error_haefl
		jmp	@@fitdone
@@fitcog:	shl	ebx,2			;fit cog
		cmp	[cog_org],ebx
		ja	error_caefl		;limit exceeded?
@@fitdone:	call	get_end
		jmp	@@nextline


@@dirditto:	cmp	[ditto_flag],1		;DITTO, already active?
		je	@@dittoactive

		call	@@entersymbol		;new, enter any symbol
		call	@@getvalueint		;get count
		cmp	ebx,0			;must be >= 0
		jl	error_dcmbapi
		call	get_end
		mov	[ditto_flag],1		;set parameters
		mov	[ditto_index],0
		mov	[ditto_count],ebx
		mov	eax,[source_ptr]
		mov	[ditto_source_ptr],eax
		mov	eax,[obj_ptr]
		mov	[ditto_obj_ptr],eax
		jmp	@@nextline

@@dittoactive:	call	get_element		;active, get END
		cmp	al,type_asm_end
		jne	error_eend
		call	get_end
		cmp	[ditto_count],0		;zero count?
		je	@@dittozero
		inc	[ditto_index]		;inc index and check if count reached
		mov	eax,[ditto_index]
		cmp	eax,[ditto_count]
		je	@@dittodone
		mov	eax,[ditto_source_ptr]	;count not reached, repoint to body of block
		mov	[source_ptr],eax
		jmp	@@nextline

@@dittozero:	mov	eax,[ditto_obj_ptr]	;zero count, restore obj_ptr
		mov	[obj_ptr],eax

@@dittodone:	mov	[ditto_flag],0		;done, cancel flag and carry on
		call	@@entersymbol		;enter any symbol
		jmp	@@nextline


@@cond:		shl	ebx,28			;assembly condition, set cond to bl
		mov	ecx,ebx
		call	get_element_obj		;get assembly instruction
		call	@@checkinst
		je	@@instrcond
		jmp	error_eaasmi

@@instr:	mov	ecx,0F0000000h		;assembly instruction, set cond to always
@@instrcond:	mov	[@@size],2		;set long size

		push	ebx			;advance to long boundary if cog mode, enter any symbol
		call	@@coglong
		call	@@entersymbol
		pop	ebx

		mov	eax,ebx			;save effect bits
		shr	eax,9
		and	al,11b
		mov	[@@effectbits],al

		mov	eax,ebx			;get operand type
		shr	eax,11
		and	eax,3Fh			;(used to be $1F, but needed more operand types)

		and	ebx,1FFh		;isolate opcode

		cmp	al,operand_d		;install opcode according to operand group
		jae	@@oplast
		shl	ebx,19
		jmp	@@opgot
@@oplast:	or	ecx,0D600000h
@@opgot:	or	ecx,ebx

		call	[@@operands+eax*4]	;call operand handler

		call	get_element_obj		;get next element

		cmp	al,type_end		;end?
		je	@@instenter

		cmp	al,type_asm_effect	;verify effect
		jne	error_eaaeoeol
		test	[@@effectbits],bl	;if wc/wz not allowed, error
		jz	error_teinafti
		cmp	[@@effectbits],bl	;if wcz not allowed, error
		jb	error_teinafti
		shl	ebx,19			;set effect bit
		or	ecx,ebx
		call	get_end			;get end

@@instenter:	call	@@enterlong		;enter instruction

		jmp	@@nextline		;next line


@@operands	dd	offset @@op_ds		;operand handlers
		dd	offset @@op_bitx
		dd	offset @@op_testb
		dd	offset @@op_du
		dd	offset @@op_duii
		dd	offset @@op_duiz
		dd	offset @@op_ds3set
		dd	offset @@op_ds3get
		dd	offset @@op_ds2set
		dd	offset @@op_ds2get
		dd	offset @@op_ds1set
		dd	offset @@op_ds1get
		dd	offset @@op_dsj
		dd	offset @@op_ls
		dd	offset @@op_lsj
		dd	offset @@op_dsp
		dd	offset @@op_lsp
		dd	offset @@op_rep
		dd	offset @@op_jmp
		dd	offset @@op_call
		dd	offset @@op_calld
		dd	offset @@op_jpoll
		dd	offset @@op_loc
		dd	offset @@op_aug
		dd	offset @@op_d
		dd	offset @@op_de
		dd	offset @@op_l
		dd	offset @@op_cz
		dd	offset @@op_pollwait
		dd	offset @@op_getbrk
		dd	offset @@op_pinop
		dd	offset @@op_testp
		dd	offset @@op_pushpop
		dd	offset @@op_xlat
		dd	offset @@op_akpin
		dd	offset @@op_asmclk
		dd	offset @@op_nop
		dd	offset @@op_debug


@@op_ds:	call	@@tryd			;inst d,s/#
		call	get_comma
		jmp	@@trys_imm


@@op_bitx:	call	@@tryd			;inst d,s/# {wcz or none)
		call	get_comma
		call	@@trys_imm
		jmp	@@get_wcz


@@op_testb:	call	@@tryd			;inst d,s/# (wc/andc/orc/xorc or wz/andz/orz/xorz}
		call	get_comma
		call	@@trys_imm
		call	@@get_corz
		shl	ebx,22
		or	ecx,ebx
		ret

@@op_du:	call	@@tryd			;inst d,s/# / inst d (unary)
		call	check_comma
		je	@@trys_imm
		mov	eax,ecx
		shr	eax,9
		and	eax,1FFh
		or	ecx,eax
		ret


@@op_duii:	call	@@tryd			;inst d,s/# / inst d (alti)
		call	check_comma
		je	@@trys_imm
		or	ecx,(1 shl 18) + 101100100b
		ret


@@op_duiz:	call	@@tryd			;inst d,s/# / inst d
		call	check_comma
		je	@@trys_imm
		or	ecx,1 shl 18
		ret


@@op_ds3set:	call	@@trys_imm		;inst d,s/#,#0..7 / inst s/#
		test	ecx,1 shl 18
		jne	@@op_dsx_done
		call	check_comma
		jne	@@op_dsx_done
		mov	eax,ecx			;get s into d
		and	ecx,0FFFFFE00h
		and	eax,1FFh
		shl	eax,9
		or	ecx,eax
		jmp	@@op_ds3x


@@op_ds3get:	call	@@tryd			;inst d,s/#,#0..7 / inst d
		call	check_comma
		jne	@@op_dsx_done
@@op_ds3x:	call	@@trys_imm
		call	get_comma
		call	get_pound
		call	@@tryvalueint
		cmp	ebx,111b
		ja	error_smb0t7
		jmp	@@op_ds1_done


@@op_ds2set:	call	@@trys_imm		;inst d,s/#,#0..3 / inst s/#
		test	ecx,1 shl 18
		jne	@@op_dsx_done
		call	check_comma
		jne	@@op_dsx_done
		mov	eax,ecx			;get s into d
		and	ecx,0FFFFFE00h
		and	eax,1FFh
		shl	eax,9
		or	ecx,eax
		jmp	@@op_ds2x


@@op_ds2get:	call	@@tryd			;inst d,s/#,#0..3 / inst d
		call	check_comma
		jne	@@op_dsx_done
@@op_ds2x:	call	@@trys_imm
		call	get_comma
		call	get_pound
		call	@@tryvalueint
		cmp	ebx,11b
		ja	error_smb0t3
		jmp	@@op_ds1_done


@@op_ds1set:	call	@@trys_imm		;inst d,s/#,#0..1 / inst s/#
		test	ecx,1 shl 18
		jne	@@op_dsx_done
		call	check_comma
		jne	@@op_dsx_done
		mov	eax,ecx			;get s into d
		and	ecx,0FFFFFE00h
		and	eax,1FFh
		shl	eax,9
		or	ecx,eax
		jmp	@@op_ds1x


@@op_ds1get:	call	@@tryd			;inst d,s/#,#0..1 / inst d
		call	check_comma
		jne	@@op_dsx_done
@@op_ds1x:	call	@@trys_imm
		call	get_comma
		call	get_pound
		call	@@tryvalueint
		cmp	ebx,1b
		ja	error_smb0t1
@@op_ds1_done:	shl	ebx,19
		or	ecx,ebx
@@op_dsx_done:	ret


@@op_dsj:	call	@@tryd			;inst d,s/@
		call	get_comma
		jmp	@@trys_rel


@@op_ls:	mov	edx,1 shl 19		;inst d/#,s/#
		call	@@tryd_imm
		call	get_comma
		jmp	@@trys_imm


@@op_lsj:	mov	edx,1 shl 19		;inst d/#,s/@
		call	@@tryd_imm
		call	get_comma
		jmp	@@trys_rel


@@op_dsp:	call	@@tryd			;inst d,s/#/ptra/ptrb
		call	get_comma
		call	@@chkpab
		jnc	@@trys_imm_pab
		or	ecx,edx
		ret


@@op_lsp:	mov	edx,1 shl 19		;inst d/#,s/#/ptra/ptrb
		call	@@tryd_imm
		call	get_comma
		call	@@chkpab
		jnc	@@trys_imm_pab
		or	ecx,edx
		ret


@@op_rep:	call	check_at		;rep d/#/@,s/#
		jne	@@op_ls			;if not @, handle d/#,s/#
		or	ecx,1 shl 19		;set d-immediate bit
		call	@@tryvalueint		;@, get cog/lut address
		push	ebx			;save address
		call	get_comma		;get comma
		call	@@trys_imm		;get s (may be ##)
		pop	ebx			;restore address
		cmp	[@@pass],0		;if pass 0, don't qualify address
		je	@@op_rep_pass0
		cmp	[orgh],1		;orgh or cog mode?
		je	@@op_rep_hub
		shl	ebx,2			;cog, get delta
		sub	ebx,[cog_org]
		jmp	@@op_rep_set
@@op_rep_hub:	sub	ebx,[hub_org]		;hub, get delta
@@op_rep_set:	test	bl,11b			;test common alignment
		jnz	error_rbeiooa
		shr	ebx,2			;make into rep d value
		sub	ebx,1
		cmp	ebx,1FFh		;make sure not out of range
		ja	error_rbeioor
		call	@@installd
@@op_rep_pass0:	ret


@@op_jmp:	call	check_pound		;jmp # <or> jmp d
		je	@@op_calli

		and	ecx,0F0000000h		;reg, preserve conditional bits
		or	ecx,00D60002Ch		;make 'jmp d' instruction
		call	@@tryd			;get d register
		mov	[@@effectbits],11b	;enable effects
		ret


@@op_call:	call	check_pound		;call/calla/callb # <or> call/calla/callb d
		je	@@op_calli

		mov	eax,ecx			;reg, make 'call/calla/callb d' instruction
		shr	eax,21
		and	eax,11b
		add	eax,00D60002Ch
		and	ecx,0F0000000h		;preserve conditional bits
		or	ecx,eax
		call	@@tryd			;get d register
		mov	[@@effectbits],11b	;enable effects
		ret

@@op_calli:	call	@@tryir			;determine immediate or relative address
		jnc	@@op_calli_abs

		mov	eax,[hub_org]		;cog or hub?
		cmp	[orgh],1
		je	@@op_calli_hub
		mov	eax,[cog_org]
		shl	ebx,2
@@op_calli_hub:	add	eax,4			;compute relative address
		sub	ebx,eax
		or	ecx,1 shl 20		;set relative address bit
@@op_calli_abs:	and	ebx,0FFFFFh		;install relative address
		or	ecx,ebx
		ret


@@op_calld:	call	@@tryvaluereg		;'calld 1F6h..1F9h,#{\}adr20' <or> 'calld d,s/#rel9', get d
		mov	edx,ebx			;save d
		call	get_comma		;get comma
		call	check_pound		;check for #
		je	@@op_calld_i

		call	@@tryvaluereg		;no #, 'call d,s', get s register
		and	ecx,0F0000000h		;preserve conditional bits
		or	ecx,00B200000h		;make 'calld d,s' instruction
@@op_calld_r9:	shl	edx,9			;install d
		or	ecx,edx
		or	ecx,ebx			;install s
		mov	[@@effectbits],11b	;enable effects
		ret

@@op_calld_i:	call	@@tryir			;#, determine immediate or relative address
		jc	@@op_calld_ir

		cmp	[@@pass],0		;#, immediate address, if pass 0, skip test
		je	@@op_calld_ret
		cmp	edx,1F6h		;make sure d from 1F6h to 1F9h
		jb	error_drmbpppp
		cmp	edx,1F9h
		ja	error_drmbpppp
@@op_calld_i20:	and	edx,11b			;install into mini d field
		xor	edx,10b
		shl	edx,21
		or	ecx,edx
		and	ebx,0FFFFFh		;install address
		or	ecx,ebx
@@op_calld_ret:	ret

@@op_calld_ir:	cmp	[@@pass],0		;#, relative address, if pass 0, skip test
		je	@@op_calld_ret

		cmp	[orgh],1		;cog or hub mode?
		je	@@op_calld_irh

		mov	eax,[cog_org]		;cog mode, check rel9 address
		shr	eax,2
		add	eax,1
		sub	ebx,eax
		jmp	@@op_calld_ir9

@@op_calld_irh:	mov	eax,[hub_org]		;hub mode, check rel9 address
		add	eax,4
		sub	ebx,eax
		test	ebx,11b
		jnz	@@op_calld_nr9
		sar	ebx,2

@@op_calld_ir9:	cmp	ebx,0FFh
		jg	@@op_calld_nr9
		cmp	ebx,0FFFFFF00h
		jl	@@op_calld_nr9
		and	ebx,1FFh		;make rel9 address
		and	ecx,0F0000000h		;preserve conditional bits
		or	ecx,00B240000h		;make 'calld d,#s' instruction
		jmp	@@op_calld_r9

@@op_calld_nr9:	cmp	edx,1F6h		;if 1F6h..1F9h, make 20-bit calld
		jb	error_drmbpppp
		cmp	edx,1F9h
		ja	error_drmbpppp
		or	ecx,1 shl 20		;set relative address bit in case 20-bit address
		jmp	@@op_calld_i20


@@op_jpoll:	mov	eax,ecx			;jint..jnqmt s/#
		and	eax,0FF80000h
		shr	eax,19-9
		and	ecx,0F0000000h
		or	ecx,eax
		or	ecx,0BC80000h
		jmp	@@trys_rel


@@op_loc:	call	@@tryvaluereg		;loc reg,#
		cmp	[@@pass],0
		je	@@op_locs
		cmp	ebx,1F6h		;validate reg
		jb	error_drmbpppp
		cmp	ebx,1F9h
		ja	error_drmbpppp
		and	ebx,11b
		xor	ebx,10b
		shl	ebx,21
		or	ecx,ebx
@@op_locs:	call	get_comma		;get ','
		call	get_pound		;get '#'
		call	check_back		;check for '\'
		pushf
		mov	[orgh_symbol_flag],0	;get address
		call	@@tryvalueint
		mov	al,[orgh_symbol_flag]
		cmp	ebx,0FFFFFh		;validate address
		ja	error_amnex
		popf
		je	@@op_locabs		;if '\', absolute
		cmp	ebx,400h
		jb	@@op_loccog		;	orgh	orgh_symbol_flag | address >= $400
		or	al,1			;	-----------------------------------------------
@@op_loccog:	xor	al,[orgh]		;	0	0	relative, address-(cog_org/4+1)
		jnz	@@op_locabs		;	0	1	absolute
		mov	eax,[hub_org]		;	1	0	absolute
		add	eax,4			;	1	1	relative, address-(hub_org+4)
		cmp	[orgh],1
		je	@@op_locrelh
		mov	eax,[cog_org]
		shr	eax,2
		add	eax,1
@@op_locrelh:	sub	ebx,eax			;compute relative address
		or	ecx,1 shl 20		;set relative address bit
@@op_locabs:	and	ebx,0FFFFFh		;install address
		or	ecx,ebx
		ret


@@op_aug:	call	get_pound		;get #
		call	@@tryvalueint		;get constant
		jmp	@@augcon		;insert constant bits 31..9


@@op_d:		jmp	@@tryd			;inst d


@@op_de:	call	get_element		;inst d and/or effects
		call	back_element
		cmp	al,type_asm_effect	;if asm effect first, set immediate bit to inhibit write
		jne	@@op_d
		or	ecx,1 shl 18
		ret


@@op_l:		mov	edx,1 shl 18		;inst d/#0..511
		jmp	@@tryd_imm


@@op_cz:	test	[@@effectbits],10b	;modcz/modc/modz
		jz	@@op_z			;modz?

		call	@@tryvalueint		;get cdata
		and	ebx,0Fh			;set cdata
		shl	ebx,9+4
		or	ecx,ebx

		test	[@@effectbits],01b	;modc?
		jz	@@op_c

		call	get_comma		;modcz, get comma

@@op_z:		call	@@tryvalueint		;get zdata
		and	ebx,0Fh			;set zdata
		shl	ebx,9+0
		or	ecx,ebx

@@op_c:		or	ecx,1 shl 18		;set immediate bit
		ret


@@op_pollwait:	mov	eax,ecx			;pollxxx/waitxxx <blank>
		and	eax,1FFh		;get s into d
		shl	eax,9
		or	ecx,eax
		and	ecx,0FFFFFE00h
		or	ecx,24h
		ret


@@op_getbrk:	mov	edx,1 shl 18		;getbrk d wc/wz/wcz
		call	@@tryd_imm
		jmp	@@get_wcwzwcz


@@op_pinop:	mov	edx,1 shl 18		;pinop d/#0..511 (wcz or none)
		call	@@tryd_imm
		jmp	@@get_wcz


@@op_testp:	mov	edx,1 shl 18		;testp d/#0..511 (wc/andc/orc/xorc or wz/andz/orz/xorz}
		call	@@tryd_imm
		call	@@get_corz
		shl	ebx,1
		or	ecx,ebx
		ret


@@op_pushpop:	movzx	eax,cl			;push/pop
		and	ecx,0F0000000h		;preserve conditional bits
		or	ecx,[@@pushpop+eax*4]	;or in push/pop instruction
		cmp	al,pp_popa		;get d/# or d
		jae	@@tryd
		mov	edx,1 shl 19
		jmp	@@tryd_imm

@@pushpop	dd	0C640161h		;PUSHA	D/#	-->	WRLONG	D/#,PTRA++
		dd	0C6401E1h		;PUSHB	D/#	-->	WRLONG	D/#,PTRB++
		dd	0B04015Fh		;POPA	D	-->	RDLONG	D,--PTRA
		dd	0B0401DFh		;POPB	D	-->	RDLONG	D,--PTRB


@@op_xlat:	movzx	eax,cl			;get index number
		and	ecx,0F0000000h		;preserve conditional bits
		or	ecx,[@@xlat+eax*4]	;or instruction in
		ret

@@xlat		dd	0D64002Dh		;RET
		dd	0D64002Eh		;RETA
		dd	0D64002Fh		;RETB
		dd	0B3BFFFFh		;RETI0		-->	CALLD	INB,INB		WCZ
		dd	0B3BFFF5h		;RETI1		-->	CALLD	INB,$1F5	WCZ
		dd	0B3BFFF3h		;REII2		-->	CALLD	INB,$1F3	WCZ
		dd	0B3BFFF1h		;RETI3		-->	CALLD	INB,$1F1	WCZ
		dd	0B3BFDFFh		;RESI0		-->	CALLD	INA,INB		WCZ
		dd	0B3BE9F5h		;RESI1		-->	CALLD	$1F4,$1F5	WCZ
		dd	0B3BE5F3h		;RESI2		-->	CALLD	$1F2,$1F3	WCZ
		dd	0B3BE1F1h		;RESI3		-->	CALLD	$1F0,$1F1	WCZ
		dd	0CAC0000h		;XSTOP		-->	XINIT	#0,#0


@@op_akpin:	and	ecx,0F0000000h		;akpin s/#, preserve conditional bits
		or	ecx,00C080200h		;wrpin #1,s/#
		jmp	@@trys_imm


@@op_asmclk:	mov	ebx,[clkmode]		;asmclk, check if rcfast/rcslow - TESTT _RET_ needs to be handled properly
		test	bl,10b
		jnz	@@asmclkxin
		and	ebx,1
		shl	ebx,9
		or	ecx,ebx
		or	ecx,0D640000h		;rcfast/rcslow, assemble 'hubset #0/1'
		ret

@@asmclkxin:	and	ebx,0FFFFFFFCh		;assemble 'hubset ##clkmode & $FFFFFFFC'
		stc
		call	@@augds
		push	ecx
		call	@@augret		;handle conditional field
		shl	ebx,9
		or	ecx,ebx
		or	ecx,0D640000h
		call	@@enterlong
		pop	ecx
		mov	ebx,20000000/100	;assemble 'waitx ##20_000_000/100'
		stc
		call	@@augds
		push	ecx
		call	@@augret		;handle conditional field
		shl	ebx,9
		or	ecx,ebx
		or	ecx,0D64001Fh
		call	@@enterlong
		pop	ecx
		mov	ebx,[clkmode]		;assemble 'hubset ##clkmode'
		stc
		call	@@augds
		shl	ebx,9
		or	ecx,ebx
		or	ecx,0D640000h
		ret


@@op_nop:	shr	ecx,32-4		;nop, condition is not allowed
		cmp	cl,0Fh
		jne	error_nchcor
		mov	ecx,0			;nop
		ret


@@op_debug:	call	check_debug		;DEBUG, if disabled, ignore rest of line and emit nothing
		je	@@debugon
		call	skip_to_end		;skip to end of line
		call	get_end			;get end
		pop	eax			;pop return address so no long is emitted
		jmp	@@nextline		;get next line
@@debugon:
		mov	eax,ecx			;get condition
		shr	eax,32-4		;_ret_ is okay
		jz	@@debugok
		cmp	al,0Fh			;<always> condition is okay
		je	@@debugok
		push	ecx			;some other condition, assemble a SKIP #1 before the BRK instruction
		and	ecx,0F0000000h		;isolate condition
		xor	ecx,0FD640231h		;make IF_<opposite> SKIP #1 instruction
		call	@@enterlong		;enter instruction
		pop	ecx
		or	ecx,0F0000000h		;set BRK condition to <always>
@@debugok:
		call	check_left		;check for '('
		je	@@debugleft

		or	ecx,1 shl 18		;no parameters, assemble 'BRK #0' for debugger
		call	get_end			;make sure eol
		jmp	back_element

@@debugleft:	cmp	[@@pass],0		;parameters, if pass 0, skip parameters and emit long
		jne	@@debugpass1
		jmp	skip_to_end		;skip to end of line
@@debugpass1:
		push	ecx			;pass 1
		call	ci_debug_asm		;compile debug for asm, returns BRK index in al
		pop	ecx
		movzx	eax,al			;install BRK index
		shl	eax,9
		or	ecx,eax
		or	ecx,1 shl 18		;set immediate bit
		call	get_end			;make sure eol
		jmp	back_element		;back up for assembler


@@asmlocal:	or	dl,dl			;if not local symbol, inc asm local
		jns	@@asmlocal2

		inc	[byte asm_local+3]
		cmp	[byte asm_local+3],3Ah
		jne	@@asmlocal2
		mov	[byte asm_local+3],30h

		inc	[byte asm_local+2]
		cmp	[byte asm_local+2],3Ah
		jne	@@asmlocal2
		mov	[byte asm_local+2],30h

		inc	[byte asm_local+1]
		cmp	[byte asm_local+1],3Ah
		jne	@@asmlocal2
		mov	[byte asm_local+1],30h

		inc	[byte asm_local+0]
		cmp	[byte asm_local+0],3Ah
		jne	@@asmlocal2
		mov	[byte asm_local+0],30h

		jmp	error_loxdse

@@asmlocal2:	ret


@@entersymbol:	or	edx,edx			;enter any symbol as type_dat_????
		jns	@@ret
		push	ebx
		mov	ebx,[obj_ptr]		;obj ptr in low bits
		or	ebx,0FFF00000h		;flag orgh by 0FFFh in high bits
		cmp	[orgh],1		;if orgh mode, got value
		je	@@entersymbol2
		mov	eax,[cog_org]		;get cog org in high word
		test	al,11b			;make sure long aligned
		jnz	error_csmbla
		shr	eax,2
		shl	eax,32-12
		and	ebx,000FFFFFh
		or	ebx,eax
@@entersymbol2:	mov	al,[@@size]		;adjust type by size
		mov	[byte inf_data1],al	;enter dat symbol info
		mov	[inf_data0],ebx
		mov	[inf_type],info_dat_symbol
		add	al,type_dat_byte
		call	enter_info
		test	edx,40000000h		;check for res symbol
		jz	@@entersymbol3
		mov	al,type_dat_long_res
@@entersymbol3:	call	enter_symbol2_print	;enter symbol
		pop	ebx
		ret


@@nosymbol:	or	edx,edx			;make sure no symbol
		js	error_tdcbpbas
		ret


@@coglong:	cmp	[orgh],0		;if cog mode, advance to next long
		jne	@@ret
		push	ecx
		mov	ecx,[cog_org]
		neg	ecx
		and	ecx,11b
		xor	ebx,ebx
		mov	dl,0
		call	@@enter
		pop	ecx
		ret


@@enterlong:	mov	ebx,ecx			;enter instruction in ecx
		mov	ecx,1
		mov	dl,2

@@enter:	jecxz	@@ret			;enter ebx value ecx times, using dl size

		cmp	[@@sizefit],0		;size fit enabled?
		je	@@enter2

		cmp	dl,1			;check size range
		ja	@@enter2		;long?
		jne	@@enterb		;byte?

		cmp	ebx,0FFFF8000h		;word
		jl	@@enterwerr
		cmp	ebx,0FFFFh
		jle	@@enter2
@@enterwerr:	jmp	error_wmbft

@@enterb:	cmp	ebx,0FFFFFF80h		;byte
		jl	@@enterberr
		cmp	ebx,0FFh
		jle	@@enter2
@@enterberr:	jmp	error_bmbft

@@enter2:	push	ecx
		mov	cl,dl
		mov	dh,1
		shl	dh,cl
		pop	ecx
		mov	eax,ebx
@@enter3:	call	@@enterbyte
		shr	eax,8
		dec	dh
		jnz	@@enter3
		loop	@@enter2
@@ret:		ret


@@enterbyte:	call	enter_obj		;enter byte into obj

		cmp	[orgh],0		;orgh mode?
		jne	@@enterbyteh

		inc	[cog_org]		;else, increment org
		push	eax			;limit exceeded?
		mov	eax,[cog_org_limit]
		cmp	[cog_org],eax
		pop	eax
		ja	error_cael
		ret

@@enterbyteh:	inc	[hub_org]		;else, increment org
		push	eax			;limit exceeded?
		mov	eax,[hub_org_limit]
		cmp	[hub_org],eax
		pop	eax
		ja	error_hael
		ret


@@tryvalue:	mov	bl,[@@pass]		;try operand - integer or float
		xor	bl,11b			;if second pass, must resolve
		jmp	try_value


@@tryvalueint:	mov	bl,[@@pass]		;try operand - integer only
		xor	bl,11b			;if second pass, must resolve
		jmp	try_value_int


@@getvalueint:	mov	bl,10b			;get operand - integer only
		jmp	try_value_int


@@checkinst:	cmp	al,type_asm_inst	;asm instruction? z=1 if true
		je	@@checkdone
		cmp	al,type_op		;operator alias?
		je	@@checkop
		cmp	al,type_i_flex		;spin instruction alias
		je	@@checkflex
		cmp	al,type_debug		;DEBUG ?
		je	@@gotdebug
		jmp	@@checkdone

@@checkflex:	push	eax
		mov	eax,ac_hubset		;HUBSET ?
		cmp	ebx,fc_hubset
		je	@@checkok
		mov	eax,ac_coginit		;COGINIT ?
		cmp	ebx,fc_coginit
		je	@@checkok
		mov	eax,ac_cogstop		;COGSTOP ?
		cmp	ebx,fc_cogstop
		je	@@checkok
		mov	eax,ac_cogid		;COGID ?
		cmp	ebx,fc_cogid
		je	@@checkok
		mov	eax,ac_getrnd		;GETRND ?
		cmp	ebx,fc_getrnd
		je	@@checkok
		mov	eax,ac_getct		;GETCT ?
		cmp	ebx,fc_getct
		je	@@checkok
		mov	eax,ac_wrpin		;WRPIN ?
		cmp	ebx,fc_wrpin
		je	@@checkok
		mov	eax,ac_wxpin		;WXPIN ?
		cmp	ebx,fc_wxpin
		je	@@checkok
		mov	eax,ac_wypin		;WYPIN ?
		cmp	ebx,fc_wypin
		je	@@checkok
		mov	eax,ac_akpin		;AKPIN ?
		cmp	ebx,fc_akpin
		je	@@checkok
		mov	eax,ac_rdpin		;RDPIN ?
		cmp	ebx,fc_rdpin
		je	@@checkok
		mov	eax,ac_rqpin		;RQPIN ?
		cmp	ebx,fc_rqpin
		je	@@checkok
		mov	eax,ac_locknew		;LOCKNEW ?
		cmp	ebx,fc_locknew
		je	@@checkok
		mov	eax,ac_lockret		;LOCKRET ?
		cmp	ebx,fc_lockret
		je	@@checkok
		mov	eax,ac_locktry		;LOCKTRY ?
		cmp	ebx,fc_locktry
		je	@@checkok
		mov	eax,ac_lockrel		;LOCKREL ?
		cmp	ebx,fc_lockrel
		je	@@checkok
		mov	eax,ac_cogatn		;COGATN ?
		cmp	ebx,fc_cogatn
		je	@@checkok
		mov	eax,ac_pollatn		;POLLATN ?
		cmp	ebx,fc_pollatn
		je	@@checkok
		mov	eax,ac_waitatn		;WAITATN ?
		cmp	ebx,fc_waitatn
		je	@@checkok
		mov	eax,ac_call		;CALL ?
		cmp	ebx,fc_call
		je	@@checkok
		jmp	@@checknot

@@checkop:	push	eax
		mov	eax,ac_abs		;ABS ?
		cmp	bl,op_abs
		je	@@checkok
		mov	eax,ac_encod		;ENCOD ?
		cmp	bl,op_encod
		je	@@checkok
		mov	eax,ac_decod		;DECOD ?
		cmp	bl,op_decod
		je	@@checkok
		mov	eax,ac_bmask		;BMASK ?
		cmp	bl,op_bmask
		je	@@checkok
		mov	eax,ac_ones		;ONES ?
		cmp	bl,op_ones
		je	@@checkok
		mov	eax,ac_qlog		;QLOG ?
		cmp	bl,op_qlog
		je	@@checkok
		mov	eax,ac_qexp		;QEXP ?
		cmp	bl,op_qexp
		je	@@checkok
		mov	eax,ac_sar		;SAR ?
		cmp	bl,op_sar
		je	@@checkok
		mov	eax,ac_ror		;ROR ?
		cmp	bl,op_ror
		je	@@checkok
		mov	eax,ac_rol		;ROL ?
		cmp	bl,op_rol
		je	@@checkok
		mov	eax,ac_rev		;REV ?
		cmp	bl,op_rev
		je	@@checkok
		mov	eax,ac_zerox		;ZEROX ?
		cmp	bl,op_zerox
		je	@@checkok
		mov	eax,ac_signx		;SIGNX ?
		cmp	bl,op_signx
		je	@@checkok
		mov	eax,ac_sca		;SCA ?
		cmp	bl,op_sca
		je	@@checkok
		mov	eax,ac_scas		;SCAS ?
		cmp	bl,op_scas
		je	@@checkok
		test	ebx,opc_alias		;make sure !!,&&,^^,|| are not masquerading as NOT,AND,XOR,OR
		jnz	@@checknot
		mov	eax,ac_not		;NOT ?
		cmp	bl,op_lognot
		je	@@checkok
		mov	eax,ac_and		;AND ?
		cmp	bl,op_logand
		je	@@checkok
		mov	eax,ac_or		;OR ?
		cmp	bl,op_logor
		je	@@checkok
		mov	eax,ac_xor		;XOR ?
		cmp	bl,op_logxor
		jne	@@checknot
@@checkok:	mov	ebx,eax
@@checknot:	pop	eax
@@checkdone:	ret

@@gotdebug:	mov	ebx,ac_debug		;DEBUG
		ret


@@get_wcwzwcz:	call	get_element		;get wc/wz/wcz
		cmp	al,type_asm_effect	;if not flag effect, done
		je	back_element
		jmp	error_ewcwzwcz


@@get_wcz:	call	get_element		;get wcz or nothing
		cmp	al,type_asm_effect	;if not flag effect, done
		jne	back_element
		cmp	bl,11b			;if not wcz, done
		jne	back_element
		or	ecx,11b shl 19		;got wcz, set bits
		ret


@@get_corz:	call	get_element		;get wc/andc/orc/xorc or wz/andz/orz/xorz
		cmp	al,type_asm_effect2
		je	@@get_corz_wr
		cmp	al,type_asm_effect
		jne	error_ewaox
		cmp	bl,11b
		je	error_ewaox
@@get_corz_wr:	mov	al,bl			;got one, set wc or wz bit
		and	eax,11b
		shl	eax,19
		or	ecx,eax
		shr	ebx,2			;get function into ebx (00b..11b)
		ret


@@tryd_imm:	call	check_pound		;try d operand, check for #/## (edx must hold imm bit)
		jne	@@tryd			;if no #, try d
		or	ecx,edx			;set immediate bit
		call	check_pound		;check for ##
		jne	@@tryd_imm9
		call	@@tryvalueint		;##, get 32-bit constant
		stc				;enter augd instruction
		call	@@augds
		jmp	@@installd
@@tryd_imm9:	call	@@tryvaluecon		;#, get 9-bit constant
		jmp	@@installd


@@tryd:		call	@@tryvaluereg		;try d operand
@@installd:	shl	ebx,9			;install into d field
		or	ecx,ebx
		ret


@@trys_rel:	call	check_pound		;try s operand, check for #
		jne	@@trys

		call	check_pound		;check for ##
		je	@@trys_rel32

		or	ecx,1 shl 18		;relative address, set immediate bit
		call	@@tryvalueint		;get relative address
		cmp	[@@pass],0		;if pass 0, don't qualify address
		je	@@trys_relx
		call	@@checkcross		;check that address doesn't cross between cog/lut and hub
		mov	eax,[hub_org]		;hub or cog mode?
		cmp	[orgh],1
		je	@@trys_relh
		mov	eax,[cog_org]
		shl	ebx,2
@@trys_relh:	sub	ebx,eax
		sub	ebx,4
		test	ebx,11b			;make sure alignment is same
		jnz	error_rainawi
		sar	ebx,2			;get 9 significant offset bits into s
		cmp	ebx,0FFh		;if greater than 0FFh, out of range
		jg	error_raioor
		cmp	ebx,0FFFFFF00h		;if less than -100h, out of range
		jl	error_raioor
@@trys_relx:	and	ebx,1FFh		;in range
		or	ecx,ebx			;install relative address into s field
		ret

@@trys_rel32:	or	ecx,1 shl 18		;@@ 32-bit, set immediate bit
		call	@@tryvalueint		;get relative address
		cmp	[@@pass],0		;if pass 0, don't qualify address
		je	@@trys_relx32
		call	@@checkcross		;check that address doesn't cross between cog/lut and hub
		mov	eax,[hub_org]		;hub or cog mode?
		cmp	[orgh],1
		je	@@trys_relh32
		mov	eax,[cog_org]
		shl	ebx,2
@@trys_relh32:	sub	ebx,eax
		sub	ebx,8
		test	ebx,11b			;make sure alignment is same
		jnz	error_rainawi
		sar	ebx,2			;get 18 significant offset bits into s
		and	ebx,0FFFFFh shr 2
@@trys_relx32:	clc				;enter augs instruction
		call	@@augds
		or	ecx,ebx
		ret


@@trys_imm_pab:	call	check_pound		;try s operand, check for #/## (disallow >0FFh for #)
		jne	@@trys			;if no #, try s
		or	ecx,1 shl 18		;set immediate bit
		call	check_pound		;check for ##
		je	@@trys_imm32
		call	@@tryvalueint		;#, get 8-bit constant
		cmp	ebx,0FFh		;make sure within 0FFh
		ja	error_cmbf0t255
		jmp	@@trys_immi		;install constant into s field


@@trys_imm:	call	check_pound		;try s operand, check for #/##
		jne	@@trys			;if no #, try s
		or	ecx,1 shl 18		;set immediate bit
		call	check_pound		;check for ##
		jne	@@trys_imm9
@@trys_imm32:	call	@@tryvalueint		;##, get 32-bit constant
		clc				;install augs
		call	@@augds
		jmp	@@trys_immi
@@trys_imm9:	call	@@tryvaluecon		;#, get 9-bit constant
@@trys_immi:	or	ecx,ebx			;install constant into s field
		ret


@@trys:		call	@@tryvaluereg		;try s operand
		or	ecx,ebx			;install into s field
		ret


@@tryvaluereg:	call	@@tryvalueint		;get register address
		cmp	ebx,1FFh		;make sure within 1FFh
		ja	error_rcex
		ret


@@tryvaluecon:	call	@@tryvalueint		;get register value
		cmp	ebx,1FFh		;make sure within 1FFh
		ja	error_cmbf0t511
		ret


@@augds:	push	ebx			;enter augs/augd instruction
		push	ecx
		mov	eax,0Fh			;make augs/augd
		rcl	eax,1
		shl	eax,23
		call	@@augret		;handle conditional field
		or	ecx,eax			;install augs/augd
		call	@@augcon
		call	@@enterlong
		pop	ecx
		pop	ebx
		and	ebx,1FFh
		ret

@@augcon:	mov	eax,ebx			;insert augs/augd constant
		shr	eax,9
		or	ecx,eax
		ret

@@augret:	and	ecx,0F0000000h		;if 0000b (ret) then %1111b (always)
		jnz	@@augret2
		or	ecx,0F0000000h
@@augret2:	ret


@@chkpab:	call	get_element		;check for ptra/ptrb expression, get into edx

		cmp	al,type_inc		;++(ptra/ptrb)?
		jne	@@chkpab_noti
		call	get_element
		call	@@chkpab_reg
		jne	@@chkpab_quit2
		or	bl,40h+01h		;++ptra/ptrb, set update bit, set index to +1
		jmp	@@chkpab_upd
@@chkpab_noti:
		cmp	al,type_dec		;--(ptra/ptrb)?
		jne	@@chkpab_notd
		call	get_element
		call	@@chkpab_reg
		jne	@@chkpab_quit2
		or	bl,40h+1Fh		;--ptra/ptrb, set update bit, set index to -1
		jmp	@@chkpab_upd
@@chkpab_notd:
		call	@@chkpab_reg		;ptra/ptrb(++/--)?
		jne	@@chkpab_quit

		call	check_inc		;ptra/ptrb++?
		jne	@@chkpab_notpi
		or	bl,40h+20h+01h		;ptra/ptrb++, set update and post bits, set index to +1
		jmp	@@chkpab_upd
@@chkpab_notpi:
		call	check_dec		;ptra/ptrb--?
		jne	@@chkpab_upd
		or	bl,40h+20h+1Fh		;ptra/ptrb--, set update and post bits, set index to -1
		jmp	@@chkpab_upd

@@chkpab_quit2:	call	back_element		;not (++/--)ptra/ptrb(++/--), back up
@@chkpab_quit:	call	back_element		;back up
		clc				;not a ptra/ptrb expression, c=0
		ret

@@chkpab_upd:	mov	edx,ebx			;(++/--)ptra/ptrb(++/--), install bits
		or	edx,(1 shl 18) + 100h	;set immediate bit and ptra/ptrb bit
		call	check_leftb		;check for '[' to signify index
		jne	@@chkpab_done		;if no index, done
		call	check_pound		;check for ##
		jne	@@chkpab_npp
		call	get_pound
		call	@@tryvalueint		;##, get 20-bit index value
		test	dl,40h			;if update bit set and negative number, negate index
		jz	@@chkpab_ppnu
		test	dl,10h
		jz	@@chkpab_ppnu
		neg	ebx
@@chkpab_ppnu:	and	ebx,0FFFFFh
		and	edx,1E0h
		shl	edx,20-5
		or	ebx,edx
		clc				;install augs
		call	@@augds
		or	ecx,1 shl 18		;set immediate bit
		or	ecx,ebx			;install lower 9 bits of constant
		xor	edx,edx
		jmp	@@chkpab_rb
@@chkpab_npp:	call	@@tryvalueint		;no ##, get index value
		test	dl,40h			;if update bit set, check positive number
		jz	@@chkpab_nup
		test	dl,10h
		jz	@@chkpab_pos
		cmp	ebx,1			;'--' update, index must be 1..16
		jb	@@chkpab_err4b
		cmp	ebx,16
		ja	@@chkpab_err4b
		neg	bl
		jmp	@@chkpab_ok
@@chkpab_pos:	cmp	ebx,1			;'++' update, index must be 1..16
		jb	@@chkpab_err4b
		cmp	ebx,16
		ja	@@chkpab_err4b
		and	bl,0Fh
		jmp	@@chkpab_ok
@@chkpab_nup:	cmp	ebx,-32			;no update, index must be from -32 to +31
		jae	@@chkpab_nupn
		cmp	ebx,31
		ja	@@chkpab_err6b
@@chkpab_nupn:	and	dl,0C0h
		and	bl,3Fh
		jmp	@@chkpab_or
@@chkpab_ok:	and	dl,0E0h			;install ptr index
		and	bl,1Fh
@@chkpab_or:	or	dl,bl
@@chkpab_rb:	call	get_rightb		;get ']'
@@chkpab_done:	stc				;done, c=1
		ret

@@chkpab_err6b:	call	restore_value_ptrs	;ptr index range errors
		jmp	error_picmr6b
@@chkpab_err4b:	call	restore_value_ptrs
		jmp	error_picmr116

@@chkpab_reg:	cmp	al,type_register	;check ptra/ptrb
		jne	@@chkpab_regn
		cmp	ebx,1F8h		;ptra address
		je	@@chkpab_regy
		cmp	ebx,1F9h		;ptrb address
		jne	@@chkpab_regn
@@chkpab_regy:	and	ebx,1
		shl	ebx,7
		xor	al,al			;got ptra/ptrb, z=1
@@chkpab_regn:	ret


@@tryir:	call	check_back		;check for '\' absolute override
		pushf				;try immediate or relative address
		call	@@tryvalueint
		cmp	ebx,0FFFFFh
		ja	error_amnex
		popf
		je	@@tryir_abs		;if '\' absolute override, done

		cmp	[orgh],1		;cog or hub mode?
		je	@@tryir_hub

		cmp	ebx,400h		;cog mode, absolute if >= $400
		jb	@@tryir_rel
		jmp	@@tryir_abs

@@tryir_hub:	cmp	ebx,400h		;hub mode, absolute if < $400
		jb	@@tryir_abs

@@tryir_rel:	stc				;relative address, c=1
		ret

@@tryir_abs:	clc				;absolute address, c=0
		ret


@@checkcross:	cmp	[orgh],1		;make sure relative branches do not cross cog/lut <--> hub
		je	@@checkcrossh

		cmp	ebx,400h
		jae	error_racc
		ret

@@checkcrossh:	cmp	ebx,400h
		jb	error_racc
		ret


@@enterinfo:	cmp	[@@infoflag],0		;enter any info
		je	@@ret
		cmp	[@@pass],0		;enter dat block info on first pass
		jne	@@ret
		push	[@@srcstart]
		pop	[inf_start]
		push	[source_ptr]
		pop	[inf_finish]
		push	[@@objstart]
		pop	[inf_data0]
		push	[obj_ptr]
		pop	[inf_data1]
		mov	[inf_type],info_dat
		jmp	enter_info


dbx		@@infoflag
ddx		@@srcstart
ddx		@@objstart

ddx		@@sourceptr
ddx		@@objptr
ddx		@@local
dbx		@@size
dbx		@@sizefit
dbx		@@pass

dbx		@@effectbits

dbx		orgh
ddx		orgh_offset
ddx		inline_cog_org
ddx		inline_cog_org_limit
ddx		cog_org
ddx		cog_org_limit
ddx		hub_org
ddx		hub_org_limit

dbx		ditto_flag
ddx		ditto_index
ddx		ditto_count
ddx		ditto_source_ptr
ddx		ditto_obj_ptr
;
;
; Compile sub blocks
;
compile_sub_blocks:

		cmp	[pasm_mode],1		;if pasm mode, done
		je	@@done

		mov	[@@block],block_pub	;compile pub's
		call	@@compile

		mov	[@@block],block_pri	;compile pri's
		call	@@compile

		inc	[@@sub]			;enter end offset after sub index, done
		jmp	@@enteroffset


@@compile:	call	reset_element		;reset element

@@nextblock:	mov	dl,[@@block]		;scan for pub/pri block
		call	next_block
		jc	@@done

		call	write_symbols_local	;start local symbols

		push	[source_start]		;set info source start
		pop	[inf_start]
		push	[obj_ptr]		;set info obj start
		pop	[inf_data0]

		call	get_element_obj		;get sub symbol and save value
		mov	[@@sub],ebx

		push	[source_start]		;set info sub name
		pop	[inf_data2]
		push	[source_finish]
		pop	[inf_data3]

		mov	[@@local],0		;reset local variable counter


		call	get_left		;get '('
		call	check_right		;if ')', no parameters
		je	@@noparams

@@parameter:	mov	[@@size],4		;set default parameter size
		mov	[@@type],type_loc_long	;set default parameter type
		mov	[@@value_overlay],0	;clear value overlay in case not {^}struct
		call	get_element_obj		;get unique parameter name, struct, or '^'
		call	check_con_struct_size	;struct? (eax=size)
		jne	@@paramnstr
		add	eax,11b			;struct, set size by rounding up to next long
		shr	eax,2
		shl	eax,2
		mov	[@@size],eax
		mov	[@@type],type_loc_struct
		jmp	@@paramstrid
@@paramnstr:	call	check_ptr		;check for ^byte/word/long/struct
		jne	@@paramchk
		cmp	al,type_size
		jne	@@paramstrptr
		mov	al,type_loc_byte_ptr
		add	al,bl
		mov	[@@type],al
		jmp	@@paramname
@@paramstrptr:	mov	[@@type],type_loc_struct_ptr
@@paramstrid:	shl	ebx,20
		mov	[@@value_overlay],ebx
@@paramname:	call	get_element_obj		;get unique parameter name
@@paramchk:	cmp	al,type_undefined
		jne	error_eaupn
		call	backup_symbol		;enter local symbol
		mov	al,[@@type]
		mov	ebx,[@@local]
		or	ebx,[@@value_overlay]
		call	enter_symbol2_print
		mov	eax,[@@size]
		add	[@@local],eax
		call	get_comma_or_right	;get comma or ')'
		je	@@parameter
@@noparams:

		call	check_colon		;check for ':' to signify result(s)
		jne	@@noresults

@@result:	mov	[@@size],4		;set default result size
		mov	[@@type],type_loc_long	;set default result type
		mov	[@@value_overlay],0	;clear value overlay in case not struct
		call	get_element_obj		;get unique result name or struct
		call	check_con_struct_size	;struct? (eax=size)
		jne	@@resultnstr
		add	eax,11b			;struct, set size by rounding up to next long
		shr	eax,2
		shl	eax,2
		mov	[@@size],eax
		mov	[@@type],type_loc_struct
		jmp	@@resultstrid
@@resultnstr:	call	check_ptr		;check for ^byte/word/long/struct
		jne	@@resultchk
		cmp	al,type_size
		jne	@@resultstrptr
		mov	al,type_loc_byte_ptr
		add	al,bl
		mov	[@@type],al
		jmp	@@resultname
@@resultstrptr:	mov	[@@type],type_loc_struct_ptr
@@resultstrid:	shl	ebx,20
		mov	[@@value_overlay],ebx
@@resultname:	call	get_element_obj		;get unique result name
@@resultchk:	cmp	al,type_undefined
		jne	error_eaurn
		call	backup_symbol		;enter local symbol
		mov	al,[@@type]
		mov	ebx,[@@local]
		or	ebx,[@@value_overlay]
		call	enter_symbol2_print
		mov	eax,[@@size]
		add	[@@local],eax
		call	check_comma		;check for comma
		je	@@result
@@noresults:

		push	[@@local]		;set local variable base
		pop	[@@localvar]

		call	get_pipe_or_end		;get pipe or end
		jne	@@novariables


@@variable:	mov	[@@size],4		;set default variable size
		mov	[@@type],type_loc_long	;set default variable type
		mov	[@@value_overlay],0	;clear value overlay in case not struct

		call	get_element_obj		;get alignw/alignl, {^}byte/word/long/struct, and/or unique variable name

		call	check_align		;alignw/alignl?
		jne	@@noalign
		test	[@@local],ecx
		jz	@@aligned
		or	[@@local],ecx
		inc	[@@local]
@@aligned:	call	get_element_obj
@@noalign:
		cmp	al,type_size		;byte/word/long?
		jne	@@varnotsize
		mov	al,type_loc_byte
		add	al,bl
		mov	[@@type],al
		mov	cl,bl
		mov	eax,1
		shl	eax,cl
		mov	[@@size],eax
		jmp	@@varname
@@varnotsize:
		call	check_con_struct_size	;struct? (eax=size)
		jne	@@varnotstruct
		mov	[@@size],eax
		mov	[@@type],type_loc_struct
		jmp	@@varstructid
@@varnotstruct:
		call	check_ptr		;^byte/word/long/struct?
		jne	@@varnamechk
		cmp	al,type_size
		jne	@@varstructptr
		mov	al,type_loc_byte_ptr
		add	al,bl
		mov	[@@type],al
		jmp	@@varname
@@varstructptr:	mov	[@@type],type_loc_struct_ptr
@@varstructid:	shl	ebx,20
		mov	[@@value_overlay],ebx

@@varname:	call	get_element_obj		;get unique variable name
@@varnamechk:	cmp	al,type_undefined
		jne	error_eauvnsa
		call	backup_symbol		;enter local symbol
		mov	al,[@@type]
		mov	ebx,[@@local]
		or	ebx,[@@value_overlay]
		call	enter_symbol2_print

		mov	ebx,1			;if no [count] specified, use 1
		call	check_leftb		;'['?
		jne	@@nocount		;(already disallowed for ^byte/word/long/struct)
		call	get_value_int		;get count
		cmp	ebx,method_locals_limit
		ja	@@error_loxlve
		call	get_rightb		;get ']'
@@nocount:
		mov	eax,[@@size]		;update local variable pointer
		mul	ebx
		or	edx,edx
		jnz	@@error_loxlve
		cmp	eax,method_locals_limit
		jae	@@error_loxlve
		xchg	[@@local],eax
		add	[@@local],eax
		cmp	[@@local],method_locals_limit
		jae	@@error_loxlve
		cmp	eax,method_locals_limit
		jae	@@error_loxlve

		call	get_comma_or_end	;get comma or end
		je	@@variable		;if comma, get next variable
@@novariables:

		call	@@enteroffset		;enter sub offset into index

		mov	eax,[@@local]		;compile rfvar for local variables
		sub	eax,[@@localvar]
		add	eax,11b			;round up to long
		shr	eax,2
		call	compile_rfvar

		mov	eax,[@@sub]		;set number of results for method
		shr	eax,20
		and	eax,0Fh
		mov	[sub_results],eax

		call	compile_top_block	;compile top instruction block

		push	[source_ptr]		;set info source finish
		pop	[inf_finish]
		push	[obj_ptr]		;set info obj finish
		pop	[inf_data1]
		cmp	[@@block],block_pub	;set info type
		mov	eax,info_pub
		je	@@pubtype
		mov	eax,info_pri
@@pubtype:	mov	[inf_type],eax
		call	enter_info		;enter info

		call	reset_symbols_local	;cancel local symbols
		call	write_symbols_main

		jmp	@@nextblock		;get next PUB/PRI block

@@done:		ret


@@error_loxlve:	jmp	error_loxlve

@@enteroffset:	mov	ebx,[@@sub]		;enter offset into index
		and	ebx,0FFFFFh
		mov	eax,[obj_ptr]
		or	[dword obj+ebx*4],eax
		ret


dbx		@@type
ddx		@@size
ddx		@@value_overlay
dbx		@@block
ddx		@@sub
ddx		@@local
ddx		@@localvar
;
;
; Compile obj data
;
compile_obj_blocks:

		cmp	[pasm_mode],1		;if pasm mode, done
		je	@@done

		call	pad_obj_long		;pad obj to next long alignment

		xor	ebx,ebx			;reset file counter

@@file:		cmp	ebx,[obj_files]		;if no more files, modify index
		je	@@filesdone

		mov	esi,[obj_offsets+ebx*4]	;get obj data address
		add	esi,offset obj_data

		mov	eax,[obj_ptr]		;set objptr to current
		mov	[@@objptr+ebx*4],eax

		lodsd				;get vsize and set objvar
		mov	[@@objvar+ebx*4],eax

		lodsd				;get psize and append obj bytes
		mov	ecx,eax
@@insert:	lodsb
		call	enter_obj
		loop	@@insert

		inc	ebx			;inc file counter
		jmp	@@file			;get next obj
@@filesdone:

		mov	ecx,[obj_count]		;get number of objects in index
		jecxz	@@done

		lea	edi,[obj]		;get start of object index

@@index:	mov	ebx,[edi]		;get file number from index

		mov	eax,[@@objptr+ebx*4]	;write obj offset to index
		stosd

		mov	eax,[var_ptr]		;write var offset to index
		stosd

		mov	eax,[@@objvar+ebx*4]	;update var pointer, check limit
		add	[var_ptr],eax
		cmp	[var_ptr],obj_size_limit
		ja	error_tmvsid

		loop	@@index			;handle next object

@@done:		ret


ddx		@@objptr,files_limit
ddx		@@objvar,files_limit
;
;
; Distill obj blocks
;
distill_obj_blocks:

		cmp	[pasm_mode],1		;if pasm mode, exit
		je	@@done

		jmp	distill_objects

@@done:		ret
;
;
; Build struct-definition record
;
;   get_element ready to get '(' or '='
;   struct_def_ptr must point to offset in struct_def of next struct definition
;
; struct_name = existing_struct_name
;
; struct_name({byte/word/long/struct} member_name{[count]}, ...)
;
;	struct element
;	--------------
;	type = type_con_struct
;	value = struct id
;
;	struct record
;	-------------
;	word: size_of_struct_record (including this word)
;	long: size_of_struct_memory
;	member record(s)
;	    long: member offset address
;	    byte: type (0=byte, 1=word, 2=long, 3=struct + struct_record)
;	    byte: member_name length
;	    byte(s): "member_name"
;	    byte: 1 if another member, 0 if end of record
;
build_struct_record:

		call	check_equal			;check for '='
		jne	@@notassign
		call	get_element_obj			;got '=', get type_con_struct
		cmp	al,type_con_struct
		jne	error_eaesn
		jmp	@@enter_struct			;copy other struct into this struct
@@notassign:

		call	check_left			;get '('
		jne	error_eeqol

		mov	eax,[struct_def_ptr]		;save start address for size patching
		mov	[@@start],eax

		mov	ebx,0
		call	@@enter_word			;reserve space for size_of_struct_record patch
		call	@@enter_long			;reserve space for size_of_struct_memory patch

		mov	[@@offset],0			;reset offset address

@@member:	mov	ebx,[@@offset]			;(another) member, enter offset
		call	@@enter_long

		call	get_element_obj			;get byte/word/long/struct or name

		cmp	al,type_size			;byte/word/long?
		jne	@@notsize
		call	@@enter_byte			;enter 0/1/2 for byte/word/long
		mov	cl,bl				;size is 1/2/4
		mov	ebx,1
		shl	ebx,cl
		mov	[@@size],ebx
		jmp	@@getname
@@notsize:
		cmp	al,type_con_struct		;struct name?
		jne	@@notstruct
		push	ebx				;save id of struct record
		mov	bl,3				;enter 3 for struct
		call	@@enter_byte
		pop	ebx
		call	@@enter_struct			;copy other struct into this struct
		jmp	@@getname
@@notstruct:
		mov	bl,2				;no byte/word/long/struct, default to long
		call	@@enter_byte			;enter 2 for long
		mov	[@@size],4			;size is 4
		call	back_element			;back up to get name again

@@getname:	call	get_symbol			;get member name
		jc	error_eas
		lea	esi,[symbol]			;enter member name
		call	@@enter_name

		mov	ebx,1				;if no [count] specified, use 1
		call	check_leftb			;'['?
		jne	@@gotcount
		call	get_value_int			;get count
		cmp	ebx,1				;check instance count >= 1
		jl	error_iccbl
		je	@@justone			;if more than one instance..
		cmp	[@@size],0FFFFh			;..make sure indexed struct <= $FFFF bytes
		ja	error_iscexb
		cmp	ebx,10000h			;ensure instance count <= $10000 (0..$FFFF)
		ja	error_icce
@@justone:	call	get_rightb			;get ']'
@@gotcount:
		mov	eax,[@@size]			;multiply instance count by size
		mul	ebx
		or	edx,edx
		jnz	@@error_sehr
		cmp	eax,obj_size_limit
		ja	@@error_sehr
		add	[@@offset],eax			;update offset
		cmp	[@@offset],obj_size_limit
		jae	@@error_sehr

		call	get_comma_or_right		;get comma or ')'
		mov	bl,1
		je	@@more
		mov	bl,0
@@more:		call	@@enter_byte			;enter 1 if more or 0 if done
		cmp	bl,1
		je	@@member

		mov	eax,[@@start]			;make patches
		mov	ebx,[struct_def_ptr]		;patch size_of_struct_record
		sub	ebx,eax
		mov	[word struct_def+eax],bx
		mov	ebx,[@@offset]			;patch size_of_struct_memory
		mov	[dword struct_def+2+eax],ebx

		ret


@@error_sehr:	jmp	error_sehr			;error, structure exceeds hub range


@@enter_struct:	mov	eax,[struct_id_to_def+ebx*4]	;point to struct record (ebx = struct id)
		movzx	ecx,[word struct_def+eax]	;get struct record size
		mov	ebx,[dword struct_def+2+eax]	;get struct size
		mov	[@@size],ebx
@@entersb:	mov	bl,[struct_def+eax]		;enter other struct record into this struct record
		call	@@enter_byte
		inc	eax
		loop	@@entersb
		ret

@@enter_name:	mov	bl,cl				;enter name length
		call	@@enter_byte
@@enter_name2:	lodsb					;enter name characters
		mov	bl,al
		call	@@enter_byte
		loop	@@enter_name2
		ret

@@enter_long:	call	@@enter_word
		ror	ebx,16
		call	@@enter_word
		ror	ebx,16
		ret

@@enter_word:	call	@@enter_byte
		xchg	bl,bh
		call	@@enter_byte
		xchg	bl,bh
		ret

@@enter_byte:	push	eax
		mov	eax,[struct_def_ptr]
		cmp	eax,struct_def_limit
		je	error_dsdle
		mov	[struct_def+eax],bl
		inc	[struct_def_ptr]
		pop	eax
		ret


ddx		@@start
ddx		@@offset
ddx		@@size
;
;
; Collapse DEBUG data
;
collapse_debug_data:

		cmp	[debug_mode],0		;if not debug mode, exit
		je	@@done

		cmp	[obj_stack_ptr],1	;if not top recursion level, exit
		jne	@@done

		xor	edx,edx			;find first empty debug table entry

@@scan:		cmp	[word debug_data+edx],0
		jne	@@next

		movzx	ecx,[word debug_data]	;collapse space between debug table and debug data
		sub	ecx,200h
		jecxz	@@empty
		lea	esi,[debug_data+200h]
		lea	edi,[debug_data+edx]
	rep	movsb
@@empty:
		mov	eax,200h		;adjust pointers downward
		sub	eax,edx
@@adjust:	sub	edx,2
		js	@@done
		sub	[word debug_data+edx],ax
		jmp	@@adjust

@@next:		add	edx,2
		cmp	edx,200h
		jne	@@scan
@@done:
		cmp	[word debug_data],debug_size_limit	;make sure data fits
		ja	error_dditl

		ret
;
;
; Compile final touches
;
compile_final:	mov	[size_flash_loader],flash_loader_end-flash_loader	;set size_flash_loader

		mov	[size_interpreter],0	;size_interpreter = 0

		mov	eax,[obj_ptr]		;size_obj = obj_ptr
		mov	[size_obj],eax

		mov	[size_var],0		;size_var = 0

		cmp	[pasm_mode],1		;if pasm mode, exit
		je	@@done


		mov	[size_interpreter],interpreter_end-interpreter		;set size_interpreter

		mov	edx,[obj_ptr]		;remember obj_ptr

		mov	al,0			;append dummy checksum
		call	enter_obj

		lea	esi,[pubcon_list]	;append pub/con list
		mov	ecx,[pubcon_list_size]
@@list:		lodsb
		call	enter_obj
		loop	@@list

		mov	eax,8			;move object upwards to accommodate vsize and psize longs
		call	move_obj_up

		mov	eax,[var_ptr]		;insert vsize
		mov	[dword obj+0],eax
		mov	[size_var],eax		;set size_var

		mov	[dword obj+4],edx	;insert psize
		mov	[size_obj],edx		;set size_obj

		lea	esi,[obj]		;compute checksum
		mov	ecx,[obj_ptr]
		mov	ah,0
@@crc:		lodsb
		sub	ah,al
		loop	@@crc

		mov	[obj+8+edx],ah		;insert checksum (+8 accommodates vsize and psize longs)

@@done:		ret
;
;
; Determine download baud and debug pins and baud
;
determine_bauds_pins:

		lea	esi,[@@symlbaud]	;check for 'download_baud' symbol
		call	check_setup_symbol
		ja	error_downbaud		;if defined (c=0) and not integer (z=0), then error
		jc	@@nosymlbaud
		mov	[download_baud],ebx
@@nosymlbaud:
		lea	esi,[@@sympin]		;check for 'debug_pin' symbol
		call	check_setup_symbol
		ja	error_debugpin		;if defined (c=0) and not integer (z=0), then error
		jnc	@@gotsympintx
		lea	esi,[@@sympintx]	;check for 'debug_pin_tx' symbol
		call	check_setup_symbol
		ja	error_debugptx		;if defined (c=0) and not integer (z=0), then error
		jnc	@@gotsympintx
		mov	bl,62			;not defined, use 62
@@gotsympintx:	and	bl,3Fh
		mov	[debug_pin_tx],bl

		lea	esi,[@@sympinrx]	;check for 'debug_pin_rx' symbol
		call	check_setup_symbol
		ja	error_debugprx		;if defined (c=0) and not integer (z=0), then error
		jnc	@@gotsympinrx
		mov	bl,63			;not defined, use 63
@@gotsympinrx:	and	bl,3Fh
		mov	[debug_pin_rx],bl

		lea	esi,[@@symdbaud]	;check for 'debug_baud' symbol
		call	check_setup_symbol
		ja	error_debugbaud		;if defined (c=0) and not integer (z=0), then error
		jnc	@@gotsymdbaud
		mov	ebx,[download_baud]	;not defined, use download_baud
@@gotsymdbaud:	mov	[debug_baud],ebx

		mov	ecx,-1			;check for host-side symbols
		lea	esi,[@@symleft]
		lea	edi,[debug_left]
		call	@@hostsymbol
		lea	esi,[@@symtop]
		lea	edi,[debug_top]
		call	@@hostsymbol
		lea	esi,[@@symwidth]
		lea	edi,[debug_width]
		call	@@hostsymbol
		lea	esi,[@@symheight]
		lea	edi,[debug_height]
		call	@@hostsymbol

		xor	ecx,ecx
		lea	esi,[@@symdisleft]
		lea	edi,[debug_display_left]
		call	@@hostsymbol
		lea	esi,[@@symdistop]
		lea	edi,[debug_display_top]
		call	@@hostsymbol
		lea	esi,[@@symlog]
		lea	edi,[debug_log_size]
		call	@@hostsymbol
		lea	esi,[@@symoff]
		lea	edi,[debug_windows_off]
		call	@@hostsymbol

		ret


@@hostsymbol:	call	check_setup_symbol	;check for host-side symbol
		jnc	@@hostsymbolok
		mov	ebx,ecx
@@hostsymbolok:	mov	[edi],ebx
		ret


@@symlbaud:	db	'DOWNLOAD_BAUD',0

@@sympin:	db	'DEBUG_PIN',0		;same purpose as debug_pin_tx
@@sympintx:	db	'DEBUG_PIN_TX',0
@@sympinrx:	db	'DEBUG_PIN_RX',0
@@symdbaud:	db	'DEBUG_BAUD',0

@@symleft:	db	'DEBUG_LEFT',0
@@symtop:	db	'DEBUG_TOP',0
@@symwidth:	db	'DEBUG_WIDTH',0
@@symheight:	db	'DEBUG_HEIGHT',0
@@symdisleft:	db	'DEBUG_DISPLAY_LEFT',0
@@symdistop:	db	'DEBUG_DISPLAY_TOP',0
@@symlog:	db	'DEBUG_LOG_SIZE',0
@@symoff:	db	'DEBUG_WINDOWS_OFF',0
;
;
; Determine DEBUG enables
;
determine_debug_enables:

		lea	esi,[@@debug_disable]			;look up DEBUG_DISABLE symbol
		call	check_setup_symbol
		mov	cl,0					;default to not disabled
		jc	@@notdisabled				;if undefined, not disabled
		jne	error_ddcobd				;if not integer, error
		or	ebx,ebx					;if not zero, enabled
		jz	@@notdisabled
		mov	cl,1					;not zero, disabled
@@notdisabled:	mov	[debug_disable],cl

		lea	esi,[@@debug_mask]			;look up DEBUG_MASK symbol
		call	check_setup_symbol
		mov	cl,0					;default to debug mask undefined
		jc	@@undefined				;undefined?
		jne	error_dmcobd				;if not integer, error
		mov	cl,1					;debug mask defined
		mov	[debug_mask],ebx			;set debug mask
@@undefined:	mov	[debug_mask_defined],cl

		ret



@@debug_disable:db	'DEBUG_DISABLE',0
@@debug_mask:	db	'DEBUG_MASK',0


dbx		debug_disable
dbx		debug_mask_defined
ddx		debug_mask
;
;
; Check for setup-related symbol
; esi must point to symbol name
; c=1 if undefined, else ebx=value and z=0 if not integer constant
;
check_setup_symbol:

		push	ecx			;check if symbol defined
		push	edi
		lea	edi,[symbol]
		mov	ecx,symbol_size_limit+1
	rep	movsb
		call	find_symbol
		cmp	al,type_undefined
		stc				;c=1 if undefined
		je	@@nosymbol
		cmp	al,type_con_int
		clc				;c=0 if defined, z=0 if not integer constant
@@nosymbol:	pop	edi
		pop	ecx
		ret
;
;
; Insert interpreter
;
insert_interpreter:

		mov	eax,[size_obj]		;adjust obj_ptr to trim off pub/con list
		add	eax,8			;(+8 preserves vsize and psize longs)
		mov	[obj_ptr],eax

		mov	edx,0			;determine index of first pub
@@findpub:	mov	eax,[dword obj+8+edx*8]
		or	eax,eax
		js	@@gotpub
		inc	edx
		jmp	@@findpub
@@gotpub:	shl	edx,1+20		;get index into edx[31:20]

		mov	eax,[size_interpreter]	;move object upwards to accommodate interpreter
		sub	eax,8			;(-8 eliminates vsize and psize longs)
		call	move_obj_up

		lea	esi,[interpreter]	;install interpreter
		lea	edi,[obj]
		mov	ecx,[size_interpreter]
	rep	movsb

		mov	eax,[size_interpreter]	;set pbase_init
		mov	[dword obj+@@pbase_init],eax

		add	eax,[size_obj]		;set vbase_init
		or	edx,eax			;index of first pub in vbase_init[31:20]
		mov	[dword obj+@@vbase_init],edx

		add	eax,[size_var]		;set dbase_init
		mov	[dword obj+@@dbase_init],eax

		add	eax,400h		;ensure dbase has $100 longs of stack headroom

		cmp	[debug_mode],0		;account for debugger
		je	@@nodebug
		add	eax,4000h
@@nodebug:
		cmp	eax,obj_size_limit	;verify that everything fits
		jae	error_pex

		mov	eax,[size_var]		;set var_longs
		add	eax,400h		;include stack headroom so that first pub's params are cleared
		shr	eax,2
		dec	eax
		mov	[dword obj+@@var_longs],eax

		mov	eax,[clkmode]		;set clkmode_hub
		mov	[dword obj+@@clkmode_hub],eax

		mov	eax,[clkfreq]		;set clkfreq_hub
		mov	[dword obj+@@clkfreq_hub],eax

		cmp	[debug_mode],0		;if not debug mode, force NOP instructions
		jne	@@debugmode
		mov	[dword obj+@@debugnop+0],0
		mov	[dword obj+@@debugnop+4],0
		mov	[dword obj+@@debugnop+8],0
		jmp	@@notdebugmode
@@debugmode:	movzx	eax,[debug_pin_rx]	;debug mode, install debug_pin_rx into instructions
		or	[dword obj+@@debugnop+4],eax
		shl	eax,9
		or	[dword obj+@@debugnop+0],eax
		or	[dword obj+@@debugnop+8],eax
@@notdebugmode:
		ret


@@pbase_init	=	30h
@@vbase_init	=	34h
@@dbase_init	=	38h
@@var_longs	=	3Ch
@@clkmode_hub	=	40h
@@clkfreq_hub	=	44h
@@debugnop	=	0F2Ch

interpreter:	include	"Spin2_interpreter.inc"
interpreter_end:
;
;
; Insert debugger
;
insert_debugger:

		test	[clkmode],10b			;make sure crystal/clock mode
		jz	@@error
		cmp	[clkfreq],10000000		;make sure >= 10 MHz
		jae	@@ok
@@error:	jmp	error_debugclk
@@ok:

		mov	edx,[obj_ptr]			;get obj_ptr (application size)

		movzx	eax,[word debug_data]		;move program upwards to accommodate debugger and debug data
		add	eax,debugger_end-debugger
		call	move_obj_up

		lea	esi,[debugger]			;install debugger
		lea	edi,[obj]
		mov	ecx,debugger_end-debugger
	rep	movsb

		lea	esi,[debug_data]		;install debugger data
		lea	edi,[obj + (debugger_end-debugger)]
		movzx	ecx,[word debug_data]
	rep	movsb

		mov	[dword obj+@@_appsize_],edx	;install _appsize_

		mov	eax,[clkfreq]			;install _clkfreq_
		mov	[dword obj+@@_clkfreq_],eax

		mov	eax,[clkmode]			;install _clkmode2_
		mov	[dword obj+@@_clkmode2_],eax

		and	al,0FCh				;install _clkmode1_
		mov	[dword obj+@@_clkmode1_],eax

		lea	esi,[@@symcogs]			;check for 'debug_cogs' symbol
		call	check_setup_symbol
		jc	@@nosymcogs
		jne	error_debugcog
		mov	[obj+@@_hubset_],bl
@@nosymcogs:
		lea	esi,[@@symcoginit]		;check for 'debug_coginit' symbol
		call	check_setup_symbol
		jc	@@nosymcoginit
		mov	[dword obj+@@_brkcond_],110h
@@nosymcoginit:
		lea	esi,[@@symmain]			;check for 'debug_main' symbol
		call	check_setup_symbol
		jc	@@nosymmain
		mov	[dword obj+@@_brkcond_],001h
@@nosymmain:
		lea	esi,[@@symdelay]		;check for 'debug_delay' symbol
		call	check_setup_symbol
		jc	@@nosymdelay
		jne	error_debugdly
		mov	eax,[clkfreq]
		xor	edx,edx
		mov	ecx,1000
		div	ecx
		mul	ebx
		or	edx,edx				;limit to 0FFFFFFFFh
		jz	@@symdelayok
		mov	eax,0FFFFFFFFh
@@symdelayok:	mov	[dword obj+@@_delay_],eax
@@nosymdelay:
		mov	al,[debug_pin_tx]		;set _txpin_
		mov	[obj+@@_txpin_],al

		mov	al,[debug_pin_rx]		;set _rxpin_
		mov	[obj+@@_rxpin_],al

		mov	eax,[debug_baud]		;install _baud_
		mov	[dword obj+@@_baud_],eax

		lea	esi,[@@symtimestamp]		;check for 'debug_timestamp' symbol
		call	check_setup_symbol
		jc	@@nosymstamp
		or	[obj+@@_rxpin_+3],80h		;indicate timestamp in msb of _rxpin_
@@nosymstamp:
		ret


@@symcogs:	db	'DEBUG_COGS',0
@@symcoginit:	db	'DEBUG_COGINIT',0
@@symmain:	db	'DEBUG_MAIN',0
@@symdelay:	db	'DEBUG_DELAY',0
@@symtimestamp:	db	'DEBUG_TIMESTAMP',0

@@_clkfreq_	=	0D4h
@@_clkmode1_	=	0D8h
@@_clkmode2_	=	0DCh
@@_delay_	=	0E0h
@@_appsize_	=	0E4h
@@_hubset_	=	0E8h
@@_brkcond_	=	11Ch
@@_txpin_	=	140h
@@_rxpin_	=	144h
@@_baud_	=	148h

debugger:	include "Spin2_debugger.inc"
debugger_end:
;
;
; Insert clock setter
;
insert_clock_setter:

		lea	esi,[@@sym]				;look up _AUTOCLK symbol
		call	check_setup_symbol
		jc	@@continue				;if undefined, proceed
		jne	error_acobd				;if not integer, error
		or	ebx,ebx					;if zero, don't insert clock setter
		je	@@done
@@continue:

		cmp	[clkmode],00b				;if RCFAST mode, nothing to do
		je	@@done

		mov	eax,clock_setter_end-clock_setter	;move program upwards to accommodate clock setter
		call	move_obj_up

		lea	esi,[clock_setter]			;install clock setter
		lea	edi,[obj]
		mov	ecx,clock_setter_end-clock_setter
	rep	movsb

		cmp	[clkmode],01b				;NOP unneeded instructions
		jne	@@notrcslow
		mov	[dword obj+@@_ext1_],0			;RCSLOW
		mov	[dword obj+@@_ext2_],0
		mov	[dword obj+@@_ext3_],0
		jmp	@@nopdone
@@notrcslow:	mov	[dword obj+@@_rcslow_],0		;not RCSLOW
@@nopdone:
		mov	eax,[clkmode]				;install _clkmode2_
		mov	[dword obj+@@_clkmode2_],eax

		and	al,0FCh					;install _clkmode1_
		mov	[dword obj+@@_clkmode1_],eax

		mov	eax,[obj_ptr]				;install _appblocks_
		shr	eax,9+2
		inc	eax
		mov	[dword obj+@@_appblocks_],eax

@@done:		ret


@@sym:		db	'_AUTOCLK',0


@@_ext1_	=	000h
@@_ext2_	=	004h
@@_ext3_	=	008h
@@_rcslow_	=	028h
@@_clkmode1_	=	034h
@@_clkmode2_	=	038h
@@_appblocks_	=	03Ch

clock_setter:	include	"clock_setter.inc"
clock_setter_end:
;
;
; Insert flash loader
;
insert_flash_loader:

		call	pad_obj_long			;pad obj to next long alignment for checksum computation

		mov	eax,[size_flash_loader]		;move program upwards to accommodate flash loader
		call	move_obj_up

		lea	esi,[flash_loader]		;install flash loader
		lea	edi,[obj]
		mov	ecx,eax
	rep	movsb

		cmp	[debug_mode],0			;if not debug mode, force NOP instruction at WRPIN
		jne	@@debugmode
		mov	[dword obj+@@_debugnop_],0
		jmp	@@notdebugmode
@@debugmode:	mov	al,[debug_pin_tx]		;debug mode, install debug_pin_tx into WRPIN
		or	[obj+@@_debugnop_],al
@@notdebugmode:
		mov	ecx,[obj_ptr]			;compute negative sum of all data
		shr	ecx,2
		mov	ebx,0
		lea	esi,[obj]
@@sum:		lodsd
		sub	ebx,eax
		loop	@@sum

		mov	[dword obj+@@_checksum_],ebx	;insert checksum into loader

		ret


@@_checksum_	=	04h
@@_debugnop_	=	08h

flash_loader:	include	"flash_loader.inc"
flash_loader_end:
;
;
; Make flash file
;
make_flash_file:

		call	pad_obj_long			;pad obj to next long alignment

		mov	edx,[obj_ptr]			;get number of application longs
		shr	edx,2

		mov	eax,@@loader_size		;move program upwards to accommodate flash loader
		call	move_obj_up

		lea	edi,[obj]			;install flash loader
		lea	esi,[flash_loader+@@loader_offset]
		mov	ecx,@@loader_size
	rep	movsb

		mov	eax,edx				;get number of app longs
		lea	edi,[obj+@@app_longs]
		stosd					;set app_longs
		stosd					;set app_longs2

		lea	esi,[obj+@@loader_size]		;compute app checksum
		mov	ecx,edx
		xor	ebx,ebx
@@sumapp:	lodsd
		sub	ebx,eax
		loop	@@sumapp
		mov	eax,ebx
		stosd					;set app_sum

		lea	esi,[obj]			;compute loader checksum
		mov	ecx,100h
		xor	ebx,ebx
@@sumloader:	lodsd
		sub	ebx,eax
		loop	@@sumloader
		mov	eax,ebx
		stosd					;set loader_sum

		mov	ecx,100h*4			;if less than 100h longs, pad to 100h
		sub	ecx,[obj_ptr]
		jbe	@@nopad
		mov	al,0
@@pad:		call	enter_obj
		loop	@@pad
@@nopad:
		ret


@@loader_offset	=	160h
@@loader_size	=	1F0h - @@loader_offset

@@app_longs	=	@@loader_size - 10h
@@app_longs2	=	@@loader_size - 0Ch
@@app_sum	=	@@loader_size - 08h
@@loader_sum	=	@@loader_size - 04h
;
;
; Move obj block upward by eax bytes (reverse move)
;
move_obj_up:	push	ecx
		push	esi
		push	edi

		lea	esi,[obj]		;get pointers
		mov	edi,esi
		add	edi,eax
		mov	ecx,[obj_ptr]
		add	esi,ecx
		dec	esi
		add	edi,ecx
		dec	edi

		add	[obj_ptr],eax		;make sure within obj_size_limit
		cmp	[obj_ptr],obj_size_limit
		ja	error_pex

		std				;move obj upwards
	rep	movsb
		cld

		pop	edi
		pop	esi
		pop	ecx
		ret
;
;
; Pad obj to next long alignment
;
pad_obj_long:	push	eax

@@align:	test	[obj_ptr],11b
		jz	@@aligned
		mov	al,0
		call	enter_obj
		jmp	@@align
@@aligned:
		pop	eax
		ret
;
;
; Point to first con block
;
point_to_con:	call	reset_element		;reset element

		mov	dl,block_con		;scan for con block
		call	next_block
		jc	@@exit			;if not found, exit

		push	[source_start]		;else, set source pointers
		pop	[source_finish]

@@exit:		ret
;
;
; Determine clock mode and frequency
;
determine_clock:

		lea	esi,[@@clkmode_]	;look for CLKMODE_ symbol (shouldn't exist)
		call	@@findsymbol

		lea	esi,[@@clkfreq_]	;look for CLKFREQ_ symbol (shouldn't exist)
		call	@@findsymbol

		lea	esi,[@@_errfreq]	;look for _ERRFREQ symbol
		call	@@findsymbol
		mov	[@@errfreq],ebx

		lea	esi,[@@_clkfreq]	;look for _CLKFREQ symbol
		call	@@findsymbol
		mov	[@@clkfreq],ebx

		lea	esi,[@@_xtlfreq]	;look for _XTLFREQ symbol
		call	@@findsymbol
		mov	[@@xtlfreq],ebx

		lea	esi,[@@_xinfreq]	;look for _XINFREQ symbol
		call	@@findsymbol
		mov	[@@xinfreq],ebx

		lea	esi,[@@_rcfast]		;look for _RCFAST symbol
		call	@@findsymbol

		lea	esi,[@@_rcslow]		;look for _RCSLOW symbol
		call	@@findsymbol


		mov	al,[@@flags]		;determine setup (eight flags in @@flags, so no need to mask)

		test	al,11000000b		;make sure neither CLKMODE_ nor CLKFREQ_ were declared
		jnz	error_cccbd

		mov	ah,al			;flags in al and ah
		and	ah,011111b		;hide _ERRFREQ in ah to reduce comparisons

		cmp	ah,010000b		;_CLKFREQ ?		+ _ERRFREQ optional
		je	@@clk

		cmp	ah,011000b		;_CLKFREQ + _XTLFREQ ?	+ _ERRFREQ optional
		je	@@clk_xtl

		cmp	ah,010100b		;_CLKFREQ + _XINFREQ ?	+ _ERRFREQ optional
		je	@@clk_xin

		cmp	al,001000b		;_XTLFREQ ?
		je	@@xtl

		cmp	al,000100b		;_XINFREQ ?
		je	@@xin

		cmp	al,000010b		;_RCFAST ?
		je	@@rcf

		cmp	al,000001b		;_RCSLOW ?
		je	@@rcs

		cmp	al,000000b		;if no symbol, use default mode
		je	@@default

		jmp	error_codcssf		;error, conflicting or deficient clock symbols found


@@default:	cmp	[debug_mode],0		;default to _RCFAST if not debug mode
		je	@@rcf
		mov	[@@xtlfreq],20000000	;debug mode, set _XTLFREQ to 20 MHz
		jmp	@@xtl


@@clk:		mov	[clkmode],1011b		;_CLKFREQ	(assumes 20 MHz crystal)
		mov	eax,20000000
		jmp	@@pll

@@clk_xtl:	cmp	[@@xtlfreq],16000000	;_CLKFREQ + _XTLFREQ
		mov	[clkmode],1011b
		jae	@@pf
		mov	[clkmode],1111b		;_XTLFREQ < 16 MHz, use 15pF instead of 7.5pF
@@pf:		mov	eax,[@@xtlfreq]
		jmp	@@pll

@@clk_xin:	mov	[clkmode],0111b		;_CLKFREQ + _XINFREQ
		mov	eax,[@@xinfreq]
@@pll:		mov	[xinfreq],eax
		mov	ebx,[@@clkfreq]
		mov	ecx,[@@errfreq]
		test	[@@flags],100000b	;if no _ERRFREQ, use default of 1 MHz (always works)
		jnz	@@goterr
		mov	ecx,1000000
@@goterr:	call	pll_calc
		jnc	error_pllscnba
		or	[clkmode],eax
		mov	[clkfreq],ebx
		jmp	@@done

@@xtl:		cmp	[@@xtlfreq],16000000	;_XTLFREQ
		mov	[clkmode],1010b
		jae	@@pf2
		mov	[clkmode],1110b		;_XTLFREQ < 16 MHz, use 15pF instead of 7.5pF
@@pf2:		mov	eax,[@@xtlfreq]
		mov	[clkfreq],eax
		mov	[xinfreq],eax
		jmp	@@done

@@xin:		mov	[clkmode],0110b		;_XINFREQ
		mov	eax,[@@xinfreq]
		mov	[clkfreq],eax
		mov	[xinfreq],eax
		jmp	@@done

@@rcf:		mov	[clkmode],0000b		;_RCFAST	(default)
		mov	[clkfreq],20000000
		mov	[xinfreq],0
		jmp	@@done

@@rcs:		mov	[clkmode],0001b		;_RCSLOW
		mov	[clkfreq],20000
		mov	[xinfreq],0


@@done:		mov	al,type_con_int		;enter CLKMODE_ symbol
		mov	ebx,[clkmode]
		lea	esi,[@@clkmode_]
		call	@@entersymbol

		mov	al,type_con_int		;enter CLKFREQ_ symbol
		mov	ebx,[clkfreq]
		lea	esi,[@@clkfreq_]
		jmp	@@entersymbol


@@findsymbol:	lea	edi,[symbol]		;find symbol and set 'defined' flag if found
		mov	ecx,symbol_size_limit+1
	rep	movsb
		call	find_symbol
		cmp	al,type_undefined
		je	@@findsymbol2
		cmp	al,type_con_int
		jne	error_cfcobd
		stc
@@findsymbol2:	rcl	[@@flags],1
		ret

@@entersymbol:	lea	edi,[symbol2]		;enter symbol
		mov	ecx,symbol_size_limit+1
	rep	movsb
		jmp	enter_symbol2_print


@@clkmode_	db	'CLKMODE_',0
@@clkfreq_	db	'CLKFREQ_',0
@@_errfreq	db	'_ERRFREQ',0
@@_clkfreq	db	'_CLKFREQ',0
@@_xtlfreq	db	'_XTLFREQ',0
@@_xinfreq	db	'_XINFREQ',0
@@_rcfast	db	'_RCFAST',0
@@_rcslow	db	'_RCSLOW',0

dbx		@@flags
ddx		@@errfreq
ddx		@@clkfreq
ddx		@@xtlfreq
ddx		@@xinfreq
;
;
; Calculate PLL setting
;
; on entry:	eax = input frequency in Hz
;		ebx = desired output frequency in Hz
;		ecx = max allowable error in Hz
;
; on exit:	eax = PLL mode with crystal bits cleared (eax[3:2]=0)
;		ebx = actual output frequency in Hz
;		c = 1 if setting found
;
pll_calc:	mov	[@@xinfreq],eax
		mov	[@@clkfreq],ebx
		mov	[@@errfreq],ecx

		mov	[@@found],0		;clear the found flag in case no success
		mov	[@@error],ecx		;set initial error allowance

		cmp	[@@xinfreq],250000	;xinfreq must be 250 KHz to 500 MHz
		jb	@@abort
		cmp	[@@xinfreq],500000000
		ja	@@abort

		cmp	[@@clkfreq],3333333	;clkfreq must be 3.333333 MHz to 500 MHz
		jb	@@abort
		cmp	[@@clkfreq],500000000
		ja	@@abort


		mov	[@@pppp],0		;sweep post divider from 1,2,4,6,..30

@@loop1:	mov	eax,[@@pppp]		;determine post divider value
		shl	eax,1
		jnz	@@notzero
		inc	eax
@@notzero:	mov	[@@post],eax

		mov	[@@divd],64		;sweep xin divider from 64 to 1

@@loop2:	mov	eax,[@@xinfreq]		;fpfd = round(xinfreq / divd)
		shl	eax,1			;x2 for later rounding
		mov	edx,0			;xinfreq --> edx:eax
		div	[@@divd]		;divide edx:eax by divd
		inc	eax			;round quotient
		shr	eax,1
		mov	[@@fpfd],eax

		mov	eax,[@@post]		;mult = round((post * divd) * clkfreq / xinfreq)
		mul	[@@divd]		;multiply post by divd --> eax
		shl	eax,1			;x2 for later rounding
		mul	[@@clkfreq]		;multiply by clkfreq --> edx:eax
		div	[@@xinfreq]		;divide edx:eax by xinfreq
		inc	eax			;round quotient
		shr	eax,1
		mov	[@@mult],eax

		mov	eax,[@@xinfreq]		;fvco = round(xinfreq * mult / divd)
		shl	eax,1			;x2 for later rounding
		mul	[@@mult]		;multiply xinfreq by mult --> edx:eax
		cmp	[@@divd],edx		;if divd > edx then safe to divide
		ja	@@safe
		mov	eax,0			;else, fvco = 0
		jmp	@@unsafe
@@safe:		div	[@@divd]		;divide edx:eax by divd
		inc	eax			;round quotient
		shr	eax,1
@@unsafe:	mov	[@@fvco],eax

		mov	eax,[@@fvco]		;fout = round(fvco / post)
		shl	eax,1			;x2 for later rounding
		mov	edx,0			;fvco --> edx:eax
		div	[@@post]		;divide edx:eax by post
		inc	eax			;round quotient
		shr	eax,1
		mov	[@@fout],eax

		mov	eax,[@@fout]		;abse = absolute(fout - clkfreq)
		sub	eax,[@@clkfreq]
		jnc	@@pos
		neg	eax
@@pos:		mov	[@@abse],eax


		cmp	eax,[@@error]		;does this setting have lower or same error?
		ja	@@nope

		cmp	[@@fpfd],250000		;is fpfd at least 250KHz?
		jb	@@nope

		cmp	[@@mult],1024		;is mult 1024 or less?
		ja	@@nope

		cmp	[@@fvco],99000000	;is fvco at least 99 MHz?
		jb	@@nope

		cmp	[@@fvco],201000000	;is fvco no more than 201 MHz?
		jbe	@@yep

		mov	eax,[@@clkfreq]		;is fvco no more than clkfreq + errfreq?
		add	eax,[@@errfreq]
		cmp	[@@fvco],eax
		ja	@@nope


@@yep:		mov	[@@found],1		;found the best setting so far, set flag

		mov	eax,[@@abse]		;update error to abse
		mov	[@@error],eax

		mov	eax,[@@divd]		;set the divider field
		dec	eax
		shl	eax,18
		mov	[@@mode],eax

		mov	eax,[@@mult]		;set the multiplier field
		dec	eax
		shl	eax,8
		or	[@@mode],eax

		mov	eax,[@@pppp]		;set the post divider field
		dec	eax
		and	eax,1111b
		shl	eax,4
		or	[@@mode],eax

		or	[@@mode],01000003h	;set the pll-enable bit and select the pll

		mov	eax,[@@fout]		;save the pll frequency
		mov	[@@freq],eax


@@nope:		dec	[@@divd]		;decrement divd and loop if not 0
		jnz	@@loop2

		inc	[@@pppp]		;increment pppp and loop if under 16
		cmp	[@@pppp],16
		jb	@@loop1

		mov	eax,[@@mode]		;get mode into eax
		mov	ebx,[@@freq]		;get freq into ebx
@@abort:	shr	[@@found],1		;get found flag into c
		ret


ddx		@@xinfreq
ddx		@@clkfreq
ddx		@@errfreq
ddx		@@found
ddx		@@error
ddx		@@abse
ddx		@@pppp
ddx		@@post
ddx		@@divd
ddx		@@fpfd
ddx		@@mult
ddx		@@fvco
ddx		@@fout
ddx		@@mode
ddx		@@freq
;
;
; Print doc data
;
print_doc:	call	reset_element		;print any initial doc comment
		mov	[doc_flag],0
		mov	[doc_mode],1
@@initial:	call	get_element
		cmp	al,type_end
		je	@@initial
		cmp	[doc_flag],0		;if one found, print cr
		je	@@noinitial
		call	print_cr
@@noinitial:	mov	[doc_mode],0
		push	[source_start]		;save ptr after
		pop	[@@start]

		call	print_string		;print object title
		db	'Object "',0
		lea	esi,[obj_title]
@@title:	lodsb
		cmp	al,0
		je	@@titledone
		call	print_chr
		jmp	@@title
@@titledone:	call	print_string
		db	'" Interface:',13,13,0

		call	@@printall		;print interfaces

		call	print_string		;print statistics
		db	13,'Program:  ',0
		mov	eax,[obj_ptr]
		call	print_decimal
		call	print_string
		db	' bytes',13,'Variable: ',0
		mov	eax,[var_ptr]
		call	print_decimal
		call	print_string
		db	' bytes',13,0

		mov	[doc_mode],1		;set doc mode

		cmp	[doc_flag],0		;if doc comments, print interfaces again,
		je	@@ret			;..this time with doc comments


@@printall:	call	reset_element		;reset element
		push	[@@start]		;point after any initial doc comment
		pop	[source_ptr]

@@nextblock:	mov	dl,block_pub		;scan for pub block
		call	next_block
		jc	@@ret			;if eof, done

		cmp	[doc_mode],0		;if doc mode, print extra cr and underline
		je	@@notdoc
		call	print_cr
		clc
		call	@@scanint
@@underline:	mov	al,'_'
		call	print_chr
		loop	@@underline
		call	print_cr
@@notdoc:
		call	print_string		;print pub name and interface
		db	'PUB  ',0
		stc
		call	@@scanint

		cmp	[doc_mode],0		;print extra cr?
		je	@@notdoc2
		call	print_cr
@@notdoc2:
		jmp	@@nextblock


@@scanint:	rcl	dl,1			;scan/print interface according to c
		push	[source_ptr]		;save source_ptr

		call	get_element		;name first..
		mov	ecx,[source_finish]
		mov	esi,[source_start]
		sub	ecx,esi
		push	ecx
		add	esi,[source]
@@scanname:	lodsb
		call	@@scanprint2
		loop	@@scanname
		pop	ecx

		call	@@scanskip		;..then any parameters
		cmp	al,'('
		jne	@@scancolon2
		call	@@scanprint

@@scanpar:	call	@@scanskip
@@scanpar2:	call	@@scanprint
		cmp	al,')'
		je	@@scancolon
		cmp	al,','
		jne	@@scanpar
		mov	al,' '
		jmp	@@scanpar2

@@scancolon:	call	@@scanskip		;..then any result(s)
@@scancolon2:	cmp	al,':'
		jne	@@scancr
		mov	al,' '
		call	@@scanprint
		mov	al,':'
		call	@@scanprint
		mov	al,' '
		call	@@scanprint

@@scanresult:	call	@@scanskip
@@scanresultc:	call	@@scanprint
		mov	al,[byte esi]
		call	check_word_chr
		lodsb
		jnc	@@scanresultc
		dec	esi
		call	@@scanskip
		cmp	al,','
		jne	@@scanresultx
		call	@@scanprint
		mov	al,' '
		call	@@scanprint
		jmp	@@scanresult
@@scanresultx:
@@scancr:	pop	[source_ptr]		;done, restore source_ptr
		add	ecx,4			;account for 'PUB  ' - cr
		mov	al,13			;print cr

@@scanprint:	inc	ecx			;inc chr counter
@@scanprint2:	test	dl,1			;print depending on mode
		jnz	print_chr

@@ret:		ret


@@scanskip:	lodsb				;skip any whitespace
		cmp	al,' '
		je	@@scanskip
		cmp	al,9
		je	@@scanskip
		ret


ddx		@@start
;
;
;************************************************************************
;*  Object Distiller							*
;************************************************************************
;
;
; Distill objects
;
distill_objects:

		push	[obj_ptr]

		call	distill_build
		call	distill_scrub
		call	distill_eliminate
		call	distill_rebuild
		call	distill_reconnect

		pop	eax
		sub	eax,[obj_ptr]
		add	[distilled_bytes],eax

		ret
;
;
; Build initial object list
;
distill_build:	mov	[dis_ptr],0		;reset distiller list pointer
		mov	eax,0			;base object id is 0
		mov	esi,0			;base object offset is 0
		mov	edi,1			;initial sub-object id is 1

@@record:	call	@@enter			;enter object id

		mov	eax,esi			;enter object offset
		call	@@enter

		mov	ecx,0			;count sub-objects
@@countobjects:	test	[obj+esi+ecx*8+3],80h	;look for msb set in long
		jnz	@@enterobjects
		inc	ecx
		jmp	@@countobjects
@@enterobjects:	mov	eax,ecx			;enter sub-object count
		call	@@enter

		mov	ebx,ecx			;count methods
		shl	ebx,3
		add	ebx,esi
		mov	eax,0
@@countmethods:	mov	edx,[dword obj+ebx+eax*4]
		or	edx,edx			;look for msb clear in long
		jns	@@entermethods
		inc	eax
		jmp	@@countmethods
@@entermethods:	call	@@enter			;enter method count

		mov	eax,edx			;enter object size
		call	@@enter

		jecxz	@@done			;if no sub-objects, done

		mov	edx,edi			;remember initial sub-object id

		push	ecx			;enter sub-object id's
@@id:		mov	eax,edi
		call	@@enter
		inc	edi
		loop	@@id
		pop	ecx

		mov	ebx,0			;enter sub-objects
@@sub:		mov	eax,[dword obj+esi+ebx*8]
		push	ebx
		push	ecx
		push	edx
		push	esi
		add	esi,eax
		mov	eax,edx
		call	@@record		;recursively call @@record to enter any sub-objects' sub-object records
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		inc	ebx
		inc	edx
		loop	@@sub

@@done:		ret


@@enter:	mov	ebx,[dis_ptr]		;enter long into distiller list
		cmp	ebx,distiller_limit*4
		je	error_odo
		mov	[dis+ebx],eax
		add	[dis_ptr],4
		ret
;
;
; Scrub sub-object offsets within objects to enable comparison of redundant objects
;
distill_scrub:	mov	ebx,0			;start with base object

@@clear:	mov	esi,[dis+ebx+4]		;get object offset
		mov	ecx,[dis+ebx+8]		;get sub-object count

		mov	eax,ecx			;advance pointer to next object record
		shl	eax,2
		add	eax,5 shl 2
		add	ebx,eax

		jecxz	@@none			;if no sub-objects, no offsets to clear

		mov	eax,0			;clear sub-object offset(s)
@@zero:		mov	[dword obj+esi+eax*8],0
		inc	eax
		loop	@@zero

@@none:		cmp	ebx,[dis_ptr]		;finished?
		jne	@@clear

		ret
;
;
; Eliminate redundant objects
;
distill_eliminate:

		mov	ebx,0			;start with base object

@@newobject:	mov	ecx,[dis+ebx+8]		;if sub-object count is 0
		jecxz	@@search		;..or all sub-object id's have msb set,
		lea	esi,[dis+ebx+20]	;..then search for match
@@msb:		lodsd
		or	eax,eax
		jns	@@nextobject
		loop	@@msb

@@search:	mov	edx,ebx			;search, start from current object

@@checknext:	mov	eax,[dis+edx+8]		;point to next trailing object record
		shl	eax,2
		add	eax,5 shl 2
		add	edx,eax
		cmp	edx,[dis_ptr]		;if end of trailing objects, next object
		je	@@nextobject

		mov	eax,[dis+ebx+16]	;do object sizes match?
		cmp	eax,[dis+edx+16]
		jne	@@checknext

		mov	ecx,[dis+ebx+8]		;do sub-object counts match?
		cmp	ecx,[dis+edx+8]
		jne	@@checknext

		jecxz	@@nosubs		;do sub-object id's match?
		lea	esi,[dis+ebx+20]
		lea	edi,[dis+edx+20]
	repe	cmpsd
		jne	@@checknext
@@nosubs:
		mov	esi,[dis+ebx+4]		;do object binaries match?
		mov	edi,[dis+edx+4]
		add	esi,offset obj
		add	edi,offset obj
		mov	ecx,eax
	repe	cmpsb
		jne	@@checknext

		mov	eax,[dis+ebx]		;objects match, update all related sub-object id's
		call	@@update
		mov	eax,[dis+edx]		;set msb's of id's
		call	@@update

		mov	eax,[dis+ebx+8]		;remove redundant object record from list
		shl	eax,2			;(id is no longer referenced by any record)
		add	eax,5 shl 2
		lea	edi,[dis+ebx]
		mov	esi,edi
		add	esi,eax
		sub	[dis_ptr],eax
		mov	ecx,[dis_ptr]
		sub	ecx,ebx
	rep	movsb

		jmp	distill_eliminate	;start over to search for next redundancy

@@nextobject:	mov	eax,[dis+ebx+8]		;point to next object record
		shl	eax,2
		add	eax,5 shl 2
		add	ebx,eax
		cmp	ebx,[dis_ptr]		;if not end of objects, try next
		jne	@@newobject

		ret				;done, all redundancies eliminated


@@update:	push	ebx			;update sub-object id's in records
		mov	esi,0			;eax = old id, [dis+edx] points to new id

@@updatenext:	add	esi,5 shl 2		;point to sub-object id's
		mov	ecx,[dis+esi-12]	;get sub-object count
		jecxz	@@updatenone		;any sub-objects to update?

@@updatesub:	mov	ebx,[dis+esi]		;convert any old id's to new id's and set msb
		and	ebx,7FFFFFFFh
		cmp	ebx,eax
		jne	@@updatenot
		mov	ebx,[dis+edx]
		or	ebx,80000000h
		mov	[dis+esi],ebx
@@updatenot:	add	esi,1 shl 2
		loop	@@updatesub

@@updatenone:	cmp	esi,[dis_ptr]		;another record to process?
		jne	@@updatenext

		pop	ebx
		ret
;
;
; Rebuild distilled object with sub-objects
;
distill_rebuild:

		mov	ebx,0			;reset list ptr
		mov	edx,0			;reset rebuild ptr

@@loop:		mov	esi,edx			;copy object and update offset
		xchg	esi,[dis+ebx+4]
		add	esi,offset obj
		lea	edi,[@@rebuild+edx]
		mov	ecx,[dis+ebx+16]	;get object size and long align
		test	ecx,11b
		jz	@@pad
		or	ecx,11b
		inc	ecx
@@pad:		add	edx,ecx
	rep	movsb

		mov	eax,[dis+ebx+8]		;another object?
		shl	eax,2
		add	eax,5 shl 2
		add	ebx,eax
		cmp	ebx,[dis_ptr]
		jne	@@loop

		mov	[obj_ptr],edx		;rebuild done, copy distilled object

		mov	ecx,edx			;back to obj and update ptr
		lea	esi,[@@rebuild]
		lea	edi,[obj]
	rep	movsb

		ret


dbx		@@rebuild,obj_size_limit
;
;
; Reconnect any sub-objects
;
distill_reconnect:

		mov	ebx,0			;start with base object

@@obj:		mov	ecx,[dis+ebx+8]		;ecx holds number of sub-objects
		jecxz	@@done			;if zero, nothing to do

		mov	edx,[dis+ebx+4]		;edx holds object offset
		lea	esi,[dis+ebx+20]	;esi points to sub-object id's
		lea	edi,[obj+edx]		;edi points to sub-object list within object

@@sub:		lodsd				;get sub-object id
		and	eax,7FFFFFFFh

		push	ecx			;find offset of sub-object
		mov	ebx,0
@@find:		cmp	[dis+ebx],eax
		je	@@found
		mov	ecx,[dis+ebx+8]
		shl	ecx,2
		add	ecx,5 shl 2
		add	ebx,ecx
		jmp	@@find
@@found:	pop	ecx

		mov	eax,[dis+ebx+4]		;enter relative offset of sub-object
		sub	eax,edx
		and	eax,7FFFFFFFh		;(not needed if objects are, indeed, arranged top to bottom - verify later!)
		stosd
		add	edi,4

		push	ecx			;call @@obj recursively to reconnect any sub-objects' sub-objects
		push	edx
		push	esi
		push	edi
		call	@@obj
		pop	edi
		pop	esi
		pop	edx
		pop	ecx

		loop	@@sub			;loop until sub-objects reconnected

@@done:		ret
;
;
; Distiller data
;
; 3+ long records:
;
; 0:	object id
; 1:	object offset
; 2:	sub-object count
; 3:	method count
; 4:	object size
; 5+:	sub-object id's (if any)
;
ddx		dis_ptr
ddx		dis,distiller_limit
;
;
;************************************************************************
;*  Elementizer								*
;************************************************************************
;
;
; Reset element
;
reset_element:	xor	eax,eax
		mov	[source_ptr],eax
		mov	[source_flags],al

		ret
;
;
; Get element
;
; on entry:     source_ptr = source pointer
;
; on exit:      eax = element type
;               ebx = element value
;               source_start = element start
;               source_finish = element finish
;               source_ptr = new source pointer
;
;               if eof, c=1
;
get_element:	push	ecx
		push	edx
		push	esi
		push	edi

		mov	[symbol_flag],0		;reset symbol flag

		movzx	eax,[back_index]	;update back data
		and	al,07h
		mov	ebx,[source_ptr]
		mov	[back_ptrs+eax*4],ebx
		mov	bl,[source_flags]
		mov	[back_flags+eax],bl
		inc	[back_index]
		shl	[back_skip],1

		xor	eax,eax			;eax=0 (type)
		xor	ebx,ebx			;ebx=0 (value)
		xor	ecx,ecx			;ecx=0 (base)

		mov	esi,[source_ptr]	;esi points to source
		add	esi,[source]
		lea	edi,[symbol]		;edi points to symbol

@@skip:		mov	edx,esi			;get element start into edx

		lodsb				;get chr

		cmp	[source_flags],0	;old string?
		jne	@@str2

		cmp	al,'"'			;new string?
		je	@@str

		cmp	al,0			;end of file?
		je	@@eof

		cmp	al,13			;end of line?
		je	@@eol

		cmp	al,' '			;space or tab?
		jbe	@@skip

		cmp	al,"'"			;comment?
		je	@@com

		cmp	al,"{"			;brace comment start?
		je	@@bcom

		cmp	al,"}"			;unmatched brace comment end?
		je	@@error_bcom

		cmp	al,'%'			;binary or packed characters?
		je	@@bin

		cmp	al,'$'			;hex?
		je	@@hex

		cmp	al,'0'			;decimal?
		jb	@@notdec
		cmp	al,'9'
		jbe	@@dec
@@notdec:
		cmp	al,'.'			;continue on next line?
		jne	@@not3dot
		cmp	[byte esi],'.'
		jne	@@not3dot
		cmp	[byte esi + 1],'.'
		jne	@@not3dot
@@skipline:	lodsb				;skip rest of line
		cmp	al,0			;end of file?
		je	@@eof
		cmp	al,13			;end of line?
		jne	@@skipline
		jmp	@@skip			;continue on next line
@@not3dot:
		call	check_word_chr		;symbol?
		mov	cl,symbol_size_limit+1
		jnc	@@sym2

		shl	eax,8			;may be non-word symbol, store 1st chr
		lodsb				;get 2nd chr in case 2-chr symbol
		cmp	al,' '			;if 2nd chr is white space or eol, try 1-chr
		jbe	@@onechr
		shl	eax,8			;store 2nd chr
		lodsb				;get 3rd chr in case 3-chr symbol
		cmp	al,' '			;if 3rd chr is white space or eol, try 2-chr
		jbe	@@twochr
		call	find_symbol_s3		;check if 3-chr symbol valid
		je	@@got			;if so, got it
@@twochr:	dec	esi			;back up source ptr for 2-chr symbol
		shr	eax,8			;shift out white space or eol chr
		call	find_symbol_s2		;check if 2-chr symbol valid
		je	@@got			;if so, got it
@@onechr:	dec	esi			;back up source ptr for 1-chr symbol
		shr	eax,8			;shift out white space or eol chr
		call	find_symbol_s1		;check if 1-chr symbol valid
		je	@@got			;if so, got it
		jmp	@@error_op		;if not, error

@@str:		lodsb				;new string, get first chr
@@str2:		cmp	[source_flags],1	;old string, comma?
		je	@@str4
		mov	[source_flags],ah	;reset flags
		cmp	al,'"'			;if '"', error
		je	@@error_str		;(first time only)
		cmp	al,0			;if eof, error
		je	@@error_str2
		cmp	al,13			;if eol, error
		je	@@error_str3
		mov	bl,al			;return constant
		lodsb				;if '"' next, done
		cmp	al,'"'
		je	@@str3
		inc	[source_flags]		;not '"', set comma flag
		dec	esi
@@str3:		mov	al,type_con_int		;return constant
		jmp	@@got
@@str4:		inc	[source_flags]		;cancel comma flag
		dec	esi
		mov	al,type_comma		;return comma
		jmp	@@got

@@com:		cmp	[byte esi],"'"		;comment, doc comment?
		jne	@@com2

		inc	esi			;yes, skip second "'"
		mov	[doc_flag],1		;set doc flag
@@doc:		lodsb				;get comment chr
		cmp	al,0			;end of file?
		je	@@com3
		call	@@docprint		;print doc comment chr
		cmp	al,13			;end of line?
		je	@@eol
		jmp	@@doc

@@com2:		lodsb				;get comment chr
		cmp	al,13			;end of line?
		je	@@eol
		cmp	al,0			;end of file?
		jne	@@com2
@@com3:		dec	esi			;eof, repoint to eof
		jmp	@@eof2

@@bcom:		cmp	[byte esi],"{"		;brace comment, doc comment?
		jne	@@bcom2

		mov	[doc_flag],1		;yes, set doc comment flag
		inc	esi			;skip second "{"
		lodsb				;skip end if present
		cmp	al,13
		je	@@bdoc
		dec	esi
@@bdoc:		lodsb
		cmp	al,0
		je	@@error_bdoc
		cmp	al,"}"
		jne	@@bdoc2
		cmp	[byte esi],"}"
		je	@@bdoc3
@@bdoc2:	call	@@docprint
		jmp	@@bdoc
@@bdoc3:	inc	esi
		jmp	@@skip			;brace doc comment done, skip

@@bcom2:	inc	ebx			;brace comment, level up
@@bcom3:	lodsb				;get comment chr
		cmp	al,0			;if eof, error
		je	@@error_bcom2
		cmp	al,"{"			;level up?
		je	@@bcom2
		cmp	al,"}"			;level down?
		jne	@@bcom3			;ignore other chrs
		dec	ebx
		jne	@@bcom3
		jmp	@@skip			;brace comment done, skip

@@eof:		dec	esi			;end of file, repoint to eof
		mov	edx,esi
@@eof2:		dec	ecx			;on exit, c=1
@@eol:		mov	al,type_end		;end of line
		jmp	@@got

@@bin:		lodsb				;%"?
		cmp	al,'"'
		je	@@packed
		cmp	al,'%'			;% or %%?
		je	@@double

		mov	cl,2			;% binary or $
		call	check_digit
		jnc	@@con
		dec	esi
		mov	al,type_percent
		jmp	@@got

@@double:	lodsb				;%% double binary
		mov	cl,4
		call	check_digit
		jnc	@@con
		call	@@setptrs
		jmp	error_idbn

@@hex:		lodsb				;$ hex or $ or $$
		mov	cl,16
		call	check_digit
		jnc	@@con
		cmp	[byte esi-1],'$'
		mov	al,type_dollar2
		je	@@got
		dec	esi
		mov	al,type_dollar
		jmp	@@got

@@dec:		mov	cl,10			;decimal

@@con:		dec	esi			;back up to first digit
@@con2:		lodsb				;get next chr
		cmp	al,'_'			;if underscore, ignore
		je	@@con2
		call	check_digit		;mac digit in al into ebx
		jc	@@con4
		movzx	eax,al
		xchg	eax,ebx
		push	edx
		push	ecx
		movzx	ecx,cl
		mul	ecx
		pop	ecx
		or	edx,edx
		pop	edx
		jnz	@@con3			;note overflow
		add	ebx,eax
		jnc	@@con2
@@con3:		mov	ch,1
		jmp	@@con2
@@con4:		cmp	cl,10			;check for floating-point constant
		jne	@@con7
		dec	esi			;base 10, look for '.' or 'e'
		lodsb
		cmp	al,'.'
		jne	@@con5
		lodsb				;make sure '.' followed by digit
		dec	esi
		call	check_digit
		jnc	@@con6
		jmp	@@con7
@@con5:		call	uppercase
		cmp	al,'E'
		jne	@@con7			;if neither, integer
@@con6:		call	get_float		;get floating-point constant at edx
		jc	@@error_flt		;invalid?
		mov	eax,type_con_float	;return constant float
		jmp	@@got
@@con7:		dec	esi			;integer done, back up to last chr
		cmp	ch,0			;trap overflow
		jne	@@error_con
@@con8:		mov	eax,type_con_int	;return constant
		jmp	@@got

@@packed:	call	@@packedchr		;packed chrs
		cmp	al,'"'
		je	@@error_str
		mov	bl,al
		call	@@packedchr
		cmp	al,'"'
		je	@@con8
		mov	bh,al
		call	@@packedchr
		cmp	al,'"'
		je	@@con8
		ror	ebx,16
		mov	bl,al
		rol	ebx,16
		call	@@packedchr
		cmp	al,'"'
		je	@@con8
		ror	ebx,24
		mov	bl,al
		rol	ebx,24
		call	@@packedchr
		cmp	al,'"'
		je	@@con8
		jmp	@@error_nmt4c

@@packedchr:	lodsb				;get packed chr
		cmp	al,0			;if eof, error
		je	@@error_str2
		cmp	al,13			;if eol, error
		je	@@error_str3
		ret

@@sym:		lodsb				;symbol, gather chrs
		call	check_word_chr
		jc	@@sym3
@@sym2:		stosb
		loop	@@sym
		jmp	@@error_sym
@@sym3:		dec	esi			;back up to non-symbol chr
		mov	al,0			;terminate symbol
		stosb
		inc	[symbol_flag]		;set symbol flag
		call	find_symbol		;find symbol

@@got:		call	@@setptrs		;set pointers

		shl	ecx,1			;if eof, c=1

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret


@@setptrs:	mov	edi,[source]		;set pointers
		sub	edx,edi
		sub	esi,edi
		mov	[source_start],edx
		mov	[source_finish],esi
		mov	[source_ptr],esi
		ret

@@docprint:	cmp	[doc_mode],0		;if doc mode, print chr
		jne	print_chr
		ret


@@error_bcom:	call	@@setptrs		;error, brace comment end
		jmp	error_bmbpbb

@@error_bcom2:	dec	esi			;error, brace comment open
		mov	edx,esi
		call	@@setptrs
		jmp	error_erb

@@error_bdoc:	dec	esi			;error, brace document comment open
		mov	edx,esi
		call	@@setptrs
		jmp	error_erbb

@@error_op:	call	@@setptrs		;error, unrecognized chr
		jmp	error_uc

@@error_str:	call	@@setptrs		;error, empty string
		jmp	error_es

@@error_str2:	dec	esi			;(eof, back up)

@@error_str3:	call	@@setptrs		;error, unterminated string
		jmp	error_eatq

@@error_nmt4c:	inc	edx			;error, too many packed chrs
		inc	edx
		call	@@setptrs
		jmp	error_nmt4c

@@error_flt:	call	@@setptrs		;error, floating-point constant invalid
		jmp	error_fpcmbw

@@error_con:	call	@@setptrs		;error, constant too large
		jmp	error_ce32b

@@error_sym:	call	@@setptrs		;error, symbol too long
		jmp	error_sexc
;
;
; Back up possible-obj-multi or one element
;
back_element:	call	back_element_single
		jc	back_element

		ret


back_element_single:

		push	eax

@@skip:		dec	[back_index]
		movzx	eax,[back_index]
		and	al,07h
		push	[back_ptrs+eax*4]
		pop	[source_ptr]
		mov	al,[back_flags+eax]
		mov	[source_flags],al
		shr	[back_skip],1		;c=1 if another element

		pop	eax
		ret
;
;
; Check al for word character
; c=0 if word character
;
check_word_chr:	cmp	al,'0'			;digit?
		jc	cwc_done
		cmp	al,'9'+1
		jc	cwc_flip

check_word_chr_initial:				;initial word chr cannot be digit

		cmp	al,'_'			;underscore?
		je	cwc_done

		call	uppercase		;make uppercase

		cmp	al,'A'			;letter?
		jc	cwc_done
		cmp	al,'Z'+1

cwc_flip:	cmc

cwc_done:	ret
;
;
; Check al for digit below cl
; c=0 if valid digit
;
check_digit:	call	check_hex		;0-F?
		jc	@@error

		cmp	al,cl			;below cl?
		cmc

@@error:	ret
;
;
; Check al for hex digit
; c=0 if hex digit
;
check_hex:	call	uppercase

		sub	al,'0'			;0-9?
		cmp	al,9+1
		jc	@@flip

		sub	al,'A'-'9'-1		;A-F?
		cmp	al,0Ah
		jc	@@done
		cmp	al,0Fh+1

@@flip:		cmc

@@done:		ret
;
;
; Make al uppercase
;
uppercase:	cmp	al,'a'
		jb	@@done
		cmp	al,'z'
		ja	@@done

		sub	al,'a'-'A'

@@done:		ret
;
;
; Get floating-point constant at edx
;
get_float:	push	edx

		mov	esi,edx			;get source start in esi

		mov	ecx,10			;set base
		xor	edx,edx			;reset significant digits and decimal point flag
		xor	ebx,ebx			;reset mantissa
		xor	edi,edi			;reset base10 exponent

@@mantissa:	lodsb				;get chr
		cmp	al,'_'			;if underscore, ignore
		je	@@mantissa
		call	check_digit		;check for digit
		jc	@@notdigit		;not digit?
		cmp	dl,0			;significant digit already?
		jne	@@digitvalid
		cmp	al,0			;first significant digit?
		jne	@@digitvalid
		cmp	dh,0			;zero, if no decimal point yet, ignore
		je	@@mantissa
		dec	edi			;leading zero right of decimal point, dec exponent
		jmp	@@mantissa		;get next chr

@@digitvalid:	cmp	dl,9			;mac up to nine significant digits (30 bits max)
		jne	@@significant

		cmp	dh,0			;after nine significant digits and still no
		jne	@@mantissa		;...decimal point, just inc exponent
		inc	edi
		jmp	@@mantissa

@@significant:	inc	dl			;inc significant digits
		cmp	dh,0			;if right of decimal point, dec exponent
		je	@@notright
		dec	edi
@@notright:	movzx	eax,al			;mac digit into mantissa
		xchg	eax,ebx
		push	edx
		mul	ecx
		pop	edx
		add	ebx,eax
		jmp	@@mantissa		;get next chr


@@notdigit:	dec	esi			;not digit, get chr
		lodsb

		cmp	al,'.'			;decimal point?
		jne	@@notpoint
		cmp	dh,1			;if decimal point already, got constant string
		je	@@gotconstant
		mov	dh,1			;else, set decimal point flag
		jmp	@@mantissa		;get next chr
@@notpoint:
		call	uppercase		;'e' exponent?
		cmp	al,'E'
		jne	@@gotconstant		;if not, got constant

		lodsb				;exponent, check for '-' or '+'
		mov	dh,1			;set negative flag
		cmp	al,'-'
		je	@@expneg		;'-'?
		cmp	al,'+'
		je	@@exppos		;'+'?
		dec	esi			;neither, positive, back up
@@exppos:	mov	dh,0			;clear negative flag
@@expneg:
		lodsb				;get first exponent digit
		call	check_digit
		jc	@@error			;if invalid, error
		mov	dl,al
@@expdigit:	lodsb				;get any secondary exponent digits
		cmp	al,'_'			;if underscore, ignore
		je	@@expdigit
		call	check_digit
		jc	@@expdone
		xchg	al,dl			;mac exponent digit
		mul	cl
		cmp	ah,0			;if overflow, set flag
		jne	@@expover
		add	dl,al
		jnc	@@expdigit
@@expover:	or	dh,2
		jmp	@@expdigit

@@expdone:	test	dh,2			;exponent done
		jnz	@@error			;if overflow, error
		movzx	eax,dl			;mac 'e' exponent into mantissa exponent
		test	dh,1
		jz	@@expnotneg
		neg	eax
@@expnotneg:	add	edi,eax


@@gotconstant:	or	ebx,ebx			;got constant string, ebx=mantissa, edi=base10 exponent
		jz	@@done			;if mantissa 0, result 0, c=0

		mov	ecx,32			;justify mantissa and get base2 exponent
@@justfp:	dec	ecx
		shl	ebx,1
		jnc	@@justfp

		add	ebx,100h		;round to nearest mantissa lsb
		adc	ecx,0

		and	bh,0FEh			;clear sign, insert exponent, and justify float
		add	cl,127
		mov	bl,cl
		ror	ebx,9

@@normalize:	cmp	edi,-37			;if base10 exponent < -37, normalize
		jge	@@checkover
		mov	eax,[@@tens]
		call	fp_mul
		mov	ebx,eax
		add	edi,37
		jmp	@@normalize

@@checkover:	cmp	edi,38			;if base10 exponent > 38, error
		jg	@@error

		mov	eax,[@@tens+37*4+edi*4]	;multiply float by base 10 exponent
		call	fp_mul
		jc	@@error			;overflow?

		mov	ebx,eax			;float in ebx
		jmp	@@done			;done, c=0

@@error:	stc				;error, c=1

@@done:		dec	esi			;done, back up to last constant chr

		pop	edx
		ret


@@tens		dd	0.0000000000000000000000000000000000001		;1e-37 (Turbo Assembler right for exp $01+ values)
		dd	0.000000000000000000000000000000000001
		dd	0.00000000000000000000000000000000001
		dd	0.0000000000000000000000000000000001
		dd	0.000000000000000000000000000000001
		dd	0.00000000000000000000000000000001
		dd	0.0000000000000000000000000000001
		dd	0.000000000000000000000000000001		;1e-30
		dd	0.00000000000000000000000000001
		dd	0.0000000000000000000000000001
		dd	0.000000000000000000000000001
		dd	0.00000000000000000000000001
		dd	0.0000000000000000000000001
		dd	0.000000000000000000000001
		dd	0.00000000000000000000001
		dd	0.0000000000000000000001
		dd	0.000000000000000000001
		dd	0.00000000000000000001				;1e-20
		dd	0.0000000000000000001
		dd	0.000000000000000001
		dd	0.00000000000000001
		dd	0.0000000000000001
		dd	0.000000000000001
		dd	0.00000000000001
		dd	0.0000000000001
		dd	0.000000000001
		dd	0.00000000001
		dd	0.0000000001					;1e-10
		dd	0.000000001
		dd	0.00000001
		dd	0.0000001
		dd	0.000001
		dd	0.00001
		dd	0.0001
		dd	0.001
		dd	0.01
		dd	0.1
		dd	1.0						;1e0
		dd	10.0
		dd	100.0
		dd	1000.0
		dd	10000.0
		dd	100000.0
		dd	1000000.0
		dd	10000000.0
		dd	100000000.0
		dd	1000000000.0
		dd	10000000000.0					;1e10
		dd	100000000000.0
		dd	1000000000000.0
		dd	10000000000000.0
		dd	100000000000000.0
		dd	1000000000000000.0
		dd	10000000000000000.0
		dd	100000000000000000.0
		dd	1000000000000000000.0
		dd	10000000000000000000.0
		dd	100000000000000000000.0				;1e20
		dd	1000000000000000000000.0
		dd	10000000000000000000000.0
		dd	100000000000000000000000.0
		dd	1000000000000000000000000.0
		dd	10000000000000000000000000.0
		dd	100000000000000000000000000.0
		dd	1000000000000000000000000000.0
		dd	10000000000000000000000000000.0
		dd	100000000000000000000000000000.0
		dd	1000000000000000000000000000000.0		;1e30
		dd	10000000000000000000000000000000.0
		dd	100000000000000000000000000000000.0
		dd	1000000000000000000000000000000000.0
		dd	10000000000000000000000000000000000.0
		dd	100000000000000000000000000000000000.0
		dd	1000000000000000000000000000000000000.0
		dd	10000000000000000000000000000000000000.0
		dd	100000000000000000000000000000000000000.0	;1e38
;
;
; Get element's column +1 into [column]
;
get_column:	push	eax
		push	ebx
		push	ecx
		push	esi

		mov	ecx,[source_start]
		mov	esi,[source]

@@find:		jecxz	@@got
		dec	ecx
		cmp	[byte esi+ecx],13
		jne	@@find
		inc	ecx
@@got:		add	esi,ecx

		neg	ecx
		add	ecx,[source_start]
		jecxz	@@done

		xor	ebx,ebx
@@loop:		lodsb
		cmp	al,09h
		jne	@@nottab
		or	bl,07h
@@nottab:	inc	ebx
		loop	@@loop
		mov	ecx,ebx

@@done:		inc	ecx
		mov	[column],ecx

		pop	esi
		pop	ecx
		pop	ebx
		pop	eax
		ret


ddx		column
;
;
; Elementizer data
;
dbx		symbol_flag

ddx		source_ptr
dbx		source_flags

dbx		back_index
dbx		back_skip
ddx		back_ptrs,8
dbx		back_flags,8
;
;
;************************************************************************
;*  Expression Resolver							*
;************************************************************************
;
; Resolver routines:
;
;	get_value	- Resolve expression - if error, abort
;	try_value	- bl.0 = try, bl.1 = assembly operand mode
;
; On exit:
;
;	if resolved:		ebx=value, c=1 if float
;	if unresolvable:	ebx=0 if try, else abort
;
; Basic expression syntax rules:		i.e.  4000 / (ABS x * 5) // 127) + 1
;
;	Any one of these...	Must be followed by any one of these...
;	------------------------------------------------------------------
;	constant		binary operator
;	)			)
;				? (ternary operator)
;				<end>
;
;	Any one of these...	Must be followed by any one of these... *
;	------------------------------------------------------------------
;	unary operator		constant
;	binary operator		unary operator
;	(			(
;	? (ternary operator)
;
;				* initial element of an expression
;
; Get/try value
;
get_value:	mov	bl,0			;must resolve
try_value:	mov	bh,0			;either integer or float allowed
		jmp	gt_value

get_value_int:	mov	bl,0			;must resolve
try_value_int:	mov	bh,1			;only integer allowed
gt_value:	and	bl,11b			;clear undefined flag in bl.2
		mov	[exp_flags],bl		;set flags

		push	eax
		push	ecx
		push	edx

		xor	ecx,ecx			;reset math stack pointer

		mov	dh,bh			;get mode (0=uncommitted, 1=integer, 2=float)

		call	get_element		;get start of expression
		push	[source_start]
		call	back_element

		call	resolve_exp		;resolve expression

		call	back_element_single	;get end of expression, set start
		call	get_element
		pop	[source_start]

		push	[source_start]		;save value pointers
		pop	[value_start]
		push	[source_finish]
		pop	[value_finish]

		mov	ebx,[mat-4+ecx*4]	;get value into ebx

		cmp	dh,2			;c=1 if float
		cmc

		pop	edx
		pop	ecx
		pop	eax
		ret


dbx		exp_flags
;
;
; Try to resolve Spin2 constant expression
; c=0 if succeeded with constant in ebx
; c=1 if failed with [source_ptr] restored
;
try_spin2_con_exp:

		push	eax
		push	ecx
		push	edx

		xor	ecx,ecx			;reset math stack pointer

		mov	dh,4			;set Spin2 constant expression mode
		mov	[exp_flags],0		;must resolve

		push	[source_ptr]		;push source_ptr

		mov	[try_spin2_con_esp],esp	;save esp in case of failure to resolve

		call	resolve_exp		;attempt to resolve Spin2 constant expression
		mov	ebx,[mat-4+ecx*4]	;succeeded, get value into ebx
		pop	eax			;pop old ptr
		clc				;c=0
		jmp	try_spin2_con_exit

fail_spin2_con_exp:

		mov	esp,[try_spin2_con_esp]	;failed to resolve constant expression, restore esp
		pop	[source_ptr]		;restore source_ptr
		stc				;c=1

try_spin2_con_exit:

		pop	edx
		pop	ecx
		pop	eax
		ret


ddx		try_spin2_con_esp
;
;
; Resolve expression with sub-expressions
;
resolve_exp:	mov	dl,ternary_precedence+1	;expression, set ternary precedence + 1

@@subexp:	push	ebx			;sub-expression, maintain precedence
		push	edx

		dec	dl			;lower precedence, if was 0, resolve term
		js	@@term			;else, resolve sub-expression

		call	@@subexp		;resolve first sub-expression
@@next:		call	get_element		;get ternary, binary, or <end>
		call	check_ternary		;ternary?
		je	@@ternary
		call	check_binary		;if not binary, back up
		jne	@@backup

		cmp	bh,dl			;binary, if not current precedence, back up
		jne	@@backup
		call	@@previewop		;preview for indication/compliance
		call	@@subexpsave		;resolve sub-expression, save source pointers
		call	perform_binary		;perform binary operation
		jmp	@@next			;check for next binary

@@ternary:	cmp	dl,ternary_precedence	;ternary, if not ternary precedence, back up
		jne	@@backup
		call	resolve_exp		;got 'exp ?', get 'exp:exp'
		call	get_colon
		call	resolve_exp
		sub	ecx,2			;pick result
		cmp	[mat-4+ecx*4],0
		mov	ebx,[mat+0+ecx*4]
		jne	@@ternary2
		mov	ebx,[mat+4+ecx*4]
@@ternary2:	mov	[mat-4+ecx*4],ebx
		jmp	@@done

@@term:		call	get_element_obj		;term, get constant, unary, or '('
		call	is_plus			;ignore leading '+' or '+.'
		je	@@term
		call	check_constant
		je	@@constant
		call	sub_to_neg
		call	fsub_to_fneg
		call	check_unary
		je	@@unary
		cmp	al,type_left
		je	@@left
		cmp	dh,4			;syntax error or non-constant term
		je	fail_spin2_con_exp	;if trying to resolve Spin2 constant, fail
		jmp	error_eacuool

@@constant:	call	perform_push		;constant, push onto math stack
		jmp	@@done

@@unary:	mov	dl,bh			;unary, set unary's precedence
		call	@@previewop		;preview for indication/compliance
		call	@@subexpsave		;resolve sub-expression, save source pointers
		call	perform_unary		;perform unary operation
		jmp	@@done

@@left:		call	resolve_exp		;'(', resolve expression
		call	get_right		;get ')'
		jmp	@@done

@@backup:	call	back_element		;end of (sub-)expression, back up

@@done:		mov	al,dh			;retain mode
		pop	edx
		mov	dh,al
		pop	ebx
		ret


@@previewop:	cmp	dh,4			;if trying to resolve Spin2 constant, okay
		je	@@okay
		call	check_float		;if operator is floating-point-compatible, okay
		je	@@okay
		cmp	dh,2			;if float mode, error
		je	error_ionaifpe
		mov	dh,1			;set integer mode in case undefined
@@okay:		ret

@@subexpsave:	push	[source_start]		;save source pointers
		push	[source_finish]
		call	@@subexp		;resolve next sub-expression
		pop	[source_finish]
		pop	[source_start]
		ret
;
;
; Check constant
; z=1 if constant with value in ebx
;
check_constant:	cmp	dh,4			;trying to resolve Spin2 constant?
		jne	@@notspin2

		call	sub_to_neg		;-constant?
		jne	@@spin2notneg
		call	get_element_obj
		cmp	al,type_con_int		;-type_con_int?
		jne	@@spin2notconi
		neg	ebx
		jmp	@@spin2con
@@spin2notconi:	cmp	al,type_con_float	;-type_con_float?
		jne	@@spin2notconf
		xor	ebx,80000000h
		jmp	@@spin2con
@@spin2notconf:	call	back_element		;back up past non-constant
		call	back_element		;back up to '-'
		call	get_element		;get '-' again
@@spin2notneg:
		cmp	al,type_con_int		;type_con_int okay
		je	@@spin2exit
		cmp	al,type_con_float	;type_con_float okay
		je	@@spin2exit

		cmp	al,type_pound		;check for #register
		jne	@@spin2exit
		call	get_element
		cmp	al,type_register	;type_register?
		je	@@spin2con
		cmp	al,type_dat_long_res	;type_dat_long_res?
		je	@@gotres
		cmp	al,type_dat_byte	;type_dat_byte..type_dat_long?
		jb	@@spin2regerr
		cmp	al,type_dat_long
		ja	@@spin2regerr
@@gotres:	shr	ebx,32-12		;must be below $400
		cmp	ebx,400h
		jb	@@spin2con
@@spin2regerr:	jmp	error_eregsym

@@spin2con:	cmp	al,al			;type_con_int/type_con_float, make z=1
@@spin2exit:	ret
@@notspin2:

		call	sub_to_neg		;-constant?
		jne	@@notneg
		call	get_element_obj
		cmp	al,type_con_int		;-type_con_int?
		jne	@@notconi
		neg	ebx
		jmp	@@chkconi
@@notconi:	cmp	al,type_con_float	;-type_con_float?
		jne	@@notconf
		xor	ebx,80000000h
		jmp	@@chkconf
@@notconf:	call	back_element		;back up past non-constant
		call	back_element		;back up to '-'
		call	get_element		;get '-' again
@@notneg:
		cmp	al,type_con_int		;constant integer?
		jne	@@notcon
@@chkconi:	call	@@checkint
		jmp	@@okay
@@notcon:
		cmp	al,type_con_float	;constant float?
		jne	@@notconfloat
@@chkconf:	call	@@checkfloat
		jmp	@@okay
@@notconfloat:
		cmp	al,type_float		;FLOAT(integer exp)?
		jne	@@notfloat
		call	@@checkfloat
		call	get_left		;FLOAT(integer exp), get '('
		mov	dh,1			;set integer mode
		call	resolve_exp		;resolve integer expression
		mov	dh,2			;return to float mode
		call	get_right		;get ')'
		mov	eax,[mat-4+ecx*4]	;convert integer to float
		dec	ecx
		call	fp_float
		mov	ebx,eax
		jmp	@@okay
@@notfloat:
		cmp	al,type_round		;ROUND(float exp)?
		jne	@@notround
		push	offset fp_round
		jmp	@@roundtrunc
@@notround:
		cmp	al,type_trunc		;TRUNC(float exp)?
		jne	@@nottrunc
		push	offset fp_trunc
@@roundtrunc:	call	@@checkint
		call	get_left		;get '('
		push	[source_finish]		;save source pointer in case error
		mov	dh,2			;set float mode
		call	resolve_exp		;resolve float expression
		mov	dh,1			;return to integer mode
		call	get_right		;get ')'
		push	[source_start]		;set source pointer in case error
		pop	[source_finish]
		pop	[source_start]
		mov	eax,[mat-4+ecx*4]	;convert float to rounded integer
		dec	ecx
		pop	ebx
		call	ebx
		jc	error_fpo		;error?
		mov	ebx,eax
		jmp	@@okay
@@nottrunc:
		cmp	al,type_sizeof		;SIZEOF(struct)?
		jne	@@notsizeof
		cmp	[con_block_flag],1	;not allowed in CON block
		je	error_soioa
		cmp	[obj_block_flag],1	;not allowed in OBJ block
		je	error_soioa
		call	@@checkint
		call	get_left		;get '('
		call	get_element_obj		;get type_con_struct
		call	check_con_struct_size	;get struct size into eax, z=0 if not type_con_struct
		jne	error_easn		;error if not type_con_struct
		call	get_right		;get ')'
		mov	ebx,eax
		jmp	@@okay
@@notsizeof:
		test	[exp_flags],10b		;if operand mode, check for local symbol
		jz	@@notop
		call	check_local
@@notop:
		call	@@checkundef		;if undefined and not try, error
		je	@@ret			;if undefined and try, okay

		cmp	al,type_dollar		;allow origin ($) if operand
		jne	@@notorg
		test	[exp_flags],10b
		jz	error_dioa
		call	@@checkint
		cmp	[orgh],0		;return hub or cog origin
		mov	ebx,[hub_org]
		jne	@@okay
		mov	ebx,[cog_org]
		shr	ebx,2
		jmp	@@okay
@@notorg:
		cmp	al,type_dollar2		;allow DITTO index ($$) if operand
		jne	@@notditto
		test	[exp_flags],10b
		jz	error_diioa
		cmp	[ditto_flag],0
		je	error_diioa
		mov	ebx,[ditto_index]
		jmp	@@okay
@@notditto:
		cmp	al,type_register	;allow register if operand or CON block
		jne	@@notreg
		cmp	[con_block_flag],1
		je	@@regokay
		test	[exp_flags],10b
		jz	error_rinah
@@regokay:	call	@@checkint
		jmp	@@okay
@@notreg:
		cmp	[inline_flag],1		;if inline-assembly mode, remap local longs
		jne	@@notinline
		cmp	al,type_loc_byte	;local byte variable not allowed
		je	@@locerror
		cmp	al,type_loc_word	;local word variable not allowed
		je	@@locerror
		cmp	al,type_loc_long	;local long variable is allowed
		je	@@locsizeok
		cmp	al,type_loc_struct	;local struct variable is allowed, but user must know layout
		je	@@locsizeok
		cmp	al,type_loc_byte_ptr	;local byte ptr variable is allowed
		je	@@locsizeok
		cmp	al,type_loc_word_ptr	;local word ptr variable is allowed
		je	@@locsizeok
		cmp	al,type_loc_long_ptr	;local long ptr variable is allowed
		je	@@locsizeok
		cmp	al,type_loc_struct_ptr	;local struct ptr variable is allowed, but user must know layout
		jne	@@notinline
@@locsizeok:	and	ebx,0FFFFFh		;trim in case structure
		test	bl,11b			;must be long-aligned
		jnz	@@locerror
		cmp	ebx,10h shl 2		;must be within first 16
		jae	@@locerror
		shr	ebx,2			;make into long index
		add	ebx,inline_locals_base	;add inline-locals register base
		jmp	@@okay
@@locerror:	jmp	error_lvmb
@@notinline:
		cmp	al,type_at		;check for @type_dat_????
		jne	@@notat
		call	@@checkint
		call	get_element_obj
		call	@@checkdat		;if type_dat_????, use dat ptr
		je	@@trim
		cmp	al,type_hub_long	;accommodate clkmode/clkfreq
		je	@@trim
		call	@@checkundef		;if undefined and not try, error
		je	@@ret			;if undefined and try, okay
		jmp	error_eads		;else, error
@@notat:
		call	@@checkdat		;special handing for type_dat_????
		jne	@@ret

		call	@@checkint		;type_dat_????
		test	[exp_flags],10b		;if not operand, use dat ptr
		jz	@@trim
		cmp	ebx,0FFF00000h		;if not cog register, use dat ptr
		jae	@@orghsymbol
		shr	ebx,32-12		;use org address in high bits
		jmp	@@trim
@@orghsymbol:	mov	[orgh_symbol_flag],1	;set orgh_symbol_flag
		cmp	[pasm_mode],1		;if spin mode, add orgh_offset
		je	@@trim
		add	ebx,[orgh_offset]
@@trim:		and	ebx,0FFFFFh		;trim in case dat ptr

@@okay:		cmp	al,al			;z=1

@@ret:		ret


@@checkdat:	test	[exp_flags],10b		;check for type_dat_???
		jz	@@notres
		cmp	al,type_dat_long_res	;if operand mode, convert type_dat_long_res to type_dat_long
		jne	@@notres
		mov	al,type_dat_long
@@notres:	cmp	al,type_dat_byte	;check for type_dat_????
		jb	@@ret			;z=1 if true
		cmp	al,type_dat_long
		jbe	@@okay
		ret

@@checkundef:	cmp	al,type_undefined	;check for either undefined or undefined.symbol
		jne	@@ret			;if not undefined, z=0
		or	[exp_flags],100b	;set undefined flag
		push	[source_start]		;save symbol pointers
		pop	[@@source_start]
		push	[source_finish]
		pop	[@@source_finish]
		call	check_dot		;check for apparent obj.constant
		jne	@@notdot
		push	ecx			;got '.', make sure symbol follows
		call	get_symbol
		pop	ecx
		jc	error_eacn		;if no symbol after '.', error
@@notdot:	push	[@@source_start]	;restore symbol pointers
		pop	[source_start]
		push	[@@source_finish]
		pop	[source_finish]
		test	[exp_flags],01b		;if undefined and try, z=1
		jnz	@@okay
		jmp	error_us		;else, error

@@checkfloat:	cmp	dh,1			;check float mode
		je	error_fpnaiie		;if integer mode, error
		mov	dh,2			;set float mode
		ret

@@checkint:	cmp	dh,2			;check integer mode
		je	error_inaifpe		;if float mode, error
		mov	dh,1			;set integer mode
		ret


ddx		@@source_start
ddx		@@source_finish

dbx		orgh_symbol_flag
;
;
; Perform push/binary/unary operation
;
perform_push:	cmp	ecx,matsize		;check stack pointer
		je	error_eitc

		mov	[mat-0+ecx*4],ebx	;push value
		inc	ecx

		ret


perform_binary:	dec	ecx

perform_unary:	xor	eax,eax			;if undefined flag, return 0
		test	[exp_flags],100b
		jnz	@@got

		push	ecx
		push	edx

		cmp	dh,2			;z=1 if float mode

		mov	eax,[mat-4+ecx*4]	;get terms
		mov	ecx,[mat-0+ecx*4]

		movzx	ebx,bl			;call handler
		call	[@@ops+ebx*4]

		pop	edx
		pop	ecx

@@got:		mov	[mat-4+ecx*4],eax	;store result

		ret


@@ops		dd	offset @@bitnot
		dd	offset @@neg
		dd	offset @@fneg
		dd	offset @@abs
		dd	offset @@fabs
		dd	offset @@encod
		dd	offset @@decod
		dd	offset @@bmask
		dd	offset @@ones
		dd	offset @@sqrt
		dd	offset @@fsqrt
		dd	offset @@qlog
		dd	offset @@qexp
		dd	offset @@log2
		dd	offset @@log10
		dd	offset @@log
		dd	offset @@exp2
		dd	offset @@exp10
		dd	offset @@exp
		dd	offset @@shr
		dd	offset @@shl
		dd	offset @@sar
		dd	offset @@ror
		dd	offset @@rol
		dd	offset @@rev
		dd	offset @@zerox
		dd	offset @@signx
		dd	offset @@bitand
		dd	offset @@bitxor
		dd	offset @@bitor
		dd	offset @@mul
		dd	offset @@fmul
		dd	offset @@div
		dd	offset @@fdiv
		dd	offset @@divu
		dd	offset @@rem
		dd	offset @@remu
		dd	offset @@sca
		dd	offset @@scas
		dd	offset @@frac
		dd	offset @@add
		dd	offset @@fadd
		dd	offset @@sub
		dd	offset @@fsub
		dd	offset @@pow
		dd	offset @@fge
		dd	offset @@fle
		dd	offset @@addbits
		dd	offset @@addpins
		dd	offset @@lt
		dd	offset @@flt
		dd	offset @@ltu
		dd	offset @@lte
		dd	offset @@flte
		dd	offset @@lteu
		dd	offset @@e
		dd	offset @@fe
		dd	offset @@ne
		dd	offset @@fne
		dd	offset @@gte
		dd	offset @@fgte
		dd	offset @@gteu
		dd	offset @@gt
		dd	offset @@fgt
		dd	offset @@gtu
		dd	offset @@ltegt
		dd	offset @@lognot
		dd	offset @@logand
		dd	offset @@logxor
		dd	offset @@logor


@@bitnot:	not	eax			;not
		ret


@@neg:		jz	@@fneg			;neg, float?

		neg	eax			;neg integer
		ret

@@fneg:		xor	eax,80000000h		;neg float
		ret


@@abs:		jz	@@fabs			;abs, float?

		or	eax,eax			;abs integer
		jns	@@abs2
		neg	eax
@@abs2:		ret

@@fabs:		and	eax,7FFFFFFFh		;abs float
		ret


@@encod:	mov	ecx,31			;encod
@@encod2:	shl	eax,1
		jc	@@encod3
		loop	@@encod2
@@encod3:	mov	eax,ecx
		ret

@@decod:	mov	cl,al			;decod
		mov	eax,1
		shl	eax,cl
		ret

@@bmask:	mov	cl,al			;bmask
		mov	eax,2
		shl	eax,cl
		dec	eax
		ret

@@ones:		mov	ecx,0			;ones
@@ones2:	shl	eax,1
		pushf
		adc	ecx,0
		popf
		jnz	@@ones2
		mov	eax,ecx
		ret

@@sqrt:		mov	[@@t],eax		;sqrt
		mov	ebx,8000h
		xor	ecx,ecx
@@sqrt2:	or	ecx,ebx
		mov	eax,ecx
		mul	eax
		cmp	eax,[@@t]
		jbe	@@sqrt3
		xor	ecx,ebx
@@sqrt3:	shr	ebx,1
		jnc	@@sqrt2
		mov	eax,ecx
		ret

ddx		@@t

@@fsqrt:	jmp	fp_sqrt			;fsqrt

@@qlog:		jmp	cordic_qlog		;qlog

@@qexp:		jmp	cordic_qexp		;qexp

@@log2:		jmp	fp_log2			;log2

@@log10:	jmp	fp_log10		;log10

@@log:		jmp	fp_log			;log

@@exp2:		jmp	fp_exp2			;exp2

@@exp10:	jmp	fp_exp10		;exp10

@@exp:		jmp	fp_exp			;exp

@@shr:		shr	eax,cl			;shr
		ret

@@shl:		shl	eax,cl			;shl
		ret

@@sar:		sar	eax,cl			;sar
		ret

@@ror:		ror	eax,cl			;ror
		ret

@@rol:		rol	eax,cl			;rol
		ret

@@rev:		and	ecx,1Fh			;rev
		inc	ecx
		xor	ebx,ebx
@@rev2:		shr	eax,1
		rcl	ebx,1
		loop	@@rev2
		mov	eax,ebx
		ret

@@zerox:	not	cl			;zerox
		shl	eax,cl
		shr	eax,cl
		ret

@@signx:	not	cl			;signx
		shl	eax,cl
		sar	eax,cl
		ret

@@bitand:	and	eax,ecx			;bitand
		ret

@@bitxor:	xor	eax,ecx			;bitxor
		ret

@@bitor:	or	eax,ecx			;bitor
		ret


@@mul:		jz	@@fmul			;mul, float?

		imul	ecx			;mul integer
		ret

@@fmul:		mov	ebx,ecx			;mul float
		call	fp_mul
		jc	error_fpo
		ret


@@div:		jz	@@fdiv			;div, float?

		or	ecx,ecx			;div integer
		jz	error_dbz
		cdq
		idiv	ecx
		ret

@@fdiv:		mov	ebx,ecx			;div float
		call	fp_div
		jc	error_fpo
		ret


@@divu:		or	ecx,ecx			;divu
		jz	error_dbz
		xor	edx,edx
		div	ecx
		ret

@@rem:		or	ecx,ecx			;rem
		jz	error_dbz
		cdq
		idiv	ecx
		mov	eax,edx
		ret

@@remu:		or	ecx,ecx			;remu
		jz	error_dbz
		xor	edx,edx
		div	ecx
		mov	eax,edx
		ret

@@sca:		mul	ecx			;sca
		mov	eax,edx
		ret

@@scas:		imul	ecx			;scas
		shl	eax,1
		rcl	edx,1
		shl	eax,1
		rcl	edx,1
		mov	eax,edx
		ret

@@frac:		or	ecx,ecx			;frac
		jz	error_dbz
		cmp	eax,ecx
		jae	error_divo
		mov	edx,eax
		xor	eax,eax
		div	ecx
		ret


@@add:		jz	@@fadd			;add, float?

		add	eax,ecx			;add integer
		ret

@@fadd:		mov	ebx,ecx			;add float
		call	fp_add
		jc	error_fpo
		ret


@@sub:		jz	@@fsub			;sub, float?

		sub	eax,ecx			;sub integer
		ret

@@fsub:		mov	ebx,ecx			;sub float
		call	fp_sub
		jc	error_fpo
		ret


@@pow:		mov	ebx,ecx			;pow
		jmp	fp_pow


@@fge:		jz	@@fgefp			;fge, float?

		cmp	eax,ecx			;fge integer
		jge	@@fge2
		mov	eax,ecx
@@fge2:		ret

@@fgefp:	mov	ebx,ecx			;fge float
		call	fp_fge
		jc	error_fpo
		ret


@@fle:		jz	@@flefp			;fle, float?

		cmp	eax,ecx			;fle integer
		jle	@@fle2
		mov	eax,ecx
@@fle2:		ret

@@flefp:	mov	ebx,ecx			;fle float
		call	fp_fle
		jc	error_fpo
		ret


@@addbits:	and	ecx,1Fh			;addbits
		shl	ecx,5
		and	eax,1Fh
		or	eax,ecx
		ret

@@addpins:	and	ecx,1Fh			;addpins
		shl	ecx,6
		and	eax,3Fh
		or	eax,ecx
		ret


@@lt:		mov	dl,001b			;lt
		jmp	@@cmp

@@flt:		mov	dl,001b			;flt
		jmp	@@fcmp

@@ltu:		mov	dl,001b			;ltu
		jmp	@@cmpu

@@lte:		mov	dl,101b			;lte
		jmp	@@cmp

@@flte:		mov	dl,101b			;flte
		jmp	@@fcmp

@@lteu:		mov	dl,101b			;lteu
		jmp	@@cmpu

@@e:		mov	dl,100b			;e
		jmp	@@cmp

@@fe:		mov	dl,100b			;fe
		jmp	@@fcmp

@@ne:		mov	dl,011b			;ne
		jmp	@@cmp

@@fne:		mov	dl,011b			;fne
		jmp	@@fcmp

@@gte:		mov	dl,110b			;gte
		jmp	@@cmp

@@fgte:		mov	dl,110b			;fgte
		jmp	@@fcmp

@@gteu:		mov	dl,110b			;gteu
		jmp	@@cmpu

@@gt:		mov	dl,010b			;gt
		jmp	@@cmp

@@fgt:		mov	dl,010b			;fgt
		jmp	@@fcmp

@@gtu:		mov	dl,010b			;gtu
		jmp	@@cmpu


@@ltegt:	mov	dl,011b			;ltegt, float?
		jz	@@ltegtfp

		call	@@cmp			;ltegt integer
		test	dl,010b
		jz	@@ltegt2
		mov	eax,1			;greater than, make +1
@@ltegt2:	ret

@@ltegtfp:	call	@@cmp			;ltegt float
		and	eax,3F800000h
		test	dl,001b
		jz	@@ltegtfp2
		xor	eax,80000000h		;less than, make -1.0
@@ltegtfp2:	ret


@@cmpu:		cmp	eax,ecx			;cmp unsigned (integer)
		mov	al,001b			;less than
		jb	@@cmp3
		mov	al,010b			;greater than
		ja	@@cmp3
		mov	al,100b			;equal
		jmp	@@cmp3


@@cmp:		jnz	@@cmp1			;cmp, float?
		call	@@fcmp
		and	eax,3F800000h
		ret

@@fcmp:		mov	ebx,ecx			;cmp float
		call	fp_cmp
		jc	error_fpo
		jmp	@@cmp2

@@cmp1:		cmp	eax,ecx			;cmp integer
@@cmp2:		mov	al,001b			;less than
		jl	@@cmp3
		mov	al,010b			;greater than
		jg	@@cmp3
		mov	al,100b			;equal
@@cmp3:		and	dl,al
		movzx	eax,dl
		jmp	@@logic


@@lognot:	call	@@logic			;lognot
		not	eax
		ret


@@logand:	call	@@logic			;logand
		and	eax,ecx
		ret

@@logxor:	call	@@logic			;logxor
		xor	eax,ecx
		ret

@@logor:	call	@@logic			;logor
		or	eax,ecx
		ret


@@logic:	or	eax,eax			;make eax and ecx logical
		jz	@@logic2			;non-0 becomes $FFFFFFFF (-1)
		mov	eax,0FFFFFFFFh
@@logic2:	or	ecx,ecx
		jz	@@logic3
		mov	ecx,0FFFFFFFFh
@@logic3:	ret
;
;
; Expression resolver stack
;
matsize		=	10h			;math stack size (long)
ddx		mat,matsize			;math stack
;
;
; Cordic QLOG/QEXP resolver
;
cordic_qlog:	clc
		jmp	cordic_q

cordic_qexp:	stc

cordic_q:	push	ebx
		push	ecx
		push	edx

		rcl	[@@exp],1		;store mode

		test	[@@exp],1		;qlog or qexp pre-fix?
		jnz	@@exp_pre

		mov	ebx,eax			;qlog pre-fix, save ~magnitude in mag
		mov	ecx,31
@@getmag:	shl	ebx,1
		jc	@@gotmag
		loop	@@getmag
@@gotmag:	xor	cl,1Fh
		mov	[@@mag],cl

		shl	eax,cl			;init y
		and	eax,7FFFFFFFh
		mov	edx,0
		shld	edx,eax,6
		shl	eax,6
		mov	[@@y+0],eax
		mov	[@@y+4],edx

		or	edx,010b shl (37-32)	;init x
		mov	[@@x+0],eax
		mov	[@@x+4],edx

		mov	[@@z+0],0		;init z
		mov	[@@z+4],0

		jmp	@@iterations


@@exp_pre:	mov	ecx,eax			;qexp pre-fix, save ~exponent in mag
		shr	ecx,32-5
		xor	cl,1Fh
		mov	[@@mag],cl

		mov	[@@x+0],42E61C5Ah	;init x
		mov	[@@x+4],0000007Fh

		mov	[@@y+0],0		;init y
		mov	[@@y+4],0

		and	eax,07FFFFFFh		;init z
		mov	edx,0
		shld	edx,eax,11
		shl	eax,11
		mov	[@@z+0],eax
		mov	[@@z+4],edx


@@iterations:	mov	ecx,1			;init index

		call	@@sec			;sec01
		call	@@adj_next		;adj02
		call	@@sec			;sec02
		call	@@adj_next		;adj03
		call	@@sec			;sec03
		call	@@adj_next		;adj04
		call	@@sec			;sec04
		call	@@sec			;sec04x
		call	@@sec_next		;sec05
		call	@@sec_next		;sec06
		call	@@adj_next		;adj07
		call	@@sec			;sec07
		call	@@adj_next		;adj08
		call	@@sec			;sec08
		call	@@sec_next		;sec09
		call	@@adj_next		;adj10
		call	@@sec			;sec10
		call	@@sec_next		;sec11
		call	@@adj_next		;adj12
		call	@@sec			;sec12
		call	@@sec_next		;sec13
		call	@@sec			;sec13x
		call	@@adj_next		;adj14
		call	@@sec			;sec14
		call	@@sec_next		;sec15
		call	@@adj_next		;adj16
		call	@@sec			;sec16
		call	@@sec_next		;sec17
		call	@@sec_next		;sec18
		call	@@adj_next		;adj19
		call	@@sec			;sec19
		call	@@adj_next		;adj20
		call	@@sec			;sec20
		call	@@sec_next		;sec21
		call	@@adj_next		;adj22
		call	@@sec			;sec22
		call	@@adj_next		;adj23
		call	@@sec			;sec23
		call	@@adj_next		;adj24
		call	@@sec			;sec24
		call	@@adj_next		;adj25
		call	@@sec			;sec25
		call	@@sec_next		;sec26
		call	@@sec_next		;sec27
		call	@@sec_next		;sec28
		call	@@sec_next		;sec29
		call	@@adj_next		;adj30
		call	@@sec			;sec30
		call	@@sec_next		;sec31

		mov	cl,[@@mag]		;post-shift x and y down by ~mag
		lea	ebx,[@@x]
		call	@@get
		call	@@sar
		call	@@put
		lea	ebx,[@@y]
		call	@@get
		call	@@sar
		call	@@put

		test	[@@exp],1		;qlog or qexp post-fix?
		jnz	@@exp_post

		mov	eax,[@@z+0]		;qlog post-fix
		mov	edx,[@@z+4]
		mov	cl,9-7
		call	@@sar
		and	eax,0FFFFFF80h
		movzx	ecx,[@@mag]
		xor	cl,1Fh
		shl	ecx,35-32
		add	eax,80h
		adc	edx,ecx
		cmp	[@@mag],0
		jne	@@log_post
		test	edx,1 shl (39-32)
		jnz	@@log_post
		mov	eax,0FFFFFFFFh
		mov	edx,eax
@@log_post:	mov	cl,8
		jmp	@@done

@@exp_post:	mov	eax,[@@x+0]		;qexp post-fix
		mov	edx,[@@x+4]
		add	eax,[@@y+0]
		adc	edx,[@@y+4]
		add	eax,20h
		adc	edx,0
		mov	cl,7
@@done:		call	@@sar

		pop	edx
		pop	ecx
		pop	ebx
		ret


@@sec_next:	inc	cl			;cordic iteration

@@sec:		lea	ebx,[@@y]		;get xd
		call	@@get
		call	@@sar
		lea	ebx,[@@xd]
		call	@@put

		lea	ebx,[@@x]		;get yd
		call	@@get
		call	@@sar
		lea	ebx,[@@yd]
		call	@@put

		lea	ebx,[@@zdeltas-8+ecx*8]	;get zd
		call	@@get
		lea	ebx,[@@zd]
		call	@@put

		test	[@@exp],1		;qlog or qexp steering logic?
		jnz	@@qexp
		cmp	[@@y+4],0
		jl	@@flip
		jmp	@@same
@@qexp:		cmp	[@@z+4],0
		jl	@@same

@@flip:		lea	ebx,[@@xd]		;negate xd/yd/zd
		call	@@neg
		lea	ebx,[@@yd]
		call	@@neg
		lea	ebx,[@@zd]
		call	@@neg

@@same:		lea	ebx,[@@xd]		;update x
		call	@@get
		lea	ebx,[@@x]
		call	@@sub

		lea	ebx,[@@yd]		;update y
		call	@@get
		lea	ebx,[@@y]
		call	@@sub

		lea	ebx,[@@zd]		;update z
		call	@@get
		lea	ebx,[@@z]
		jmp	@@add


@@adj_next:	inc	cl			;cordic scale adjustment

		lea	ebx,[@@x]		;update x
		call	@@get
		call	@@sar
		call	@@sub

		lea	ebx,[@@y]		;update y
		call	@@get
		call	@@sar
		jmp	@@sub


@@get:		mov	eax,[ebx+0]		;subroutines
		mov	edx,[ebx+4]
		ret

@@sar:		shrd	eax,edx,cl
		sar	edx,cl
		ret

@@neg:		not	[dword ebx+0]
		not	[dword ebx+4]
		add	[dword ebx+0],1
		adc	[dword ebx+4],0
		ret

@@add:		add	[ebx+0],eax
		adc	[ebx+4],edx
		ret

@@sub:		sub	[ebx+0],eax
		sbb	[ebx+4],edx
		ret

@@put:		mov	[ebx+0],eax
		mov	[ebx+4],edx
		ret


@@zdeltas:	dq	32B803473Fh		;hyberbolic cordic deltas
		dq	179538DEA7h
		dq	0B9A2C912Fh
		dq	05C73F7233h
		dq	02E2E683F7h
		dq	01715C285Fh
		dq	00B8AB3164h
		dq	005C553C5Ch
		dq	002E2A92A3h
		dq	00171547E0h
		dq	000B8AA3C2h
		dq	0005C551DBh
		dq	0002E2A8EDh
		dq	0001715476h
		dq	0000B8AA3Bh
		dq	00005C551Eh
		dq	00002E2A8Fh
		dq	0000171547h
		dq	00000B8AA4h
		dq	000005C552h
		dq	000002E2A9h
		dq	0000017154h
		dq	000000B8AAh
		dq	0000005C55h
		dq	0000002E2Bh
		dq	0000001715h
		dq	0000000B8Bh
		dq	00000005C5h
		dq	00000002E3h
		dq	0000000171h
		dq	00000000B9h


dbx		@@exp
dbx		@@mag
ddx		@@x,2
ddx		@@y,2
ddx		@@z,2
ddx		@@xd,2
ddx		@@yd,2
ddx		@@zd,2
;
;
;************************************************************************
;*  Floating-Point Operations						*
;************************************************************************
;
; Floating-point routines:
;
;	fp_fge		- force eax => ebx
;	fp_fle		- force eax <= ebx
;	fp_cmp		- compare eax to ebx
;	fp_add		- add ebx into eax
;	fp_sub		- subtract ebx from eax
;	fp_mul		- multiply ebx into eax
;	fp_div		- divide eax into ebx
;	fp_pow		- raise eax to the power of ebx
;
;	fp_log2		- get log2 of eax
;	fp_log10	- get log2 of eax
;	fp_log		- get log2 of eax
;	fp_exp2		- get log2 of eax
;	fp_exp10	- get log2 of eax
;	fp_exp		- get log2 of eax
;
;	fp_float	- convert eax integer to float
;	fp_round	- convert eax float to rounded integer
;	fp_trunc	- convert eax float to truncated integer
;

;
;
; Floating-point fge (greatest(fp eax, fp ebx) -> fp eax)
; c=1 if overflow
;
fp_fge:		call	fp_cmp			;compare fp eax to fb ebx, c=1 if overflow

		jge	@@exit			;if fp eax < fp ebx, return fp ebx
		mov	eax,ebx

@@exit:		ret
;
;
; Floating-point fle (least(fp eax, fp ebx) -> fp eax)
; c=1 if overflow
;
fp_fle:		call	fp_cmp			;compare fp eax to fb ebx, c=1 if overflow

		jle	@@exit			;if fp eax > fp ebx, return fp ebx
		mov	eax,ebx

@@exit:		ret
;
;
; Floating-point comparison (fp eax - fp ebx -> overflow, zero flags)
; c=1 if overflow
;
fp_cmp:		push	eax
		push	ebx

		call	fp_sub			;compare fp eax to fp ebx
		jc	@@exit			;overflow?

		cmp	eax,0			;affect overflow and zero flags
		clc				;c=0

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Floating-point addition/subtraction (fp eax +/- fp ebx -> fp eax)
; c=1 if overflow
;
fp_sub:		xor	ebx,80000000h		;for subtraction, negate fp ebx

fp_add:		push	ecx
		push	edx
		push	esi
		push	edi

		call	fp_unpack_eax		;unpack floats
		call	fp_unpack_ebx

		shr	dl,1			;perform possible mantissa negations
		jnc	@@apos
		neg	eax
@@apos:		shr	dh,1
		jnc	@@bpos
		neg	ebx
@@bpos:
		cmp	esi,edi			;order unpacked floats by exponent
		jge	@@order
		xchg	eax,ebx
		xchg	esi,edi
@@order:
		mov	ecx,esi			;shift lower mantissa right by exponent difference
		sub	ecx,edi
		cmp	ecx,24
		jbe	@@inrange
		xor	ebx,ebx			;out of range, clear lower mantissa
@@inrange:	sar	ebx,cl

		add	eax,ebx			;add mantissas

		cmp	eax,0			;get sign and absolutize mantissa
		mov	dl,0
		jge	@@rpos
		mov	dl,1
		neg	eax
@@rpos:
		call	fp_pack_eax		;pack float, c=1 if overflow

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret
;
;
; Floating-point multiply (fp eax * fp ebx -> fp eax)
; c=1 if overflow
;
fp_mul:		push	edx
		push	esi
		push	edi

		call	fp_unpack_eax		;unpack floats
		call	fp_unpack_ebx

		xor	dl,dh			;get result sign

		add	esi,edi			;add exponents
		sub	esi,127

		push	edx			;multiply mantissas
		mul	ebx
		shl	edx,3
		mov	eax,edx
		pop	edx

		call	fp_pack_eax		;pack float, c=1 if overflow

		pop	edi
		pop	esi
		pop	edx
		ret
;
;
; Floating-point divide (fp eax / fp ebx -> fp eax)
; c=1 if overflow
;
fp_div:		push	edx
		push	esi
		push	edi

		call	fp_unpack_eax		;unpack floats
		call	fp_unpack_ebx

		or	ebx,ebx			;check for divide by 0
		stc
		jz	@@exit

		xor	dl,dh			;get result sign

		sub	esi,edi			;subtract exponents
		add	esi,127

		xor	edi,edi			;divide mantissas
		mov	dh,30
@@div:		cmp	eax,ebx
		jb	@@not
		sub	eax,ebx
@@not:		cmc
		rcl	edi,1
		shl	eax,1
		dec	dh
		jnz	@@div
		mov	eax,edi

		call	fp_pack_eax		;pack float, c=1 if overflow

@@exit:		pop	edi
		pop	esi
		pop	edx
		ret
;
;
; Floating-point power (fp eax to-the-power-of fp ebx --> fp eax)
;
fp_pow:		push	ebx
		call	fp_log2
		pop	ebx
		call	fp_mul
		jc	error_fpo
		jmp	fp_exp2
;
;
; Floating-point square-root (FSQRT(fp eax) --> fp eax)
; c=1 if overflow
;
fp_sqrt:	push	ecx
		push	edx
		push	esi
		push	edi

		cmp	eax,80000000h		;negative numbers not allowed
		ja	error_fpcmbp

		call	fp_unpack_eax		;unpack float

		sub	esi,127			;unbias exponent
		sar	esi,1			;halve root exponent
		jc	@@odd			;if exponent was even, shift mantissa down
		shr	eax,1
@@odd:		add	esi,127-1		;bias and decrement exponent to account for bit29-justification

		or	eax,eax			;sqrt
		jz	@@zero
		mov	[@@sqr],eax
		mov	ebx,80000000h
		xor	ecx,ecx
@@sqrt2:	or	ecx,ebx
		mov	eax,ecx
		mul	eax
		cmp	edx,[@@sqr]
		jbe	@@sqrt3
		xor	ecx,ebx
@@sqrt3:	shr	ebx,1
		jnc	@@sqrt2
		mov	eax,ecx
@@zero:
		xor	edx,edx			;clear sign in dl.0
		call	fp_pack_eax		;pack float, c=1 if overflow
		jc	error_fpo

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret


ddx		@@sqr
;
;
; Floating-point logarithms (LOG2/LOG10/LOG(fp eax) --> fp eax)
; c=1 if overflow
;
fp_log2:	xor	ebx,ebx			;log2, no result scaling
		jmp	fp_logx

fp_log10:	mov	ebx,04D104D42h		;log10 (log2 --> log10)		2^32 * log10(2.0)
		jmp	fp_logx

fp_log:		mov	ebx,0B17217F8h		;log (log2 --> log)		2^32 * log(2.0)

fp_logx:	push	ecx
		push	edx
		push	esi
		push	edi

		call	fp_unpack_eax		;unpack float

		test	dl,1			;cannot be negative
		jnz	error_fpcmbp
		or	eax,eax			;cannot be zero
		jz	error_fpcmbp

		call	cordic_qlog		;perform QLOG on mantissa
		shl	eax,5			;bit31-justify log mantissa

		sub	esi,127			;unbias exponent
		jns	@@pos			;if exponent < 0, (must check sign, not carry, because it could have started negative)
		or	dl,1			;..set negative
		not	esi			;..not exponent
		not	eax			;..not mantissa
@@pos:
		mov	ecx,8			;get number of exponent bits to head mantissa (8..1)
		mov	edi,80h
@@int:		test	esi,edi
		jnz	@@gotint
		shr	edi,1
		loop	@@int
		inc	ecx			;if exponent was 0, single bit
@@gotint:
		shr	eax,cl			;make room at mantissa head
		ror	esi,cl			;position exponent bits at mantissa head
		or	eax,esi			;or exponent bits into mantissa
		shr	eax,3			;bit-28 justify mantissa

		or	ebx,ebx			;log10/log?
		jz	@@noadj
		push	edx			;adjust to another log base
		mul	ebx
		mov	eax,edx
		pop	edx
@@noadj:
		mov	esi,ecx			;get exponent
		add	esi,127			;bias exponent

		call	fp_pack_eax		;pack float

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret
;
;
; Floating-point exponentials (EXP2/EXP10/EXP(fp eax) --> fp eax)
; c=1 if overflow
;
fp_exp2:	xor	ebx,ebx			;exp2, no input scaling
		jmp	fp_expn

fp_exp10:	mov	ebx,0D49A784Ch		;exp10 (exp2 --> exp10)		2^30 / log10(2.0)
		jmp	fp_expn

fp_exp:		mov	ebx,05C551D95h		;exp (exp2 --> exp)		2^30 / log(2.0)

fp_expn:	push	ecx
		push	edx
		push	esi
		push	edi

		call	fp_unpack_eax		;unpack float

		sub	esi,127			;unbias exponent

		or	ebx,ebx			;exp10/exp?
		jz	@@noadj

		push	edx			;adjust to another exp base
		mul	ebx
		shld	edx,eax,2		;shift result by two to compensate for 2<<30, making 2<<32
		mov	eax,edx
		pop	edx

		test	eax,80000000h		;bit29-justify mantissa
		jz	@@ok31
		shr	eax,1
		inc	esi
@@ok31:
		test	eax,40000000h		;bit29-justify mantissa
		jz	@@ok30
		shr	eax,1
		inc	esi
@@ok30:
@@noadj:
		shl	eax,2			;shift mantissa left to msb-justify

		add	esi,1			;get number of whole exponent bits in mantissa head

		cmp	esi,8			;exponent bits cannot exceed +8
		jg	error_fpo

		mov	ecx,esi			;any whole exponent bits in mantissa?
		cmp	ecx,1
		jl	@@shiftdown

		xor	esi,esi			;extract whole exponent bits from mantissa
		shld	esi,eax,cl		;these bits form new exponent
		shl	eax,cl			;msb-justify fractional exponent in mantissa
		jmp	@@cont

@@shiftdown:	neg	ecx			;no whole exponent bits in mantissa
		shr	eax,cl			;shift fractional exponent in mantissa down
		mov	esi,0			;set exponent to 0
@@cont:
		test	dl,1			;if negative
		jz	@@pos
		mov	dl,0			;..set positive
		not	esi			;..not exponent
		not	eax			;..not mantissa
@@pos:
		shr	eax,5			;make bit29-justified QEXP value
		or	eax,29 shl 27
		call	cordic_qexp		;perform QEXP on mantissa

		add	esi,127			;bias exponent

		call	fp_pack_eax		;pack float, c=1 if overflow
		jc	error_fpo

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret
;
;
; Convert integer to floating-point (int eax --> fp eax)
;
fp_float:	push	edx
		push	esi

		mov	edx,eax			;get sign
		shr	edx,31

		or	eax,eax			;if mantissa 0, result 0
		jz	@@exit

		jns	@@pos			;absolutize mantissa
		neg	eax
@@pos:
		mov	esi,32+127		;determine exponent and mantissa
@@exp:		dec	esi
		shl	eax,1
		jnc	@@exp
		rcr	eax,1			;replace leading 1
		shr	eax,2			;bit29-justify mantissa

		call	fp_pack_eax		;pack float

@@exit:		pop	esi
		pop	edx
		ret
;
;
; Convert float to rounded/truncated integer (fp eax --> int eax)
; c=1 if overflow
;
fp_round:	stc
		jmp	fp_rt

fp_trunc:	clc

fp_rt:		push	ecx
		push	edx
		push	esi

		rcl	dh,1			;get round flag in dh.0

		call	fp_unpack_eax		;unpack float
		shl	eax,2			;bit31-justify mantissa

		mov	ecx,30+127		;if exponent > 30, overflow, c=1
		sub	ecx,esi
		stc
		jl	@@exit
		cmp	esi,-1+127		;if exponent 0..30, integer
		jg	@@integer
		mov	eax,0			;if exponent < -1, zero
		jl	@@done
		shr	dh,1			;exponent -1, 1/2 rounds to 1
		rcl	eax,1
		jmp	@@neg

@@integer:	shr	eax,cl			;in range, round and justify
		shr	dh,1
		adc	eax,0
		shr	eax,1

@@neg:		shr	dl,1			;negative?
		jnc	@@pos
		neg	eax
@@pos:
@@done:		clc				;done, c=0

@@exit:		pop	esi			;c=1 if overflow
		pop	edx
		pop	ecx
		ret
;
;
; Unpack eax
;
; dl.0=sign, esi=exponent, eax = mantissa (bit29-justified)
; if mantissa 0, value 0
;
fp_unpack_eax:	shl	eax,1			;get sign a
		rcl	dl,1

		mov	esi,eax			;get exponent a
		shr	esi,24

		shl	eax,8			;get mantissa a

		or	esi,esi			;if exponent not 0, add msb
		jnz	@@nz

		or	eax,eax			;if mantissa 0, done
		jz	@@z

		inc	esi			;adjust exp and mantissa
@@adj:		dec	esi
		shl	eax,1
		jnc	@@adj

@@nz:		stc				;install/replace leading 1
		rcr	eax,1
		shr	eax,2			;bit29-justify mantissa
@@z:
		ret
;
;
; Unpack ebx
;
; dh.0=sign, edi=exponent, ebx = mantissa (bit29-justified)
; if mantissa 0, value 0
;
fp_unpack_ebx:	shl	ebx,1			;get sign b
		rcl	dh,1

		mov	edi,ebx			;get exponent b
		shr	edi,24

		shl	ebx,8			;get mantissa b

		or	edi,edi			;if exponent not 0, add msb
		jnz	@@nz

		or	ebx,ebx			;if mantissa 0, done
		jz	@@z

		inc	edi			;adjust exp and mantissa
@@adj:		dec	edi
		shl	ebx,1
		jnc	@@adj

@@nz:		stc				;install/replace leading 1
		rcr	ebx,1
		shr	ebx,2			;bit29-justify mantissa
@@z:
		ret
;
;
; Pack eax
;
; dl.0=sign, esi=exponent, eax = mantissa (bit29-justified)
; c=1 if overflow
;
fp_pack_eax:	or	eax,eax			;if mantissa 0, result 0, c=0
		jz	@@exit

		add	esi,3			;adjust exponent by mantissa
@@exp:		dec	esi
		shl	eax,1
		jnc	@@exp

		add	eax,100h		;round up mantissa by 0.5
		adc	esi,0			;account for overflow
@@skip:
		cmp	esi,0			;if exponent > 0, pack result
		jg	@@pack

		stc				;exponent =< 0, unnormalized mantissa
		rcr	eax,1			;replace leading 1
@@ushr:		or	esi,esi			;shift unnormalized mantissa right
		jz	@@pack			;...and inc exponent until 0
		shr	eax,1
		inc	esi
		jmp	@@ushr

@@pack:		shr	ah,1			;pack result
		shr	dl,1
		rcl	ah,1
		mov	edx,esi
		mov	al,dl
		ror	eax,9

		cmp	esi,0FFh		;c=1 if overflow
		cmc

@@exit:		ret
;
;
; Restore value pointers
;
restore_value_ptrs:

		push	[value_start]
		pop	[source_start]
		push	[value_finish]
		pop	[source_finish]

		ret


ddx		value_start
ddx		value_finish
;
;
;************************************************************************
;*  Instruction Block Compiler						*
;************************************************************************
;
;
; Compile instruction block
; ebp must hold column
;
compile_top_block:

		mov	[bnest_ptr],0		;reset blocknest ptr
		mov	[bstack_ptr],0		;reset blockstack ptr
		xor	ebp,ebp			;reset column (effectively -1)

		call	compile_block		;compile top block

		mov	al,bc_return_results	;enter return
		jmp	enter_obj


compile_block:	push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		push	ebp			;push current column

cb_loop:	call	get_element_obj		;get element
		jc	@@done			;if eof, done
		cmp	al,type_end		;if end of line, loop
		je	cb_loop
		cmp	al,type_block		;if block designator, back up
		je	@@backup

		call	get_column		;if same or negative indention, back up
		pop	ebp
		push	ebp
		cmp	[column],ebp
		jbe	@@backup

		cmp	al,type_if		;'if' block?
		je	cb_if

		cmp	al,type_ifnot		;'ifnot' block?
		je	cb_if

		cmp	al,type_case		;'case' block?
		je	cb_case

		cmp	al,type_case_fast	;'case_fast' block?
		je	cb_case_fast

		cmp	al,type_repeat		;'repeat' block?
		je	cb_repeat

		call	compile_instruction	;no flow-control structures, compile instruction
		call	get_end			;get end of line
		jmp	cb_loop			;loop

@@backup:	call	back_element		;back up

@@done:		pop	ebp			;pop current column

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		pop	eax
		ret
;
;
; Compile block and check for empty - TESTT not being used
;
;compile_block_check:
;
;		push	ebx
;		push	ecx
;
;		mov	ebx,[obj_ptr]		;get initial obj ptr
;		mov	ecx,[source_start]	;remember block start
;
;		call	compile_block
;
;		cmp	ebx,[obj_ptr]		;if terminal obj ptr same, block empty
;		je	@@error
;
;		pop	ecx
;		pop	ebx
;		ret
;
;
;@@error:	mov	[source_start],ecx
;		mov	[source_finish],ecx
;		jmp	error_bie

;
;
; Compile block - 'if' / 'ifnot'
;
cb_if:		cmp	al,type_if
		lea	ebx,[@@comp_if]
		je	@@if
		lea	ebx,[@@comp_ifnot]
@@if:
		mov	ebp,[column]		;set new column

		mov	al,type_if		;set new 'if' blocknest
		mov	ah,if_limit/16+1	;reserve if_limit + 16 bstack variables
		call	new_bnest

		mov	eax,ebx			;optimize 'if' block
		call	optimize_block

		call	end_bnest		;done, end blocknest
		jmp	cb_loop			;return to compile block loop


@@comp_if:	mov	bl,bc_jz		;'if' entry (jz)
		mov	ecx,1			;reset address count
		jmp	@@cond

@@comp_ifnot:	mov	bl,bc_jnz		;'ifnot' entry (jnz)
		mov	ecx,1			;reset address count
		jmp	@@cond


@@block:	call	compile_block		;compile 'if/ifnot/elseif/elseifnot' block

		call	get_element		;get next element
		jc	@@done			;if eof, done
		call	get_column		;get column
		cmp	[column],ebp		;if lower, done
		jb	@@backup
		cmp	al,type_elseif		;same, 'elseif'?
		mov	bl,bc_jz		;(jz)
		je	@@elsecond
		cmp	al,type_elseifnot	;same, 'elseifnot'?
		mov	bl,bc_jnz		;(jnz)
		je	@@elsecond
		cmp	al,type_else		;same, 'else'?
		je	@@else
@@backup:	call	back_element		;back up, done
		jmp	@@done

@@elsecond:	call	@@jmpout		;'elseif/elseifnot', compile bc_jmp out
		cmp	ecx,if_limit+2		;check 'if' limit
		je	error_loxee		;(+2 accounts for 'if' and 'else' addresses)

@@cond:		call	compile_exp		;compile conditional expression
		call	get_end
		mov	eax,ecx			;compile next address
		call	compile_bstack_branch	;(bl = jz/jnz)
		jmp	@@block


@@else:		call	@@jmpout		;'else', compile bc_jmp out
		call	get_end
		call	compile_block		;compile 'else' block

@@done:		mov	eax,ecx			;set last address
		call	write_bstack_ptr
		mov	eax,0			;set final address
		jmp	write_bstack_ptr	;returns to optimize_block


@@jmpout:	push	ebx
		mov	eax,0			;compile bc_jmp out
		mov	bl,bc_jmp		;(jmp)
		call	compile_bstack_branch
		mov	eax,ecx			;set next address
		call	write_bstack_ptr
		inc	ecx			;inc address count
		pop	ebx
		ret
;
;
; Compile block - 'case'
;
cb_case:	mov	ebp,[column]		;set new column

		mov	al,type_case		;set new 'case' blocknest
		mov	ah,case_limit/16+1	;reserve case_limit + 16 bstack variables
		call	new_bnest

		lea	eax,[@@comp]		;optimize case block
		call	optimize_block

		call	end_bnest		;done, end blocknest
		jmp	cb_loop			;return to compile block loop


@@comp:		mov	eax,0			;compile final address
		call	compile_bstack_address

		call	compile_exp		;compile target value
		call	get_end

		push	[source_ptr]		;save original source ptr
		mov	ecx,0			;reset case count and 'other' block flag in ecx[31]


@@nextcase1:	call	get_element		;first pass builds case branches, get range/value/'other'
		jc	@@done1			;if eof, first pass done
		cmp	al,type_end		;ignore blank lines
		je	@@nextcase1

		call	get_column		;if no indention, first pass done
		call	back_element
		cmp	[column],ebp
		jbe	@@done1

		or	ecx,ecx			;if 'other' already encountered, error
		js	error_omblc

		push	ebp			;save original column
		mov	ebp,[column]		;set new column

		cmp	al,type_other		;'other' case?
		jne	@@notother1
		or	ecx,80000000h		;set 'other' flag
		call	get_element		;skip 'other'
		mov	edx,[source_start]	;save source ptr for 'other' block
		jmp	@@getcolon		;get colon and skip instruction block
@@notother1:
		inc	ecx			;not 'other', must be range/value, inc case count
		mov	eax,ecx
		and	eax,7FFFFFFFh
		cmp	eax,case_limit		;check case limit
		ja	error_loxcase

@@nextrange:	call	compile_range		;compile value/range
		mov	bl,bc_case_range	;(case range)
		je	@@range
		mov	bl,bc_case_value	;(case value)
@@range:	mov	eax,ecx
		and	eax,7FFFFFFFh
		call	compile_bstack_branch	;compile branch
		call	check_comma		;if comma, compound case
		je	@@nextrange

@@getcolon:	call	get_colon		;get ':' after (last) range/value or 'other'
		call	skip_block		;skip instruction block

		pop	ebp			;restore original column
		jmp	@@nextcase1		;get next case
@@done1:

		test	ecx,7FFFFFFFh		;second pass builds case blocks
		jz	error_nce		;if no value/range cases, error

		or	ecx,ecx			;if 'other' case, compile 'other' block after case branches
		jns	@@noother
		mov	[source_ptr],edx	;set source ptr to 'other' block
		call	get_element		;get 'other' to set column
		call	get_column		;get column
		call	get_element		;skip colon
		push	ebp			;save original column
		mov	ebp,[column]		;get 'other' column
		call	compile_block		;compile 'other' case block
		pop	ebp			;restore original column
@@noother:
		mov	al,bc_case_done		;(case done) end of range/value checks
		call	enter_obj

		pop	[source_ptr]		;restore original source pointer
		mov	ecx,0			;reset case count, ready to compile range/value case blocks


@@nextcase2:	call	get_element		;get range/value column
		jc	@@done2			;if eof, second pass done
		cmp	al,type_end		;ignore blank lines
		je	@@nextcase2

		call	get_column		;if no indention, second pass done
		call	back_element
		cmp	[column],ebp
		jbe	@@done2

		push	ebp			;save original column
		mov	ebp,[column]		;set new column

		cmp	al,type_other		;if 'other' case, skip (already compiled)
		jne	@@notother2
		call	get_element		;skip 'other'
		call	get_element		;skip colon
		call	skip_block		;skip 'other' block
		jmp	@@skipped
@@notother2:
@@skiprange:	call	skip_range		;skip range/value (already compiled)
		call	check_comma
		je	@@skiprange
		call	get_element		;skip colon

		inc	ecx			;write block address
		mov	eax,ecx
		and	eax,7FFFFFFFh
		call	write_bstack_ptr

		call	compile_block		;compile range/value case block

		mov	al,bc_case_done		;(casedone)
		call	enter_obj

@@skipped:	pop	ebp			;restore original column
		jmp	@@nextcase2		;get next case


@@done2:	mov	eax,0			;write final address
		jmp	write_bstack_ptr
;
;
; Compile block - 'case_fast'
;
cb_case_fast:	mov	ebp,[column]		;set new column

		mov	al,type_case_fast	;set new 'case_fast' blocknest
		mov	ah,case_fast_limit/16+1	;reserve case_fast_limit + 16 bstack variables
		call	new_bnest

		lea	eax,[@@comp]		;optimize case_fast block
		call	optimize_block

		call	end_bnest		;done, end blocknest
		jmp	cb_loop			;return to compile block loop


@@final_addr	=	0
@@table_ptr	=	1
@@source_ptr	=	2
@@min_value	=	3
@@max_value	=	4
@@table_address	=	5


@@comp:		mov	eax,@@final_addr	;compile final address
		call	compile_bstack_address

		call	compile_exp		;compile target value
		call	get_end

		mov	al,bc_case_fast_init	;enter case_fast init
		call	enter_obj

		mov	eax,0			;enter spacer for rflong
		call	enter_obj_long

		mov	eax,0			;enter spacer for rfword
		call	enter_obj_word

		mov	eax,@@table_ptr		;remember jump table start
		call	write_bstack_ptr

		mov	ebx,[source_ptr]	;remember source ptr
		mov	eax,@@source_ptr
		call	write_bstack

		mov	eax,@@min_value		;reset min value
		mov	ebx,7FFFFFFFh
		call	write_bstack

		mov	eax,@@max_value		;reset max value
		mov	ebx,80000000h
		call	write_bstack


		mov	ecx,0			;reset case count
		mov	dl,0			;reset 'other' block flag

@@nextcase1:	call	get_element		;first pass determines min and max values
		jc	@@done1			;if eof, first pass done
		cmp	al,type_end		;ignore blank lines
		je	@@nextcase1

		call	get_column		;if no indention, first pass done
		call	back_element
		cmp	[column],ebp
		jbe	@@done1

		cmp	dl,1			;if 'other' already encountered, error
		je	error_omblc

		push	ebp			;save original column
		mov	ebp,[column]		;set new column

		cmp	al,type_other		;'other' case?
		jne	@@notother1
		mov	dl,1			;set 'other' flag
		call	get_element		;skip 'other'
		jmp	@@getcolon1		;get colon and skip instruction block
@@notother1:
		inc	ecx			;not 'other', must be case, inc case count
		mov	eax,ecx
		cmp	eax,case_fast_limit	;check case_fast limit
		ja	error_loxcasef

@@nextrange1:	call	get_range		;get value/range and update min and max values
		call	@@updateminmax
		mov	eax,ebx
		call	@@updateminmax
		call	check_comma		;if comma, compound case
		je	@@nextrange1

@@getcolon1:	call	get_colon		;get ':' after (last) value/range
		call	skip_block		;skip instruction block

		pop	ebp			;restore original column
		jmp	@@nextcase1		;get next case
@@done1:

		cmp	ecx,0			;if no value/range cases, error
		je	error_nce

		mov	eax,@@table_ptr		;write min value into rflong position
		call	read_bstack
		push	ebx
		mov	eax,@@min_value
		call	read_bstack
		pop	eax
		mov	[dword obj-6+eax],ebx

		push	eax			;write max-min+1 value into rfword position
		push	ebx
		mov	eax,@@max_value
		call	read_bstack
		pop	eax
		sub	ebx,eax
		inc	ebx
		pop	eax
		mov	[word obj-2+eax],bx

		mov	edx,ecx			;get 'other' case in dx

		mov	ecx,0			;init jump table with 'other' case	TESTT use enter_obj_word, instead, to avoid obj overflow
@@inittable:	mov	[word obj+eax+ecx*2],dx
		inc	ecx
		cmp	ecx,ebx
		jbe	@@inittable
		shl	ecx,1			;update obj_ptr
		add	ecx,eax
		mov	[obj_ptr],ecx

		mov	eax,@@source_ptr	;point back to source after 'case_fast' line
		call	read_bstack
		mov	[source_ptr],ebx


		mov	ecx,0			;reset case count

@@nextcase2:	call	get_element		;second pass fills in table and compiles blocks
		jc	@@done2			;if eof, second pass done
		cmp	al,type_end		;ignore blank lines
		je	@@nextcase2

		call	get_column		;if no indention, second pass done
		call	back_element
		cmp	[column],ebp
		jbe	@@done2

		push	ebp			;save original column
		mov	ebp,[column]		;set new column

		cmp	al,type_other		;'other' case?
		jne	@@notother2
		call	get_element		;skip 'other'
		jmp	@@getcolon2		;get colon and compile instruction block
@@notother2:
@@nextrange2:	call	get_range		;get value/range and write into jump table
		sub	ebx,eax			;get range count into ebx
		inc	ebx
		push	ebx
		push	eax			;get table start position into eax
		mov	eax,@@min_value
		call	read_bstack
		pop	eax
		sub	eax,ebx
		push	eax
		mov	eax,@@table_ptr
		call	read_bstack
		pop	eax
		shl	eax,1
		add	eax,ebx			;table pointer in eax
		pop	ebx			;entry count in ebx

@@filltable:	cmp	[word obj+eax],dx	;make sure entries are unclaimed with 'other' case
		jne	error_cfiinu
		mov	[word obj+eax],cx	;fill table entries with case number
		add	eax,2
		dec	ebx
		jnz	@@filltable

		call	check_comma		;if comma, compound case
		je	@@nextrange2

@@getcolon2:	call	get_colon		;get ':' after value/range

		mov	eax,ecx			;write block address for this case
		add	eax,@@table_address
		call	write_bstack_ptr

		call	compile_block		;compile instruction block

		inc	ecx			;inc case count

		mov	eax,ecx			;write block address for potential missing 'other' case
		add	eax,@@table_address	;(points to next/last bc_case_fast_done)
		call	write_bstack_ptr

		mov	eax,@@table_ptr		;make sure address offset will fit into jump table word
		call	read_bstack
		mov	eax,[obj_ptr]
		sub	eax,ebx
		cmp	eax,0FFFFh
		ja	error_cfbex

		mov	al,bc_case_fast_done	;(case fast done)
		call	enter_obj

		pop	ebp			;restore original column
		jmp	@@nextcase2		;get next case
@@done2:
		mov	eax,@@final_addr	;write final address
		call	write_bstack_ptr


		mov	eax,@@table_ptr		;replace case numbers with block offsets in jump table
		call	read_bstack
		movzx	ecx,[word obj-2+ebx]	;get jump table count in ecx
		inc	ecx
		mov	edx,ebx			;get jump table offset in edx

@@replace:	movzx	eax,[word obj+ebx]	;get case index from jump table
		push	ebx
		add	eax,@@table_address	;use case index to look up case block offset
		call	read_bstack
		mov	eax,ebx
		sub	eax,edx
		pop	ebx
		mov	[word obj+ebx],ax	;write case block offset into jump table
		add	ebx,2			;loop until all cases + 'other' handled
		loop	@@replace

		ret



@@updateminmax:	push	eax			;update min and max values with eax
		push	ebx
		push	ecx

		mov	ecx,eax

		mov	eax,@@min_value		;update min value
		call	read_bstack
		cmp	ecx,ebx
		jge	@@notmin
		mov	ebx,ecx
		call	write_bstack
@@notmin:
		mov	eax,@@max_value		;update max value
		call	read_bstack
		cmp	ecx,ebx
		jle	@@notmax
		mov	ebx,ecx
		call	write_bstack
@@notmax:
		call	read_bstack		;check for span violation
		mov	ecx,ebx
		mov	eax,@@min_value
		call	read_bstack
		sub	ecx,ebx
		cmp	ecx,255
		ja	error_cfvmbw

		pop	ecx
		pop	ebx
		pop	eax
		ret
;
;
; Compile block - 'repeat'
;
; bstack[0] = 'next' address
; bstack[1] = 'quit' address
; bstack[2] = loop address
;
cb_repeat:	mov	ebp,[column]		;set new column

		mov	al,type_repeat		;set new 'repeat' blocknest
		mov	ah,1			;reserve 16 bstack variables
		call	new_bnest

		call	get_element		;determine repeat type

		cmp	al,type_end		;plain (may be post-while/until)?
		je	@@plain

		cmp	al,type_while		;pre-while?
		mov	cl,bc_jz		;(jz)
		je	@@prewu

		cmp	al,type_until		;pre-until?
		mov	cl,bc_jnz		;(jnz)
		je	@@prewu

		call	back_element		;count/var
		push	[source_ptr]
		call	skip_exp
		call	get_element
		pop	[source_ptr]
		cmp	al,type_end		;count?
		je	@@count
		cmp	al,type_with		;count WITH var?
		je	@@countvar


		mov	al,type_repeat_var	;redo blocknext type to repeat-var
		call	redo_bnest
		lea	eax,[@@varcomp]		;optimize repeat-var block
		jmp	@@optimize

@@varcomp:	mov	eax,2			;compile loop address
		call	compile_bstack_address
		call	get_variable		;get variable (ecx, esi, edi hold variable data)
		call	get_from		;get 'from'
		push	[source_ptr]		;save source pointer to 'from' expression
		call	skip_exp		;skip 'from' expression
		call	get_to			;get 'to'
		call	compile_exp		;compile 'to' expression
		call	get_step_or_end		;check for 'step' or end
		mov	dh,bc_repeat_var_init_1	;if no 'step', ready to compile setup + repeat_var_init_1
		jne	@@varcompstep1
		call	compile_exp		;compile 'step' expression
		call	get_end
		mov	dh,bc_repeat_var_init	;ready to compile setup + repeat_var_init
@@varcompstep1:	pop	eax			;point to 'from' expression
		call	compile_oos_exp		;compile 'from' expression
		call	compile_var_assign
		mov	eax,2			;set loop address
		call	write_bstack_ptr
		call	compile_block		;compile repeat block
		mov	eax,0			;set 'next' address
		call	write_bstack_ptr
		mov	dh,bc_repeat_var_loop	;compile setup + repeat_var_loop
		call	compile_var_assign
		mov	eax,1			;set 'quit' address
		jmp	write_bstack_ptr


@@countvar:	mov	al,type_repeat_count_var;redo blocknest type to repeat-count-var
		call	redo_bnest
		lea	eax,[@@countvarcomp]
		jmp	@@optimize

@@countvarcomp:	mov	eax,2			;compile loop address
		call	compile_bstack_address
		call	compile_exp		;compile count expression
		call	get_with		;skip 'WITH'
		call	get_variable		;get variable (ecx, esi, edi hold variable data)
		call	get_end
		mov	dh,bc_repeat_var_init_n	;compile setup + repeat_var_init_n
		call	compile_var_assign
		mov	eax,2			;set loop address
		call	write_bstack_ptr
		call	compile_block		;compile repeat block
		mov	eax,0			;set 'next' address
		call	write_bstack_ptr
		mov	dh,bc_repeat_var_loop	;compile setup + repeat_var_loop
		call	compile_var_assign
		mov	eax,1			;set 'quit' address
		jmp	write_bstack_ptr


@@count:	mov	al,type_repeat_count	;redo blocknest type to repeat-count
		call	redo_bnest
		lea	eax,[@@countcomp]	;optimize repeat-count block
		jmp	@@optimize

@@countcomp:	call	compile_exp_check_con	;compile count expression, check for constant
		pushf
		call	get_end
		popf
		jnz	@@countnc		;if not constant, compile tjz at start of block
		mov	ebx,[con_value]		;get constant
		cmp	ebx,0			;if 0, skip block (compile nothing)
		je	skip_block
		call	compile_constant	;not 0, compile constant and skip tjz
		jmp	@@countnz
@@countnc:	mov	bl,bc_tjz		;(tjz)
		mov	eax,1			;compile forward branch ('quit')
		call	compile_bstack_branch
@@countnz:	mov	eax,2			;set loop address
		call	write_bstack_ptr
		call	compile_block		;compile repeat block
		mov	eax,0			;set 'next' address
		call	write_bstack_ptr
		mov	bl,bc_djnz		;(djnz)
		mov	eax,2			;compile backward branch (loop)
		call	compile_bstack_branch
		mov	eax,1			;set 'quit' address
		jmp	write_bstack_ptr


@@prewu:	lea	eax,[@@prewucomp]	;optimize repeat-while/until block
		jmp	@@optimize

@@prewucomp:	mov	eax,0			;set 'next' address
		call	write_bstack_ptr
		call	compile_exp		;compile pre-while/until expression
		call	get_end
		mov	bl,cl			;(jz/jnz)
		mov	eax,1			;compile forward branch ('quit')
		call	compile_bstack_branch
		call	compile_block		;compile repeat block
		mov	bl,bc_jmp		;(jmp)
		mov	eax,0			;compile backward branch ('next')
		call	compile_bstack_branch
		mov	eax,1			;set 'quit' address
		jmp	write_bstack_ptr


@@plain:	mov	cl,0			;assume plain (not post-while/until)
		lea	eax,[@@plaincomp]	;optimize repeat-plain block
		jmp	@@optimize

@@plaincomp:	mov	eax,2			;set loop address
		call	write_bstack_ptr
		cmp	cl,1			;post-while/until?
		je	@@plainwu
		mov	eax,0			;set plain 'next' address
		call	write_bstack_ptr
@@plainwu:	call	compile_block		;compile repeat block
		call	get_element		;get next element
		jc	@@plainloop		;if eof, plain
		call	get_column		;get column
		cmp	[column],ebp		;if lower, backup, plain
		jb	@@plainbackup
		cmp	al,type_while		;post-while?
		mov	bl,bc_jnz		;(jnz)
		je	@@plainpost
		cmp	al,type_until		;post-until?
		mov	bl,bc_jz		;(jz)
		jne	@@plainbackup
@@plainpost:	mov	cl,1			;set post-while/until flag
		mov	eax,0			;set post-while/until 'next' address
		call	write_bstack_ptr
		call	compile_exp		;compile post-while/until expression
		call	get_end
		jmp	@@plainpost2		;compile post-while/until loop
@@plainbackup:	call	back_element		;lower/unknown, backup
@@plainloop:	mov	bl,bc_jmp		;compile plain loop (jmp)
@@plainpost2:	mov	eax,2			;compile backward branch (loop)
		call	compile_bstack_branch
		mov	eax,1			;set 'quit' address
		jmp	write_bstack_ptr


@@optimize:	call	optimize_block		;optimize repeat block
		call	end_bnest		;done, end blocknest
		jmp	cb_loop			;return to compile block loop
;
;
; Optimizing block compiler
; eax must point to compiler routine
; ebp must hold column
;
optimize_block:	push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		push	[source_ptr]		;push pointers
		push	[obj_ptr]

		xor	esi,esi			;init size to impossible

@@compile:	pop	[obj_ptr]		;restore pointers
		pop	[source_ptr]
		push	[source_ptr]
		push	[obj_ptr]

		push	eax
		push	esi

		call	eax			;call compiler routine

		pop	esi
		pop	eax

		cmp	esi,[obj_ptr]		;(re)compile until same size twice
		mov	esi,[obj_ptr]
		jne	@@compile

		pop	esi			;pop pointers
		pop	esi

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		ret
;
;
; Blocknest routines
;
new_bnest:	push	ebx
		push	ecx
		push	edi

		mov	ebx,[bnest_ptr]		;new blocknest (al = type, ah = stacksize >> 4)
		cmp	ebx,block_nest_limit
		je	error_loxnbe
		inc	[bnest_ptr]

		mov	[bnest_type+ebx],al	;set blockstack base
		mov	edi,[bstack_ptr]
		mov	[bstack_base+ebx*4],edi

		movzx	ecx,ah			;set blockstack ptr
		shl	ecx,4
		add	[bstack_ptr],ecx
		cmp	[bstack_ptr],block_stack_limit
		ja	error_bnso

		mov	eax,07FFFFh		;init bstack values to max forward
		shl	edi,2
		add	edi,offset bstack
	rep	stosd

		pop	edi
		pop	ecx
		pop	ebx
		ret


redo_bnest:	mov	ebx,[bnest_ptr]		;redo blocknest type (al=type)
		mov	[bnest_type-1+ebx],al
		ret


end_bnest:	dec	[bnest_ptr]		;end blocknest
		mov	ebx,[bnest_ptr]
		push	[bstack_base+ebx*4]	;reset blockstack ptr
		pop	[bstack_ptr]
		ret


ddx		bnest_ptr			;blocknest data
dbx		bnest_type,block_nest_limit
;
;
; Blockstack routines
;
write_bstack:	push	ebx			;write blockstack (eax=index, ebx=value)
		mov	ebx,[bnest_ptr]
		mov	ebx,[bstack_base-4+ebx*4]
		add	ebx,eax
		pop	[bstack+ebx*4]
		ret


write_bstack_ptr:

		push	ebx			;write obj_ptr to blockstack (eax=index)
		mov	ebx,[bnest_ptr]
		mov	ebx,[bstack_base-4+ebx*4]
		add	ebx,eax
		push	[obj_ptr]
		pop	[bstack+ebx*4]
		pop	ebx
		ret


read_bstack:	mov	ebx,[bnest_ptr]		;read blockstack (eax=index, ebx=value on exit)
		mov	ebx,[bstack_base-4+ebx*4]
		add	ebx,eax
		mov	ebx,[bstack+ebx*4]
		ret


compile_bstack_address:				;compile address from bstack (eax=index)

		call	read_bstack		;get address

		cmp	ebx,0FFFFh		;long?
		jbe	@@notlong
		mov	al,bc_con_rflong
		call	enter_obj
		mov	eax,ebx
		jmp	enter_obj_long
@@notlong:
		cmp	ebx,0FFh		;word?
		jbe	@@notword
		mov	al,bc_con_rfword
		call	enter_obj
		mov	ax,bx
		jmp	enter_obj_word
@@notword:
		mov	al,bc_con_rfbyte	;byte
		call	enter_obj
		mov	al,bl
		jmp	enter_obj


compile_bstack_branch:				;compile branch from bstack (eax=index, bl=branch bytecode)

		push	ebx			;save bytecode in bl
		call	read_bstack		;get address into ebx
		pop	eax			;restore bytecode into al
		jmp	compile_branch		;compile branch


ddx		bstack_ptr			;blockstack data
ddx		bstack_base,block_nest_limit
ddx		bstack,block_stack_limit
;
;
;************************************************************************
;*  Instruction Compiler						*
;************************************************************************
;
;
; Compile instruction
;
compile_instruction:

		mov	ch,0			;(no result required, since 'abort' provides result)
		mov	cl,bc_drop_trap		;(drop anchor - trap)
		cmp	al,type_back		;\obj{[]}.method({param,...}), \method({param,...}), \var({param,...}){:results} ?
		je	ct_try

		mov	ch,0			;(no result required)
		mov	cl,bc_drop		;(drop anchor)
		cmp	al,type_obj		;obj{[]}.method({param,...})?
		je	ct_objpub
		cmp	al,type_method		;method({param,...})?
		je	ct_method

		cmp	al,type_i_next_quit	;instruction NEXT/QUIT ?
		je	ci_next_quit

		cmp	al,type_i_return	;instruction RETURN ?
		je	ci_return

		cmp	al,type_i_abort		;instruction ABORT ?
		je	ci_abort

		cmp	al,type_i_cogspin	;instruction COGSPIN ?
		mov	cl,bc_coginit
		je	ct_cogspin_taskspin

		cmp	al,type_i_taskspin	;instruction TASKSPIN ?
		mov	cl,bc_taskspin
		je	ct_cogspin_taskspin	;(c=0 for no push)

		cmp	al,type_debug		;DEBUG?
		je	ci_debug

		cmp	al,type_i_flex		;flex instruction?
		jne	@@notflex
		test	bh,flex_results		;must not return any result
		jnz	error_ticobu
		jmp	compile_flex
@@notflex:
		cmp	al,type_asm_dir		;inline assembly?
		jne	@@notinline
		cmp	bl,dir_org		;ORG?
		je	compile_org
		cmp	bl,dir_orgh		;ORGH?
		je	compile_orgh
@@notinline:
		cmp	al,type_inc		;++var ?
		mov	dh,bc_var_inc		;(assign pre-inc)
		je	compile_var_pre

		cmp	al,type_dec		;--var ?
		mov	dh,bc_var_dec		;(assign pre-dec)
		je	compile_var_pre

		cmp	al,type_rnd		;??var ?
		mov	dh,bc_var_rnd		;(assign pre-dec)
		je	compile_var_pre

		call	sub_to_neg		;unary var assignment?
		call	fsub_to_fneg
		call	check_unary
		je	ci_unary

		mov	edx,[source_start]	;save source start for compile_var_multi and ct_method_ptr

		cmp	al,type_under		;check for _{[type_con_int|type_con_struct]},... := param(s),...
		jne	@@notwriteskip
		call	back_element
		call	check_write_skip
		call	get_comma
		jmp	compile_var_multi
@@notwriteskip:
		call	check_var		;variable ?
		jne	error_eaiov		;if not, error

		call	get_element_obj		;get element after variable

		cmp	al,type_comma		;var,... := param(s),... ?
		je	compile_var_multi

		push	eax			;check for structure operation
		mov	al,ch
		call	is_struct
		pop	eax
		jne	@@notstruct
		cmp	[compiled_struct_flags],3
		je	@@notstruct
		cmp	al,type_assign		;structure := ?
		jne	@@notstructass
		cmp	[compiled_struct_size],15*4
		jbe	compile_var_multi	;if 15 longs or less, do stack assignment
		mov	ah,bc_bytemove		;else, do copy
		jmp	compile_struct_copy
@@notstructass:	cmp	al,type_swap		;structure :=: ?
		mov	ah,bc_byteswap
		je	compile_struct_copy
		cmp	al,type_til		;structure~ ?
		mov	ah,bc_con_n+1		;(0)
		je	compile_struct_fill
		cmp	al,type_tiltil		;structure~~ ?
		mov	ah,bc_con_n+0		;(-1)
		je	compile_struct_fill
		jmp	error_eastott
@@notstruct:
		cmp	al,type_assign		;var := ?
		je	compile_var_multi

		cmp	al,type_left		;var({param,...}){:results} ?
		jne	@@notvarleft
		mov	ch,0			;(no result required)
		mov	cl,bc_drop		;(drop anchor)
		jmp	ct_method_ptr
@@notvarleft:
		cmp	al,type_inc		;var++ ?
		mov	dh,bc_var_inc
		je	compile_var_assign

		cmp	al,type_dec		;var-- ?
		mov	dh,bc_var_dec
		je	compile_var_assign

		call	check_lognot		;var!! ?
		mov	dh,bc_var_lognot
		je	compile_var_assign

		call	check_bitnot		;var! ?
		mov	dh,bc_var_bitnot
		je	compile_var_assign

		cmp	al,type_til		;var~ ?
		mov	dl,bc_con_n+1
		je	compile_var_clrset_inst

		cmp	al,type_tiltil		;var~~ ?
		mov	dl,bc_con_n
		je	compile_var_clrset_inst

		call	check_binary		;var binary op assign (w/push)?
		jne	@@notbin
		call	check_equal		;check for '=' after binary op
		jne	@@notbin
		call	check_assign		;verify that assignment is allowed
		jne	error_tocbufa
		shr	ebx,16
		sub	bl,bc_lognot-bc_lognot_write
		mov	dh,bl
		mov	dl,2
		call	compile_exp
		jmp	compile_var
@@notbin:
		call	back_element		;no post-var modifier, back up

		call	back_element		;error, back up to variable
		call	get_element_obj
		jmp	error_vnao
;
;
; Compile 'struct1 := struct2' or 'struct1 :=: struct2'
;
compile_struct_copy:

		push	eax			;got struct1
		push	[compiled_struct_size]

		call	compile_var_addr	;compile @struct1

		call	get_struct_variable	;get struct2

		pop	eax			;make sure structs are same size
		cmp	[compiled_struct_size],eax
		jne	error_smbss
		push	eax

		call	compile_var_addr	;compile @struct2

		pop	ebx			;compile common struct size
		call	compile_constant

		pop	eax			;enter hub bytecode bc_bytemove or bc_byteswap
		mov	al,ah
		jmp	enter_hub_bytecode
;
;
; Compile struct~ or struct~~
;
compile_struct_fill:

		push	[compiled_struct_size]	;got struct

		call	compile_var_addr	;compile @struct

		mov	al,ah			;enter bc_con_n for 0 or -1
		call	enter_obj

		pop	ebx			;compile struct size
		call	compile_constant

		mov	al,bc_bytefill		;enter hub bytecode bc_bytefill
		jmp	enter_hub_bytecode
;
;
; Compile instruction - 'next'/'quit'
; on entry: bl=0 for 'next', bl=1 for 'quit'
;
ci_next_quit:	mov	ecx,[bnest_ptr]		;get blocknest ptr
		mov	edx,0			;reset pop count

@@find:		cmp	ecx,0			;find repeat block
		je	error_tioawarb

		mov	al,[bnest_type-1+ecx]	;get blocknest type
		mov	ah,bc_jmp		;get default branch for 'quit'

		cmp	al,type_repeat		;'repeat' blocknest?
		je	@@got

		cmp	al,type_repeat_var	;'repeat-var' blocknest?
		je	@@repvar
		cmp	al,type_repeat_count_var;'repeat-count-var' blocknest?
		jne	@@notrepvar
@@repvar:	cmp	bl,0			;'next' needs no pops
		je	@@got
		add	edx,4*4			;'quit' needs 4 long pops
		jmp	@@got
@@notrepvar:
		cmp	al,type_repeat_count	;'repeat-count' blocknest?
		jne	@@notrepcount
		mov	ah,bc_jnz		;'quit' uses bc_jnz since non-0 value is on stack (no need to pop)
		jmp	@@got
@@notrepcount:
		cmp	al,type_case		;allow nesting within 'case' block(s)
		jne	@@notcase
		add	edx,2*4			;add 2 long pops for each nested 'case'
		jmp	@@ignore
@@notcase:
		cmp	al,type_case_fast	;allow nesting within 'case_fast' block(s)
		jne	@@notcasefast
		add	edx,1*4			;add 1 long pop for each nested 'case_fast'
		jmp	@@ignore
@@notcasefast:
		cmp	al,type_if		;ignore 'if' blocknest(s)
		je	@@ignore

		jmp	error_internal		;(should never happen)

@@ignore:	dec	ecx			;check next lower blocknest until repeat block found
		jmp	@@find


@@got:		cmp	edx,0			;compile any pops
		je	@@nopops
		cmp	edx,1*4			;single pop?
		jne	@@multipops
		mov	al,bc_pop
		call	enter_obj
		jmp	@@nopops
@@multipops:	mov	al,bc_pop_rfvar		;multiple pops
		call	enter_obj
		sub	edx,4			;account for final manual long pop in interpreter
		push	eax
		mov	eax,edx			;enter adjusted pop count
		call	compile_rfvar
		pop	eax
@@nopops:
		mov	ecx,[bstack_base-4+ecx*4]

		cmp	bl,1			;compile 'next'/'quit' branch
		je	@@quit

		mov	al,bc_jmp		;'next' (jmp)
		mov	ebx,[bstack+0+ecx*4]
		jmp	compile_branch

@@quit:		mov	al,ah			;'quit' (jmp/jnz)
		mov	ebx,[bstack+4+ecx*4]
		jmp	compile_branch
;
;
; Compile instruction - 'return'
;
ci_return:	call	get_element		;preview next element
		call	back_element
		cmp	al,type_end		;if end, no arg(s)
		mov	al,bc_return_results
		je	@@enter

		mov	ecx,[sub_results]	;get number of results
		jecxz	@@error			;if no results, error

		call	compile_parameters_np	;compile parameters without parentheses

		mov	al,bc_return_args

@@enter:	jmp	enter_obj


@@error:	jmp	error_eeol		;error, something after 'return', but method has no result(s)
;
;
; Compile instruction - 'abort'
;
ci_abort:	call	get_element		;preview next element
		call	back_element
		cmp	al,type_end		;if end, no arg
		mov	al,bc_abort_0
		je	@@enter

		call	compile_exp		;arg, compile expression
		mov	al,bc_abort_arg

@@enter:	jmp	enter_obj
;
;
; Compile instruction - SEND()
;
ci_send:	call	get_left		;get '('
		call	check_right		;make sure '(' not followed by ')'
		je	error_esendd

@@trynext:	mov	ecx,0			;check for string of bytes
		mov	edx,[source_ptr]	;remember source pointer

@@trybytes:	call	get_element_obj		;constant byte?
		cmp	al,type_con_int
		jne	@@notbyte
		cmp	ebx,0FFh
		ja	@@notbyte
		inc	ecx
		call	check_comma
		je	@@trybytes

@@notbyte:	mov	[source_ptr],edx	;set source pointer

		cmp	ecx,2			;if two or more bytes, compile for bc_call_send_bytes
		jb	@@tryother

		mov	al,bc_call_send_bytes
		call	enter_obj
		mov	eax,ecx
		call	compile_rfvar
@@enterbytes:	call	get_element_obj
		mov	al,bl
		call	enter_obj
		cmp	ecx,1
		je	@@nocomma
		call	get_comma
@@nocomma:	loop	@@enterbytes
		jmp	@@checkmore

@@tryother:	call	compile_parameter_send	;compile SEND parameter
		cmp	eax,0			;if SEND parameter returned no value, check for more parameters
		je	@@checkmore
		mov	al,bc_call_send		;value on stack, compile bc_call_send
		call	enter_obj

@@checkmore:	call	get_comma_or_right
		je	@@trynext

		ret
;
;
; Compile ORG inline assembly block - first handle ORG operand(s)
;
compile_org:	mov	ecx,000h		;ready default cog origin
		mov	edx,inline_org_limit	;ready default cog origin limit
		call	check_end		;if end, use defaults
		je	@@org
		call	get_value_int		;get cog origin value
		cmp	ebx,inline_org_limit
		ja	error_icaexl
		mov	ecx,ebx
		call	check_comma		;check for comma
		jne	@@orgend
		call	get_value_int		;get cog origin limit value
		cmp	ebx,inline_org_limit
		ja	error_icaexl
		mov	edx,ebx
@@orgend:	call	get_end			;get end
@@org:
		mov	al,bc_hub_bytecode	;enter ORGH bytecodes
		call	enter_obj
		mov	al,bc_org
		call	enter_obj

		mov	ax,cx			;enter origin
		call	enter_obj_word

		mov	ax,0			;enter placeholder for number of longs, minus 1
		call	enter_obj_word

		push	[obj_ptr]		;remember obj_ptr

		shl	ecx,2			;set inline cog origin and limit
		mov	[inline_cog_org],ecx
		shl	edx,2
		mov	[inline_cog_org_limit],edx

		mov	[orgh],0		;set org mode
		call	compile_inline_block	;compile inline block

		pop	ebx			;get original obj_ptr

@@pad:		mov	eax,ebx			;make inline block a whole number of longs
		xor	eax,[obj_ptr]
		and	al,11b
		jz	@@long
		mov	al,0
		call	enter_obj
		jmp	@@pad
@@long:
		mov	ecx,[obj_ptr]		;compute number of longs
		sub	ecx,ebx
		shr	ecx,2

		jz	error_isie		;if inline block is empty, error

		dec	ecx			;store number of longs minus 1 into placeholder
		mov	[word obj-2+ebx],cx

		ret
;
;
; Compile ORGH inline assembly block
;
compile_orgh:	call	get_end			;get end

		mov	al,bc_hub_bytecode	;enter ORGH bytecodes
		call	enter_obj
		mov	al,bc_orgh
		call	enter_obj

		mov	ax,0			;enter placeholder for number of longs
		call	enter_obj_word

		push	[obj_ptr]		;remember obj_ptr

		mov	[inline_cog_org],000h shl 2		;set cog origin and limit
		mov	[inline_cog_org_limit],1F8h shl 2

		mov	[orgh],1		;set orgh mode
		call	compile_inline_block	;compile inline block

		pop	ebx			;get original obj_ptr

@@pad:		mov	eax,ebx			;make inline block a whole number of longs
		xor	eax,[obj_ptr]
		and	al,11b
		jz	@@long
		mov	al,0
		call	enter_obj
		jmp	@@pad
@@long:
		mov	ecx,[obj_ptr]		;compute number of longs
		sub	ecx,ebx
		shr	ecx,2

		jz	error_isie		;if inline block is empty, error
		cmp	ecx,0FFFFh
		ja	error_isil

		mov	[word obj-2+ebx],cx	;store number of longs into placeholder

		ret
;
;
; Compile multi-variable assignment - var / _{[type_con_int|type_con_struct]},... := param(s),...
;
compile_var_multi:

		mov	[source_ptr],edx	;repoint to initial variable

		mov	ecx,0			;scan 'var / _{[type_con_int|type_con_struct]},...' and remember source_ptr's
		mov	edx,0			;ecx = long count, edx = variable count

@@scan:		push	[source_ptr]		;save source pointer

		call	check_write_skip	;if '_{[type_con_int|type_con_struct]}', got long count in eax
		je	@@next

		push	ecx			;not '_{[type_con_int|type_con_struct]}', get variable
		call	get_variable
		mov	al,ch
		pop	ecx
		call	is_struct		;if not structure, single long
		mov	eax,1
		jne	@@next
		cmp	[compiled_struct_flags],3	;if structure byte/word/long, single long
		je	@@next
		mov	eax,[compiled_struct_size]	;structure, must fit within 15 longs
		call	check_struct_stack_fit
		add	eax,11b			;convert bytes to enveloping longs
		shr	eax,2
@@next:		add	ecx,eax			;track long count
		inc	edx			;track variable count
		call	check_comma
		je	@@scan

		call	get_assign		;get ":='

		call	compile_parameters_np	;compile parameters (long count in ecx)

		mov	ecx,edx			;get variable count
		mov	edx,[source_ptr]	;remember source_ptr

@@write:	pop	[source_ptr]		;compile variable writes
		push	ecx
		push	edx
		call	check_write_skip	;if '_{[type_con_int|type_con_struct]}', just pop value(s)
		jne	@@var
		cmp	eax,1			;single or multiple pop(s)?
		je	@@singlepop
		push	eax			;multiple pops
		mov	al,bc_pop_rfvar
		call	enter_obj
		pop	eax
		dec	eax			;account for final manual long pop in interpreter
		shl	eax,2
		call	compile_rfvar
		jmp	@@cont
@@singlepop:	mov	al,bc_pop		;single pop
		call	enter_obj
		jmp	@@cont
@@var:		call	compile_var_write	;else, write value to variable
@@cont:		pop	edx
		pop	ecx
		loop	@@write

		mov	[source_ptr],edx	;restore source_ptr
		ret
;
;
; Check al for '_' or '_[type_con_int|type_con_struct]'
; on entry, al=type, ebx=value
; on exit, z=1 if '_' or '_[type_con_int|type_con_struct]' with enveloping long count in eax
;
check_write_skip:

		call	check_under		;if not '_', exit with z=0
		jne	@@not

		call	check_leftb		;got '_', check for '['
		mov	eax,1
		jne	@@got			;if just '_', single long

		call	get_element_obj		;got '_[', check for integer constant
		cmp	al,type_con_int
		jne	@@notint
		mov	eax,ebx
		cmp	eax,1
		jb	@@interr
		cmp	eax,15
		jbe	@@gotint
@@interr:	jmp	error_cmbf1t15
@@notint:
		call	back_element		;check for struct
		push	ecx
		push	edx
		push	esi
		push	edi
		call	get_struct_and_size
		call	check_struct_stack_fit
		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		add	eax,11b			;get enveloping long count
		shr	eax,2

@@gotint:	call	get_rightb		;get ']'

@@got:		cmp	al,al			;z=1

@@not:		ret
;
;
; Compile instruction - unary var assignment
;
ci_unary:	call	check_assign		;verify that assignment is allowed
		jne	error_tocbufa
		call	get_equal		;get '='
		shr	ebx,16			;compile var assignment
		mov	dh,bl
		sub	dh,bc_lognot-bc_lognot_write
		jmp	compile_var_pre
;
;
;********************************
;*  DEBUG Instruction Compiler  *
;********************************
;
;
; DEBUG byte commands:
;
; 00000000	end				end of DEBUG commands
; 00000001	asm				set asm mode
; 00000010	IF(cond)			abort if cond = 0
; 00000011	IFNOT(cond)			abort if cond <> 0
; 00000100	cogn				output "CogN  " with possible timestamp
; 00000101	chr				output chr
; 00000110	str				output string
; 00000111	DLY(ms)				delay for ms
; 00001000	PC_KEY(ptr)			get key
; 00001001	PC_MOUSE(ptr)			get mouse
; 00001010	C_Z_pre				ouput ", C=? Z=?"
; 00001011	C_Z				ouput "C=? Z=?"
;
; ______00	', ' + zstring + ' = ' + data	specifiers for BOOL..SBIN_LONG_ARRAY
; ______01	       zstring + ' = ' + data
; ______10	                  ', ' + data
; ______11	                         data
;
; 001000__	BOOL(val)			boolean
; 001001__	ZSTR(ptr)			z-string, in quotes for show
; 001010__	<empty>
; 001011__	FDEC(val)			floating-point
; 001100__	FDEC_REG_ARRAY(ptr,len)		floating-point
; 001101__	LSTR(ptr,len)			length-string, in quotes for show
; 001110__	<empty>
; 001111__	FDEC_ARRAY(ptr,len)		floating-point
;
; 010000__	UDEC(val)			unsigned decimal
; 010001__	UDEC_BYTE(val)
; 010010__	UDEC_WORD(val)
; 010011__	UDEC_LONG(val)
; 010100__	UDEC_REG_ARRAY(ptr,len)
; 010100__	UDEC_BYTE_ARRAY(ptr,len)
; 010110__	UDEC_WORD_ARRAY(ptr,len)
; 010111__	UDEC_LONG_ARRAY(ptr,len)
;
; 011000__	SDEC(val)			signed decimal
; 011001__	SDEC_BYTE(val)
; 011010__	SDEC_WORD(val)
; 011011__	SDEC_LONG(val)
; 011100__	SDEC_REG_ARRAY(ptr,len)
; 011101__	SDEC_BYTE_ARRAY(ptr,len)
; 011110__	SDEC_WORD_ARRAY(ptr,len)
; 011111__	SDEC_LONG_ARRAY(ptr,len)
;
; 100000__	UHEX(val)			unsigned hex
; 100001__	UHEX_BYTE(val)
; 100010__	UHEX_WORD(val)
; 100011__	UHEX_LONG(val)
; 100100__	UHEX_REG_ARRAY(ptr,len)
; 100101__	UHEX_BYTE_ARRAY(ptr,len)
; 100110__	UHEX_WORD_ARRAY(ptr,len)
; 100111__	UHEX_LONG_ARRAY(ptr,len)
;
; 101000__	SHEX(val)			signed hex
; 101001__	SHEX_BYTE(val)
; 101010__	SHEX_WORD(val)
; 101011__	SHEX_LONG(val)
; 101100__	SHEX_REG_ARRAY(ptr,len)
; 101101__	SHEX_BYTE_ARRAY(ptr,len)
; 101110__	SHEX_WORD_ARRAY(ptr,len)
; 101111__	SHEX_LONG_ARRAY(ptr,len)
;
; 110000__	UBIN(val)			unsigned binary
; 110001__	UBIN_BYTE(val)
; 110010__	UBIN_WORD(val)
; 110011__	UBIN_LONG(val)
; 110100__	UBIN_REG_ARRAY(ptr,len)
; 110101__	UBIN_BYTE_ARRAY(ptr,len)
; 110110__	UBIN_WORD_ARRAY(ptr,len)
; 110111__	UBIN_LONG_ARRAY(ptr,len)
;
; 111000__	SBIN(val)			signed binary
; 111001__	SBIN_BYTE(val)
; 111010__	SBIN_WORD(val)
; 111011__	SBIN_LONG(val)
; 111100__	SBIN_REG_ARRAY(ptr,len)
; 111101__	SBIN_BYTE_ARRAY(ptr,len)
; 111110__	SBIN_WORD_ARRAY(ptr,len)
; 111111__	SBIN_LONG_ARRAY(ptr,len)
;
;
count0		dc_end		'lower DEBUG commands
count		dc_asm
count		dc_if
count		dc_ifnot
count		dc_cogn
count		dc_chr
count		dc_str
count		dc_dly
count		dc_pc_key
count		dc_pc_mouse
count		dc_c_z_pre
count		dc_c_z
;
;
; Check if DEBUG is enabled and okay to proceed
; z=1 if okay, z=0 if not okay
;
check_debug:	push	ebx
		push	ecx

		cmp	[debug_mode],0		;debug mode?
		je	@@disabled

		cmp	[debug_disable],0	;debug disabled?
		jne	@@disabled

		call	check_leftb		;check for [gatebit]
		jne	@@enabled
		call	get_value_int		;gatebit must be 0..31
		cmp	ebx,31
		ja	error_dmbmb
		cmp	[debug_mask_defined],0	;DEBUG_MASK must be defined
		je	error_dmmbd
		call	get_rightb
		mov	cl,bl			;check if gatebit set in mask
		mov	eax,1
		shl	eax,cl
		test	[debug_mask],eax
		jnz	@@enabled		;if gatebit set, enabled

@@disabled:	or	al,1			;disabled, z=0
		jmp	@@done

@@enabled:	xor	al,al			;enabed, z=1

@@done:		pop	ecx
		pop	ebx
		ret
;
;
; Compile DEBUG for Spin2
;
ci_debug:	mov	[debug_first],1		;set first flag
		mov	[debug_record_size],0	;reset debug record size
		mov	[@@tickmode],0		;reset tick mode
		mov	[@@stack],0		;reset run-time stack depth

		call	check_debug		;if debug disabled, skip to end of line
		jne	skip_to_end

		call	check_left		;debug enabled, check for '('
		je	@@left

		call	get_end			;no '(', make sure end of line
		call	back_element
		mov	al,bc_debug		;enter DEBUG bytecode
		call	enter_obj
		mov	al,0			;enter rfvar value for stack popping
		call	enter_obj
		mov	al,0			;enter BRK code for debugger
		jmp	enter_obj

@@left:		call	check_right		;'(', if ')' then empty
		je	@@enterdebug

		mov	eax,[source_ptr]	;check for '`'
		add	eax,[source]
		cmp	[byte eax],'`'
		jne	@@nottick		;if no '`', not tick mode

		inc	[@@tickmode]		;set tick mode

@@tickstr:	mov	eax,[source_ptr]	;enter string
		call	debug_tick_string
		jne	@@enterdebug		;if ')' and end of line, enter debug data

@@tickcommand:	call	get_element		;got '`', check for debug command
		cmp	al,type_debug_cmd
		je	@@tickcmd
		cmp	al,type_if
		je	@@isif
		cmp	al,type_ifnot
		je	@@isifnot
		cmp	al,type_op
		jne	@@notbool
		cmp	bl,op_ternary
		je	@@tickbool
@@notbool:	cmp	al,type_dot
		je	@@tickfdec
		cmp	al,type_left
		je	@@tickdec
		cmp	al,type_dollar
		je	@@tickhex
		cmp	al,type_percent
		je	@@tickbin
		cmp	al,type_pound
		je	@@tickchr
		jmp	error_ebackcmd

@@tickbool:	mov	bl,00100011b		;'?', do BOOL_
		jmp	@@tickcmd

@@tickfdec:	mov	bl,00101111b		;'.', do FDEC_
		jmp	@@tickcmd

@@tickdec:	dec	[source_ptr]		;'(', back up and do SDEC_
		mov	bl,01100011b
		jmp	@@tickcmd

@@tickhex:	mov	bl,10100011b		;'$', do UHEX_
		jmp	@@tickcmd

@@tickbin:	mov	bl,11000011b		;'%', do UBIN_
		jmp	@@tickcmd

@@tickchr:	call	get_left		;'#', do chr
@@tickchrlp:	mov	bl,dc_chr		;non-string value, enter chr command
		call	debug_enter_byte
		call	compile_exp		;compile value
		call	@@incstack		;account for expression
		call	get_comma_or_right
		je	@@tickchrlp

@@ticknext:	mov	esi,[source_ptr]	;check for '`' or ')'
		add	esi,[source]
		mov	al,[esi]

		cmp	al,'`'			;if '`', command follows
		jne	@@ticknottick
		inc	[source_ptr]
		jmp	@@tickcommand
@@ticknottick:
		cmp	al,')'			;')', if not followed by end-of-line, part of string
		jne	@@tickstr
		push	[source_ptr]
		call	get_right
		call	check_end
		pop	[source_ptr]
		jne	@@tickstr
		call	back_element		;')' followed by end-of-line, DEBUG done
		jmp	@@enterdebug
@@nottick:
		call	get_element		;check for initial IF/IFNOT command to inhibit output
		mov	bl,dc_if
		cmp	al,type_if
		je	@@if
		mov	bl,dc_ifnot
		cmp	al,type_ifnot
		jne	@@notif
@@if:		call	@@singleparam		;compile single-parameter command
		mov	bl,dc_cogn		;enter cogn command
		call	debug_enter_byte
		jmp	@@checknext		;check for more DEBUG data/commands
@@notif:
		mov	bl,dc_cogn		;no initial IF/IFNOT, enter cogn command
		call	debug_enter_byte
		call	back_element		;back up to initial element


@@next:		call	get_element		;get next element

		cmp	al,type_if		;check for IF command
		jne	@@notif2
@@isif:		mov	bl,dc_if		;enter IF command
		call	@@singleparam		;compile single-parameter command
		jmp	@@checknext		;check for more DEBUG data/commands
@@notif2:
		cmp	al,type_ifnot		;check for IFNOT command
		jne	@@notif3
@@isifnot:	mov	bl,dc_ifnot		;enter IFNOT command
		call	@@singleparam		;compile single-parameter command
		jmp	@@checknext		;check for more DEBUG data/commands
@@notif3:
		cmp	al,type_debug_cmd	;check for debug command
		jne	@@notcmd

@@tickcmd:	cmp	bl,dc_dly		;DLY command?
		je	@@dkm
		cmp	bl,dc_pc_key		;PC_KEY command?
		je	@@dkm
		cmp	bl,dc_pc_mouse		;PC_MOUSE command?
		jne	@@notdkm
@@dkm:		call	@@singleparam		;compile single-parameter command
		call	get_right		;get ')' to ensure last command
		jmp	@@enterdebug		;enter DEBUG code and record
@@notdkm:
		cmp	bl,dc_c_z_pre		;C_Z command?
		jne	@@notcz
		add	bl,[debug_first]	;if first flag set, skip ', ' output
		call	debug_enter_byte	;enter C_Z command
		mov	[debug_first],0		;clear first flag
		jmp	@@checknext		;check for more DEBUG data/commands
@@notcz:
		test	bl,10h			;dual-parameter command?
		jnz	@@dualparam

		test	bl,02h			;single-parameter command, show source?
		jnz	@@spsimple


		call	get_left		;verbose, get '('

@@spverbose:	lea	eax,[@@skipparam]	;get expression source string pointers
		call	debug_exp_source
		call	compile_parameter	;compile a parameter, may have multiple return values
		mov	ecx,eax			;get number of return values
		call	debug_enter_byte_flag	;enter first single-parameter command
		call	@@incstack		;account for first parameter
		call	debug_verbose_string	;enter expression source string
		dec	ecx			;if more data, do comma+space+data
		jz	@@spvnext
		or	bl,02h			;switch to comma+space+data mode
@@spvmulti:	call	debug_enter_byte_flag	;enter single-parameter command
		call	@@incstack		;account for nth parameter
		loop	@@spvmulti		;loop for additional parameters
@@spvnext:	and	bl,0FCh			;restore original command
		call	get_comma_or_right	;check for more parameters in command
		je	@@spverbose
		jmp	@@checknext		;check for more DEBUG data/commands


@@spsimple:	call	compile_parameters_mptr	;compile parameters, returns parameter count in ecx
		or	ecx,ecx			;make sure not zero parameters
		jz	error_eaet
@@spsmulti:	call	debug_enter_byte_flag	;enter command for each parameter
		call	@@incstack		;account for one parameter
		loop	@@spsmulti
		jmp	@@checknext		;check for more DEBUG data/commands


@@dualparam:	test	bl,02h			;dual-parameter command, verbose?
		jnz	@@dpsimple


		call	get_left		;verbose, get '('

@@dpverbose:	lea	eax,[@@skipparam]	;get expression source string pointers
		call	debug_exp_source
		mov	ecx,2			;compile two parameters
		call	compile_parameters_np
		call	debug_enter_byte_flag	;enter dual-parameter command
		call	@@incstack		;account for two parameters
		call	@@incstack
		call	debug_verbose_string	;enter expression source string
		call	get_comma_or_right	;check for more parameters in command
		je	@@dpverbose
		jmp	@@checknext		;check for more DEBUG data/commands


@@dpsimple:	call	compile_parameters_mptr	;compile parameters, returns parameter count in ecx
		or	ecx,ecx			;make sure not zero parameters
		jz	error_eaet
		shr	ecx,1			;make sure an even number of parameters
		jc	error_eaenop
@@dpsmulti:	call	debug_enter_byte_flag	;enter command for each parameter pair
		call	@@incstack		;account for two parameters
		call	@@incstack
		loop	@@dpsmulti
		jmp	@@checknext		;check for more DEBUG data/commands


@@notcmd:	call	back_element		;not debug command, back up
		call	debug_check_string	;if byte(s) then make string
		jc	@@checknext		;if string, check for more DEBUG data/commands

		mov	bl,dc_chr		;non-string value, enter chr command
		call	debug_enter_byte
		call	compile_exp		;compile value
		call	@@incstack		;account for expression
		mov	[debug_first],1		;set first flag (followed by @@checknext)

@@checknext:	cmp	[@@tickmode],0		;tick mode?
		jne	@@ticknext
		call	get_comma_or_right	;more DEBUG data/commands?
		je	@@next


@@enterdebug:	mov	al,bc_debug		;end of DEBUG data/commands, enter DEBUG bytecode
		call	enter_obj

		mov	al,[@@stack]		;enter rfvar value for stack popping
		call	enter_obj

		call	debug_enter_record	;enter record into debug data, get brk code in al

		jmp	enter_obj		;enter BRK code


@@singleparam:	call	debug_enter_byte	;compile single-parameter command, enter command
		mov	ecx,1			;compile parameter
		call	compile_parameters
		jmp	@@incstack		;account for parameter


@@skipparam:	push	[obj_ptr]		;skip parameter which may return multiple values
		call	compile_parameter
		pop	[obj_ptr]
		ret

@@incstack:	add	[@@stack],4		;inc stack counter
		js	error_dditl		;used via rfvar, so don't let msb get set
		ret


dbx		@@tickmode
dbx		@@stack
;
;
; Compile DEBUG for assembler
;
ci_debug_asm:	mov	[debug_first],1		;set first flag
		mov	[debug_record_size],0	;reset debug record size
		mov	[@@tickmode],0		;reset tick mode

		call	check_right		;empty?
		je	@@enterdebug

		mov	bl,dc_asm		;enter asm-mode command
		call	debug_enter_byte

		mov	eax,[source_ptr]	;check for '`'
		add	eax,[source]
		cmp	[byte eax],'`'
		jne	@@nottick		;if no '`', not tick mode

		inc	[@@tickmode]		;set tick mode

@@tickstr:	mov	eax,[source_ptr]	;enter string
		call	debug_tick_string
		jne	@@enterdebug		;if ')' and end of line, enter debug data

@@tickcommand:	call	get_element		;got '`', check for debug command
		cmp	al,type_debug_cmd
		je	@@tickcmd
		cmp	al,type_if
		je	@@isif
		cmp	al,type_ifnot
		je	@@isifnot
		cmp	al,type_op
		jne	@@notbool
		cmp	bl,op_ternary
		je	@@tickbool
@@notbool:	cmp	al,type_dot
		je	@@tickfdec
		cmp	al,type_left
		je	@@tickdec
		cmp	al,type_dollar
		je	@@tickhex
		cmp	al,type_percent
		je	@@tickbin
		cmp	al,type_pound
		je	@@tickchr
		jmp	error_ebackcmd

@@tickbool:	mov	bl,00100011b		;'?', do BOOL_
		jmp	@@tickcmd

@@tickfdec:	mov	bl,00101111b		;'.', do FDEC_
		jmp	@@tickcmd

@@tickdec:	dec	[source_ptr]		;'(', back up and do SDEC_
		mov	bl,01100011b
		jmp	@@tickcmd

@@tickhex:	mov	bl,10100011b		;'$', do UHEX_
		jmp	@@tickcmd

@@tickbin:	mov	bl,11000011b		;'%', do UBIN_
		jmp	@@tickcmd

@@tickchr:	call	get_left		;'#', do chr
@@tickchrlp:	mov	bl,dc_chr		;non-string value, enter chr command
		call	debug_enter_byte
		call	@@compileparam		;compile value
		call	get_comma_or_right
		je	@@tickchrlp

@@ticknext:	mov	esi,[source_ptr]	;check for '`' or ')'
		add	esi,[source]
		mov	al,[esi]

		cmp	al,'`'			;if '`', command follows
		jne	@@ticknottick
		inc	[source_ptr]
		jmp	@@tickcommand
@@ticknottick:
		cmp	al,')'			;')', if not followed by end-of-line, part of string
		jne	@@tickstr
		push	[source_ptr]
		call	get_right
		call	check_end
		pop	[source_ptr]
		jne	@@tickstr
		call	back_element		;')' followed by end-of-line, DEBUG done
		jmp	@@enterdebug
@@nottick:
		call	get_element		;check for initial IF/IFNOT command to inhibit output
		mov	bl,dc_if
		cmp	al,type_if
		je	@@if
		mov	bl,dc_ifnot
		cmp	al,type_ifnot
		jne	@@notif
@@if:		call	@@singleparam		;compile single-parameter command
		mov	bl,dc_cogn		;enter cogn command
		call	debug_enter_byte
		jmp	@@checknext		;check for more DEBUG data/commands
@@notif:
		mov	bl,dc_cogn		;no initial IF/IFNOT, enter cogn command
		call	debug_enter_byte
		call	back_element		;back up to initial element


@@next:		call	get_element		;get next element

		cmp	al,type_if		;check for IF command
		jne	@@notif2
@@isif:		mov	bl,dc_if		;enter IF command
		call	@@singleparam		;compile single-parameter command
		jmp	@@checknext		;check for more DEBUG data/commands
@@notif2:
		cmp	al,type_ifnot		;check for IFNOT command
		jne	@@notif3
@@isifnot:	mov	bl,dc_ifnot		;enter IFNOT command
		call	@@singleparam		;compile single-parameter command
		jmp	@@checknext		;check for more DEBUG data/commands
@@notif3:
		cmp	al,type_debug_cmd	;check for debug command
		jne	@@notcmd

@@tickcmd:	cmp	bl,dc_dly		;DLY command?
		je	@@dkm
		cmp	bl,dc_pc_key		;PC_KEY command?
		je	@@dkm
		cmp	bl,dc_pc_mouse		;PC_MOUSE command?
		jne	@@notdkm
@@dkm:		call	@@singleparam		;compile single-parameter command
		call	get_right		;get ')' to ensure last command
		jmp	@@enterdebug		;enter DEBUG code and record
@@notdkm:
		cmp	bl,dc_c_z_pre		;C_Z command?
		jne	@@notcz
		add	bl,[debug_first]	;if first flag set, skip ', ' output
		call	debug_enter_byte	;enter C_Z command
		mov	[debug_first],0		;clear first flag
		jmp	@@checknext		;check for more DEBUG data/commands
@@notcz:
		call	get_left		;BOOL..SBIN_LONG_ARRAY, get '('

@@param:	call	debug_enter_byte_flag	;enter command with flag

		test	bl,02h			;verbose command?
		jnz	@@notverbose
		lea	eax,[@@getparam]	;verbose, compile parameter source string
		call	debug_exp_source
		call	debug_verbose_string
@@notverbose:
		test	bl,10h			;compile one or two parameters
		jz	@@oneparam
		call	@@compileparam
		call	get_comma
@@oneparam:	call	@@compileparam

		call	get_comma_or_right	;check for more parameters in command
		je	@@param

		jmp	@@checknext		;check for more DEBUG data/commands


@@notcmd:	call	back_element		;not debug command, back up
		call	debug_check_string	;if byte(s) then make string
		jc	@@checknext		;if string, check for more DEBUG data/commands

		mov	bl,dc_chr		;non-string value, enter chr command
		call	debug_enter_byte
		call	@@compileparam		;compile value
		mov	[debug_first],1		;set first flag (followed by @@checknext)

@@checknext:	cmp	[@@tickmode],0		;tick mode?
		jne	@@ticknext
		call	get_comma_or_right	;more DEBUG data/commands?
		je	@@next


@@enterdebug:	jmp	debug_enter_record	;enter debug record, return BRK code in al



@@singleparam:	call	debug_enter_byte	;compile single-parameter command, enter command
		call	get_left		;get '('
		call	@@compileparam		;compile parameter
		jmp	get_right		;get ')'


@@compileparam:	push	ebx

		call	@@getparam		;compile register/#immediate parameter
		jz	@@immparam		;#immediate?

		cmp	ebx,3FFh		;register, 10-bit
		ja	error_rpcx
		or	ebx,8000h
@@wordparam:	ror	ebx,8
		call	debug_enter_byte
		rol	ebx,8
		jmp	@@lastbyte

@@immparam:	test	ebx,0FFFFC000h		;#immediate, 14-bit?
		jz	@@wordparam

		push	ebx			;#immediate, 32-bit
		mov	bl,40h
		call	debug_enter_byte
		pop	ebx
		call	debug_enter_byte
		shr	ebx,8
		call	debug_enter_byte
		shr	ebx,8
		call	debug_enter_byte
		shr	ebx,8
@@lastbyte:	call	debug_enter_byte

		pop	ebx
		ret


@@getparam:	call	check_pound		;get parameter, z=1 if #immediate
		pushf
		mov	bl,10b
		call	try_value_int
		popf
		ret


dbx		@@tickmode
;
;
; Get debug expression source start and finish
; eax must point to expression skipper
;
debug_exp_source:

		push	ebx
		push	[source_ptr]		;save source_ptr

		call	skip_element_obj	;get start

		push	[source_start]
		pop	[debug_src_start]

		call	back_element		;get finish
		call	eax
		call	back_element
		call	skip_element_obj

		push	[source_finish]
		pop	[debug_src_finish]

		pop	[source_ptr]		;restore source_ptr
		pop	ebx
		ret
;
;
; Enter expression string for verbose command
;
debug_verbose_string:

		push	ebx			;enter expression string for verbose command
		push	ecx
		push	esi

		mov	ecx,[debug_src_finish]	;get expression string length
		sub	ecx,[debug_src_start]

		mov	esi,[debug_src_start]	;get expression string start
		add	esi,[source]

@@chr:		lodsb				;enter string chrs
		mov	bl,al
		call	debug_enter_byte
		loop	@@chr

		mov	bl,0			;zero-terminate string
		call	debug_enter_byte

		pop	esi
		pop	ecx
		pop	ebx

		ret
;
;
; Enter command with first flag update
;
debug_enter_byte_flag:

		or	bl,[debug_first]	;incorporate first flag
		call	debug_enter_byte	;enter command
		and	bl,0FEh			;switch to pre-comma mode
		mov	[debug_first],0		;clear first flag

		ret
;
;
; If chrs expressed in source, enter string
;
debug_check_string:

		mov	ecx,0
		mov	edx,[source_ptr]

@@trybyte:	call	get_element_obj		;constant chr?
		cmp	al,type_con_int
		jne	@@notchr
		or	ebx,ebx
		je	@@notchr
		cmp	ebx,0FFh
		ja	@@notchr
		inc	ecx
		call	check_comma
		je	@@trybyte

@@notchr:	mov	[source_ptr],edx	;point to first string byte / restore source_ptr

		jecxz	@@nostring		;if no bytes, exit with c=1

		mov	bl,dc_str		;enter debug string command
		call	debug_enter_byte

		jmp	@@string		;enter string bytes
@@stringlp:	call	get_comma
@@string:	call	get_element_obj
		call	debug_enter_byte
		loop	@@stringlp

		mov	bl,0			;zero-terminate string
		call	debug_enter_byte

		mov	[debug_first],1		;set first flag

		stc				;c=1 signifies string compiled
		ret

@@nostring:	clc				;c=0 signifies no string
		ret
;
;
; Enter tick-mode string
; on entry, eax must point to start of string
; on exit, [source_ptr] points after string
;
debug_tick_string:

		push	ebx
		push	ecx
		push	esi

		mov	esi,eax			;esi points within source
		add	esi,[source]

		push	esi			;remember start of string

		inc	esi			;point to chr after start of string
		xor	ecx,ecx			;reset counter

@@next:		lodsb				;gather string bytes
		inc	ecx			;inc counter

		cmp	al,0			;if end of file, error
		je	error_os

		cmp	al,')'			;if ')' followed by end of line, end of string
		jne	@@noteol
		mov	eax,esi
		sub	eax,[source]
		mov	[source_ptr],eax
		call	get_element
		cmp	al,type_end
		jne	@@next
		jmp	@@eos
@@noteol:
		cmp	al,'`'			;if '`', end of string
		jne	@@next

@@eos:		pop	esi			;end of string, got counter, repoint to start of string

		mov	bl,dc_str		;enter debug string command
		call	debug_enter_byte

@@chr:		lodsb				;enter string bytes
		mov	bl,al
		call	debug_enter_byte
		loop	@@chr

		mov	bl,0			;zero-terminate string
		call	debug_enter_byte

		lodsb				;get byte after string

		sub	esi,[source]		;point to chr after '`' or last ')'
		mov	[source_ptr],esi

		cmp	al,'`'			;z=1 if '`', z=0 if ')' and end of line

		mov	[debug_first],1		;set first flag

		pop	esi
		pop	ecx
		pop	ebx
		ret
;
;
; Enter byte into command buffer
; bl must hold byte
;
debug_enter_byte:

		push	eax

		movzx	eax,[debug_record_size]

		inc	[debug_record_size]
		jz	error_dditl

		mov	[debug_record+eax],bl

		pop	eax
		ret
;
;
; Enter record into debug data
; on exit, al holds BRK code
;
debug_enter_record:

		mov	bl,0			;zero-terminate record
		call	debug_enter_byte

		mov	ebx,1			;get debug index into ebx (1..255)
@@getindex:	movzx	eax,[word debug_data+ebx*2]
		or	eax,eax			;if index empty, make new entry
		je	@@newindex
		lea	esi,[debug_record]	;if index already points to an identical command string, use it
		lea	edi,[debug_data+eax]	;(this gets around needing to patch objects)
		movzx	ecx,[debug_record_size]
	repe	cmpsb
		je	@@oldindex
		inc	bl			;check next index
		jnz	@@getindex
		jmp	error_dditl

@@newindex:	movzx	edx,[word debug_data]	;make new index, enter destination address of command string
		mov	[word debug_data+ebx*2],dx

		movzx	eax,[debug_record_size]	;make sure room for command string
		add	eax,edx
		cmp	eax,debug_data_limit
		ja	error_dditl
		mov	[word debug_data],ax

		lea	esi,[debug_record]	;enter debug record
		lea	edi,[debug_data+edx]
		movzx	ecx,[debug_record_size]
	rep	movsb

@@oldindex:	mov	al,bl			;get BRK code into al

		ret
;
;
; Data
;
ddx		debug_src_start
ddx		debug_src_finish

dbx		debug_first
dbx		debug_record_size
dbx		debug_record,100h
;
;
;************************************************************************
;*  Expression Compiler							*
;************************************************************************
;
; Basic expression syntax rules:     i.e.  4000 / (ABS x * 5) // 127) + 1
;
;	Any one of these...	Must be followed by any one of these...
;	------------------------------------------------------------------
;	term			binary operator
;	)			)
;				? (ternary operator)
;				<end>
;
;	Any one of these...	Must be followed by any one of these... *
;	------------------------------------------------------------------
;	unary operator		term
;	binary operator		unary operator
;	(			(
;	? (ternary operator)
;
;				* initial element of an expression
;
;
; Compile expression with sub-expressions and check for constant
; z=1 if constant with value in con_value and expression skipped
;
compile_exp_check_con:

		push	[obj_ptr]		;save obj_ptr
		pop	[@@con_ptr]

		call	compile_exp		;compile expression, may be constant
		jnz	@@nope

		push	[@@con_ptr]		;constant, restore obj_ptr, z=1
		pop	[obj_ptr]
@@nope:
		ret


ddx		@@con_ptr
ddx		con_value
;
;
; Compile expression with sub-expressions
; z=1 if constant with value in con_value
;
compile_exp:	push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		call	try_spin2_con_exp	;first, try to resolve constant expression
		jc	@@notcon		;if failed, compile non-constant expression

		mov	[con_value],ebx		;constant, update con_value
		call	compile_constant	;compile constant
		xor	al,al			;z=1
		jmp	@@exit
@@notcon:
		call	@@topexp		;compile non-constant expression
		or	al,1			;z=0

@@exit:		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		pop	eax
		ret


@@topexp:	mov	dl,ternary_precedence+1	;expression, set ternary precedence + 1

@@subexp:	push	ebx
		push	edx

		dec	dl			;lower precedence, if was 0, compile term
		js	@@term			;else, compile sub-expression

		call	@@subexp		;compile first sub-expression
@@next:		call	get_element		;get ternary, binary or <end>
		call	check_ternary		;ternary?
		je	@@ternary
		call	check_binary		;if not binary, back up
		jne	@@backup

		cmp	bh,dl			;binary, if not current precedence, back up
		jne	@@backup
		call	@@subexp		;compile next sub-expression
		call	@@enterop		;enter unary operator
		jmp	@@next			;check for next binary

@@ternary:	cmp	dl,ternary_precedence	;ternary, if not ternary precedence, back up
		jne	@@backup
		call	@@topexp		;got 'exp ?', get 'exp:exp'
		call	get_colon
		call	@@topexp
		mov	al,bc_ternary		;(ternary)
		call	enter_obj
		jmp	@@done

@@term:		call	get_element_obj		;term, get '@@', unary, '(', or term
		call	is_plus			;ignore leading '+' or '+.'
		je	@@term
		call	negcon_to_con		;convert -constant to constant
		call	sub_to_neg		;convert subtract to negate
		call	fsub_to_fneg		;convert floating-point subtract to floating-point negate
		cmp	al,type_atat
		je	@@atat
		call	check_unary
		je	@@unary
		cmp	al,type_left
		je	@@left
		call	compile_term
		jmp	@@done

@@atat:		mov	dl,0			;@@, set highest precedence
		call	@@subexp		;compile sub-expression
		mov	al,bc_add_pbase		;compile add-pbase
		call	enter_obj
		jmp	@@done

@@unary:	call	check_equal		;unary, check for var assignment
		jne	@@unarynormal
		call	check_assign		;verify that assignment is allowed
		jne	error_tocbufa
		shr	ebx,16
		sub	bl,bc_lognot-bc_lognot_write_push
		mov	dh,bl
		mov	dl,2
		call	get_variable
		call	compile_var
		jmp	@@done

@@unarynormal:	mov	dl,bh			;unary, set unary's precedence
		call	@@subexp		;compile sub-expression
		call	@@enterop		;enter unary operator
		jmp	@@done

@@left:		call	@@topexp		;'(', compile expression
		call	get_right		;get ')'
		jmp	@@done

@@backup:	call	back_element		;end of (sub-)expression, back up

@@done:		pop	edx
		pop	ebx
		ret


@@enterop:	test	ebx,opc_hubcode		;enter operator, check if hubcode
		jz	@@enterop2
		mov	al,bc_hub_bytecode
		call	enter_obj
@@enterop2:	mov	eax,ebx			;math bc_??? in ebx[23:16]
		shr	eax,16
		jmp	enter_obj
;
;
; Compile term
;
compile_term:	cmp	al,type_con_int		;constant integer?
		je	compile_constant

		cmp	al,type_con_float	;constant float?
		je	compile_constant

		cmp	al,type_sizeof		;SIZEOF ?
		je	ct_sizeof

		cmp	al,type_constr		;STRING ?
		je	ct_constr

		cmp	al,type_conlstr		;LSTRING ?
		je	ct_conlstr

		cmp	al,type_size		;BYTE/WORD/LONG ?
		jne	@@notsize
		call	check_left
		jne	@@notsize
		jmp	ct_condata
@@notsize:
		cmp	al,type_float		;FLOAT ?
		jne	@@notfloat
		mov	ebx,fc_float
		jmp	compile_flex
@@notfloat:
		cmp	al,type_round		;ROUND ?
		jne	@@notround
		mov	ebx,fc_round
		jmp	compile_flex
@@notround:
		cmp	al,type_trunc		;TRUNC ?
		jne	@@nottrunc
		mov	ebx,fc_trunc
		jmp	compile_flex
@@nottrunc:
		mov	ch,0			;(no result required, since 'abort' provides result)
		mov	cl,bc_drop_trap_push	;(drop anchor - trap, push)
		cmp	al,type_back		;\obj{[]}.method({param,...}), \method({param,...}), \var({param,...}){:results} ?
		je	ct_try

		mov	ch,1			;(single result required)
		mov	cl,bc_drop_push		;(drop anchor - push)
		cmp	al,type_obj		;obj{[]}.method({param,...})?
		je	ct_objpub
		cmp	al,type_method		;method({param,...}) ?
		je	ct_method

		cmp	al,type_i_look		;instruction LOOKUP/LOOKDOWN ?
		je	ct_look

		cmp	al,type_i_cogspin	;instruction COGSPIN ?
		mov	cl,bc_coginit_push
		je	ct_cogspin_taskspin

		cmp	al,type_i_taskspin	;instruction TASKSPIN ?
		mov	cl,bc_taskspin
		stc				;(c=1 for push)
		je	ct_cogspin_taskspin

		cmp	al,type_i_flex		;flex instruction?
		jne	@@notflex
		cmp	ebx,fc_coginit		;if fc_coginit, change to fc_coginit_push
		jne	@@notcoginit
		mov	ebx,fc_coginit_push
@@notcoginit:	mov	al,bh			;must return one result
		and	al,flex_results
		cmp	al,1 shl flex_results_shift
		jne	error_etmrasr
		jmp	compile_flex
@@notflex:
		cmp	al,type_at		;@"string", @obj{[]}.method, @method, @hubvar ?
		je	ct_at

		cmp	al,type_upat		;^@var
		je	ct_upat

		cmp	al,type_inc		;++var ?
		mov	dh,bc_var_preinc_push
		je	compile_var_pre

		cmp	al,type_dec		;--var ?
		mov	dh,bc_var_predec_push
		je	compile_var_pre

		cmp	al,type_rnd		;??var ?
		mov	dh,bc_var_rnd_push
		je	compile_var_pre

		mov	edx,[source_start]	;save source start for ct_method_ptr

		call	check_var		;var ?
		jne	error_eaet

		mov	al,ch				;struct var ?
		call	is_struct
		jne	@@notstruct
		cmp	[compiled_struct_flags],3	;if byte/word/long member, treat as regular variable
		je	@@notstruct
		cmp	[compiled_struct_size],4	;structure, if it fits in a long, read it
		jbe	@@readvar
		call	get_element			;doesn't fit in a long, only "==" or "<>" allowed
		cmp	al,type_op
		jne	@@structerr
		cmp	bl,op_e
		je	compile_struct_compare
		cmp	bl,op_ne
		je	compile_struct_compare
@@structerr:	jmp	error_eeone
@@notstruct:
		call	get_element		;get element after variable

		cmp	al,type_left		;var({param,...}){:results} ?
		jne	@@notvarleft
		mov	ch,1			;(single result required)
		mov	cl,bc_drop_push		;(drop anchor - push)
		jmp	ct_method_ptr
@@notvarleft:
		cmp	al,type_inc		;var++ ?
		mov	dh,bc_var_postinc_push
		je	compile_var_assign

		cmp	al,type_dec		;var-- ?
		mov	dh,bc_var_postdec_push
		je	compile_var_assign

		call	check_lognot		;var!! ?
		mov	dh,bc_var_lognot_push
		je	compile_var_assign

		call	check_bitnot		;var! ?
		mov	dh,bc_var_bitnot_push
		je	compile_var_assign

		cmp	al,type_back		;var\x ?
		mov	dh,bc_var_swap
		je	compile_var_exp

		cmp	al,type_til		;var~ ?
		mov	dl,bc_con_n+1
		je	compile_var_clrset_term

		cmp	al,type_tiltil		;var~~ ?
		mov	dl,bc_con_n
		je	compile_var_clrset_term

		cmp	al,type_assign		;var := x ?
		mov	dh,bc_write_push
		je	compile_var_exp

		call	check_binary		;var binary op assign (w/push)?
		jne	@@notbin
		test	ebx,opc_assign		;verify that assignment is allowed
		jz	@@notbin
		call	check_equal		;check for '=' after binary op
		jne	@@notbin
		shr	ebx,16
		sub	bl,bc_lognot-bc_lognot_write_push
		mov	dh,bl
		mov	dl,2
		call	compile_exp
		jmp	compile_var
@@notbin:
		call	back_element		;no post-var modifier, back up

@@readvar:	mov	dl,0			;var, read
		jmp	compile_var
;
;
; Compile 'struct1 == struct2' or 'struct1 <> struct2'
; on entry, bl=op_e or bl=op_ne
;
compile_struct_compare:

		push	ebx			;got struct1
		push	[compiled_struct_size]

		call	compile_var_addr	;compile @struct1

		call	get_struct_variable	;get struct2

		pop	eax			;make sure structs are same size
		cmp	[compiled_struct_size],eax
		jne	error_smbss
		push	eax

		call	compile_var_addr	;compile @struct2

		pop	ebx			;compile common struct size
		call	compile_constant

		mov	al,bc_bytecomp		;enter hub bytecode bc_bytecomp
		call	enter_hub_bytecode

		pop	ebx			;if '<>', enter bc_lognot
		cmp	bl,op_ne
		jne	@@notne
		mov	al,bc_lognot
		call	enter_obj
@@notne:
		ret
;
;
; Compile term - SIZEOF(type_???_struct)
;
ct_sizeof:	call	get_left			;get '('

		call	get_struct_and_size		;get struct and size

		mov	ebx,eax				;compile size constant
		call	compile_constant

		jmp	get_right			;get ')'
;
;
; Compile term - STRING("constantstring")
;
ct_constr:	call	get_left		;get '('

		mov	al,bc_string		;enter string bytecode
		call	enter_obj

		mov	edx,[obj_ptr]		;remember obj_ptr for patching length byte

		mov	al,0			;enter dummy length byte, gets patched later
		call	enter_obj

		mov	cl,1			;reset length, account for 0 terminator
@@chr:		call	get_value		;get string chr
		jc	@@chrerror		;floating-point not allowed
		or	ebx,ebx			;0 not allowed
		jz	@@chrerror
		cmp	ebx,0FFh		;above 0FFh not allowed
		jbe	@@chrok
@@chrerror:	jmp	error_scmrf
@@chrok:	mov	al,bl			;enter string chr
		call	enter_obj
		inc	cl			;check string length
		jz	error_sdcx
		call	get_comma_or_right	;check for another character
		je	@@chr

		mov	al,0			;done, enter 0 to terminate string
		call	enter_obj

		mov	[obj+edx],cl		;patch length byte

		ret
;
;
; Compile term - LSTRING("constantstring", zero_ok, zero_ok)
;
ct_conlstr:	call	get_left		;get '('

		mov	al,bc_string		;enter string bytecode
		call	enter_obj

		mov	edx,[obj_ptr]		;remember obj_ptr for patching length bytes

		mov	al,0			;enter dummy length bytes, get patched later
		call	enter_obj
		call	enter_obj

		mov	cl,1			;reset length, account for length byte
@@chr:		call	get_value		;get string chr
		jc	@@chrerror		;floating-point not allowed
		cmp	ebx,0FFh		;above 0FFh not allowed
		jbe	@@chrok
@@chrerror:	ja	error_lscmrf
@@chrok:	mov	al,bl			;enter string chr
		call	enter_obj
		inc	cl			;check string length
		jz	error_sdcx
		call	get_comma_or_right	;check for another character
		je	@@chr

		mov	[obj+edx],cl		;patch length bytes
		dec	cl
		mov	[obj+edx+1],cl

		ret
;
;
; Compile term - BYTE/WORD/LONG(value, value, BYTE/WORD/LONG value)
;
ct_condata:	mov	dl,bl			;save size

		mov	al,bc_string		;enter string bytecode
		call	enter_obj

		mov	esi,[obj_ptr]		;remember obj_ptr for patching length byte

		mov	al,0			;enter dummy length byte, gets patched later
		call	enter_obj

		mov	ch,0			;reset length

@@value:	call	get_element		;check for size override
		cmp	al,type_size
		mov	cl,bl
		je	@@override
		call	back_element
		mov	cl,dl			;use default size
@@override:	call	get_value

@@enter:	mov	ah,1
		shl	ah,cl

@@byte:		mov	al,bl
		call	enter_obj		;enter byte
		inc	ch			;check data limit
		jz	error_bwldcx
		shr	ebx,8			;get next byte
		dec	ah			;loop if another byte
		jnz	@@byte
		call	get_comma_or_right	;check for another value
		je	@@value

		mov	[obj+esi],ch		;patch length byte

		ret
;
;
; Compile term - \obj{[]}.method({param,...}), \method({param,...}), \var({param,...}){:results}
; if ch = 0 then method can have no results
; if ch = 1 then method must have one result
; if ch = 2 then method must have at least one result
; cl must hold bc_drop_?
;
ct_try:		call	get_element_obj		;get element after '\'

		cmp	al,type_obj		;\obj{[]}.method({param,...}) ?
		je	ct_objpub

		cmp	al,type_method		;\method({param,...}) ?
		je	ct_method

		mov	edx,[source_start]	;save source start for ct_method_ptr
		push	ecx			;\var({param,...}){:results} ?
		call	check_var
		pop	ecx
		jne	error_eamoov
		call	get_left
		jmp	ct_method_ptr

;
;
; Compile term - obj{[]}.method({param,...})
; if ch = 0 then method can have no results
; if ch = 1 then method must have one result
; if ch = 2 then method must have at least one result
; cl must hold bc_drop_?
;
ct_objpub:	mov	al,cl			;(drop anchor)
		call	enter_obj

		mov	edx,ebx			;preserve obj data

		mov	edi,0			;reset index flags

		call	check_index		;check for obj[]
		jne	@@noindex
		push	eax			;push obj index exp ptr
		or	edi,1			;set obj index flag
@@noindex:
		call	get_dot			;get dot

		mov	eax,edx			;get objpub symbol
		call	get_obj_symbol
		jne	error_eamn

		call	confirm_result		;single result required?

		mov	ecx,ebx			;compile any parameters
		shr	ecx,24
		call	compile_parameters

		test	edi,1			;obj[]?
		jz	@@noindex2
		pop	eax
		call	compile_oos_exp
@@noindex2:
		mov	al,bc_call_obj_sub	;enter method call bytecode
		add	eax,edi			;(bc_call_obj_sub/bc_call_obji_sub)
		call	enter_obj

		mov	eax,edx			;compile rfvar index of obj
		and	eax,0FFFFFFh
		call	compile_rfvar

		mov	eax,ebx			;compile rfvar index of pub
		and	eax,0FFFFFh
		jmp	compile_rfvar


confirm_result:	cmp	ch,0			;no result okay?
		je	@@resok
		mov	eax,ebx			;get number of results
		shr	eax,20
		and	eax,0Fh
		cmp	eax,1
		jb	error_tmrnr		;if no result, error
		je	@@resok			;if one result, okay
		cmp	ch,1			;more than one result allowed?
		je	error_tmrmr
@@resok:	ret
;
;
; Compile term - method({param,...})
; if ch = 0 then method can have any number of results
; if ch = 1 then method must have one result
; if ch = 2 then method must have at least one result
; cl must hold bc_drop_?
;
ct_method:	call	confirm_result		;single result required?

		mov	al,cl			;(drop anchor)
		call	enter_obj

		mov	ecx,ebx			;compile any parameters
		shr	ecx,24
		call	compile_parameters

		mov	al,bc_call_sub		;enter method call bytecode
		call	enter_obj

		mov	eax,ebx			;(index of sub)
		and	eax,0FFFFFh
		jmp	compile_rfvar
;
;
; Compile term - var({param,...}){:results} or RECV() or SEND(param{,...})
; if ch = 0 then method can have any number of results
; if ch = 1 then method must have one result
; if ch = 2 then method must have at least one result
; cl must hold bc_drop_?
; edx must point to var
;
ct_method_ptr:	push	edx			;remember source ptr for variable
		mov	[source_ptr],edx	;point to variable

		mov	edx,ecx			;remember result requirement in dh and bc_drop_? in dl

		call	get_method_ptr_var	;get method pointer

		cmp	ch,type_register	;if RECV(), no parameters allowed, one return value
		jne	@@notrecv
		cmp	esi,mrecv_reg
		jne	@@notrecv
		cmp	dl,bc_drop_push		;only bc_drop_push is allowed
		jne	error_recvcbu
		call	get_left
		call	get_right
		mov	al,bc_call_recv		;(call recv)
		call	enter_obj
		pop	eax			;pop unneeded source ptr
		ret				;exit
@@notrecv:
		cmp	ch,type_register	;if SEND(param{,...}), parameters allowed, no return value
		jne	@@notsend
		cmp	esi,msend_reg
		jne	@@notsend
		cmp	dl,bc_drop		;only bc_drop is allowed
		jne	error_sendcbu
		pop	eax			;pop unneeded source ptr
		jmp	ci_send			;compile SEND(param{,...})
@@notsend:
		push	[source_start]		;remember source pointers in case error
		push	[source_finish]

		mov	al,dl			;(drop anchor)
		call	enter_obj

		call	compile_parameters_mptr	;compile parameters for method pointer

		call	get_colon_result_count	;check for colon and result count, ebx = count
		shl	ebx,20			;single result required?

		pop	[source_finish]		;in case error, restore source pointers to show variable name
		pop	[source_start]

		mov	ch,dh			;check result requirement
		call	confirm_result

@@varread:	pop	eax			;compile variable read
		push	[source_ptr]
		mov	[source_ptr],eax
		call	compile_var_read
		pop	[source_ptr]

		mov	al,bc_call_ptr		;(call method pointer)
		jmp	enter_obj
;
;
; Compile term - LOOKUP/LOOKDOWN
;
ct_look:	mov	cl,bl			;save 'lookup'/'lookdown' and 0/1 flags

		mov	al,type_i_look		;set new 'look' blocknest
		mov	ah,1			;reserve 16 bstack variables
		call	new_bnest

		lea	eax,[@@comp]		;optimize block
		call	optimize_block

		jmp	end_bnest		;done, end blocknest


@@comp:		mov	eax,0			;compile address constant
		call	compile_bstack_address

		call	get_left		;get '('
		call	compile_exp		;compile target value
		call	get_colon		;get ':'

		mov	al,cl			;compile initial index
		and	al,1
		add	al,bc_con_n+1		;(constant 0/1)
		call	enter_obj

@@loop:		mov	al,cl			;compile (next) value/range
		shr	al,1
		and	al,1
		call	compile_range
		jne	@@value
		or	al,2
@@value:	add	al,bc_lookup_value	;(bc_lookup_value, bc_lookdown_value, bc_lookup_range, bc_lookdown_range)
		call	enter_obj

		call	get_comma_or_right	;get ',' or ')'
		je	@@loop

		mov	al,bc_look_done		;(lookdone)
		call	enter_obj

		mov	eax,0			;set address
		jmp	write_bstack_ptr
;
;
; Compile term - COGSPIN(cog,method(parameters),stackadr)
;   on entry: cl = bc_coginit / bc_coginit_push
;
; Compile term - TASKSPIN(task,method(parameters),stackadr)
;   on entry: cl = bc_taskspin, c=1 for result push
;
ct_cogspin_taskspin:

		pushf				;push bc_coginit / bc_coginit_push / bc_taskspin (c=push)
		shl	ecx,1
		popf
		rcr	ecx,1			;save c into ecx msb
		push	ecx

		call	get_left		;get '('

		call	compile_exp		;compile cog or task exp
		call	get_comma		;get ','

		call	get_element_obj		;get method/obj/var
		mov	edx,[source_start]	;remember source start

		cmp	al,type_obj		;obj{[]}.method({param,...}) ?
		je	@@object
		cmp	al,type_method		;method({param,...}) ?
		je	@@method
		call	check_var		;var({param,...}) ?
		je	@@method_ptr
		jmp	error_eamomp


@@object:	call	check_index		;object method, skip any index
		call	get_dot			;get '.'
		mov	eax,ebx			;get obj symbol
		call	get_obj_symbol
		jne	error_eamn		;if not method, error

@@method:	mov	ecx,ebx			;get parameter count
		shr	ecx,24
		push	ecx			;push parameter count
		call	compile_parameters	;compile parameters

		push	[source_ptr]		;compile method as method pointer
		mov	[source_ptr],edx
		call	ct_at
		pop	[source_ptr]
		jmp	@@finish


@@method_ptr:	mov	[source_ptr],edx	;method pointer, confirm long variable
		call	get_method_ptr_var

		call	compile_parameters_mptr	;compile parameters, returns parameter count in ecx
		push	ecx			;push parameter count

		push	[source_ptr]		;compile variable method pointer
		mov	[source_ptr],edx
		call	compile_var_read
		pop	[source_ptr]


@@finish:	call	get_comma		;get ','

		call	compile_exp		;compile stackadr

		call	get_right		;get ')'

		mov	al,bc_hub_bytecode	;enter bc_hub_bytecode before bc_cogspin / bc_taskspin
		call	enter_obj

		pop	ebx			;pop parameter count
		pop	ecx			;pop bc_coginit / bc_coginit_push / bc_taskspin (msb=push)

		cmp	cl,bc_taskspin		;COGSPIN or TASKSPIN ?
		je	@@taskspin2


		mov	al,bc_cogspin		;COGSPIN, enter bc_cogspin
		call	enter_obj

		mov	al,bl			;enter parameter count
		call	enter_obj

		mov	al,cl			;enter bc_coginit / bc_coginit_push
		jmp	enter_obj


@@taskspin2:	mov	al,cl			;TASKSPIN, enter bc_taskspin
		call	enter_obj

		or	ecx,ecx			;if result push, set msb of parameter count
		jns	@@nopush
		or	bl,80h
@@nopush:
		mov	al,bl			;enter parameter count
		jmp	enter_obj
;
;
; Compile flex instruction
;
compile_flex:	call	get_left		;get '('

		movzx	ecx,bh			;any parameters?
		and	ecx,flex_params
		jz	@@paramsdone


		test	bh,flex_pinfld		;check for pinfield in first parameter?
		jz	@@params

		push	[source_ptr]		;if first parameter returns single value followed by '..', pinfield
		push	[obj_ptr]
		call	compile_parameter
		dec	eax
		jne	@@oneresult
		call	check_dotdot
@@oneresult:	pop	[obj_ptr]
		pop	[source_ptr]
		jne	@@params


		push	[source_ptr]		;pinfield, push source_ptr and obj_ptr
		push	[obj_ptr]

		call	compile_exp_check_con	;try to get both values as constants
		jnz	@@notcons
		mov	edx,[con_value]
		call	get_dotdot
		call	compile_exp_check_con
		jnz	@@notcons
		mov	eax,[con_value]

		push	ebx			;got both as constants, make sure they don't cross ports
		mov	ebx,edx
		xor	ebx,eax
		test	ebx,20h
		jnz	error_pmbttsp
		pop	ebx
		sub	edx,eax			;compile single constant
		and	edx,1Fh
		shl	edx,6
		and	eax,3Fh
		or	eax,edx
		push	ebx
		mov	ebx,eax
		call	compile_constant
		pop	ebx
		pop	eax			;pop original source_ptr and obj_ptr from stack
		pop	eax
		jmp	@@condone

@@notcons:	pop	[obj_ptr]		;not constants, compile both values normally
		pop	[source_ptr]
		call	compile_exp
		call	get_dotdot
		call	compile_exp
		mov	al,bc_bitrange		;enter bytecodes
		call	enter_obj
		mov	al,bc_addpins
		call	enter_obj

@@condone:	dec	ecx			;more parameters to compile?
		jz	@@paramsdone
		call	get_comma		;more parameters, get ','


@@params:	call	compile_parameters_np	;compile parameters without parentheses

@@paramsdone:	call	get_right		;get ')'

		test	bh,flex_hubcode		;hub bytecode?
		jz	@@nothub
		mov	al,bc_hub_bytecode
		call	enter_obj
@@nothub:
		mov	al,bl			;enter bytecode
		jmp	enter_obj
;
;
; Compile term - @"string", @\"string", @obj{[]}.method, @method, or @hubvar
;
ct_at:		call	get_element_obj		;get string, object, method, or variable
		cmp	al,type_con_int
		je	@@string
		cmp	al,type_back
		je	@@string_esc
		cmp	al,type_obj
		je	@@object
		cmp	al,type_method
		je	@@method
		call	check_var
		je	@@var
		jmp	error_easvmoo

@@string_esc:	call	get_element_obj		;@\"string", get type_con_int
		cmp	al,type_con_int
		jne	error_esc
		mov	ch,1			;set escape-character mode
		jmp	@@stringbc

@@string:	mov	ch,0			;@"string", clear escape-character mode
@@stringbc:	mov	al,bc_string		;enter string bytecode
		call	enter_obj

		mov	edx,[obj_ptr]		;remember obj_ptr for patching length byte

		mov	al,0			;enter dummy length byte, gets patched later
		call	enter_obj

		mov	cl,1			;reset length, account for 0 terminator
		call	back_element		;back up to first character
@@chr:		call	get_element_obj		;get string chr
		cmp	al,type_con_int
		jne	@@chrerror
		or	ebx,ebx			;0 not allowed
		jz	@@chrerror
		cmp	ebx,0FFh		;above 0FFh not allowed
		jbe	@@chrok
@@chrerror:	jmp	error_scmrf
@@chrok:	cmp	ch,1			;if escape-character mode, handle escape character
		call	handle_escape_chr
		mov	al,bl			;enter string chr
		call	enter_obj
		inc	cl			;check string length
		jz	error_sdcx
		cmp	[source_flags],0	;check if string done
		je	@@strdone
		call	get_comma		;get comma and loop for next character
		jmp	@@chr
@@strdone:
		mov	al,0			;done, enter 0 to terminate string
		call	enter_obj

		mov	[obj+edx],cl		;patch length byte
		ret


@@object:	mov	edx,ebx			;@obj{[]}.method, preserve obj data
		mov	edi,0			;reset index flag

		call	check_index		;check for obj[]
		jne	@@noindex
		push	eax			;push obj index exp ptr
		or	edi,1			;set obj index flag
@@noindex:
		call	get_dot			;get dot

		mov	eax,edx			;get obj symbol
		call	get_obj_symbol
		jne	error_eamn		;if not method, error

		test	edi,1			;compile any obj[] index
		jz	@@noindex2
		pop	eax
		call	compile_oos_exp
@@noindex2:
		mov	al,bc_mptr_obj_sub	;enter mptr bytecode
		add	eax,edi			;(bc_mptr_obj_sub/bc_mptr_obji_sub)
		call	enter_obj

		mov	eax,edx			;compile rfvar index of obj
		and	eax,0FFFFFFh		;isolate obj index
		call	compile_rfvar

		mov	eax,ebx			;compile rfvar index of pub
		and	eax,0FFFFFh		;isolate pub index
		jmp	compile_rfvar


@@method:	mov	al,bc_mptr_sub		;@method, enter mptr bytecode
		call	enter_obj

		mov	eax,ebx			;compile rfvar index of method
		and	eax,0FFFFFh		;isolate method index
		jmp	compile_rfvar


@@var:		cmp	ch,type_register	;if @register, error
		je	error_arina

		test	ecx,var_bitfield_flag	;if @bitfield, error
		jnz	error_ainafbf

		mov	dh,bc_get_addr		;compile variable address
		jmp	compile_var_assign
;
;
; Compile term - ^@var
;
ct_upat:	call	get_element_obj		;get variable
		call	check_var
		jne	error_eav

		mov	dh,bc_get_field		;compile variable field
		jmp	compile_var_assign
;
;
;************************************************************************
;*  Compiler Support Routines						*
;************************************************************************
;
;
; Scan elements for type=type_block and value=dl
; c=0 if found, c=1 if eof
;
next_block:	call	get_element		;scan for type_block dl
		jc	@@eof
		cmp	al,type_block
		jne	next_block
		cmp	bl,dl
		jne	next_block

		call	get_column		;found it, verify first column
		cmp	[column],1
		jne	error_bdmbifc		;c=0

@@eof:		ret
;
;
; Get element, converting type_obj subtypes, c=1 if eof
;
;	type_obj.type_obj_con_int    --> type_con_int
;	type_obj.type_obj_con_float  --> type_con_float
;	type_obj.type_obj_con_struct --> type_con_struct
;	type_obj.type_obj_pub        --> type_obj (compiler will discover type_obj_pub)
;	type_obj                     --> type_obj (compiler will handle whatever is next)
;
get_element_obj:

		call	get_element		;get element
		jc	@@eof			;eof?

		cmp	al,type_obj		;if not type_obj, done
		jne	@@done

		push	[source_start]		;save source start
		pop	[@@start]

		mov	[@@value],ebx		;save value

		call	get_element		;dot?
		cmp	al,type_dot
		jne	@@back1			;if no dot, back up once

		mov	eax,[@@value]		;get type_obj_int/float/struct/pub symbol
		call	get_obj_symbol
		je	@@back2			;if type_obj_pub, back up twice (will be handled later)

		or	[back_skip],11b		;type_con_int/float/struct, if back_element gets called, must back up twice
		jmp	@@restore		;exit with type_con_int/float/struct

@@back2:	call	back_element		;type_obj_pub, back up
@@back1:	call	back_element		;no dot, back up

		mov	eax,type_obj		;restore type_obj and value
		mov	ebx,[@@value]

@@restore:	push	[@@start]		;restore source start
		pop	[source_start]

@@done:		clc				;not eof, c=0
@@eof:		ret


ddx		@@value
ddx		@@start
;
;
; Handle escape character if z=1
;  on entry, bl holds character (may be '\'), z=1 if escape characters allowed
;  on exit, bl holds character
;
;  \a = 7, alarm bell
;  \b = 8, backspace
;  \t = 9, tab
;  \n = 10, new line
;  \f = 12, form feed
;  \r = 13, carriage return
;  \\ = 92, \ (backslash)
;  \x01 to \xFF = $01 to $FF (0 is not allowed, as it would terminate the string)
;
handle_escape_chr:

		jne	@@done			;escape mode?

		cmp	bl,'\'			;backslash?
		jne	@@done

		call	@@getchr		;get initial character after backslash

		cmp	al,'A'
		mov	bl,7
		je	@@done

		cmp	al,'B'
		mov	bl,8
		je	@@done

		cmp	al,'T'
		mov	bl,9
		je	@@done

		cmp	al,'N'
		mov	bl,10
		je	@@done

		cmp	al,'F'
		mov	bl,12
		je	@@done

		cmp	al,'R'
		mov	bl,13
		je	@@done

		cmp	al,'\'
		mov	bl,'\'
		je	@@done

		cmp	al,'X'			;hex character 'x??'
		jne	@@nothex
		call	@@getchr
		call	check_hex
		jc	error_iec
		mov	bl,al
		call	@@getchr
		call	check_hex
		jc	error_iec
		shl	bl,4
		or	bl,al
		jz	error_scmrf		;error if zero
		jmp	@@done
@@nothex:
		call	back_element		;unrecognized chr, back up and pass '\'
		call	back_element
		mov	bl,'\'

@@done:		ret


@@getchr:	push	ebx
		cmp	[source_flags],0	;make sure string not done
		je	error_esc
		call	get_comma
		call	get_element_obj		;get string chr
		cmp	al,type_con_int
		jne	error_esc
		cmp	ebx,1
		jl	error_scmrf
		cmp	ebx,0FFh
		jg	error_scmrf
		mov	al,bl
		call	uppercase
		pop	ebx
		ret
;
;
; Get ???
;
get_left:	push	eax			;'('
		push	ebx
		call	get_element
		cmp	al,type_left
		jne	error_eleft
		pop	ebx
		pop	eax
		ret

get_right:	push	eax			;')'
		push	ebx
		call	get_element
		cmp	al,type_right
		jne	error_eright
		pop	ebx
		pop	eax
		ret

get_leftb:	push	eax			;'['
		push	ebx
		call	get_element
		cmp	al,type_leftb
		jne	error_eleftb
		pop	ebx
		pop	eax
		ret

get_rightb:	push	eax			;']'
		push	ebx
		call	get_element
		cmp	al,type_rightb
		jne	error_erightb
		pop	ebx
		pop	eax
		ret

get_comma:	push	eax			;','
		push	ebx
		call	get_element
		cmp	al,type_comma
		jne	error_ecomma
		pop	ebx
		pop	eax
		ret

get_pound:	push	eax			;'#'
		push	ebx
		call	get_element
		cmp	al,type_pound
		jne	error_epound
		pop	ebx
		pop	eax
		ret

get_equal:	push	eax			;'='
		push	ebx
		call	get_element
		cmp	al,type_equal
		jne	error_eequal
		pop	ebx
		pop	eax
		ret

get_colon:	push	eax			;':'
		push	ebx
		call	get_element
		cmp	al,type_colon
		jne	error_ecolon
		pop	ebx
		pop	eax
		ret

get_dot:	push	eax			;'.'
		push	ebx
		call	get_element
		cmp	al,type_dot
		jne	error_edot
		pop	ebx
		pop	eax
		ret

get_dotdot:	push	eax			;'..'
		push	ebx
		call	get_element
		cmp	al,type_dotdot
		jne	error_edotdot
		pop	ebx
		pop	eax
		ret

get_assign:	push	eax			;':='
		push	ebx
		call	get_element
		cmp	al,type_assign
		jne	error_eassign
		pop	ebx
		pop	eax
		ret

get_size:	push	eax			;BYTE/WORD/LONG
		push	ebx
		call	get_element
		cmp	al,type_size
		jne	error_ebwl
		pop	ebx
		pop	eax
		ret

get_from:	push	eax			;'FROM'
		push	ebx
		call	get_element
		cmp	al,type_from
		jne	error_efrom
		pop	ebx
		pop	eax
		ret

get_to:		push	eax			;'TO'
		push	ebx
		call	get_element
		cmp	al,type_to
		jne	error_eto
		pop	ebx
		pop	eax
		ret

get_with:	push	eax			;'WITH'
		push	ebx
		call	get_element
		cmp	al,type_with
		jne	error_ewith
		pop	ebx
		pop	eax
		ret

get_end:	push	eax			;end of line
		push	ebx
		call	get_element
		cmp	al,type_end
		jne	error_eeol
		pop	ebx
		pop	eax
		ret
;
;
; Get comma or right parenthesis
; z=1 if comma, z=0 if right
;
get_comma_or_right:

		push	eax
		push	ebx

		call	get_element		;get comma or right

		cmp	al,type_comma		;comma?
		je	@@exit			;comma, z=1

		cmp	al,type_right		;right?
		jne	error_ecor		;if neither, error

		inc	eax			;right, z=0

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Get comma or end
; z=1 if comma, z=0 if end
;
get_comma_or_end:

		push	eax
		push	ebx

		call	get_element		;get comma or end

		cmp	al,type_comma		;comma?
		je	@@exit			;comma, z=1

		cmp	al,type_end		;end?
		jne	error_ecoeol		;if neither, error

		inc	eax			;end, z=0

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Get colon result count in ebx
; ebx = constant
;
get_colon_result_count:

		push	eax
		push	ecx
		push	esi
		push	edi

		call	check_colon			;if no colon, return 0
		mov	ebx,0
		jne	@@got

		call	get_element_obj			;get element

		cmp	al,type_con_int			;constant?
		je	@@got				;got size

		call	check_con_struct_size		;con struct?
		jne	error_eiconos
		mov	ebx,eax				;get size in longs
		add	ebx,3
		shr	ebx,2

@@got:		cmp	ebx,method_results_limit	;check result count
		ja	error_loxre

		pop	edi
		pop	esi
		pop	ecx
		pop	eax
		ret
;
;
; Get 'step' or end
; z=1 if 'step', z=0 if end
;
get_step_or_end:

		push	eax
		push	ebx

		call	get_element		;get step or end

		cmp	al,type_step		;'step'?
		je	@@exit			;'step', z=1

		cmp	al,type_end		;end?
		jne	error_esoeol		;if neither, error

		inc	eax			;end, z=0

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Get pipe or end
; z=1 if pipe, z=0 if end
;
get_pipe_or_end:

		push	eax
		push	ebx

		call	get_element		;get pipe or end

		cmp	al,type_op		;pipe?
		jne	@@notpipe
		cmp	bl,op_bitor
		je	@@exit			;pipe, z=1
@@notpipe:
		cmp	al,type_end		;end?
		jne	error_epoeol		;if neither, error

		inc	eax			;end, z=0

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Check for ternary/binary/unary/compare/float/alias operator
; z=1 if type, z=0 if not type
;
check_ternary:	test	ebx,opc_ternary
		jnz	check_tbu
		jmp	check_tbu_no

check_binary:	test	ebx,opc_binary
		jnz	check_tbu
		jmp	check_tbu_no

check_unary:	test	ebx,opc_unary
		jnz	check_tbu
		jmp	check_tbu_no

check_assign:	test	ebx,opc_assign
		jnz	check_tbu
		jmp	check_tbu_no

check_float:	test	ebx,opc_float
		jnz	check_tbu
		jmp	check_tbu_no

check_alias:	test	ebx,opc_alias
		jnz	check_tbu
		jmp	check_tbu_no

check_hubcode:	test	ebx,opc_hubcode
		jnz	check_tbu

check_tbu_no:	cmp	al,0			;make z=0
		jnz	@@ret
		cmp	al,1
@@ret:		ret

check_tbu:	cmp	al,type_op
		ret				;z=1 if type
;
;
; Check for operator
;
check_lognot:	cmp	al,type_op		;check for !!
		jne	@@ret
		cmp	bl,op_lognot
@@ret:		ret

check_bitnot:	cmp	al,type_op		;check for !
		jne	@@ret
		cmp	bl,op_bitnot
@@ret:		ret
;
;
; Check for ^BYTE, ^WORD, ^LONG, or ^type_con_struct
; z=1 if found, al=type, ebx=value
; z=0 if not found
;
check_ptr:	call	is_caret		;'^' ?
		jne	@@ret			;z=0

		call	get_element_obj		;got '^', get next element

		cmp	al,type_size		;BYTE/WORD/LONG?
		je	@@ret			;z=1

		cmp	al,type_con_struct	;struct?
		je	@@ret			;z=1

		jmp	error_ebwls		;else, error

@@ret:		ret
;
;
; Check al for type_con_struct (ebx=id) and get struct size
; z=1 if found, eax=byte_count
; z=0 if not found
;
check_con_struct_size:

		cmp	al,type_con_struct		;struct?
		je	get_con_struct_size

		ret
;
;
; Get struct size from structure id in ebx
; on exit, eax=byte_count, z flag same
;
get_con_struct_size:

		mov	eax,[struct_id_to_def+ebx*4]	;get offset of struct definition from struct id
		mov	eax,[dword struct_def+2+eax]	;get struct size from struct definition

		ret
;
;
; Check if structure will fit on stack (15 longs or less)
; on entry, eax must hold struct size
;
check_struct_stack_fit:

		cmp	eax,15*4		;if over 15 longs, error
		ja	error_stosmne

		ret
;
;
; Scan to ']' with nesting
;
scan_to_rightb:	push	eax
		push	ebx
		push	ecx

		xor	ecx,ecx			;reset nested '[]' counter

@@nest:		inc	ecx			;inc nest level

@@next:		call	get_element		;get next element

		cmp	al,type_end		;if end of line, error
		je	error_erightb

		cmp	al,type_leftb		;if '[', inc nest level, get next
		je	@@nest

		cmp	al,type_rightb		;if not ']', get next
		jne	@@next

		dec	ecx			;']', dec nest level, get next if nested
		jnz	@@next

@@done:		pop	ecx			;got it
		pop	ebx
		pop	eax
		ret
;
;
; Scan to ')' with nesting
;
scan_to_right:	push	eax
		push	ebx
		push	ecx

		xor	ecx,ecx			;reset nested '()' counter

@@nest:		inc	ecx			;inc nest level

@@next:		call	get_element		;get next element

		cmp	al,type_end		;if end of line, error
		je	error_eright

		cmp	al,type_left		;if '(', inc nest level, get next
		je	@@nest

		cmp	al,type_right		;if not ')', get next
		jne	@@next

		dec	ecx			;')', dec nest level, get next if nested
		jnz	@@next

@@done:		pop	ecx			;got it
		pop	ebx
		pop	eax
		ret
;
;
; Skip to end of line
;
skip_to_end:	push	eax
		push	ebx

@@skip:		call	get_element		;skip to end of line
		cmp	al,type_end
		jne	@@skip

		call	back_element		;back up to end of line

		pop	ebx
		pop	eax
		ret

;
;
; Skip to comma or end of line
;
skip_to_comma_or_end:

		push	eax
		push	ebx

@@scan:		call	get_element		;get next element
		cmp	al,type_comma		;comma?
		je	@@got
		cmp	al,type_end		;end of line?
		jne	@@scan
@@got:
		call	back_element		;back up to comma or end of line

		pop	ebx
		pop	eax
		ret
;
;
; Check for local symbol
; c=0 if local
;
check_local:	cmp	al,type_colon		;if colon or dot, local symbol
		je	@@is
		cmp	al,type_dot
		je	@@is
		stc
		ret


@@is:		push	ecx

		push	[source_start]		;check for symbol after dot
		call	get_symbol
		pop	[source_start]
		jc	error_eals		;if no symbol, error

		cmp	cl,symbol_size_limit-1	;check symbol size
		ja	error_sexc

		lea	edi,[symbol+ecx]	;append local digits and 0
		mov	al,27h
		stosb
		mov	eax,[asm_local]
		stosd
		mov	al,0
		stosb

		pop	ecx

		call	find_symbol		;find local symbol
		clc				;c=0

		ret
;
;
; Get type_obj_int/float/struct/pub symbol
; eax[31:24] must hold obj id
; on exit, al = type_obj_pub/type_con_int/type_con_float/type_con_struct, ebx = value, z=1 if type_obj_pub
;
get_obj_symbol:	push	ecx

		push	eax			;save obj id

		call	get_symbol		;get obj int/float/struct/pub symbol
		jc	@@error

		pop	eax			;restore obj id

		shr	eax,24			;append obj id + 1 and 0
		inc	eax
		mov	[word symbol+ecx],ax

		call	find_symbol		;lookup appended symbol

		cmp	al,type_obj_pub		;if obj pub, done, z=1
		je	@@exit

		cmp	al,type_obj_con_int	;must be type_obj_con_int/float/struct
		jb	@@error
		cmp	al,type_obj_con_struct
		ja	@@error
		sub	al,type_obj_con_int-type_con_int	;return type_con_int/float/struct, z=0

@@exit:		pop	ecx
		ret


@@error:	jmp	error_eaocsom
;
;
; Get symbol
; c=0 if symbol with length in ecx
;
get_symbol:	push	edi

		lea	edi,[symbol]		;edi points to symbol

		mov	[byte edi],0		;get element and verify symbol
		call	get_element
		mov	al,[edi]
		call	check_word_chr_initial
		jc	@@error

		call	measure_symbol		;get symbol size into ecx
		clc

@@error:	pop	edi
		ret
;
;
; Get filename into symbol
;
get_filename:	push	edi

		xor	ecx,ecx			;reset size

		call	get_element		;save filename start
		mov	eax,[source_start]
		mov	[filename_start],eax
		call	back_element

@@chr:		call	get_element_obj		;get filename chr

		cmp	al,type_con_int		;valid constant?
		jne	@@error
		mov	eax,ebx
		cmp	eax,20h
		jb	@@error2
		cmp	eax,7Eh
		ja	@@error2
		push	ecx
		mov	ecx,9
		lea	edi,[@@illegals]
	repne	scasb
		pop	ecx
		je	@@error2

		mov	[filename+ecx],al	;enter chr
		inc	ecx

		mov	eax,[source_finish]	;update filename finish
		mov	[filename_finish],eax

		cmp	cl,253			;check size
		ja	error_ftl

		call	check_comma		;another chr?
		je	@@chr

		mov	[filename+ecx],0	;got filename, zero-terminate

		push	[filename_start]	;set source pointers to filename
		pop	[source_start]
		push	[filename_finish]
		pop	[source_finish]

		pop	edi
		ret


@@error:	jmp	error_ifufiq
@@error2:	jmp	error_ifc

@@illegals:	db	'\/:*?"<>|'

ddx		filename_start
ddx		filename_finish
dbx		filename, 254+1
;
;
; Check for alignw/alignl
; al = type
; ebx = value
; if alignw/alignl, z=1 and ecx=01b/11b
;
check_align:	cmp	al,type_asm_dir		;check for alignw/alignl
		jne	@@done

		cmp	bl,dir_alignw
		mov	ecx,01b
		je	@@done

		cmp	bl,dir_alignl
		mov	ecx,11b
@@done:
		ret
;
;
; Check for structure type
; if al is structure type, z=1
;
is_struct:	cmp	al,type_con_struct
		je	@@is
		cmp	al,type_loc_struct
		je	@@is
		cmp	al,type_var_struct
		je	@@is
		cmp	al,type_dat_struct
		jne	is_struct_ptr
@@is:		ret
;
;
; Check for ptr type
; al = type
; if ptr type, z=1
;
is_ptr:		cmp	al,type_loc_byte_ptr
		je	@@is
		cmp	al,type_var_byte_ptr
		je	@@is
		cmp	al,type_loc_word_ptr
		je	@@is
		cmp	al,type_var_word_ptr
		je	@@is
		cmp	al,type_loc_long_ptr
		je	@@is
		cmp	al,type_var_long_ptr
		jne	is_struct_ptr
@@is:		ret

is_struct_ptr:	cmp	al,type_loc_struct_ptr
		je	@@is
		cmp	al,type_var_struct_ptr
@@is:		ret
;
;
; Check for ptr val type
; al = type
; if ptr val type, z=1
;
is_ptr_val:	cmp	al,type_loc_byte_ptr_val
		je	@@is
		cmp	al,type_var_byte_ptr_val
		je	@@is
		cmp	al,type_loc_word_ptr_val
		je	@@is
		cmp	al,type_var_word_ptr_val
		je	@@is
		cmp	al,type_loc_long_ptr_val
		je	@@is
		cmp	al,type_var_long_ptr_val
		jne	is_struct_ptr_val
@@is:		ret

is_struct_ptr_val:
		cmp	al,type_loc_struct_ptr_val
		je	@@is
		cmp	al,type_var_struct_ptr_val
@@is:		ret
;
;
; Check for element type
; z=1 if match, z=0 if not match
;
check_left:	push	eax			;'('
		mov	al,type_left
		jmp	check_element

check_right:	push	eax			;')'
		mov	al,type_right
		jmp	check_element

check_leftb:	push	eax			;'['
		mov	al,type_leftb
		jmp	check_element

check_rightb:	push	eax			;']'
		mov	al,type_rightb
		jmp	check_element

check_comma:	push	eax			;','
		mov	al,type_comma
		jmp	check_element

check_pound:	push	eax			;'#'
		mov	al,type_pound
		jmp	check_element

check_colon:	push	eax			;':'
		mov	al,type_colon
		jmp	check_element

check_equal:	push	eax			;'='
		mov	al,type_equal
		jmp	check_element

check_under:	push	eax			;'_'
		mov	al,type_under
		jmp	check_element

check_dot:	push	eax			;'.'
		mov	al,type_dot
		jmp	check_element

check_dotdot:	push	eax			;'..'
		mov	al,type_dotdot
		jmp	check_element

check_at:	push	eax			;'@'
		mov	al,type_at
		jmp	check_element

check_inc:	push	eax			;'++'
		mov	al,type_inc
		jmp	check_element

check_dec:	push	eax			;'--'
		mov	al,type_dec
		jmp	check_element

check_back:	push	eax			;'\'
		mov	al,type_back
		jmp	check_element

check_tick:	push	eax			;'`'
		mov	al,type_tick
		jmp	check_element

check_end:	push	eax			;end of line
		mov	al,type_end


check_element:	push	ebx

		push	eax			;push target type
		call	get_element		;get element
		pop	ebx			;pop target type
		cmp	al,bl			;types match?
		je	@@exit			;if so, z=1

		call	back_element		;back up
		inc	eax			;z=0

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Check index - [exp]
; z=1 if index with exp ptr in eax
; z=0 if no index
;
check_index:	call	check_leftb		;check for '['
		jne	@@exit

		mov	eax,[source_ptr]	;get source ptr
		call	skip_exp		;skip expression
		call	get_rightb		;get ']'
		cmp	eax,eax			;z=1

@@exit:		ret
;
;
; Skip index - [exp]
;
skip_index:	call	get_leftb		;get '['
		call	skip_exp		;skip expression
		jmp	get_rightb		;get ']'
;
;
; Check for plus
; z=1 if '+' or '+.'
;
is_plus:	cmp	al,type_op
		jne	@@exit

		cmp	bl,op_add		;'+' ?
		je	@@exit

		cmp	bl,op_fadd		;'+.' ?

@@exit:		ret
;
;
; Check for '^'
; z=1 if '^'
;
is_caret:	cmp	al,type_op
		jne	@@exit

		cmp	bl,op_bitxor

@@exit:		ret
;
;
;
; Convert -constant to constant
;
negcon_to_con:	cmp	al,type_op
		jne	@@exit

		cmp	bl,op_sub
		jne	@@exit

		push	eax
		push	ebx
		call	get_element_obj
		cmp	al,type_con_int
		je	@@con
		cmp	al,type_con_float
		jne	@@notcon

		pop	eax			;constant float
		pop	eax
		mov	al,type_con_float
		xor	ebx,80000000h
		jmp	@@exit

@@con:		pop	eax			;constant integer
		pop	eax
		mov	al,type_con_int
		neg	ebx
		jmp	@@exit

@@notcon:	call	back_element
		pop	ebx
		pop	eax

@@exit:		ret
;
;
; Convert op_sub to op_neg
; z=1 if converted
;
sub_to_neg:	cmp	al,type_op
		jne	@@exit

		cmp	bl,op_sub
		jne	@@exit

		mov	ebx,oc_neg

@@exit:		ret
;
;
; Convert op_fsub to op_fneg
; z=1 if converted
;
fsub_to_fneg:	cmp	al,type_op
		jne	@@exit

		cmp	bl,op_fsub
		jne	@@exit

		mov	ebx,oc_fneg

@@exit:		ret
;
;
; Enter hub bytecode in al
;
enter_hub_bytecode:

		push	eax
		mov	al,bc_hub_bytecode
		call	enter_obj
		pop	eax
		jmp	enter_obj
;
;
; Enter al/ax/eax into obj
;
enter_obj_long:	call	enter_obj_word
		shr	eax,8

enter_obj_word:	call	enter_obj
		shr	eax,8


enter_obj:	push	edi

		mov	edi,[obj_ptr]
		cmp	edi,obj_size_limit
		jae	error_pex

		inc	[obj_ptr]

		add	edi,offset obj
		stosb

		pop	edi
		ret
;
;
; Skip block
;
skip_block:	push	[obj_ptr]		;save object pointer

		call	compile_block		;skip block

		pop	[obj_ptr]		;restore object pointer
		ret
;
;
; Skip range
;
skip_range:	push	[obj_ptr]		;save object pointer

		call	compile_range		;skip range

		pop	[obj_ptr]		;restore object pointer
		ret
;
;
; Skip expression
;
skip_exp:	push	[obj_ptr]		;save object pointer

		call	compile_exp		;skip expression

		pop	[obj_ptr]		;restore object pointer
		ret
;
;
; Skip expression, checking for constant
;
skip_exp_check_con:

		push	[obj_ptr]		;save object pointer

		call	compile_exp_check_con	;skip expression, checking for constant

		pop	[obj_ptr]		;restore object pointer
		ret
;
;
; Skip element
;
skip_element:	push	eax
		push	ebx

		call	get_element

		pop	ebx
		pop	eax
		ret
;
;
; Skip element, handle type_obj_con_int/float/struct handling
;
skip_element_obj:

		push	eax
		push	ebx

		call	get_element_obj

		pop	ebx
		pop	eax
		ret
;
;
; Compile out-of-sequence expression
; eax must hold source ptr
;
compile_oos_exp:

		push	[source_ptr]

		mov	[source_ptr],eax
		call	compile_exp

		pop	[source_ptr]
		ret
;
;
; Compile value/range
; z=0 if value, z=1 if range
;
compile_range:	call	compile_exp		;compile first value

		call	check_dotdot		;check for '..'
		jne	@@exit

		call	compile_exp		;compile second value
		cmp	eax,eax			;z=1

@@exit:		ret
;
;
; Get value/range
; low value in eax and high (same) value in ebx
;
get_range:	call	get_value_int		;get first value into eax and ebx
		mov	eax,ebx

		push	[source_start]		;save source pointers
		push	[source_finish]

		call	check_dotdot		;check for '..'
		pop	[source_finish]		;in case single value, restore source_finish
		jne	@@done

		call	get_value_int		;get second value into ebx

		cmp	eax,ebx			;low in eax, high in ebx
		jle	@@done
		xchg	eax,ebx

@@done:		pop	[source_start]		;restore source_start
		ret
;
;
; Compile any parameters - accommodates instructions/methods with multiple return values
; ecx must hold parameter count (0+)
;
compile_parameters:

		call	get_left		;get '('

		jecxz	@@done			;any parameters?

		call	compile_parameters_np	;compile parameters with no parentheses

@@done:		jmp	get_right		;get ')'
;
;
; Compile parameters with no parentheses - accommodates instructions/methods with multiple return values
; ecx must hold parameter count (1+)
;
compile_parameters_np:

		push	eax

@@loop:		call	compile_parameter	;compile parameter, may be method with multiple return values
		sub	ecx,eax			;subtract compiled parameters from target parameter count
		js	error_enope		;underflow?
		jz	@@done			;done?
		call	get_comma		;get comma between parameters
		jmp	@@loop

@@done:		pop	eax
		ret
;
;
; Compile parameters for method pointer - accommodates instructions/methods with multiple return values
; on exit, ecx holds parameter count (0+)
;
compile_parameters_mptr:

		push	eax

		mov	ecx,0			;reset parameter count

		call	get_left		;get '('
		call	check_right		;check ')' for no parameters
		je	@@noparams

@@param:	call	compile_parameter	;compile parameters
		add	ecx,eax
		cmp	ecx,method_params_limit
		ja	error_loxpe
		call	get_comma_or_right
		je	@@param

@@noparams:	pop	eax
		ret
;
;
; Compile a parameter - accommodates structure pushes and instructions/methods with multiple return values
; on exit, eax holds number of actual structure longs or parameters compiled
;
;	structure{[]}{.substructure{[]}}				- must be 15 or fewer longs, else error
;	structure{[]}{.substructure{[]}}.long{[]}({params,...}):2+
;	rotxy/polxy/xypol
;	obj{[]}.method({params,...})
;	method({params,...})
;	var({params,...}):2+
;
compile_parameter:

		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi
		push	[source_ptr]		;push source pointer

		call	get_element_obj		;get element to check


		call	check_var			;check variable to detect structure
		jne	@@notstruct			;if not variable, can't be structure

		mov	al,ch				;got variable, if not structure, get initial element again
		call	is_struct
		jne	@@notstruct2

		cmp	[compiled_struct_flags],3	;structure or byte/word/long member
		jne	@@struct

		call	check_left			;byte/word/long member, check for '(' indicating method pointer
		jne	@@single			;if no, '(', single parameter

		pop	eax				;'(', get initial element again and try as method pointer (must be long)
		push	eax
		mov	[source_ptr],eax
		call	get_element
		jmp	@@chkvarmethod

@@struct:	cmp	[compiled_struct_size],4	;structure, if fits in a long, single parameter
		jbe	@@single
		call	get_element			;if "==" or "<>" follows, single parameter to be handled by compile_exp
		cmp	al,type_op
		jne	@@notstructcmp
		cmp	bl,op_e
		je	@@single
		cmp	bl,op_ne
		je	@@single

@@notstructcmp:	call	back_element			;not "==" or "<>", back up
		mov	eax,[compiled_struct_size]	;structure > long, get long count to push
		add	eax,11b
		shr	eax,2
		mov	dl,0				;compile structure read/push (checks struct size)
		call	compile_var
		pop	ebx				;pop source pointer and exit
		jmp	@@exit

@@notstruct2:	pop	eax				;variable, but not structure, get initial element again
		push	eax
		mov	[source_ptr],eax
		call	get_element_obj
@@notstruct:

		cmp	al,type_i_flex		;flex instruction?
		jne	@@notflex
		movzx	ecx,bh			;multiple return values?
		and	ecx,flex_results
		shr	ecx,flex_results_shift
		cmp	ecx,2
		jb	@@single
		push	ecx			;yes, save number of results
		push	[source_start]		;save source pointers
		push	[source_finish]
		call	compile_flex		;compile flex instruction
		pop	[source_finish]		;restore source pointers in case error
		pop	[source_start]
		pop	eax			;restore number of results
		pop	ebx			;pop source pointer
		jmp	@@exit
@@notflex:
		cmp	al,type_obj		;obj{[]}.method({params,...}) ?
		jne	@@notobj
		call	check_index		;skip any index
		call	get_dot			;get '.'
		mov	eax,ebx			;get obj_pub/int/float/struct
		call	get_obj_symbol
		mov	esi,offset ct_objpub
		je	@@checkmult		;obj_pub? (index okay)
		jmp	error_oiina		;error, obj_int/float/struct with illegal index
@@notobj:
		cmp	al,type_method		;method({params,...}) ?
		mov	esi,offset ct_method
		je	@@checkmult

@@chkvarmethod:	call	check_var_method	;var({params,...}){:returns} ?
		jne	@@single		;if not var method, compile as expression
		mov	esi,offset ct_method_ptr
		jmp	@@checkmult2

@@checkmult:	shr	ebx,20			;multiple return values?
		and	ebx,0Fh
@@checkmult2:	cmp	ebx,2
		jb	@@single		;if no result, will be caught by compile_exp

		pop	edx			;get source pointer into edx for ct_method_ptr
		mov	[source_ptr],edx	;back up to obj/method/var symbol
		push	ebx			;save number of results
		push	[source_start]		;save source pointers
		push	[source_finish]
		call	get_element_obj		;get symbol again
		mov	ch,2			;(multiple results allowed)
		mov	cl,bc_drop_push		;(drop anchor - push)
		call	esi			;compile obj{[]}.method({params,...}) / method({params,...}) / var({params,...}):2+
		pop	[source_finish]		;restore source pointers in case error
		pop	[source_start]
		pop	eax			;restore number of results
		jmp	@@exit


@@single:	pop	[source_ptr]		;compile expression
		call	compile_exp		;will error if no return value
		mov	eax,1			;set one result

@@exit:		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		ret
;
;
; Compile a parameter for SEND - accommodates methods with no return value
; on exit, eax holds 0 or 1 for number of parameters on the stack
;
;	obj{[]}.method({params,...})
;	method({params,...})
;	var({params,...}){:1}
;
compile_parameter_send:

		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi
		push	[source_ptr]		;save source pointer

		call	get_element_obj		;get element to check


		cmp	al,type_obj		;obj{[]}.method({params,...}) ?
		jne	@@notobj
		call	check_index		;skip any index
		call	get_dot			;get '.'
		mov	eax,ebx			;get obj_pub/int/float/struct
		call	get_obj_symbol
		mov	esi,offset ct_objpub
		je	@@checkmult		;obj_pub? (index okay)
		jmp	error_oiina		;error, obj_int/float/struct with illegal index
@@notobj:
		cmp	al,type_method		;method({params,...}) ?
		mov	esi,offset ct_method
		je	@@checkmult

		call	check_var_method	;var({params,...}){:returns} ?
		jne	@@exp			;if not var method, compile as expression
		mov	esi,offset ct_method_ptr
		jmp	@@checkmult2

@@checkmult:	shr	ebx,20			;check return values?
		and	ebx,0Fh
@@checkmult2:	cmp	ebx,1
		ja	error_spmcrmv		;if multiple return values, not allowed by SEND
		je	@@exp			;if one return value, compile as expression

		pop	edx			;no return value, get source pointer into edx for ct_method_ptr
		mov	[source_ptr],edx	;back up to obj/method/var symbol
		push	[source_start]		;save source pointers
		push	[source_finish]
		call	get_element_obj		;get symbol again
		mov	ch,0			;(no result okay)
		mov	cl,bc_drop		;(drop anchor)
		call	esi			;compile obj{[]}.method({params,...}) / method({params,...}) / var({params,...}){:0}
		pop	[source_finish]		;restore source pointers in case error
		pop	[source_start]
		mov	eax,0			;set no result
		jmp	@@exit


@@exp:		pop	[source_ptr]		;compile expression
		call	compile_exp
		mov	eax,1			;set one result

@@exit:		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		ret
;
;
; Check for var({params,...}){:returns}
; al must hold type
; on exit, z=1 if method with number of return values in ebx
;
check_var_method:

		push	esi
		push	edi

		push	[source_start]		;save source pointers
		push	[source_finish]

		call	check_var		;check for variable
		jne	@@not			;if not variable, not method
		call	check_left		;if no '(', not method
		jne	@@not

		cmp	ch,type_register	;if RECV(), no parameters allowed, one return value
		jne	@@notrecv
		cmp	esi,mrecv_reg
		jne	@@notrecv
		call	get_right
		mov	ebx,1
		jmp	@@is
@@notrecv:
		cmp	ch,type_register	;if SEND(param{,...}), parameters allowed, no return value
		jne	@@notsend
		cmp	esi,msend_reg
		jne	@@notsend
		call	scan_to_right
		mov	ebx,0
		jmp	@@is
@@notsend:
		call	scan_to_right		;skip parameters to ')'

		call	get_colon_result_count	;check for colon and result count, ebx = count

@@is:		cmp	eax,eax			;is var method, z=1

@@not:		pop	[source_finish]		;restore source pointers in case error
		pop	[source_start]

		pop	edi
		pop	esi
		ret
;
;
; Get method pointer variable - must be long/reg without bitfield
;
get_method_ptr_var:

		call	get_element_obj		;get variable name (may be type_obj_con_struct --> type_con_struct)
		push	[source_start]		;push source pointers in case error
		push	[source_finish]
		call	back_element

		call	get_variable		;get variable

		test	ecx,var_bitfield_flag	;no bitfield allowed
		jnz	@@exit

		mov	al,ch			;structure long member is allowed
		call	is_struct
		jne	@@notstruct
		cmp	[compiled_struct_flags],3
		jne	@@notstruct
		cmp	[compiled_struct_word_size],2
		je	@@exit
@@notstruct:
		cmp	cl,2			;long hub variable is allowed
		je	@@exit

		cmp	ch,type_register	;register is allowed

@@exit:		pop	[source_finish]		;pop source pointers
		pop	[source_start]

		jne	error_mpmblv		;error?

		ret
;
;
; Get structure and size from struct definition or structure variable
; on exit, eax holds size
;
get_struct_and_size:

		call	get_element_obj			;check for lone type_con_struct (no '[' indicating variable)
		cmp	al,type_con_struct
		jne	@@notcon
		call	check_leftb
		jne	get_con_struct_size		;if lone type_con_struct, get size (struct id in ebx)
		call	back_element
@@notcon:	call	back_element

		call	get_struct_variable		;get structure variable
		mov	eax,[compiled_struct_size]	;get size

		ret
;
;
; Get structure variable (not byte/word/long member)
;
get_struct_variable:

		call	get_variable			;get variable

		mov	al,ch				;must be structure
		call	is_struct
		jne	error_easn

		cmp	[compiled_struct_flags],3	;cannot be a byte/word/long member
		je	error_easn

		ret
;
;
; Get variable
;
get_variable:	call	get_element_obj

		call	check_var
		jne	error_eav

		ret
;
;
; Check variable
; on entry, al must hold type and ebx must hold value
; on exit, z=1 if variable with ecx/esi/edi set
;
;
;	ecx:31:24  = variable pointer pre/post-inc/dec-push bytecode or 0 for read
;
;	ecx.19     = bitfield constant flag
;	ecx.18     = bitfield flag
;	ecx.17     = index flag
;	ecx.16     = size override flag
;
;	ch         = type_register
;	             type_field
;	             type_size
;
;	             type_loc_byte
;	             type_loc_byte_ptr
;	             type_var_byte
;	             type_var_byte_ptr
;	             type_dat_byte
;
;	             type_con_struct
;	             type_loc_struct
;	             type_loc_struct_ptr
;	             type_var_struct
;	             type_var_struct_ptr
;	             type_dat_struct
;
;	cl         = 0:byte/default
;	             1:word in hub
;	             2:long in hub
;
;	esi = address (reg/loc/var/dat/hub/struct)
;	edi = source_ptr after variable (points to [base]/[index]/.[bitfield] exp)
;
;
;	register
;	--------------------------------------------------------------------------
;	type_reg	(REG)
;	type_register
;	--------------------------------------------------------------------------
;	        REG [register] {[index]} {.[bitfield]}
;	        regname        {[index]} {.[bitfield]}
;
;
;	register/hub FIELD
;	--------------------------------------------------------------------------
;	type_field	(FIELD)
;	--------------------------------------------------------------------------
;	        FIELD [memfield] {[index]}
;
;
;	hub BYTE/WORD/LONG
;	--------------------------------------------------------------------------
;	type_size	(BYTE/WORD/LONG)
;	--------------------------------------------------------------------------
;	        BYTE/WORD/LONG [base]            {[index]} {.[bitfield]}
;
;
;	hub byte/word/long variable
;	--------------------------------------------------------------------------
;	type_loc_byte / type_var_byte / type_dat_byte / type_hub_byte
;	type_loc_word / type_var_word / type_dat_word / type_hub_word
;	type_loc_long / type_var_long / type_dat_long / type_hub_long
;	--------------------------------------------------------------------------
;	        hubvar         {.BYTE/WORD/LONG} {[index]} {.[bitfield]}
;
;
;	hub byte/word/long variable pointer	(++/-- is byte/word/long sized)
;	--------------------------------------------------------------------------
;	type_loc_byte_ptr / type_var_byte_ptr
;	type_loc_word_ptr / type_var_word_ptr
;	type_loc_long_ptr / type_var_long_ptr
;	--------------------------------------------------------------------------
;	        hubptr         {.BYTE/WORD/LONG} {[index]} {.[bitfield]}
;	[++/--] hubptr         {.BYTE/WORD/LONG} {[index]} {.[bitfield]}
;	        hubptr [++/--] {.BYTE/WORD/LONG} {[index]} {.[bitfield]}
;
;	       [hubptr]
;
;
;	hub CON STRUCT variable
;	--------------------------------------------------------------------------
;	type_con_struct
;	--------------------------------------------------------------------------
;	        structname [base] {[index]} {.member {[index]}} {.[bitfield]}
;
;
;	hub struct variable
;	--------------------------------------------------------------------------
;	type_loc_struct / type_var_struct / type_dat_struct
;	--------------------------------------------------------------------------
;	        structvar         {[index]} {.member {[index]}} {.[bitfield]}
;
;
;	hub struct variable pointer		(++/-- is struct sized)
;	--------------------------------------------------------------------------
;	type_loc_struct_ptr / type_var_struct_ptr
;	--------------------------------------------------------------------------
;	        structptr         {[index]} {.member {[index]}} {.[bitfield]}
;	[++/--] structptr         {[index]} {.member {[index]}} {.[bitfield]}
;	        structptr [++/--] {[index]} {.member {[index]}} {.[bitfield]}
;
;	       [structptr]
;
;
var_bitfield_con	=	080000h
var_bitfield_flag	=	040000h
var_index_flag		=	020000h
var_size_override	=	010000h


check_var:	push	eax
		push	ebx

		cmp	al,type_recv		;RECV?
		jne	@@notrecv
		mov	al,type_register
		mov	ebx,mrecv_reg
@@notrecv:
		cmp	al,type_send		;SEND?
		jne	@@notsend
		mov	al,type_register
		mov	ebx,msend_reg
@@notsend:
		xor	ecx,ecx			;reset flags

		mov	ch,al			;save type into ch
		mov	esi,ebx			;save address or struct id into esi
		mov	edi,[source_ptr]	;save current source pointer into edi


		call	is_ptr			;ptr{[++/--]} ?
		jne	@@notpostptr
		call	check_leftb		;check for '['
		jne	@@gotptr
		call	get_element		;get possible ++/--
		call	check_rightb		;check for ']'
		jne	@@notpost
		cmp	al,type_inc		;ptr[++] ?
		je	@@postinc
		cmp	al,type_dec		;ptr[--] ?
		je	@@postdec
		call	back_element		;not ptr[++/--], back up to after ptr
@@notpost:	call	back_element
		call	back_element
		jmp	@@gotptr		;got ptr[++/--]
@@postinc:	or	ecx,bc_var_postinc_push shl 24
		jmp	@@gotptr
@@postdec:	or	ecx,bc_var_postdec_push shl 24
		jmp	@@gotptr
@@notpostptr:
		cmp	al,type_leftb		;[ptr] or [++/--]ptr ?
		jne	@@notpreptr
		call	get_element		;get ptr/++/--
		call	get_rightb		;get ']'
		call	is_ptr			;[ptr] ?
		je	@@ptrval
		cmp	al,type_inc		;[++] ?
		je	@@preinc
		cmp	al,type_dec		;[--] ?
		je	@@predec
		jmp	error_eptrid		;else, error
@@preinc:	or	ecx,bc_var_preinc_push shl 24
		jmp	@@preptr
@@predec:	or	ecx,bc_var_predec_push shl 24
@@preptr:	call	get_element		;got [++/--], get ptr
		call	is_ptr
		jne	error_eptr
		mov	ch,al			;save type into ch
		mov	esi,ebx			;save value into esi
		jmp	@@gotptr		;got [++/--]ptr

@@ptrval:	mov	ch,al			;got [ptr], save type into ch
		add	ch,4			;convert type_???_????_ptr to type_???_????_ptr_val
		mov	esi,ebx			;save value into esi
		mov	edi,[source_ptr]	;save current source pointer into edi
		jmp	@@isvar			;[ptr] cannot have bitfield

@@gotptr:	mov	edi,[source_ptr]	;save current source pointer into edi
		mov	al,ch			;al=type
		mov	ebx,esi			;ebx=value
@@notpreptr:

		call	is_struct		;struct? (struct ptr already handled)
		jne	@@notstruct
		call	skip_struct_setup	;skip struct arguments
		cmp	[compiled_struct_flags],3
		je	@@chkbitfield		;if struct byte/word/long, may have bitfield
		jmp	@@isvar			;struct reference cannot have bitfield
@@notstruct:

		and	esi,0FFFFFh		;strip address of any register field

		mov	ch,type_loc_byte	;loc byte/word/long?
		cmp	al,ch
		jb	@@notloc
		cmp	al,type_loc_long
		jbe	@@lvdh
@@notloc:
		mov	ch,type_loc_byte_ptr	;loc byte/word/long ptr?
		cmp	al,ch
		jb	@@notlocptr
		cmp	al,type_loc_long_ptr
		jbe	@@lvdh
@@notlocptr:
		mov	ch,type_var_byte	;var byte/word/long?
		cmp	al,ch
		jb	@@notvar
		cmp	al,type_var_long
		jbe	@@lvdh
@@notvar:
		mov	ch,type_var_byte_ptr	;var byte/word/long ptr?
		cmp	al,ch
		jb	@@notvarptr
		cmp	al,type_var_long_ptr
		jbe	@@lvdh
@@notvarptr:
		mov	ch,type_dat_byte	;dat byte/word/long?
		cmp	al,ch
		jb	@@notdat
		cmp	al,type_dat_long
		jbe	@@lvdh
@@notdat:
		mov	ch,type_hub_byte	;hub byte/word/long?
		cmp	al,ch
		jb	@@nothub
		cmp	al,type_hub_long
		jbe	@@lvdh
@@nothub:

		cmp	al,type_reg		;reg[address]?
		jne	@@notreg
		call	get_leftb
		mov	bl,10b
		call	try_value_int
		cmp	ebx,1FFh
		ja	error_cmbf0t511
		call	get_rightb
		mov	al,type_register
		mov	esi,ebx
		mov	edi,[source_ptr]
@@notreg:
		cmp	al,type_field		;FIELD[memfield]?
		jne	@@notfield
		mov	ch,type_field
		call	skip_index
		call	check_index		;check for [index]
		jne	@@isvar
		or	ecx,var_index_flag
		jmp	@@isvar
@@notfield:
		mov	ch,al			;other

		cmp	al,type_register	;register?
		je	@@checkindex

		cmp	al,type_size		;BYTE/WORD/LONG?
		jne	@@exit			;if not, exit with z=0
		call	check_index		;check for [base]
		jne	@@exit			;if not, exit with z=0
		mov	cl,bl			;remember size
		jmp	@@checkindex

@@lvdh:		call	check_dot		;loc/var/dat/hub, check for .BYTE/WORD/LONG
		jne	@@lvdhnodot
		push	eax			;got '.', check for BYTE/WORD/LONG
		call	get_element
		cmp	al,type_size
		mov	cl,bl
		pop	eax
		jne	@@lvdhbackup
		or	ecx,var_size_override	;got .BYTE/WORD/LONG, set size override flag
		jmp	@@checkindex
@@lvdhbackup:	call	back_element
		call	back_element
@@lvdhnodot:	mov	cl,al			;get size into cl
		sub	cl,ch

@@checkindex:	call	check_index		;check for [index]
		jne	@@noindex
		or	ecx,var_index_flag
@@noindex:
@@chkbitfield:	call	check_dot		;check for .[bitfield]
		jne	@@nobf
		or	ecx,var_bitfield_flag	;set bitfield flag
		call	get_leftb		;get '['
		call	skip_exp_check_con	;skip expression, checking for constant
		jnz	@@notcon
		or	ecx,var_bitfield_con
@@notcon:	call	check_dotdot		;check for '..'
		jne	@@bfrb
		call	skip_exp_check_con	;skip expression, checking for constant
		jz	@@bfrb
		and	ecx,not var_bitfield_con
@@bfrb:		call	get_rightb		;get ']'
		mov	[compiled_struct_flags],3	;set struct byte/word/long in case disturbed by skip_exp_check_con
@@nobf:
@@isvar:	xor	eax,eax			;z=1

@@exit:		pop	ebx
		pop	eax
		ret
;
;
; Compile variable
; check_var must have been called (ecx,esi,edi valid)
; dl must hold operation (0=read, 1=write, 2=setup-assign)
; dh must hold any assignment bytecode
;
compile_var:	push	eax
		push	ebx
		push	ecx
		push	edx
		push	[source_ptr]

		mov	[source_ptr],edi	;point after var


		test	ecx,var_bitfield_flag	;compile any non-constant bitfield first
		jz	@@nobf
		test	ecx,var_bitfield_con	;if bitfield-constant, nothing to compile here
		jnz	@@nobf

		push	[source_ptr]		;save source_ptr
		mov	al,ch			;if struct, skip it
		call	is_struct
		jne	@@bfnotstruct
		mov	ebx,esi
		call	skip_struct_setup
@@bfnotstruct:	cmp	ch,type_size		;if byte/word/long, skip [base]
		jne	@@bfnotsize
		call	skip_index
@@bfnotsize:	test	ecx,var_size_override	;if size override, skip .BYTE/WORD/LONG
		jz	@@bfnsor
		call	get_dot
		call	get_size
@@bfnsor:	test	ecx,var_index_flag	;if index, skip [index]
		jz	@@bfnoindex
		call	skip_index
@@bfnoindex:	call	get_dot			;get '.'
		call	get_leftb		;get '['
		call	compile_exp		;compile bitfield expression
		call	check_dotdot		;'top..bottom'?
		jne	@@bfnotspan
		call	compile_exp
		mov	al,bc_bitrange
		call	enter_obj
		mov	al,bc_addbits
		call	enter_obj
@@bfnotspan:	call	get_rightb		;get ']'
		pop	[source_ptr]		;restore source_ptr
@@nobf:

		mov	al,ch			;[hubptr/structptr]?
		call	is_ptr_val
		jne	@@notptrval

		mov	ebx,1			;set default inc/dec value to 1

		cmp	dl,2			;check for assign plus pre/post-inc/dec
		jne	@@ptrvalx
		cmp	dh,bc_var_inc
		je	@@ptrvalincdec
		cmp	dh,bc_var_dec
		je	@@ptrvalincdec
		cmp	dh,bc_var_preinc_push
		je	@@ptrvalincdec
		cmp	dh,bc_var_predec_push
		je	@@ptrvalincdec
		cmp	dh,bc_var_postinc_push
		je	@@ptrvalincdec
		cmp	dh,bc_var_postdec_push
		jne	@@ptrvalx

@@ptrvalincdec:	call	is_struct_ptr_val		;pre/post-inc/dec [structptr]?
		jne	@@ptrvalhub
		mov	ebx,esi				;get struct size
		shr	ebx,20
		call	get_con_struct_size
		mov	ebx,eax				;if size is 1, no special inc/dec value
		jmp	@@ptrvalx

@@ptrvalhub:	cmp	ch,type_loc_byte_ptr_val	;pre/post-inc/dec [hubptr]
		je	@@ptrvalx			;if byte ptr, no special inc/dec value
		cmp	ch,type_var_byte_ptr_val
		je	@@ptrvalx
		mov	ebx,2				;if word ptr, inc/dec value is 2
		cmp	ch,type_loc_word_ptr_val
		je	@@ptrvalx
		cmp	ch,type_var_word_ptr_val
		je	@@ptrvalx
		mov	ebx,4				;must be long ptr, inc/dec value is 4

@@ptrvalx:	cmp	ch,type_loc_byte_ptr_val	;convert type_loc/var_????_ptr_val to type_loc/var_byte
		jb	@@ptrvalvar
		cmp	ch,type_loc_struct_ptr_val
		ja	@@ptrvalvar
		mov	ch,type_loc_byte
		jmp	@@ptrvalloc
@@ptrvalvar:	mov	ch,type_var_byte
@@ptrvalloc:	mov	cl,2			;set long size
		and	esi,0FFFFFh		;mask away any struct id
		call	compile_var		;compile pointer variable assign
		cmp	ebx,1			;if no special inc/dec value, done
		jz	@@done

		dec	[obj_ptr]		;special inc/dec value, back up over pre/post-inc/dec assign
		mov	al,bc_set_incdec	;compile inc/dec-value modifier and special inc/dec value
		call	enter_obj
		mov	eax,ebx
		call	compile_rfvar
		mov	al,dh			;reenter pre/post-inc/dec assign
		jmp	@@enter
@@notptrval:

		mov	al,ch			;hubptr/structptr?
		call	is_ptr
		jne	@@notptr
		call	is_struct_ptr		;structptr will be handled as struct
		je	@@notptr

		push	ecx			;save type, size, and flags
		push	edx			;save read/write/assign
		mov	edx,ecx			;check for pre/post-inc/dec-push assign
		shr	edx,24
		jz	@@ptrnoas		;if no assign, read (dl=0)
		mov	dh,dl			;assign, dh=bytecode, dl=2
		mov	dl,2
@@ptrnoas:	add	ch,4			;convert type_loc/dat_byte_ptr to type_loc/dat_byte_ptr_val
		add	ch,cl			;add in size
		movzx	ecx,cx			;clear all variable flags to inhibit any special compilation
		call	compile_var		;compile read/assign of pointer variable
		pop	edx			;restore read/write/assign
		pop	ecx			;restore type, size, and flags

		test	ecx,var_size_override	;if size override, skip .BYTE/WORD/LONG
		jz	@@ptrnosor
		call	get_dot
		call	get_size
@@ptrnosor:
		test	ecx,var_index_flag	;index?
		mov	al,bc_setup_byte_pa	;without index
		jz	@@ptrni
		call	compile_index		;with index
		mov	al,bc_setup_byte_pb_pi
@@ptrni:	add	al,cl
		jmp	@@entersetup
@@notptr:

		mov	al,ch					;struct?
		call	is_struct
		jne	@@notstruct

		mov	ebx,esi					;compile struct setup
		call	compile_struct_setup
		cmp	[compiled_struct_flags],3		;if not byte/word/long member, handle (sub)struct
		jne	@@structnotbwl
		cmp	ch,type_con_struct			;if type_con_struct, not optimizable, handle bitfield
		je	@@enterbit
		cmp	ch,type_loc_struct_ptr			;if type_loc_struct_ptr, not optimizable, handle bitfield
		je	@@enterbit
		cmp	ch,type_var_struct_ptr			;if type_var_struct_ptr, not optimizable, handle bitfield
		je	@@enterbit
		cmp	[compiled_struct_index_mode],1		;if struct indexing, not optimizable, handle bitfield
		ja	@@enterbit
		jne	@@structnindex				;optimize type_loc/var/dat_struct using normal setups, index?
		or	ecx,var_index_flag			;if index after byte/word/long member, set index flag
@@structnindex:	sub	ch,3					;convert type_loc/var/dat_struct to type_loc/var/dat_byte
		mov	cl,[compiled_struct_word_size]		;get 0/1/2 (byte/word/long) size in cl
		mov	esi,[compiled_struct_address]		;get byte/word/long base-offset address in esi
		mov	eax,[compiled_struct_source_ptr]	;set source_ptr after byte/word/long member, before any index
		mov	[source_ptr],eax
		mov	eax,[compiled_struct_obj_ptr]		;set obj_ptr back to struct setup bytecodes for rewriting
		mov	[obj_ptr],eax
		jmp	@@notstruct				;proceed as type_loc/var/dat_byte to use smaller primitive setups
@@structnotbwl:
		cmp	dl,2					;assignment?
		jne	@@structnotass
		cmp	dh,bc_get_addr				;only @struct is allowed
		jne	error_oaocbats
		mov	al,0					;enter 0 to get address
		jmp	@@enter
@@structnotass:
		mov	eax,[compiled_struct_size]		;read or write
		call	check_struct_stack_fit			;make sure struct fits on stack
		cmp	dl,1					;if write/pop, enter byte count
		je	@@enter
		or	al,80h					;if read/push, enter byte count | 80h
		jmp	@@enter
@@notstruct:

		cmp	ch,type_field		;FIELD[memfield]?
		jne	@@notfield
		call	compile_index
		test	ecx,var_index_flag	;index?
		mov	al,bc_setup_field_p
		jz	@@entersetup
		call	compile_index
		mov	al,bc_setup_field_pi
		jmp	@@entersetup
@@notfield:

		cmp	ch,type_register	;register?
		jne	@@notreg

		cmp	esi,prx_regs+0		;pr0..pr7 with no index?
		jb	@@notregpasm
		cmp	esi,prx_regs+7
		ja	@@notregpasm
		test	ecx,var_index_flag	;index?
		jnz	@@notregpasm
		mov	eax,esi			;enter setup $1F8..$1FF bytecode
		sub	eax,prx_regs
		add	eax,bc_setup_reg_1D8_1F8+0
		jmp	@@entersetup
@@notregpasm:
		cmp	esi,1F8h		;$1F8..$1FF with no index?
		jb	@@notregio
		cmp	esi,1FFh
		ja	@@notregio
		test	ecx,var_index_flag	;index?
		jnz	@@notregio
		mov	eax,esi			;enter setup $1F8..$1FF bytecode
		sub	eax,1F8h
		add	eax,bc_setup_reg_1D8_1F8+8
		jmp	@@entersetup
@@notregio:
		test	ecx,var_index_flag	;register index?
		mov	al,bc_setup_reg		;get non-index bytecode
		jz	@@notregi		;if no index, got bytecode and reg
		call	@@compileindex		;compile index, checking for constant
		mov	al,bc_setup_reg_pi	;get index bytecode
		jnz	@@notregi		;if not constant index, got bytecode and reg
		mov	al,bc_setup_reg		;constant, revert to non-index bytecode	TESTT could be optimized to use single bytecode by having two: one for $0xx and one for $1xx
		call	enter_obj		;enter setup bytecode
		mov	eax,esi			;get reg address plus index
		add	eax,[con_value]		;add index into reg
		jmp	@@regsignx
@@notregi:	call	enter_obj		;enter setup bytecode
		mov	eax,esi			;get reg address
@@regsignx:	shl	eax,32-9		;sign-extend address to express bottom/top reg addresses in one byte
		sar	eax,32-9
		call	compile_rfvars		;compile rfvars for base register
		jmp	@@enterbit
@@notreg:

		cmp	ch,type_size		;BYTE/WORD/LONG?
		jne	@@notsize
		test	ecx,var_index_flag	;index?
		mov	al,bc_setup_byte_pa	;without index
		jz	@@sizeni
		call	compile_index		;with index
		mov	al,bc_setup_byte_pb_pi
@@sizeni:	call	compile_index
		add	al,cl
		jmp	@@entersetup
@@notsize:

		test	ecx,var_size_override	;if size override, skip .BYTE/WORD/LONG
		jz	@@nosor
		call	get_dot
		call	get_size
@@nosor:

		cmp	ch,type_var_byte	;first 16 var longs with no index?
		jne	@@notvar16
		cmp	cl,2			;long?
		jne	@@notvar16
		test	esi,11b			;long aligned?
		jnz	@@notvar16
		cmp	esi,16*4		;first 16?
		jae	@@notvar16
		test	ecx,var_index_flag	;no index?
		jnz	@@notvar16
		mov	eax,esi			;get address nibble
		shr	eax,2
		or	al,bc_setup_var_0_15	;setup, also used for read/write bitfield
		jmp	@@entersetup
@@notvar16:

		cmp	ch,type_loc_byte	;first 16 local longs with no index?
		jne	@@notloc16
		cmp	cl,2			;long?
		jne	@@notloc16
		test	esi,11b			;long aligned?
		jnz	@@notloc16
		cmp	esi,16*4		;first 16?
		jae	@@notloc16
		test	ecx,var_index_flag	;no index?
		jnz	@@notloc16
		mov	eax,esi			;get address nibble
		shr	eax,2
		test	ecx,var_bitfield_flag	;if bitfield, use setup
		jnz	@@loc16setup
		cmp	dl,2			;setup?
		jae	@@loc16setup
		cmp	dl,1			;write?
		je	@@loc16write
		or	al,bc_read_local_0_15	;read
		jmp	@@enter
@@loc16write:	or	al,bc_write_local_0_15	;write
		jmp	@@enter
@@loc16setup:	or	al,bc_setup_local_0_15	;setup, also used for read/write bitfield
		jmp	@@entersetup
@@notloc16:

		cmp	ch,type_hub_byte	;hub byte/word/long with possible index?
		jne	@@nothub

		push	ebx			;compile address
		mov	ebx,esi
		call	compile_constant
		pop	ebx
		test	ecx,var_index_flag	;index?
		mov	al,bc_setup_byte_pa	;without index
		jz	@@hubni
		call	compile_index		;with index
		mov	al,bc_setup_byte_pb_pi
@@hubni:	add	al,cl
		jmp	@@entersetup
@@nothub:

		mov	al,cl			;pbase/vbase/dbase byte/word/long with possible index
		mov	ah,6			;get size*6 to begin setup bytecode
		mul	ah
		add	al,bc_setup_byte_pbase
		cmp	ch,type_dat_byte	;pbase?
		je	@@gotbase
		inc	al
		cmp	ch,type_var_byte	;vbase?
		je	@@gotbase
		inc	al			;dbase
@@gotbase:	test	ecx,var_index_flag	;index?
		jz	@@baseni
		add	al,3			;index, make index bytecode
		call	@@compileindex		;compile index, checking for constant
		jnz	@@baseni		;if not constant, keep compiled index
		sub	al,3			;constant, revert to non-index bytecode
		call	enter_obj		;enter setup bytecode
		shl	[con_value],cl		;scale index constant
		mov	eax,esi			;get offset plus scaled index constant
		add	eax,[con_value]
		call	compile_rfvar		;compile rfvar for base offset
		jmp	@@enterbit
@@baseni:
		call	enter_obj		;enter setup bytecode
		mov	eax,esi			;compile rfvar for base offset
		call	compile_rfvar
		jmp	@@enterbit


@@entersetup:	call	enter_obj		;enter variable-setup bytecode


@@enterbit:	test	ecx,var_bitfield_flag	;bitfield?
		jz	@@nobit
		call	get_dot			;get '.'
		call	get_leftb		;get '['
		test	ecx,var_bitfield_con	;constant bitfield?
		jnz	@@bfcon
		mov	al,bc_setup_bfield_pop	;not constant bitfield, already compiled
		call	skip_exp		;skip bitfield
		call	check_dotdot
		jne	@@bitsetup
		call	skip_exp
		jmp	@@bitsetup
@@bfcon:
		call	skip_exp_check_con	;skip expression, getting constant
		jnz	error_eicon		;(should not error)
		mov	eax,[con_value]		;get constant
		and	eax,3FFh
		call	check_dotdot		;check for '..'
		jne	@@bitcompile
		call	skip_exp_check_con	;skip expression, getting constant
		jnz	error_eicon		;(should not error)
		sub	eax,[con_value]		;get size of bitspan in eax
		and	eax,1Fh
		shl	eax,5
		and	[con_value],1Fh
		or	eax,[con_value]
@@bitcompile:	cmp	eax,31
		jbe	@@bitcon0to31
		push	eax			;>31, bitfield-rfvar
		mov	al,bc_setup_bfield_rfvar
		call	enter_obj
		pop	eax
		call	compile_rfvar
		jmp	@@bitrightb
@@bitcon0to31:	add	al,bc_setup_bfield_0_31	;bitfield-0..31
@@bitsetup:	call	enter_obj
@@bitrightb:	call	get_rightb		;get ']'
@@nobit:

		mov	al,bc_read		;read?
		cmp	dl,0
		je	@@enter
		mov	al,bc_write		;write?
		cmp	dl,1
		je	@@enter
		mov	al,dh			;assign
@@enter:	call	enter_obj

@@done:		pop	[source_ptr]
		pop	edx
		pop	ecx
		pop	ebx
		pop	eax
		ret



@@compileindex:	call	get_leftb		;get '['
		call	compile_exp_check_con	;compile index, check for constant
		pushf
		call	get_rightb		;get ']'
		popf
		ret
;
;
; Compile var operations
;
compile_var_clrset_inst:

		mov	al,dl			;var~/var~~ instruction
		call	enter_obj		;compile 0/-1
		mov	dl,1			;(write)
		jmp	compile_var

compile_var_read:

		call	get_variable
		mov	dl,0			;(read)
		jmp	compile_var

compile_var_write:

		call	get_variable
		mov	dl,1			;(write)
		jmp	compile_var

compile_var_clrset_term:

		mov	al,dl			;var~/var~~ term
		call	enter_obj		;compile 0/-1
		mov	dh,bc_var_swap
		jmp	compile_var_assign

compile_var_exp:

		call	compile_exp		;var := exp, compile expression
		jmp	compile_var_assign

compile_var_pre:

		call	get_variable		;<unary> var
		jmp	compile_var_assign

compile_var_addr:

		mov	dh,bc_get_addr		;@var
		jmp	compile_var_assign

compile_var_assign:

		mov	dl,2			;(assign)
		jmp	compile_var
;
;
; Compile structure setup
;
; on entry:
;
;   struct_name[address]{[index]}{{.byte/word/long/struct{[index]} ...}
;
;	al = type_con_struct, ebx = struct id
;
;   struct_var{[index]}{{.byte/word/long/struct{[index]} ...}
;
;	al = type_loc_struct, ebx.[31..20] = struct id, ebx.[19..0] = loc address of structure
;	al = type_var_struct, ebx.[31..20] = struct id, ebx.[19..0] = var address of structure
;	al = type_dat_struct, ebx.[31..20] = struct id, ebx.[19..0] = dat address of structure
;
;   {[++/--]}struct_ptr{[++/--]}{[index]}{{.byte/word/long/struct{[index]} ...}
;
;	al = type_loc_struct_ptr, ebx.[31..20] = struct id, ebx.[19..0] = loc address of ptr, ecx[31..24] = pre/post-inc/dec-push or 0 for read
;	al = type_var_struct_ptr, ebx.[31..20] = struct id, ebx.[19..0] = var address of ptr, ecx[31..24] = pre/post-inc/dec-push or 0 for read
;
; on exit:
;
;	compiled_struct_flags.[0]	= index or '.' was found, else base structure
;	compiled_struct_flags.[1]	= byte/word/long, else base/sub structure
;
;	compiled_struct_flags		= 0 if base structure (returns address at runtime)
;					  1 if index or sub structure (returns address at runtime)
;					  3 if byte/word/long (performs setup at runtime for read/write/assign)
;
;	compiled_struct_size		= size of last structure/byte/word/long in expression
;	compiled_struct_address		= address of byte/word/long (before any index)
;	compiled_struct_word_size	= size of member, if present (0/1/2 for byte/word/long)
;	compiled_struct_source_ptr	= source pointer after byte/word/long member (before [index]/.[bitfield] exp)
;	compiled_struct_obj_ptr		= obj_ptr of structure-setup bytecodes (after pushed values)
;
;	compiled_struct_index_mode	= 0 if no indexes (can be optimized)
;					  1 if single index on byte/word/long member (can be optimized)
;					  else other case (cannot be optimized)
;
;
; Optimization is possible if the following are all true:
;
;	al				= type_loc/var/dat_struct (not type_con_struct or type_loc/var_struct_ptr)
;	compiled_struct_flags		= 3 (byte/word/long member, not a structure)
;	compiled_struct_index_mode	= 0 (no index) or 1 (single index on byte/word/long member)
;
;
; To optimize for compile_var, set registers as follows:
;
;	cl		= compiled_struct_word_size (0/1/2 for byte/word/long)
;	ch		= ch - 3 (type_???_struct --> type_???_byte)
;	ecx.17		= 1 if compiled_struct_index_mode == 1
;	esi		= compiled_struct_address
;	source_ptr	= compiled_struct_source_ptr
;	obj_ptr		= compiled_struct_obj_ptr
;
;
skip_struct_setup:

		push	[obj_ptr]
		call	compile_struct_setup
		pop	[obj_ptr]
		ret


compile_struct_setup:

		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		mov	[byte @@struct_type],al		;save structure type
		mov	[byte @@flags],0		;clear flags

		cmp	al,type_con_struct		;type_con_struct? (ebx = struct id)
		jne	@@notpopstruct
		call	get_leftb			;get '['
		mov	eax,[source_ptr]		;save pop-address expression ptr
		mov	[@@pop_source_ptr],eax
		lea	eax,[skip_exp]			;skip expression for now
		call	@@exp
		call	get_rightb			;get ']'
		mov	[@@offset],0			;init offset to zero
		jmp	@@gotsetup
@@notpopstruct:
		call	is_struct_ptr			;type_var/con_struct_ptr? (ebx[31..20] = struct id)
		jne	@@notstructptr
		movzx	eax,al				;arrange compile_var settings for setup pop-address
		add	al,4				;convert type_loc/var_struct_ptr to type_loc/var_struct_ptr_val
		shl	eax,8
		mov	[@@var_ecx],eax			;set type_loc/var_struct_ptr_val
		shr	ecx,24
		mov	ah,cl
		mov	al,2
		jnz	@@structptras			;if pre/post-inc/dec-push assignment, al=2, ah=bytecode
		mov	al,0				;else, al=0 for read
@@structptras:	mov	[@@var_edx],eax			;set pre/post-inc/dec-push assignment or read
		mov	[@@var_esi],ebx			;set loc/var address
		mov	eax,[source_ptr]
		mov	[@@var_edi],eax			;set source ptr
		mov	[@@offset],0			;init offset to zero
		jmp	@@gotsetup20
@@notstructptr:
		mov	eax,ebx				;type_loc/var/dat_struct (ebx[31..20] = struct id)
		and	eax,0FFFFFh
		mov	[@@offset],eax			;init offset loc/var/dat address
@@gotsetup20:	shr	ebx,20				;get struct id
@@gotsetup:
		mov	[@@index_count],0		;{[index]}{{.byte/word/long/struct{[index]} ...}

		lea	esi,[struct_def]		;point to start of structure record
		add	esi,[struct_id_to_def+ebx*4]


@@structloop:	lodsw					;skip structure record size

		lodsd					;get structure size
		mov	[@@size],eax

		call	@@handleindex			;handle structure index

		mov	[byte @@word_size],3		;set word size to 3 in case no member

		call	check_dot			;check for '.'
		jne	@@compile			;if no '.' then compile setup

		call	check_leftb			;if '.[', bitfield, back up to '.' and compile setup
		jne	@@notbitfield
		call	back_element
		call	back_element
		jmp	@@compile
@@notbitfield:
		or	[byte @@flags],01b		;set index/dot flag

		call	get_symbol			;get symbol, ecx holds length
		jc	error_easmn
		mov	[@@symbol_length],ecx


@@checkmember:	lodsd					;(next) structure member, get offset
		mov	[@@member_offset],eax
		lodsb					;get type
		mov	[byte @@member_type],al
		cmp	al,3				;struct type?
		jne	@@notstruct
		mov	edx,esi				;remember sub-struct record offset
		movzx	eax,[word esi]			;skip sub-struct record for now
		add	esi,eax
@@notstruct:	lodsb					;get member name length
		movzx	ecx,al				;copy member name to symbol2
		lea	edi,[symbol2]
	rep	movsb

		mov	ecx,[@@symbol_length]		;compare member name length
		cmp	cl,al
		jne	@@notmatch

		push	esi				;compare member name
		lea	esi,[symbol]
		lea	edi,[symbol2]
	repe	cmpsb
		pop	esi
		jne	@@notmatch

		mov	eax,[@@member_offset]		;got match, update offset
		add	[@@offset],eax

		mov	cl,[byte @@member_type]		;sub-struct? (3)
		cmp	cl,3
		jne	@@notstruct2			;if not struct, byte/word/long
		mov	esi,edx				;struct, repoint to sub-struct
		jmp	@@structloop
@@notstruct2:
		or	[byte @@flags],10b		;byte/word/long (0/1/2), set byte/word/long flag

		mov	[byte @@word_size],cl		;set word size to 0/1/2 for byte word long
		mov	eax,1				;set size to 1/2/4
		shl	eax,cl
		mov	[@@size],eax
		push	[source_ptr]			;remember source_ptr after byte/word/long member,
		pop	[@@post_source_ptr]		;..in case single dynamic index
		push	[@@index_count]			;remember index count
		call	@@handleindex			;handle byte/word/long index
		pop	eax				;juxtapose prior index count and current index count
		shl	eax,2
		or	eax,[@@index_count]
		mov	[@@index_mode],eax		;save index mode
		cmp	al,1				;if no single dynamic index on byte/word/long,
		je	@@gotindex			;..may be static index, so remember source_ptr
		push	[source_ptr]
		pop	[@@post_source_ptr]
@@gotindex:	jmp	@@compile			;compile setup

@@notmatch:	lodsb					;not found, another member to check?
		cmp	al,0
		jne	@@checkmember
		jmp	error_sdnctn


@@compile:	mov	eax,[obj_ptr]			;remember initial obj_ptr in case later optimization
		mov	[@@initial_obj_ptr],eax

		cmp	[@@index_count],0		;compile any runtime index expressions in push order
		je	@@noindexexp
		push	[source_ptr]
		mov	ecx,0
@@indexexp:	mov	eax,[@@index_source_ptr+ecx*4]
		mov	[source_ptr],eax
		lea	eax,[compile_exp]
		call	@@exp
		inc	ecx
		cmp	ecx,[@@index_count]
		jne	@@indexexp
		pop	[source_ptr]
@@noindexexp:
		cmp	[byte @@struct_type],type_con_struct	;compile pop address if type_con_struct
		jne	@@notpopaddr
		call	back_element			;preserve element history so ci_debug works properly
		push	[source_ptr]
		mov	eax,[@@pop_source_ptr]
		mov	[source_ptr],eax
		lea	eax,[compile_exp]
		call	@@exp
		pop	[source_ptr]
		call	skip_element			;get one element in history
@@notpopaddr:
		mov	al,[byte @@struct_type]		;compile pop address if type_dat/loc_struct_ptr
		call	is_struct_ptr
		jne	@@notptr
		mov	ecx,[@@var_ecx]			;type and long size
		mov	edx,[@@var_edx]			;pre/post-inc/dec-push assign or read
		mov	esi,[@@var_esi]			;loc/dat address
		mov	edi,[@@var_edi]			;source ptr
		lea	eax,[compile_var]		;compile variable read for pop-address
		call	@@exp
@@notptr:
		mov	ah,[byte @@struct_type]		;enter bytecode
		cmp	ah,type_loc_struct
		mov	al,bc_setup_struct_dbase	;type_loc_struct
		je	@@gotbc
		cmp	ah,type_var_struct
		mov	al,bc_setup_struct_vbase	;type_var_struct
		je	@@gotbc
		cmp	ah,type_dat_struct
		mov	al,bc_setup_struct_pbase	;type_dat_struct
		je	@@gotbc
		mov	al,bc_setup_struct_pop		;type_con_struct / type_loc_struct_ptr / type_var_struct_ptr
@@gotbc:	call	enter_obj

		movzx	eax,[byte @@word_size]		;enter rfvar value: 20 address bits, 2 size bits, 2 index-count bits
		inc	al
		and	al,11b				;structure/byte/word/long = 0/1/2/3
		shl	al,2
		or	al,[byte @@index_count]		;index count = 0..3
		mov	ebx,[@@offset]
		shl	ebx,4				;install address
		or	eax,ebx
		call	compile_rfvar

		mov	ecx,[@@index_count]		;enter any runtime index sizes in pop order
		jecxz	@@noindexexp2
@@indexexp2:	mov	eax,[@@index_size-4+ecx*4]
		call	compile_rfvar
		loop	@@indexexp2
@@noindexexp2:
		mov	al,[byte @@flags]		;set flags
		mov	[compiled_struct_flags],al

		mov	eax,[@@size]			;set structure/byte/word/long size
		mov	[compiled_struct_size],eax

		mov	eax,[@@offset]			;set address
		mov	[compiled_struct_address],eax

		mov	al,[byte @@word_size]		;set word size
		mov	[compiled_struct_word_size],al

		mov	eax,[@@post_source_ptr]		;set source_ptr after byte/word/long
		mov	[compiled_struct_source_ptr],eax

		mov	eax,[@@initial_obj_ptr]		;set initial obj_ptr
		mov	[compiled_struct_obj_ptr],eax

		mov	al,[byte @@index_mode]		;set index mode
		mov	[compiled_struct_index_mode],al

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		pop	eax
		ret



@@handleindex:	call	check_leftb			;check for index
		je	@@isindex
		ret

@@isindex:	or	[byte @@flags],01b		;set index/dot flag
		cmp	[@@size],0FFFFh			;index, error if structure exceeds $FFFF bytes
		ja	error_iscexb
		mov	eax,[@@index_count]		;save index expression source pointer and size
		mov	ebx,[source_ptr]
		mov	[@@index_source_ptr+eax*4],ebx	;a fourth @@index_source_ptr and @@index_size were
		mov	ebx,[@@size]			;..needed to accommodate constant-index cases after
		mov	[@@index_size+eax*4],ebx	;..the limit of three variable-index cases is reached
		lea	eax,[skip_exp_check_con]	;check if [con] or [exp] without advancing obj_ptr
		call	@@exp
		jz	@@indexcon
		inc	[@@index_count]			;[exp], limit reached?
		cmp	[@@index_count],3
		ja	error_loxrs
		jmp	get_rightb

@@indexcon:	mov	eax,[con_value]			;[con], check range
		cmp	eax,0FFFFh
		ja	error_simbf
		mul	[@@size]			;multiply by size and add to offset
		cmp	eax,obj_size_limit
		ja	@@error_sehr
		add	[@@offset],eax
		cmp	[@@offset],obj_size_limit
		ja	@@error_sehr
		jmp	get_rightb

@@error_sehr:	jmp	error_sehr			;error, structure exceeds hub range


@@exp:		push	[@@struct_type]			;save state before compiling expression
		push	[@@flags]
		push	[@@pop_source_ptr]
		push	[@@offset]
		push	[@@var_ecx]
		push	[@@var_edx]
		push	[@@var_esi]
		push	[@@var_edi]
		push	[@@symbol_length]
		push	[@@size]
		push	[@@word_size]
		push	[@@member_offset]
		push	[@@member_type]
		push	[@@initial_obj_ptr]
		push	[@@post_source_ptr]
		push	[@@index_mode]
		push	[@@index_count]
		push	[@@index_source_ptr]
		push	[@@index_source_ptr_1]
		push	[@@index_source_ptr_2]
		push	[@@index_source_ptr_3]
		push	[@@index_size]
		push	[@@index_size_1]
		push	[@@index_size_2]
		push	[@@index_size_3]

		push	eax
		push	ebx
		push	ecx
		push	edx
		push	esi
		push	edi

		call	eax				;compile expression (possibly reentrant)

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	ebx
		pop	eax

		pop	[@@index_size_3]		;restore state
		pop	[@@index_size_2]
		pop	[@@index_size_1]
		pop	[@@index_size]
		pop	[@@index_source_ptr_3]
		pop	[@@index_source_ptr_2]
		pop	[@@index_source_ptr_1]
		pop	[@@index_source_ptr]
		pop	[@@index_count]
		pop	[@@index_mode]
		pop	[@@post_source_ptr]
		pop	[@@initial_obj_ptr]
		pop	[@@member_type]
		pop	[@@member_offset]
		pop	[@@word_size]
		pop	[@@size]
		pop	[@@symbol_length]
		pop	[@@var_edi]
		pop	[@@var_esi]
		pop	[@@var_edx]
		pop	[@@var_ecx]
		pop	[@@offset]
		pop	[@@pop_source_ptr]
		pop	[@@flags]
		pop	[@@struct_type]
		ret


ddx		@@struct_type
ddx		@@flags
ddx		@@pop_source_ptr
ddx		@@offset
ddx		@@var_ecx
ddx		@@var_edx
ddx		@@var_esi
ddx		@@var_edi
ddx		@@symbol_length
ddx		@@size
ddx		@@word_size
ddx		@@member_offset
ddx		@@member_type
ddx		@@initial_obj_ptr
ddx		@@post_source_ptr
ddx		@@index_mode
ddx		@@index_count
ddx		@@index_source_ptr
ddx		@@index_source_ptr_1
ddx		@@index_source_ptr_2
ddx		@@index_source_ptr_3
ddx		@@index_size
ddx		@@index_size_1
ddx		@@index_size_2
ddx		@@index_size_3

dbx		compiled_struct_flags
ddx		compiled_struct_size
ddx		compiled_struct_address
dbx		compiled_struct_word_size
ddx		compiled_struct_source_ptr
ddx		compiled_struct_obj_ptr
dbx		compiled_struct_index_mode
;
;
; Compile constant
; ebx must hold constant
;
compile_constant:

		push	eax
		push	ebx
		push	ecx

		mov	eax,ebx			;check if -1..14
		inc	eax
		cmp	eax,14+1
		ja	@@notimm
		add	al,bc_con_n
		call	enter_obj
		jmp	@@exit
@@notimm:
		cmp	ebx,000000FFh		;check if $000000xx
		ja	@@notb
		mov	al,bc_con_rfbyte
		call	enter_obj
		mov	al,bl
		call	enter_obj
		jmp	@@exit
@@notb:
		cmp	ebx,0FFFFFF00h		;check if $FFFFFFxx
		jb	@@notbn
		mov	al,bc_con_rfbyte_not
		call	enter_obj
		mov	al,bl
		not	al
		call	enter_obj
		jmp	@@exit
@@notbn:
		mov	cl,0			;check if byte exponential
@@exp:		mov	eax,1
		shl	eax,cl
		cmp	eax,ebx			;byte decode?
		mov	ch,bc_con_rfbyte_decod
		je	@@gotexp
		not	eax			;byte decode not?
		cmp	eax,ebx
		mov	ch,bc_con_rfbyte_decod_not
		je	@@gotexp
		not	eax			;byte mask?
		shl	eax,1
		dec	eax
		cmp	eax,ebx
		mov	ch,bc_con_rfbyte_bmask
		je	@@gotexp
		not	eax			;byte mask not?
		cmp	eax,ebx
		mov	ch,bc_con_rfbyte_bmask_not
		je	@@gotexp
		inc	cl
		cmp	cl,20h
		jne	@@exp
		jmp	@@notexp

@@gotexp:	mov	al,ch
		call	enter_obj
		mov	al,cl
		call	enter_obj
		jmp	@@exit
@@notexp:
		cmp	ebx,0000FFFFh		;check if $0000xxxx
		ja	@@notw
		mov	al,bc_con_rfword
		call	enter_obj
		mov	eax,ebx
		call	enter_obj_word
		jmp	@@exit
@@notw:
		cmp	ebx,0FFFF0000h		;check if $FFFFxxxx
		jb	@@notwn
		mov	al,bc_con_rfword_not
		call	enter_obj
		mov	eax,ebx
		not	eax
		call	enter_obj_word
		jmp	@@exit
@@notwn:
		mov	al,bc_con_rflong	;must be $xxxxxxxx
		call	enter_obj
		mov	eax,ebx
		call	enter_obj_long

@@exit:		pop	ecx
		pop	ebx
		pop	eax
		ret
;
;
; Compile index - [exp]
;
compile_index:	call	get_leftb
		call	compile_exp
		jmp	get_rightb
;
;
; Compile branch
; al must hold branch instruction (bc_jmp/bc_jz/bc_jnz/bc_tjz/bc_djnz), ebx must hold address
;
compile_branch:	call	enter_obj		;enter branch instruction

		sub	ebx,[obj_ptr]		;compute relative address

		mov	eax,ebx			;compile relative address
		jmp	compile_rfvars
;
;
; Compile rfvars value in eax
;
compile_rfvars_dat:

		push	eax
		push	ebx
		push	esi

		jmp	compile_rfvs


compile_rfvars:	push	eax
		push	ebx
		push	esi

		lea	esi,[enter_obj]

compile_rfvs:	shl	eax,3			;mask valid bits
		sar	eax,3
		mov	ebx,eax

		mov	ah,7Fh			;1..3-byte

		cmp	ebx,0FFFFFFC0h		;1-byte?
		jae	@@got1
		cmp	ebx,00000003Fh
		jbe	@@got1

		cmp	ebx,0FFFFE000h		;2-byte?
		jae	@@got2
		cmp	ebx,000001FFFh
		jbe	@@got2

		cmp	ebx,0FFF00000h		;3-byte?
		jae	@@got3
		cmp	ebx,0000FFFFFh
		jbe	@@got3

		mov	ah,0FFh			;4-byte

		call	@@byte
@@got3:		call	@@byte
@@got2:		call	@@byte
@@got1:		mov	al,bl
		and	al,ah
		call	esi

		pop	esi
		pop	ebx
		pop	eax
		ret


@@byte:		mov	al,bl			;enter byte
		or	al,80h
		sar	ebx,7
		jmp	esi
;
;
; Compile rfvar value in eax
;
compile_rfvar_dat:

		push	eax
		push	ebx
		push	esi

		jmp	compile_rfv


compile_rfvar:	push	eax
		push	ebx
		push	esi

		lea	esi,[enter_obj]

compile_rfv:	and	eax,1FFFFFFFh		;mask valid bits
		mov	ebx,eax

		call	@@byte
		call	@@byte
		call	@@byte
		mov	al,bl
		jmp	@@last


@@byte:		mov	al,bl
		shr	ebx,7
		jz	@@pop
		or	al,80h
		jmp	esi

@@pop:		pop	ebx
@@last:		call	esi

		pop	esi
		pop	ebx
		pop	eax
		ret
;
;
; Enter data into pub/con list
;
pubcon_symbol2:	push	ecx			;enter symbol2 into pub/con list, al must hold objx_???

		push	eax
		lea	edi,[symbol2]
		call	measure_symbol
		pop	eax

		or	al,cl
		call	pubcon_byte		;enter objx_??? OR length byte

		lea	esi,[symbol2]		;enter symbol2
@@name:		lodsb
		call	pubcon_byte
		loop	@@name

		pop	ecx
		ret


pubcon_byte:	mov	edi,[pubcon_list_size]	;enter byte into pub/con list
		cmp	edi,pubcon_list_limit
		je	error_pclo
		add	edi,offset pubcon_list
		stosb
		inc	[pubcon_list_size]

		ret
;
;
;************************************************************************
;*  Disassembler							*
;************************************************************************
;
flag_tab	=	37

		count0	disop_addr20			;operand symbols
		count	disop_aug
		count	disop_cz
		count	disop_d
		count	disop_dc
		count	disop_dc_modc
		count	disop_dcz
		count	disop_dcz_modcz
		count	disop_ds
		count	disop_ds_alt
		count	disop_ds_alti
		count	disop_ds_branch
		count	disop_ds_byte
		count	disop_ds_nib
		count	disop_ds_ptr
		count	disop_ds_single
		count	disop_ds_word
		count	disop_dsc
		count	disop_dscz
		count	disop_dscz_bit
		count	disop_dscz_bit_log
		count	disop_dscz_branch
		count	disop_dscz_ptr
		count	disop_dscz_single
		count	disop_dsz
		count	disop_dz_modz
		count	disop_l
		count	disop_lc
		count	disop_lcz
		count	disop_lcz_pin
		count	disop_lcz_pin_log
		count	disop_ls
		count	disop_ls_branch
		count	disop_ls_pin
		count	disop_ls_ptr
		count	disop_lsc
		count	disop_lx
		count	disop_none
		count	disop_p_addr20
		count	disop_s
		count	disop_s_branch
		count	disop_s_pin
;
;
; Disassemble instruction
;
_disassemble:	lea	edi,[disassembler_string]	;edi points to string
		mov	edx,[disassembler_inst]		;edx holds instruction
		and	[disassembler_addr],0FFFFFh	;trim address

		mov	eax,edx				;print condition
		or	eax,eax
		mov	al,0Fh				;if NOP, use blank
		jz	@@nop
		shr	eax,32-4
@@nop:		mov	ah,12
		mul	ah
		lea	esi,[da_cond]
		add	esi,eax
		mov	ecx,12
	rep	movsb

		mov	al,' '				;print space
		stosb

		lea	esi,[da_nop]			;if NOP, force NOP record
		or	edx,edx
		jz	@@gotinst

		lea	esi,[da_ins]			;determine instruction record
@@find:		mov	eax,edx
		and	eax,[esi+0]
		cmp	eax,[esi+4]
		je	@@gotinst
		add	esi,16
		jmp	@@find

@@gotinst:	mov	ah,[esi+8]			;got instruction entry, get operand code
		add	esi,9				;print mnemonic
		mov	ecx,7
	rep	movsb

		mov	al,' '				;print space
		stosb

		movzx	eax,ah				;call operand handler
		call	[@@operands+eax*4]

		mov	ecx,flag_tab + 4		;print spaces to end of string
		add	ecx,offset disassembler_string
		sub	ecx,edi
		jbe	@@eos				;if at or beyond end of string, just zero-terminate it
		mov	al,' '
	rep	stosb
@@eos:		mov	edi,offset disassembler_string + flag_tab + 4
		mov	al,0				;zero-terminate string
		stosb

		ret


@@operands	dd	offset do_addr20		;operand handlers
		dd	offset do_aug
		dd	offset do_cz
		dd	offset do_d
		dd	offset do_dc
		dd	offset do_dc_modc
		dd	offset do_dcz
		dd	offset do_dcz_modcz
		dd	offset do_ds
		dd	offset do_ds_alt
		dd	offset do_ds_alti
		dd	offset do_ds_branch
		dd	offset do_ds_byte
		dd	offset do_ds_nib
		dd	offset do_ds_ptr
		dd	offset do_ds_single
		dd	offset do_ds_word
		dd	offset do_dsc
		dd	offset do_dscz
		dd	offset do_dscz_bit
		dd	offset do_dscz_bit_log
		dd	offset do_dscz_branch
		dd	offset do_dscz_ptr
		dd	offset do_dscz_single
		dd	offset do_dsz
		dd	offset do_dz_modz
		dd	offset do_l
		dd	offset do_lc
		dd	offset do_lcz
		dd	offset do_lcz_pin
		dd	offset do_lcz_pin_log
		dd	offset do_ls
		dd	offset do_ls_branch
		dd	offset do_ls_pin
		dd	offset do_ls_ptr
		dd	offset do_lsc
		dd	offset do_lx
		dd	offset do_none
		dd	offset do_p_addr20
		dd	offset do_s
		dd	offset do_s_branch
		dd	offset do_s_pin


do_addr20:	jmp	da_addr20		;addr20

do_aug:		mov	al,'#'			;aug
		stosb
		mov	al,'$'
		stosb
		mov	eax,edx
		shl	eax,1
		mov	cl,6
		call	da_hex
		mov	al,'x'
		stosb
		stosb
		ret

do_cz:		jmp	da_flag			;cz

do_d:		jmp	da_d			;d

do_dc:		call	da_d			;dc
		and	edx,1 shl 20
		jmp	da_flag

do_dc_modc:	mov	eax,edx			;dc_modc
		shr	eax,13-8
		and	ah,0Fh
		call	da_mod
		jmp	da_flag

do_dcz:		call	da_d			;dcz
		jmp	da_flag

do_dcz_modcz:	mov	eax,edx			;dcz_modcz
		shr	eax,13-8
		and	ah,0Fh
		call	da_mod
		mov	al,','
		stosb
		mov	eax,edx
		shr	eax,9-8
		and	ah,0Fh
		call	da_mod
		jmp	da_flag

do_ds:		call	da_d			;ds
		mov	al,','
		stosb
		jmp	da_s

do_ds_alt:	call	da_d			;ds_alt
		mov	eax,edx
		and	eax,1 shl 18 + 1FFh
		cmp	eax,1 shl 18
		jne	@@s
		ret
@@s:		mov	al,','
		stosb
		jmp	da_s

do_ds_alti:	call	da_d			;ds_alti
		mov	eax,edx
		and	eax,1 shl 18 + 1FFh
		cmp	eax,1 shl 18 + 164h
		jne	@@s
		ret
@@s:		mov	al,','
		stosb
		jmp	da_s

do_ds_branch:	call	da_d			;ds_branch
		mov	al,','
		stosb
		jmp	da_s_branch

do_ds_byte:	call	da_d			;ds_byte
		mov	al,','
		stosb
		call	da_s
		mov	al,','
		stosb
		mov	al,'#'
		stosb
		mov	eax,edx
		shr	eax,19
		and	al,3
		or	al,'0'
		stosb
		ret

do_ds_nib:	call	da_d			;ds_nib
		mov	al,','
		stosb
		call	da_s
		mov	al,','
		stosb
		mov	al,'#'
		stosb
		mov	eax,edx
		shr	eax,19
		and	al,7
		or	al,'0'
		stosb
		ret

do_ds_ptr:	call	da_d			;ds_ptr
		mov	al,','
		stosb
		jmp	da_s_ptr

do_ds_single:	call	da_d			;ds_single
		test	edx,1 shl 18
		jnz	@@notsame
		mov	eax,edx
		shr	eax,9
		xor	eax,edx
		and	eax,1FFh
		jnz	@@notsame
		ret
@@notsame:	mov	al,','
		stosb
		jmp	da_s

do_ds_word:	call	da_d			;ds_word
		mov	al,','
		stosb
		call	da_s
		mov	al,','
		stosb
		mov	al,'#'
		stosb
		mov	eax,edx
		shr	eax,19
		and	al,1
		or	al,'0'
		stosb
		ret

do_dsc:		call	da_d			;dsc
		mov	al,','
		stosb
		call	da_s
		and	edx,1 shl 20
		jmp	da_flag

do_dscz:	call	da_d			;dscz
		mov	al,','
		stosb
		call	da_s
		jmp	da_flag

do_dscz_bit:	call	da_d			;dscz_bit
		mov	al,','
		stosb
		call	da_s_bit
		jmp	da_flag

do_dscz_bit_log:call	da_d			;dscz_bit_log
		mov	al,','
		stosb
		call	da_s_bit_log
		mov	eax,edx
		shr	eax,20-8
		and	ah,1101b
		add	ah,0001b
		shr	ah,1
		jmp	da_flag_logic

do_dscz_branch:	call	da_d			;dscz_branch
		mov	al,','
		stosb
		call	da_s_branch
		jmp	da_flag

do_dscz_ptr:	call	da_d			;dscz_ptr
		mov	al,','
		stosb
		call	da_s_ptr
		jmp	da_flag

do_dscz_single:	call	da_d			;dscz_single
		test	edx,1 shl 18
		jnz	@@notsame
		mov	eax,edx
		shr	eax,9
		xor	eax,edx
		and	eax,1FFh
		jz	@@flags
@@notsame:	mov	al,','
		stosb
		call	da_s
@@flags:	jmp	da_flag

do_dsz:		call	da_d			;dsz
		mov	al,','
		stosb
		call	da_s
		and	edx,1 shl 19
		jmp	da_flag

do_dz_modz:	mov	eax,edx			;dz_modz
		shr	eax,9-8
		and	ah,0Fh
		call	da_mod
		jmp	da_flag

do_l:		jmp	da_l			;l

do_lc:		call	da_l			;lc
		and	edx,1 shl 20
		jmp	da_flag

do_lcz:		call	da_l			;lcz
		jmp	da_flag

do_lcz_pin:	call	da_l_pin		;lcz_pin
		jmp	da_flag

do_lcz_pin_log:	call	da_l_pin_log		;lcz_pin_log
		mov	ah,dl
		and	ah,110b
		test	edx,1 shl 20
		jz	@@notc
		or	ah,001b
@@notc:		jmp	da_flag_logic

do_ls:		call	da_ls			;ls
		mov	al,','
		stosb
		jmp	da_s

do_ls_branch:	call	da_ls			;ls_branch
		mov	al,','
		stosb
		jmp	da_s_branch

do_ls_pin:	call	da_ls			;ls_pin
		mov	al,','
		stosb
		jmp	da_s_pin

do_ls_ptr:	call	da_ls			;ls_ptr
		mov	al,','
		stosb
		jmp	da_s_ptr

do_lsc:		call	da_ls			;lsc
		mov	al,','
		stosb
		call	da_s
		and	edx,1 shl 20
		jmp	da_flag

do_lx:		jmp	da_ls			;lx

do_none:	ret				;none

do_p_addr20:	mov	eax,edx			;p_addr20
		shr	eax,21-8
		and	ah,3
		add	ah,6
		call	da_reg
		mov	al,','
		stosb
		jmp	da_addr20

do_s:		jmp	da_s			;s

do_s_branch:	jmp	da_s_branch		;s_branch

do_s_pin:	jmp	da_s_pin		;s_pin
;
;
; Print {#}d
; Print d
;
da_ls:		test	edx,1 shl 19		;ls
		jmp	da_lx

da_l_pin_log:	test	edx,1 shl 18		;l_pin_log
		jz	da_d
		mov	al,'#'			;immediate pin
		stosb
		jmp	da_l_pin2

da_l_pin:	test	edx,1 shl 18		;l_pin
		jz	da_d
		mov	al,'#'			;immediate pin
		stosb
		mov	eax,edx
		shr	eax,9+6
		and	al,07h
		jz	da_l_pin2
		mov	ebx,edx
		shr	ebx,9
		add	al,bl
		and	al,1Fh
		and	bl,20h
		or	al,bl
		call	da_dec
		mov	al,'.'
		stosb
		stosb
da_l_pin2:	mov	eax,edx
		shr	eax,9
		and	al,3Fh
		jmp	da_dec

da_l:		test	edx,1 shl 18		;l
da_lx:		jz	da_d

		mov	al,'#'			;immediate
		stosb
da_lh:		mov	al,'$'
		stosb
		mov	eax,edx
		shr	eax,9
		and	eax,1FFh
		mov	cl,3
		jmp	da_hex

da_d:		mov	eax,edx			;register
		shr	eax,9
		and	eax,1FFh
		cmp	eax,1F0h
		jb	da_lh

		and	al,0Fh			;special register $1Fx
		mov	ah,al
		jmp	da_reg
;
;
; Print (#)s
;
da_s_bit_log:	test	edx,1 shl 18		;s_bit_log
		jz	da_s
		mov	al,'#'			;immediate pin
		stosb
		jmp	da_s_bit2

da_s_bit:	test	edx,1 shl 18		;s_bit
		jz	da_s
		mov	al,'#'			;immediate pin
		stosb
		mov	eax,edx
		shr	eax,5
		and	al,0Fh
		jz	da_s_bit2
		add	al,dl
		and	al,1Fh
		call	da_dec
		mov	al,'.'
		stosb
		stosb
da_s_bit2:	mov	al,dl
		and	al,1Fh
		jmp	da_dec

da_s_pin:	test	edx,1 shl 18		;s_pin
		jz	da_s
		mov	al,'#'			;immediate pin
		stosb
		mov	eax,edx
		shr	eax,6
		and	al,07h
		jz	da_s_pin2
		mov	bl,dl
		add	al,dl
		and	al,1Fh
		and	bl,20h
		or	al,bl
		call	da_dec
		mov	al,'.'
		stosb
		stosb
da_s_pin2:	mov	al,dl
		and	al,3Fh
		jmp	da_dec

da_s:		test	edx,1 shl 18		;immediate?
		jz	da_sr

		mov	al,'#'			;immediate
		stosb
da_sh:		mov	al,'$'
		stosb
		mov	eax,edx
		and	eax,1FFh
		mov	cl,3
		jmp	da_hex

da_sr:		mov	eax,edx			;register
		and	eax,1FFh
		cmp	eax,1F0h
		jb	da_sh

		and	al,0Fh			;special register $1Fx
		mov	ah,al
		jmp	da_reg
;
;
; Print s branch
;
da_s_branch:	test	edx,1 shl 18
		jz	da_sr

		mov	al,'#'
		stosb

		mov	eax,edx
		shl	eax,32-9
		sar	eax,32-9

		mov	ebx,[disassembler_addr]
		and	ebx,0FFFFFh
		cmp	ebx,400h
		jae	@@hub

		add	eax,ebx
		add	eax,1
		and	eax,3FFh
		mov	cl,3
		jmp	da_hex

@@hub:		shl	eax,2
		add	eax,ebx
		add	eax,4
		and	eax,0FFFFFh
		mov	cl,5
		jmp	da_hex
;
;
; Print s ptr
;
da_s_ptr:	test	edx,1 shl 18		;register or immediate?
		jz	da_sr

		test	edx,100h		;immediate ptr?
		jnz	@@ptr

		mov	al,'#'			;8-bit address
		stosb
		mov	al,'$'
		stosb
		mov	al,dl
		mov	cl,2
		jmp	da_hex


@@ptr:		test	dl,40h			;non-updating PTRx?
		jnz	@@updt

		call	@@ptrx

		test	dl,3Fh			;non-0 index?
		jz	@@exit

		mov	al,'['
		stosb
		test	dl,20h
		jz	@@pos
		mov	al,'-'
		stosb
@@pos:		mov	al,dl
		test	al,20h
		jz	@@pos2
		neg	al
@@pos2:		and	al,3Fh
		call	da_dec
		mov	al,']'
		stosb
@@exit:		ret


@@updt:		test	dl,20h			;pre-update or post-update?
		jnz	@@post
		call	@@incdec
@@post:		call	@@ptrx
		test	dl,20h
		jz	@@pre
		call	@@incdec
@@pre:
		mov	al,dl			;non-1 index?
		and	al,1Fh
		cmp	al,01h
		je	@@exit
		cmp	al,1Fh
		je	@@exit

		mov	al,'['
		stosb
		mov	ah,dl
		neg	ah
		test	dl,10h
		jnz	@@abs
		neg	ah
		test	dl,0Fh
		jnz	@@abs
		mov	ah,10h
@@abs:		mov	al,ah
		and	al,1Fh
		call	da_dec
		mov	al,']'
		stosb
		ret


@@ptrx:		mov	al,'p'
		stosb
		mov	al,'t'
		stosb
		mov	al,'r'
		stosb
		mov	al,'a'
		test	dl,80h
		jz	@@ptra
		mov	al,'b'
@@ptra:		stosb
		ret

@@incdec:	mov	al,'+'
		test	dl,10h
		jz	@@incdecpos
		mov	al,'-'
@@incdecpos:	stosb
		stosb
		ret
;
;
; Print flag
;
da_flag:	call	da_flag_tab	;tab to flag position

		mov	eax,edx		;isolate flag bits
		shr	eax,19
		and	eax,3
		shl	eax,2		;multiply by four and point to flag string
		lea	esi,[@@flag]
		add	esi,eax
		mov	ecx,4		;print flag string
	rep	movsb

		ret


@@flag	db	'    '			;flag effects (4 bytes each)
	db	'wz  '
	db	'wc  '
	db	'wcz '
;
;
; Print flag logic
; ah = logic
;
da_flag_logic:	call	da_flag_tab	;tab to flag position

		movzx	eax,ah		;get index
		shl	eax,2		;multiply by four and point to flag string
		lea	esi,[@@flag]
		add	esi,eax
		mov	ecx,4		;print flag string
	rep	movsb

		ret


@@flag	db	'wz  '			;flag effects (4 bytes each)
	db	'wc  '
	db	'andz'
	db	'andc'
	db	'orz '
	db	'orc '
	db	'xorz'
	db	'xorc'
;
;
; Tab to cl
;
da_flag_tab:	mov	ecx,flag_tab	;need to print more spaces?
		add	ecx,offset disassembler_string	;print spaces to end of string
		sub	ecx,edi
		ja	@@tab

		add	edi,ecx		;back up and print space
		dec	edi
		mov	ecx,1

@@tab:		mov	al,' '
	rep	stosb

		ret
;
;
; Print 20-bit address
;
da_addr20:	mov	al,'#'		;print '#'
		stosb

		mov	eax,[disassembler_addr]

		test	edx,100000h	;relative or absolute?
		jz	@@abs

		cmp	eax,400h	;relative cog or hub?
		jae	@@relhub

		shl	edx,31-19	;relative cog
		sar	edx,31-19+2
		add	eax,edx
		inc	eax
		jmp	da_addr

@@relhub:	add	eax,edx		;relative hub
		add	eax,4
		jmp	da_addr

@@abs:		mov	al,'\'		;absolute
		stosb
		mov	eax,edx
		jmp	da_addr
;
;
; Print address
;
da_addr:	mov	[byte edi],'$'	;print '$'
		inc	edi

		and	eax,0FFFFFh	;mask address

		cmp	eax,400h	;10-bit or 20-bit address?

		mov	cl,3
		jb	da_hex

		mov	cl,5
		jmp	da_hex
;
;
; Print hex value
; eax = value
; cl = digits
;
da_hex:		movzx	ecx,cl		;clear upper ecx

		shl	cl,2		;get first nibble into position
		ror	eax,cl
		shr	cl,2

@@digit:	rol	eax,4		;print hex digits
		push	eax
		and	al,0Fh		;convert nibble in al to hex
		add	al,'0'
		cmp	al,'9'
		jbe	@@got
		add	al,'A'-'9'-1
@@got:		stosb
		pop	eax
		loop	@@digit

		ret
;
;
; Print decimal value
; al = value
;
da_dec:		mov	ah,-1
@@tens:		inc	ah
		sub	al,10
		jnc	@@tens

		cmp	ah,0
		je	@@ones
		add	ah,'0'
		mov	[edi],ah
		inc	edi
@@ones:
		add	al,'0'+10
		stosb
		ret
;
;
; Print MODCZ/register operand
; ah = nibble
;
da_mod:		lea	esi,[da_mods]	;point to MODCZ operands
		jmp	da_opstr

da_reg:		lea	esi,[da_regs]	;point to IJMP3..INB operands


da_opstr:	cmp	ah,0		;at operand yet?
		je	@@got

@@skip:		lodsb			;nope, skip past current
		cmp	al,0
		jne	@@skip
		dec	ah
		jmp	da_opstr	;check if at operand

@@got:		lodsb			;got operand, check if done
		cmp	al,0
		je	@@done
		stosb			;print chr
		jmp	@@got		;loop

@@done:		ret
;
;
; Data
;
da_mods	db	'_clr',0		;MODCZ operands
	db	'_nc_and_nz',0
	db	'_nc_and_z',0
	db	'_nc',0
	db	'_c_and_nz',0
	db	'_nz',0
	db	'_c_ne_z',0
	db	'_nc_or_nz',0
	db	'_c_and_z',0
	db	'_c_eq_z',0
	db	'_z',0
	db	'_nc_or_z',0
	db	'_c',0
	db	'_c_or_nz',0
	db	'_c_or_z',0
	db	'_set',0

da_regs	db	'ijmp3',0		;IJMP3..INB operands
	db	'iret3',0
	db	'ijmp2',0
	db	'iret2',0
	db	'ijmp1',0
	db	'iret1',0
	db	'pa',0
	db	'pb',0
	db	'ptra',0
	db	'ptrb',0
	db	'dira',0
	db	'dirb',0
	db	'outa',0
	db	'outb',0
	db	'ina',0
	db	'inb',0

da_cond	db	'_ret_       '		;conditions (12 bytes each)
	db	'if_nc_and_nz'
	db	'if_nc_and_z '
	db	'if_nc       '
	db	'if_c_and_nz '
	db	'if_nz       '
	db	'if_c_ne_z   '
	db	'if_nc_or_nz '
	db	'if_c_and_z  '
	db	'if_c_eq_z   '
	db	'if_z        '
	db	'if_nc_or_z  '
	db	'if_c        '
	db	'if_c_or_nz  '
	db	'if_c_or_z   '
	db	'            '

macro	disasm	mnem,im,dm,sm,iv,dv,sv,disop	;macro for disassembler table entries
	dd	(im shl 18) + (dm shl 9) + sm
	dd	(iv shl 18) + (dv shl 9) + sv
	db	disop
	db	mnem
	endm

da_ins:	disasm	'ror    ',	3F8h, 000h, 000h,	000h, 000h, 000h,	disop_dscz
	disasm	'rol    ',	3F8h, 000h, 000h,	008h, 000h, 000h,	disop_dscz
	disasm	'shr    ',	3F8h, 000h, 000h,	010h, 000h, 000h,	disop_dscz
	disasm	'shl    ',	3F8h, 000h, 000h,	018h, 000h, 000h,	disop_dscz
	disasm	'rcr    ',	3F8h, 000h, 000h,	020h, 000h, 000h,	disop_dscz
	disasm	'rcl    ',	3F8h, 000h, 000h,	028h, 000h, 000h,	disop_dscz
	disasm	'sar    ',	3F8h, 000h, 000h,	030h, 000h, 000h,	disop_dscz
	disasm	'sal    ',	3F8h, 000h, 000h,	038h, 000h, 000h,	disop_dscz
	disasm	'add    ',	3F8h, 000h, 000h,	040h, 000h, 000h,	disop_dscz
	disasm	'addx   ',	3F8h, 000h, 000h,	048h, 000h, 000h,	disop_dscz
	disasm	'adds   ',	3F8h, 000h, 000h,	050h, 000h, 000h,	disop_dscz
	disasm	'addsx  ',	3F8h, 000h, 000h,	058h, 000h, 000h,	disop_dscz
	disasm	'sub    ',	3F8h, 000h, 000h,	060h, 000h, 000h,	disop_dscz
	disasm	'subx   ',	3F8h, 000h, 000h,	068h, 000h, 000h,	disop_dscz
	disasm	'subs   ',	3F8h, 000h, 000h,	070h, 000h, 000h,	disop_dscz
	disasm	'subsx  ',	3F8h, 000h, 000h,	078h, 000h, 000h,	disop_dscz
	disasm	'cmp    ',	3F8h, 000h, 000h,	080h, 000h, 000h,	disop_dscz
	disasm	'cmpx   ',	3F8h, 000h, 000h,	088h, 000h, 000h,	disop_dscz
	disasm	'cmps   ',	3F8h, 000h, 000h,	090h, 000h, 000h,	disop_dscz
	disasm	'cmpsx  ',	3F8h, 000h, 000h,	098h, 000h, 000h,	disop_dscz
	disasm	'cmpr   ',	3F8h, 000h, 000h,	0A0h, 000h, 000h,	disop_dscz
	disasm	'cmpm   ',	3F8h, 000h, 000h,	0A8h, 000h, 000h,	disop_dscz
	disasm	'subr   ',	3F8h, 000h, 000h,	0B0h, 000h, 000h,	disop_dscz
	disasm	'cmpsub ',	3F8h, 000h, 000h,	0B8h, 000h, 000h,	disop_dscz
	disasm	'fge    ',	3F8h, 000h, 000h,	0C0h, 000h, 000h,	disop_dscz
	disasm	'fle    ',	3F8h, 000h, 000h,	0C8h, 000h, 000h,	disop_dscz
	disasm	'fges   ',	3F8h, 000h, 000h,	0D0h, 000h, 000h,	disop_dscz
	disasm	'fles   ',	3F8h, 000h, 000h,	0D8h, 000h, 000h,	disop_dscz
	disasm	'sumc   ',	3F8h, 000h, 000h,	0E0h, 000h, 000h,	disop_dscz
	disasm	'sumnc  ',	3F8h, 000h, 000h,	0E8h, 000h, 000h,	disop_dscz
	disasm	'sumz   ',	3F8h, 000h, 000h,	0F0h, 000h, 000h,	disop_dscz
	disasm	'sumnz  ',	3F8h, 000h, 000h,	0F8h, 000h, 000h,	disop_dscz

	disasm	'testb  ',	3CEh, 000h, 000h,	102h, 000h, 000h,	disop_dscz_bit_log
	disasm	'testb  ',	3CEh, 000h, 000h,	104h, 000h, 000h,	disop_dscz_bit_log
	disasm	'testbn ',	3CEh, 000h, 000h,	10Ah, 000h, 000h,	disop_dscz_bit_log
	disasm	'testbn ',	3CEh, 000h, 000h,	10Ch, 000h, 000h,	disop_dscz_bit_log

	disasm	'bitl   ',	3F8h, 000h, 000h,	100h, 000h, 000h,	disop_dscz_bit
	disasm	'bith   ',	3F8h, 000h, 000h,	108h, 000h, 000h,	disop_dscz_bit
	disasm	'bitc   ',	3F8h, 000h, 000h,	110h, 000h, 000h,	disop_dscz_bit
	disasm	'bitnc  ',	3F8h, 000h, 000h,	118h, 000h, 000h,	disop_dscz_bit
	disasm	'bitz   ',	3F8h, 000h, 000h,	120h, 000h, 000h,	disop_dscz_bit
	disasm	'bitnz  ',	3F8h, 000h, 000h,	128h, 000h, 000h,	disop_dscz_bit
	disasm	'bitrnd ',	3F8h, 000h, 000h,	130h, 000h, 000h,	disop_dscz_bit
	disasm	'bitnot ',	3F8h, 000h, 000h,	138h, 000h, 000h,	disop_dscz_bit

	disasm	'and    ',	3F8h, 000h, 000h,	140h, 000h, 000h,	disop_dscz
	disasm	'andn   ',	3F8h, 000h, 000h,	148h, 000h, 000h,	disop_dscz
	disasm	'or     ',	3F8h, 000h, 000h,	150h, 000h, 000h,	disop_dscz
	disasm	'xor    ',	3F8h, 000h, 000h,	158h, 000h, 000h,	disop_dscz
	disasm	'muxc   ',	3F8h, 000h, 000h,	160h, 000h, 000h,	disop_dscz
	disasm	'muxnc  ',	3F8h, 000h, 000h,	168h, 000h, 000h,	disop_dscz
	disasm	'muxz   ',	3F8h, 000h, 000h,	170h, 000h, 000h,	disop_dscz
	disasm	'muxnz  ',	3F8h, 000h, 000h,	178h, 000h, 000h,	disop_dscz

	disasm	'mov    ',	3F8h, 000h, 000h,	180h, 000h, 000h,	disop_dscz
	disasm	'not    ',	3F8h, 000h, 000h,	188h, 000h, 000h,	disop_dscz_single
	disasm	'abs    ',	3F8h, 000h, 000h,	190h, 000h, 000h,	disop_dscz_single
	disasm	'neg    ',	3F8h, 000h, 000h,	198h, 000h, 000h,	disop_dscz_single
	disasm	'negc   ',	3F8h, 000h, 000h,	1A0h, 000h, 000h,	disop_dscz_single
	disasm	'negnc  ',	3F8h, 000h, 000h,	1A8h, 000h, 000h,	disop_dscz_single
	disasm	'negz   ',	3F8h, 000h, 000h,	1B0h, 000h, 000h,	disop_dscz_single
	disasm	'negnz  ',	3F8h, 000h, 000h,	1B8h, 000h, 000h,	disop_dscz_single

	disasm	'incmod ',	3F8h, 000h, 000h,	1C0h, 000h, 000h,	disop_dscz
	disasm	'decmod ',	3F8h, 000h, 000h,	1C8h, 000h, 000h,	disop_dscz
	disasm	'zerox  ',	3F8h, 000h, 000h,	1D0h, 000h, 000h,	disop_dscz
	disasm	'signx  ',	3F8h, 000h, 000h,	1D8h, 000h, 000h,	disop_dscz
	disasm	'encod  ',	3F8h, 000h, 000h,	1E0h, 000h, 000h,	disop_dscz_single
	disasm	'ones   ',	3F8h, 000h, 000h,	1E8h, 000h, 000h,	disop_dscz_single
	disasm	'test   ',	3F8h, 000h, 000h,	1F0h, 000h, 000h,	disop_dscz_single
	disasm	'testn  ',	3F8h, 000h, 000h,	1F8h, 000h, 000h,	disop_dscz

	disasm	'setnib ',	3F0h, 000h, 000h,	200h, 000h, 000h,	disop_ds_nib
	disasm	'getnib ',	3F0h, 000h, 000h,	210h, 000h, 000h,	disop_ds_nib
	disasm	'rolnib ',	3F0h, 000h, 000h,	220h, 000h, 000h,	disop_ds_nib

	disasm	'setbyte',	3F8h, 000h, 000h,	230h, 000h, 000h,	disop_ds_byte
	disasm	'getbyte',	3F8h, 000h, 000h,	238h, 000h, 000h,	disop_ds_byte
	disasm	'rolbyte',	3F8h, 000h, 000h,	240h, 000h, 000h,	disop_ds_byte

	disasm	'setword',	3FCh, 000h, 000h,	248h, 000h, 000h,	disop_ds_word
	disasm	'getword',	3FCh, 000h, 000h,	24Ch, 000h, 000h,	disop_ds_word
	disasm	'rolword',	3FCh, 000h, 000h,	250h, 000h, 000h,	disop_ds_word

	disasm	'altsn  ',	3FEh, 000h, 000h,	254h, 000h, 000h,	disop_ds_alt
	disasm	'altgn  ',	3FEh, 000h, 000h,	256h, 000h, 000h,	disop_ds_alt
	disasm	'altsb  ',	3FEh, 000h, 000h,	258h, 000h, 000h,	disop_ds_alt
	disasm	'altgb  ',	3FEh, 000h, 000h,	25Ah, 000h, 000h,	disop_ds_alt
	disasm	'altsw  ',	3FEh, 000h, 000h,	25Ch, 000h, 000h,	disop_ds_alt
	disasm	'altgw  ',	3FEh, 000h, 000h,	25Eh, 000h, 000h,	disop_ds_alt
	disasm	'altr   ',	3FEh, 000h, 000h,	260h, 000h, 000h,	disop_ds_alt
	disasm	'altd   ',	3FEh, 000h, 000h,	262h, 000h, 000h,	disop_ds_alt
	disasm	'alts   ',	3FEh, 000h, 000h,	264h, 000h, 000h,	disop_ds_alt
	disasm	'altb   ',	3FEh, 000h, 000h,	266h, 000h, 000h,	disop_ds_alt
	disasm	'alti   ',	3FEh, 000h, 000h,	268h, 000h, 000h,	disop_ds_alti
	disasm	'setr   ',	3FEh, 000h, 000h,	26Ah, 000h, 000h,	disop_ds
	disasm	'setd   ',	3FEh, 000h, 000h,	26Ch, 000h, 000h,	disop_ds
	disasm	'sets   ',	3FEh, 000h, 000h,	26Eh, 000h, 000h,	disop_ds
	disasm	'decod  ',	3FEh, 000h, 000h,	270h, 000h, 000h,	disop_ds_single
	disasm	'bmask  ',	3FEh, 000h, 000h,	272h, 000h, 000h,	disop_ds_single
	disasm	'crcbit ',	3FEh, 000h, 000h,	274h, 000h, 000h,	disop_ds
	disasm	'crcnib ',	3FEh, 000h, 000h,	276h, 000h, 000h,	disop_ds
	disasm	'muxnits',	3FEh, 000h, 000h,	278h, 000h, 000h,	disop_ds
	disasm	'muxnibs',	3FEh, 000h, 000h,	27Ah, 000h, 000h,	disop_ds
	disasm	'muxq   ',	3FEh, 000h, 000h,	27Ch, 000h, 000h,	disop_ds
	disasm	'movbyts',	3FEh, 000h, 000h,	27Eh, 000h, 000h,	disop_ds

	disasm	'mul    ',	3FCh, 000h, 000h,	280h, 000h, 000h,	disop_dsz
	disasm	'muls   ',	3FCh, 000h, 000h,	284h, 000h, 000h,	disop_dsz
	disasm	'sca    ',	3FCh, 000h, 000h,	288h, 000h, 000h,	disop_dsz
	disasm	'scas   ',	3FCh, 000h, 000h,	28Ch, 000h, 000h,	disop_dsz

	disasm	'addpix ',	3FEh, 000h, 000h,	290h, 000h, 000h,	disop_ds
	disasm	'mulpix ',	3FEh, 000h, 000h,	292h, 000h, 000h,	disop_ds
	disasm	'blnpix ',	3FEh, 000h, 000h,	294h, 000h, 000h,	disop_ds
	disasm	'mixpix ',	3FEh, 000h, 000h,	296h, 000h, 000h,	disop_ds
	disasm	'addct1 ',	3FEh, 000h, 000h,	298h, 000h, 000h,	disop_ds
	disasm	'addct2 ',	3FEh, 000h, 000h,	29Ah, 000h, 000h,	disop_ds
	disasm	'addct3 ',	3FEh, 000h, 000h,	29Ch, 000h, 000h,	disop_ds
	disasm	'wmlong ',	3FEh, 000h, 000h,	29Eh, 000h, 000h,	disop_ds_ptr
	disasm	'rqpin  ',	3FAh, 000h, 000h,	2A0h, 000h, 000h,	disop_dsc
	disasm	'rdpin  ',	3FAh, 000h, 000h,	2A2h, 000h, 000h,	disop_dsc
	disasm	'rdlut  ',	3F8h, 000h, 000h,	2A8h, 000h, 000h,	disop_dscz_ptr
	disasm	'rdbyte ',	3F8h, 000h, 000h,	2B0h, 000h, 000h,	disop_dscz_ptr
	disasm	'rdword ',	3F8h, 000h, 000h,	2B8h, 000h, 000h,	disop_dscz_ptr
	disasm	'popa   ',	3F9h, 000h, 1FFh,	2C1h, 000h, 15Fh,	disop_dcz
	disasm	'popb   ',	3F9h, 000h, 1FFh,	2C1h, 000h, 1Dfh,	disop_dcz
	disasm	'rdlong ',	3F8h, 000h, 000h,	2C0h, 000h, 000h,	disop_dscz_ptr

	disasm	'resi3  ',	3FFh, 1FFh, 1FFh,	2CEh, 1F0h, 1F1h,	disop_none
	disasm	'resi2  ',	3FFh, 1FFh, 1FFh,	2CEh, 1F2h, 1F3h,	disop_none
	disasm	'resi1  ',	3FFh, 1FFh, 1FFh,	2CEh, 1F4h, 1F5h,	disop_none
	disasm	'resi0  ',	3FFh, 1FFh, 1FFh,	2CEh, 1FEh, 1FFh,	disop_none
	disasm	'reti3  ',	3FFh, 1FFh, 1FFh,	2CEh, 1FFh, 1F1h,	disop_none
	disasm	'reti2  ',	3FFh, 1FFh, 1FFh,	2CEh, 1FFh, 1F3h,	disop_none
	disasm	'reti1  ',	3FFh, 1FFh, 1FFh,	2CEh, 1FFh, 1F5h,	disop_none
	disasm	'reti0  ',	3FFh, 1FFh, 1FFh,	2CEh, 1FFh, 1FFh,	disop_none
	disasm	'calld  ',	3F8h, 000h, 000h,	2C8h, 000h, 000h,	disop_dscz_branch

	disasm	'callpa ',	3FCh, 000h, 000h,	2D0h, 000h, 000h,	disop_ls_branch
	disasm	'callpb ',	3FCh, 000h, 000h,	2D4h, 000h, 000h,	disop_ls_branch
	disasm	'djz    ',	3FEh, 000h, 000h,	2D8h, 000h, 000h,	disop_ds_branch
	disasm	'djnz   ',	3FEh, 000h, 000h,	2DAh, 000h, 000h,	disop_ds_branch
	disasm	'djf    ',	3FEh, 000h, 000h,	2DCh, 000h, 000h,	disop_ds_branch
	disasm	'djnf   ',	3FEh, 000h, 000h,	2DEh, 000h, 000h,	disop_ds_branch
	disasm	'ijz    ',	3FEh, 000h, 000h,	2E0h, 000h, 000h,	disop_ds_branch
	disasm	'ijnz   ',	3FEh, 000h, 000h,	2E2h, 000h, 000h,	disop_ds_branch
	disasm	'tjz    ',	3FEh, 000h, 000h,	2E4h, 000h, 000h,	disop_ds_branch
	disasm	'tjnz   ',	3FEh, 000h, 000h,	2E6h, 000h, 000h,	disop_ds_branch
	disasm	'tjf    ',	3FEh, 000h, 000h,	2E8h, 000h, 000h,	disop_ds_branch
	disasm	'tjnf   ',	3FEh, 000h, 000h,	2EAh, 000h, 000h,	disop_ds_branch
	disasm	'tjs    ',	3FEh, 000h, 000h,	2ECh, 000h, 000h,	disop_ds_branch
	disasm	'tjns   ',	3FEh, 000h, 000h,	2EEh, 000h, 000h,	disop_ds_branch
	disasm	'tjv    ',	3FEh, 000h, 000h,	2F0h, 000h, 000h,	disop_ds_branch

	disasm	'jint   ',	3FEh, 1FFh, 000h,	2F2h, 000h, 000h,	disop_s_branch
	disasm	'jct1   ',	3FEh, 1FFh, 000h,	2F2h, 001h, 000h,	disop_s_branch
	disasm	'jct2   ',	3FEh, 1FFh, 000h,	2F2h, 002h, 000h,	disop_s_branch
	disasm	'jct3   ',	3FEh, 1FFh, 000h,	2F2h, 003h, 000h,	disop_s_branch
	disasm	'jse1   ',	3FEh, 1FFh, 000h,	2F2h, 004h, 000h,	disop_s_branch
	disasm	'jse2   ',	3FEh, 1FFh, 000h,	2F2h, 005h, 000h,	disop_s_branch
	disasm	'jse3   ',	3FEh, 1FFh, 000h,	2F2h, 006h, 000h,	disop_s_branch
	disasm	'jse4   ',	3FEh, 1FFh, 000h,	2F2h, 007h, 000h,	disop_s_branch
	disasm	'jpat   ',	3FEh, 1FFh, 000h,	2F2h, 008h, 000h,	disop_s_branch
	disasm	'jfbw   ',	3FEh, 1FFh, 000h,	2F2h, 009h, 000h,	disop_s_branch
	disasm	'jxmt   ',	3FEh, 1FFh, 000h,	2F2h, 00Ah, 000h,	disop_s_branch
	disasm	'jxfi   ',	3FEh, 1FFh, 000h,	2F2h, 00Bh, 000h,	disop_s_branch
	disasm	'jxro   ',	3FEh, 1FFh, 000h,	2F2h, 00Ch, 000h,	disop_s_branch
	disasm	'jxrl   ',	3FEh, 1FFh, 000h,	2F2h, 00Dh, 000h,	disop_s_branch
	disasm	'jatn   ',	3FEh, 1FFh, 000h,	2F2h, 00Eh, 000h,	disop_s_branch
	disasm	'jqmt   ',	3FEh, 1FFh, 000h,	2F2h, 00Fh, 000h,	disop_s_branch
	disasm	'jnint  ',	3FEh, 1FFh, 000h,	2F2h, 010h, 000h,	disop_s_branch
	disasm	'jnct1  ',	3FEh, 1FFh, 000h,	2F2h, 011h, 000h,	disop_s_branch
	disasm	'jnct2  ',	3FEh, 1FFh, 000h,	2F2h, 012h, 000h,	disop_s_branch
	disasm	'jnct3  ',	3FEh, 1FFh, 000h,	2F2h, 013h, 000h,	disop_s_branch
	disasm	'jnse1  ',	3FEh, 1FFh, 000h,	2F2h, 014h, 000h,	disop_s_branch
	disasm	'jnse2  ',	3FEh, 1FFh, 000h,	2F2h, 015h, 000h,	disop_s_branch
	disasm	'jnse3  ',	3FEh, 1FFh, 000h,	2F2h, 016h, 000h,	disop_s_branch
	disasm	'jnse4  ',	3FEh, 1FFh, 000h,	2F2h, 017h, 000h,	disop_s_branch
	disasm	'jnpat  ',	3FEh, 1FFh, 000h,	2F2h, 018h, 000h,	disop_s_branch
	disasm	'jnfbw  ',	3FEh, 1FFh, 000h,	2F2h, 019h, 000h,	disop_s_branch
	disasm	'jnxmt  ',	3FEh, 1FFh, 000h,	2F2h, 01Ah, 000h,	disop_s_branch
	disasm	'jnxfi  ',	3FEh, 1FFh, 000h,	2F2h, 01Bh, 000h,	disop_s_branch
	disasm	'jnxro  ',	3FEh, 1FFh, 000h,	2F2h, 01Ch, 000h,	disop_s_branch
	disasm	'jnxrl  ',	3FEh, 1FFh, 000h,	2F2h, 01Dh, 000h,	disop_s_branch
	disasm	'jnatn  ',	3FEh, 1FFh, 000h,	2F2h, 01Eh, 000h,	disop_s_branch
	disasm	'jnqmt  ',	3FEh, 1FFh, 000h,	2F2h, 01Fh, 000h,	disop_s_branch

	disasm	'setpat ',	3FCh, 000h, 000h,	2FCh, 000h, 000h,	disop_ls
	disasm	'wrpin  ',	3FCh, 000h, 000h,	300h, 000h, 000h,	disop_ls_pin
	disasm	'akpin  ',	3FEh, 1FFh, 000h,	302h, 001h, 000h,	disop_s_pin
	disasm	'wxpin  ',	3FCh, 000h, 000h,	304h, 000h, 000h,	disop_ls_pin
	disasm	'wypin  ',	3FCh, 000h, 000h,	308h, 000h, 000h,	disop_ls_pin
	disasm	'wrlut  ',	3FCh, 000h, 000h,	30Ch, 000h, 000h,	disop_ls_ptr
	disasm	'wrbyte ',	3FCh, 000h, 000h,	310h, 000h, 000h,	disop_ls_ptr
	disasm	'wrword ',	3FCh, 000h, 000h,	314h, 000h, 000h,	disop_ls_ptr
	disasm	'pusha  ',	3FDh, 000h, 1FFh,	319h, 000h, 161h,	disop_lx
	disasm	'pushb  ',	3FDh, 000h, 1FFh,	319h, 000h, 1E1h,	disop_lx
	disasm	'wrlong ',	3FCh, 000h, 000h,	318h, 000h, 000h,	disop_ls_ptr
	disasm	'rdfast ',	3FCh, 000h, 000h,	31Ch, 000h, 000h,	disop_ls
	disasm	'wrfast ',	3FCh, 000h, 000h,	320h, 000h, 000h,	disop_ls
	disasm	'fblock ',	3FCh, 000h, 000h,	324h, 000h, 000h,	disop_ls
	disasm	'xinit  ',	3FCh, 000h, 000h,	328h, 000h, 000h,	disop_ls
	disasm	'xstop  ',	3FFh, 1FFh, 1FFh,	32Bh, 000h, 000h,	disop_none
	disasm	'xzero  ',	3FCh, 000h, 000h,	32Ch, 000h, 000h,	disop_ls
	disasm	'xcont  ',	3FCh, 000h, 000h,	330h, 000h, 000h,	disop_ls
	disasm	'rep    ',	3FCh, 000h, 000h,	334h, 000h, 000h,	disop_ls
	disasm	'coginit',	3F8h, 000h, 000h,	338h, 000h, 000h,	disop_lsc
	disasm	'qmul   ',	3FCh, 000h, 000h,	340h, 000h, 000h,	disop_ls
	disasm	'qdiv   ',	3FCh, 000h, 000h,	344h, 000h, 000h,	disop_ls
	disasm	'qfrac  ',	3FCh, 000h, 000h,	348h, 000h, 000h,	disop_ls
	disasm	'qsqrt  ',	3FCh, 000h, 000h,	34Ch, 000h, 000h,	disop_ls
	disasm	'qrotate',	3FCh, 000h, 000h,	350h, 000h, 000h,	disop_ls
	disasm	'qvector',	3FCh, 000h, 000h,	354h, 000h, 000h,	disop_ls

	disasm	'hubset ',	3FEh, 000h, 1FFh,	358h, 000h, 000h,	disop_l
	disasm	'cogid  ',	3FAh, 000h, 1FFh,	358h, 000h, 001h,	disop_lc
	disasm	'cogstop',	3FEh, 000h, 1FFh,	358h, 000h, 003h,	disop_l
	disasm	'locknew',	3FBh, 000h, 1FFh,	358h, 000h, 004h,	disop_dc
	disasm	'lockret',	3FEh, 000h, 1FFh,	358h, 000h, 005h,	disop_l
	disasm	'locktry',	3FAh, 000h, 1FFh,	358h, 000h, 006h,	disop_lc
	disasm	'lockrel',	3FAh, 000h, 1FFh,	358h, 000h, 007h,	disop_lc
	disasm	'qlog   ',	3FEh, 000h, 1FFh,	358h, 000h, 00Eh,	disop_l
	disasm	'qexp   ',	3FEh, 000h, 1FFh,	358h, 000h, 00Fh,	disop_l
	disasm	'rfbyte ',	3F9h, 000h, 1FFh,	358h, 000h, 010h,	disop_dcz
	disasm	'rfword ',	3F9h, 000h, 1FFh,	358h, 000h, 011h,	disop_dcz
	disasm	'rflong ',	3F9h, 000h, 1FFh,	358h, 000h, 012h,	disop_dcz
	disasm	'rfvar  ',	3F9h, 000h, 1FFh,	358h, 000h, 013h,	disop_dcz
	disasm	'rfvars ',	3F9h, 000h, 1FFh,	358h, 000h, 014h,	disop_dcz

	disasm	'wfbyte ',	3FEh, 000h, 1FFh,	358h, 000h, 015h,	disop_l
	disasm	'wfword ',	3FEh, 000h, 1FFh,	358h, 000h, 016h,	disop_l
	disasm	'wflong ',	3FEh, 000h, 1FFh,	358h, 000h, 017h,	disop_l
	disasm	'getqx  ',	3F9h, 000h, 1FFh,	358h, 000h, 018h,	disop_dcz
	disasm	'getqy  ',	3F9h, 000h, 1FFh,	358h, 000h, 019h,	disop_dcz
	disasm	'getct  ',	3FBh, 000h, 1FFh,	358h, 000h, 01Ah,	disop_dc
	disasm	'getrnd ',	3F9h, 000h, 1FFh,	358h, 000h, 01Bh,	disop_dcz
	disasm	'getrnd ',	3F9h, 1FFh, 1FFh,	359h, 000h, 01Bh,	disop_cz
	disasm	'setdacs',	3FEh, 000h, 1FFh,	358h, 000h, 01Ch,	disop_l
	disasm	'setxfrq',	3FEh, 000h, 1FFh,	358h, 000h, 01Dh,	disop_l
	disasm	'getxacc',	3FFh, 000h, 1FFh,	358h, 000h, 01Eh,	disop_d
	disasm	'waitx  ',	3F8h, 000h, 1FFh,	358h, 000h, 01Fh,	disop_lcz
	disasm	'setse1 ',	3FEh, 000h, 1FFh,	358h, 000h, 020h,	disop_l
	disasm	'setse2 ',	3FEh, 000h, 1FFh,	358h, 000h, 021h,	disop_l
	disasm	'setse3 ',	3FEh, 000h, 1FFh,	358h, 000h, 022h,	disop_l
	disasm	'setse4 ',	3FEh, 000h, 1FFh,	358h, 000h, 023h,	disop_l

	disasm	'pollint',	3F9h, 1FFh, 1FFh,	358h, 000h, 024h,	disop_cz
	disasm	'pollct1',	3F9h, 1FFh, 1FFh,	358h, 001h, 024h,	disop_cz
	disasm	'pollct2',	3F9h, 1FFh, 1FFh,	358h, 002h, 024h,	disop_cz
	disasm	'pollct3',	3F9h, 1FFh, 1FFh,	358h, 003h, 024h,	disop_cz
	disasm	'pollse1',	3F9h, 1FFh, 1FFh,	358h, 004h, 024h,	disop_cz
	disasm	'pollse2',	3F9h, 1FFh, 1FFh,	358h, 005h, 024h,	disop_cz
	disasm	'pollse3',	3F9h, 1FFh, 1FFh,	358h, 006h, 024h,	disop_cz
	disasm	'pollse4',	3F9h, 1FFh, 1FFh,	358h, 007h, 024h,	disop_cz
	disasm	'pollpat',	3F9h, 1FFh, 1FFh,	358h, 008h, 024h,	disop_cz
	disasm	'pollfbw',	3F9h, 1FFh, 1FFh,	358h, 009h, 024h,	disop_cz
	disasm	'pollxmt',	3F9h, 1FFh, 1FFh,	358h, 00Ah, 024h,	disop_cz
	disasm	'pollxfi',	3F9h, 1FFh, 1FFh,	358h, 00Bh, 024h,	disop_cz
	disasm	'pollxro',	3F9h, 1FFh, 1FFh,	358h, 00Ch, 024h,	disop_cz
	disasm	'pollxrl',	3F9h, 1FFh, 1FFh,	358h, 00Dh, 024h,	disop_cz
	disasm	'pollatn',	3F9h, 1FFh, 1FFh,	358h, 00Eh, 024h,	disop_cz
	disasm	'pollqmt',	3F9h, 1FFh, 1FFh,	358h, 00Fh, 024h,	disop_cz
	disasm	'waitint',	3F9h, 1FFh, 1FFh,	358h, 010h, 024h,	disop_cz
	disasm	'waitct1',	3F9h, 1FFh, 1FFh,	358h, 011h, 024h,	disop_cz
	disasm	'waitct2',	3F9h, 1FFh, 1FFh,	358h, 012h, 024h,	disop_cz
	disasm	'waitct3',	3F9h, 1FFh, 1FFh,	358h, 013h, 024h,	disop_cz
	disasm	'waitse1',	3F9h, 1FFh, 1FFh,	358h, 014h, 024h,	disop_cz
	disasm	'waitse2',	3F9h, 1FFh, 1FFh,	358h, 015h, 024h,	disop_cz
	disasm	'waitse3',	3F9h, 1FFh, 1FFh,	358h, 016h, 024h,	disop_cz
	disasm	'waitse4',	3F9h, 1FFh, 1FFh,	358h, 017h, 024h,	disop_cz
	disasm	'waitpat',	3F9h, 1FFh, 1FFh,	358h, 018h, 024h,	disop_cz
	disasm	'waitfbw',	3F9h, 1FFh, 1FFh,	358h, 019h, 024h,	disop_cz
	disasm	'waitxmt',	3F9h, 1FFh, 1FFh,	358h, 01Ah, 024h,	disop_cz
	disasm	'waitxfi',	3F9h, 1FFh, 1FFh,	358h, 01Bh, 024h,	disop_cz
	disasm	'waitxro',	3F9h, 1FFh, 1FFh,	358h, 01Ch, 024h,	disop_cz
	disasm	'waitxrl',	3F9h, 1FFh, 1FFh,	358h, 01Dh, 024h,	disop_cz
	disasm	'waitatn',	3F9h, 1FFh, 1FFh,	358h, 01Eh, 024h,	disop_cz

	disasm	'allowi ',	3FFh, 1FFh, 1FFh,	358h, 020h, 024h,	disop_none
	disasm	'stalli ',	3FFh, 1FFh, 1FFh,	358h, 021h, 024h,	disop_none
	disasm	'trgint1',	3FFh, 1FFh, 1FFh,	358h, 022h, 024h,	disop_none
	disasm	'trgint2',	3FFh, 1FFh, 1FFh,	358h, 023h, 024h,	disop_none
	disasm	'trgint3',	3FFh, 1FFh, 1FFh,	358h, 024h, 024h,	disop_none
	disasm	'nixint1',	3FFh, 1FFh, 1FFh,	358h, 025h, 024h,	disop_none
	disasm	'nixint2',	3FFh, 1FFh, 1FFh,	358h, 026h, 024h,	disop_none
	disasm	'nixint3',	3FFh, 1FFh, 1FFh,	358h, 027h, 024h,	disop_none

	disasm	'setint1',	3FEh, 000h, 1FFh,	358h, 000h, 025h,	disop_l
	disasm	'setint2',	3FEh, 000h, 1FFh,	358h, 000h, 026h,	disop_l
	disasm	'setint3',	3FEh, 000h, 1FFh,	358h, 000h, 027h,	disop_l
	disasm	'setq   ',	3FEh, 000h, 1FFh,	358h, 000h, 028h,	disop_l
	disasm	'setq2  ',	3FEh, 000h, 1FFh,	358h, 000h, 029h,	disop_l
	disasm	'push   ',	3FEh, 000h, 1FFh,	358h, 000h, 02Ah,	disop_l
	disasm	'pop    ',	3F9h, 000h, 1FFh,	358h, 000h, 02Bh,	disop_dcz
	disasm	'jmp    ',	3F9h, 000h, 1FFh,	358h, 000h, 02Ch,	disop_dcz
	disasm	'call   ',	3F9h, 000h, 1FFh,	358h, 000h, 02Dh,	disop_dcz
	disasm	'ret    ',	3F9h, 000h, 1FFh,	359h, 000h, 02Dh,	disop_cz
	disasm	'calla  ',	3F9h, 000h, 1FFh,	358h, 000h, 02Eh,	disop_dcz
	disasm	'reta   ',	3F9h, 000h, 1FFh,	359h, 000h, 02Eh,	disop_cz
	disasm	'callb  ',	3F9h, 000h, 1FFh,	358h, 000h, 02Fh,	disop_dcz
	disasm	'retb   ',	3F9h, 000h, 1FFh,	359h, 000h, 02Fh,	disop_cz

	disasm	'jmprel ',	3FEh, 000h, 1FFh,	358h, 000h, 030h,	disop_l
	disasm	'skip   ',	3FEh, 000h, 1FFh,	358h, 000h, 031h,	disop_l
	disasm	'skipf  ',	3FEh, 000h, 1FFh,	358h, 000h, 032h,	disop_l
	disasm	'execf  ',	3FEh, 000h, 1FFh,	358h, 000h, 033h,	disop_l
	disasm	'getptr ',	3FFh, 000h, 1FFh,	358h, 000h, 034h,	disop_d

	disasm	'cogbrk ',	3FEh, 000h, 1FFh,	358h, 000h, 035h,	disop_l
	disasm	'getbrk ',	3FAh, 000h, 1FFh,	35Ah, 000h, 035h,	disop_dcz
	disasm	'getbrk ',	3FCh, 000h, 1FFh,	35Ch, 000h, 035h,	disop_dcz

	disasm	'brk    ',	3FEh, 000h, 1FFh,	358h, 000h, 036h,	disop_l
	disasm	'setluts',	3FEh, 000h, 1FFh,	358h, 000h, 037h,	disop_l
	disasm	'setcy  ',	3FEh, 000h, 1FFh,	358h, 000h, 038h,	disop_l
	disasm	'setci  ',	3FEh, 000h, 1FFh,	358h, 000h, 039h,	disop_l
	disasm	'setcq  ',	3FEh, 000h, 1FFh,	358h, 000h, 03Ah,	disop_l
	disasm	'setcfrq',	3FEh, 000h, 1FFh,	358h, 000h, 03Bh,	disop_l
	disasm	'setcmod',	3FEh, 000h, 1FFh,	358h, 000h, 03Ch,	disop_l
	disasm	'setpiv ',	3FEh, 000h, 1FFh,	358h, 000h, 03Dh,	disop_l
	disasm	'setpix ',	3FEh, 000h, 1FFh,	358h, 000h, 03Eh,	disop_l
	disasm	'cogatn ',	3FEh, 000h, 1FFh,	358h, 000h, 03Fh,	disop_l

	disasm	'testp  ',	3FEh, 000h, 1E1h,	35Ah, 000h, 040h,	disop_lcz_pin_log
	disasm	'testp  ',	3FEh, 000h, 1E1h,	35Ch, 000h, 040h,	disop_lcz_pin_log
	disasm	'testpn ',	3FEh, 000h, 1E1h,	35Ah, 000h, 041h,	disop_lcz_pin_log
	disasm	'testpn ',	3FEh, 000h, 1E1h,	35Ch, 000h, 041h,	disop_lcz_pin_log

	disasm	'dirl   ',	3F8h, 000h, 1FFh,	358h, 000h, 040h,	disop_lcz_pin
	disasm	'dirh   ',	3F8h, 000h, 1FFh,	358h, 000h, 041h,	disop_lcz_pin
	disasm	'dirc   ',	3F8h, 000h, 1FFh,	358h, 000h, 042h,	disop_lcz_pin
	disasm	'dirnc  ',	3F8h, 000h, 1FFh,	358h, 000h, 043h,	disop_lcz_pin
	disasm	'dirz   ',	3F8h, 000h, 1FFh,	358h, 000h, 044h,	disop_lcz_pin
	disasm	'dirnz  ',	3F8h, 000h, 1FFh,	358h, 000h, 045h,	disop_lcz_pin
	disasm	'dirrnd ',	3F8h, 000h, 1FFh,	358h, 000h, 046h,	disop_lcz_pin
	disasm	'dirnot ',	3F8h, 000h, 1FFh,	358h, 000h, 047h,	disop_lcz_pin
	disasm	'outl   ',	3F8h, 000h, 1FFh,	358h, 000h, 048h,	disop_lcz_pin
	disasm	'outh   ',	3F8h, 000h, 1FFh,	358h, 000h, 049h,	disop_lcz_pin
	disasm	'outc   ',	3F8h, 000h, 1FFh,	358h, 000h, 04Ah,	disop_lcz_pin
	disasm	'outnc  ',	3F8h, 000h, 1FFh,	358h, 000h, 04Bh,	disop_lcz_pin
	disasm	'outz   ',	3F8h, 000h, 1FFh,	358h, 000h, 04Ch,	disop_lcz_pin
	disasm	'outnz  ',	3F8h, 000h, 1FFh,	358h, 000h, 04Dh,	disop_lcz_pin
	disasm	'outrnd ',	3F8h, 000h, 1FFh,	358h, 000h, 04Eh,	disop_lcz_pin
	disasm	'outnot ',	3F8h, 000h, 1FFh,	358h, 000h, 04Fh,	disop_lcz_pin
	disasm	'fltl   ',	3F8h, 000h, 1FFh,	358h, 000h, 050h,	disop_lcz_pin
	disasm	'flth   ',	3F8h, 000h, 1FFh,	358h, 000h, 051h,	disop_lcz_pin
	disasm	'fltc   ',	3F8h, 000h, 1FFh,	358h, 000h, 052h,	disop_lcz_pin
	disasm	'fltnc  ',	3F8h, 000h, 1FFh,	358h, 000h, 053h,	disop_lcz_pin
	disasm	'fltz   ',	3F8h, 000h, 1FFh,	358h, 000h, 054h,	disop_lcz_pin
	disasm	'fltnz  ',	3F8h, 000h, 1FFh,	358h, 000h, 055h,	disop_lcz_pin
	disasm	'fltrnd ',	3F8h, 000h, 1FFh,	358h, 000h, 056h,	disop_lcz_pin
	disasm	'fltnot ',	3F8h, 000h, 1FFh,	358h, 000h, 057h,	disop_lcz_pin
	disasm	'drvl   ',	3F8h, 000h, 1FFh,	358h, 000h, 058h,	disop_lcz_pin
	disasm	'drvh   ',	3F8h, 000h, 1FFh,	358h, 000h, 059h,	disop_lcz_pin
	disasm	'drvc   ',	3F8h, 000h, 1FFh,	358h, 000h, 05Ah,	disop_lcz_pin
	disasm	'drvnc  ',	3F8h, 000h, 1FFh,	358h, 000h, 05Bh,	disop_lcz_pin
	disasm	'drvz   ',	3F8h, 000h, 1FFh,	358h, 000h, 05Ch,	disop_lcz_pin
	disasm	'drvnz  ',	3F8h, 000h, 1FFh,	358h, 000h, 05Dh,	disop_lcz_pin
	disasm	'drvrnd ',	3F8h, 000h, 1FFh,	358h, 000h, 05Eh,	disop_lcz_pin
	disasm	'drvnot ',	3F8h, 000h, 1FFh,	358h, 000h, 05Fh,	disop_lcz_pin

	disasm	'splitb ',	3FFh, 000h, 1FFh,	358h, 000h, 060h,	disop_d
	disasm	'mergeb ',	3FFh, 000h, 1FFh,	358h, 000h, 061h,	disop_d
	disasm	'splitw ',	3FFh, 000h, 1FFh,	358h, 000h, 062h,	disop_d
	disasm	'mergew ',	3FFh, 000h, 1FFh,	358h, 000h, 063h,	disop_d
	disasm	'seussf ',	3FFh, 000h, 1FFh,	358h, 000h, 064h,	disop_d
	disasm	'seussr ',	3FFh, 000h, 1FFh,	358h, 000h, 065h,	disop_d
	disasm	'rgbsqz ',	3FFh, 000h, 1FFh,	358h, 000h, 066h,	disop_d
	disasm	'rgbexp ',	3FFh, 000h, 1FFh,	358h, 000h, 067h,	disop_d
	disasm	'xoro32 ',	3FFh, 000h, 1FFh,	358h, 000h, 068h,	disop_d
	disasm	'rev    ',	3FFh, 000h, 1FFh,	358h, 000h, 069h,	disop_d
	disasm	'rczr   ',	3F9h, 000h, 1FFh,	358h, 000h, 06Ah,	disop_dcz
	disasm	'rczl   ',	3F9h, 000h, 1FFh,	358h, 000h, 06Bh,	disop_dcz
	disasm	'wrc    ',	3FFh, 000h, 1FFh,	358h, 000h, 06Ch,	disop_d
	disasm	'wrnc   ',	3FFh, 000h, 1FFh,	358h, 000h, 06Dh,	disop_d
	disasm	'wrz    ',	3FFh, 000h, 1FFh,	358h, 000h, 06Eh,	disop_d
	disasm	'wrnz   ',	3FFh, 000h, 1FFh,	358h, 000h, 06Fh,	disop_d
	disasm	'modc   ',	3FFh, 000h, 1FFh,	35Dh, 000h, 06Fh,	disop_dc_modc
	disasm	'modz   ',	3FFh, 000h, 1FFh,	35Bh, 000h, 06Fh,	disop_dz_modz
	disasm	'modcz  ',	3F9h, 000h, 1FFh,	359h, 000h, 06Fh,	disop_dcz_modcz

	disasm	'setscp ',	3FEh, 000h, 1FFh,	358h, 000h, 070h,	disop_l
	disasm	'getscp ',	3FFh, 000h, 1FFh,	358h, 000h, 071h,	disop_d

	disasm	'jmp    ',	3F8h, 000h, 000h,	360h, 000h, 000h,	disop_addr20
	disasm	'call   ',	3F8h, 000h, 000h,	368h, 000h, 000h,	disop_addr20
	disasm	'calla  ',	3F8h, 000h, 000h,	370h, 000h, 000h,	disop_addr20
	disasm	'callb  ',	3F8h, 000h, 000h,	378h, 000h, 000h,	disop_addr20
	disasm	'calld  ',	3E0h, 000h, 000h,	380h, 000h, 000h,	disop_p_addr20
	disasm	'loc    ',	3E0h, 000h, 000h,	3A0h, 000h, 000h,	disop_p_addr20
	disasm	'augs   ',	3E0h, 000h, 000h,	3C0h, 000h, 000h,	disop_aug
	disasm	'augd   ',	3E0h, 000h, 000h,	3E0h, 000h, 000h,	disop_aug

	disasm	'<error>',	000h, 000h, 000h,	000h, 000h, 000h,	disop_none

da_nop:	disasm	'nop    ',	000h, 000h, 000h,	000h, 000h, 000h,	disop_none
;
;
;************************************************************************
;*  DEBUG Display Parser						*
;************************************************************************
;
count0	dd_end				;end of line	elements
count	dd_dis				;display type
count	dd_nam				;display name
count	dd_key				;display command
count	dd_num				;number, $num/%num/num
count	dd_str				;string, 'text'
count	dd_unk				;unknown symbol

count0	dd_dis_logic			;LOGIC		displays
count	dd_dis_scope			;SCOPE
count	dd_dis_scope_xy			;SCOPE_XY
count	dd_dis_fft			;FFT
count	dd_dis_spectro			;SPECTRO
count	dd_dis_plot			;PLOT
count	dd_dis_term			;TERM
count	dd_dis_bitmap			;BITMAP
count	dd_dis_midi			;MIDI

count0	dd_key_black			;BLACK		color group
count	dd_key_white			;WHITE
count	dd_key_orange			;ORANGE
count	dd_key_blue			;BLUE
count	dd_key_green			;GREEN
count	dd_key_cyan			;CYAN
count	dd_key_red			;RED
count	dd_key_magenta			;MAGENTA
count	dd_key_yellow			;YELLOW
count	dd_key_gray			;GRAY

count	dd_key_lut1			;LUT1		color-mode group
count	dd_key_lut2			;LUT2
count	dd_key_lut4			;LUT4
count	dd_key_lut8			;LUT8
count	dd_key_luma8			;LUMA8
count	dd_key_luma8w			;LUMA8W
count	dd_key_luma8x			;LUMA8X
count	dd_key_hsv8			;HSV8
count	dd_key_hsv8w			;HSV8W
count	dd_key_hsv8x			;HSV8X
count	dd_key_rgbi8			;RGBI8
count	dd_key_rgbi8w			;RGBI8W
count	dd_key_rgbi8x			;RGBI8X
count	dd_key_rgb8			;RGB8
count	dd_key_hsv16			;HSV16
count	dd_key_hsv16w			;HSV16W
count	dd_key_hsv16x			;HSV16X
count	dd_key_rgb16			;RGB16
count	dd_key_rgb24			;RGB24

count	dd_key_longs_1bit		;LONGS_1BIT	pack-data group
count	dd_key_longs_2bit		;LONGS_2BIT
count	dd_key_longs_4bit		;LONGS_4BIT
count	dd_key_longs_8bit		;LONGS_8BIT
count	dd_key_longs_16bit		;LONGS_16BIT
count	dd_key_words_1bit		;WORDS_1BIT
count	dd_key_words_2bit		;WORDS_2BIT
count	dd_key_words_4bit		;WORDS_4BIT
count	dd_key_words_8bit		;WORDS_8BIT
count	dd_key_bytes_1bit		;BYTES_1BIT
count	dd_key_bytes_2bit		;BYTES_2BIT
count	dd_key_bytes_4bit		;BYTES_4BIT

count	dd_key_alt			;ALT		keywords
count	dd_key_auto			;AUTO
count	dd_key_backcolor		;BACKCOLOR
count	dd_key_box			;BOX
count	dd_key_cartesian		;CARTESIAN
count	dd_key_channel			;CHANNEL
count	dd_key_circle			;CIRCLE
count	dd_key_clear			;CLEAR
count	dd_key_close			;CLOSE
count	dd_key_color			;COLOR
count	dd_key_crop			;CROP
count	dd_key_depth			;DEPTH
count	dd_key_dot			;DOT
count	dd_key_dotsize			;DOTSIZE
count	dd_key_hidexy			;HIDEXY
count	dd_key_holdoff			;HOLDOFF
count	dd_key_layer			;LAYER
count	dd_key_line			;LINE
count	dd_key_linesize			;LINESIZE
count	dd_key_logscale			;LOGSCALE
count	dd_key_lutcolors		;LUTCOLORS
count	dd_key_mag			;MAG
count	dd_key_obox			;OBOX
count	dd_key_opacity			;OPACITY
count	dd_key_origin			;ORIGIN
count	dd_key_oval			;OVAL
count	dd_key_pc_key			;PC_KEY
count	dd_key_pc_mouse			;PC_MOUSE
count	dd_key_polar			;POLAR
count	dd_key_pos			;POS
count	dd_key_precise			;PRECISE
count	dd_key_range			;RANGE
count	dd_key_rate			;RATE
count	dd_key_samples			;SAMPLES
count	dd_key_save			;SAVE
count	dd_key_scroll			;SCROLL
count	dd_key_set			;SET
count	dd_key_signed			;SIGNED
count	dd_key_size			;SIZE
count	dd_key_spacing			;SPACING
count	dd_key_sparse			;SPARSE
count	dd_key_sprite			;SPRITE
count	dd_key_spritedef		;SPRITEDEF
count	dd_key_text			;TEXT
count	dd_key_textangle		;TEXTANGLE
count	dd_key_textsize			;TEXTSIZE
count	dd_key_textstyle		;TEXTSTYLE
count	dd_key_title			;TITLE
count	dd_key_trace			;TRACE
count	dd_key_trigger			;TRIGGER
count	dd_key_update			;UPDATE
count	dd_key_window			;WINDOW


debug_symbols:

	sym	dd_dis,	dd_dis_logic,			'LOGIC'		;displays
	sym	dd_dis,	dd_dis_scope,			'SCOPE'
	sym	dd_dis,	dd_dis_scope_xy,		'SCOPE_XY'
	sym	dd_dis,	dd_dis_fft,			'FFT'
	sym	dd_dis,	dd_dis_spectro,			'SPECTRO'
	sym	dd_dis,	dd_dis_plot,			'PLOT'
	sym	dd_dis,	dd_dis_term,			'TERM'
	sym	dd_dis,	dd_dis_bitmap,			'BITMAP'
	sym	dd_dis,	dd_dis_midi,			'MIDI'

	sym	dd_key,	dd_key_black,			'BLACK'		;color group
	sym	dd_key,	dd_key_white,			'WHITE'
	sym	dd_key,	dd_key_orange,			'ORANGE'
	sym	dd_key,	dd_key_blue,			'BLUE'
	sym	dd_key,	dd_key_green,			'GREEN'
	sym	dd_key,	dd_key_cyan,			'CYAN'
	sym	dd_key,	dd_key_red,			'RED'
	sym	dd_key,	dd_key_magenta,			'MAGENTA'
	sym	dd_key,	dd_key_yellow,			'YELLOW'
	sym	dd_key,	dd_key_gray,			'GRAY'
	sym	dd_key,	dd_key_gray,			'GREY'		;(allow both spellings)

	sym	dd_key,	dd_key_lut1,			'LUT1'		;color-mode group
	sym	dd_key,	dd_key_lut2,			'LUT2'
	sym	dd_key,	dd_key_lut4,			'LUT4'
	sym	dd_key,	dd_key_lut8,			'LUT8'
	sym	dd_key,	dd_key_luma8,			'LUMA8'
	sym	dd_key,	dd_key_luma8w,			'LUMA8W'
	sym	dd_key,	dd_key_luma8x,			'LUMA8X'
	sym	dd_key,	dd_key_hsv8,			'HSV8'
	sym	dd_key,	dd_key_hsv8w,			'HSV8W'
	sym	dd_key,	dd_key_hsv8x,			'HSV8X'
	sym	dd_key,	dd_key_rgbi8,			'RGBI8'
	sym	dd_key,	dd_key_rgbi8w,			'RGBI8W'
	sym	dd_key,	dd_key_rgbi8x,			'RGBI8X'
	sym	dd_key,	dd_key_rgb8,			'RGB8'
	sym	dd_key,	dd_key_hsv16,			'HSV16'
	sym	dd_key,	dd_key_hsv16w,			'HSV16W'
	sym	dd_key,	dd_key_hsv16x,			'HSV16X'
	sym	dd_key,	dd_key_rgb16,			'RGB16'
	sym	dd_key,	dd_key_rgb24,			'RGB24'

	sym	dd_key,	dd_key_longs_1bit,		'LONGS_1BIT'	;packed-data group
	sym	dd_key,	dd_key_longs_2bit,		'LONGS_2BIT'
	sym	dd_key,	dd_key_longs_4bit,		'LONGS_4BIT'
	sym	dd_key,	dd_key_longs_8bit,		'LONGS_8BIT'
	sym	dd_key,	dd_key_longs_16bit,		'LONGS_16BIT'
	sym	dd_key,	dd_key_words_1bit,		'WORDS_1BIT'
	sym	dd_key,	dd_key_words_2bit,		'WORDS_2BIT'
	sym	dd_key,	dd_key_words_4bit,		'WORDS_4BIT'
	sym	dd_key,	dd_key_words_8bit,		'WORDS_8BIT'
	sym	dd_key,	dd_key_bytes_1bit,		'BYTES_1BIT'
	sym	dd_key,	dd_key_bytes_2bit,		'BYTES_2BIT'
	sym	dd_key,	dd_key_bytes_4bit,		'BYTES_4BIT'

	sym	dd_key,	dd_key_alt,			'ALT'		;keywords
	sym	dd_key,	dd_key_auto,			'AUTO'
	sym	dd_key,	dd_key_backcolor,		'BACKCOLOR'
	sym	dd_key,	dd_key_box,			'BOX'
	sym	dd_key,	dd_key_cartesian,		'CARTESIAN'
	sym	dd_key,	dd_key_channel,			'CHANNEL'
	sym	dd_key,	dd_key_circle,			'CIRCLE'
	sym	dd_key,	dd_key_clear,			'CLEAR'
	sym	dd_key,	dd_key_close,			'CLOSE'
	sym	dd_key,	dd_key_color,			'COLOR'
	sym	dd_key,	dd_key_crop,			'CROP'
	sym	dd_key,	dd_key_depth,			'DEPTH'
	sym	dd_key,	dd_key_dot,			'DOT'
	sym	dd_key,	dd_key_dotsize,			'DOTSIZE'
	sym	dd_key,	dd_key_hidexy,			'HIDEXY'
	sym	dd_key,	dd_key_holdoff,			'HOLDOFF'
	sym	dd_key,	dd_key_layer,			'LAYER'
	sym	dd_key,	dd_key_line,			'LINE'
	sym	dd_key,	dd_key_linesize,		'LINESIZE'
	sym	dd_key,	dd_key_logscale,		'LOGSCALE'
	sym	dd_key,	dd_key_lutcolors,		'LUTCOLORS'
	sym	dd_key,	dd_key_mag,			'MAG'
	sym	dd_key,	dd_key_obox,			'OBOX'
	sym	dd_key, dd_key_opacity,			'OPACITY'
	sym	dd_key,	dd_key_origin,			'ORIGIN'
	sym	dd_key,	dd_key_oval,			'OVAL'
	sym	dd_key,	dd_key_pc_key,			'PC_KEY'
	sym	dd_key,	dd_key_pc_mouse,		'PC_MOUSE'
	sym	dd_key,	dd_key_polar,			'POLAR'
	sym	dd_key,	dd_key_pos,			'POS'
	sym	dd_key,	dd_key_precise,			'PRECISE'
	sym	dd_key,	dd_key_range,			'RANGE'
	sym	dd_key,	dd_key_rate,			'RATE'
	sym	dd_key,	dd_key_samples,			'SAMPLES'
	sym	dd_key,	dd_key_save,			'SAVE'
	sym	dd_key,	dd_key_scroll,			'SCROLL'
	sym	dd_key,	dd_key_set,			'SET'
	sym	dd_key,	dd_key_signed,			'SIGNED'
	sym	dd_key,	dd_key_size,			'SIZE'
	sym	dd_key,	dd_key_spacing,			'SPACING'
	sym	dd_key,	dd_key_sparse,			'SPARSE'
	sym	dd_key, dd_key_sprite,			'SPRITE'
	sym	dd_key, dd_key_spritedef,		'SPRITEDEF'
	sym	dd_key,	dd_key_text,			'TEXT'
	sym	dd_key,	dd_key_textangle,		'TEXTANGLE'
	sym	dd_key,	dd_key_textsize,		'TEXTSIZE'
	sym	dd_key,	dd_key_textstyle,		'TEXTSTYLE'
	sym	dd_key,	dd_key_title,			'TITLE'
	sym	dd_key,	dd_key_trace,			'TRACE'
	sym	dd_key,	dd_key_trigger,			'TRIGGER'
	sym	dd_key,	dd_key_update,			'UPDATE'
	sym	dd_key,	dd_key_window,			'WINDOW'

	db	0
;
;
; Variables
;
ddx		ddsymbols_auto_hash,1000h	;auto symbols
dbx		ddsymbols_auto,ddsymbols_limit_auto

ddx		ddsymbols_name_hash,1000h	;name symbols
dbx		ddsymbols_name,ddsymbols_limit_name

ddx		dd_sym_start
dbx		dd_sym_size

dbx		dd_sym_exists
ddx		dd_sym_exists_ptr,32

dbx		dd_name,symbol_size_limit+2

ddx		debug_display_ptr
;
;
; Reset debug symbols
;
reset_debug_symbols:

		mov	edi,offset ddsymbols_auto_hash		;reset debug symbols
		call	reset_hash_table

		mov	[symbol_ptr_hash],	offset ddsymbols_auto_hash	;write auto symbols
		mov	[symbol_ptr],		offset ddsymbols_auto
		mov	[symbol_ptr_limit],	offset ddsymbols_auto + ddsymbols_limit_auto - (1+32+1+4+1+4)

		lea	esi,[debug_symbols]			;enter debug symbols
		call	enter_symbols

		mov	edi,offset ddsymbols_name_hash		;reset name symbols
		call	reset_hash_table

		mov	[symbol_ptr_hash],	offset ddsymbols_name_hash	;write name symbols
		mov	[symbol_ptr],		offset ddsymbols_name
		mov	[symbol_ptr_limit],	offset ddsymbols_name + ddsymbols_limit_name - (1+32+1+4+1+4)

		ret
;
;
; Parse debug string
;
; Instance:	dd_dis
;		dd_unk	(unknown symbol, assigned dd_nam and debug_display_new, plus record entered)
;		dd_key | dd_num | dd_str
;		dd_end
;
; Command:	dd_nam
;		dd_key | dd_num | dd_str
;		dd_end
;
parse_debug_string:

		mov	[debug_display_ptr],0		;reset record pointer
		lea	esi,[debug_display_string]	;point to source string
		mov	[symbol2],0			;flag display-instance
		mov	[@@close_flag],0		;flag display-command close
		mov	[@@targets],0			;reset target count for existing-display command

		call	get_dd_element			;check for display-instance or instance-name symbol
		cmp	al,dd_dis			;new-display instance?
		je	@@newinstance
		cmp	al,dd_nam			;existing-display command?
		je	@@command

@@abort:	mov	[debug_display_type+0],0	;abort due to unexpected type
		ret


@@newinstance:	call	enter_dd_record		;new display instance, enter display-instance record

		call	get_dd_element		;check for unique instance name
		cmp	al,dd_unk
		jne	@@abort

		call	backup_symbol		;copy unique instance name to symbol2

		push	esi			;copy original non-uppercased symbol to dd_name
		push	edi
		movzx	ecx,[dd_sym_size]
		mov	esi,[dd_sym_start]
		lea	edi,[dd_name]
	rep	movsb
		mov	al,0
		stosb
		pop	edi
		pop	esi

		mov	al,[symbol_exists]	;save symbol-exists flag and ptr
		mov	[dd_sym_exists],al
		mov	eax,[symbol_exists_ptr]
		mov	[dd_sym_exists_ptr],eax

		mov	eax,dd_nam		;ready to enter instance-name record
		lea	ebx,[dd_name]		;value points to display name, id will be debug_display_new
		jmp	@@enter			;enter instance-name record and process rest of elements


@@command:	movzx	ecx,[@@targets]		;existing-display command
		mov	eax,[symbol_exists_ptr]	;save symbol ptr into index
		mov	[dd_sym_exists_ptr+ecx*4],eax
		inc	[@@targets]		;inc target count (will never exceed 32)
		mov	al,dd_nam		;enter instance-name record
		call	enter_dd_record
		call	get_dd_element		;get next element
		cmp	al,dd_nam		;if another target display name, enter it
		je	@@command
		jmp	@@check			;not display name, process as rest of elements


@@enter:	call	enter_dd_record		;enter record

		call	get_dd_element		;process rest of elements

@@check:	cmp	al,dd_key		;allow keyword, but check for command and dd_key_close
		jne	@@notkey
		cmp	ebx,dd_key_close
		jne	@@enter
		cmp	[symbol2],0
		jne	@@enter
		mov	[@@close_flag],1
		jmp	@@enter
@@notkey:
		cmp	al,dd_num		;allow number
		je	@@enter

		cmp	al,dd_str		;allow string
		je	@@enter

		cmp	al,0			;allow end
		jne	@@abort

		cmp	[symbol2],0		;got to end without aborting, is this a new display instance or command?
		je	@@commanddone


		xor	ebx,ebx			;new display instance, determine its id
		mov	eax,[debug_display_ena]
@@getid:	test	eax,1
		jz	@@gotid
		inc	ebx
		cmp	ebx,32			;abort if no more id's
		je	@@abort
		shr	eax,1
		jmp	@@getid
@@gotid:
		call	@@toggle		;set id bit in debug_display_ena

		mov	[debug_display_new],ebx	;ebx and debug_display_new hold id

		cmp	[dd_sym_exists],0	;does symbol already exist?
		je	@@entersymbol

		mov	eax,[dd_sym_exists_ptr]	;symbol already exists, update type and value
		mov	[byte eax-1],dd_nam
		mov	[dword eax-1-4],ebx
		jmp	@@done

@@entersymbol:	mov	al,dd_nam		;symbol doesn't exist, enter symbol
		call	enter_symbol2
		jmp	@@done


@@commanddone:	movzx	ecx,[@@targets]		;existing-display command done, report number of display targets
		mov	[debug_display_targs],cl

		cmp	[@@close_flag],0	;was dd_key_close found?
		je	@@done

@@close:	mov	eax,[dd_sym_exists_ptr+ecx*4-4]	;yes, change display name symbol type(s) from dd_nam to dd_unk
		mov	[byte eax-1],dd_unk
		mov	bl,[byte eax-1-4]	;get id from symbol value
		call	@@toggle		;cancel id bit in debug_display_ena
		loop	@@close			;loop until done


@@done:		mov	al,0			;enter dd_end record (al=0)
		jmp	enter_dd_record



@@toggle:	push	ecx			;toggle debug_display_ena bit by id in bl
		mov	cl,bl
		mov	eax,1
		shl	eax,cl
		xor	[debug_display_ena],eax
		pop	ecx
		ret


dbx		@@close_flag
dbx		@@targets
;
;
; Get next element from debug display at esi - al=type and ebx=value
;
get_dd_element:	call	check_dd_sym		;check for symbol
		jnc	@@got

		call	check_dd_num		;check for number
		jnc	@@got

		call	check_dd_str		;check for string
		jnc	@@got

		lodsb				;get chr, inc ptr

		cmp	al,0			;check for end
		jne	get_dd_element

		dec	esi			;repoint to end in case called again
@@got:		ret
;
;
; Check for debug display symbol at esi
; c=0 if symbol, type in al, value in ebx, esi points after symbol
;
check_dd_sym:	mov	al,[esi]		;get initial chr
		call	check_word_chr_initial	;check for '_' or alpha
		jc	@@exit			;if not, exit with c=1


		push	edi

		mov	ah,0			;reset symbol length
		mov	[dd_sym_start],esi	;save symbol start
		lea	edi,[symbol]		;point to symbol

@@chr:		lodsb				;gather symbol chrs
		call	check_word_chr
		jc	@@got
		cmp	ah,symbol_size_limit	;if symbol length at limit, ignore extra chrs
		je	@@chr
		stosb				;store chr into symbol
		inc	ah			;inc symbol length
		jmp	@@chr			;try next chr
@@got:
		mov	[dd_sym_size],ah	;got symbol, save size
		dec	esi			;repoint to chr after symbol
		mov	al,0			;zero-terminate symbol
		stosb

		call	find_dd_symbol		;find debug display symbol

		pop	edi
		clc				;c=0
@@exit:		ret
;
;
; Check for number at esi
; c=0 if number, dd_num in al, value in ebx, esi points after number
;
check_dd_num:	push	esi			;save original ptr

		xor	ebx,ebx			;reset accumulator
		mov	ah,0			;clear negate flag
		lodsb				;get initial chr

		cmp	al,'-'			;negate?
		jne	@@notneg
		inc	ah
		lodsb				;get next chr
@@notneg:
		cmp	al,'$'			;hex?
		je	@@hex

		cmp	al,'%'			;binary?
		je	@@bin

		sub	al,'0'			;decimal?
		jb	@@nope
		cmp	al,9
		jbe	@@dec

@@nope:		pop	esi			;not a number, restore original ptr
		stc				;c=1
		ret


@@hex:		lodsb				;hex
		call	check_hex
		jc	@@nope

@@hexloop:	shl	ebx,4
		or	bl,al
@@hexchr:	lodsb
		cmp	al,'_'
		je	@@hexchr
		call	check_hex
		jnc	@@hexloop
		jmp	@@got


@@bin:		lodsb				;binary
		sub	al,'0'
		jc	@@nope
		cmp	al,1
		ja	@@nope

@@binloop:	shl	ebx,1
		or	bl,al
@@binchr:	lodsb
		cmp	al,'_'
		je	@@binchr
		sub	al,'0'
		jc	@@got
		cmp	al,1
		jbe	@@binloop
		jmp	@@got


@@decloop:	lodsb				;decimal
		cmp	al,'_'
		je	@@decloop
		sub	al,'0'
		jc	@@got
		cmp	al,9
		ja	@@got
@@dec:		push	ecx			;multiply by 10
		mov	ecx,ebx
		shl	ebx,2
		add	ebx,ecx
		shl	ebx,1
		movzx	ecx,al
		add	ebx,ecx
		pop	ecx
		jmp	@@decloop


@@got:		dec	ah			;got number, negate?
		jnz	@@pos
		neg	ebx
@@pos:
		pop	eax			;pop original ptr
		dec	esi			;back up ptr
		mov	al,dd_num		;set dd_num
		clc				;c=0
		ret
;
;
; Check for 'string' at esi
; c=0 if string, address in ebx, esi points after string
;
check_dd_str:	cmp	[byte esi],27h		;if not ', exit with c=1
		stc
		jne	@@exit

		inc	esi			;point past '
		mov	ebx,esi			;get string address into ebx

@@chr:		lodsb				;get string chr
		cmp	al,27h			;if ', got string, c=0
		je	@@got
		cmp	al,0			;if not end, get next chr
		jne	@@chr

		dec	esi			;string not terminated, repoint to end, c=0
		jmp	@@type

@@got:		mov	[byte esi-1],0		;zero-terminate string in-situ
@@type:		mov	al,dd_str		;set dd_str
@@exit:		ret
;
;
; Find debug display symbol in auto/name symbol table
; symbol must hold name, terminated with 0
; if found, eax=type and ebx=value
; if not found, eax=0 (type_undefined) and ebx=0
;
find_dd_symbol:	push	ecx
		push	edx
		push	esi
		push	edi

		lea	esi,[symbol]		;hash symbol, ecx=length, edx=hash index
		call	hash_symbol

		mov	ebx,offset ddsymbols_auto_hash		;search debug display auto symbols
		call	check_symbol
		jnc	@@found

		mov	ebx,offset ddsymbols_name_hash		;search debug display name symbols
		call	check_symbol
		jnc	@@found

		mov	al,dd_unk		;symbol not found, unknown
		xor	ebx,ebx

@@found:	pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret
;
;
; Enter type (al) and value (ebx) into debug display record
;
enter_dd_record:

		push	eax
		push	ecx

		mov	ecx,[debug_display_ptr]		;get record pointer
		cmp	ecx,debug_display_limit		;check it
		jb	@@enter

		mov	al,0				;if overflow, set first record to dd_end
		xor	ecx,ecx

@@enter:	mov	[debug_display_type+ecx],al	;enter type
		mov	[debug_display_value+ecx*4],ebx	;enter value

		inc	[debug_display_ptr]		;inc record pointer

		pop	ecx
		pop	eax
		ret
;
;
;************************************************************************
;*  Symbol Engine							*
;************************************************************************
;
;
; Hash table index ($1000 elements):
;
;	long:	pointer to symbol record (0=no record)
;
; Symbol records:
;
;	byte:	symbol length, including terminating zero
;	bytes:	symbol chrs + 0
;	long:	symbol value
;	byte:	symbol type
;	long:	pointer to next record (0=no record)
;
;
; Variables
;
ddx		symbol_ptr_hash				;these three must be set to the current symbol set
ddx		symbol_ptr
ddx		symbol_ptr_limit

ddx		symbols_pre_hash,1000h			;preprocessor symbols
dbx		symbols_pre,symbols_limit_pre

ddx		symbols_auto_hash,1000h			;auto symbols
dbx		symbols_auto,symbols_limit_auto

ddx		symbols_level_hash,1000h		;spin2 level symbols
dbx		symbols_level,symbols_limit_level

ddx		symbols_param_hash,1000h		;parameter symbols
dbx		symbols_param,symbols_limit_param

ddx		symbols_main_hash,1000h			;main symbols
dbx		symbols_main,symbols_limit_main

ddx		symbols_local_hash,1000h		;local symbols
dbx		symbols_local,symbols_limit_local

ddx		symbols_inline_hash,1000h		;inline symbols
dbx		symbols_inline,symbols_limit_inline

dbx		symbol_exists				;symbol-exists flag and ptr
ddx		symbol_exists_ptr

dbx		symbol,symbol_size_limit+2			;+2 for obj.method extra byte and 0
dbx		symbol2,symbol_size_limit+2
;
;
; Enter preprocessor symbols into hashed symbol table
;
enter_symbols_pre:

		call	reset_symbols_pre		;reset preprocessor symbols
		call	write_symbols_pre

		lea	esi,[preprocessor_symbols]	;enter functional preprocessor symbols
		cmp	[debug_mode],0			;add '__DEBUG__'?
		je	@@enter
		lea	esi,[preprocessor_symbols_debug]
@@enter:	call	enter_symbols

		mov	edi,0				;enter any preprocessor symbols from command-line
@@ext:		cmp	edi,[pre_symbols]
		je	@@done
		mov	esi,edi
		shl	esi,5
		add	esi,offset pre_symbol_names
		call	hash_symbol
		push	edi
		lea	edi,[symbol2]
	rep	movsb
		pop	edi
		mov	al,type_pre_symbol
		mov	ebx,1
		call	enter_symbol2
		inc	edi
		jmp	@@ext

@@done:		ret
;
;
; Enter auto symbols into hashed symbol table
;
enter_symbols_auto:

		call	reset_symbols_auto
		call	write_symbols_auto
		lea	esi,[automatic_symbols]
		jmp	enter_symbols
;
;
; Discover Spin2 level and enter associated symbols
;
enter_symbols_level:

		call	reset_symbols_level
		call	write_symbols_level

		call	determine_level

		cmp	[spin2_level],44
		je	error_level44

		cmp	[spin2_level],43
		jb	@@not43
		lea	esi,[level43_symbols]
		call	enter_symbols
@@not43:
		cmp	[spin2_level],44
		jb	@@not44
		lea	esi,[level44_symbols]
		call	enter_symbols
@@not44:
		cmp	[spin2_level],45
		jb	@@not45
		lea	esi,[level45_symbols]
		call	enter_symbols
@@not45:
		cmp	[spin2_level],46
		jb	@@not46
		lea	esi,[level46_symbols]
		call	enter_symbols
@@not46:
		cmp	[spin2_level],47
		jb	@@not47
		lea	esi,[level47_symbols]
		call	enter_symbols
@@not47:
		cmp	[spin2_level],50
		jb	@@not50
		lea	esi,[level50_symbols]
		call	enter_symbols
@@not50:
		cmp	[spin2_level],51
		jb	@@not51
		lea	esi,[level51_symbols]
		call	enter_symbols
@@not51:
		ret
;
;
; Enter symbols into hashed symbol table
;
enter_symbols:	call	hash_symbol		;hash symbol name to get length

		lea	edi,[symbol2]		;copy symbol name to symbol2
	rep	movsb
		lodsd				;get value
		mov	ebx,eax
		lodsb				;get type
		call	enter_symbol2		;enter symbol

		cmp	[byte esi],0		;end of automatic symbols?
		jne	enter_symbols

		ret
;
;
; Enter param symbols into hashed symbol table
;
enter_symbols_param:

		call	reset_symbols_param
		call	write_symbols_param
		mov	edx,0

@@symbol:	cmp	edx,[params]
		je	@@done

		mov	esi,edx
		shl	esi,5
		add	esi,offset param_names
		lea	edi,[symbol2]
		mov	ecx,32
	rep	movsb

		mov	al,[param_types+edx]
		mov	ebx,[param_values+edx*4]
		call	enter_symbol2

		inc	edx
		jmp	@@symbol

@@done:		ret
;
;
; Resets for symbol tables
;
reset_symbols_pre:

		mov	edi,offset symbols_pre_hash
		jmp	reset_hash_table

reset_symbols_auto:

		mov	edi,offset symbols_auto_hash
		jmp	reset_hash_table

reset_symbols_level:

		mov	edi,offset symbols_level_hash
		jmp	reset_hash_table

reset_symbols_param:

		mov	edi,offset symbols_param_hash
		jmp	reset_hash_table

reset_symbols_main:

		mov	edi,offset symbols_main_hash
		jmp	reset_hash_table

reset_symbols_local:

		mov	edi,offset symbols_local_hash
		jmp	reset_hash_table

reset_symbols_inline:

		mov	edi,offset symbols_inline_hash

reset_hash_table:

		xor	eax,eax
		mov	ecx,1000h
	rep	stosd

		ret
;
;
; Write-setups for symbol tables
;
write_symbols_pre:

		mov	[symbol_ptr_hash],	offset symbols_pre_hash
		mov	[symbol_ptr],		offset symbols_pre
		mov	[symbol_ptr_limit],	offset symbols_pre + symbols_limit_pre - (1+32+1+4+1+4)
		ret

write_symbols_auto:

		mov	[symbol_ptr_hash],	offset symbols_auto_hash
		mov	[symbol_ptr],		offset symbols_auto
		mov	[symbol_ptr_limit],	offset symbols_auto + symbols_limit_auto - (1+32+1+4+1+4)
		ret

write_symbols_level:

		mov	[symbol_ptr_hash],	offset symbols_level_hash
		mov	[symbol_ptr],		offset symbols_level
		mov	[symbol_ptr_limit],	offset symbols_level + symbols_limit_level - (1+32+1+4+1+4)
		ret

write_symbols_param:

		mov	[symbol_ptr_hash],	offset symbols_param_hash
		mov	[symbol_ptr],		offset symbols_param
		mov	[symbol_ptr_limit],	offset symbols_param + symbols_limit_param - (1+32+1+4+1+4)
		ret

write_symbols_main:

		mov	[symbol_ptr_hash],	offset symbols_main_hash
		mov	[symbol_ptr],		offset symbols_main
		mov	[symbol_ptr_limit],	offset symbols_main + symbols_limit_main - (1+32+1+4+1+4)
		ret

write_symbols_local:

		mov	[symbol_ptr_hash],	offset symbols_local_hash
		mov	[symbol_ptr],		offset symbols_local
		mov	[symbol_ptr_limit],	offset symbols_local + symbols_limit_local - (1+32+1+4+1+4)
		ret

write_symbols_inline:

		mov	[symbol_ptr_hash],	offset symbols_inline_hash
		mov	[symbol_ptr],		offset symbols_inline
		mov	[symbol_ptr_limit],	offset symbols_inline + symbols_limit_inline - (1+32+1+4+1+4)
		ret
;
;
; Enter symbol2 into symbol table
; symbol2 must hold name, terminated with 0
; al must hold type
; ebx must hold value
;
enter_symbol2:	push	eax
		push	ecx
		push	edx
		push	esi
		push	edi

		push	eax			;save type

		mov	edi,[symbol_ptr]	;get symbol record pointer
		cmp	edi,[symbol_ptr_limit]	;make sure symbol table has enough room for another symbol
		jae	error_stif

		lea	esi,[symbol2]		;hash symbol2 name to get length and hash index
		call	hash_symbol
		add	edx,[symbol_ptr_hash]	;get pointer to hash table
		jmp	@@check			;append new record

@@skip:		mov	edx,eax			;point to next record
		movzx	eax,[byte edx]		;skip over record
		add	eax,1+4+1		;account for length byte, (symbol length in eax), value long, type byte
		add	edx,eax
@@check:	mov	eax,[edx]		;check link
		or	eax,eax
		jnz	@@skip			;if not zero, skip again

		mov	[edx],edi		;link and enter record
		mov	al,cl			;enter symbol length
		stosb
	rep	movsb				;enter symbol name with terminating zero
		mov	eax,ebx			;enter symbol value
		stosd
		pop	eax			;enter symbol type
		stosb
		xor	eax,eax			;enter new link terminator
		stosd

		mov	[symbol_ptr],edi

		pop	edi
		pop	esi
		pop	edx
		pop	ecx
		pop	eax
		ret
;
;
; Find symbol in param symbol table
; symbol must hold name, terminated with 0
; if found, eax=type and ebx=value
; if not found, eax=0 (type_undefined) and ebx=0
;
find_param:	push	ecx
		push	edx
		push	esi
		push	edi

		lea	esi,[symbol]		;hash symbol, ecx=length, edx=hash index
		call	hash_symbol

		mov	ebx,offset symbols_param_hash		;search param symbols
		call	check_symbol
		jnc	@@found

		xor	eax,eax			;symbol not found
		xor	ebx,ebx

@@found:	pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret
;
;
; Find symbol in symbol tables
; symbol must hold name, terminated with 0
; if found, eax=type and ebx=value
; if not found, eax=0 (type_undefined) and ebx=0
;
find_symbol:	push	ecx
		push	edx
		push	esi
		push	edi

		lea	esi,[symbol]		;hash symbol, ecx=length, edx=hash index
		call	hash_symbol

		mov	ebx,offset symbols_pre_hash		;search only preprocessor symbols?
		cmp	ebx,[symbol_ptr_hash]
		jne	@@notpre
		call	check_symbol
		jnc	@@found
		jmp	@@notfound
@@notpre:
		mov	ebx,offset symbols_auto_hash		;search auto symbols
		call	check_symbol
		jnc	@@found

		mov	ebx,offset symbols_level_hash		;search spin2 level symbols
		call	check_symbol
		jnc	@@found

		mov	ebx,offset symbols_main_hash		;search main symbols
		call	check_symbol
		jnc	@@found

		mov	ebx,offset symbols_local_hash		;search local symbols
		call	check_symbol
		jnc	@@found

		mov	ebx,offset symbols_inline_hash		;search inline symbols
		call	check_symbol
		jnc	@@found

@@notfound:	xor	eax,eax			;symbol not found
		xor	ebx,ebx

@@found:	pop	edi
		pop	esi
		pop	edx
		pop	ecx
		ret
;
;
; Check for symbol
; ebx must point to symbol table
; ecx must hold symbol length
; edx must hold symbol hash index
; esi must point to symbol
; if found, eax=type and ebx=value
; if not found, eax=0 (type_undefined) and ebx=0
;
check_symbol:	push	edx			;preserve hash table index
		add	edx,ebx			;get hash table pointer

		mov	[symbol_exists],0	;clear symbol-exists flag

@@link:		mov	edx,[edx]		;check for symbol record
		cmp	edx,1			;if record < 1 then c=1
		jc	@@nope			;if no record, symbol not found, c=1

		movzx	eax,[byte edx]		;get symbol length
		inc	edx			;point edi to symbol
		mov	edi,edx
		add	edx,eax			;point edx to next link
		add	edx,4+1
		cmp	eax,ecx			;if symbol size mismatch, check next link
		jne	@@link

		push	ecx			;symbol size match, compare symbol names
		push	esi
	repe	cmpsb				;c=0 if match
		pop	esi
		pop	ecx
		jne	@@link			;if names mismatch, check next link

		mov	ebx,[edx-1-4]		;found symbol, get value
		movzx	eax,[byte edx-1]	;get type

		mov	[symbol_exists],1	;set symbol-exists flag and save ptr
		mov	[symbol_exists_ptr],edx	;c=0

@@nope:		pop	edx
		ret
;
;
; Hash symbol at esi
; on exit:
;	ecx = symbol length, including terminating zero
;	edx = hash index
;
hash_symbol:	push	eax
		push	esi			;save symbol pointer

		xor	ecx,ecx			;reset symbol length
		xor	edx,edx			;reset hash

@@hash:		xor	eax,eax			;get symbol chr into eax
		lodsb
		inc	ecx			;inc length
		cmp	al,0			;if chr = 0, finish hash
		je	@@finish
		add	edx,eax			;hash += chr
		mov	eax,edx			;hash += (hash << 10)
		shl	eax,10
		add	edx,eax
		mov	eax,edx			;hash ^= (hash >> 6)
		shr	eax,6
		xor	edx,eax
		jmp	@@hash			;next chr

@@finish:	mov	eax,edx			;hash += (hash << 3)
		shl	eax,3
		add	edx,eax
		mov	eax,edx			;hash ^= (hash >> 11)
		shr	eax,11
		xor	edx,eax
		mov	eax,edx			;hash += (hash << 15)
		shl	eax,15
		add	edx,eax

		mov	eax,edx			;make 12-bit hash index
		ror	eax,16
		xor	edx,eax
		mov	eax,edx
		shr	eax,32-4
		xor	edx,eax
		and	edx,0FFFh
		shl	edx,2

		pop	esi			;restore symbol pointer, ecx=symbol length, edx=hash index
		pop	eax
		ret
;
;
; Backup symbol to symbol2
;
backup_symbol:	push	ecx
		push	esi
		push	edi

		lea	esi,[symbol]
		lea	edi,[symbol2]
		mov	ecx,symbol_size_limit+2
	rep	movsb

		pop	edi
		pop	esi
		pop	ecx
		ret
;
;
; Get symbol length into ecx
; edi must point to symbol
;
measure_symbol:	xor	ecx,ecx
		dec	ecx
		mov	al,0
	repne	scasb
		not	ecx
		dec	ecx

		ret
;
;
; Enter symbol2 after printing it
;
enter_symbol2_print:

		call	print_symbol2
		jmp	enter_symbol2
;
;
; Find non-word 3-chr symbol
;
find_symbol_s3:	syms	':=:',	type_swap,	0

		syms	'+//',	type_op,	oc_remu
		syms	'+<=',	type_op,	oc_lteu
		syms	'+>=',	type_op,	oc_gteu
		syms	'<=>',	type_op,	oc_ltegt

		syms	'<>.',	type_op,	oc_fne
		syms	'==.',	type_op,	oc_fe
		syms	'<=.',	type_op,	oc_flte
		syms	'>=.',	type_op,	oc_fgte

		ret
;
;
; Find non-word 2-chr symbol
;
find_symbol_s2:	syms	':=',	type_assign,	0
		syms	'@@',	type_atat,	0
		syms	'^@',	type_upat	0
		syms	'..',	type_dotdot,	0
		syms	'~~',	type_tiltil,	0
		syms	'++',	type_inc,	0
		syms	'--',	type_dec,	0
		syms	'??',	type_rnd,	0

		syms	'>>',	type_op,	oc_shr
		syms	'<<',	type_op,	oc_shl
		syms	'+/',	type_op,	oc_divu
		syms	'//',	type_op,	oc_rem
		syms	'#>',	type_op,	oc_fge
		syms	'<#',	type_op,	oc_fle
		syms	'+<',	type_op,	oc_ltu
		syms	'<=',	type_op,	oc_lte
		syms	'==',	type_op,	oc_e
		syms	'<>',	type_op,	oc_ne
		syms	'>=',	type_op,	oc_gte
		syms	'+>',	type_op,	oc_gtu
		syms	'!!',	type_op,	oc_lognot
		syms	'&&',	type_op,	oc_logand
		syms	'^^',	type_op,	oc_logxor
		syms	'||',	type_op,	oc_logor

;		syms	'-.',	type_op,	oc_fneg		(uses oc_fsub symbol)
		syms	'<.',	type_op,	oc_flt
		syms	'>.',	type_op,	oc_fgt
		syms	'+.',	type_op,	oc_fadd
		syms	'-.',	type_op,	oc_fsub
		syms	'*.',	type_op,	oc_fmul
		syms	'/.',	type_op,	oc_fdiv

		ret
;
;
; Find non-word 1-chr symbol
;
find_symbol_s1:	syms	'(',	type_left,	0
		syms	')',	type_right,	0
		syms	'[',	type_leftb,	0
		syms	']',	type_rightb,	0
		syms	',',	type_comma,	0
		syms	'=',	type_equal,	0
		syms	'#',	type_pound,	0
		syms	':',	type_colon,	0
		syms	'\',	type_back,	0
		syms	'.',	type_dot,	0
		syms	'@',	type_at,	0
		syms	'~',	type_til,	0
		syms	'`',	type_tick,	0

		syms	'!',	type_op,	oc_bitnot
;		syms	'-',	type_op,	oc_neg		(uses oc_sub symbol)
		syms	'&',	type_op,	oc_bitand
		syms	'^',	type_op,	oc_bitxor
		syms	'|',	type_op,	oc_bitor
		syms	'*',	type_op,	oc_mul
		syms	'/',	type_op,	oc_div
		syms	'+',	type_op,	oc_add
		syms	'-',	type_op,	oc_sub
		syms	'<',	type_op,	oc_lt
		syms	'>',	type_op,	oc_gt
		syms	'?',	type_op,	oc_ternary

		ret
;
;
; Preprocessor symbols
;
preprocessor_symbols_debug:

	sym	type_pre_symbol,	1,		'__DEBUG__'

preprocessor_symbols:

	sym	type_pre_symbol,	1,		'__PNUT__'
	sym	type_pre_command,	pre_define,	'DEFINE'
	sym	type_pre_command,	pre_undef,	'UNDEF'
	sym	type_pre_command,	pre_ifdef,	'IFDEF'
	sym	type_pre_command,	pre_ifndef,	'IFNDEF'
	sym	type_pre_command,	pre_elseifdef,	'ELSEIFDEF'
	sym	type_pre_command,	pre_elseifndef,	'ELSEIFNDEF'
	sym	type_pre_command,	pre_else,	'ELSE'
	sym	type_pre_command,	pre_endif,	'ENDIF'

	db	0
;
;
; Automatic symbols
;
automatic_symbols:

	sym	type_op,		oc_abs,		'ABS'		;(also asm instruction)
	sym	type_op,		oc_fabs,	'FABS'
	sym	type_op,		oc_encod,	'ENCOD'		;(also asm instruction)
	sym	type_op,		oc_decod,	'DECOD'		;(also asm instruction)
	sym	type_op,		oc_bmask,	'BMASK'		;(also asm instruction)
	sym	type_op,		oc_ones,	'ONES'		;(also asm instruction)
	sym	type_op,		oc_sqrt,	'SQRT'
	sym	type_op,		oc_fsqrt,	'FSQRT'
	sym	type_op,		oc_qlog,	'QLOG'		;(also asm instruction)
	sym	type_op,		oc_qexp,	'QEXP'		;(also asm instruction)
	sym	type_op,		oc_sar,		'SAR'		;(also asm instruction)
	sym	type_op,		oc_ror,		'ROR'		;(also asm instruction)
	sym	type_op,		oc_rol,		'ROL'		;(also asm instruction)
	sym	type_op,		oc_rev,		'REV'		;(also asm instruction)
	sym	type_op,		oc_zerox,	'ZEROX'		;(also asm instruction)
	sym	type_op,		oc_signx,	'SIGNX'		;(also asm instruction)
	sym	type_op,		oc_sca,		'SCA'		;(also asm instruction)
	sym	type_op,		oc_scas,	'SCAS'		;(also asm instruction)
	sym	type_op,		oc_frac,	'FRAC'
	sym	type_op,		oc_addbits,	'ADDBITS'
	sym	type_op,		oc_addpins,	'ADDPINS'
	sym	type_op,		oc_lognot_name,	'NOT'		;(also asm instruction)
	sym	type_op,		oc_logand_name,	'AND'		;(also asm instruction)
	sym	type_op,		oc_logxor_name,	'XOR'		;(also asm instruction)
	sym	type_op,		oc_logor_name,	'OR'		;(also asm instruction)


	sym	type_float,		0,		'FLOAT'		;floating-point operators
	sym	type_round,		0,		'ROUND'
	sym	type_trunc,		0,		'TRUNC'

	sym	type_constr,		0,		'STRING'	;string expressions

	sym	type_block,		block_con,	'CON'		;block designators
	sym	type_block,		block_obj,	'OBJ'
	sym	type_block,		block_var,	'VAR'
	sym	type_block,		block_pub,	'PUB'
	sym	type_block,		block_pri,	'PRI'
	sym	type_block,		block_dat,	'DAT'

	sym	type_field,		0,		'FIELD'		;field

	sym	type_size,		0,		'BYTE'		;size
	sym	type_size,		1,		'WORD'
	sym	type_size,		2,		'LONG'

	sym	type_size_fit,		0,		'BYTEFIT'	;size fits
	sym	type_size_fit,		1,		'WORDFIT'

	sym	type_fvar,		0,		'FVAR'		;fvar
	sym	type_fvar,		1,		'FVARS'

	sym	type_file,		0,		'FILE'		;file-related

	sym	type_if,		0,		'IF'		;high-level flow-control structures
	sym	type_ifnot,		0,		'IFNOT'
	sym	type_elseif,		0,		'ELSEIF'
	sym	type_elseifnot,		0,		'ELSEIFNOT'
	sym	type_else,		0,		'ELSE'
	sym	type_case,		0,		'CASE'
	sym	type_case_fast,		0,		'CASE_FAST'
	sym	type_other,		0,		'OTHER'
	sym	type_repeat,		0,		'REPEAT'
	sym	type_while,		0,		'WHILE'
	sym	type_until,		0,		'UNTIL'
	sym	type_from,		0,		'FROM'
	sym	type_to,		0,		'TO'
	sym	type_step,		0,		'STEP'
	sym	type_with,		0,		'WITH'

	sym	type_i_next_quit,	0,		'NEXT'		;high-level instructions
	sym	type_i_next_quit,	1,		'QUIT'
	sym	type_i_return,		0,		'RETURN'
	sym	type_i_abort,		0,		'ABORT'
	sym	type_i_look,		00b,		'LOOKUPZ'
	sym	type_i_look,		01b,		'LOOKUP'
	sym	type_i_look,		10b,		'LOOKDOWNZ'
	sym	type_i_look,		11b,		'LOOKDOWN'
	sym	type_i_cogspin,		0,		'COGSPIN'
	sym	type_recv,		0,		'RECV'
	sym	type_send,		0,		'SEND'

	sym	type_debug,		0,		'DEBUG'		;debug

	sym	type_debug_cmd,		dc_dly,		'DLY'		;debug commands
	sym	type_debug_cmd,		dc_pc_key,	'PC_KEY'
	sym	type_debug_cmd,		dc_pc_mouse,	'PC_MOUSE'

	sym	type_debug_cmd,		00100100b,	'ZSTR'
	sym	type_debug_cmd,		00100110b,	'ZSTR_'
	sym	type_debug_cmd,		00101100b,	'FDEC'
	sym	type_debug_cmd,		00101110b,	'FDEC_'
	sym	type_debug_cmd,		00110000b,	'FDEC_REG_ARRAY'
	sym	type_debug_cmd,		00110010b,	'FDEC_REG_ARRAY_'
	sym	type_debug_cmd,		00110100b,	'LSTR'
	sym	type_debug_cmd,		00110110b,	'LSTR_'
	sym	type_debug_cmd,		00111100b,	'FDEC_ARRAY'
	sym	type_debug_cmd,		00111110b,	'FDEC_ARRAY_'

	sym	type_debug_cmd,		01000000b,	'UDEC'
	sym	type_debug_cmd,		01000010b,	'UDEC_'
	sym	type_debug_cmd,		01000100b,	'UDEC_BYTE'
	sym	type_debug_cmd,		01000110b,	'UDEC_BYTE_'
	sym	type_debug_cmd,		01001000b,	'UDEC_WORD'
	sym	type_debug_cmd,		01001010b,	'UDEC_WORD_'
	sym	type_debug_cmd,		01001100b,	'UDEC_LONG'
	sym	type_debug_cmd,		01001110b,	'UDEC_LONG_'
	sym	type_debug_cmd,		01010000b,	'UDEC_REG_ARRAY'
	sym	type_debug_cmd,		01010010b,	'UDEC_REG_ARRAY_'
	sym	type_debug_cmd,		01010100b,	'UDEC_BYTE_ARRAY'
	sym	type_debug_cmd,		01010110b,	'UDEC_BYTE_ARRAY_'
	sym	type_debug_cmd,		01011000b,	'UDEC_WORD_ARRAY'
	sym	type_debug_cmd,		01011010b,	'UDEC_WORD_ARRAY_'
	sym	type_debug_cmd,		01011100b,	'UDEC_LONG_ARRAY'
	sym	type_debug_cmd,		01011110b,	'UDEC_LONG_ARRAY_'

	sym	type_debug_cmd,		01100000b,	'SDEC'
	sym	type_debug_cmd,		01100010b,	'SDEC_'
	sym	type_debug_cmd,		01100100b,	'SDEC_BYTE'
	sym	type_debug_cmd,		01100110b,	'SDEC_BYTE_'
	sym	type_debug_cmd,		01101000b,	'SDEC_WORD'
	sym	type_debug_cmd,		01101010b,	'SDEC_WORD_'
	sym	type_debug_cmd,		01101100b,	'SDEC_LONG'
	sym	type_debug_cmd,		01101110b,	'SDEC_LONG_'
	sym	type_debug_cmd,		01110000b,	'SDEC_REG_ARRAY'
	sym	type_debug_cmd,		01110010b,	'SDEC_REG_ARRAY_'
	sym	type_debug_cmd,		01110100b,	'SDEC_BYTE_ARRAY'
	sym	type_debug_cmd,		01110110b,	'SDEC_BYTE_ARRAY_'
	sym	type_debug_cmd,		01111000b,	'SDEC_WORD_ARRAY'
	sym	type_debug_cmd,		01111010b,	'SDEC_WORD_ARRAY_'
	sym	type_debug_cmd,		01111100b,	'SDEC_LONG_ARRAY'
	sym	type_debug_cmd,		01111110b,	'SDEC_LONG_ARRAY_'

	sym	type_debug_cmd,		10000000b,	'UHEX'
	sym	type_debug_cmd,		10000010b,	'UHEX_'
	sym	type_debug_cmd,		10000100b,	'UHEX_BYTE'
	sym	type_debug_cmd,		10000110b,	'UHEX_BYTE_'
	sym	type_debug_cmd,		10001000b,	'UHEX_WORD'
	sym	type_debug_cmd,		10001010b,	'UHEX_WORD_'
	sym	type_debug_cmd,		10001100b,	'UHEX_LONG'
	sym	type_debug_cmd,		10001110b,	'UHEX_LONG_'
	sym	type_debug_cmd,		10010000b,	'UHEX_REG_ARRAY'
	sym	type_debug_cmd,		10010010b,	'UHEX_REG_ARRAY_'
	sym	type_debug_cmd,		10010100b,	'UHEX_BYTE_ARRAY'
	sym	type_debug_cmd,		10010110b,	'UHEX_BYTE_ARRAY_'
	sym	type_debug_cmd,		10011000b,	'UHEX_WORD_ARRAY'
	sym	type_debug_cmd,		10011010b,	'UHEX_WORD_ARRAY_'
	sym	type_debug_cmd,		10011100b,	'UHEX_LONG_ARRAY'
	sym	type_debug_cmd,		10011110b,	'UHEX_LONG_ARRAY_'

	sym	type_debug_cmd,		10100000b,	'SHEX'
	sym	type_debug_cmd,		10100010b,	'SHEX_'
	sym	type_debug_cmd,		10100100b,	'SHEX_BYTE'
	sym	type_debug_cmd,		10100110b,	'SHEX_BYTE_'
	sym	type_debug_cmd,		10101000b,	'SHEX_WORD'
	sym	type_debug_cmd,		10101010b,	'SHEX_WORD_'
	sym	type_debug_cmd,		10101100b,	'SHEX_LONG'
	sym	type_debug_cmd,		10101110b,	'SHEX_LONG_'
	sym	type_debug_cmd,		10110000b,	'SHEX_REG_ARRAY'
	sym	type_debug_cmd,		10110010b,	'SHEX_REG_ARRAY_'
	sym	type_debug_cmd,		10110100b,	'SHEX_BYTE_ARRAY'
	sym	type_debug_cmd,		10110110b,	'SHEX_BYTE_ARRAY_'
	sym	type_debug_cmd,		10111000b,	'SHEX_WORD_ARRAY'
	sym	type_debug_cmd,		10111010b,	'SHEX_WORD_ARRAY_'
	sym	type_debug_cmd,		10111100b,	'SHEX_LONG_ARRAY'
	sym	type_debug_cmd,		10111110b,	'SHEX_LONG_ARRAY_'

	sym	type_debug_cmd,		11000000b,	'UBIN'
	sym	type_debug_cmd,		11000010b,	'UBIN_'
	sym	type_debug_cmd,		11000100b,	'UBIN_BYTE'
	sym	type_debug_cmd,		11000110b,	'UBIN_BYTE_'
	sym	type_debug_cmd,		11001000b,	'UBIN_WORD'
	sym	type_debug_cmd,		11001010b,	'UBIN_WORD_'
	sym	type_debug_cmd,		11001100b,	'UBIN_LONG'
	sym	type_debug_cmd,		11001110b,	'UBIN_LONG_'
	sym	type_debug_cmd,		11010000b,	'UBIN_REG_ARRAY'
	sym	type_debug_cmd,		11010010b,	'UBIN_REG_ARRAY_'
	sym	type_debug_cmd,		11010100b,	'UBIN_BYTE_ARRAY'
	sym	type_debug_cmd,		11010110b,	'UBIN_BYTE_ARRAY_'
	sym	type_debug_cmd,		11011000b,	'UBIN_WORD_ARRAY'
	sym	type_debug_cmd,		11011010b,	'UBIN_WORD_ARRAY_'
	sym	type_debug_cmd,		11011100b,	'UBIN_LONG_ARRAY'
	sym	type_debug_cmd,		11011110b,	'UBIN_LONG_ARRAY_'

	sym	type_debug_cmd,		11100000b,	'SBIN'
	sym	type_debug_cmd,		11100010b,	'SBIN_'
	sym	type_debug_cmd,		11100100b,	'SBIN_BYTE'
	sym	type_debug_cmd,		11100110b,	'SBIN_BYTE_'
	sym	type_debug_cmd,		11101000b,	'SBIN_WORD'
	sym	type_debug_cmd,		11101010b,	'SBIN_WORD_'
	sym	type_debug_cmd,		11101100b,	'SBIN_LONG'
	sym	type_debug_cmd,		11101110b,	'SBIN_LONG_'
	sym	type_debug_cmd,		11110000b,	'SBIN_REG_ARRAY'
	sym	type_debug_cmd,		11110010b,	'SBIN_REG_ARRAY_'
	sym	type_debug_cmd,		11110100b,	'SBIN_BYTE_ARRAY'
	sym	type_debug_cmd,		11110110b,	'SBIN_BYTE_ARRAY_'
	sym	type_debug_cmd,		11111000b,	'SBIN_WORD_ARRAY'
	sym	type_debug_cmd,		11111010b,	'SBIN_WORD_ARRAY_'
	sym	type_debug_cmd,		11111100b,	'SBIN_LONG_ARRAY'
	sym	type_debug_cmd,		11111110b,	'SBIN_LONG_ARRAY_'


	sym	type_asm_end,		0,		'END'		;misc
	sym	type_under,		0,		'_'


	sym	type_i_flex,		fc_hubset,	'HUBSET'	;(also asm instruction)

	sym	type_i_flex,		fc_coginit,	'COGINIT'	;(also asm instruction)
	sym	type_i_flex,		fc_cogstop,	'COGSTOP'	;(also asm instruction)
	sym	type_i_flex,		fc_cogid,	'COGID'		;(also asm instruction)
	sym	type_i_flex,		fc_cogchk,	'COGCHK'

	sym	type_i_flex,		fc_getrnd,	'GETRND'	;(also asm instruction)
	sym	type_i_flex,		fc_getct,	'GETCT'		;(also asm instruction)
	sym	type_i_flex,		fc_pollct,	'POLLCT'
	sym	type_i_flex,		fc_waitct,	'WAITCT'

	sym	type_i_flex,		fc_pinwrite,	'PINWRITE'
	sym	type_i_flex,		fc_pinwrite,	'PINW'
	sym	type_i_flex,		fc_pinlow,	'PINLOW'
	sym	type_i_flex,		fc_pinlow,	'PINL'
	sym	type_i_flex,		fc_pinhigh,	'PINHIGH'
	sym	type_i_flex,		fc_pinhigh,	'PINH'
	sym	type_i_flex,		fc_pintoggle,	'PINTOGGLE'
	sym	type_i_flex,		fc_pintoggle,	'PINT'
	sym	type_i_flex,		fc_pinfloat,	'PINFLOAT'
	sym	type_i_flex,		fc_pinfloat,	'PINF'
	sym	type_i_flex,		fc_pinread,	'PINREAD'
	sym	type_i_flex,		fc_pinread,	'PINR'

	sym	type_i_flex,		fc_pinstart,	'PINSTART'
	sym	type_i_flex,		fc_pinclear,	'PINCLEAR'

	sym	type_i_flex,		fc_wrpin,	'WRPIN'		;(also asm instruction)
	sym	type_i_flex,		fc_wxpin,	'WXPIN'		;(also asm instruction)
	sym	type_i_flex,		fc_wypin,	'WYPIN'		;(also asm instruction)
	sym	type_i_flex,		fc_akpin,	'AKPIN'		;(also asm instruction)
	sym	type_i_flex,		fc_rdpin,	'RDPIN'		;(also asm instruction)
	sym	type_i_flex,		fc_rqpin,	'RQPIN'		;(also asm instruction)

	sym	type_i_flex,		fc_rotxy,	'ROTXY'
	sym	type_i_flex,		fc_polxy,	'POLXY'
	sym	type_i_flex,		fc_xypol,	'XYPOL'

	sym	type_i_flex,		fc_locknew,	'LOCKNEW'	;(also asm instruction)
	sym	type_i_flex,		fc_lockret,	'LOCKRET'	;(also asm instruction)
	sym	type_i_flex,		fc_locktry,	'LOCKTRY'	;(also asm instruction)
	sym	type_i_flex,		fc_lockrel,	'LOCKREL'	;(also asm instruction)
	sym	type_i_flex,		fc_lockchk,	'LOCKCHK'

	sym	type_i_flex,		fc_cogatn,	'COGATN'	;(also asm instruction)
	sym	type_i_flex,		fc_pollatn,	'POLLATN'	;(also asm instruction)
	sym	type_i_flex,		fc_waitatn,	'WAITATN'	;(also asm instruction)

	sym	type_i_flex,		fc_clkset,	'CLKSET'
	sym	type_i_flex,		fc_regexec,	'REGEXEC'
	sym	type_i_flex,		fc_regload,	'REGLOAD'
	sym	type_i_flex,		fc_call,	'CALL'		;(also asm instruction)
	sym	type_i_flex,		fc_getregs,	'GETREGS'
	sym	type_i_flex,		fc_setregs,	'SETREGS'

	sym	type_i_flex,		fc_bytefill,	'BYTEFILL'
	sym	type_i_flex,		fc_bytemove,	'BYTEMOVE'
	sym	type_i_flex,		fc_wordfill,	'WORDFILL'
	sym	type_i_flex,		fc_wordmove,	'WORDMOVE'
	sym	type_i_flex,		fc_longfill,	'LONGFILL'
	sym	type_i_flex,		fc_longmove,	'LONGMOVE'

	sym	type_i_flex,		fc_strsize,	'STRSIZE'
	sym	type_i_flex,		fc_strcomp,	'STRCOMP'
	sym	type_i_flex,		fc_strcopy,	'STRCOPY'

	sym	type_i_flex,		fc_getcrc,	'GETCRC'

	sym	type_i_flex,		fc_waitus,	'WAITUS'
	sym	type_i_flex,		fc_waitms,	'WAITMS'
	sym	type_i_flex,		fc_getms,	'GETMS'
	sym	type_i_flex,		fc_getsec,	'GETSEC'
	sym	type_i_flex,		fc_muldiv64,	'MULDIV64'
	sym	type_i_flex,		fc_qsin,	'QSIN'
	sym	type_i_flex,		fc_qcos,	'QCOS'

	sym	type_i_flex,		fc_nan,		'NAN'


	sym	type_asm_dir,		dir_orgh,	'ORGH'		;assembly directives
	sym	type_asm_dir,		dir_alignw,	'ALIGNW'
	sym	type_asm_dir,		dir_alignl,	'ALIGNL'
	sym	type_asm_dir,		dir_org,	'ORG'
	sym	type_asm_dir,		dir_orgf,	'ORGF'
	sym	type_asm_dir,		dir_res,	'RES'
	sym	type_asm_dir,		dir_fit,	'FIT'

	sym	type_asm_cond,		if_ret,		'_RET_'		;assembly conditionals
	sym	type_asm_cond,		if_nc_and_nz,	'IF_NC_AND_NZ'
	sym	type_asm_cond,		if_nc_and_nz,	'IF_NZ_AND_NC'
	sym	type_asm_cond,		if_nc_and_nz,	'IF_GT'
	sym	type_asm_cond,		if_nc_and_nz,	'IF_A'
	sym	type_asm_cond,		if_nc_and_z,	'IF_NC_AND_Z'
	sym	type_asm_cond,		if_nc_and_z,	'IF_Z_AND_NC'
	sym	type_asm_cond,		if_nc,		'IF_NC'
	sym	type_asm_cond,		if_nc,		'IF_GE'
	sym	type_asm_cond,		if_nc,		'IF_AE'
	sym	type_asm_cond,		if_c_and_nz,	'IF_C_AND_NZ'
	sym	type_asm_cond,		if_c_and_nz,	'IF_NZ_AND_C'
	sym	type_asm_cond,		if_nz,		'IF_NZ'
	sym	type_asm_cond,		if_nz,		'IF_NE'
	sym	type_asm_cond,		if_c_ne_z,	'IF_C_NE_Z'
	sym	type_asm_cond,		if_c_ne_z,	'IF_Z_NE_C'
	sym	type_asm_cond,		if_nc_or_nz,	'IF_NC_OR_NZ'
	sym	type_asm_cond,		if_nc_or_nz,	'IF_NZ_OR_NC'
	sym	type_asm_cond,		if_c_and_z,	'IF_C_AND_Z'
	sym	type_asm_cond,		if_c_and_z,	'IF_Z_AND_C'
	sym	type_asm_cond,		if_c_eq_z,	'IF_C_EQ_Z'
	sym	type_asm_cond,		if_c_eq_z,	'IF_Z_EQ_C'
	sym	type_asm_cond,		if_z,		'IF_Z'
	sym	type_asm_cond,		if_z,		'IF_E'
	sym	type_asm_cond,		if_nc_or_z,	'IF_NC_OR_Z'
	sym	type_asm_cond,		if_nc_or_z,	'IF_Z_OR_NC'
	sym	type_asm_cond,		if_c,		'IF_C'
	sym	type_asm_cond,		if_c,		'IF_LT'
	sym	type_asm_cond,		if_c,		'IF_B'
	sym	type_asm_cond,		if_c_or_nz,	'IF_C_OR_NZ'
	sym	type_asm_cond,		if_c_or_nz,	'IF_NZ_OR_C'
	sym	type_asm_cond,		if_c_or_z,	'IF_C_OR_Z'
	sym	type_asm_cond,		if_c_or_z,	'IF_Z_OR_C'
	sym	type_asm_cond,		if_c_or_z,	'IF_LE'
	sym	type_asm_cond,		if_c_or_z,	'IF_BE'
	sym	type_asm_cond,		if_always,	'IF_ALWAYS'

	sym	type_asm_cond,		if_nc_and_nz,	'IF_00'
	sym	type_asm_cond,		if_nc_and_z,	'IF_01'
	sym	type_asm_cond,		if_c_and_nz,	'IF_10'
	sym	type_asm_cond,		if_c_and_z,	'IF_11'
	sym	type_asm_cond,		if_nz,		'IF_X0'
	sym	type_asm_cond,		if_z,		'IF_X1'
	sym	type_asm_cond,		if_nc,		'IF_0X'
	sym	type_asm_cond,		if_c,		'IF_1X'
	sym	type_asm_cond,		if_c_or_z,	'IF_NOT_00'
	sym	type_asm_cond,		if_c_or_nz,	'IF_NOT_01'
	sym	type_asm_cond,		if_nc_or_z,	'IF_NOT_10'
	sym	type_asm_cond,		if_nc_or_nz,	'IF_NOT_11'
	sym	type_asm_cond,		if_c_eq_z,	'IF_SAME'
	sym	type_asm_cond,		if_c_ne_z,	'IF_DIFF'

	sym	type_asm_cond,		0000b,		'IF_0000'
	sym	type_asm_cond,		0001b,		'IF_0001'
	sym	type_asm_cond,		0010b,		'IF_0010'
	sym	type_asm_cond,		0011b,		'IF_0011'
	sym	type_asm_cond,		0100b,		'IF_0100'
	sym	type_asm_cond,		0101b,		'IF_0101'
	sym	type_asm_cond,		0110b,		'IF_0110'
	sym	type_asm_cond,		0111b,		'IF_0111'
	sym	type_asm_cond,		1000b,		'IF_1000'
	sym	type_asm_cond,		1001b,		'IF_1001'
	sym	type_asm_cond,		1010b,		'IF_1010'
	sym	type_asm_cond,		1011b,		'IF_1011'
	sym	type_asm_cond,		1100b,		'IF_1100'
	sym	type_asm_cond,		1101b,		'IF_1101'
	sym	type_asm_cond,		1110b,		'IF_1110'
	sym	type_asm_cond,		1111b,		'IF_1111'

									;assembly instructions

;	sym	type_asm_inst,		ac_ror,		'ROR'		(declared as type_op)
;	sym	type_asm_inst,		ac_rol,		'ROL'		(declared as type_op)
	sym	type_asm_inst,		ac_shr,		'SHR'
	sym	type_asm_inst,		ac_shl,		'SHL'
	sym	type_asm_inst,		ac_rcr,		'RCR'
	sym	type_asm_inst,		ac_rcl,		'RCL'
;	sym	type_asm_inst,		ac_sar,		'SAR'		(declared as type_op)
	sym	type_asm_inst,		ac_sal,		'SAL'

	sym	type_asm_inst,		ac_add,		'ADD'
	sym	type_asm_inst,		ac_addx,	'ADDX'
	sym	type_asm_inst,		ac_adds,	'ADDS'
	sym	type_asm_inst,		ac_addsx,	'ADDSX'

	sym	type_asm_inst,		ac_sub,		'SUB'
	sym	type_asm_inst,		ac_subx,	'SUBX'
	sym	type_asm_inst,		ac_subs,	'SUBS'
	sym	type_asm_inst,		ac_subsx,	'SUBSX'

	sym	type_asm_inst,		ac_cmp,		'CMP'
	sym	type_asm_inst,		ac_cmpx,	'CMPX'
	sym	type_asm_inst,		ac_cmps,	'CMPS'
	sym	type_asm_inst,		ac_cmpsx,	'CMPSX'

	sym	type_asm_inst,		ac_cmpr,	'CMPR'
	sym	type_asm_inst,		ac_cmpm,	'CMPM'
	sym	type_asm_inst,		ac_subr,	'SUBR'
	sym	type_asm_inst,		ac_cmpsub,	'CMPSUB'

	sym	type_asm_inst,		ac_fge,		'FGE'
	sym	type_asm_inst,		ac_fle,		'FLE'
	sym	type_asm_inst,		ac_fges,	'FGES'
	sym	type_asm_inst,		ac_fles,	'FLES'

	sym	type_asm_inst,		ac_sumc,	'SUMC'
	sym	type_asm_inst,		ac_sumnc,	'SUMNC'
	sym	type_asm_inst,		ac_sumz,	'SUMZ'
	sym	type_asm_inst,		ac_sumnz,	'SUMNZ'

	sym	type_asm_inst,		ac_bitl,	'BITL'
	sym	type_asm_inst,		ac_bith,	'BITH'
	sym	type_asm_inst,		ac_bitc,	'BITC'
	sym	type_asm_inst,		ac_bitnc,	'BITNC'
	sym	type_asm_inst,		ac_bitz,	'BITZ'
	sym	type_asm_inst,		ac_bitnz,	'BITNZ'
	sym	type_asm_inst,		ac_bitrnd,	'BITRND'
	sym	type_asm_inst,		ac_bitnot,	'BITNOT'

	sym	type_asm_inst,		ac_testb,	'TESTB'
	sym	type_asm_inst,		ac_testbn,	'TESTBN'

;	sym	type_asm_inst,		ac_and,		'AND'		(declared as type_op)
	sym	type_asm_inst,		ac_andn,	'ANDN'
;	sym	type_asm_inst,		ac_or,		'OR'		(declared as type_op)
;	sym	type_asm_inst,		ac_xor,		'XOR'		(declared as type_op)

	sym	type_asm_inst,		ac_muxc,	'MUXC'
	sym	type_asm_inst,		ac_muxnc,	'MUXNC'
	sym	type_asm_inst,		ac_muxz,	'MUXZ'
	sym	type_asm_inst,		ac_muxnz,	'MUXNZ'

	sym	type_asm_inst,		ac_mov,		'MOV'
;	sym	type_asm_inst,		ac_not,		'NOT'		(declared as type_op)
;	sym	type_asm_inst,		ac_abs,		'ABS'		(declared as type_op)
	sym	type_asm_inst,		ac_neg,		'NEG'

	sym	type_asm_inst,		ac_negc,	'NEGC'
	sym	type_asm_inst,		ac_negnc,	'NEGNC'
	sym	type_asm_inst,		ac_negz,	'NEGZ'
	sym	type_asm_inst,		ac_negnz,	'NEGNZ'

	sym	type_asm_inst,		ac_incmod,	'INCMOD'
	sym	type_asm_inst,		ac_decmod,	'DECMOD'
;	sym	type_asm_inst,		ac_zerox,	'ZEROX'		(declared as type_op)
;	sym	type_asm_inst,		ac_signx,	'SIGNX'		(declared as type_op)

;	sym	type_asm_inst,		ac_encod,	'ENCOD'		(declared as type_op)
;	sym	type_asm_inst,		ac_ones,	'ONES'		(declared as type_op)
	sym	type_asm_inst,		ac_test,	'TEST'
	sym	type_asm_inst,		ac_testn,	'TESTN'

	sym	type_asm_inst,		ac_setnib,	'SETNIB'
	sym	type_asm_inst,		ac_getnib,	'GETNIB'
	sym	type_asm_inst,		ac_rolnib,	'ROLNIB'

	sym	type_asm_inst,		ac_setbyte,	'SETBYTE'
	sym	type_asm_inst,		ac_getbyte,	'GETBYTE'
	sym	type_asm_inst,		ac_rolbyte,	'ROLBYTE'

	sym	type_asm_inst,		ac_setword,	'SETWORD'
	sym	type_asm_inst,		ac_getword,	'GETWORD'
	sym	type_asm_inst,		ac_rolword,	'ROLWORD'

	sym	type_asm_inst,		ac_altsn,	'ALTSN'
	sym	type_asm_inst,		ac_altgn,	'ALTGN'
	sym	type_asm_inst,		ac_altsb,	'ALTSB'
	sym	type_asm_inst,		ac_altgb,	'ALTGB'
	sym	type_asm_inst,		ac_altsw,	'ALTSW'
	sym	type_asm_inst,		ac_altgw,	'ALTGW'
	sym	type_asm_inst,		ac_altr,	'ALTR'
	sym	type_asm_inst,		ac_altd,	'ALTD'
	sym	type_asm_inst,		ac_alts,	'ALTS'
	sym	type_asm_inst,		ac_altb,	'ALTB'
	sym	type_asm_inst,		ac_alti,	'ALTI'
	sym	type_asm_inst,		ac_setr,	'SETR'
	sym	type_asm_inst,		ac_setd,	'SETD'
	sym	type_asm_inst,		ac_sets,	'SETS'
;	sym	type_asm_inst,		ac_decod,	'DECOD'		(declared as type_op)
;	sym	type_asm_inst,		ac_bmask,	'BMASK'		(declared as type_op)
	sym	type_asm_inst,		ac_crcbit,	'CRCBIT'
	sym	type_asm_inst,		ac_crcnib,	'CRCNIB'
	sym	type_asm_inst,		ac_muxnits,	'MUXNITS'
	sym	type_asm_inst,		ac_muxnibs,	'MUXNIBS'
	sym	type_asm_inst,		ac_muxq,	'MUXQ'
	sym	type_asm_inst,		ac_movbyts,	'MOVBYTS'

	sym	type_asm_inst,		ac_mul,		'MUL'
	sym	type_asm_inst,		ac_muls,	'MULS'
;	sym	type_asm_inst,		ac_sca,		'SCA'		(declared as type_op)
;	sym	type_asm_inst,		ac_scas,	'SCAS'		(declared as type_op)

	sym	type_asm_inst,		ac_addpix,	'ADDPIX'
	sym	type_asm_inst,		ac_mulpix,	'MULPIX'
	sym	type_asm_inst,		ac_blnpix,	'BLNPIX'
	sym	type_asm_inst,		ac_mixpix,	'MIXPIX'

	sym	type_asm_inst,		ac_addct1,	'ADDCT1'
	sym	type_asm_inst,		ac_addct2,	'ADDCT2'
	sym	type_asm_inst,		ac_addct3,	'ADDCT3'
	sym	type_asm_inst,		ac_wmlong,	'WMLONG'

;	sym	type_asm_inst,		ac_rqpin,	'RQPIN'		(declared as type_i_flex)
;	sym	type_asm_inst,		ac_rdpin,	'RDPIN'		(declared as type_i_flex)
	sym	type_asm_inst,		ac_rdlut,	'RDLUT'

	sym	type_asm_inst,		ac_rdbyte,	'RDBYTE'
	sym	type_asm_inst,		ac_rdword,	'RDWORD'
	sym	type_asm_inst,		ac_rdlong,	'RDLONG'

	sym	type_asm_inst,		ac_callpa,	'CALLPA'
	sym	type_asm_inst,		ac_callpb,	'CALLPB'

	sym	type_asm_inst,		ac_djz,		'DJZ'
	sym	type_asm_inst,		ac_djnz,	'DJNZ'
	sym	type_asm_inst,		ac_djf,		'DJF'
	sym	type_asm_inst,		ac_djnf,	'DJNF'

	sym	type_asm_inst,		ac_ijz,		'IJZ'
	sym	type_asm_inst,		ac_ijnz,	'IJNZ'

	sym	type_asm_inst,		ac_tjz,		'TJZ'
	sym	type_asm_inst,		ac_tjnz,	'TJNZ'
	sym	type_asm_inst,		ac_tjf,		'TJF'
	sym	type_asm_inst,		ac_tjnf,	'TJNF'
	sym	type_asm_inst,		ac_tjs,		'TJS'
	sym	type_asm_inst,		ac_tjns,	'TJNS'
	sym	type_asm_inst,		ac_tjv,		'TJV'

	sym	type_asm_inst,		ac_jint,	'JINT'
	sym	type_asm_inst,		ac_jct1,	'JCT1'
	sym	type_asm_inst,		ac_jct2,	'JCT2'
	sym	type_asm_inst,		ac_jct3,	'JCT3'
	sym	type_asm_inst,		ac_jse1,	'JSE1'
	sym	type_asm_inst,		ac_jse2,	'JSE2'
	sym	type_asm_inst,		ac_jse3,	'JSE3'
	sym	type_asm_inst,		ac_jse4,	'JSE4'
	sym	type_asm_inst,		ac_jpat,	'JPAT'
	sym	type_asm_inst,		ac_jfbw,	'JFBW'
	sym	type_asm_inst,		ac_jxmt,	'JXMT'
	sym	type_asm_inst,		ac_jxfi,	'JXFI'
	sym	type_asm_inst,		ac_jxro,	'JXRO'
	sym	type_asm_inst,		ac_jxrl,	'JXRL'
	sym	type_asm_inst,		ac_jatn,	'JATN'
	sym	type_asm_inst,		ac_jqmt,	'JQMT'

	sym	type_asm_inst,		ac_jnint,	'JNINT'
	sym	type_asm_inst,		ac_jnct1,	'JNCT1'
	sym	type_asm_inst,		ac_jnct2,	'JNCT2'
	sym	type_asm_inst,		ac_jnct3,	'JNCT3'
	sym	type_asm_inst,		ac_jnse1,	'JNSE1'
	sym	type_asm_inst,		ac_jnse2,	'JNSE2'
	sym	type_asm_inst,		ac_jnse3,	'JNSE3'
	sym	type_asm_inst,		ac_jnse4,	'JNSE4'
	sym	type_asm_inst,		ac_jnpat,	'JNPAT'
	sym	type_asm_inst,		ac_jnfbw,	'JNFBW'
	sym	type_asm_inst,		ac_jnxmt,	'JNXMT'
	sym	type_asm_inst,		ac_jnxfi,	'JNXFI'
	sym	type_asm_inst,		ac_jnxro,	'JNXRO'
	sym	type_asm_inst,		ac_jnxrl,	'JNXRL'
	sym	type_asm_inst,		ac_jnatn,	'JNATN'
	sym	type_asm_inst,		ac_jnqmt,	'JNQMT'

;	sym	type_asm_inst,		ac_empty,	'<empty>'
;	sym	type_asm_inst,		ac_empty,	'<empty>'
	sym	type_asm_inst,		ac_setpat,	'SETPAT'

;	sym	type_asm_inst,		ac_wrpin,	'WRPIN'		(declared as type_i_flex)
;	sym	type_asm_inst,		ac_wxpin,	'WXPIN'		(declared as type_i_flex)
;	sym	type_asm_inst,		ac_wypin,	'WYPIN'		(declared as type_i_flex)
	sym	type_asm_inst,		ac_wrlut,	'WRLUT'

	sym	type_asm_inst,		ac_wrbyte,	'WRBYTE'
	sym	type_asm_inst,		ac_wrword,	'WRWORD'
	sym	type_asm_inst,		ac_wrlong,	'WRLONG'

	sym	type_asm_inst,		ac_rdfast,	'RDFAST'
	sym	type_asm_inst,		ac_wrfast,	'WRFAST'
	sym	type_asm_inst,		ac_fblock,	'FBLOCK'

	sym	type_asm_inst,		ac_xinit,	'XINIT'
	sym	type_asm_inst,		ac_xzero,	'XZERO'
	sym	type_asm_inst,		ac_xcont,	'XCONT'

	sym	type_asm_inst,		ac_rep,		'REP'

;	sym	type_asm_inst,		ac_coginit,	'COGINIT'	(declared as type_i_flex)
	sym	type_asm_inst,		ac_qmul,	'QMUL'
	sym	type_asm_inst,		ac_qdiv,	'QDIV'
	sym	type_asm_inst,		ac_qfrac,	'QFRAC'
	sym	type_asm_inst,		ac_qsqrt,	'QSQRT'
	sym	type_asm_inst,		ac_qrotate,	'QROTATE'
	sym	type_asm_inst,		ac_qvector,	'QVECTOR'

;	sym	type_asm_inst,		ac_hubset,	'HUBSET'	(declared as type_i_flex)
;	sym	type_asm_inst,		ac_cogid,	'COGID'		(declared as type_i_flex)
;	sym	type_asm_inst,		ac_cogstop,	'COGSTOP'	(declared as type_i_flex)
;	sym	type_asm_inst,		ac_locknew,	'LOCKNEW'	(declared as type_i_flex)
;	sym	type_asm_inst,		ac_lockret,	'LOCKRET'	(declared as type_i_flex)
;	sym	type_asm_inst,		ac_locktry,	'LOCKTRY'	(declared as type_i_flex)
;	sym	type_asm_inst,		ac_lockrel,	'LOCKREL'	(declared as type_i_flex)
;	sym	type_asm_inst,		ac_qlog,	'QLOG'		(declared as type_op)
;	sym	type_asm_inst,		ac_qexp,	'QEXP'		(declared as type_op)

	sym	type_asm_inst,		ac_rfbyte,	'RFBYTE'
	sym	type_asm_inst,		ac_rfword,	'RFWORD'
	sym	type_asm_inst,		ac_rflong,	'RFLONG'
	sym	type_asm_inst,		ac_rfvar,	'RFVAR'
	sym	type_asm_inst,		ac_rfvars,	'RFVARS'

	sym	type_asm_inst,		ac_wfbyte,	'WFBYTE'
	sym	type_asm_inst,		ac_wfword,	'WFWORD'
	sym	type_asm_inst,		ac_wflong,	'WFLONG'

	sym	type_asm_inst,		ac_getqx,	'GETQX'
	sym	type_asm_inst,		ac_getqy,	'GETQY'

;	sym	type_asm_inst,		ac_getct,	'GETCT'		(declared as type_i_flex)
;	sym	type_asm_inst,		ac_getrnd,	'GETRND'	(declared as type_i_flex)

	sym	type_asm_inst,		ac_setdacs,	'SETDACS'
	sym	type_asm_inst,		ac_setxfrq,	'SETXFRQ'
	sym	type_asm_inst,		ac_getxacc,	'GETXACC'

	sym	type_asm_inst,		ac_waitx,	'WAITX'

	sym	type_asm_inst,		ac_setse1,	'SETSE1'
	sym	type_asm_inst,		ac_setse2,	'SETSE2'
	sym	type_asm_inst,		ac_setse3,	'SETSE3'
	sym	type_asm_inst,		ac_setse4,	'SETSE4'

	sym	type_asm_inst,		ac_pollint,	'POLLINT'
	sym	type_asm_inst,		ac_pollct1,	'POLLCT1'
	sym	type_asm_inst,		ac_pollct2,	'POLLCT2'
	sym	type_asm_inst,		ac_pollct3,	'POLLCT3'
	sym	type_asm_inst,		ac_pollse1,	'POLLSE1'
	sym	type_asm_inst,		ac_pollse2,	'POLLSE2'
	sym	type_asm_inst,		ac_pollse3,	'POLLSE3'
	sym	type_asm_inst,		ac_pollse4,	'POLLSE4'
	sym	type_asm_inst,		ac_pollpat,	'POLLPAT'
	sym	type_asm_inst,		ac_pollfbw,	'POLLFBW'
	sym	type_asm_inst,		ac_pollxmt,	'POLLXMT'
	sym	type_asm_inst,		ac_pollxfi,	'POLLXFI'
	sym	type_asm_inst,		ac_pollxro,	'POLLXRO'
	sym	type_asm_inst,		ac_pollxrl,	'POLLXRL'
;	sym	type_asm_inst,		ac_pollatn,	'POLLATN'	(declared as type_i_flex)
	sym	type_asm_inst,		ac_pollqmt,	'POLLQMT'

	sym	type_asm_inst,		ac_waitint,	'WAITINT'
	sym	type_asm_inst,		ac_waitct1,	'WAITCT1'
	sym	type_asm_inst,		ac_waitct2,	'WAITCT2'
	sym	type_asm_inst,		ac_waitct3,	'WAITCT3'
	sym	type_asm_inst,		ac_waitse1,	'WAITSE1'
	sym	type_asm_inst,		ac_waitse2,	'WAITSE2'
	sym	type_asm_inst,		ac_waitse3,	'WAITSE3'
	sym	type_asm_inst,		ac_waitse4,	'WAITSE4'
	sym	type_asm_inst,		ac_waitpat,	'WAITPAT'
	sym	type_asm_inst,		ac_waitfbw,	'WAITFBW'
	sym	type_asm_inst,		ac_waitxmt,	'WAITXMT'
	sym	type_asm_inst,		ac_waitxfi,	'WAITXFI'
	sym	type_asm_inst,		ac_waitxro,	'WAITXRO'
	sym	type_asm_inst,		ac_waitxrl,	'WAITXRL'
;	sym	type_asm_inst,		ac_waitatn,	'WAITATN'	(declared as type_i_flex)

	sym	type_asm_inst,		ac_allowi,	'ALLOWI'
	sym	type_asm_inst,		ac_stalli,	'STALLI'

	sym	type_asm_inst,		ac_trgint1,	'TRGINT1'
	sym	type_asm_inst,		ac_trgint2,	'TRGINT2'
	sym	type_asm_inst,		ac_trgint3,	'TRGINT3'

	sym	type_asm_inst,		ac_nixint1,	'NIXINT1'
	sym	type_asm_inst,		ac_nixint2,	'NIXINT2'
	sym	type_asm_inst,		ac_nixint3,	'NIXINT3'

	sym	type_asm_inst,		ac_setint1,	'SETINT1'
	sym	type_asm_inst,		ac_setint2,	'SETINT2'
	sym	type_asm_inst,		ac_setint3,	'SETINT3'

	sym	type_asm_inst,		ac_setq,	'SETQ'
	sym	type_asm_inst,		ac_setq2,	'SETQ2'

	sym	type_asm_inst,		ac_push,	'PUSH'
	sym	type_asm_inst,		ac_pop,		'POP'

	sym	type_asm_inst,		ac_jmprel,	'JMPREL'
	sym	type_asm_inst,		ac_skip,	'SKIP'
	sym	type_asm_inst,		ac_skipf,	'SKIPF'
	sym	type_asm_inst,		ac_execf,	'EXECF'

	sym	type_asm_inst,		ac_getptr,	'GETPTR'
	sym	type_asm_inst,		ac_getbrk,	'GETBRK'
	sym	type_asm_inst,		ac_cogbrk,	'COGBRK'
	sym	type_asm_inst,		ac_brk,		'BRK'

	sym	type_asm_inst,		ac_setluts,	'SETLUTS'

	sym	type_asm_inst,		ac_setcy,	'SETCY'
	sym	type_asm_inst,		ac_setci,	'SETCI'
	sym	type_asm_inst,		ac_setcq,	'SETCQ'
	sym	type_asm_inst,		ac_setcfrq,	'SETCFRQ'
	sym	type_asm_inst,		ac_setcmod,	'SETCMOD'

	sym	type_asm_inst,		ac_setpiv,	'SETPIV'
	sym	type_asm_inst,		ac_setpix,	'SETPIX'

;	sym	type_asm_inst,		ac_cogatn,	'COGATN'	(declared as type_i_flex)

	sym	type_asm_inst,		ac_testp,	'TESTP'
	sym	type_asm_inst,		ac_testpn,	'TESTPN'

	sym	type_asm_inst,		ac_dirl,	'DIRL'
	sym	type_asm_inst,		ac_dirh,	'DIRH'
	sym	type_asm_inst,		ac_dirc,	'DIRC'
	sym	type_asm_inst,		ac_dirnc,	'DIRNC'
	sym	type_asm_inst,		ac_dirz,	'DIRZ'
	sym	type_asm_inst,		ac_dirnz,	'DIRNZ'
	sym	type_asm_inst,		ac_dirrnd,	'DIRRND'
	sym	type_asm_inst,		ac_dirnot,	'DIRNOT'

	sym	type_asm_inst,		ac_outl,	'OUTL'
	sym	type_asm_inst,		ac_outh,	'OUTH'
	sym	type_asm_inst,		ac_outc,	'OUTC'
	sym	type_asm_inst,		ac_outnc,	'OUTNC'
	sym	type_asm_inst,		ac_outz,	'OUTZ'
	sym	type_asm_inst,		ac_outnz,	'OUTNZ'
	sym	type_asm_inst,		ac_outrnd,	'OUTRND'
	sym	type_asm_inst,		ac_outnot,	'OUTNOT'

	sym	type_asm_inst,		ac_fltl,	'FLTL'
	sym	type_asm_inst,		ac_flth,	'FLTH'
	sym	type_asm_inst,		ac_fltc,	'FLTC'
	sym	type_asm_inst,		ac_fltnc,	'FLTNC'
	sym	type_asm_inst,		ac_fltz,	'FLTZ'
	sym	type_asm_inst,		ac_fltnz,	'FLTNZ'
	sym	type_asm_inst,		ac_fltrnd,	'FLTRND'
	sym	type_asm_inst,		ac_fltnot,	'FLTNOT'

	sym	type_asm_inst,		ac_drvl,	'DRVL'
	sym	type_asm_inst,		ac_drvh,	'DRVH'
	sym	type_asm_inst,		ac_drvc,	'DRVC'
	sym	type_asm_inst,		ac_drvnc,	'DRVNC'
	sym	type_asm_inst,		ac_drvz,	'DRVZ'
	sym	type_asm_inst,		ac_drvnz,	'DRVNZ'
	sym	type_asm_inst,		ac_drvrnd,	'DRVRND'
	sym	type_asm_inst,		ac_drvnot,	'DRVNOT'

	sym	type_asm_inst,		ac_splitb,	'SPLITB'
	sym	type_asm_inst,		ac_mergeb,	'MERGEB'
	sym	type_asm_inst,		ac_splitw,	'SPLITW'
	sym	type_asm_inst,		ac_mergew,	'MERGEW'
	sym	type_asm_inst,		ac_seussf,	'SEUSSF'
	sym	type_asm_inst,		ac_seussr,	'SEUSSR'
	sym	type_asm_inst,		ac_rgbsqz,	'RGBSQZ'
	sym	type_asm_inst,		ac_rgbexp,	'RGBEXP'
	sym	type_asm_inst,		ac_xoro32,	'XORO32'
;	sym	type_asm_inst,		ac_rev,		'REV'		(declared as type_op)
	sym	type_asm_inst,		ac_rczr,	'RCZR'
	sym	type_asm_inst,		ac_rczl,	'RCZL'
	sym	type_asm_inst,		ac_wrc,		'WRC'
	sym	type_asm_inst,		ac_wrnc,	'WRNC'
	sym	type_asm_inst,		ac_wrz,		'WRZ'
	sym	type_asm_inst,		ac_wrnz,	'WRNZ'
	sym	type_asm_inst,		ac_modcz,	'MODCZ'
	sym	type_asm_inst,		ac_modc,	'MODC'
	sym	type_asm_inst,		ac_modz,	'MODZ'

	sym	type_asm_inst,		ac_setscp,	'SETSCP'
	sym	type_asm_inst,		ac_getscp,	'GETSCP'

	sym	type_asm_inst,		ac_jmp,		'JMP'
;	sym	type_asm_inst,		ac_call,	'CALL'		(declared as type_i_flex)
	sym	type_asm_inst,		ac_calla,	'CALLA'
	sym	type_asm_inst,		ac_callb,	'CALLB'
	sym	type_asm_inst,		ac_calld,	'CALLD'
	sym	type_asm_inst,		ac_loc,		'LOC'

	sym	type_asm_inst,		ac_augs,	'AUGS'
	sym	type_asm_inst,		ac_augd,	'AUGD'

	sym	type_asm_inst,		ac_pusha,	'PUSHA'		;alias instructions
	sym	type_asm_inst,		ac_pushb,	'PUSHB'
	sym	type_asm_inst,		ac_popa,	'POPA'
	sym	type_asm_inst,		ac_popb,	'POPB'

	sym	type_asm_inst,		ac_ret,		'RET'		;xlat instructions
	sym	type_asm_inst,		ac_reta,	'RETA'
	sym	type_asm_inst,		ac_retb,	'RETB'
	sym	type_asm_inst,		ac_reti0,	'RETI0'
	sym	type_asm_inst,		ac_reti1,	'RETI1'
	sym	type_asm_inst,		ac_reti2,	'RETI2'
	sym	type_asm_inst,		ac_reti3,	'RETI3'
	sym	type_asm_inst,		ac_resi0,	'RESI0'
	sym	type_asm_inst,		ac_resi1,	'RESI1'
	sym	type_asm_inst,		ac_resi2,	'RESI2'
	sym	type_asm_inst,		ac_resi3,	'RESI3'
	sym	type_asm_inst,		ac_xstop,	'XSTOP'

;	sym	type_asm_inst,		ac_akpin,	'AKPIN'		(declared as type_i_flex)

	sym	type_asm_inst,		ac_asmclk,	'ASMCLK'

	sym	type_asm_inst,		ac_nop,		'NOP'


	sym	type_asm_effect,	0010b,		'WC'		;assembly effects
	sym	type_asm_effect,	0001b,		'WZ'
	sym	type_asm_effect,	0011b,		'WCZ'
	sym	type_asm_effect2,	0110b,		'ANDC'
	sym	type_asm_effect2,	0101b,		'ANDZ'
	sym	type_asm_effect2,	1010b,		'ORC'
	sym	type_asm_effect2,	1001b,		'ORZ'
	sym	type_asm_effect2,	1110b,		'XORC'
	sym	type_asm_effect2,	1101b,		'XORZ'


	sym	type_con_int,		if_ret,		'_CLR'		;modcz values
	sym	type_con_int,		if_nc_and_nz,	'_NC_AND_NZ'
	sym	type_con_int,		if_nc_and_nz,	'_NZ_AND_NC'
	sym	type_con_int,		if_nc_and_nz,	'_GT'
	sym	type_con_int,		if_nc_and_z,	'_NC_AND_Z'
	sym	type_con_int,		if_nc_and_z,	'_Z_AND_NC'
	sym	type_con_int,		if_nc,		'_NC'
	sym	type_con_int,		if_nc,		'_GE'
	sym	type_con_int,		if_c_and_nz,	'_C_AND_NZ'
	sym	type_con_int,		if_c_and_nz,	'_NZ_AND_C'
	sym	type_con_int,		if_nz,		'_NZ'
	sym	type_con_int,		if_nz,		'_NE'
	sym	type_con_int,		if_c_ne_z,	'_C_NE_Z'
	sym	type_con_int,		if_c_ne_z,	'_Z_NE_C'
	sym	type_con_int,		if_nc_or_nz,	'_NC_OR_NZ'
	sym	type_con_int,		if_nc_or_nz,	'_NZ_OR_NC'
	sym	type_con_int,		if_c_and_z,	'_C_AND_Z'
	sym	type_con_int,		if_c_and_z,	'_Z_AND_C'
	sym	type_con_int,		if_c_eq_z,	'_C_EQ_Z'
	sym	type_con_int,		if_c_eq_z,	'_Z_EQ_C'
	sym	type_con_int,		if_z,		'_Z'
	sym	type_con_int,		if_z,		'_E'
	sym	type_con_int,		if_nc_or_z,	'_NC_OR_Z'
	sym	type_con_int,		if_nc_or_z,	'_Z_OR_NC'
	sym	type_con_int,		if_c,		'_C'
	sym	type_con_int,		if_c,		'_LT'
	sym	type_con_int,		if_c_or_nz,	'_C_OR_NZ'
	sym	type_con_int,		if_c_or_nz,	'_NZ_OR_C'
	sym	type_con_int,		if_c_or_z,	'_C_OR_Z'
	sym	type_con_int,		if_c_or_z,	'_Z_OR_C'
	sym	type_con_int,		if_c_or_z,	'_LE'
	sym	type_con_int,		if_always,	'_SET'


	sym	type_reg,		0,		'REG'		;reg

	sym	type_register,		prx_regs+0,	'PR0'		;pasm regs
	sym	type_register,		prx_regs+1,	'PR1'
	sym	type_register,		prx_regs+2,	'PR2'
	sym	type_register,		prx_regs+3,	'PR3'
	sym	type_register,		prx_regs+4,	'PR4'
	sym	type_register,		prx_regs+5,	'PR5'
	sym	type_register,		prx_regs+6,	'PR6'
	sym	type_register,		prx_regs+7,	'PR7'

	sym	type_register,		1F0h,		'IJMP3'		;interrupt vectors
	sym	type_register,		1F1h,		'IRET3'
	sym	type_register,		1F2h,		'IJMP2'
	sym	type_register,		1F3h,		'IRET2'
	sym	type_register,		1F4h,		'IJMP1'
	sym	type_register,		1F5h,		'IRET1'
	sym	type_register,		1F6h,		'PA'		;calld/loc targets
	sym	type_register,		1F7h,		'PB'
	sym	type_register,		1F8h,		'PTRA'		;special function registers
	sym	type_register,		1F9h,		'PTRB'
	sym	type_register,		1FAh,		'DIRA'
	sym	type_register,		1FBh,		'DIRB'
	sym	type_register,		1FCh,		'OUTA'
	sym	type_register,		1FDh,		'OUTB'
	sym	type_register,		1FEh,		'INA'
	sym	type_register,		1FFh,		'INB'


	sym	type_hub_long,		00040h,		'CLKMODE'	;spin permanent variables
	sym	type_hub_long,		00044h,		'CLKFREQ'

	sym	type_var_long,		0,		'VARBASE'


	sym	type_con_int,		0,		'FALSE'		;numeric constants
	sym	type_con_int,		0FFFFFFFFh,	'TRUE'
	sym	type_con_int,		80000000h,	'NEGX'
	sym	type_con_int,		7FFFFFFFh,	'POSX'
	sym	type_con_float,		40490FDBh,	'PI'


	sym	type_con_int,		000000b,	'COGEXEC'	;coginit constants
	sym	type_con_int,		100000b,	'HUBEXEC'
	sym	type_con_int,		010000b,	'COGEXEC_NEW'
	sym	type_con_int,		110000b,	'HUBEXEC_NEW'
	sym	type_con_int,		010001b,	'COGEXEC_NEW_PAIR'
	sym	type_con_int,		110001b,	'HUBEXEC_NEW_PAIR'
	sym	type_con_int,		010000b,	'NEWCOG'	;cogspin constant


	syml	type_con_int,		0b,	31,	'P_TRUE_A'	;smart pin constants
	syml	type_con_int,		1b,	31,	'P_INVERT_A'

	syml	type_con_int,		000b,	28,	'P_LOCAL_A'
	syml	type_con_int,		001b,	28,	'P_PLUS1_A'
	syml	type_con_int,		010b,	28,	'P_PLUS2_A'
	syml	type_con_int,		011b,	28,	'P_PLUS3_A'
	syml	type_con_int,		100b,	28,	'P_OUTBIT_A'
	syml	type_con_int,		101b,	28,	'P_MINUS3_A'
	syml	type_con_int,		110b,	28,	'P_MINUS2_A'
	syml	type_con_int,		111b,	28,	'P_MINUS1_A'

	syml	type_con_int,		0b,	27,	'P_TRUE_B'
	syml	type_con_int,		1b,	27,	'P_INVERT_B'

	syml	type_con_int,		000b,	24,	'P_LOCAL_B'
	syml	type_con_int,		001b,	24,	'P_PLUS1_B'
	syml	type_con_int,		010b,	24,	'P_PLUS2_B'
	syml	type_con_int,		011b,	24,	'P_PLUS3_B'
	syml	type_con_int,		100b,	24,	'P_OUTBIT_B'
	syml	type_con_int,		101b,	24,	'P_MINUS3_B'
	syml	type_con_int,		110b,	24,	'P_MINUS2_B'
	syml	type_con_int,		111b,	24,	'P_MINUS1_B'

	syml	type_con_int,		000b,	21,	'P_PASS_AB'
	syml	type_con_int,		001b,	21,	'P_AND_AB'
	syml	type_con_int,		010b,	21,	'P_OR_AB'
	syml	type_con_int,		011b,	21,	'P_XOR_AB'
	syml	type_con_int,		100b,	21,	'P_FILT0_AB'
	syml	type_con_int,		101b,	21,	'P_FILT1_AB'
	syml	type_con_int,		110b,	21,	'P_FILT2_AB'
	syml	type_con_int,		111b,	21,	'P_FILT3_AB'

	syml	type_con_int,		0000b,	17,	'P_LOGIC_A'
	syml	type_con_int,		0001b,	17,	'P_LOGIC_A_FB'
	syml	type_con_int,		0010b,	17,	'P_LOGIC_B_FB'
	syml	type_con_int,		0011b,	17,	'P_SCHMITT_A'
	syml	type_con_int,		0100b,	17,	'P_SCHMITT_A_FB'
	syml	type_con_int,		0101b,	17,	'P_SCHMITT_B_FB'
	syml	type_con_int,		0110b,	17,	'P_COMPARE_AB'
	syml	type_con_int,		0111b,	17,	'P_COMPARE_AB_FB'

	syml	type_con_int,		100000b,15,	'P_ADC_GIO'
	syml	type_con_int,		100001b,15,	'P_ADC_VIO'
	syml	type_con_int,		100010b,15,	'P_ADC_FLOAT'
	syml	type_con_int,		100011b,15,	'P_ADC_1X'
	syml	type_con_int,		100100b,15,	'P_ADC_3X'
	syml	type_con_int,		100101b,15,	'P_ADC_10X'
	syml	type_con_int,		100110b,15,	'P_ADC_30X'
	syml	type_con_int,		100111b,15,	'P_ADC_100X'

	syml	type_con_int,		10100b,	16,	'P_DAC_990R_3V'
	syml	type_con_int,		10101b,	16,	'P_DAC_600R_2V'
	syml	type_con_int,		10110b,	16,	'P_DAC_124R_3V'
	syml	type_con_int,		10111b,	16,	'P_DAC_75R_2V'

	syml	type_con_int,		1100b,	17,	'P_LEVEL_A'
	syml	type_con_int,		1101b,	17,	'P_LEVEL_A_FBN'
	syml	type_con_int,		1110b,	17,	'P_LEVEL_B_FBP'
	syml	type_con_int,		1111b,	17,	'P_LEVEL_B_FBN'

	syml	type_con_int,		0b,	16,	'P_ASYNC_IO'
	syml	type_con_int,		1b,	16,	'P_SYNC_IO'

	syml	type_con_int,		0b,	15,	'P_TRUE_IN'
	syml	type_con_int,		1b,	15,	'P_INVERT_IN'

	syml	type_con_int,		0b,	14,	'P_TRUE_OUTPUT'		;added P_TRUE_OUT
	syml	type_con_int,		0b,	14,	'P_TRUE_OUT'
	syml	type_con_int,		1b,	14,	'P_INVERT_OUTPUT'	;added P_INVERT_OUT
	syml	type_con_int,		1b,	14,	'P_INVERT_OUT'

	syml	type_con_int,		000b,	11,	'P_HIGH_FAST'
	syml	type_con_int,		001b,	11,	'P_HIGH_1K5'
	syml	type_con_int,		010b,	11,	'P_HIGH_15K'
	syml	type_con_int,		011b,	11,	'P_HIGH_150K'
	syml	type_con_int,		100b,	11,	'P_HIGH_1MA'
	syml	type_con_int,		101b,	11,	'P_HIGH_100UA'
	syml	type_con_int,		110b,	11,	'P_HIGH_10UA'
	syml	type_con_int,		111b,	11,	'P_HIGH_FLOAT'

	syml	type_con_int,		000b,	8,	'P_LOW_FAST'
	syml	type_con_int,		001b,	8,	'P_LOW_1K5'
	syml	type_con_int,		010b,	8,	'P_LOW_15K'
	syml	type_con_int,		011b,	8,	'P_LOW_150K'
	syml	type_con_int,		100b,	8,	'P_LOW_1MA'
	syml	type_con_int,		101b,	8,	'P_LOW_100UA'
	syml	type_con_int,		110b,	8,	'P_LOW_10UA'
	syml	type_con_int,		111b,	8,	'P_LOW_FLOAT'

	syml	type_con_int,		00b,	6,	'P_TT_00'
	syml	type_con_int,		01b,	6,	'P_TT_01'
	syml	type_con_int,		10b,	6,	'P_TT_10'
	syml	type_con_int,		11b,	6,	'P_TT_11'
	syml	type_con_int,		01b,	6,	'P_OE'
	syml	type_con_int,		01b,	6,	'P_CHANNEL'
	syml	type_con_int,		10b,	6,	'P_BITDAC'

	syml	type_con_int,		00000b,	1,	'P_NORMAL'
	syml	type_con_int,		00001b,	1,	'P_REPOSITORY'
	syml	type_con_int,		00001b,	1,	'P_DAC_NOISE'
	syml	type_con_int,		00010b,	1,	'P_DAC_DITHER_RND'
	syml	type_con_int,		00011b,	1,	'P_DAC_DITHER_PWM'
	syml	type_con_int,		00100b,	1,	'P_PULSE'
	syml	type_con_int,		00101b,	1,	'P_TRANSITION'
	syml	type_con_int,		00110b,	1,	'P_NCO_FREQ'
	syml	type_con_int,		00111b,	1,	'P_NCO_DUTY'
	syml	type_con_int,		01000b,	1,	'P_PWM_TRIANGLE'
	syml	type_con_int,		01001b,	1,	'P_PWM_SAWTOOTH'
	syml	type_con_int,		01010b,	1,	'P_PWM_SMPS'
	syml	type_con_int,		01011b,	1,	'P_QUADRATURE'
	syml	type_con_int,		01100b,	1,	'P_REG_UP'
	syml	type_con_int,		01101b,	1,	'P_REG_UP_DOWN'
	syml	type_con_int,		01110b,	1,	'P_COUNT_RISES'
	syml	type_con_int,		01111b,	1,	'P_COUNT_HIGHS'
	syml	type_con_int,		10000b,	1,	'P_STATE_TICKS'
	syml	type_con_int,		10001b,	1,	'P_HIGH_TICKS'
	syml	type_con_int,		10010b,	1,	'P_EVENTS_TICKS'
	syml	type_con_int,		10011b,	1,	'P_PERIODS_TICKS'
	syml	type_con_int,		10100b,	1,	'P_PERIODS_HIGHS'
	syml	type_con_int,		10101b,	1,	'P_COUNTER_TICKS'
	syml	type_con_int,		10110b,	1,	'P_COUNTER_HIGHS'
	syml	type_con_int,		10111b,	1,	'P_COUNTER_PERIODS'
	syml	type_con_int,		11000b,	1,	'P_ADC'
	syml	type_con_int,		11001b,	1,	'P_ADC_EXT'
	syml	type_con_int,		11010b,	1,	'P_ADC_SCOPE'
	syml	type_con_int,		11011b,	1,	'P_USB_PAIR'
	syml	type_con_int,		11100b,	1,	'P_SYNC_TX'
	syml	type_con_int,		11101b,	1,	'P_SYNC_RX'
	syml	type_con_int,		11110b,	1,	'P_ASYNC_TX'
	syml	type_con_int,		11111b,	1,	'P_ASYNC_RX'


	syml	type_con_int,		0000h,	16,	'X_IMM_32X1_LUT'	;streamer constants
	syml	type_con_int,		1000h,	16,	'X_IMM_16X2_LUT'
	syml	type_con_int,		2000h,	16,	'X_IMM_8X4_LUT'
	syml	type_con_int,		3000h,	16,	'X_IMM_4X8_LUT'

	syml	type_con_int,		4000h,	16,	'X_IMM_32X1_1DAC1'
	syml	type_con_int,		5000h,	16,	'X_IMM_16X2_2DAC1'
	syml	type_con_int,		5002h,	16,	'X_IMM_16X2_1DAC2'
	syml	type_con_int,		6000h,	16,	'X_IMM_8X4_4DAC1'
	syml	type_con_int,		6002h,	16,	'X_IMM_8X4_2DAC2'
	syml	type_con_int,		6004h,	16,	'X_IMM_8X4_1DAC4'
	syml	type_con_int,		6006h,	16,	'X_IMM_4X8_4DAC2'
	syml	type_con_int,		6007h,	16,	'X_IMM_4X8_2DAC4'
	syml	type_con_int,		600Eh,	16,	'X_IMM_4X8_1DAC8'
	syml	type_con_int,		600Fh,	16,	'X_IMM_2X16_4DAC4'
	syml	type_con_int,		7000h,	16,	'X_IMM_2X16_2DAC8'
	syml	type_con_int,		7001h,	16,	'X_IMM_1X32_4DAC8'

	syml	type_con_int,		7002h,	16,	'X_RFLONG_32X1_LUT'
	syml	type_con_int,		7004h,	16,	'X_RFLONG_16X2_LUT'
	syml	type_con_int,		7006h,	16,	'X_RFLONG_8X4_LUT'
	syml	type_con_int,		7008h,	16,	'X_RFLONG_4X8_LUT'

	syml	type_con_int,		08000h,	16,	'X_RFBYTE_1P_1DAC1'
	syml	type_con_int,		09000h,	16,	'X_RFBYTE_2P_2DAC1'
	syml	type_con_int,		09002h,	16,	'X_RFBYTE_2P_1DAC2'
	syml	type_con_int,		0A000h,	16,	'X_RFBYTE_4P_4DAC1'
	syml	type_con_int,		0A002h,	16,	'X_RFBYTE_4P_2DAC2'
	syml	type_con_int,		0A004h,	16,	'X_RFBYTE_4P_1DAC4'
	syml	type_con_int,		0A006h,	16,	'X_RFBYTE_8P_4DAC2'
	syml	type_con_int,		0A007h,	16,	'X_RFBYTE_8P_2DAC4'
	syml	type_con_int,		0A00Eh,	16,	'X_RFBYTE_8P_1DAC8'
	syml	type_con_int,		0A00Fh,	16,	'X_RFWORD_16P_4DAC4'
	syml	type_con_int,		0B000h,	16,	'X_RFWORD_16P_2DAC8'
	syml	type_con_int,		0B001h,	16,	'X_RFLONG_32P_4DAC8'

	syml	type_con_int,		0B002h,	16,	'X_RFBYTE_LUMA8'
	syml	type_con_int,		0B003h,	16,	'X_RFBYTE_RGBI8'
	syml	type_con_int,		0B004h,	16,	'X_RFBYTE_RGB8'
	syml	type_con_int,		0B005h,	16,	'X_RFWORD_RGB16'
	syml	type_con_int,		0B006h,	16,	'X_RFLONG_RGB24'

	syml	type_con_int,		0C000h,	16,	'X_1P_1DAC1_WFBYTE'
	syml	type_con_int,		0D000h,	16,	'X_2P_2DAC1_WFBYTE'
	syml	type_con_int,		0D002h,	16,	'X_2P_1DAC2_WFBYTE'
	syml	type_con_int,		0E000h,	16,	'X_4P_4DAC1_WFBYTE'
	syml	type_con_int,		0E002h,	16,	'X_4P_2DAC2_WFBYTE'
	syml	type_con_int,		0E004h,	16,	'X_4P_1DAC4_WFBYTE'
	syml	type_con_int,		0E006h,	16,	'X_8P_4DAC2_WFBYTE'
	syml	type_con_int,		0E007h,	16,	'X_8P_2DAC4_WFBYTE'
	syml	type_con_int,		0E00Eh,	16,	'X_8P_1DAC8_WFBYTE'
	syml	type_con_int,		0E00Fh,	16,	'X_16P_4DAC4_WFWORD'
	syml	type_con_int,		0F000h,	16,	'X_16P_2DAC8_WFWORD'
	syml	type_con_int,		0F001h,	16,	'X_32P_4DAC8_WFLONG'

	syml	type_con_int,		0F002h,	16,	'X_1ADC8_0P_1DAC8_WFBYTE'
	syml	type_con_int,		0F003h,	16,	'X_1ADC8_8P_2DAC8_WFWORD'
	syml	type_con_int,		0F004h,	16,	'X_2ADC8_0P_2DAC8_WFWORD'
	syml	type_con_int,		0F005h,	16,	'X_2ADC8_16P_4DAC8_WFLONG'
	syml	type_con_int,		0F006h,	16,	'X_4ADC8_0P_4DAC8_WFLONG'

	syml	type_con_int,		0F007h,	16,	'X_DDS_GOERTZEL_SINC1'
	syml	type_con_int,		0F087h,	16,	'X_DDS_GOERTZEL_SINC2'

	syml	type_con_int,		0000h,	16,	'X_DACS_OFF'
	syml	type_con_int,		0100h,	16,	'X_DACS_0_0_0_0'
	syml	type_con_int,		0200h,	16,	'X_DACS_X_X_0_0'
	syml	type_con_int,		0300h,	16,	'X_DACS_0_0_X_X'
	syml	type_con_int,		0400h,	16,	'X_DACS_X_X_X_0'
	syml	type_con_int,		0500h,	16,	'X_DACS_X_X_0_X'
	syml	type_con_int,		0600h,	16,	'X_DACS_X_0_X_X'
	syml	type_con_int,		0700h,	16,	'X_DACS_0_X_X_X'
	syml	type_con_int,		0800h,	16,	'X_DACS_0N0_0N0'
	syml	type_con_int,		0900h,	16,	'X_DACS_X_X_0N0'
	syml	type_con_int,		0A00h,	16,	'X_DACS_0N0_X_X'
	syml	type_con_int,		0B00h,	16,	'X_DACS_1_0_1_0'
	syml	type_con_int,		0C00h,	16,	'X_DACS_X_X_1_0'
	syml	type_con_int,		0D00h,	16,	'X_DACS_1_0_X_X'
	syml	type_con_int,		0E00h,	16,	'X_DACS_1N1_0N0'
	syml	type_con_int,		0F00h,	16,	'X_DACS_3_2_1_0'

	syml	type_con_int,		0000h,	16,	'X_PINS_OFF'
	syml	type_con_int,		0080h,	16,	'X_PINS_ON'

	syml	type_con_int,		0000h,	16,	'X_WRITE_OFF'
	syml	type_con_int,		0080h,	16,	'X_WRITE_ON'

	syml	type_con_int,		0000h,	16,	'X_ALT_OFF'
	syml	type_con_int,		0001h,	16,	'X_ALT_ON'


	sym	type_con_int,		0,		'INT_OFF'		;event/interrupt constants
	sym	type_con_int,		0,		'EVENT_INT'
	sym	type_con_int,		1,		'EVENT_CT1'
	sym	type_con_int,		2,		'EVENT_CT2'
	sym	type_con_int,		3,		'EVENT_CT3'
	sym	type_con_int,		4,		'EVENT_SE1'
	sym	type_con_int,		5,		'EVENT_SE2'
	sym	type_con_int,		6,		'EVENT_SE3'
	sym	type_con_int,		7,		'EVENT_SE4'
	sym	type_con_int,		8,		'EVENT_PAT'
	sym	type_con_int,		9,		'EVENT_FBW'
	sym	type_con_int,		10,		'EVENT_XMT'
	sym	type_con_int,		11,		'EVENT_XFI'
	sym	type_con_int,		12,		'EVENT_XRO'
	sym	type_con_int,		13,		'EVENT_XRL'
	sym	type_con_int,		14,		'EVENT_ATN'
	sym	type_con_int,		15,		'EVENT_QMT'

	db	0
;
;
; Spin2 level symbols
;
level43_symbols:

	sym	type_conlstr,		0,		'LSTRING'

	db	0


level44_symbols:

	sym	type_i_flex,		fc_byteswap,	'BYTESWAP'
	sym	type_i_flex,		fc_bytecomp,	'BYTECOMP'
	sym	type_i_flex,		fc_wordswap,	'WORDSWAP'
	sym	type_i_flex,		fc_wordcomp,	'WORDCOMP'
	sym	type_i_flex,		fc_longswap,	'LONGSWAP'
	sym	type_i_flex,		fc_longcomp,	'LONGCOMP'

	sym	type_debug_cmd,		00100000b,	'BOOL'
	sym	type_debug_cmd,		00100010b,	'BOOL_'

	db	0


level45_symbols:

	sym	type_struct,		0,		'STRUCT'	;struct definition in CON
	sym	type_sizeof,		0,		'SIZEOF'	;returns size of structure

	db	0


level46_symbols:

	sym	type_debug_cmd,		dc_c_z_pre,	'C_Z'

	db	0


level47_symbols:

	sym	type_i_taskspin,	bc_taskspin,	'TASKSPIN'
	sym	type_i_flex,		fc_tasknext,	'TASKNEXT'
	sym	type_i_flex,		fc_taskstop,	'TASKSTOP'
	sym	type_i_flex,		fc_taskhalt,	'TASKHALT'
	sym	type_i_flex,		fc_taskcont,	'TASKCONT'
	sym	type_i_flex,		fc_taskchk,	'TASKCHK'
	sym	type_i_flex,		fc_taskid,	'TASKID'
	sym	type_con_int,		0FFFFFFFFh,	'NEWTASK'
	sym	type_con_int,		0FFFFFFFFh,	'THISTASK'
	sym	type_register,		taskhlt_reg,	'TASKHLT'

	db	0


level50_symbols:

	sym	type_asm_dir,		dir_ditto,	'DITTO'

	db	0


level51_symbols:

	sym	type_op,		oc_pow,		'POW'
	sym	type_op,		oc_log2,	'LOG2'
	sym	type_op,		oc_log10,	'LOG10'
	sym	type_op,		oc_log,		'LOG'
	sym	type_op,		oc_exp2,	'EXP2'
	sym	type_op,		oc_exp10,	'EXP10'
	sym	type_op,		oc_exp,		'EXP'

	db	0
;
;
;*********
;*  End  *
;*********
;
		ends
		end
