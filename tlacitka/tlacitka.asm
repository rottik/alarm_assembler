;*******************************************************************************
;  Priklad 19 - SDILENI TLACITKA - indikace tlacitka tl3  led0
;*******************************************************************************
;	Definice symbolu    
;	............................................................................
				list		p=16F877A				; deklarece procesoru
				include		"d:\p16f877a.inc"		; deklarece registru
				__config	3F31h					; konfiguracni pojistky


				pombity		equ		33h
				reg2		equ		34h
				reg1		equ		35h
				pom			equ		36h
				pom2		equ		37h
				port		equ		38h
				pred		equ		39h
				cekani		equ		3ah
				#define		rp0		STATUS,5		; volba stranky pameti dat¨
				#define		led		PORTB,3
				#define		indbzuc		pombity,7
				#define 	bzucak		PORTC,2
;		W		0
;		F		1
				org		0000h
				goto 	start
;	............................................................................
;	preruseni
				org		0004h
				bcf		PIR1,TMR1IF		; shozeni pir1
				clrf	TMR1L
				clrf	TMR1H			; reset TMR1
				decfsz	cekani
				goto	intend
				movlw	d'6'
				movwf	cekani
				movf	PORTD,W
				movwf	pred			; zaloha PORTuD
		; sdileni
				bsf		PORTC,1			; deaktivace bargrafu
				movlw	0ffh			; nastaveni vsech katod BARGRAFU - po zapnuti anod
				movwf	PORTD			; se LED nerozsviti
				bsf 	rp0				; banka1

				movlw	0ffh
				movwf	TRISD       	; nastaveni TL jako vstupu
			
				bcf		rp0				; banka0
				movf	PORTD,W			; nacteni tlacitek a ulozeni do reg port
				movwf	port
				bsf 	rp0				; banka1

				clrf	TRISD			; nastaveni TL jako vystupu
			
				bcf		rp0				; banka0
				movf	pred,W
				movwf	PORTD
				bcf 	PORTC,1			; aktivace anod BARGRAFU

	; test tlacitek
				movlw   0ffh
				movwf	PORTD
				btfsc	port,2			; pokud je stiskle TL2 neguj zapnuti budiku
				goto	pres1			; neni stiskle	preskoc 	
				btfss	led				; sviti led?
				goto	rozsvitled				; ne - rozsvit
				btfsc	led				; ano sviti-nesviti led?
				goto	zhasniled				; ne - zhasni
	
pres1:			btfsc	port,3			; 
				goto	pres2			;  	
				btfss	indbzuc			; bzuci?
				goto	bzuc			; ne - bzuc
				btfsc	indbzuc			; ano bzuci-nebzuc?
				goto	nebzuc			; ne - nebzuc

pres2:			btfsc	port,0			; nastaveni LED0 podle stavu tlacitka	
	            bsf		PORTD,7				
				btfss 	port,0			; neni stiskle?
				bcf		PORTD,7
		
				btfsc	port,1			; nastaveni LED1 podle stavu tlacitka	
				bsf		PORTD,6				
				btfss 	port,1			; neni stiskle?
				bcf		PORTD,6

intend:			retfie
; ................................
rozsvitled:		bsf		led				; rozsvit led
				goto	pres1			; preskoc na dalsi tl
; ................................				
zhasniled:		bcf		led				; zhasni led
				goto	pres1			; preskoc na dalsi tl
; ................................
bzuc:			bsf		indbzuc	
				goto	pres2
; ................................
nebzuc:			bcf		indbzuc
				goto	pres2
;	.....................................................................................
;	Inicializace portu
start:			bsf 	rp0				; banka1

				bcf		TRISC,1			; nastav bit C1 jako vystup -  napojen BARGRAF
				bcf     TRISB,3			; nastav led jako vystup
			 	clrf	TRISD			; bargraf pouzit
				bcf		TRISC,2			; bzucak jako vystup
				bsf		PIE1,TMR1IE		; povoleni preruseni od tmr1
				bsf		INTCON,PEIE		; povoleni preruseni od periferii
				bsf		INTCON,GIE		; globalni

				bcf		rp0				; banka0
	
				movlw	0ffh			; nastaveni vsech katod BARGRAFU - po zapnuti anod
				movwf	PORTD			; se LED nerozsviti
				clrf	TMR1L			 
				clrf	TMR1H			 
				movlw	b'00000001'		; spusteni TMR1
				movwf	T1CON
				clrf	port
				clrf	pred
				bcf		PORTC,1			; aktivace bargrafu
				movlw	d'6'
				movwf	cekani			; prodlouzeni TMR1
				movlw   255h
				movwf	reg2

hlavni:			btfsc	indbzuc
				goto    sirena
				goto	hlavni	

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
				goto 	hlavni

zpozdeni:		movlw		50h
				movwf		reg1
cyk1:			decfsz		reg1
				goto		cyk1
				return
				end
