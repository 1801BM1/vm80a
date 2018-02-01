	title	'Z80 instruction set exerciser'

; zexlax.z80 - Z80 instruction set exerciser
; Copyright (C) 1994  Frank D. Cringle
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version 2
; of the License, or (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;_______________________________________________________________________
;
;
; Modified to exercise an 8080 by Ian Bartholomew, February 2009
; 
; I have made the following changes -
;
; Converted all mnemonics to 8080 and rewritten any Z80 code used
; in the original exerciser.  Changes are tagged with a #idb in the
; source code listing.
;
; Removed any test descriptors that are not used.
;  
; Changed the macro definitions to work in M80
;
; The machine state snapshot has been changed to remove the IX/IY registers.
; They have been replaced by two more copies of HL to obviate the need
; for major changes in the exerciser code.
;
; Changed flag mask in all tests to 0ffh to reflect that the 8080, unlike the 8085
; and Z80, does define the unused bits in the flag register - [S Z 0 AC 0 P 1 C]
;
;_______________________________________________________________________
;
fclk		equ	25000
udat		equ	0FE00h
ucsr		equ	0FE01h
leds		equ	0FFFBh
disp		equ     0FFFCh
keys		equ	0FF00h

tx_ready	equ	080h
tx_brk		equ	040h
tx_empty	equ	020h
rx_ready	equ	008h
rx_break	equ	004h
rx_perr		equ	002h
rx_ovf		equ	001h

                .8080
		aseg
		org	0h
entry:		jmp	begin
ticks:		ds	2
		org	08h
		ei
		ret
		org	10h
		ei
		ret
		org	18h
		ei
		ret
		org	20h
		jmp	int1000
		org	28h
		ei
		ret
		org	30h
		ei
		ret
		org	38h
		ei
		ret

int1000:	push	PSW
		push	H
		lhld	ticks
		inx	H
		shld	ticks
		pop	H
		pop	PSW
		ei
		ret

;_______________________________________________________________________
;
		org	100h
begin:		jmp	start
;
; machine state before test (needs to be at predictably constant address)
;
msbt:		ds	14
spbt:		ds	2
;
; For the purposes of this test program, the machine state consists of:
;	a 2 byte memory operand, followed by
;	the registers iy,ix,hl,de,bc,af,sp
; for a total of 16 bytes.
;
; The program tests instructions (or groups of similar instructions)
; by cycling through a sequence of machine states, executing the test
; instruction for each one and running a 32-bit crc over the resulting
; machine states.  At the end of the sequence the crc is compared to
; an expected value that was found empirically on a real Z80.
;
; A test case is defined by a descriptor which consists of:
;	a flag mask byte,
;	the base case,
;	the increment vector,
;	the shift vector,
;	the expected crc,
;	a short descriptive message.
;
; The flag mask byte is used to prevent undefined flag bits from
; influencing the results.  Documented flags are as per Mostek Z80
; Technical Manual.
;
; The next three parts of the descriptor are 20 byte vectors
; corresponding to a 4 byte instruction and a 16 byte machine state.
; The first part is the base case, which is the first test case of
; the sequence.  This base is then modified according to the next 2
; vectors.  Each 1 bit in the increment vector specifies a bit to be
; cycled in the form of a binary counter.  For instance, if the byte
; corresponding to the accumulator is set to 0ffh in the increment
; vector, the test will be repeated for all 256 values of the
; accumulator.  Note that 1 bits don't have to be contiguous.  The
; number of test cases 'caused' by the increment vector is equal to
; 2^(number of 1 bits).  The shift vector is similar, but specifies a
; set of bits in the test case that are to be successively inverted.
; Thus the shift vector 'causes' a number of test cases equal to the
; number of 1 bits in it.
;
; The total number of test cases is the product of those caused by the
; counter and shift vectors and can easily become unweildy.  Each
; individual test case can take a few milliseconds to execute, due to
; the overhead of test setup and crc calculation, so test design is a
; compromise between coverage and execution time.
;
; This program is designed to detect differences between
; implementations and is not ideal for diagnosing the causes of any
; discrepancies.  However, provided a reference implementation (or
; real system) is available, a failing test case can be isolated by
; hand using a binary search of the test space.
;_______________________________________________________________________
;
start:		lxi	SP, stack		;
		lxi	H, 8080h		;
		call	hexlo                   ;
		lxi	H, msg0			;
		call	print			;
;                                               ;
;@@tloop:	call	getch			;
;		push	PSW			;
;		call	putch			;
;		pop	PSW			;
;		mov	L, A			;
;		mvi	H, 0			;
;		call	hexlo                   ;
;		jmp	@@tloop			;
;						;
;@@tloop:	lhld	ticks			;
;		call	hexlo			;
;		ei				;
;		lhld	ticks			;
;		call	puthx			;
;		mvi	A, 10			;
;		call	putch			;
;		mvi	A, 13			;
;		call	putch			;
;		jmp	@@tloop			;
;						;
                lxi	H, stable+32		;
		mvi	E, 1			;
@@genloop:	push	H			;
		mov	A, E			;
						;
		rrc				;
		jnc	@@bit1			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit0		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit1:		rrc                             ;
		jnc	@@bit2			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit1		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit2:		rrc				;
		jnc	@@bit3			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit2		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit3:		rrc				;
		jnc	@@bit4			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit3		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit4:		rrc				;
		jnc	@@bit5			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit4		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit5:		rrc				;
		jnc	@@bit6			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit5		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit6:		rrc				;
		jnc	@@bit7			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit6		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@bit7:		rrc				;
		jnc	@@next			;
		mvi	M, 0CDh			; call
		inx	H			;
		lxi	B, nxtbit7		;
		mov	M, C			;
		inx	H			;
		mov	M, B			;
		inx	H			;
						;
@@next:		dcx	H			;
		dcx	H			;
		dcx	H			;
		mvi	M,0C3h			; jmp
		pop	H			;
		lxi	B, 32			;
		dad	B			;
		inr	E			;
		jnz	@@genloop		;
		                                ;
		lxi	H, tests		; first test case
@@loop:		mov	A, M			; end of list ?
		inx	H			;
		ora	M			;
		jz	@@done			;
		dcx	H			;
		call	stt			;
		jmp	@@loop			;
						;	
@@done:		lxi	H, msg3			;
		call	print			;
		lxi	H, disp			;
		mvi	M, 079h			; 'd'
		inx	H			;
		mvi	M, 054h			; 'o'
		inx	H                       ;
		mvi	M, 05Ch                 ; 'n'
		inx	H                       ;
		mvi	M, 05Eh                 ; 'E'
		jmp	$                       ;
						;
tests:						;
		dw	add16			;
;		dw	add8i			;
;		dw	adc8i			;
;		dw	sub8i			;
;		dw	sbb8i			;
;		dw	ana8i			;
;		dw	xra8i			;
;		dw	ora8i			;
;		dw	cmp8i			;
		dw	alu8i			;
		dw	alu8r			;
		dw	daa			;
		dw	inca			;
		dw	incb			;
		dw	incbc			;
		dw	incc			;
		dw	incd			;
		dw	incde			;
		dw	ince			;
		dw	inch			;
		dw	inchl			;
		dw	incl			;
		dw	incm			;
		dw	incsp			;
		dw	ld162			;
		dw	ld166			;
		dw	ld16im			;
		dw	ld8bd			;
		dw	ld8im			;
		dw	ld8rr			;
		dw	lda			;
		dw	rot8080			;
		dw	stabd			;
		dw	0			;
;_______________________________________________________________________
;
tstr		macro	insn, memop, hliy, hlix, rhl, rde, rbc, flags, acc, rsp
		local	lab
lab:		db	insn, 0, 0, 0
		dw	memop, hliy, hlix, rhl, rde, rbc
		db	flags
		db	acc
		dw	rsp
	if	$-lab ne 20
	error	'missing parameter'
	endif
		endm

tstr16		macro	insn, arg16, memop, hliy, hlix, rhl, rde, rbc, flags, acc, rsp
		local	lab
lab:		db	insn, low arg16, high arg16, 0
		dw	memop, hliy, hlix, rhl, rde, rbc
		db	flags
		db	acc
		dw	rsp
	if	$-lab ne 20
	error	'missing parameter'
	endif
		endm

;_______________________________________________________________________
;
; add hl,<bc,de,hl,sp> (19,456 cycles)
add16:	db	0ffh		; flag mask
	tstr	9,0c4a5h,0c4c7h,0d226h,0a050h,058eah,08566h,0c6h,0deh,09bc9h
	tstr	030h,0,0,0,0f821h,0,0,0,0,0	; (512 cycles)
	tstr	0,0,0,0,-1,-1,-1,0d7h,0,-1	; (38 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "dad <B,D,H,SP>        14474BA6 : ", 0

; aluop a,nn (28,672 cycles)
alu8i:	db	0ffh		; flag mask
	tstr	0c6h,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	038h,0,0,0,0,0,0,0,-1,0		; (2048 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "aluop NN              9E922F9E : ", 0

; adi nn (3,584 cycles)
add8i:	db	0ffh		; flag mask
	tstr	0c6h,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "add8i                 CD0203CE : ", 0

; aci nn (3,584 cycles)
adc8i:	db	0ffh		; flag mask
	tstr	0ceh,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "adc8i                 6F26398B : ", 0

; sui nn (3,584 cycles)
sub8i:	db	0ffh		; flag mask
	tstr	0d6h,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "sub8i                 E5DA5007 : ", 0

; sbi nn (3,584 cycles)
sbb8i:	db	0ffh		; flag mask
	tstr	0deh,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "sbb8i                 2C47E33B : ", 0

; xri nn (3,584 cycles)
ana8i:	db	0ffh		; flag mask
	tstr	0e6h,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "ana8i                 8383F645 : ", 0

; xri nn (3,584 cycles)
xra8i:	db	0ffh		; flag mask
	tstr	0eeh,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "xra8i                 BCEA1369 : ", 0

; ori nn (3,584 cycles)
ora8i:	db	0ffh		; flag mask
	tstr	0f6h,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "ora8i                 B22030B1 : ", 0

; cpi nn (3,584 cycles)
cmp8i:	db	0ffh		; flag mask
	tstr	0feh,09140h,07e3ch,07a67h,0df6dh,05b61h,00b29h,010h,066h,085b2h
	tstr	0,0,0,0,0,0,0,0,-1,0		; (256 cycles)
	tstr16	0,0ffh,0,0,0,0,0,0,0d7h,0,0	; (14 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "cmp8i                 B922496F : ", 0

; aluop a,<b,c,d,e,h,l,(hl),a> (753,664 cycles)
alu8r:	db	0ffh		; flag mask
	tstr	080h,0c53eh,0573ah,04c4dh,msbt,0e309h,0a666h,0d0h,03bh,0adbbh
	tstr	03fh,0,0,0,0,0,0,0,-1,0		; (16,384 cycles)
	tstr	0,0ffh,0,0,0,-1,-1,0d7h,0,0	; (46 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "aluop <B..L,M,A>      CF762C86 : ", 0

; <daa,cpl,scf,ccf>
daa:	db	0ffh		; flag mask
	tstr	027h,02141h,009fah,01d60h,0a559h,08d5bh,09079h,004h,08eh,0299dh
	tstr	018h,0,0,0,0,0,0,0d7h,-1,0	; (65,536 cycles)
	tstr	0,0,0,0,0,0,0,0,0,0		; (1 cycle)
	db	0,0,0,0				; expected crc
	db	10, 13, "<daa,cma,stc,cmc>     BB3F030C : ", 0

; <inc,dec> a (3072 cycles)
inca:	db	0ffh		; flag mask
	tstr	03ch,04adfh,0d5d8h,0e598h,08a2bh,0a7b0h,0431bh,044h,05ah,0d030h
	tstr	001h,0,0,0,0,0,0,0,-1,0		; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> A           ADB6460E : ", 0

; <inc,dec> b (3072 cycles)
incb:	db	0ffh		; flag mask
	tstr	004h,0d623h,0432dh,07a61h,08180h,05a86h,01e85h,086h,058h,09bbbh
	tstr	001h,0,0,0,0,0,0ff00h,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> B           83ED1345 : ", 0

; <inc,dec> bc (1536 cycles)
incbc:	db	0ffh		; flag mask
	tstr	003h,0cd97h,044abh,08dc9h,0e3e3h,011cch,0e8a4h,002h,049h,02a4dh
	tstr	008h,0,0,0,0,0,0f821h,0,0,0	; (256 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inx,dcx> B           F79287CD : ", 0

; <inc,dec> c (3072 cycles)
incc:	db	0ffh		; flag mask
	tstr	00ch,0d789h,00935h,0055bh,09f85h,08b27h,0d208h,095h,005h,00660h
	tstr	001h,0,0,0,0,0,0ffh,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> C           E5F6721B : ", 0

; <inc,dec> d (3072 cycles)
incd:	db	0ffh		; flag mask
	tstr	014h,0a0eah,05fbah,065fbh,0981ch,038cch,0debch,043h,05ch,003bdh
	tstr	001h,0,0,0,0,0ff00h,0,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> D           15B5579A : ", 0

; <inc,dec> de (1536 cycles)
incde:	db	0ffh		; flag mask
	tstr	013h,0342eh,0131dh,028c9h,00acah,09967h,03a2eh,092h,0f6h,09d54h
	tstr	008h,0,0,0,0,0f821h,0,0,0,0	; (256 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inx,dcx> D           7F4E2501 : ", 0

; <inc,dec> e (3072 cycles)
ince:	db	0ffh		; flag mask
	tstr	01ch,0602fh,04c0dh,02402h,0e2f5h,0a0f4h,0a10ah,013h,032h,05925h
	tstr	001h,0,0,0,0,0ffh,0,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> E           CF2AB396 : ", 0

; <inc,dec> h (3072 cycles)
inch:	db	0ffh		; flag mask
	tstr	024h,01506h,0f2ebh,0e8ddh,0262bh,011a6h,0bc1ah,017h,006h,02818h
	tstr	001h,0,0,0,0ff00h,0,0,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> H           12B2952C : ", 0

; <inc,dec> hl (1536 cycles)
inchl:	db	0ffh		; flag mask
	tstr	023h,0c3f4h,007a5h,01b6dh,04f04h,0e2c2h,0822ah,057h,0e0h,0c3e1h
	tstr	008h,0,0,0,0f821h,0,0,0,0,0	; (256 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inx,dcx> H           9F2B23C0 : ", 0

; <inc,dec> l (3072 cycles)
incl:	db	0ffh		; flag mask
	tstr	02ch,08031h,0a520h,04356h,0b409h,0f4c1h,0dfa2h,0d1h,03ch,03ea2h
	tstr	001h,0,0,0,0ffh,0,0,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> L           FF57D356 : ", 0

; <inc,dec> (hl) (3072 cycles)
incm:	db	0ffh		; flag mask
	tstr	034h,0b856h,00c7ch,0e53eh,msbt,0877eh,0da58h,015h,05ch,01f37h
	tstr	001h,0ffh,0,0,0,0,0,0,0,0	; (512 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inr,dcr> M           92E963BD : ", 0

; <inc,dec> sp (1536 cycles)
incsp:	db	0ffh		; flag mask
	tstr	033h,0346fh,0d482h,0d169h,0deb6h,0a494h,0f476h,053h,002h,0855bh
	tstr	008h,0,0,0,0,0,0,0,0,0f821h	; (256 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<inx,dcx> SP          D5702FAB : ", 0

; ld hl,(nnnn) (16 cycles)
ld162:	db	0ffh		; flag mask
	tstr16	02ah,msbt,09863h,07830h,02077h,0b1feh,0b9fah,0abb8h,004h,006h,06015h
	tstr	0,0,0,0,0,0,0,0,0,0		; (1 cycle)
	tstr	0,-1,0,0,0,0,0,0,0,0		; (16 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "lhld NNNN             A9C3D5CB : ", 0
	
; ld (nnnn),hl (16 cycles)
ld166:	db	0ffh		; flag mask
	tstr16	022h,msbt,0d003h,07772h,07f53h,03f72h,064eah,0e180h,010h,02dh,035e9h
	tstr	0,0,0,0,0,0,0,0,0,0		; (1 cycle)
	tstr	0,0,0,0,-1,0,0,0,0,0		; (16 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "shld NNNN             E8864F26 : ", 0

; ld <bc,de,hl,sp>,nnnn (64 cycles)
ld16im:	db	0ffh		; flag mask
	tstr	1,05c1ch,02d46h,08eb9h,06078h,074b1h,0b30eh,046h,0d1h,030cch
	tstr	030h,0,0,0,0,0,0,0,0,0		; (4 cycles)
	tstr16	0,0ffffh,0,0,0,0,0,0,0,0,0	; (16 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "lxi <B,D,H,SP>,NNNN   FCF46E12 : ", 0

;tstr		macro	insn, memop, hliy, hlix, rhl, rde, rbc, flags, acc, rsp
; ld a,<(bc),(de)> (44 cycles)
ld8bd:	db	0ffh		; flag mask
	tstr	00ah,0b3a8h,01d2ah,07f8eh,042ach,msbt,msbt,0c6h,0b1h,0ef8eh
	tstr	010h,0,0,0,0,0,0,0,0,0		; (2 cycles)
	tstr	0,0ffh,0,0,0,0,0,0d7h,-1,0	; (22 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "ldax <B,D>            2B821D5F : ", 0

; ld <b,c,d,e,h,l,(hl),a>,nn (64 cycles)
ld8im:	db	0ffh		; flag mask
	tstr	6,0c407h,0f49dh,0d13dh,00339h,0de89h,07455h,053h,0c0h,05509h
	tstr	038h,0,0,0,0,0,0,0,0,0		; (8 cycles)
	tstr	0,0,0,0,0,0,0,0,-1,0		; (8 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "mvi <B..L,M,A>,NN     EAA72044 : ", 0

; ld <b,c,d,e,h,l,a>,<b,c,d,e,h,l,a> (3456 cycles)
ld8rr:	db	0ffh		; flag mask
	tstr	040h,072a4h,0a024h,061ach,msbt,082c7h,0718fh,097h,08fh,0ef8eh
	tstr	03fh,0,0,0,0,0,0,0,0,0		; (64 cycles)
	tstr	0,0ffh,0,0,0,-1,-1,0d7h,-1,0	; (54 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "mov <B..L,A>,<B..L,A> 10B58CEE : ", 0

; ld a,(nnnn) / ld (nnnn),a (44 cycles)
lda:	db	0ffh		; flag mask
	tstr16	032h,msbt,0fd68h,0f4ech,044a0h,0b543h,00653h,0cdbah,0d2h,04fh,01fd8h
	tstr	008h,0,0,0,0,0,0,0,0,0		; (2 cycle)
	tstr	0,0ffh,0,0,0,0,0,0d7h,-1,0	; (22 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<sta,lda> NNNN        ED57AF72 : ", 0

; <rlca,rrca,rla,rra> (6144 cycles)
rot8080: db	0ffh		; flag mask
	tstr	7,0cb92h,06d43h,00a90h,0c284h,00c53h,0f50eh,091h,0ebh,040fch
	tstr	018h,0,0,0,0,0,0,0,-1,0		; (1024 cycles)
	tstr	0,0,0,0,0,0,0,0d7h,0,0		; (6 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "<rlc,rrc,ral,rar>     E0D89235 : ", 0

; ld (<bc,de>),a (96 cycles)
stabd:	db	0ffh		; flag mask
	tstr	2,00c3bh,0b592h,06cffh,0959eh,msbt,msbt+1,0c1h,021h,0bde7h
	tstr	018h,0,0,0,0,0,0,0,0,0		; (4 cycles)
	tstr	0,-1,0,0,0,0,0,0,-1,0		; (24 cycles)
	db	0,0,0,0				; expected crc
	db	10, 13, "stax <B,D>            2B0471E9 : ", 0

;_______________________________________________________________________
;
; start test pointed to by (hl)
;
stt:		push	H			;
		mov	A, M			; get pointer to test
		inx	H			;
		mov	H, M			;
		mov	L, A			;
		mov	A, M			; flag mask
		sta	flgmsk+1		;
		inx	H			;
		push	H			;
		lxi	D,20			;
		dad	D			; point to incmask
		lxi	D, counter		;
		call	initmask		;
		pop	H			;
						;
		push	H			;
		lxi	D,20+20 		;
		dad	D			; point to scanmask
		lxi	D, shifter		;
		call	initmask		;
		lxi	H, shifter		;
		mvi	M, 1			; first bit
		pop	H			;
						;
		push	H			;
		lxi	D, iut			; copy initial instruction under test
		mvi	B, 4			;
@@copyI:	mov	A, M			;
		stax	D			;
		inx	H			;
		inx	D			;
		dcr	B			;
		jnz	@@copyI			;
						;
		lxi	D, msbt			; copy initial machine state
		mvi	B, 16			;
@@copyS:	mov	A, M			;
		stax	D			;
		inx	H			;
		inx	D			;
		dcr	B			;
		jnz	@@copyS			;
		   				;
		lxi	D, 20+20+4		; skip incmask, scanmask and expcrc
		dad	D			;
;		mov	L, M    		; show test name
;		mvi	H, 0                    ;
;		call	hexlo                   ;
		call	print			;
		call	getch			;
		cpi	27			;
		jnz	@@soit			;
		lxi	h, msg1			;
		call	print			;
		                                ;
		pop	H			;
		pop	H			;
		inx	H			;
		inx	H			;
		ret				;
						;
@@soit:		lxi	H, msg2			;
		call	print			;
						; test loop
		call	initcrc			; initialize crc
@@loop:		lda	iut			;
		cpi	076h			; pragmatically avoid halt intructions
		jz	@@halt			;
		cnz	test			; execute the test instruction
@@halt:		call	count			; increment the counter
		cnz	shift			; shift the scan bit
		pop	H			; pointer to test case
		jz	@@next			; done if shift returned NZ
						;
		lxi	H, msg4			;
		call	print			;
		lxi	h,crcval		;
		call	phex8			;
		pop	H			;
		inx	H			;
		inx	H			;
		ret				;
						;
@@next:		push	H			;
		mvi	A,1			; initialise count and shift scanners
		sta	cntbit			;
		sta	shfbit			;
		lxi	H, counter		;
		shld	cntbyt			;
		lxi	H, shifter		;
		shld	shfbyt			;
						;
		pop	H			; pointer to test case
		push	H			;
		lxi	D, iut			;
						;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
						;
		lxi	D, msbt			; setup machine state
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
						;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
						;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
						;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		inx	H			;
		call	subyte			;
		jmp	@@loop			;
						;
subyte:		push	D			;
		push	H			;
		mov	C, M			; get base byte
		lxi	D, 20			;
		dad	D			; point to incmask
		mov	A, M			;
		ora	A			;
		jz	@@skipcnt		;
						;
		push	H			;
		rrc				;
		rrc				;
		rrc				;
		mov	H, A			;
		ani	11100000b		;
		mov	L, A			;
		xra	H			;
		adi	high stable		;
		mov	H, A			;
		shld	cntsub			;
						;
 cntbyt	equ $+1					;
		lxi	D, 0			;
 cntbit	equ $+2					;
		lxi	H, 0			;
 cntsub	equ $+1					;
		call	0			;
						;
		mov	A, H			;
		sta	cntbit			;
		xchg				;
		shld	cntbyt			;
		pop	H			;
						;
@@skipcnt:	lxi	D, 20			;
		dad	D			; point to shift mask
		mov	A, M			;
		ora	A			;
		jz	@@skipshf		;
 shfbyt	equ $+1					;
		lxi	D,0			;
 shfbit	equ $+2					;
		lxi	H,0			;
						;
		rrc				;
		rrc				;
		rrc				;
		mov	B, A			;
		ani	11100000b		;
		sta	shfsub			;
		xra	b			;
		adi	high stable		;
		sta	shfsub+1		;
 shfsub	equ $+1					;
		call	0			;
		mov	A, H			;
		sta	shfbit			;
		xchg				;
		shld	shfbyt			;
						;
@@skipshf:	pop	H			;
		pop	D			;
		mov	A, C			;
		stax	D			; mangled byte to destination
		inx	D			;
		ret				;
;_______________________________________________________________________
;
; clear memory at HL, B bytes
;
clrmem:		push	H			;
		xra	A			;
@@loop:		mov	M, A			;
		inx	H			;
		dcr	B			;
		jnz	@@loop			;
		pop	H			;
		ret				;
;_______________________________________________________________________
;
; initialise counter or shifter
; DE = pointer to work area for counter or shifter
; HL = pointer to mask
;
initmask:	push	D			;
		xchg				;
		mvi	B, 20+20		;
		call	clrmem			; clear work area
		xchg				;
		mvi	B, 20			; byte counter
		mvi	C, 1			; first bit
		mvi	D, 0			; bit counter
@@loop:		mov	E, M			;
@@byte:		mov	A, E			;
		ana	C			;
		jz	@@skip			;
		inr	D			; found nonzero bit
						;
@@skip:		mov	A, C			;
		rlc				;
		mov	C, A			;
		cpi	1			;
		jnz	@@byte			;
		inx	H			;
		dcr	B			;
		jnz	@@loop			;
;
; got number of 1-bits in mask in D
;
		mov	A, D			;
		ani	0f8h			;
		rrc                             ;
		rrc                             ;
		rrc				; divide by 8 (get byte offset)
		mov	L, A			;
		mvi	H, 0			;
		mov	A, D			;
		ani	7			; bit offset
		inr	A			;
		mov	B, A			;
		mvi	A, 080h			;
@@rlc:		rlc          			;
		dcr	B			;
		jnz	@@rlc			;
		pop	D			;
		dad	D			;
		lxi	D, 20			;
		dad	D			;
		mov	M, A			;
		ret				;

;_______________________________________________________________________
;
; multi-byte counter
;
count:		lxi	H, counter		; 20 byte counter starts here
		lxi	D, counter+20		; somewhere in here is the stop bit
@@loop:		inr	M			;
		jz	@@next			; overflow to next byte
		ldax	D			;
		ana	M			; test for terminal value
		rz				;
		mvi	M, 0			; reset to zero
		ret				; ZF = 0 (not zero) returned
						;
@@next:		inx	H			;
		inx	D			;
		jmp	@@loop			;
						;
;_______________________________________________________________________
;
; multi-byte shifter
;
shift:		lxi	H, shifter		; 20 byte shift register starts here
		lxi	D, shifter+20		; somewhere in here is the stop bit
@@loop:		mov	A, M			;
		ora	A			;
		jz	@@next			;
		mov	B, A           		;
		ldax	D			;
		ana	B			;
		rnz				;
		mov	A, B			;
		rlc				;
		cpi	1			;
		jnz	@@done			;
		mvi	M, 0			;
		inx	H			;
		inx	D			;
@@done:		mov	M, A			;
		xra	a			; set Z
		ret				;
@@next:		inx	H			;
		inx	D			;
		jmp	@@loop			;
						;
counter: 	ds	2*20			;
shifter: 	ds	2*20			;
						;
; test harness
test:	
	di			; disable interrupts

;#idb ld (spsav),sp replaced by following code
;#idb All registers and flages are immediately overwritten so
;#idb no need to preserve any state.
	lxi	h,0		; save stack pointer
	dad	sp
	shld	spsav
;#idb

	lxi	sp,msbt+2	; point to test-case machine state

;#idb pop iy	
;#idb pop ix both replaced by following code
;#idb Just dummy out ix/iy with copies of hl
	pop	h		; and load all regs
	pop	h
;#idb

	pop	h
	pop	d
	pop	b
	pop	psw

;#idb ld sp,(spbt) replaced with the following code
;#idb HL is copied/restored before/after load so no state changed
	shld	temp
	lhld	spbt
	sphl
	lhld	temp
;#idb

iut:	ds	4		; max 4 byte instruction under test

;#idb ld (spat),sp replaced with the following code
;#idb Must be very careful to preserve registers and flag
;#idb state resulting from the test.  The temptation is to use the
;#idb stack - but that doesn't work because of the way the app
;#idb uses SP as a quick way of pointing to memory.
;#idb Bit of a code smell, but I can't think of an easier way.
	shld	temp
	lxi	h,0
	jc	temp1		;jump on the state of the C flag set in the test

	dad	sp		;this code will clear the C flag (0 + nnnn = nc)
	jmp	temp2		;C flag is same state as before

temp1:	dad	sp		;this code will clear the C flag (0 + nnnn = nc)
	stc			;C flage needs re-setting to preserve state

temp2:	shld	spat
	lhld	temp
;#idb

	lxi	sp,spat
	push	psw		; save other registers
	push	b
	push	d
	push	h

;#idb push ix
;#idb push iy both replaced by following code
;#idb Must match change made to pops made before test
	push	h
	push	h
;#idb

;#idb ld sp,(spsav) replaced with following code
;#idb No need to preserve state
	lhld	spsav		; restore stack pointer
	sphl
;#idb

	ei			; enable interrupts
	lhld	msbt		; copy memory operand
	shld	msat
	lxi	h,flgsat	; flags after test
	mov	a,m
flgmsk:	ani	0ffh		; mask-out irrelevant bits (self-modified code!)
	mov	m,a
	mvi	b,16		; total of 16 bytes of state
	lxi	d,msat
tcrc:	ldax	d
	inx	d
	call	updcrc		; accumulate crc of this test case
	dcr	b
	jnz	tcrc
	ret

;#idb Added to store HL state
temp:	ds	2
;#idb

; machine state after test
msat:	ds	14	; memop,iy,ix,hl,de,bc,af
spat:	ds	2	; stack pointer after test
flgsat	equ	spat-2	; flags

spsav:	ds	2	; saved stack pointer

;_______________________________________________________________________
;
; get next counter bit in low bit of a counter/shifter
;
nxtbit		macro	mask			;
		local	lab0, lab1		;		
						;
        	ldax	D			;
		ana	H			;
		dad	H			;
		jnz	lab0			;
		rnc				;
		mvi	H, 1			;
		inx	D			;
		ret				;
						;
lab0: 		jnc	lab1			;
		mvi	H, 1			;
		inx	D			;
lab1:        	mvi	A, mask			;
		xra	C			; flip bit if shifter bit was set
		mov	C, A			;
		ret                     	;
		endm				;
						;
nxtbit0:	nxtbit	001h			;
nxtbit1:	nxtbit	002h			;
nxtbit2:	nxtbit	004h			;
nxtbit3:	nxtbit	008h			;
nxtbit4:	nxtbit	010h			;
nxtbit5:	nxtbit	020h			;
nxtbit6:	nxtbit	040h			;
nxtbit7:	nxtbit	080h			;
						;	
;_______________________________________________________________________
;
wait1:		ei				;
		hlt				;
		ret				;
						;
		push	H			;
		lxi	H, -fclk/24		;
@@wait:		inx	H			;
		mov	A, H    		;
		ora	L			;
		jnz	@@wait			;
		pop	H			;
		ret				;
						;
waitms:		call	wait1			;
		dcr	H			;
		jnz	waitms			;
		ret				;
						;
waitk:		lxi	H, keys			;
		mov	A, M			;
		rrc				;
		jc	@@wk5			;
		mvi	H, 20			;
		call	waitms			;
		lxi	H, keys			;
		mov	A, M			;
		rrc				;
		jc	@@wk5			;
@@wk0:		mvi	H, 20			;
		call	waitms			;
		lxi	H, keys                 ;
		mov	A, M			;
		rrc				;
		jnc	@@wk0			;
		mvi	H, 20			;
		call	waitms			;
		lxi	H, keys			;
		mov	A, M			;
		rrc				;
		jnc	@@wk0			;
		ret				;
						;
@@wk5:		mvi	H, 250			;
		call	waitms			;
		lxi	H, leds			;
		mvi	M, 1			;
		mvi	H, 250			;
		call	waitms			;
		lxi	H, leds			;
		mvi	M, 0			;
		jmp	waitk			;
;_______________________________________________________________________
;
; display hex
; display the big-endian 32-bit value pointed to by hl
;
phex8:		push	PSW			;
		push	H			;
		mov	A, M			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	puthd			;
		mov	A, M			;
		call	puthd			;
		inx	H			;
		mov	A, M			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	puthd			;
		mov	A, M			;
		call	puthd			;
		inx	H			;
		mov	A, M			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	puthd			;
		mov	A, M			;
		call	puthd			;
		inx	H			;
		mov	A, M			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	puthd			;
		mov	A, M			;
		call	puthd			;
		pop	H			;
		pop	PSW			;
		ret				;
						;
hexlo:		push	D			;
		lxi	D, disp+0		;
		mov	A, L			;
		call	hconv			;
		stax	D			;
		inx	D			;
		mov	A, L			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	hconv			;
		stax	D			;
		inx	D			;
		mov	A, H			;
		call	hconv			;
		stax	D			;
		inx	D			;
		mov	A, H			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	hconv			;
		stax	D			;
		pop	D			;
		ret				;
						;
hconv:		push	H			;
		push	D			;
		lxi	H, hextt		;
		ani	0Fh			;
		mov	E, A			;
		mvi	D, 0			;
		dad	D			;
		mov	A, M			;
		pop	D			;
		pop	H			;
		ret				;
						;
hextt:		db	03Fh, 006h, 05Bh, 04Fh	;
		db	066h, 06Dh, 07Dh, 007h	;
		db	07Fh, 06Fh, 077h, 07Ch	;
		db	039h, 05Eh, 079h, 071h 	;
						;
;_______________________________________________________________________
;
; Console routines
;
print:		mov	A, M			; HL - pointer to
		ana	A			; ASCIZ line to output
		rz				;
		call	putch			;
		inx	H			;
		jmp	print			;
						;
puthx:		mov	A, H			; HL - 16bit hex to output
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	puthd			;
		mov	A, H			;
		call	puthd			;
		mov	A, L			;
		rrc				;
		rrc				;
		rrc				;
		rrc				;
		call	puthd			;
		mov	A, L			;
		call	puthd			;
		ret				;
						;
puthd:		ani	0Fh			; put one hex digit
		adi	'0'			;
		cpi	'9'+1			;
		jc	putch			;
		adi	'A'-'0'-10		;

putch:		push	PSW			; char to output in A
@@wait:		lda	ucsr			;
		ani	tx_ready		;
		jz	@@wait			;		
		pop	PSW			;
		sta	udat			;
		ret				;
						;
getch:		lda	ucsr			; returns in[ut char in A
		ani	rx_ready		;
		jz	getch			;		
		lda	udat			;
		ret				;
;_______________________________________________________________________
;
; 32-bit crc routine
; entry: a contains next byte, hl points to crc
; exit:  crc updated
;
updcrc:		push	B			;
		push	D			;
		lxi	H, crcval+3		;
		xra	M			; xor with new byte
		mov	L, A			;
		mvi	H, 0			;
		dad	H			; use result as index into table of 4 byte entries
		dad	H			;
		lxi	D, crctab		;
		dad	D			; point to selected entry in crctab
		xchg				;
		lxi	H, crcval		;
						;
		ldax	D			;
		mov	B, M			;
		mov	M, A			;
		inx	D                       ;
		inx	H			;
						;
		ldax	D			;
		xra	B			;
		mov	B, M			;
		mov	M, A			;
		inx	D			;
		inx	H			;
		        			;
		ldax	D			;
		xra	B			;
		mov	B, M			;
		mov	M, A			;
		inx	D			;
		inx	H			;
						;
		ldax	D			;
		xra	B			;
		mov	M, A			;
		pop	D			;
		pop	B			;
		ret				;
;_______________________________________________________________________
;
initcrc:	push	PSW			;
		push	B			;
		push	H			;
		lxi	H, crcval		;
		mvi	A, 0FFh			;
		mvi	B, 4			;
@@loop:		mov	M, A			;
		inx	H			;
		dcr	B			;
		jnz	@@loop			;
		pop	H			;
		pop	B			;
		pop	PSW			;
		ret				;
;_______________________________________________________________________
;
crctab:		db	000h,000h,000h,000h
		db	077h,007h,030h,096h
		db	0eeh,00eh,061h,02ch
		db	099h,009h,051h,0bah
		db	007h,06dh,0c4h,019h
		db	070h,06ah,0f4h,08fh
		db	0e9h,063h,0a5h,035h
		db	09eh,064h,095h,0a3h
		db	00eh,0dbh,088h,032h
		db	079h,0dch,0b8h,0a4h
		db	0e0h,0d5h,0e9h,01eh
		db	097h,0d2h,0d9h,088h
		db	009h,0b6h,04ch,02bh
		db	07eh,0b1h,07ch,0bdh
		db	0e7h,0b8h,02dh,007h
		db	090h,0bfh,01dh,091h
		db	01dh,0b7h,010h,064h
		db	06ah,0b0h,020h,0f2h
		db	0f3h,0b9h,071h,048h
		db	084h,0beh,041h,0deh
		db	01ah,0dah,0d4h,07dh
		db	06dh,0ddh,0e4h,0ebh
		db	0f4h,0d4h,0b5h,051h
		db	083h,0d3h,085h,0c7h
		db	013h,06ch,098h,056h
		db	064h,06bh,0a8h,0c0h
		db	0fdh,062h,0f9h,07ah
		db	08ah,065h,0c9h,0ech
		db	014h,001h,05ch,04fh
		db	063h,006h,06ch,0d9h
		db	0fah,00fh,03dh,063h
		db	08dh,008h,00dh,0f5h
		db	03bh,06eh,020h,0c8h
		db	04ch,069h,010h,05eh
		db	0d5h,060h,041h,0e4h
		db	0a2h,067h,071h,072h
		db	03ch,003h,0e4h,0d1h
		db	04bh,004h,0d4h,047h
		db	0d2h,00dh,085h,0fdh
		db	0a5h,00ah,0b5h,06bh
		db	035h,0b5h,0a8h,0fah
		db	042h,0b2h,098h,06ch
		db	0dbh,0bbh,0c9h,0d6h
		db	0ach,0bch,0f9h,040h
		db	032h,0d8h,06ch,0e3h
		db	045h,0dfh,05ch,075h
		db	0dch,0d6h,00dh,0cfh
		db	0abh,0d1h,03dh,059h
		db	026h,0d9h,030h,0ach
		db	051h,0deh,000h,03ah
		db	0c8h,0d7h,051h,080h
		db	0bfh,0d0h,061h,016h
		db	021h,0b4h,0f4h,0b5h
		db	056h,0b3h,0c4h,023h
		db	0cfh,0bah,095h,099h
		db	0b8h,0bdh,0a5h,00fh
		db	028h,002h,0b8h,09eh
		db	05fh,005h,088h,008h
		db	0c6h,00ch,0d9h,0b2h
		db	0b1h,00bh,0e9h,024h
		db	02fh,06fh,07ch,087h
		db	058h,068h,04ch,011h
		db	0c1h,061h,01dh,0abh
		db	0b6h,066h,02dh,03dh
		db	076h,0dch,041h,090h
		db	001h,0dbh,071h,006h
		db	098h,0d2h,020h,0bch
		db	0efh,0d5h,010h,02ah
		db	071h,0b1h,085h,089h
		db	006h,0b6h,0b5h,01fh
		db	09fh,0bfh,0e4h,0a5h
		db	0e8h,0b8h,0d4h,033h
		db	078h,007h,0c9h,0a2h
		db	00fh,000h,0f9h,034h
		db	096h,009h,0a8h,08eh
		db	0e1h,00eh,098h,018h
		db	07fh,06ah,00dh,0bbh
		db	008h,06dh,03dh,02dh
		db	091h,064h,06ch,097h
		db	0e6h,063h,05ch,001h
		db	06bh,06bh,051h,0f4h
		db	01ch,06ch,061h,062h
		db	085h,065h,030h,0d8h
		db	0f2h,062h,000h,04eh
		db	06ch,006h,095h,0edh
		db	01bh,001h,0a5h,07bh
		db	082h,008h,0f4h,0c1h
		db	0f5h,00fh,0c4h,057h
		db	065h,0b0h,0d9h,0c6h
		db	012h,0b7h,0e9h,050h
		db	08bh,0beh,0b8h,0eah
		db	0fch,0b9h,088h,07ch
		db	062h,0ddh,01dh,0dfh
		db	015h,0dah,02dh,049h
		db	08ch,0d3h,07ch,0f3h
		db	0fbh,0d4h,04ch,065h
		db	04dh,0b2h,061h,058h
		db	03ah,0b5h,051h,0ceh
		db	0a3h,0bch,000h,074h
		db	0d4h,0bbh,030h,0e2h
		db	04ah,0dfh,0a5h,041h
		db	03dh,0d8h,095h,0d7h
		db	0a4h,0d1h,0c4h,06dh
		db	0d3h,0d6h,0f4h,0fbh
		db	043h,069h,0e9h,06ah
		db	034h,06eh,0d9h,0fch
		db	0adh,067h,088h,046h
		db	0dah,060h,0b8h,0d0h
		db	044h,004h,02dh,073h
		db	033h,003h,01dh,0e5h
		db	0aah,00ah,04ch,05fh
		db	0ddh,00dh,07ch,0c9h
		db	050h,005h,071h,03ch
		db	027h,002h,041h,0aah
		db	0beh,00bh,010h,010h
		db	0c9h,00ch,020h,086h
		db	057h,068h,0b5h,025h
		db	020h,06fh,085h,0b3h
		db	0b9h,066h,0d4h,009h
		db	0ceh,061h,0e4h,09fh
		db	05eh,0deh,0f9h,00eh
		db	029h,0d9h,0c9h,098h
		db	0b0h,0d0h,098h,022h
		db	0c7h,0d7h,0a8h,0b4h
		db	059h,0b3h,03dh,017h
		db	02eh,0b4h,00dh,081h
		db	0b7h,0bdh,05ch,03bh
		db	0c0h,0bah,06ch,0adh
		db	0edh,0b8h,083h,020h
		db	09ah,0bfh,0b3h,0b6h
		db	003h,0b6h,0e2h,00ch
		db	074h,0b1h,0d2h,09ah
		db	0eah,0d5h,047h,039h
		db	09dh,0d2h,077h,0afh
		db	004h,0dbh,026h,015h
		db	073h,0dch,016h,083h
		db	0e3h,063h,00bh,012h
		db	094h,064h,03bh,084h
		db	00dh,06dh,06ah,03eh
		db	07ah,06ah,05ah,0a8h
		db	0e4h,00eh,0cfh,00bh
		db	093h,009h,0ffh,09dh
		db	00ah,000h,0aeh,027h
		db	07dh,007h,09eh,0b1h
		db	0f0h,00fh,093h,044h
		db	087h,008h,0a3h,0d2h
		db	01eh,001h,0f2h,068h
		db	069h,006h,0c2h,0feh
		db	0f7h,062h,057h,05dh
		db	080h,065h,067h,0cbh
		db	019h,06ch,036h,071h
		db	06eh,06bh,006h,0e7h
		db	0feh,0d4h,01bh,076h
		db	089h,0d3h,02bh,0e0h
		db	010h,0dah,07ah,05ah
		db	067h,0ddh,04ah,0cch
		db	0f9h,0b9h,0dfh,06fh
		db	08eh,0beh,0efh,0f9h
		db	017h,0b7h,0beh,043h
		db	060h,0b0h,08eh,0d5h
		db	0d6h,0d6h,0a3h,0e8h
		db	0a1h,0d1h,093h,07eh
		db	038h,0d8h,0c2h,0c4h
		db	04fh,0dfh,0f2h,052h
		db	0d1h,0bbh,067h,0f1h
		db	0a6h,0bch,057h,067h
		db	03fh,0b5h,006h,0ddh
		db	048h,0b2h,036h,04bh
		db	0d8h,00dh,02bh,0dah
		db	0afh,00ah,01bh,04ch
		db	036h,003h,04ah,0f6h
		db	041h,004h,07ah,060h
		db	0dfh,060h,0efh,0c3h
		db	0a8h,067h,0dfh,055h
		db	031h,06eh,08eh,0efh
		db	046h,069h,0beh,079h
		db	0cbh,061h,0b3h,08ch
		db	0bch,066h,083h,01ah
		db	025h,06fh,0d2h,0a0h
		db	052h,068h,0e2h,036h
		db	0cch,00ch,077h,095h
		db	0bbh,00bh,047h,003h
		db	022h,002h,016h,0b9h
		db	055h,005h,026h,02fh
		db	0c5h,0bah,03bh,0beh
		db	0b2h,0bdh,00bh,028h
		db	02bh,0b4h,05ah,092h
		db	05ch,0b3h,06ah,004h
		db	0c2h,0d7h,0ffh,0a7h
		db	0b5h,0d0h,0cfh,031h
		db	02ch,0d9h,09eh,08bh
		db	05bh,0deh,0aeh,01dh
		db	09bh,064h,0c2h,0b0h
		db	0ech,063h,0f2h,026h
		db	075h,06ah,0a3h,09ch
		db	002h,06dh,093h,00ah
		db	09ch,009h,006h,0a9h
		db	0ebh,00eh,036h,03fh
		db	072h,007h,067h,085h
		db	005h,000h,057h,013h
		db	095h,0bfh,04ah,082h
		db	0e2h,0b8h,07ah,014h
		db	07bh,0b1h,02bh,0aeh
		db	00ch,0b6h,01bh,038h
		db	092h,0d2h,08eh,09bh
		db	0e5h,0d5h,0beh,00dh
		db	07ch,0dch,0efh,0b7h
		db	00bh,0dbh,0dfh,021h
		db	086h,0d3h,0d2h,0d4h
		db	0f1h,0d4h,0e2h,042h
		db	068h,0ddh,0b3h,0f8h
		db	01fh,0dah,083h,06eh
		db	081h,0beh,016h,0cdh
		db	0f6h,0b9h,026h,05bh
		db	06fh,0b0h,077h,0e1h
		db	018h,0b7h,047h,077h
		db	088h,008h,05ah,0e6h
		db	0ffh,00fh,06ah,070h
		db	066h,006h,03bh,0cah
		db	011h,001h,00bh,05ch
		db	08fh,065h,09eh,0ffh
		db	0f8h,062h,0aeh,069h
		db	061h,06bh,0ffh,0d3h
		db	016h,06ch,0cfh,045h
		db	0a0h,00ah,0e2h,078h
		db	0d7h,00dh,0d2h,0eeh
		db	04eh,004h,083h,054h
		db	039h,003h,0b3h,0c2h
		db	0a7h,067h,026h,061h
		db	0d0h,060h,016h,0f7h
		db	049h,069h,047h,04dh
		db	03eh,06eh,077h,0dbh
		db	0aeh,0d1h,06ah,04ah
		db	0d9h,0d6h,05ah,0dch
		db	040h,0dfh,00bh,066h
		db	037h,0d8h,03bh,0f0h
		db	0a9h,0bch,0aeh,053h
		db	0deh,0bbh,09eh,0c5h
		db	047h,0b2h,0cfh,07fh
		db	030h,0b5h,0ffh,0e9h
		db	0bdh,0bdh,0f2h,01ch
		db	0cah,0bah,0c2h,08ah
		db	053h,0b3h,093h,030h
		db	024h,0b4h,0a3h,0a6h
		db	0bah,0d0h,036h,005h
		db	0cdh,0d7h,006h,093h
		db	054h,0deh,057h,029h
		db	023h,0d9h,067h,0bfh
		db	0b3h,066h,07ah,02eh
		db	0c4h,061h,04ah,0b8h
		db	05dh,068h,01bh,002h
		db	02ah,06fh,02bh,094h
		db	0b4h,00bh,0beh,037h
		db	0c3h,00ch,08eh,0a1h
		db	05ah,005h,0dfh,01bh
		db	02dh,002h,0efh,08dh

crcval:		ds	4

		org	(($+255)/256)*256
stable:		ds	8192
		ds	256
stack:	
;_______________________________________________________________________
;
msg0:		db	10, 10, 13, "i8080 instruction exerciser"
		db	10, 13, "Some tests take a long time (minutes)"
		db	10, 13, "You can press ESC to skip the test", 10, 13, 0
msg1:		db	"skipped", 0
msg2:		db	"wait...", 0
msg3:		db	10, 13, 10, 13, "Exerciser completed", 10, 13, 0
msg4:		db	8, 8, 8, 8, 8, 8, 8, 0

;_______________________________________________________________________
;
; DAD <B,D,H,SP>		14474BA6
; ALUOP NN			9E922F9E
; ALUOP <B,C,D,E,H,L,M,A>	CF762C86
; <DAA,CMA,STC,CMC>		BB3F030C
; <INR,DCR> A			ADB6460E
; <INR,DCR> B			83ED1345
; <INX,DCX> B			F79287CD
; <INR,DCR> C			E5F6721B
; <INR,DCR> D			15B5579A
; <INX,DCX> D			7F4E2501
; <INR,DCR> E			CF2AB396
; <INR,DCR> H			12B2952C
; <INX,DCX> H			9F2B23C0
; <INR,DCR> L			FF57D356
; <INR,DCR> M			92E963BD
; <INX,DCX> SP			D5702FAB
; LHLD NNNN			A9C3D5CB
; SHLD NNNN			E8864F26
; LXI <B,D,H,SP>,NNNN		FCF46E12
; LDAX <B,D>			2B821D5F
; MVI <B..L,M,A>,NN		EAA72044
; MOV <B..L,A>,<B..L,A>		10B58CEE
; STA NNNN / LDA NNNN		ED57AF72
; <RLC,RRC,RAL,RAR>		E0D89235
; STAX <B,D>			2B0471E9
;_______________________________________________________________________
;
                end	entry
