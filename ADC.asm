#include p18f87k22.inc

    global  ADC_Setup, ADC_Read
    global  multiply_first_L, multiply_first_H
    global  temp_0, temp_1, ans
    
temp_0	res 4
temp_1	res 4
count	res 1
ans	res 2
	
ADC    code
    
ADC_Setup
    bsf	    TRISA,RA0	    ; use pin A0(==AN0) for input
    bsf	    ANCON0,ANSEL0   ; set A0 to analog
    movlw   0x01	    ; select AN0 for measurement
    movwf   ADCON0	    ; and turn ADC on
    movlw   0x30	    ; Select 4.096V positive reference
    movwf   ADCON1	    ; 0V for -ve reference and -ve input
    movlw   0xF6	    ; Right justified output
    movwf   ADCON2	    ; Fosc/64 clock and acquisition times
    lfsr    FSR2, ans
    return

ADC_Read
    bsf	    ADCON0,GO	    ; Start conversion
adc_loop
    btfsc   ADCON0,GO	    ; check to see if finished
    bra	    adc_loop
    return

multiply_first_H
    lfsr    FSR0, temp_0
    POSTINC0
    movf    ADRESH, W
    mullw   0x8A	    ; Multiplies W register to 
    movf    PRODL, W	    ; Moves lower result to W
    addwfc  POSTINC0	    ; Adds lower result to temp_0
    movf    PRODH, W	    ; Moves upper result to W
    addwfc  FSR0	    ; Adds upper result to temp_0
    
    movf    ADRESH, W
    mullw   0x41
    movf    PRODL, W	    ; Moves lower result to W
    addwfc  POSTINC0	    ; Adds lower result to temp_0
    movf    PRODH, W	    ; Moves upper result to W
    addwfc  FSR0	    ; Adds upper result to temp_0
    return

multiply_first_L
    lfsr    FSR0, temp_0
    movf    ADRESL, W
    mullw   0x8A	    ; Multiplies W register to 
    movf    PRODL, W	    ; Moves lower result to W
    addwfc  POSTINC0	    ; Adds lower result to temp_0
    movf    PRODH, W	    ; Moves upper result to W
    addwfc  FSR0	    ; Adds upper result to temp_0
    
    movf    ADRESL, W
    mullw   0x41
    movf    PRODL, W	    ; Moves lower result to W
    addwfc  POSTINC0	    ; Adds lower result to temp_0
    movf    PRODH, W	    ; Moves upper result to W
    addwfc  FSR0	    ; Adds upper result to temp_0	
    return
    
multiply_ten
    lfsr    FSR0, temp_0    ; Loads temp0 to file select 0
    lfsr    FSR1, temp_1    ; Loads temp1 to file select 1
    clrf    temp_1	    ; Clears temp1
    movlw   0x03	    ; Sets up counter
    movwf   count	    
multiply_loop
    movf    FSR0, W	    ; Loads result from fsr0
    mullw   0x0A	    ; Multiplies result by 10
    movf    PRODL, W	    ; Moves lower result to W
    addwfc  POSTINC1	    ; Adds lower result to temp1
    movf    PRODH, W	    ; Moves upper result to W
    addwfc  FSR1	    ; Adds upper result to temp1
    DECFSZ  count	    ; Ticks counter and determine loop
    bra	    multiply_loop   ; Loops
    movlw   0x04	    ; Sets up loop for moving from temp1 to temp0
    movwf   count
    lfsr    FSR0, temp_0    ; Loads temp0 to file select 0
    lfsr    FSR1, temp_1    ; Loads temp1 to file select 1
move_loop
    movff   POSTINC1, POSTINC0	; Moves results from temp1 to temp0
    DECFSZ  count		; Ticks counter and determine loop
    bra	    move_loop
    return
    
save_upper
    movf    FSR0, W	    ; Moves result to working register
    RLNCF   W, 4, 0	    ; Rotates result 4 bits to the left (WREG)
    clrf    FSR0	    ; Clears result (temp register)
    addwf   FSR2	    ; Adds result to ans
    return
     
save_lower
    movf    FSR0, W	    ; Moves result to working register
    clrf    FSR0
    addwf   FSR2	    ; Adds result to ans
    return
    
    
    
    
    

    end