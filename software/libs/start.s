    .section .text           # Code section
    .globl _start            # Declare _start as a global symbol
    .align 2                 # Ensure proper alignment


_start:
    jal ra, main             # Jump and link to main (call main)
    j _halt                  # Jump to halt

_halt:
    j _halt                  # Infinite loop to stop the CPU

