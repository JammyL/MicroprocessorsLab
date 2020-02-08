	 #include "p18f87k22.inc"
	 
acs0	udata_acs   ; reserve data space in access ram
	 
angle	    res 1
unit_count  res 1
bits_on	    res 1
bits_count  res 1
bits_test   res 1
   
code
	
get_angle
    clrf    TRISD
    movlw   0x02
    movwf   unit_count
    call    check_input_angle
    
    
check_input_angle
    movlw   0x08
    movwf   bits_count
    movf    PORTD, W
    BTFSC   W, 3
    bra	    check_input_angle
    BTFSC   W, 7
    bra     check_zero
zero_passed
    movwf   bits_test
    BTFSC   bits_test, 0
    incf    bits_on
    RRNCF   bits_test
    decfsz  bits_count
    bra	    zero_passed
    BTFSC   bits_count, 2
    bra	    check_input_angle
    BTFSC   bits_count, 3
    bra	    check_input_angle
    return
    
    
    
check_zero
    BTFSS   W, 1
    bra	    check_input_angle
    bra	    zero_passed
    
    
    
    end