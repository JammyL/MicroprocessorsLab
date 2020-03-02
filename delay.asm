	 #include "p18f87k22.inc"
	 
    global  delay_base, delay_var
    
acs0	udata_acs   ; reserve data space in access ram
count1	res	1
count2	res	1
count_var  res 1
    
delay	code 0x900    
    
    
delay_base			; delay function to run 167 clock cycles
	movlw	0x02		; loads 3 to wreg
	movwf	count1		; moves 3 to count1 reg
delay_base_loop
	call	delay_base_sub	; calls delay2 subroutine
	DECFSZ	count1		; decrements count1
	bra	delay_base_loop	; loops delay1	
	nop
	nop
	nop
	return			

delay_base_sub	
	movlw	0x17		; loads 26 to wreg (WAS 1A)
	movwf	count2		; moves 25 to count2 reg
delay_base_sub_loop
	DECFSZ	count2		; decrements count2
	bra	delay_base_sub_loop	; loops delay2
	return
	
delay_var
	movwf	count_var
delay_var_loop
	call	delay_base
	DECFSZ	count_var
	bra	delay_var_loop
	return

	end

