;*****************************************************************************************************
;  hodiny
;*****************************************************************************************************
;	..................................................................................................
;	Definice symbolu
;	..................................................................................................
				list		p=16F877A				; deklarece procesoru
				include		"d:\p16f877a.inc"		; deklarece registru
				__config	3F31h					; konfiguracni pojistky
;	..................................................................................................
				vteriny		equ		22h
				disp1		equ		23h
				disp2		equ		25h
				disp3		equ		24h
				disp4		equ		26h
				pordisp		equ		27h
				sec			equ		28h

				pre1		equ		29h
				pre2		equ		2ah
				wreg		equ		2bh	
; new
				pombity		equ		21h
				reg2		equ		2ch
				reg1		equ		2dh
				pom			equ		2eh
				pom2		equ		2fh	

				budik1		equ		33h
				budik2		equ		34h
				budik3		equ		35h
				budik4		equ		36h					
;	..................................................................................................
				#define		rp0		STATUS,5		; volba stranky pameti dat
				#define		c		STATUS,0		; carry
				#define		z		STATUS,2		; zero
				#define		toif	INTCON,2		; indikace preteceni TMR0
				#define     toie	INTCON,5
				#define		gie		INTCON,7
; new
				#define		indbzuc		pombity,7
				#define 	bzucak		PORTC,2
				#define 	led			PORTB,3
				#define 	pled		pombity,6

				org		0000h
				goto 	start
;	........................................................................
;	preruseni
				org     0004h	
				bcf		toif			; vynulovani bitu toif
				movwf	wreg
				movlw	01h
				movwf	TMR0

				call 	displej

				incf	sec,F			; pricte 1 k registrucitace sekund
				movlw	0c8h
				subwf	sec,w			; odecte od sec 200 a ulozi do W
				btfss 	z				; je-li z=1, registr sec nepretekl
				goto	pkonec

				
				movlw	d'8'
				movwf	pre2
				nop
				nop
pr1:   			movlw	d'233'
				movwf	pre1
				nop
pr0:			decfsz	pre1
				goto 	pr0
				decfsz	pre2
				goto	pr1

				call	couter

				movf	wreg
pkonec:			retfie	
;	..................................................................................................
;	Inicializace portu
;	..................................................................................................

  start:       	bsf 	rp0				; nastaveni BANKY1 - STATUS(RP0)
			
				movlw	B'00000000'
				movwf	TRISD			; portD je vystup
				movlw	b'11100000'		; nastaveni anod displeje B0,B1,B2,B3 jako vystupu
				movwf	TRISB	
				bcf		TRISC,2			; bzucak jako vystup	
				movlw	B'11010011'
				movwf	OPTION_REG		; konfigurace TMR0 a preddelicky
				bsf     toie			; povoleni preruseni od TMR0
				bsf		gie				; povoleni globalniho preruseni

				bcf 	rp0				; nastaveni BANKY0 - STATUS(RP0)
				movlw	0ffh
				movwf	PORTD			; zhasne vsechny segmenty

				clrf	disp1			; vynuluje registr disp1
				clrf	disp2			; vynuluje registr disp2
				clrf	disp3			; vynuluje registr disp3
				clrf	disp4			; vynuluje registr disp4
				clrf	pordisp			; vynulovani poradi displeje
				clrf	sec				; vynulovani citace sekund
				clrf	vteriny			; vynuluje registr vteriny

				bsf 	led

				movlw	1h
				movwf	budik1
				clrf	budik2
				clrf	budik3
				clrf	budik4			
;	..................................................................................................
hlprog:			btfss	led				; test na zapnuti
				goto	hlprog
				
				call	porovnej	
				btfsc	indbzuc			; test na rovnost
				goto    sirena

				goto	hlprog	

sirena:			movlw	255h
				movwf	pom2
s3:				movlw	0ffh
				movwf   pom
s2:				decfsz	pom
				goto 	s2
				decfsz	pom2
				goto	s3
s1:				bcf		bzucak
				call	zpozdeni
				bsf		bzucak
				call	zpozdeni
				decfsz	reg2
				goto    s1
				goto 	hlprog

zpozdeni:		movlw	50h
				movwf	reg1
cyk1:			decfsz	reg1
				goto	cyk1
				return 					; skoci na zacatek smycky
;	..................................................................................................
include "d:\rp\displayled.asm"
;	..................................................................................................
;	podprogram couter
couter:			clrf	sec				; vynuluje reg sec
				incf	vteriny,F		; pricte 1 k registru disp_0 - SeKUNDY
				movlw	3ch
				subwf	vteriny,W		; odecte od vterin sedesat a ulozi do W
				btfss	c				; je-li z=1, disp_0 pretekl pres 9
				goto	adr3

				clrf	vteriny
				incf	disp1,F			; pricte 1 k registru disp1 - MINUTY
				movlw	0ah
				subwf	disp1,W			; odecte od disp1 desitku a ulozi do W
				btfss	z				; je-li z=1, disp1 pretekl pres 9
				goto   	adr3

				clrf	disp1
				incf	disp2,F			; pricte 1 k registru disp2 - DESITKY MINUT
				movlw	6h
				subwf	disp2,W			; odecte od disp2 desitku a ulozi do W
				btfss	z				; je-li z=1, disp2 pretekl pres 5
				goto	adr3

				clrf	disp2
				incf	disp3,f			; pricte 1 k registru disp3 - HODINY
				movlw	4h				
				subwf	disp3,w
				btfss	z				; je disp3 vetsi nez 3?
				goto	adr4			; ne

				movlw	2h				; ano
				subwf	disp4,w			; pokud ano tak je disp4 vetsi nez 1?
				btfsc	z				; 
				goto	adr5			; ano 

adr4			movlw	0ah				; ne
				subwf	disp3,w			; odecte od disp3 desitku a ulozi do W
				btfss	z				; je-li z=1, disp3 pretekl pres 9
				goto	adr3

adr5:			clrf	disp3
				incf	disp4,f			; pricte 1 k registru disp4 - DESITKY MINUT
				movlw	3h
				subwf	disp4,w			; odecte od disp4 desitku a ulozi do W
				btfss	z				; je-li z=1, disp4 pretekl pres 9
				goto	adr3
				clrf	disp4
adr3:			return
; ***************************************************************************************
porovnej:		movf	budik1,W
				subwf	disp1,W
				btfss	z
				goto	endpor1			; nerovno -skoc a nastava indbzuc na 0

				movf	budik2,W
				subwf	disp2,W
				btfss	z
				goto	endpor1			; nerovno -skoc a nastava indbzuc na 0
				
				movf	budik3,W
				subwf	disp3,W
				btfss	z
				goto	endpor1			; nerovno -skoc anastava indbzuc na 0

				movf	budik4,W
				subwf	disp4,W
				btfss	z
				goto	endpor1			; nerovno -skoc anastava indbzuc na 0
				
				bsf		indbzuc			; rovno nastav indbzuc na 1
				goto	endpor2			; preskoc vynulovani indbzuc

endpor1:		bcf		indbzuc			; vynuluj indbzuc
				
endpor2:        return				

				end


