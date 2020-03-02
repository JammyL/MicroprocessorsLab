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
    
    call    LCD_delay_x4us
    movf    INDF0, W        ; loads character to Wreg
    addlw   0x30            ; adds 48 for ACII character
    call    LCD_Send_Byte_D ; sends character to LCD
    call    LCD_delay_x4us
    
    
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
    call    get_nil	    ; checks for key unpressed

    movf    INDF0, W    ; loads character to Wreg
    addlw   0x30        ; adds 48 for ACII character
    call    LCD_Send_Byte_D ; sends character to LCD
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
    
    movf    INDF0, W	; loads character to Wreg
    addlw   0x30        ; adds 48 for ACII character
    call    LCD_Send_Byte_D ; sends character to LCD
    call    LCD_delay_x4us
    
    movf    INDF0, W		; moves decimal to W
    addwf   angle		; adds value to angle WHERE DO YOU WANT TO SAVE THIS?
    
    
    return
    


get_input_angle
    clrf    TRISC       ; sets PORTC to output
    movlw   0x08        ; loads 8 for counting all input pins
    movwf   bits_count  ; moves 8 to bits count
    clrf    input       ; clears input
    call    KEYBOARD_HOR    ; gets first part of keyboard input
    movwf   input           ; moves to input
    movlw   0x0F            
    cpfseq  input           ; checks for non nill input
    bra	    pressed         ; if non nill, go to pressed
    bra	    get_input_angle ; if nill, loop back
pressed
    call    KEYBOARD_VERT   ; gets rest of keybord input
    ANDWF   input, F        ; fills in rest of input
    movf    input, W        ; moves input to Wreg
    btfsc   input, 3        ; checks pin three not on - invalid input
    bra	    get_input_angle ; if pin three high, get new input
    btfsc   input, 7        ; checks pin seven not on - invalid input
    bra     check_zero      ; checks that the button pressed was 0 and not A, B or C
    movff   input, bits_test   ; move input to bits_tsts
zero_passed 
    btfsc   bits_test, 0        ; checks only two pins of 8 high
    incf    bits_on             ; increments for every pin high
    rrncf   bits_test           ; rotates to check new bit
    decfsz  bits_count
    bra	    zero_passed
    movlw   0x02
    cpfseq  bits_on             ; checks only two pins of 8 high
    bra	    get_input_angle
    return
    
get_nil
    call    KEYBOARD_HOR        ; checks for nill input. (nothing pressed)
    movwf   nil
    movlw   0x0F
    cpfseq  nil
    bra	    get_nil
    return
    
check_zero                      ; checks button pressed is zero
    btfss   input, 1
    bra	    get_input_angle
    bra	    zero_passed
    
process_angle                   ; converts keypad input to numerical value
    movlw   0x04                ; moves 4 to Wreg
    movwf   temp                ; moves 4 to temp
    movf    input, W            ; moves input to Wreg
    clrf    INDF0               ; clears value in FSR0
    btfsc   input, 7            ; if zero, nothing to be added
    bra	    process_done        ; process done if zero
process_loop_1
    incf    INDF0               ; for every column along bit is on, add 1
    btfsc   input, 0
    bra	    process_loop_2      ; once high bit found, skip to next loop
    decf    temp
    rrncf   input               ; rotates input to check next bit
    bra	    process_loop_1  
process_loop_2                  ; rotates to second half of input
    rrncf   input
    decfsz  temp
    bra	    process_loop_2
process_loop_3                  ; for everz row along bit is on, add 3
    btfsc   input, 0
    bra	    process_done
    rrncf   input               ; rotates input to check next bit
    incf    INDF0               ; increments by 3
    incf    INDF0
    incf    INDF0
    bra	    process_loop_3
process_done
    movf    INDF0, W
    return
    

    
send_lat                ; send PWM lat signal
	BSF	PORTD, 1        ; sets PORT D pin 1 high
	movlw	0x36
	call	delay_var   ; calls base delay unit 54 times
	movf	lat, W      ; moves lat to W
	tstfsz	lat         ; if 0 do not call delay
	call	delay_var   ; calls delay unit lat number of times
	BCF	PORTD, 1        ; sets PORT D pin 1 low
	movf	lat_filler, W  ; moves lat filler to W
	tstfsz	lat_filler  ; if 0 do not call delay
	call	delay_var   ; calls delay unit lat filler number of times
	movlw	0x0A	    
	movwf	count_end   ; sends end of PWM signal
	bra	send_end_loop
	
send_lon                ; send PWM long signal
	BSF	PORTD, 2        ; sets PORT D pin 2 high
	movlw	0x36	    
	call	delay_var   ; calls delay base unit 54 times
	movf	lon, W      ; moves lon to W
	tstfsz	lon         ; if 0 do not call delay
	call	delay_var   ; calls delay lon number of times
	BCF	PORTD, 2        ; sets PORTD pin 2 low
	movf	lon_filler, W   ; moves Lon filler to W
	tstfsz	lon_filler      ; if zero do not not call delaz
	call	delay_var       ; call base delay lon filler number of times
	movlw	0x0A	    
	movwf	count_end       ; sends end of PWM signal
	bra	send_end_loop
	
send_end_loop           ; finishes PWM signal
	movlw	0xA8		
	call	delay_var   ; calls base delay 0xA8 times
	decfsz	count_end
	bra	send_end_loop
	movlw	0x06
	call	delay_var   ; calls base delay 6 times
	return
    
    
    end


