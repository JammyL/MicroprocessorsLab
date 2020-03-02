	 #include "p18f87k22.inc"
	 
	 global	    interrupt_setup
	 
acs0	udata_acs   ; reserve data space in access ram
	 
	    	
   
interrupt code 0x700


interrupt_setup
;	bsf	INTCON,TMR0IE	; Enable timer0 interrupt
;	bsf	INTCON,GIE	; Enable all interrupts
	return
	
	end