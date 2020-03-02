	#include "p18f87k22.inc"
	; main code for robot arm operation

	; import and export of necessary funtions and variables
	global	lat, lon, lat_filler, lon_filler
	extern	get_angle, send_lat, send_lon
	extern	deci, angle, deci_lat, deci_lon
	extern  KEYBOARD_VERT, KEYBOARD_HOR
	extern	check_left_right, check_up_down
	extern	display_lon, display_lat
	extern	temp
	extern	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us
	extern	DELAY, delay_base, delay_var
	extern	input
	
	org 0x000		    	; Main code starts here at address 0x100
	goto init_LCD
	
int_hi	code	0x0008		; high priority interrupt
	
	btfss	INTCON3, INT1IF ; check if interrupt from keypad
	goto  skip_interrupt	; if not then return
	
	btfsc	input, 0		; check if A pressed
	goto	check_A			
	
	btfsc	input, 2		; check if B pressed
	goto	check_B
	
	return					; end interrupt
	

acs0	udata_acs   		; reserve data space in access ram
lat	res 1
lon	res 1
lat_filler  res 1
lon_filler  res 1
counter	res	1

tables	udata	0x800		; tables memory
lat_arr	res	0x40
lon_arr	res	0x40
	
pdata	code
lat_msg	data	"Lat: "
	constant    lat_msg_l=.5
lon_msg	data	"Lon: "
	constant    lon_msg_l=.5

	
	
main code 0x100				; main code
 
init_LCD						
	    bcf	    EECON1, CFGS	; point to Flash program memory  
	    bsf	    EECON1, EEPGD 	; access Flash program memory
	    call    LCD_Setup		; initialise LCD
	    call    send_Lat_tag	; sends "Lat: " to LCD
	    call    send_Lon_tag    ; sends "Lon: " to LCD

init_pos    					; sets the servos to central positions
	    setf    TRISC			; set port C to input
	    movlw   0x5A			; 90 in lon
	    movwf   lon
	    movwf   lon_filler		; 90 in lon_filler
	    clrf    lat				; 0 in lat
	    movlw   0xB4
	    movwf   lat_filler		; 180 in lat_filler
	    
	    lfsr    FSR0, deci_lon	; ponits FSR0 to decimal of lon
	    clrf    POSTINC0		; clears the first digit (0)
	    movlw   0x09			; set second digit to 9
	    movwf   POSTINC0
	    clrf    POSTINC0		; clears final digit (0)
	    
	    lfsr    FSR0, deci_lat	; sets FSR0 to decimal of lat
	    clrf    POSTINC0		; clears all 3 digits (0)
	    clrf    POSTINC0
	    clrf    POSTINC0
	    
	    call    display_lon		; sends lon to LCD
	    call    display_lat		; sends lat to LCD
	    movlw   0xAA
	    movwf   temp			; move 176 to W
init_loop1						; send PWM signal to lat servo
	    call    send_lat		; send single PWM pulse
	    decfsz  temp
	    bra	    init_loop1
	    movlw   0xAA
	    movwf   temp
init_loop2						; send PWM signal to lon servo
	    call    send_lon		; send single PWM pulse
	    decfsz  temp
	    bra	    init_loop2
init_ports
	    clrf    TRISD			; set port D as output
	   

run	  
	    clrf    TRISC			; set port C as output 
	    BSF	    TRISB, INT1		; set RB1 as input
	    BCF	    INTCON3, INT1IF ; clear interrupt flag for RB1
	    BSF	    INTCON3, INT1IE ; rising edge interrupt
	    BSF	    INTCON2, INTEDG1
	    BSF	    INTCON, GIE		; start global interrupts 
	   
	    clrf    input			; sets input to 0
	    call    KEYBOARD_HOR	; gets horizontal key information
	    movwf   input			; move to input
	    movlw   0x0F			; looks only at one side
	    cpfseq  input			; checks for input
	    bra	    pressed			; if input go to pressed
	    bra	    skip			; if no input go to skip
pressed
	    call    KEYBOARD_VERT	; gets vertical key information
	    ANDWF   input, F		; creates complete keyboard input
	    btfsc   input, 1		; checks for up/down
	    call    check_up_down
	    btfsc   input, 5		; checks for left/right
	    call    check_left_right
	    call    send_lat		; send 3 PWM signals each
	    call    send_lat
	    call    send_lat
	    call    send_lon
	    call    send_lon
	    call    send_lon

skip
	    movff   input, PORTC	; sends input to port C
	    goto    run				; loops back

skip_interrupt					; if interrupt not from keypad
	BSF	TRISB, INT1				; if interrupt not from keypad
	BCF	INTCON3, INT1IF			; clear interrupt flag
	return
	
	
	

send_Lat_tag				; sends "Lat: " to LCD
	lfsr	FSR0, lat_arr	; read string into RAM
	movlw	upper(lat_msg)
	movwf	TBLPTRU
	movlw	high(lat_msg)
	movwf	TBLPTRH
	movlw	low(lat_msg)
	movwf	TBLPTRL
	movlw	lat_msg_l
	movwf	counter
loop_Lat					; send individual chars from W
	tblrd*+
	movff	TABLAT, POSTINC0
	decfsz	counter
	bra	loop_Lat
	movlw	lat_msg_l
	lfsr	FSR2, lat_arr
	call	LCD_Write_Message
	return

	
send_Lon_tag				; sends "Lon: " to LCD
	movlw	b'11000000'		; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10				; wait 40us
	call	LCD_delay_x4us
	
	lfsr	FSR0, lon_arr	; read string into RAM
	movlw	upper(lon_msg)
	movwf	TBLPTRU
	movlw	high(lon_msg)
	movwf	TBLPTRH
	movlw	low(lon_msg)
	movwf	TBLPTRL
	movlw	lon_msg_l
	movwf	counter
loop_Lon
	tblrd*+					; send individual chars from W
	movff	TABLAT, POSTINC0
	decfsz	counter
	bra	loop_Lon
	movlw	lon_msg_l
	lfsr	FSR2, lon_arr
	call	LCD_Write_Message
	return

check_A						; if input is A and sends right PWM
	btfss	    input, 7	; check input is from key A
	goto	    skip_interrupt ; skips if not
	BCF	    TRISB, INT1		; RB1 to output
	movlw	b'11000101'		; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10				; wait 40us
	call	LCD_delay_x4us
	
	call	get_angle		; retrieves user input for full angle
	lfsr	FSR0, deci		; point FSR0 to deci
	lfsr	FSR1, deci_lon	; point FSR1 to decimal lon
	movff	POSTINC0, POSTINC1	; moves deci to deci_lon
	movff	POSTINC0, POSTINC1
	movff	POSTINC0, POSTINC1
	movff	angle, lon		; sends angle to lon
	movlw	0xB4			; fills lon_filler
	movwf	lon_filler		; fills lon_filler
	movf	lon, W			; fills lon_filler
	subwf	lon_filler		; fills lon_filler
	movlw	0xAA	    	
	movwf	counter			; counter for PWM loops
send_loop_A					; sends PWM signal 176 times
	call	send_lon		
	decfsz	counter
	goto	send_loop_A
	BCF	INTCON3, INT1IF		; clears interrupt flag
	return

check_B						; if input is B and sends right PWM
	btfss	    input, 7	; check input is from key B
	goto	    skip_interrupt ; skips if not
	BCF	    TRISB, INT1		; RB1 to output
	movlw	b'10000101'		; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10				; wait 40us
	call	LCD_delay_x4us
	
	call	get_angle		; retrieves user input for full angle
	movlw	0x0A			; adds 10 to angle
	addwf	angle
	movff	angle, lat		; sends angle to lat
	lfsr	FSR0, deci		; point FSR0 to deci
	lfsr	FSR1, deci_lat	; point FSR1 to decimal lon
	movff	POSTINC0, POSTINC1 ; moves deci to deci_lon
	movff	POSTINC0, POSTINC1
	movff	POSTINC0, POSTINC1
	movlw	0xB4
	movwf	lat_filler		; fills lat_filler
	movf	lat, W			; fills lat_filler
	subwf	lat_filler		
	movlw	0xAA			
	movwf	counter			; counter for PWM loops
send_loop_B					; sends PWM signal 176 times
	call	send_lat
	decfsz	counter
	goto	send_loop_B
	BCF	INTCON3, INT1IF
	return
	
	end