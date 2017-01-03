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
				disp1		equ		23h
				disp2		equ		25h
				disp3		equ		24h
				disp4		equ		26h
				pordisp		equ		27h
				sec			equ		28h
				vteriny		equ		29h

				reg1		equ		2ah
				reg2		equ		2bh
				pre1		equ		2ch
				pre2		equ		2dh
				wreg		equ		2eh		
				testd		equ		30h

				cekani		equ		31h	
				pPORTD		equ		32h
				
;	..................................................................................................
				#define		rp0		STATUS,5		; volba stranky pameti dat
				#define		c		STATUS,0		; carry
				#define		z		STATUS,2		; zero
				#define		toif	INTCON,2		; indikace preteceni TMR0
				#define     toie	INTCON,5
				#define		gie		INTCON,7
				#define		w		0
				#define		f		1

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
				btfsc 	z				; je-li z=0, preskoc citani
				call	couter
				goto	intend

;	preruseni od TMR1
preruseni2:		bcf		PIR1,TMR1IF
				clrf	TMR1L
				clrf	TMR1H
				decfsz	cekani			; preruseni 80ms * 3 = 240ms
				goto	intend			; sdileni probehne 1x za 240ms
				movlw	d'3'
				movwf	cekani			
				movlw	0ffh	
				movwf	testd			; nasteveni testd na 11111111(nestisla tl)
				movf	PORTD,w			; nacteni tlacitek a ulozeni do
				movwf	pPORTD			; zalozniho registru pPORTD
				movlw	0ffh
				movwf	PORTD			; nasteveni PORTD na 11111111(nestisla tl)
		; sdileni
				bsf 	rp0				; banka1

				bsf		TRISD,0			; nastaveni TL jako vstupu
				bsf		TRISD,1				

				bcf		rp0				; banka0
				movf	PORTD,w			; nacteni tlacitek a ulozeni do reg testd
				movwf	testd
				bsf 	rp0				; banka1

				bcf		TRISD,0			; nastaveni TL jako vystupu
				bcf		TRISD,1

			   	bcf		rp0				; banka0
		; konec sdileni
				movf	pPORTD,w		; obnova zalohy
				movwf	PORTD			; portu D		
	
		; test tlacitek
				btfss 	testd,0			; neni stiskle?
				call 	hodiny
		
				btfss 	testd,1			; neni stiskle?
				call	minuty

intend:			movf	wreg,W
				retfie
;	..................................................................................................
;	Inicializace portu
;	..................................................................................................

  start:       	bsf 	rp0				; nastaveni BANKY1 - STATUS(RP0)
			
				clrf	TRISD			; portD je vystup
				movlw	b'11101000'		; nastaveni anod displeje B0,B1,B2,B3 jako vystupu
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
				movlw	d'3'
				movwf	cekani		 
				movlw	b'00000001'		; spusteni TMR1
				movwf	T1CON
;	..................................................................................................
hlprog:			goto 	hlprog			; skoci na zacatek smycky
;	..................................................................................................
include"d:\rp\display.asm"
include"d:\rp\coutery.asm"
	
				end
