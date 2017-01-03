budikmin:		incf	budik1,F		; pricte 1 k registru budik1 - MINUTY
				movlw	0ah
				subwf	budik1,W		; odecte od budik1 desitku a ulozi do W
				btfss	z				; je-li z=1, budik1 je roven 10
				goto   	bm1

				clrf	budik1
				incf	budik2,F		; pricte 1 k registru budik2 - DESITKY MINUT
				movlw	6h
				subwf	budik2,W		; odecte od budik2 desitku a ulozi do W
				btfss	z				; je-li z=1, budik2 je roven 6
				goto	bm1

				clrf	budik2
bm1:			return
; ------------------------------------------------------------------------------
budikhod:		incf	budik3,F		; pricte 1 k registru budik3 - HODINY
				movlw	4h				
				subwf	budik3,W
				btfss	z				; je budik3 roven 4?
				goto	bh2				; ne

				movlw	2h				; ano
				subwf	budik4,W		; pokud ano tak je budik4 vetsi nez 1?
				btfsc	z				; 
				goto	bh3				; ano 

bh2:			movlw	0ah				; ne
				subwf	budik3,W		; odecte od budik3 desitku a ulozi do W
				btfss	z				; je-li z=1, budik3 je roven 10
				goto	bh1

bh3:			clrf	budik3
				incf	budik4,F		; pricte 1 k registru budik4 - DESITKY HODIN
				movlw	3h
				subwf	budik4,W		; odecte od budik4 desitku a ulozi do W
				btfss	z				; je-li z=1, budik4 je roven 3
				goto	bh1

				clrf	budik4
bh1:			return
