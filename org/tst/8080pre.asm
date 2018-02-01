	title	'Preliminary Z80 tests'

; prelim.z80 - Preliminary Z80 tests
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
;
;
; These tests have two goals.  To start with, we assume the worst and
; successively test the instructions needed to continue testing.
; Then we try to test all instructions which cannot be handled by
; zexlax - the crc-based instruction exerciser.
;
; Initially errors are 'reported' by jumping to 0.  This should reboot
; cp/m, so if the program terminates without any output one of the
; early tests failed.  Later errors are reported by outputting an
; address via the bdos conout routine.  The address can be located in
; a listing of this program.
;
; If the program runs to completion it displays a suitable message.
;
;******************************************************************************
;
; Modified by Ian Bartholomew to run a preliminary test on an 8080 CPU
;
; Assemble using M80
;
;******************************************************************************

fault   equ     8000h

	.8080
	aseg
	org	0h

start:	lxi	SP, stack
	mvi	A, 1		; test simple compares and z/nz jumps
	cpi	2
	jz	fault+$
	cpi	1
	jnz	fault+$
	jmp	lab0
	hlt			; emergency exit
	db	0FFh
	
lab0:	call	lab2		; does a simple call work?
lab1:	jmp	fault+$		; fail
	
lab2:	pop	H		; check return address
	mov	A, H
	cpi	high lab1
	jz	lab3
	jmp	fault+$
lab3:	mov	A, L
	cpi	low lab1
	jz	lab4
	jmp	fault+$

; test presence and uniqueness of all machine registers
; (except ir)
lab4:	lxi	SP, regs1
	pop	PSW
	pop	B
	pop	D
	pop	H
	lxi	SP, regs2+8
	push	H
	push	D
	push	B
	push	PSW

	lda	regs2+0
	cpi	2
	jnz	fault+$
	lda	regs2+1
	cpi	4
	jnz	fault+$
	lda	regs2+2
	cpi	6
	jnz	fault+$
	lda	regs2+3
	cpi	8
	jnz	fault+$

	lda	regs2+4
	cpi	10
	jnz	fault+$
	lda	regs2+5
	cpi	12
	jnz	fault+$
	lda	regs2+6
	cpi	14
	jnz	fault+$
	lda	regs2+7
	cpi	16
	jnz	fault+$

; test access to memory via (HL)
	lxi	H, hlval
	mov	A, M
	cpi	0A5h
	jnz	fault+$
	lxi	H, hlval+1
	mov	A, M
	cpi	03Ch
	jnz	fault+$

; test unconditional return
	lxi	SP, stack
	lxi	H, reta
	push	H
	ret
	jmp	fault+$

; test instructions needed for hex output
reta:	mvi	A, 0FFh
	ani	0Fh
	cpi	0Fh
	jnz	fault+$
	mvi	A, 05Ah
	ani	0Fh
	cpi	0Ah
	jnz	fault+$
	rrc
	cpi	05h
	jnz	fault+$
	rrc
	cpi	82h
	jnz	fault+$
	rrc
	cpi	41h
	jnz	fault+$
	rrc
	cpi	0a0h
	jnz	fault+$
	lxi	H, 01234h
	push	H
	pop	B
	mov	A, B
	cpi	12h
	jnz	fault+$
	mov	A, C
	cpi	34h
	jnz	fault+$

; test conditional call, ret, jp, jr
tcond	macro	flag, pcond, ncond
	lxi	H, flag
	push	H
	pop	psw
	c`pcond	lab1`pcond
	jmp	fault+$

lab1`pcond:	
	pop	H
	lxi	H, 0D7h xor flag
	push	H
	pop	PSW
	c`ncond	lab2`pcond
	jmp	fault+$

lab2`pcond:
	pop	H
	lxi	H,lab3`pcond
	push	H
	lxi	H, flag
	push	H
	pop	PSW
	r`pcond
	jmp 	fault+$

lab3`pcond:	
	lxi	H,lab4`pcond
	push	H
	lxi	H, 0D7h xor flag
	push	H
	pop	PSW
	r`ncond
	jmp 	fault+$

lab4`pcond:	
	lxi	H, flag
	push	H
	pop	PSW
	j`pcond	lab5`pcond
	jmp 	fault+$

lab5`pcond:
	lxi	H, 0D7h xor flag
	push	H
	pop	PSW
	j`ncond	lab6`pcond
	jmp 	fault+$

lab6`pcond:	
	endm

	tcond	001h, c,  nc
	tcond	004h, pe, po
	tcond	040h, z,  nz
	tcond	080h, m,  p

; test indirect jumps
	lxi	H,lab7
	pchl
	jmp	fault+$

; djnz (and (partially) inc a, inc hl)
lab7:	mvi	A, 0A5h
	mvi	B, 4
lab8:	rrc
	dcr	B
	jnz	lab8
	cpi	05Ah
	cnz	fault+$
	mvi	B, 16
lab9:	inr	A
	dcr	B
	jnz	lab9
	cpi	06Ah
	cnz	fault+$
	mvi	B, 0
	lxi	H, 0
lab10:	inx	H
	dcr	B
	jnz	lab10
	mov	A, H
	cpi	1
	cnz	fault+$
	mov	a,l
	cpi	0
	cnz	fault+$
	
allok:	lxi	H, 0FFFFh;
	mov	A, M
	jmp	fault+$
	
regs1:	db	2, 4, 6, 8, 10, 12, 14, 16
regs2:	ds	8,0

hlval:	db	0A5h,03Ch
	
	ds	120
stack	equ	$
	end	start
