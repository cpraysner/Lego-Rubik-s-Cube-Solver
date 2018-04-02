start:
.equ PS2, 0xFF200100

/* interrupt enable */

# CPU interrupt enable, r8
movi r8, 0x80
wrctl ctl3, r8

# PS2 interrupt enable, used r9
movi r17, 0b1
movia r9, PS2
stwio r18, 4(r9)

# IRQ line interrupt enable, used r10
movi r10, 0x1
wrctl ctl0, r10


INTERRUPT_HANDLER:

# exit condition check, used et
rdctl ctl4, et
andi et, 0x80
bne et, r0, EXIT_INTERRUPT_HANDLER

/* reading keyboard input and call functions according to different key*/

polling:
# polling loop
movia r18, PS2
ldwio r2, 0(r18)
andi r2, r2, 0x8000
beq r2, r0, polling

# reading in char
ldwio et, 0(r19)
andi et, et, 0xff

# compare char and call functions, planning to use movi and beq?
# maybe use bne to check break
# colour code to be matched
# blue(b), green(g), yellow(y), white(w), orange(o), red(r)
movi r20, 0x32 # blue, b
beq et, r20, blue

movi r20, 0x34 # green, g
beq et, r20, green

movi r20, 0x35 # yellow, y
beq et, r20, yellow

movi r20, 0x1D # white, w
beq et, r20, white

movi r20, 0x44 # orange, o
beq et, r20, orange

movi r20, 0x2D # red, r
beq et, r20, red


# check keyboard break code
movi r20, 0xF0
bne et, r20, poll


EXIT_INTERRUPT_HANDLER:
subi ea, ea, 4
eret
