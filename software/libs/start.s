    .section .text           # Code section
    .globl _start            # Declare _start as a global symbol
    .align 2                 # Ensure proper alignment

_start:
    call main                # Call the C main function
    j _halt                  # Jump to halt (infinite loop after main)

_halt:
    j _halt                  # Infinite loop to stop the CPU

