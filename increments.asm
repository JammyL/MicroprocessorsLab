	#include "p18f87k22.inc"
	; code to manahe incremental movement
	
    global  deci_lat, deci_lon
    global  display_lat, display_lon
    extern  lat, lat_filler, lon, lon_filler
    extern  input, temp, count, DELAY
    extern  LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us, LCD_Send_Byte_D
    global  check_up_down, check_left_right
acs0	udata_acs   ; reserve data space in access ram
deci_lat    res	3
deci_lon    res 3
    
    
incremenets	code 0xA00    

check_up_down
	btfsc	input, 4	; checks if up has been pressed
	call	move_up		; if pressed, move up
	btfsc	input, 6	; checks if down has been pressed
	call	move_down	; if pressed move down
	return

check_left_right
	btfsc	input, 0	; checks if left has been pressed
	call	move_left	; if pressed move left
	btfsc	input, 2	; checks if right has been pressed
	call	move_right	; if pressed move right
	return
	
move_up					; increments latitude by 1
	setf	TRISC		; sets PORT C to input
	BCF	INTCON, GIE		; Disbales global interrupts
	lfsr	FSR1, deci_lat	; points FSR1 to decimal of lat
	movf	POSTINC1, W		; cycles FSR1 to end of deci lat
	movf	POSTINC1, W
	movlw	0xBE			; checks value is not greater than 190
	cpfslt	lat				; if greater than 190, returns
	return
	
	movlw	0x09			; loads 9 to Wreg
	incf	lat				; increments latitude
	decf	lat_filler		; decrements lat filler
	cpfslt	INDF1			; if decimal less than 9, increment
	clrf	POSTDEC1		; if 9, clear and move to next digit
	cpfslt	INDF1			; checks digit less than 9
	clrf	POSTDEC1		; if not less than 9, clear and move to next digit
	incf	INDF1			; increment digit
	
	
	BCF	    TRISB, INT1		; set RB1 to output
	call	display_lat		; displays new latitude to LCD
	return
	
move_down					; decrements latitude by 1
	setf	TRISC			; sets PORTC to input mode
	BCF	INTCON, GIE			; disables global interrupts
	lfsr	FSR1, deci_lat	; loads decimal lat to FSR1
	movf	POSTINC1, W		; cycles to lat digit of FSR1
	movf	POSTINC1, W
	movlw	0x0A			; loads 10 to Wreg
	cpfsgt	lat				; checks latitude greater than 10
	return					; if 10 or lower, return
	
	movlw	0x09			; loads 9 to Wreg
	movwf	temp			; puts 9 in temp reg
	movlw	0x00			; loads 0 to Wreg
	decf	lat				; decrements latitude
	incf	lat_filler		; increments lat filler
	cpfsgt	INDF1			; if first digit greater than 0 skip
	movff	temp, POSTDEC1	; if 0, puts 9 in current digit and moves on 
	cpfsgt	INDF1			; if second digit greater than 0, skip
	movff	temp, POSTDEC1	; if 0, put 9 in current digit and move on
	decf	INDF1			; decrement current digit
	
	
	BCF	    TRISB, INT1		; set RB1 to output
	call	display_lat		; sends latitude to LCD
	return

move_right					; increments logitude
	setf	TRISC			; sets PORTC to input mode
	BCF	INTCON, GIE			; disables global interrupts
	lfsr	FSR0, deci_lon	; loads deci lon in to FSR0
	movf	POSTINC0, W		; cycles deci lon to last digit
	movf	POSTINC0, W
	movlw	0xB4			; moves 180 to Wreg
	cpfslt	lon				; checks deci lon not greater than 180
	return
	
	movlw	0x09			; moves 9 to Wreg
	incf	lon				; increments logitude
	decf	lon_filler		; decrements lon filler
	cpfslt	INDF0			; compares first digit, skips if less than 9
	clrf	POSTDEC0		; if digit 9, set to 0 and move to next digit
	cpfslt	INDF0			; compares current digit, skips if less than 9
	clrf	POSTDEC0		; if digit 9, set to 0 and move to next digit
	incf	INDF0			; increments current digit
	BCF	    TRISB, INT1		; set RB1 to output
	call	display_lon		; displays logitude to LCD
	return
	
move_left					; decrements longitude
	setf	TRISC			; sets PORTC to input
	BCF	INTCON, GIE			; disables global interrupts
	lfsr	FSR0, deci_lon	 ; loads deci lon to FSR0
	movf	POSTINC0, W		 ; cycles to final digit
	movf	POSTINC0, W
	movlw	0x00			; puts 0 in Wreg
	cpfsgt	lon				; checks logitude greater than 0
	return					; if 0 or less, return
	
	movlw	0x09			; moves 9 to Wreg
	movwf	temp			; puts 9 in temp
	movlw	0x00			; move 0 to Wreg
	decf	lon				; decrements logitude
	incf	lon_filler		; increments logitude filler
	cpfsgt	INDF0			; compares current digit to 0, skips if greater than 
	movff	temp, POSTDEC0	; if digit 0, put 9 in current digit and move to next digit
	cpfsgt	INDF0			; compares current digit to 0, skips if greater than 
	movff	temp, POSTDEC0  ; if digit 0, put 9 in current digit and move to next digit
	decf	INDF0			; decrements current digit
	BCF	    TRISB, INT1		; set RB1 to output
	call	display_lon		; displazs logitude to LCD
	return
	
display_lat					; displays latitude to LCD
	movlw	b'10000101'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	lfsr    FSR0, deci_lat	; loads decimal lat to FSR0
	movlw   0x03			; counter for each digit
	movwf   count
display_lat_loop
	movf    POSTINC0, W	    
	addlw   0x30			; adds 48 to get ACII character	
	call    LCD_Send_Byte_D
	call    LCD_delay_x4us
	decfsz  count
    bra	display_lat_loop
	return
	
display_lon
	movlw	b'11000101'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	lfsr    FSR0, deci_lon	; loads decimal lon to FSR0
	movlw   0x03			; counter for each digit
	movwf   count
display_lon_loop
	movf    POSTINC0, W	   
	addlw   0x30			; adds 48 to get ACII character
	call    LCD_Send_Byte_D
	call    LCD_delay_x4us
	decfsz  count
	bra	display_lon_loop
	return
	
	end


