OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  ROM (rx) : ORIGIN = 0x00000000, LENGTH = 16k
  RAM (rw) : ORIGIN = 0x80000000, LENGTH = 32k
}

ROM_START_ADDRESS   = 0x00000000;        /* Must be the same as the MEMORY region ROM ORIGIN. */
ROM_SIZE            = 4k;                /* Must match the MEMORY region ROM LENGTH. */

RAM_START_ADDRESS   = 0x80000000;        /* Must be the same as the MEMORY region RAM ORIGIN. */
RAM_SIZE            = 4k;                /* Must match the MEMORY region RAM LENGTH. */

STACK_SIZE          = 4k;                /* Needs to be calculated for your application. */
HEAP_SIZE           = 0;                 /* Needs to be calculated for your application. */

SECTIONS
{
  .text : ALIGN(0x10) 
  { 
    *(.text*)
    PROVIDE(__global_pointer$ = .); 
  } > ROM

  .rodata : ALIGN(0x10)
  {
    *(.rodata*)
  } > ROM

  .data : ALIGN(0x10)
  {
    *(.data*)
  } > RAM AT > ROM

  .bss : ALIGN(0x10)
  { 
    *(.bss*)
    *(COMMON)
    PROVIDE(__stack_top$ = . + LENGTH(RAM) - STACK_SIZE);
  } > RAM

  /* Initialize stack pointer to top of RAM */
  . = ORIGIN(RAM) + LENGTH(RAM) - STACK_SIZE;
  __stack_top$ = .;
}