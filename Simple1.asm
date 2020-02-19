	#include p18f87k22.inc

	; gets keyboard input
	; checks for interrupt
	; define new registers for decimal values
	deci_lat res	3
	deci_lon res	3
	
	lfsr	FSR0, deci_lat
	lfsr	FSR1, deci_lon
	btfsc	input, 1
	call	check_up_down
	btfsc	input, 5
	call	check_left_right
	
	; display decimals to LCD

	send_lat
	send_lon
	
check_up_down
	btfsc	input, 4
	bra	move_up
	btfsc	input, 6
	bra	move_down
	return

check_left_right
	btfsc	input, 0
	bra	move_up
	btfsc	input, 2
	bra	move_down
	return
	
move_up
	movlw	0xb4
	cpfslt	lon
	return
	
	movlw	0x09
	incf	lon
	decf	lon_filler
	cpfslt	INDF1
	clrf	POSTINC1
	cpfslt	INDF1
	clrf	POSTINC1
	incf	INDF1
	return
	
move_down
	movlw	0x00
	cpfsgt	lon
	return
	
	movlw	0x09
	movwf	temp
	movlw	0x00
	incf	lon
	decf	lon_filler
	cpfsgt	INDF1
	movff	temp, POSTINC1
	cpfsgt	INDF1
	movff	temp, POSTINC1
	decf	INDF1
	return
	
move_right
	movlw	0xb4
	cpfslt	lat
	return
	
	movlw	0x09
	incf	lat
	decf	lat_filler
	cpfslt	INDF0
	clrf	POSTINC0
	cpfslt	INDF0
	clrf	POSTINC0
	incf	INDF0
	return
	
move_left
	movlw	0x00
	cpfsgt	lat
	return
	
	movlw	0x09
	movwf	temp
	movlw	0x00
	incf	lat
	decf	lat_filler
	cpfsgt	INDF0
	movff	temp, POSTINC0
	cpfsgt	INDF0
	movff	temp, POSTINC0
	decf	INDF
	return
	
	
	end
