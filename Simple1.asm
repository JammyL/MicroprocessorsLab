<<<<<<< HEAD
	#include "p18f87k22.inc"
 
=======
	#include p18f87k22.inc

	extern	UART_Setup, UART_Transmit_Message   ; external UART subroutines
	extern  LCD_Setup, LCD_Write_Message	    ; external LCD subroutines
	extern	LCD_Write_Hex			    ; external LCD subroutines
	extern  ADC_Setup, ADC_Read		    ; external ADC routines
	
acs0	udata_acs   ; reserve data space in access ram
counter	    res 1   ; reserve one byte for a counter variable
delay_count res 1   ; reserve one byte for counter in the delay routine

tables	udata	0x400    ; reserve data anywhere in RAM (here at 0x400)
myArray res 0x80    ; reserve 128 bytes for message data

rst	code	0    ; reset vector
	goto	setup

pdata	code    ; a section of programme memory for storing data
	; ******* myTable, data in programme memory, and its length *****
myTable data	    "Hello World!\n"	; message, plus carriage return
	constant    myTable_l=.13	; length of data
	
main	code
	; ******* Programme FLASH read Setup Code ***********************
setup	bcf	EECON1, CFGS	; point to Flash program memory  
	bsf	EECON1, EEPGD 	; access Flash program memory
	call	UART_Setup	; setup UART
	call	LCD_Setup	; setup LCD
	call	ADC_Setup	; setup ADC
	goto	start
>>>>>>> origin/sandbox
	
	; ******* Main programme ****************************************
start 	lfsr	FSR0, myArray	; Load FSR0 with address in RAM	
	movlw	upper(myTable)	; address of data in PM
	movwf	TBLPTRU		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL		; load low byte to TBLPTRL
	movlw	myTable_l	; bytes to read
	movwf 	counter		; our counter register
loop 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter		; count down to zero
	bra	loop		; keep going until finished
		
	movlw	myTable_l-1	; output message to LCD (leave out "\n")
	lfsr	FSR2, myArray
	call	LCD_Write_Message

<<<<<<< HEAD
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
=======
	movlw	myTable_l	; output message to UART
	lfsr	FSR2, myArray
	call	UART_Transmit_Message
	
measure_loop
	call	ADC_Read
	movf	ADRESL,W
	call	LCD_Write_Hex
	movf	ADRESH,W
	call	LCD_Write_Hex
	goto	measure_loop		; goto current line in code

	; a delay subroutine if you need one, times around loop in delay_count
delay	decfsz	delay_count	; decrement until zero
	bra delay
	return

	end
>>>>>>> origin/sandbox
