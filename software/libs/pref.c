#include "pref.h"

uint64_t rdcycle() {
    uint32_t cycle_lo, cycle_hi, cycle_hi2;
    
    // Inline assembly block
    asm volatile (
        "0: \n"
        "   rdcycleh %[hi] \n"    // Read high part of cycle counter
        "   rdcycle %[lo] \n"     // Read low part of cycle counter
        "   rdcycleh %[hi2] \n"   // Read high part again
        "   bne %[hi], %[hi2], 0b \n" // If high parts are different, try again
        : [lo] "=r" (cycle_lo), [hi] "=r" (cycle_hi), [hi2] "=r" (cycle_hi2)
    );

    return ((uint64_t)cycle_hi << 32) | cycle_lo; // Combine hi and lo
}

uint64_t rdinstret() {
    uint32_t instret_lo, instret_hi, instret_hi2;
    
    // Inline assembly block
    asm volatile (
        "0: \n"
        "   rdinstreth %[hi] \n"    // Read high part of instret counter
        "   rdinstret %[lo] \n"     // Read low part of instret counter
        "   rdinstreth %[hi2] \n"   // Read high part again
        "   bne %[hi], %[hi2], 0b \n" // If high parts are different, try again
        : [lo] "=r" (instret_lo), [hi] "=r" (instret_hi), [hi2] "=r" (instret_hi2)
    );

    return ((uint64_t)instret_hi << 32) | instret_lo; // Combine hi and lo
}
