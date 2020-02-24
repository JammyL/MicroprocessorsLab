	 #include "p18f87k22.inc"
	 
	 global	    get_angle, send_lon, send_lat
	 global	    deci, angle, input, temp
	 extern	    LCD_Send_Byte_D, LCD_Send_Byte_I, LCD_delay_x4us
	 extern	    delay_base, delay_var
	 extern     KEYBOARD_VERT, KEYBOARD_HOR
	 extern	    lat, lon, lat_filler, lon_filler
	 
acs0	udata_acs   ; reserve data space in access ram
	 
angle	    res 1
count_end   res 1
unit_count  res 1
deci	    res	3
input	    res	1
temp	    res 1
bits_on	    res 1
bits_count  res 1
bits_test   res 1
nil	    res 1
	    
angle code 0x500
	    
get_angle
    clrf    angle	;clear angle for new value to be written
    clrf    deci	; clears temp for new value 
    lfsr    FSR0, deci	; moves temp byte one to file select zero
    call    get_input_angle ;gets input from keypad
    movlw   0xB4
    call    delay_var
    call    process_angle   ;converts to decimal 0 -> 9
    call    get_nil	    ; checks for key unpressed
    movlw   0xB4
    call    delay_var
    call    get_nil	    ; checks for key unpresse
    movlw   0x02	    ; checks value less than 2 for first digit
    cpfslt  INDF0	    ; cheks less than 2 also
    bra	    get_angle	    ; if less than 2, get new value
    
    ;	TODO:Change function names
    call    LCD_delay_x4us
    movf    INDF0, W	    ; W=0 here WHY?
    addlw   0x30
    call    LCD_Send_Byte_D
    call    LCD_delay_x4us
;    movf    INDF0, W
    
    
    movlw   0x64	    ; multiplies decimal by 100
    mulwf   POSTINC0, W	    ; multiplies decimal by 100
    movf    PRODL, W
    addwf   angle	    ; adds hex value to angle
    call    get_input_angle ; gtets input form keypad
    movlw   0xB4
    call    delay_var
    call    process_angle   ; converts to decimal 0 -> 9
    call    get_nil	    ; checks for key unpressed
    movlw   0xB4
    call    delay_var
    call    get_nil	    ; checks for key unpresse
    
    ;	TODO: DISPLAY DIGIT, Change function names
    movf    INDF0, W	    ; W=0 here WHY?
    addlw   0x30
    call    LCD_Send_Byte_D
    call    LCD_delay_x4us
    
    movlw   0x0A	    ; multiplies decimal by 10
    mulwf   POSTINC0, W	    ; multiplies decimal by 10
    movf    PRODL, W	    ; moves value to W
    addwf   angle	    ; adds hex value to angle
    call    get_input_angle	; gets input from keypad
    movlw   0xB4
    call    delay_var
    call    process_angle	; converts to decimal 0 -> 9
    call    get_nil		; checks for key unpressed
    movlw   0xB4
    call    delay_var
    call    get_nil	    ; checks for key unpresse
    
    ;	TODO: DISPLAY DIGIT, Change function names
    movf    INDF0, W	    ; W=0 here WHY?
    addlw   0x30
    call    LCD_Send_Byte_D
    call    LCD_delay_x4us
    
    movf    INDF0, W		; moves decimal to W
    addwf   angle		; adds value to angle WHERE DO YOU WANT TO SAVE THIS?
    
    
    return
    


get_input_angle
    clrf    TRISC
    movlw   0x08
    movwf   bits_count
    clrf    input
    call    KEYBOARD_HOR
    movwf   input
    movlw   0x0F
    cpfseq  input
    bra	    pressed
    bra	    get_input_angle
pressed
    call    KEYBOARD_VERT
    ANDWF   input, F
    movf    input, W
;    movff   input, PORTD
    btfsc   input, 3
    bra	    get_input_angle
    btfsc   input, 7
    bra     check_zero
    movff   input, bits_test
zero_passed 
    btfsc   bits_test, 0
    incf    bits_on
    rrncf   bits_test
    decfsz  bits_count
    bra	    zero_passed
    movlw   0x02
    cpfseq  bits_on
    bra	    get_input_angle
    return
    
get_nil
    call    KEYBOARD_HOR
    movwf   nil
    movlw   0x0F
    cpfseq  nil
    bra	    get_nil
    return
    
check_zero
    btfss   input, 1
    bra	    get_input_angle
    bra	    zero_passed
    
process_angle
    movlw   0x04
    movwf   temp
    movf    input, W
    clrf    INDF0
    btfsc   input, 7
    bra	    process_done
process_loop_1
    incf    INDF0
    btfsc   input, 0
    bra	    process_loop_2
    decf    temp
    rrncf   input
    bra	    process_loop_1 
process_loop_2
    rrncf   input
    decfsz  temp
    bra	    process_loop_2
process_loop_3
    btfsc   input, 0
    bra	    process_done
    rrncf   input
    incf    INDF0
    incf    INDF0
    incf    INDF0
    bra	    process_loop_3
process_done
    movf    INDF0, W
    return
    

    
send_lat
	BSF	PORTD, 1
	movlw	0x36	    ; Was 2D
	call	delay_var
	movf	lat, W
	tstfsz	lat
	call	delay_var
	BCF	PORTD, 1
	movf	lat_filler, W
	tstfsz	lat_filler
	call	delay_var
	movlw	0x0A	    ;Was 07
	movwf	count_end
	bra	send_end_loop
	
send_lon
	BSF	PORTD, 2
	movlw	0x36	    ; Was 2D
	call	delay_var
	movf	lon, W
	tstfsz	lon
	call	delay_var
	BCF	PORTD, 2
	movf	lon_filler, W
	tstfsz	lon_filler
	call	delay_var
	movlw	0x0A	    ; was 07
	movwf	count_end
	bra	send_end_loop
	
send_end_loop
	movlw	0xA8		; WAS E1 was e5
	call	delay_var
	decfsz	count_end
	bra	send_end_loop
	movlw	0x06
	call	delay_var
	return
    
    
    end


