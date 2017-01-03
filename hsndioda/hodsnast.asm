;*****************************************************************************************************
;  hodiny s nastavenim
;*****************************************************************************************************
;	..................................................................................................
;	Definice symbolu
;	..................................................................................................
				list		p=16F877A				; deklarece procesoru
				include		"d:\p16f877a.inc"		; deklarece registru
				__config	3F31h					; konfiguracni pojistky
;	..................................................................................................
				vteriny		equ		30h
				disp1		equ		23h
				disp2		equ		25h
				disp3		equ		24h
				disp4		equ		26h
				pordisp		equ		27h
				sec			equ		28h

				reg1		equ		2ah
				reg2		equ		2bh
				pre1		equ		2ch
				pre2		equ		2dh
				wreg		equ		2eh		
				port		equ		2fh

				cekani		equ		32h	
;	..................................................................................................
				#define		rp0		STATUS,5		; volba stranky pameti dat
				#define		c		STATUS,0		; carry
				#define		z		STATUS,2		; zero
				#define		toif	INTCON,2		; indikace preteceni TMR0
				#define     toie	INTCON,5
				#define		gie		INTCON,7
				#define		led		PORTB,3
				org		0000h
				goto 	start
;	........................................................................
;	preruseni
				org     0004h
				movwf	wreg
				btfss	toif
				goto	preruseni2	
;   pretuseni od TMR0
				bcf		toif			; vynulovani bitu toif
				clrf	TMR0

				call 	displej

				incf	sec,F			; pricte 1 k registrucitace sekund
				movlw	d'200'
				subwf	sec,W			; odecte od sec 200 a ulozi do W
				btfss 	z				; je-li z=1, registr sec nepretekl
				goto	intend

				call	couter


				goto	intend

;	preruseni od TMR1
preruseni2:		bcf		PIR1,TMR1IF
				clrf	TMR1L
				clrf	TMR1H
				decfsz	cekani
				goto	intend
				movlw	d'3'
				movwf	cekani
		; sdileni
				bsf		PORTC,1			; deaktivace bargrafu
				bsf 	rp0				; banka1

				bsf		TRISD,0			; nastaveni TL0 jako vstupu
		 	  	bsf		TRISD,1			; nastaveni TL1 jako vstupu
		 	  	bsf		TRISD,2			; nastaveni TL2 jako vstupu
		 	  	bsf		TRISD,3			; nastaveni TL3 jako vstupu
		
				bcf		rp0				; banka0
				movf	PORTD,W			; nacteni tlacitek a ulozeni do reg port
				movwf	port
				bsf 	rp0				; banka1

				bcf		TRISD,0			; nastaveni TL0 jako vystupu
				bcf		TRISD,1			; nastaveni TL1 jako vystupu
		 	  	bcf		TRISD,2			; nastaveni TL2 jako vystupu
				bcf		TRISD,3			; nastaveni TL3 jako vystupu
			
				bcf		rp0				; banka0
				bcf 	PORTC,1			; aktivace anod BARGRAFU

	; test tlacitek
				btfsc	port,2			; pokud je stiskle TL2 neguj zapnuti budiku
				goto	jmpled			; neni stiskle	preskoc 	
				btfss	led				; sviti led?
				goto	rozsvitled		; ne - rozsvit
				btfsc	led				; ano sviti-nesviti led?
				goto	zhasniled		; ne - zhasni
	
jmpled:			btfss 	port,0			; neni stiskle?
				call 	hodiny
		
				btfss 	port,1			; neni stiskle?
				call	minuty

intend:			movf	wreg,W
				retfie
; ................................
rozsvitled:		bsf		led				; rozsvit led
				goto	jmpled			; preskoc na dalsi tl
; ................................				
zhasniled:		bcf		led				; zhasni led
				goto	jmpled			; preskoc na dalsi tl
; ................................
;	..................................................................................................
;	Inicializace portu
;	..................................................................................................

  start:       	bsf 	rp0				; nastaveni BANKY1 - STATUS(RP0)
			
				movlw	B'00000000'
				movwf	TRISD			; portD je vystup
				movlw	b'11100000'		; nastaveni anod displeje B0,B1,B2,B3 jako vystupu
				movwf	TRISB		
				movlw	B'11010011'
				movwf	OPTION_REG		; konfigurace TMR0 a preddelicky
				bsf     toie			; povoleni preruseni od TMR0
				bsf		gie				; povoleni globalniho preruseni
				bsf		PIE1,TMR1IE		; povoleni preruseni od tmr1
				bsf		INTCON,PEIE

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
				clrf	TMR1L			 
				clrf	TMR1H	
				movlw	d'4'
				movwf	cekani		 
				movlw	b'00000001'		; spusteni TMR1
				movwf	T1CON
				clrf	port
;	..................................................................................................

adr0:			goto 	adr0			; skoci na zacatek smycky

;	..................................................................................................

displej:		movlw	23h				; nacte adresu disp1
				addwf	pordisp,0		; 23h + portdisp ulozi do stradace
				movwf	FSR				; nastaveni neprime adresy
				movlw	B'00010111'
				movwf	PORTB			; zhasnuti anod			
				movf	INDF,0			; nacteni hodnoty - neprime adresovani

				call	segment			; dekodovani binarniho cisla na sedmisegmentovy kod
				movwf	PORTD

				movf	pordisp,0		
				call	anoda			; aktivuje prislusnou anodu

				movwf 	PORTB
				incf	pordisp,1		; zvysi obsah pordisp o 1
				movlw	4
				subwf	pordisp,0		; kontroluje zda byly zobrazeny vsechny ctyri znaky
				btfsc	STATUS,2
				clrf	pordisp			; pokud ano vynuluje pocitadlo
				return
;	..................................................................................................
;	podprogram segment
segment:		addwf	PCL,1
				RETLW	B'11000000'		;0
				RETLW	B'11111001'		;1
				RETLW	B'10100100'		;2
				RETLW	B'10110000'		;3
				RETLW	B'10011001'		;4
				RETLW	B'10010010'		;5
				RETLW	B'10000010'		;6
				RETLW	B'11111000'		;7
				RETLW	B'10000000'		;8
				RETLW	B'10010000'		;9
				RETLW	B'10001000'		;A
				RETLW	B'10000011'		;B
				RETLW	B'11000110'		;C
				RETLW	B'10100001'		;D
				RETLW	B'10000110'		;E
				RETLW	B'10001110'		;F
;	..................................................................................................
;	podprogram anoda
anoda:			addwf	PCL,1
				retlw	B'00010110'		;1 znak displeje
				retlw	B'00010011'		;3 znak displeje
				retlw	B'00010101'		;2 znak displeje
				retlw	B'00000111'		;4 znak displeje
;	..................................................................................................
;	podprogram couter
couter:			clrf	sec				; vynuluje reg sec
				incf	vteriny,F		; pricte 1 k registru disp_0 - SUKUNDY
				movlw	3ch
				subwf	vteriny,W		; odecte od vterin sedesat a ulozi do W
				btfss	c				; je-li z=1, disp_0 pretekl pres 9
				goto	adr3

				clrf	vteriny
				incf	disp1,F			; pricte 1 k registru disp1 - MINUTY
				movlw	0ah
				subwf	disp1,W			; odecte od disp1 desitku a ulozi do W
				btfss	z				; je-li c=1, disp1 pretekl pres 9
				goto   	adr3

				clrf	disp1
				incf	disp2,F			; pricte 1 k registru disp2 - DESITKY MINUT
				movlw	6h
				subwf	disp2,W			; odecte od disp2 desitku a ulozi do W
				btfss	z				; je-li c=1, disp2 pretekl pres 5
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
				btfss	z				; je-li c=1, disp3 pretekl pres 9
				goto	adr3

adr5:			clrf	disp3
				incf	disp4,f			; pricte 1 k registru disp4 - DESITKY HODIN
				movlw	3h
				subwf	disp4,w			; odecte od disp4 desitku a ulozi do W
				btfss	z				; je-li c=1, disp4 pretekl pres 9
				goto	adr3
				clrf	disp4
adr3:			return
; ------------------------------------------------------------------------------------
minuty:			clrf	vteriny

				incf	disp1,F			; pricte 1 k registru disp1 - MINUTY
				movlw	0ah
				subwf	disp1,W			; odecte od disp1 desitku a ulozi do W
				btfss	z				; je-li c=1, disp1 pretekl pres 9
				goto   	m1

				clrf	disp1
				incf	disp2,F			; pricte 1 k registru disp2 - DESITKY MINUT
				movlw	6h
				subwf	disp2,W			; odecte od disp2 desitku a ulozi do W
				btfss	z				; je-li c=1, disp2 pretekl pres 5
				goto	m1

				clrf	disp2
m1:				return
; ------------------------------------------------------------------------------
hodiny:			clrf	vteriny

				incf	disp3,F			; pricte 1 k registru disp3 - HODINY
				movlw	4h				
				subwf	disp3,W
				btfss	z				; je disp3 vetsi nez 3?
				goto	h4				; ne

				movlw	2h				; ano
				subwf	disp4,W			; pokud ano tak je disp4 vetsi nez 1?
				btfsc	z				; 
				goto	h5				; ano 

h4				movlw	0ah				; ne
				subwf	disp3,W			; odecte od disp3 desitku a ulozi do W
				btfss	z				; je-li c=1, disp3 pretekl pres 9
				goto	h3

h5:				clrf	disp3
				incf	disp4,F			; pricte 1 k registru disp4 - DESITKY HODIN
				movlw	3h
				subwf	disp4,W			; odecte od disp4 desitku a ulozi do W
				btfss	z				; je-li c=1, disp4 pretekl pres 9
				goto	h3
				clrf	disp4
h3:				return
				end


