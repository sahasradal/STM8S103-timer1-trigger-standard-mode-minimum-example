stm8/
	;PC7 = TI2 , PC6 = TI1 , need option byte AFRO 0 to be enabled
	#include "mapping.inc"
	#include "stm8s103f.inc"
	



	segment byte at 100 'ram1'
buffer1 ds.b
buffer2 ds.b
buffer3 ds.b
buffer4 ds.b
buffer5 ds.b


	
	
	segment 'rom'
main.l
	; initialize SP
	ldw X,#stack_end
	ldw SP,X

	#ifdef RAM0	
	; clear RAM0
ram0_start.b EQU $ram0_segment_start
ram0_end.b EQU $ram0_segment_end
	ldw X,#ram0_start
clear_ram0.l
	clr (X)
	incw X
	cpw X,#ram0_end	
	jrule clear_ram0
	#endif

	#ifdef RAM1
	; clear RAM1
ram1_start.w EQU $ram1_segment_start
ram1_end.w EQU $ram1_segment_end	
	ldw X,#ram1_start
clear_ram1.l
	clr (X)
	incw X
	cpw X,#ram1_end	
	jrule clear_ram1
	#endif

	; clear stack
stack_start.w EQU $stack_segment_start
stack_end.w EQU $stack_segment_end
	ldw X,#stack_start
clear_stack.l
	clr (X)
	incw X
	cpw X,#stack_end	
	jrule clear_stack
	
	
	
	;PC7 = TI2 , PC6 = TI1 , need option byte AFRO 0 to be enabled
	; when PC7 goes high the counter starts counting
	; tested and found OK with logic analyser. PD4 toggles at 121.9HZ 50% duty cycle
	
	

main_loop.l
	mov CLK_CKDIVR,#$00	; cpu clock no divisor = 16mhz
gpio_setup:	 
	bset PD_DDR,#4		; set PD4 as output
	bset PD_CR1,#4		; set PD4 as pushpull
	;bset PC_CR1,#7		; enable input and pull up, uncomment if falling edge needed
timer_setup:
	bres TIM1_CR1,#0	; disable timer
	bres TIM1_SR1,#6	; clear update interrupt flag
	mov TIM1_SMCR,#$66  ; TS = 110 and SMS = 110 , TI2 input , trigger standard mode
	;bset TIM1_CCER1,#5  ; TI2 polarity falling edge , uncomment if falling edge needed
	bset TIM1_IER,#0	; enable update interrupt
	bset TIM1_IER,#6	; enable trigger interrupt
	RIM
	
wait:
	jp wait

	
	
	
	interrupt TIM1_ISR
TIM1_ISR
	bres TIM1_SR1,#0 ; clear interrupt flag
	bres TIM1_SR1,#6 ; clear interrupt flag
	bcpl PD_ODR,#4	 ; each update interrupt at 4.09ms after counting 65535
	iret


	
	

	interrupt NonHandledInterrupt
NonHandledInterrupt.l
	iret

	segment 'vectit'
	dc.l {$82000000+main}									; reset
	dc.l {$82000000+NonHandledInterrupt}	; trap
	dc.l {$82000000+NonHandledInterrupt}	; irq0
	dc.l {$82000000+NonHandledInterrupt}	; irq1
	dc.l {$82000000+NonHandledInterrupt}	; irq2
	dc.l {$82000000+NonHandledInterrupt}	; irq3
	dc.l {$82000000+NonHandledInterrupt}	; irq4
	dc.l {$82000000+NonHandledInterrupt}	; irq5
	dc.l {$82000000+NonHandledInterrupt}	; irq6
	dc.l {$82000000+NonHandledInterrupt}	; irq7
	dc.l {$82000000+NonHandledInterrupt}	; irq8
	dc.l {$82000000+NonHandledInterrupt}	; irq9
	dc.l {$82000000+NonHandledInterrupt}	; irq10
	dc.l {$82000000+TIM1_ISR}	; irq11
	dc.l {$82000000+NonHandledInterrupt}	; irq12
	dc.l {$82000000+NonHandledInterrupt}	; irq13
	dc.l {$82000000+NonHandledInterrupt}	; irq14
	dc.l {$82000000+NonHandledInterrupt}	; irq15
	dc.l {$82000000+NonHandledInterrupt}	; irq16
	dc.l {$82000000+NonHandledInterrupt}	; irq17
	dc.l {$82000000+NonHandledInterrupt}	; irq18
	dc.l {$82000000+NonHandledInterrupt}	; irq19
	dc.l {$82000000+NonHandledInterrupt}	; irq20
	dc.l {$82000000+NonHandledInterrupt}	; irq21
	dc.l {$82000000+NonHandledInterrupt}	; irq22
	dc.l {$82000000+NonHandledInterrupt}	; irq23
	dc.l {$82000000+NonHandledInterrupt}	; irq24
	dc.l {$82000000+NonHandledInterrupt}	; irq25
	dc.l {$82000000+NonHandledInterrupt}	; irq26
	dc.l {$82000000+NonHandledInterrupt}	; irq27
	dc.l {$82000000+NonHandledInterrupt}	; irq28
	dc.l {$82000000+NonHandledInterrupt}	; irq29

	end
