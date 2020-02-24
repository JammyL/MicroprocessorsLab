	 #include "p18f87k22.inc"
	 
	 global	    KEYBOARD_VERT, KEYBOARD_HOR, DELAY
	 global	    count
	 
acs0	udata_acs   ; reserve data space in access ram
	 
count	res 1
	    	
   
keypad code 0x300

interupt_setup
;	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
;	bsf	INTCON,GIE	; Enable all interrupts
	return


   
KEYBOARD_SETUP
    setf  TRISD			    ; Tri-state PortE
;    banksel PADCFG1		    ; PADCFG1 is not in Access Bank!!
;    bsf PADCFG1, REPU, BANKED	    ; PortE pull-ups on	
;    movlb 0x00			    ; set BSR back to Bank 0
    return
   
KEYBOARD_VERT
    movlw   0x0F
    movwf   TRISE
    movlw   0xF0
    movwf   PORTE
    call    DELAY
    movf    PORTE, W
;    clrf    PORTE
    return

KEYBOARD_HOR
    movlw   0xF0
    movwf   TRISE
    movlw   0x0F
    movwf   PORTE
    call    DELAY
    movf    PORTE, W
;    clrf    PORTE
    return
    
DELAY
    movlw   0xAA
    movwf   count
DELAY_LOOP
    DECFSZ  count
    bra	    DELAY_LOOP
    return
	

    end