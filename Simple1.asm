	#include "p18f87k22.inc"
 
	
	org 0x100		    ; Main code starts here at address 0x100

acs0	udata_acs   ; reserve data space in access ram
count1	res	1
count2	res	2
	
code

	
clrf	TRISC
	
loop
	movlw	b'11111111'
	movwf	PORTC
	call	delay1		; Loop testing delay1 and 2
	movlw	b'00000000'
	movwf	PORTC
	goto loop
	
delay1				; delay function to run 711 clock cycles
	movlw	0x03		; loads 3 to wreg
	movwf	count1		; moves 3 to count1 reg
delay1_loop
	call	delay2		; calls delay2 subroutine
	DECFSZ	count1		; decrements count1
	bra	delay1_loop	; loops delay1
	nop			; skips a clock cycle
	return			

delay2	movlw	0x4B		; loads 75 to wreg
	movwf	count2		; moves 75 to count2 reg
delay2_loop
	DECFSZ	count2		; decrements count2
	bra	delay2_loop	; loops delay2
	return


END