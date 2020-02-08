	 #include "p18f87k22.inc"
	 
acs0	udata_acs   ; reserve data space in access ram
	 
angle	    res 1
unit_count  res 1
temp	    res	1
bits_on	    res 1
bits_count  res 1
bits_test   res 1
   
code
	
get_angle
    clrf    TRISD
    clrf    angle
    call    get_input_angle
    call    process_angle
    call    get_nil
    movlw   0x01
    cpfsgt  temp
    bra	    get_angle
    ;	TODO: DISPLAY DIGIT
    movlw   0x0A
    mulwf   temp

    addwf   angle
    
    


get_input_angle
    movlw   0x08
    movwf   bits_count
    movf    PORTD, W
    tstfsz  W
    bra	    get_input_angle
    btfsc   W, 3
    bra	    get_input_angle
    btfsc   W, 7
    bra     check_zero
zero_passed
    movwf   bits_test
    btfsc   bits_test, 0
    incf    bits_on
    rrncf   bits_test
    decfsz  bits_count
    bra	    zero_passed
    btfsc   bits_count, 2
    bra	    get_input_angle
    btfsc   bits_count, 3
    bra	    get_input_angle
    return
    
get_nil
    movf    PORTD, W
    tstfsz  W
    bra	    get_nil
    return
    
check_zero
    btfss   W, 1
    bra	    get_input_angle
    bra	    zero_passed
    
process_angle
    clrf    temp
    btfsc   W, 7
    bra	    process_done
process_loop_1
    incf    temp
    btfsc   W
    bra	    process_done
    rrncf   W
    bra	    process_loop1  
process_loop_3
    btfsc   W
    bra	    process_done
    rrncf   W
    incf    temp
    incf    temp
    incf    temp
    bra	    process_loop3
process_done
    return
    

    
    
    
    end