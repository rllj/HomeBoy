.section .picobin_block, "a"

.equ PICOBIN_BLOCK_MARKER_START, 0xffffded3
.equ PICOBIN_BLOCK_MARKER_END,   0xab123579

.equ STACK_POINTER_TOP, 0x20082000

.global _picobin_start
_picobin_start:

# https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf#page=422
.word PICOBIN_BLOCK_MARKER_START
# IMAGE_DEF
.byte 0x42
.byte 0x01
.hword 0x1101

# ENTRY_POINT
.byte 0x44
.byte 0x03
.hword 0x0000
.word _start
.word STACK_POINTER_TOP

# LAST
.byte 0xff
.hword 0x0004 # The length of the block
.byte 0x00

.word 0x00000000

.word PICOBIN_BLOCK_MARKER_END

j _start
