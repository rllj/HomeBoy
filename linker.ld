MEMORY {
    FLASH (rx) : ORIGIN = 0x10000000, LENGTH = 2M
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 520K
}
/* TODO: Add stack size to avoid underflow */

ENTRY(_picobin_start)

SECTIONS {
    .text : { 
        KEEP(*(.picobin_block));
        . = ALIGN(4);
        *(.text);
    } > FLASH

    .data : {
        . = ALIGN(4);
        *(.data)
        . = ALIGN(4);
    } > RAM AT> FLASH

    .bss (NOLOAD) : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss)
        . = ALIGN(4);
        _bss_end = .;
    } > RAM
}
