OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 16K  /* Program ROM (Flash) */
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 32K  /* Data RAM */
    UART (rw) : ORIGIN = 0x10000000, LENGTH = 4K   /* Memory-mapped UART */
}

SECTIONS
{
    /* Code (text) section starts at 0x00000000 in ROM */
    . = ORIGIN(ROM);
    
    .text : {
        *(.text)        /* All .text sections (code) */
        *(.rodata)      /* Read-only data (if any) */
    } > ROM

    /* Data section starts at 0x80000000 in RAM */
    . = ORIGIN(RAM);

    .data : {
        *(.data)        /* All .data sections (initialized data) */
    } > RAM AT > ROM        /* Place .data in RAM, but load it in ROM */

    .bss : {
        *(.bss)             /* Place all .bss sections here (uninitialized variables) */
    } > RAM                 /* Place .bss in RAM */

    .uart : {
        KEEP(*(.uart))      /* Ensure the UART-related variables are kept */
    } > UART                /* Place UART control registers in memory-mapped region */
}