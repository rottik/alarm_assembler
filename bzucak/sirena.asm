	list		p=16F877A	
	__config	3F31h	
	
	reg2	equ		20h
	reg1	equ		21h
	pom		equ		22h
	pom2	equ		23h
	TRISC	equ		87h
	PORTC	equ		07h
	STATUS  equ		03h
#define 	rp0			STATUS,5
#define 	bzucak		PORTC,2


Start:		bsf 	rp0
			bcf		TRISC,2	
			bcf     rp0
			bcf		PORTC,2
			movlw   255h
			movwf	reg2

sirena:		movlw	255h
			movwf	pom2
s3:			movlw	0ffh
			movwf   pom
s2:			decfsz	pom
			goto 	s2
			decfsz	pom2
			goto	s3
s1:			bcf		bzucak
			call	zpozdeni
			bsf		bzucak
			call	zpozdeni
			decfsz	reg2
			goto    s1
			goto 	sirena

zpozdeni:
			movlw		50h
			movwf		reg1
cyk1:		decfsz		reg1
			goto		cyk1
			return
			end
