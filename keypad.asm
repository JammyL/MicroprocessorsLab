	 #include "p18f87k22.inc"
    ; code to operate the keypad

	 global	    KEYBOARD_VERT, KEYBOARD_HOR, DELAY
	 global	    count
	 
acs0	udata_acs   ; reserve data space in access ram
	 
count	res 1
	    	
   
keypad code 0x300   ; start keyboard code
   
KEYBOARD_VERT       ; get vertical information of keypad
    movlw   0x0F    ; set half of port E to output and half to input
    movwf   TRISE
    movlw   0xF0    ; send high to port E
    movwf   PORTE
    call    DELAY   ; delay
    movf    PORTE, W    ; read port E to W
    return

KEYBOARD_HOR        ; get horizontal information of keypad
    movlw   0xF0    ; set other half of port E to output and half to input
    movwf   TRISE
    movlw   0x0F    ; send high to port E
    movwf   PORTE
    call    DELAY   ; delay
    movf    PORTE, W    ; read port E to W
    return
    
DELAY               ; delay for keyboards
    movlw   0xAA
    movwf   count
DELAY_LOOP
    DECFSZ  count
    bra	    DELAY_LOOP
    return
	

    end