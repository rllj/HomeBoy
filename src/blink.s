.section .text

.equ IO_BANK0_BASE,      0x40028000
.equ GPIO25_CTRL_OFFSET, 0x000000cc

.equ PADS_BANK0_BASE,     0x40038000      
.equ PADS_GPIO25_OFFSET,  0x00000068

.equ ATOMIC_SET, 0x2000
.equ ATOMIC_CLR, 0x3000

.equ SIO_FUNC, 0x05

.equ SIO_BASE, 0xd0000000

.equ GPIO_OUT_SET, 0x018
.equ GPIO_OUT_XOR, 0x028
.equ GPIO_OE_SET,  0x038

.equ TIMER0,   0x400b0000
.equ TIMELR,   0x0000000c
.equ TIMER0LR, 0x400b000c

.global _start
_start:
    la a0, _bss_start
    la a1, _bss_end
    call bss_zero

    # Configure FUNC
    li t0, IO_BANK0_BASE+GPIO25_CTRL_OFFSET+ATOMIC_CLR
    li t1, 0x1f # Clear 0b11111 (TODO: Not sure we actually need to this)
    sw t1, (t0)
    li t0, IO_BANK0_BASE+GPIO25_CTRL_OFFSET+ATOMIC_SET
    li t1, SIO_FUNC # Set func to SIO
    sw t1, (t0)

	li t0, SIO_BASE+GPIO_OE_SET
	li t1, (1<<25)
	sw t1, (t0)

    li t0, PADS_BANK0_BASE+PADS_GPIO25_OFFSET+ATOMIC_CLR
    li t1, (1<<8)|(1<<7)
    sw t1, (t0)

    li t0, SIO_BASE+GPIO_OUT_SET
    li t1, (1<<25)
    sw t1, (t0)

    li a0, 500000
    toggle_led:
    call wait_microseconds
    li t0, SIO_BASE+GPIO_OUT_XOR
    li t1, (1<<25)
    sw t1, (t0)
    j toggle_led


bss_zero_loop:
    sw x0, (a0)
    addi a0, a0, 4
bss_zero:
    bltu a0, a1, bss_zero_loop
    ret

# Perhaps implement with MTIMECMP + interrupts later?
wait_loop:
    lw t1, (t0)
    bltu t1, t2, wait_loop
    ret
wait_microseconds:
    li t0, TIMER0LR
    lw t1, (t0)
    add t2, a0, t1
    j wait_loop
