	title	'Preliminary vm80a_core tests'

disp	equ     0FFF8h

	.8080
	aseg
	org	0h

start:	lxi	SP, stack
	mvi	A, 1		; test simple compares and z/nz jumps
	cpi	2
	cz	fault
	cpi	1
	cnz	fault
	jmp	lab0
	hlt			; emergency exit
	db	0FFh
	
lab0:	call	lab2		; does a simple call work?
lab1:	call	fault		; fail
	
lab2:	pop	H		; check return address
	mov	A, H
	cpi	high lab1
	jz	lab3
	call	fault
lab3:	mov	A, L
	cpi	low lab1
	jz	lab4
	call	fault

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
	cnz	fault
	lda	regs2+1
	cpi	4
	cnz	fault
	lda	regs2+2
	cpi	6
	cnz	fault
	lda	regs2+3
	cpi	8
	cnz	fault

	lda	regs2+4
	cpi	10
	cnz	fault
	lda	regs2+5
	cpi	12
	cnz	fault
	lda	regs2+6
	cpi	14
	cnz	fault
	lda	regs2+7
	cpi	16
	cnz	fault

; test access to memory via (HL)
	lxi	H, hlval
	mov	A, M
	cpi	0A5h
	cnz	fault
	lxi	H, hlval+1
	mov	A, M
	cpi	03Ch
	cnz	fault

; test unconditional return
	lxi	SP, stack
	lxi	H, reta
	push	H
	ret
	jmp	fault

; test instructions needed for hex output
reta:	mvi	A, 0FFh
	ani	0Fh
	cpi	0Fh
	cnz	fault
	mvi	A, 05Ah
	ani	0Fh
	cpi	0Ah
	cnz	fault
	rrc
	cpi	05h
	cnz	fault
	rrc
	cpi	82h
	cnz	fault
	rrc
	cpi	41h
	cnz	fault
	rrc
	cpi	0a0h
	cnz	fault
	lxi	H, 01234h
	push	H
	pop	B
	mov	A, B
	cpi	12h
	cnz	fault
	mov	A, C
	cpi	34h
	cnz	fault

; test conditional call, ret, jp, jr
tcond	macro	flag, pcond, ncond
	lxi	H, flag
	push	H
	pop	psw
	c`pcond	lab1`pcond
	call	fault

lab1`pcond:	
	pop	H
	lxi	H, 0D7h xor flag
	push	H
	pop	PSW
	c`ncond	lab2`pcond
	call	fault

lab2`pcond:
	pop	H
	lxi	H,lab3`pcond
	push	H
	lxi	H, flag
	push	H
	pop	PSW
	r`pcond
	call 	fault

lab3`pcond:	
	lxi	H,lab4`pcond
	push	H
	lxi	H, 0D7h xor flag
	push	H
	pop	PSW
	r`ncond
	call 	fault

lab4`pcond:	
	lxi	H, flag
	push	H
	pop	PSW
	j`pcond	lab5`pcond
	call 	fault

lab5`pcond:
	lxi	H, 0D7h xor flag
	push	H
	pop	PSW
	j`ncond	lab6`pcond
	call 	fault

lab6`pcond:	
	endm

	tcond	001h, c,  nc
	tcond	004h, pe, po
	tcond	040h, z,  nz
	tcond	080h, m,  p

; test indirect jumps
	lxi	H,lab7
	pchl
	call	fault

; djnz (and (partially) inc a, inc hl)
lab7:	mvi	A, 0A5h
	mvi	B, 4
lab8:	rrc
	dcr	B
	jnz	lab8
	cpi	05Ah
	cnz	fault
	mvi	B, 16
lab9:	inr	A
	dcr	B
	jnz	lab9
	cpi	06Ah
	cnz	fault
	mvi	B, 0
	lxi	H, 0
lab10:	inx	H
	dcr	B
	jnz	lab10
	mov	A, H
	cpi	1
	cnz	fault
	mov	a,l
	cpi	0
	cnz	fault
;_____________________________________________________
;	
; test jump instructions and flags
;
	ani	0	; initialize a reg and clear all flags
	jz	J010	;TEST "JZ"
	CALL	fault
J010:	JNC	J020	;TEST "JNC"
	CALL	fault
J020:	JPE	J030	;TEST "JPE"
	CALL	fault
J030:	JP	J040	;TEST "JP"
	CALL	fault
J040:	JNZ	J050	;TEST "JNZ"
	JC	J050	;TEST "JC"
	JPO	J050	;TEST "JPO"
	JM	J050	;TEST "JM"
	JMP	J060	;TEST "JMP" (IT'S A LITTLE LATE,BUT WHAT THE HELL!
J050:	CALL	fault
J060:	ADI	6	;A=6,C=0,P=1,S=0,Z=0
	JNZ	J070	;TEST "JNZ"
	CALL	fault
J070:	JC	J080	;TEST "JC"
	JPO	J080	;TEST "JPO"
	JP	J090	;TEST "JP"
J080:	CALL	fault
J090:	ADI	070H	;A=76H,C=0,P=0,S=0,Z=0
	JPO	J100	;TEST "JPO"
	CALL	fault
J100:	JM	J110	;TEST "JM"
	JZ	J110	;TEST "JZ"
	JNC	J120	;TEST "JNC"
J110:	CALL	fault
J120:	ADI	081H	;A=F7H,C=0,P=0,S=1,Z=0
	JM	J130	;TEST "JM"
	CALL	fault
J130:	JZ	J140	;TEST "JZ"
	JC	J140	;TEST "JC"
	JPO	J150	;TEST "JPO"
J140:	CALL	fault
J150:	ADI	0FEH	;A=F5H,C=1,P=1,S=1,Z=0
	JC	J160	;TEST "JC"
	CALL	fault
J160:	JZ	J170	;TEST "JZ"
	JPO	J170	;TEST "JPO"
	JM	AIMM	;TEST "JM"
J170:	CALL	fault
;
;
;
;TEST ACCUMULATOR IMMEDIATE INSTRUCTIONS
;
AIMM:	CPI	0	;A=F5H,C=0,Z=0
	JC	CPIE	;TEST "CPI" FOR RE-SET CARRY
	JZ	CPIE	;TEST "CPI" FOR RE-SET ZERO
	CPI	0F5H	;A=F5H,C=0,Z=1
	JC	CPIE	;TEST "CPI" FOR RE-SET CARRY ("ADI")
	JNZ	CPIE	;TEST "CPI" FOR RE-SET ZERO
	CPI	0FFH	;A=F5H,C=1,Z=0
	JZ	CPIE	;TEST "CPI" FOR RE-SET ZERO
	JC	ACII	;TEST "CPI" FOR SET CARRY
CPIE:	CALL	fault
ACII:	ACI	00AH	;A=F5H+0AH+CARRY(1)=0,C=1
	ACI	00AH	;A=0+0AH+CARRY(0)=0BH,C=0
	CPI	00BH
	JZ	SUII	;TEST "ACI"
	CALL	fault
SUII:	SUI	00CH	;A=FFH,C=0
	SUI	00FH	;A=F0H,C=1
	CPI	0F0H
	JZ	SBII	;TEST "SUI"
	CALL	fault
SBII:	SBI	0F1H	;A=F0H-0F1H-CARRY(0)=FFH,C=1
	SBI	00EH	;A=FFH-OEH-CARRY(1)=F0H,C=0
	CPI	0F0H
	JZ	ANII	;TEST "SBI"
	CALL	fault
ANII:	ANI	055H	;A=F0H<AND>55H=50H,C=0,P=1,S=0,Z=0
	CPI	050H
	JZ	ORII	;TEST "ANI"
	CALL	fault
ORII:	ORI	03AH	;A=50H<OR>3AH=7AH,C=0,P=0,S=0,Z=0
	CPI	07AH
	JZ	XRII	;TEST "ORI"
	CALL	fault
XRII:	XRI	00FH	;A=7AH<XOR>0FH=75H,C=0,P=0,S=0,Z=0
	CPI	075H
	JZ	C010	;TEST "XRI"
	CALL	fault
;
;
;
;TEST CALLS AND RETURNS
;
C010:	ANI	000H	;A=0,C=0,P=1,S=0,Z=1
	CC	fault	;TEST "CC"
	CPO	fault	;TEST "CPO"
	CM	fault	;TEST "CM"
	CNZ	fault	;TEST "CNZ"
	CPI	000H
	JZ	C020	;A=0,C=0,P=0,S=0,Z=1
	CALL	fault
C020:	SUI	077H	;A=89H,C=1,P=0,S=1,Z=0
	CNC	fault	;TEST "CNC"
	CPE	fault	;TEST "CPE"
	CP	fault	;TEST "CP"
	CZ	fault	;TEST "CZ"
	CPI	089H
	JZ	C030	;TEST FOR "CALLS" TAKING BRANCH
	CALL	fault
C030:	ANI	0FFH	;SET FLAGS BACK!
	CPO	CPOI	;TEST "CPO"
	CPI	0D9H
	JZ	MOVI	;TEST "CALL" SEQUENCE SUCCESS
	CALL	fault
CPOI:	RPE		;TEST "RPE"
	ADI	010H	;A=99H,C=0,P=0,S=1,Z=0
	CPE	CPEI	;TEST "CPE"
	ADI	002H	;A=D9H,C=0,P=0,S=1,Z=0
	RPO		;TEST "RPO"
	CALL	fault
CPEI:	RPO		;TEST "RPO"
	ADI	020H	;A=B9H,C=0,P=0,S=1,Z=0
	CM	CMI	;TEST "CM"
	ADI	004H	;A=D7H,C=0,P=1,S=1,Z=0
	RPE		;TEST "RPE"
	CALL	fault
CMI:	RP		;TEST "RP"
	ADI	080H	;A=39H,C=1,P=1,S=0,Z=0
	CP	TCPI	;TEST "CP"
	ADI	080H	;A=D3H,C=0,P=0,S=1,Z=0
	RM		;TEST "RM"
	CALL	fault
TCPI:	RM		;TEST "RM"
	ADI	040H	;A=79H,C=0,P=0,S=0,Z=0
	CNC	CNCI	;TEST "CNC"
	ADI	040H	;A=53H,C=0,P=1,S=0,Z=0
	RP		;TEST "RP"
	CALL	fault
CNCI:	RC		;TEST "RC"
	ADI	08FH	;A=08H,C=1,P=0,S=0,Z=0
	CC	CCI	;TEST "CC"
	SUI	002H	;A=13H,C=0,P=0,S=0,Z=0
	RNC		;TEST "RNC"
	CALL	fault
CCI:	RNC		;TEST "RNC"
	ADI	0F7H	;A=FFH,C=0,P=1,S=1,Z=0
	CNZ	CNZI	;TEST "CNZ"
	ADI	0FEH	;A=15H,C=1,P=0,S=0,Z=0
	RC		;TEST "RC"
	CALL	fault
CNZI:	RZ		;TEST "RZ"
	ADI	001H	;A=00H,C=1,P=1,S=0,Z=1
	CZ	CZI	;TEST "CZ"
	ADI	0D0H	;A=17H,C=1,P=1,S=0,Z=0
	RNZ		;TEST "RNZ"
	CALL	fault
CZI:	RNZ		;TEST "RNZ"
	ADI	047H	;A=47H,C=0,P=1,S=0,Z=0
	CPI	047H	;A=47H,C=0,P=1,S=0,Z=1
	RZ		;TEST "RZ"
	CALL	fault
;
;
;
;TEST "MOV","INR",AND "DCR" INSTRUCTIONS
;
MOVI:	MVI	A,077H
	INR	A
	MOV	B,A
	INR	B
	MOV	C,B
	DCR	C
	MOV	D,C
	MOV	E,D
	MOV	H,E
	MOV	L,H
	MOV	A,L	;TEST "MOV" A,L,H,E,D,C,B,A
	DCR	A
	MOV	C,A
	MOV	E,C
	MOV	L,E
	MOV	B,L
	MOV	D,B
	MOV	H,D
	MOV	A,H	;TEST "MOV" A,H,D,B,L,E,C,A
	MOV	D,A
	INR	D
	MOV	L,D
	MOV	C,L
	INR	C
	MOV	H,C
	MOV	B,H
	DCR	B
	MOV	E,B
	MOV	A,E	;TEST "MOV" A,E,B,H,C,L,D,A
	MOV	E,A
	INR	E
	MOV	B,E
	MOV	H,B
	INR	H
	MOV	C,H
	MOV	L,C
	MOV	D,L
	DCR	D
	MOV	A,D	;TEST "MOV" A,D,L,C,H,B,E,A
	MOV	H,A
	DCR	H
	MOV	D,H
	MOV	B,D
	MOV	L,B
	INR	L
	MOV	E,L
	DCR	E
	MOV	C,E
	MOV	A,C	;TEST "MOV" A,C,E,L,B,D,H,A
	MOV	L,A
	DCR	L
	MOV	H,L
	MOV	E,H
	MOV	D,E
	MOV	C,D
	MOV	B,C
	MOV	A,B
	CPI	077H
	CNZ	fault	;TEST "MOV" A,B,C,D,E,H,L,A
;
;
;
;TEST ARITHMETIC AND LOGIC INSTRUCTIONS
;
	XRA	A
	MVI	B,001H
	MVI	C,003H
	MVI	D,007H
	MVI	E,00FH
	MVI	H,01FH
	MVI	L,03FH
	ADD	B
	ADD	C
	ADD	D
	ADD	E
	ADD	H
	ADD	L
	ADD	A
	CPI	0F0H
	CNZ	fault	;TEST "ADD" B,C,D,E,H,L,A
	SUB	B
	SUB	C
	SUB	D
	SUB	E
	SUB	H
	SUB	L
	CPI	078H
	CNZ	fault	;TEST "SUB" B,C,D,E,H,L
	SUB	A
	CNZ	fault	;TEST "SUB" A
	MVI	A,080H
	ADD	A
	MVI	B,001H
	MVI	C,002H
	MVI	D,003H
	MVI	E,004H
	MVI	H,005H
	MVI	L,006H
	ADC	B
	MVI	B,080H
	ADD	B
	ADD	B
	ADC	C
	ADD	B
	ADD	B
	ADC	D
	ADD	B
	ADD	B
	ADC	E
	ADD	B
	ADD	B
	ADC	H
	ADD	B
	ADD	B
	ADC	L
	ADD	B
	ADD	B
	ADC	A
	CPI	037H
	CNZ	fault	;TEST "ADC" B,C,D,E,H,L,A
	MVI	A,080H
	ADD	A
	MVI	B,001H
	SBB	B
	MVI	B,0FFH
	ADD	B
	SBB	C
	ADD	B
	SBB	D
	ADD	B
	SBB	E
	ADD	B
	SBB	H
	ADD	B
	SBB	L
	CPI	0E0H
	CNZ	fault	;TEST "SBB" B,C,D,E,H,L
	MVI	A,080H
	ADD	A
	SBB	A
	CPI	0FFH
	CNZ	fault	;TEST "SBB" A
	MVI	A,0FFH
	MVI	B,0FEH
	MVI	C,0FCH
	MVI	D,0EFH
	MVI	E,07FH
	MVI	H,0F4H
	MVI	L,0BFH
	ANA	A
	ANA	C
	ANA	D
	ANA	E
	ANA	H
	ANA	L
	ANA	A
	CPI	024H
	CNZ	fault	;TEST "ANA" B,C,D,E,H,L,A
	XRA	A
	MVI	B,001H
	MVI	C,002H
	MVI	D,004H
	MVI	E,008H
	MVI	H,010H
	MVI	L,020H
	ORA	B
	ORA	C
	ORA	D
	ORA	E
	ORA	H
	ORA	L
	ORA	A
	CPI	03FH
	CNZ	fault	;TEST "ORA" B,C,D,E,H,L,A
	MVI	A,000H
	MVI	H,08FH
	MVI	L,04FH
	XRA	B
	XRA	C
	XRA	D
	XRA	E
	XRA	H
	XRA	L
	CPI	0CFH
	CNZ	fault	;TEST "XRA" B,C,D,E,H,L
	XRA	A
	CNZ	fault	;TEST "XRA" A
	MVI	B,044H
	MVI	C,045H
	MVI	D,046H
	MVI	E,047H
	MVI	H,(TEMP0 / 0FFH)	;HIGH BYTE OF TEST MEMORY LOCATION
	MVI	L,(TEMP0 AND 0FFH)	;LOW BYTE OF TEST MEMORY LOCATION
	MOV	M,B
	MVI	B,000H
	MOV	B,M
	MVI	A,044H
	CMP	B
	CNZ	fault	;TEST "MOV" M,B AND B,M
	MOV	M,D
	MVI	D,000H
	MOV	D,M
	MVI	A,046H
	CMP	D
	CNZ	fault	;TEST "MOV" M,D AND D,M
	MOV	M,E
	MVI	E,000H
	MOV	E,M
	MVI	A,047H
	CMP	E
	CNZ	fault	;TEST "MOV" M,E AND E,M
	MOV	M,H
	MVI	H,(TEMP0 / 0FFH)
	MVI	L,(TEMP0 AND 0FFH)
	MOV	H,M
	MVI	A,(TEMP0 / 0FFH)
	CMP	H
	CNZ	fault	;TEST "MOV" M,H AND H,M
	MOV	M,L
	MVI	H,(TEMP0 / 0FFH)
	MVI	L,(TEMP0 AND 0FFH)
	MOV	L,M
	MVI	A,(TEMP0 AND 0FFH)
	CMP	L
	CNZ	fault	;TEST "MOV" M,L AND L,M
	MVI	H,(TEMP0 / 0FFH)
	MVI	L,(TEMP0 AND 0FFH)
	MVI	A,032H
	MOV	M,A
	CMP	M
	CNZ	fault	;TEST "MOV" M,A
	ADD	M
	CPI	064H
	CNZ	fault	;TEST "ADD" M
	XRA	A
	MOV	A,M
	CPI	032H
	CNZ	fault	;TEST "MOV" A,M
	MVI	H,(TEMP0 / 0FFH)
	MVI	L,(TEMP0 AND 0FFH)
	MOV	A,M
	SUB	M
	CNZ	fault	;TEST "SUB" M
	MVI	A,080H
	ADD	A
	ADC	M
	CPI	033H
	CNZ	fault	;TEST "ADC" M
	MVI	A,080H
	ADD	A
	SBB	M
	CPI	0CDH
	CNZ	fault	;TEST "SBB" M
	ANA	M
	CNZ	fault	;TEST "ANA" M
	MVI	A,025H
	ORA	M
	CPI	037H
	CNZ	fault	;TEST "ORA" M
	XRA	M
	CPI	005H
	CNZ	fault	;TEST "XRA" M
	MVI	M,055H
	INR	M
	DCR	M
	ADD	M
	CPI	05AH
	CNZ	fault	;TEST "INR","DCR",AND "MVI" M
	LXI	B,12FFH
	LXI	D,12FFH
	LXI	H,12FFH
	INX	B
	INX	D
	INX	H
	MVI	A,013H
	CMP	B
	CNZ	fault	;TEST "LXI" AND "INX" B
	CMP	D
	CNZ	fault	;TEST "LXI" AND "INX" D
	CMP	H
	CNZ	fault	;TEST "LXI" AND "INX" H
	MVI	A,000H
	CMP	C
	CNZ	fault	;TEST "LXI" AND "INX" B
	CMP	E
	CNZ	fault	;TEST "LXI" AND "INX" D
	CMP	L
	CNZ	fault	;TEST "LXI" AND "INX" H
	DCX	B
	DCX	D
	DCX	H
	MVI	A,012H
	CMP	B
	CNZ	fault	;TEST "DCX" B
	CMP	D
	CNZ	fault	;TEST "DCX" D
	CMP	H
	CNZ	fault	;TEST "DCX" H
	MVI	A,0FFH
	CMP	C
	CNZ	fault	;TEST "DCX" B
	CMP	E
	CNZ	fault	;TEST "DCX" D
	CMP	L
	CNZ	fault	;TEST "DCX" H
	STA	TEMP0
	XRA	A
	LDA	TEMP0
	CPI	0FFH
	CNZ	fault	;TEST "LDA" AND "STA"
	LHLD	TEMPP
	SHLD	TEMP0
	LDA	TEMPP
	MOV	B,A
	LDA	TEMP0
	CMP	B
	CNZ	fault	;TEST "LHLD" AND "SHLD"
	LDA	TEMPP+1
	MOV	B,A
	LDA	TEMP0+1
	CMP	B
	CNZ	fault	;TEST "LHLD" AND "SHLD"
	MVI	A,0AAH
	STA	TEMP0
	MOV	B,H
	MOV	C,L
	XRA	A
	LDAX	B
	CPI	0AAH
	CNZ	fault	;TEST "LDAX" B
	INR	A
	STAX	B
	LDA	TEMP0
	CPI	0ABH
	CNZ	fault	;TEST "STAX" B
	MVI	A,077H
	STA	TEMP0
	LHLD	TEMPP
	LXI	D,00000H
	XCHG
	XRA	A
	LDAX	D
	CPI	077H
	CNZ	fault	;TEST "LDAX" D AND "XCHG"
	XRA	A
	ADD	H
	ADD	L
	CNZ	fault	;TEST "XCHG"
	MVI	A,0CCH
	STAX	D
	LDA	TEMP0
	CPI	0CCH
	STAX	D
	LDA	TEMP0
	CPI	0CCH
	CNZ	fault	;TEST "STAX" D
	LXI	H,07777H
	DAD	H
	MVI	A,0EEH
	CMP	H
	CNZ	fault	;TEST "DAD" H
	CMP	L
	CNZ	fault	;TEST "DAD" H
	LXI	H,05555H
	LXI	B,0FFFFH
	DAD	B
	MVI	A,055H
	CNC	fault	;TEST "DAD" B
	CMP	H
	CNZ	fault	;TEST "DAD" B
	MVI	A,054H
	CMP	L
	CNZ	fault	;TEST "DAD" B
	LXI	H,0AAAAH
	LXI	D,03333H
	DAD	D
	MVI	A,0DDH
	CMP	H
	CNZ	fault	;TEST "DAD" D
	CMP	L
	CNZ	fault	;TEST "DAD" B
	STC
	CNC	fault	;TEST "STC"
	CMC
	CC	fault	;TEST "CMC
	MVI	A,0AAH
	CMA	
	CPI	055H
	CNZ	fault	;TEST "CMA"
	ORA	A	;RE-SET AUXILIARY CARRY
	DAA
	CPI	055H
	CNZ	fault	;TEST "DAA"
	MVI	A,088H
	ADD	A
	DAA
	CPI	076H
	CNZ	fault	;TEST "DAA"
	XRA	A
	MVI	A,0AAH
	DAA
	CNC	fault	;TEST "DAA"
	CPI	010H
	CNZ	fault	;TEST "DAA"
	XRA	A
	MVI	A,09AH
	DAA
	CNC	fault	;TEST "DAA"
	CNZ	fault	;TEST "DAA"
	STC
	MVI	A,042H
	RLC
	CC	fault	;TEST "RLC" FOR RE-SET CARRY
	RLC
	CNC	fault	;TEST "RLC" FOR SET CARRY
	CPI	009H
	CNZ	fault	;TEST "RLC" FOR ROTATION
	RRC
	CNC	fault	;TEST "RRC" FOR SET CARRY
	RRC
	CPI	042H
	CNZ	fault	;TEST "RRC" FOR ROTATION
	RAL
	RAL
	CNC	fault	;TEST "RAL" FOR SET CARRY
	CPI	008H
	CNZ	fault	;TEST "RAL" FOR ROTATION
	RAR
	RAR
	CC	fault	;TEST "RAR" FOR RE-SET CARRY
	CPI	002H
	CNZ	fault	;TEST "RAR" FOR ROTATION
	LXI	B,01234H
	LXI	D,0AAAAH
	LXI	H,05555H
	XRA	A
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	LXI	B,00000H
	LXI	D,00000H
	LXI	H,00000H
	MVI	A,0C0H
	ADI	0F0H
	POP	PSW
	POP	H
	POP	D
	POP	B
	CC	fault	;TEST "PUSH PSW" AND "POP PSW"
	CNZ	fault	;TEST "PUSH PSW" AND "POP PSW"
	CPO	fault	;TEST "PUSH PSW" AND "POP PSW"
	CM	fault	;TEST "PUSH PSW" AND "POP PSW"
	MVI	A,012H
	CMP	B
	CNZ	fault	;TEST "PUSH B" AND "POP B"
	MVI	A,034H
	CMP	C
	CNZ	fault	;TEST "PUSH B" AND "POP B"
	MVI	A,0AAH
	CMP	D
	CNZ	fault	;TEST "PUSH D" AND "POP D"
	CMP	E
	CNZ	fault	;TEST "PUSH D" AND "POP D"
	MVI	A,055H
	CMP	H
	CNZ	fault	;TEST "PUSH H" AND "POP H"
	CMP	L
	CNZ	fault	;TEST "PUSH H" AND "POP H"
	LXI	H,00000H
	DAD	SP
	SHLD	SAVSTK	;SAVE THE "OLD" STACK-POINTER!
	LXI	SP,TEMP4
	DCX	SP
	DCX	SP
	INX	SP
	DCX	SP
	MVI	A,055H
	STA	TEMP2
	CMA
	STA	TEMP3
	POP	B
	CMP	B
	CNZ	fault	;TEST "LXI","DAD","INX",AND "DCX" SP
	CMA
	CMP	C
	CNZ	fault	;TEST "LXI","DAD","INX", AND "DCX" SP
	LXI	H,TEMP4
	SPHL
	LXI	H,07733H
	DCX	SP
	DCX	SP
	XTHL
	LDA	TEMP3
	CPI	077H
	CNZ	fault	;TEST "SPHL" AND "XTHL"
	LDA	TEMP2
	CPI	033H
	CNZ	fault	;TEST "SPHL" AND "XTHL"
	MVI	A,055H
	CMP	L
	CNZ	fault	;TEST "SPHL" AND "XTHL"
	CMA
	CMP	H
	CNZ	fault	;TEST "SPHL" AND "XTHL"
	LHLD	SAVSTK	;RESTORE THE "OLD" STACK-POINTER
	SPHL
	LXI	H,allok
	PCHL		;TEST "PCHL"
	jmp	fault

;
TEMPP:	DW	TEMP0	;POINTER USED TO TEST "LHLD","SHLD",
			; AND "LDAX" INSTRUCTIONS
;
TEMP0:	DS	1	;TEMPORARY STORAGE FOR CPU TEST MEMORY LOCATIONS
TEMP1:	DS	1	;TEMPORARY STORAGE FOR CPU TEST MEMORY LOCATIONS
TEMP2	DS	1	;TEMPORARY STORAGE FOR CPU TEST MEMORY LOCATIONS
TEMP3:	DS	1	;TEMPORARY STORAGE FOR CPU TEST MEMORY LOCATIONS
TEMP4:	DS	1	;TEMPORARY STORAGE FOR CPU TEST MEMORY LOCATIONS
SAVSTK:	DS	2	;TEMPORARY STACK-POINTER STORAGE LOCATION

allok:	lxi	H, 0FFFFh;
	call	hexlo
	lxi	H, 00000h
	call	hexhi
	jmp	$
	
fault:	lxi	H, disp
	mvi	M, 078h
	inx	H
	mvi	M, 038h
	inx	H
	mvi	M, 077h
	inx	H
	mvi	M, 076h
	pop	H
	call	hexhi
	jmp	$

hconv:	push	H
	push	D
	lxi	H, hextt
	ani	0Fh
	mov	E, A
	mvi	D, 0
	dad	D
	mov	A, M
	pop	D
	pop	H
	ret

hexlo:	lxi	D, disp+0
	jmp	hexdd
hexhi:	lxi	D, disp+4
hexdd:	mov	A, L
	call	hconv
	stax	D
	inx	D
	mov	A, L
	rrc
	rrc
	rrc
	rrc
	call	hconv
	stax	D
	inx	D
	mov	A, H
	call	hconv
	stax	D
	inx	D
	mov	A, H
	rrc
	rrc
	rrc
	rrc
	call	hconv
	stax	D
	ret

regs1:	db	2, 4, 6, 8, 10, 12, 14, 16
regs2:	ds	8,0

hlval:	db	0A5h,03Ch

hextt:	db	03Fh, 006h, 05Bh, 04Fh
	db	066h, 06Dh, 07Dh, 007h
	db	07Fh, 06Fh, 077h, 07Ch
	db	039h, 05Eh, 079h, 071h
	
	ds	120
stack	equ	$
	end	start
