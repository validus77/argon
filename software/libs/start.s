.section .text           # Code section
.globl _start            # Declare _start as a global symbol
.align 2                 # Ensure proper alignment

_start:
    # Initialize stack pointer to the top of RAM (assuming 4KB RAM)
    lui sp, 0x80001      # Load upper 20 bits of 0x80001000 into sp

    jal ra, main         # Jump and link to main (call main)
    j _halt              # Jump to halt

_halt:
    j _halt              # Infinite loop to stop the CPU
