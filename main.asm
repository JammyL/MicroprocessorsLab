	#include "p18f87k22.inc"
	
	global	lat, lon, lat_filler, lon_filler
	extern	get_angle, send_lat, send_lon
	extern	deci, angle, deci_lat, deci_lon
	extern  KEYBOARD_VERT, KEYBOARD_HOR
	extern	check_left_right, check_up_down
	extern	display_lon, display_lat
	extern	temp
;	extern	interrupt_setup
	extern	LCD_Setup, LCD_Write_Message, LCD_Send_Byte_I, LCD_delay_x4us
	extern	DELAY, delay_base, delay_var
	extern	input
	
	org 0x000		    ; Main code starts here at address 0x100
	goto init_LCD
	
int_hi	code	0x0008	; high vector, no low vector
	
	btfss	INTCON3, INT1IF;
	goto  skip_interrupt	; if not then return
	
;	movlw   0x0F
;	movwf   TRISE
;	movlw   0xF0
;	movwf   PORTE
;	
;	movlw	0x0A
	
	btfsc	input, 0
	goto	check_A
	
	btfsc	input, 2
	goto	check_B
	
	; retfie	FAST
	return
	

acs0	udata_acs   ; reserve data space in access ram
lat	res 1
lon	res 1
lat_filler  res 1
lon_filler  res 1
counter	res	1

tables	udata	0x800
lat_arr	res	0x40
lon_arr	res	0x40
	
pdata	code
lat_msg	data	"Lat: "
	constant    lat_msg_l=.5
lon_msg	data	"Lon: "
	constant    lon_msg_l=.5

	
	
main code 0x100
 
init_LCD
	    bcf	    EECON1, CFGS	; point to Flash program memory  
	    bsf	    EECON1, EEPGD 	; access Flash program memory
	    call    LCD_Setup
	    call    send_Lat_tag
	    call    send_Lon_tag    
init_pos    
	    setf    TRISC
	    movlw   0x5A
	    movwf   lon
	    movwf   lon_filler
	    clrf    lat
	    movlw   0xB4
	    movwf   lat_filler
	    
	    lfsr    FSR0, deci_lon
	    clrf    POSTINC0
	    movlw   0x09
	    movwf   POSTINC0
	    clrf    POSTINC0
	    
	    lfsr    FSR0, deci_lat
	    clrf    POSTINC0
	    clrf    POSTINC0
	    clrf    POSTINC0
	    
	    call    display_lon
	    call    display_lat
	    movlw   0xAA
	    movwf   temp
init_loop1
	    call    send_lat
	    decfsz  temp
	    bra	    init_loop1
	    movlw   0xAA
	    movwf   temp
init_loop2
	    call    send_lon
	    decfsz  temp
	    bra	    init_loop2
init_ports
	    clrf    TRISD
	    clrf    TRISC
	    clrf    input
	   
	    

run	  
	    clrf    TRISC
	    BSF	    TRISB, INT1
	    BCF	    INTCON3, INT1IF
	    BSF	    INTCON3, INT1IE
	    BSF	    INTCON2, INTEDG1
	    BSF	    INTCON, GIE
	   
	    
	    
;	    movlw   0xF0
;	    movwf   TRISE
;	    movlw   0x0F
;	    movwf   PORTE
	    
	    
	    clrf    input
	    call    KEYBOARD_HOR
	    movwf   input
	    movlw   0x0F
	    cpfseq  input
	    bra	    pressed
	    bra	    skip
pressed
	    call    KEYBOARD_VERT
	    ANDWF   input, F
	    btfsc   input, 1
	    call    check_up_down
	    btfsc   input, 5
	    call    check_left_right
	    call    send_lat
	    call    send_lat
	    call    send_lat
	    call    send_lon
	    call    send_lon
	    call    send_lon

skip
	    movff   input, PORTC
	    goto    run

skip_interrupt
	BSF	TRISB, INT1
	BCF	INTCON3, INT1IF
	; retfie	FAST
	return
	
	
;loop
;;	setf	PORTD
;;	movlw	0xB4
;;	call	delay_var
;;	clrf	PORTD
;;	movlw	0xB4
;;	call	delay_var
;;	goto	loop
;	nop
;	nop
;	call	get_angle
;	movlw	0xB4
;	subfwb	angle, W
;	movwf	angle_filler
;read	
;	lfsr	FSR0, deci
;	movf	POSTINC0, W
;	movf	POSTINC0, W
;	movf	POSTINC0, W
;	movf	angle, W
;angle_loop
;	call	send_angle
;	goto    angle_loop
	
;
;send_angle
;	BSF	PORTD, 1
;	movlw	0x2D
;	call	delay_var
;	movf	angle, W
;	call	delay_var
;	BCF	PORTD, 1
;	movf	angle_filler
;	call	delay_var
;	movlw	0x07
;	movwf	count_end
;count_end_loop
;	movlw	0xE1
;	call	delay_var
;	decfsz	count_end
;	bra	count_end_loop
;	return
;	
	
	
	
	
	

send_Lat_tag
	lfsr	FSR0, lat_arr	; read string into RAM
	movlw	upper(lat_msg)
	movwf	TBLPTRU
	movlw	high(lat_msg)
	movwf	TBLPTRH
	movlw	low(lat_msg)
	movwf	TBLPTRL
	movlw	lat_msg_l
	movwf	counter
loop_Lat			; send individual chars from W
	tblrd*+
	movff	TABLAT, POSTINC0
	decfsz	counter
	bra	loop_Lat
	movlw	lat_msg_l
	lfsr	FSR2, lat_arr
	call	LCD_Write_Message
	return

	
send_Lon_tag
	movlw	b'11000000'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
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
	tblrd*+			; send individual chars from W
	movff	TABLAT, POSTINC0
	decfsz	counter
	bra	loop_Lon
	movlw	lon_msg_l
	lfsr	FSR2, lon_arr
	call	LCD_Write_Message
	return

check_A	
	;BSF	    INTCON, RBIE
	btfss	    input, 7
	goto	    skip_interrupt
	BCF	    TRISB, INT1
	movlw	b'11000101'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	
	call	get_angle
	lfsr	FSR0, deci
	lfsr	FSR1, deci_lon
	movff	POSTINC0, POSTINC1
	movff	POSTINC0, POSTINC1
	movff	POSTINC0, POSTINC1
	movff	angle, lon
	movlw	0xB4
	movwf	lon_filler
	movf	lon, W
	subwf	lon_filler
	movlw	0xFF	    ;  CHANGE BACK TO AA
	movwf	counter
send_loop_A
	call	send_lon
	decfsz	counter
	goto	send_loop_A
	BCF	INTCON3, INT1IF
	; RETFIE	FAST
	return

check_B	
	;BSF	    INTCON, RBIE
	btfss	    input, 7
	goto	    skip_interrupt
	BCF	    TRISB, INT1
	movlw	b'10000101'	; set marker to the 2nd line
	call	LCD_Send_Byte_I	
	movlw	.10		; wait 40us
	call	LCD_delay_x4us
	
	call	get_angle
	movlw	0x0A
	addwf	angle
	movff	angle, lat
	lfsr	FSR0, deci
	lfsr	FSR1, deci_lat
	movff	POSTINC0, POSTINC1
	movff	POSTINC0, POSTINC1
	movff	POSTINC0, POSTINC1
	movlw	0xB4
	movwf	lat_filler
	movf	lat, W
	subwf	lat_filler
	movlw	0xAA
	movwf	counter
send_loop_B
	call	send_lat
	decfsz	counter
	goto	send_loop_B
	BCF	INTCON3, INT1IF
	; RETFIE	FAST
	return
	
	end