.equ 	addr_move_sequence, 0x1080
.equ	addr_jp1, 0xff200060
.equ addr_jp1_edge, 0xff20006c
.equ addr_jp1_irq, 0x0800
.equ timer, 0xff202000	#Timer 1 Base Address
.equ flip_period, 100000000 #1 second intervals
.equ period_sensor, 12500000 
.equ stop_period, 3120000 
.equ final_period, 9000000

.section .exceptions, "ax"

rdctl et, ipending #check ipending to see what device caused the interrupt
andi et, et, 0x1 #if bit 0 of ipending is high, we know the timer is requesting an interrupt
movi r8, 1
beq et, r8, timer_check
rdctl et, ctl4                    # check the interrupt pending register (ctl4) 
mov r12, et
movia r2, addr_jp1_irq    
and	r2, r2, r12                  # check if the pending interrupt is from GPIO JP1 
beq   r2, r0, exit_handler    
movia r2, addr_jp1_edge           # check edge capture register from GPIO JP1
ldwio et, 0(r2)
andhi r2, et, 0x800             # mask bit 27 (sensor 0)  
beq   r2, r0, exit_handler        # exit if sensor 2 did not interrupt 
br sensor0_interrupted

timer_check:
	movi r8, 1
	beq r18, r8, flip_isr #different devices using same timer, need to identify
	movi r8, 2
	beq r19, r8, down_isr
	br exit_handler 

flip_isr:
	addi r20, r20, 1 #flip counter
	movia r8, addr_jp1 
	ldwio r9, (r8)
	movia r10, 0xFFFFFFC3
 	beq r9, r10, motors_reverse
	movi r10, 2
	beq r20, r10, flip_isr_done
	br motors_forward
	
motors_reverse:
	movia et, addr_jp1
	movi r10, 0xFFFFFFEB
	stwio r10, (et) #turn on motors 1 & 2, reverse
	movia et, timer #acknowledge interrupt and reset timer
	stwio r0, (et)
	br exit_handler

motors_forward:
	movia et, addr_jp1
	movi r9, 0xFFFFFFC3 #turn on motors 1 & 2, forward
	stwio r9, (et) 
	movia et, timer #acknowledge interrupt and reset timer
	stwio r0, (et)
	br exit_handler
		
flip_isr_done:
	movia et, timer #acknowledge interrupt and reset timer
	stwio r0, (et)
	br exit_handler

down_isr:
	rdctl et, ctl4                    # check the interrupt pending register (ctl4) 
	mov r12, et
	movi r8, 1
	andi et, et, 0x1 #if bit 0 of ipending is high, we know the timer is requesting an interrupt
	beq et, r8, timer_isr
	movia r2, addr_jp1_irq    
	and	r2, r2, r12                  # check if the pending interrupt is from GPIO JP1 
	beq   r2, r0, exit_handler    
	movia r2, addr_jp1_edge           # check edge capture register from GPIO JP1
	ldwio et, 0(r2)
	andhi r2, et, 0x800             # mask bit 27 (sensor 0)  
	beq   r2, r0, exit_handler        # exit if sensor 2 did not interrupt 
	br sensor0_interrupted
 
timer_isr:
	subi r11, r11, 1
	movia et, timer #acknowledge interrupt and reset timer
	stwio r0, (et)
	br exit_handler
 
sensor0_interrupted:
	movia r2, addr_jp1_edge
	movia et, 0xffffffff
	stwio et, (r2)
	movia r8, addr_jp1
	movia r9, 0xfffffffc
	stwio r9, (r8) 
	addi r4, r0, 1
	call delay #to make sure the plate is aligned, motor0 must go in the opposite direction briefly
	movia r8, addr_jp1
	movia r9, 0xffffffff
	stwio r9, (r8) #turn off motor 0
	addi r4, r0, 1
	call final_move
	
	movia r8, addr_jp1
	movia r9, 0xfffffffe
	stwio r9, (r8) 
	addi r4, r0, 1
	
	call final_move
	movia r8, addr_jp1
	movia r9, 0xfffffffc
	stwio r9, (r8) 
	
	addi r4, r0, 1
	call final_move
	
	movia r8, addr_jp1
	movia r9, 0xfffffffe
	stwio r9, (r8) 
	addi r4, r0, 1
	call delay
	
	movia r8, addr_jp1
	movia r9, 0xfffffffe
	stwio r9, (r8) #turn off motor 0
	movia r9, 0xffffffff
	stwio r9, (r8) #turn off motor 0
	br done_turn_bottom
	

exit_handler:
	subi ea, ea, 4
	eret #return so last instruction executes




.section .text
.global _start
_start:

br back

parsing:
	
	movia r4, addr_move_sequence #r4 contains start address of sequence of moves
	
	addi r4, r4, 0x4
	
	#first step is parsing the string of moves
	movi r8, 'U' #upper
	movi r9, 'F' #front
	movi r10, 'B' #back
	movi r11, 'D' #down
	movi r12, 'L' #left
	movi r13, 'R' #right
	movi r14, 0x27 #apostrophe ("inverted")
	movi r15, 2 #for double turns
	movi r16, 0x20 #space
	
	addi r4, r4, 1
	
	ldb r17, 0(r4)
	beq r17, r8, upper_string
	beq r17, r9, front_string
	beq r17, r10, back_string
	beq r17, r11, down_string
	beq r17, r12, left_string
	beq r17, r13, right_string
	beq r17, r0, cube_solved
	
upper_string:
	addi r4, r4, 1
	ldb r17, 0(r4)
	beq r17, r16, upper
	beq r17, r14, upper_inverted
	beq r17, r15, upper_double

front_string:
	addi r4, r4, 1
	ldb r17, 0(r4)
	beq r17, r16, front
	beq r17, r14, front_inverted
	beq r17, r15, front_double

back_string:
	addi r4, r4, 1
	ldb r17, 0(r4)
	beq r17, r16, back
	beq r17, r14, back_inverted
	beq r17, r15, back_double

down_string:
	addi r4, r4, 1
	ldb r17, 0(r4)
	beq r17, r16, down
	beq r17, r14, down_inverted
	beq r17, r15, down_double

left_string:
	addi r4, r4, 1
	ldb r17, 0(r4)
	beq r17, r16, left
	beq r17, r14, left_inverted
	beq r17, r15, left_double

right_string:
	addi r4, r4, 1
	ldb r17, 0(r4)
	beq r17, r16, right
	beq r17, r14, right_inverted
	beq r17, r15, right_double
	
# ###################################################################

upper:
	call flip
	call flip
	# movia r8, addr_jp1
	# movi r9, 0xffffffeb
 	# stwio r9, (r8)
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	br parsing

upper_inverted:
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	br parsing

upper_double:
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	br parsing

front:
	movia r8, addr_jp1
	movi r9, 0xffffffc3
 	stwio r9, (r8)
	call flip
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	br parsing
	
front_inverted:
	call flip
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	br parsing
	
front_double:
	call flip
	call flip
	call flip
	# movia r8, addr_jp1
	# movi r9, 0xffffffc3
 	# stwio r9, (r8)
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	# movia r8, addr_jp1
	# movi r9, 0xffffffc3
 	# stwio r9, (r8)
	br parsing

back:
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	call flip
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	# call flip
	# subi sp, sp, 4  
	# stw ra,0(sp)
	# call turn_bottom
	# call flip
	# subi sp, sp, 4  
	# stw ra,0(sp)
	# call turn_bottom
	# call flip
	# subi sp, sp, 4  
	# stw ra,0(sp)
	# call turn_bottom
	# call flip
	# subi sp, sp, 4  
	# stw ra,0(sp)
	# call turn_bottom
	# call flip
	# movia r8, addr_jp1
	# movi r9, 0xffffffeb
 	# stwio r9, (r8)
	
	
	# call flip
	# call flip
	# movia r8, addr_jp1
	# movi r9, 0xffffffeb
 	# stwio r9, (r8)
	# subi sp, sp, 4  
	# stw ra,0(sp)
	# call turn_bottom
	# call flip
	# #call flip
	# movia r8, addr_jp1
	# movi r9, 0xffffffeb
 	# stwio r9, (r8)
	
	# call flip
	# subi sp, sp, 4  
	# stw ra,0(sp)
	# call turn_bottom
	# call flip
	
	call flip
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	
	
	br back
	
back_inverted:
	call flip
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	br parsing

back_double:
	call flip
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	call flip
	movia r8, addr_jp1
	movi r9, 0xffffffeb
 	stwio r9, (r8)
	br parsing

down:
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	br parsing

down_inverted:
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	br parsing

down_double:
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	br parsing
	
left:
	call raise_arm
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call lower_arm
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	call flip
	call raise_arm
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call lower_arm
	br parsing
	

left_inverted:
	call raise_arm
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call lower_arm
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call flip
	call flip
	call flip
	call raise_arm
	subi sp, sp, 4  
	stw ra,0(sp)
	call turn_bottom
	call lower_arm
	br parsing

left_double:

right:

right_inverted:

right_double:

#######################################################################################

flip:
	movi r18, 1 #identifier for flip_isr
	movia r8, addr_jp1
	movia r10, 0x07F557FF 
	stwio r10, 4(r8) #set direction for motors and sensors to output, sensor data registers to input
	
	movi r9, 0xffffffeb
 	stwio r9, (r8) #turn on motors 1 & 2, set to reverse
	
	movia r8, timer
	addi r9, r0, %lo(flip_period)
	stwio r9,8(r8) #store lower 16 bits of timeout period
	
	addi r9,r0,%hi(flip_period)
	stwio r9,12(r8) #store upper 16 bits of timeout period
	
	movui r9, 0b0111 
	stwio r9,4(r8)
	
	movi r9, 0b1 #timer is IRQ line 0
	wrctl ienable, r9
	
	movi r9, 0b1
	wrctl status, r9 #enable interrupts globally in the processor
	
	movi r20, 0 #counter for flips
	
	
wait_for_flip_timer:
	movi r10, 2
	beq r20, r10, flip_done
	br wait_for_flip_timer
	
flip_done:
	movia r8, addr_jp1
	movi r9, 0xffffffff
 	stwio r9, (r8) 
	movi r9, 0b0 #timer is IRQ line 0
	wrctl ienable, r9 #disable interrupts from the timer, since flip move is done
	movi r18, 0
	ret #return
	
#############################################################################
turn_bottom:
	movia r8, addr_jp1
	movia r9, 0x07f557ff #set direction for motors and sensors to output, sensor data registers to input
	stwio r9,4(r8)

	movia r9, 0xfffffffe
	stwio r9, (r8) #turn on motors 0, reverse

	movi r11, 1

	movia r8, timer
	addi r9, r0, %lo(period_sensor)
	stwio r9,8(r8) #store lower 16 bits of timeout period

	addi r9,r0,%hi(period_sensor)
	stwio r9,12(r8) #store upper 16 bits of timeout period

	movui r9, 0b0101 
	stwio r9,4(r8)

	movi r9, 0b1 #timer is IRQ line 0
	wrctl ienable, r9

	movia r9, 1
	wrctl ctl0, r9
	
	movi r19, 2 #identifier for the down_isr
	
timer_wait: #wait for timer to finish before setting up sensors
	beq r11, r0, sensors 
	br timer_wait

	
sensors:
	#load sensor0 threshold value 8 and enable sensor0

	movia r8, addr_jp1
	movia r9, 0x07f557ff
	stwio r9,4(r8)
	
	movia r9, 0xfc3ffbfe
	stwio r9, 0(r8)

	#disable threshold register and enable state mode

	movia r9, 0xffdffffe
	stwio r9, 0(r8)

	movia r2, addr_jp1_edge
	movia r9, 0xffffffff
	stwio r9, (r2)

	#enable interrupts

	movia r12, 0x08000000
	stwio r12, 8(r8)

	movia r8, addr_jp1_irq
	wrctl ctl3, r8

	movia r8, 1
	wrctl ctl0, r8

wait_for_sensor:
	br wait_for_sensor

delay:
	movia r8, timer
	stwio r9, 4(r8)

	addi r9,r0, %lo(stop_period)
	stwio r9, 8(r8)
	addi r9,r0, %hi(stop_period)
	stwio r9, 12(r8)
	addi r9, r0, 0x4 
	stwio r9, 4(r8)

delay1:
	ldwio r9,0(r8)
	andi r9,r9,0x1
	beq r9,r0,delay1
	movi r9,0x0
	stwio r9,0(r8)
	subi r4, r4, 1
	bne r4,r0,delay1
	movi r9,8
	stwio r9, 4(r8)
	ret

final_move:
	movia r8, timer
	stwio r9, 4(r8)

	addi r9,r0, %lo(final_period)
	stwio r9, 8(r8)
	addi r9,r0, %hi(final_period)
	stwio r9, 12(r8)
	addi r9, r0, 0x4 
	stwio r9, 4(r8)

final_move1:
	ldwio r9,0(r8)
	andi r9,r9,0x1
	beq r9,r0,delay1
	movi r9,0x0
	stwio r9,0(r8)
	subi r4, r4, 1
	bne r4,r0,delay1
	movi r9,8
	stwio r9, 4(r8)
	

done_turn_bottom:
	movi r9, 0b0 #timer is IRQ line 0
	wrctl ienable, r9 #disable interrupts from the timer
	#disable sensor interrupts
	movia r8, addr_jp1
	movia r12, 0x00000000
	stwio r12, 8(r8)

	#movia r8, addr_jp1_irq
	#wrctl ctl3, r8
	movi r19, 0
	movia r8, 0
	wrctl ctl0, r8
	ldw  ra, 0(sp)   # pop return address from the stack
	addi sp, sp, 4
	addi ra, ra, 12
	ret #STORE RETURN ADDRESS ON THE STACK!!

raise_arm:

	movia r8, addr_jp1
	movia r9, 0x07F557FF 
	stwio r9, 4(r8) #set direction for motors and sensors to output, sensor data registers to input
	
	movi r10, 0xfffffc3f
 	stwio r10, (r8) #turn on motors 3 & 4, set to forward
	
	ret

lower_arm:
	
	movia r8, addr_jp1
	movia r9, 0x07F557FF 
	stwio r9, 4(r8) #set direction for motors and sensors to output, sensor data registers to input
	
	movi r10, 0xffffffff
 	stwio r10, (r8) #turn off all motors to lower arm

	ret


#################################################################################
cube_solved:
	br cube_solved
	



	
	