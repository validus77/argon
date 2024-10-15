ENTRY(_start)

SECTIONS
{
    /* Code (text) section starts at 0x00000000 in ROM */
    . = 0x00000000;
    
    .text : {
        *(.text)        /* All .text sections (code) */
        *(.rodata)      /* Read-only data (if any) */
    }

    /* Data section starts at 0x80000000 in RAM */
    . = 0x80000000;

    .data : {
        *(.data)        /* All .data sections (initialized data) */
    }

    .bss : {
        *(.bss)         /* All .bss sections (zero-initialized data) */
    }
}