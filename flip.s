.equ TIMER, 0xFF202000	#Timer 1 Base Address
.equ PERIOD, 100000000 #1 second intervals
.equ	ADDR_GPIO_0, 0XFF200060


.section .text
.global _start
_start:
	movia r8, ADDR_GPIO_0
	movia r10, 0x07F557FF 
	stwio r10, 4(r8) #set direction for motors and sensors to output, sensor data registers to input
	
	movi r9, 0xFFFFFF0F
 	stwio r9, (r8) #turn on motor 2, set to forward
	
	movia r8, TIMER
	addi r9, r0, %lo(PERIOD)
	stwio r9,8(r8) #store lower 16 bits of timeout period
	
	addi r9,r0,%hi(PERIOD)
	stwio r9,12(r8) #store upper 16 bits of timeout period
	
	movui r9, 0b0111 
	stwio r9,4(r8)
	
	movi r9, 0b1 #timer is IRQ line 0
	wrctl ienable, r9
	
	movi r9, 0b1
	wrctl status, r9 #enable interrupts globally in the processor
	
	loop:
		br loop
	

.section .exceptions, "ax"

TIMER_ISR:
	rdctl et, ipending #check ipending to see what device caused the interrupt
	andi et, et, 0x1 #if bit 0 of ipending is high, we know the timer is requesting an interrupt
	beq et, r0, exit
	
	movia r8, ADDR_GPIO_0 
	ldwio r9, (r8)
	movia r10, 0x7FFFFF0F
 	beq r9, r10, turn_on_motor3
	br turn_on_motor2

	
	turn_on_motor3:
		movia et, ADDR_GPIO_0
		movi r10, 0xFFFFFFAF
		stwio r10, (et) #turn on motor3, reverse
		movia et, TIMER #acknowledge interrupt and reset timer
		stwio r0, (et)
		br exit
	
	turn_on_motor2:
		movia et, ADDR_GPIO_0
		movi r9, 0xFFFFFF0F
		stwio r9, (et) 
		movia et, TIMER #acknowledge interrupt and reset timer
		stwio r0, (et)
		br exit
	
	
	
	exit:
		subi ea, ea, 4
		eret #return so last instruction executes