budikmin:		incf	budik1,F		; pricte 1 k registru disp1 - MINUTY
				movlw	0ah
				subwf	budik1,W		; odecte od disp1 desitku a ulozi do W
				btfss	z				; je-li c=1, disp1 pretekl pres 9
				goto   	bm1

				clrf	budik1
				incf	budik2,F		; pricte 1 k registru disp2 - DESITKY MINUT
				movlw	6h
				subwf	budik2,W		; odecte od disp2 desitku a ulozi do W
				btfss	z				; je-li c=1, disp2 pretekl pres 5
				goto	bm1

				clrf	budik2
bm1:			return
; ------------------------------------------------------------------------------
budikhod:		incf	disp3,F			; pricte 1 k registru disp3 - HODINY
				movlw	4h				
				subwf	disp3,W
				btfss	z				; je disp3 vetsi nez 3?
				goto	h2				; ne

				movlw	2h				; ano
				subwf	disp4,W			; pokud ano tak je disp4 vetsi nez 1?
				btfsc	z				; 
				goto	h3				; ano 

h2:				movlw	0ah				; ne
				subwf	disp3,W			; odecte od disp3 desitku a ulozi do W
				btfss	z				; je-li c=1, disp3 pretekl pres 9
				goto	h1

h3:				clrf	disp3
				incf	disp4,F			; pricte 1 k registru disp4 - DESITKY HODIN
				movlw	3h
				subwf	disp4,W			; odecte od disp4 desitku a ulozi do W
				btfss	z				; je-li c=1, disp4 pretekl pres 9
				goto	h1
				clrf	disp4
h1:			return
