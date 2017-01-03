;*******************************************************************************
;  Priklad 19 - SDILENI TLACITKA - indikace tlacitka tl3  led0
;*******************************************************************************
;	Definice symbolu    
;	............................................................................
				list		p=16F877A				; deklarece procesoru
				include		"a:\p16f877a.inc"		; deklarece registru
				__config	3F31h					; konfiguracni pojistky

				port		equ		30h
				pred		equ		31h
				#define		rp0		STATUS,5		; volba stranky pameti dat
				org		0000h
				goto 	start
;	............................................................................
;	preruseni
				org		0004h
				bcf		PIR1,TMR1IF
				clrf	TMR1L
				clrf	TMR1H
				movf	PORTD
				movwf	predport
		; sdileni
				bsf		PORTC,1			; deaktivace bargrafu
				bsf 	rp0				; banka1

				bsf		TRISD,0			; nastaveni TL0 jako vstupu
		 	  	bsf		TRISD,1			; nastaveni TL1 jako vstupu
				bsf		TRISD,2			; nastaveni TL2 jako vstupu	
				bsf		TRISD,3         ; nastaveni TL3 jako vstupu
			
				bcf		rp0				; banka0
				movf	PORTD			; nacteni tlacitek a ulozeni do reg port
				movwf	port
				bsf 	rp0				; banka1

				bcf		TRISD,0			; nastaveni TL0 jako vystupu
				bcf		TRISD,1			; nastaveni TL1 jako vystupu
				bcf		TRISD,2			; nastaveni TL2 jako vystupu
				bcf		TRISD,3			; nastaveni TL3 jako vystupu
			
				bcf		rp0				; banka0
				bcf 	PORTC,1			; aktivace anod BARGRAFU

	; test tlacitek
				movlw	0ffh
				movwf	PORTD
			
				btfsc	port,2			; pokud je stiskle TL2 neguj zapnuti budiku
				goto	pres1			; neni stiskle	preskoc 	
				movf	predport
				xorlw	b'00000100'
				movwf	predport
				movwf	PORTD
	
pres1:			btfsc	port,3
				goto	pres2
				movf	predport
				xorlw	b'00001000'
				movwf	predport
				movwf	PORTD

pres2:			btfsc	port,0			; nastaveni LED0 podle stavu tlacitka	
	            bsf		PORTD,7				
				btfss 	port,0			; neni stiskle?
				bcf		PORTD,7
		
				btfsc	port,1			; nastaveni LED1 podle stavu tlacitka	
				bsf		PORTD,6				
				btfss 	port,1			; neni stiskle?
				bcf		PORTD,6

				retfie
				
;	.....................................................................................
;	Inicializace portu
start:			bsf 	rp0				; banka1

				bcf		TRISC,1			; nastav bit C1 jako vystup -  napojen BARGRAF
			 	clrf	TRISD			; bargraf pouzit
				bsf		PIE1,TMR1IE		; povoleni preruseni od tmr1
				bsf		INTCON,PEIE
				bsf		INTCON,GIE	

				bcf		rp0				; banka0
	
				movlw	0ffh			; nastaveni vsech katod BARGRAFU - po zapnuti anod
				movwf	PORTD			; se LED nerozsviti
				clrf	TMR1L			 
				clrf	TMR1H			 
				movlw	b'00000001'		; spusteni TMR1
				movwf	T1CON
				clrf	port
				clrf	predport
hp:				goto	hp

				end
