	#include "p18f87k22.inc"
	
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
	btfsc	input, 4
	call	move_up
	btfsc	input, 6
	call	move_down
	return

check_left_right
	btfsc	input, 0
	call	move_left
	btfsc	input, 2
	call	move_right
	return
	
move_up
	setf	TRISC
	BCF	INTCON, GIE
	lfsr	FSR1, deci_lat
	movf	POSTINC1, W
	movf	POSTINC1, W
	movlw	0xBE
	cpfslt	lat
	return
	
	movlw	0x09
	incf	lat
	decf	lat_filler
	cpfslt	INDF1
	clrf	POSTDEC1
	cpfslt	INDF1
	clrf	POSTDEC1
	incf	INDF1
	
	
	BCF	    TRISB, INT1
	;clrf	TRISB
	call	display_lat
	;setf	TRISB
	; BCF	    PORTB, INT1
	; BSF	    TRISB, INT1
	return
	
move_down
	setf	TRISC
	BCF	INTCON, GIE
	lfsr	FSR1, deci_lat
	movf	POSTINC1, W
	movf	POSTINC1, W
	movlw	0x0A
	cpfsgt	lat
	return
	
	movlw	0x09
	movwf	temp
	movlw	0x00
	decf	lat
	incf	lat_filler
	cpfsgt	INDF1
	movff	temp, POSTDEC1
	cpfsgt	INDF1
	movff	temp, POSTDEC1
	decf	INDF1
	
	
	BCF	    TRISB, INT1
	; clrf	TRISB
	call	display_lat
	;setf	TRISB
	; BCF	    PORTB, INT1
	; BSF	    TRISB, INT1
	return
	
move_right
	setf	TRISC
	BCF	INTCON, GIE
	lfsr	FSR0, deci_lon
	movf	POSTINC0, W
	movf	POSTINC0, W
	movlw	0xB4
	cpfslt	lon
	return
	
	movlw	0x09
	incf	lon
	decf	lon_filler
	cpfslt	INDF0
	clrf	POSTDEC0
	cpfslt	INDF0
	clrf	POSTDEC0
	incf	INDF0
	BCF	    TRISB, INT1
	call	display_lon
	lfsr	FSR0, deci_lon
	movf	POSTINC0, W
	movf	POSTINC0, W
	movf	POSTINC0, W
	; BCF	    PORTB, INT1
	return
	
move_left
	setf	TRISC
	BCF	INTCON, GIE
	lfsr	FSR0, deci_lon
	movf	POSTINC0, W
	movf	POSTINC0, W
	movlw	0x00
	cpfsgt	lon
	return
	
	movlw	0x09
	movwf	temp
	movlw	0x00
	decf	lon
	incf	lon_filler
	cpfsgt	INDF0
	movff	temp, POSTDEC0
	cpfsgt	INDF0
	movff	temp, POSTDEC0
	decf	INDF0
	BCF	    TRISB, INT1
	;BCF	    PORTB, INT1
	call	display_lon
	;BCF	    PORTB, INT1
	;BSF	    TRISB, INT1
	return
	
display_lat
	movlw	b'10000101'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	lfsr    FSR0, deci_lat
	movlw   0x03
	movwf   count
display_lat_loop
	movf    POSTINC0, W	    ; W=0 here WHY?
	addlw   0x30
	call    LCD_Send_Byte_D
	call    LCD_delay_x4us
	decfsz  count
        bra	display_lat_loop
;	setf	TRISB
	return
	
display_lon
	movlw	b'11000101'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	lfsr    FSR0, deci_lon
	movlw   0x03
	movwf   count
display_lon_loop
	movf    POSTINC0, W	    ; W=0 here WHY?
	addlw   0x30
	call    LCD_Send_Byte_D
	call    LCD_delay_x4us
	decfsz  count
	bra	display_lon_loop
;	setf	TRISB
	return
	
	end


