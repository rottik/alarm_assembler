;*****************************************************************************************************
;  hodiny s nastavenim bez nastaveni budiku
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

				pombity		equ		21h
				reg2		equ		2ch
				reg1		equ		2dh
				pom			equ		2eh
				pom2		equ		2fh	

				budik1		equ		33h
				budik2		equ		34h
				budik3		equ		35h
				budik4		equ		36h	
; new				
				port		equ		30h
				pred		equ		31h
				cekani		equ		32h
;	..................................................................................................
				#define		rp0		STATUS,5		; volba stranky pameti dat
				#define		c		STATUS,0		; carry
				#define		z		STATUS,2		; zero
				#define		toif	INTCON,2		; indikace preteceni TMR0
				#define     toie	INTCON,5		; spusteni TMR0
				#define		gie		INTCON,7

				#define		indbzuc		pombity,7	; identifikace rovnosti budiku s casem
				#define 	bzucak		PORTC,2	
				#define 	led			PORTB,3
				#define 	pled		pombity,6	; zaloha stavu led
; new; new
				#define		t1if		PIR1,TMR1IF
				org		0000h
				goto 	start
;	........................................................................
;	preruseni
				org     0004h
				movf	wreg,W

				btfss	toif
				goto	TMR1
; preruseni pro TMR0	
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

; spolecny konec preruseni
pkonec:			movf	wreg
				retfie	
; ??????????????????????????????????????????????????????????????????????????????
; preruseni pro TMR1
TMR1:			movf	PORTD,W
				movwf	pred			; zaloha PORTD
		; sdileni
				bsf		rp0

				movlw	0ffh
				movwf	TRISD			; PORTD jako vstup

				bcf		rp0
				movf	PORTD,W			; PORTD do W
				movwf	port			; z W do port
				bsf		rp0

				clrf	TRISD			; PORTD jako vystup
	
				bcf		rp0
		; konec sdileni		
				movf	pred,W
				movwf	PORTD			; obnova PORTD
		
				btfss	port,0
				call	hodiny

				btfss	port,1
				call	minuty

				clrf	TMR1H
				bcf		t1if

				goto	pkonec
; ??????????????????????????????????????????????????????????????????????????????
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
; -----------------------------------------------------------------------------
; new
				bsf		INTCON,PEIE		; povoleni preruseni od periferii
				bsf		PIE1,TMR1IE		; povoleni preruseni od tmr1
; -----------------------------------------------------------------------------
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
; ------------------------------------------------------------------------------	
; new	
				clrf	TMR1L			 
				clrf	TMR1H
				clrf	port
				clrf	pred
				movlw	d'3'
				movwf	cekani			; prodlouzeni TMR1
				movlw	b'00000001'		; spusteni TMR1
				movwf	T1CON	
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
include	"d:\rp\coutery.asm"
;	..................................................................................................
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
				goto	endpor1			; nerovno -skoc a nastava indbzuc na 0

				movf	budik4,W
				subwf	disp4,W
				btfss	z
				goto	endpor1			; nerovno -skoc a nastava indbzuc na 0
				
				bsf		indbzuc			; rovno nastav indbzuc na 1
				goto	endpor2			; preskoc vynulovani indbzuc

endpor1:		bcf		indbzuc			; vynuluj indbzuc
				
endpor2:        return				

				end


