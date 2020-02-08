	 #include "p18f87k22.inc"

acs0	udata_acs   ; reserve data space in access ram
	 
angle	    res 1
unit_count  res 1
bits_on	    res 1
bit_count   res 1
	
get_angle
    clrf    TRISD
    movlw   0x02
    movwf   unit_count
    call    check_input_angle
    
    
check_input_angle
    movlw   0x08
    movwf   bit_count
    movf    PORTD, W
    BTFSC   W, 3
    bra	    check_input_angle
    BTFSC   W, 7
    bra     check_zero
zero_passed
    decf    bit_count
    BTFSC   W,	bit_count 
    
    
    
check_zero
    BTFSS   W, 1
    bra	    check_input_angle
    bra	    zero_passed
    
    
test_valid_angle
    
    
	
    
 