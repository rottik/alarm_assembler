; podprogramy pro vyuziti displaye
; 	zobrazoje obsah registru 23,24,25,26 na LED zobrazovacich
;	dale vyuziva registry(nutne deklarovat): pordisp,FSR,PORTB,INDF,STATUS

displej:		bcf		pled			; pomocny bit pled vynuluj
				btfsc	led				; nesviti led? skoc
				bsf		pled			; sviti led nastav pled na 1		
				
				movlw	23h				; nacte adresu disp1
				btfsc	rezim				; pokud sviti led zobrazuj budik
				movlw	33h				; nacte adresu budik1
				addwf	pordisp,0		; 23h(nebo 33h) + portdisp ulozi do stradace
				movwf	FSR				; nastaveni neprime adresy
				movlw	B'00010111'
				movwf	PORTB			; zhasnuti anod			
				movf	INDF,0			; nacteni hodnoty - neprime adresovani

				call	segment			; dekodovani binarniho cisla na sedmisegmentovy kod
				movwf	PORTD

				movf	pordisp,0		
				call	anoda			; aktivuje prislusnou anodu
				movwf 	PORTB			; aktivuje spravny display, zhasne led

				btfsc	pled
				bsf		led				; pokud led svitila rozsvit ji

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
