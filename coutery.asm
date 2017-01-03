; podprogramy citani
;	nutno deklarovat registry: sec,vteriny,disp1,disp2,disp3,disp4
;	pouzite zarazky: couter,minuty,hodiny
;	nepouzitelne zarazky: adr4,adr5,adr3,m1,h1,h2,h3

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
m1:			return
; ------------------------------------------------------------------------------
hodiny:			clrf	vteriny

				incf	disp3,F			; pricte 1 k registru disp3 - HODINY
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
