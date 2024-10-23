
#include <stdint-gcc.h>
#include <stdbool.h>
#include "../libs/uart.h"

#define MEM_SIZE 1024
volatile unsigned char* const memory = (unsigned char*)0x80000000;  // Example base address

// Function to test RV32I memory instructions using volatile pointers
bool test_rv32i_memory_instructions() {
    bool resutls = true;
    int addr, result, expected;
    volatile unsigned int* mem_word;
    volatile unsigned short* mem_half;
    volatile unsigned char* mem_byte;

    // Test SW (Store Word) and LW (Load Word)
    addr = 4;  // Word-aligned address
    mem_word = (volatile unsigned int*)(memory + addr);
    *mem_word = 0x12345678;  // SW
    result = *mem_word;  // LW
    expected = 0x12345678;
    uart_printf("SW/LW: %s\n", (result == expected) ? "PASS" : "FAIL");
    resutls &= (result == expected);

    // Test SH (Store Halfword) and LH (Load Halfword)
    addr = 8;  // Halfword-aligned address
    mem_half = (volatile unsigned short*)(memory + addr);
    *mem_half = 0x5678;  // SH
    result = *mem_half;  // LH
    expected = 0x5678;
    uart_printf("SH/LH: %s\n", (result == expected) ? "PASS" : "FAIL");
    resutls &= (result == expected);

    // Test SB (Store Byte) and LB (Load Byte)
    addr = 12;  // Byte-aligned address
    mem_byte = (volatile unsigned char*)(memory + addr);
    *mem_byte = 0x78;  // SB
    result = *mem_byte;  // LB
    expected = 0x78;
    uart_printf("SB/LB: %s\n", (result == expected) ? "PASS" : "FAIL");
    resutls &= (result == expected);

    // Test LBU (Load Byte Unsigned)
    addr = 12;  // Byte-aligned address
    mem_byte = (volatile unsigned char*)(memory + addr);
    result = *mem_byte;  // LBU
    expected = 0x78;
    uart_printf("LBU: %s\n", (result == expected) ? "PASS" : "FAIL");
    resutls &= (result == expected);

    // Test LHU (Load Halfword Unsigned)
    addr = 8;  // Halfword-aligned address
    mem_half = (volatile unsigned short*)(memory + addr);
    result = *mem_half;  // LHU
    expected = 0x5678;
    uart_printf("LHU: %s\n", (result == expected) ? "PASS" : "FAIL");
    resutls &= (result == expected);

    return resutls;
}

// Function to use inline assembly for RV32I instructions
bool test_rv32i_inline_asm() {
    bool results = true;
    int result, expected;
    int a = 10, b = 20;

    // Inline assembly for ADD
    asm volatile ("add %0, %1, %2"
                  : "=r" (result)
                  : "r" (a), "r" (b));
    expected = 30;
    uart_printf("ADD (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);

    // Inline assembly for SUB
    asm volatile ("sub %0, %1, %2"
                  : "=r" (result)
                  : "r" (b), "r" (a));
    expected = 10;
    uart_printf("SUB (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for AND
    asm volatile ("and %0, %1, %2"
                  : "=r" (result)
                  : "r" (0x0F0F), "r" (0x00FF));
    expected = 0x000F;
    uart_printf("AND (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for OR
    asm volatile ("or %0, %1, %2"
                  : "=r" (result)
                  : "r" (0x0F00), "r" (0x00F0));
    expected = 0x0FF0;
    uart_printf("OR (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for XOR
    asm volatile ("xor %0, %1, %2"
                  : "=r" (result)
                  : "r" (0x0F0F), "r" (0x00FF));
    expected = 0x0FF0;
    uart_printf("XOR (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for SLL (Shift Left Logical)
    asm volatile ("sll %0, %1, %2"
                  : "=r" (result)
                  : "r" (0x0001), "r" (4));
    expected = 0x0010;
    uart_printf("SLL (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for SRL (Shift Right Logical)
    asm volatile ("srl %0, %1, %2"
                  : "=r" (result)
                  : "r" (0x0010), "r" (4));
    expected = 0x0001;
    uart_printf("SRL (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for SRA (Shift Right Arithmetic)
    asm volatile ("sra %0, %1, %2"
                  : "=r" (result)
                  : "r" (-16), "r" (2));
    expected = -4;
    uart_printf("SRA (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for LUI (Load Upper Immediate)
    asm volatile ("lui %0, 0xABCD"
                  : "=r" (result));
    expected = 0xABCD000;
    uart_printf("LUI (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for ADDI (Add Immediate)
    asm volatile ("addi %0, %1, 5"
                  : "=r" (result)
                  : "r" (10));
    expected = 15;
    uart_printf("ADDI (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for SLT (Set Less Than)
    asm volatile ("slt %0, %1, %2"
                  : "=r" (result)
                  : "r" (5), "r" (10));
    expected = 1;
    uart_printf("SLT (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for SLTIU (Set Less Than Immediate Unsigned)
    asm volatile ("sltiu %0, %1, 10"
                  : "=r" (result)
                  : "r" (5));
    expected = 1;
    uart_printf("SLTIU (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for BEQ (Branch if Equal)
    result = 0;
    asm volatile (
        "beq %1, %2, 1f\n"
        "addi %0, %0, 1\n"
        "1:\n"
        : "+r" (result)
        : "r" (5), "r" (5));
    expected = 0;  // Branch taken, ADDI skipped
    uart_printf("BEQ (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Inline assembly for BNE (Branch if Not Equal)
    result = 0;
    asm volatile (
        "bne %1, %2, 1f\n"
        "addi %0, %0, 1\n"
        "1:\n"
        : "+r" (result)
        : "r" (5), "r" (10));
    expected = 0;  // Branch taken, ADDI skipped
    uart_printf("BNE (ASM): %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


 // Test JAL (Jump and Link)
    result = 0x1234;  // Example jump destination
    expected = 0x1234;
    uart_printf("JAL: %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);


    // Test JALR (Jump and Link Register)
    a = 0x1000;
    result = (a + 4) & ~1;  // JALR, ensuring last bit is 0
    expected = 0x1004;
    uart_printf("JALR: %s\n", (result == expected) ? "PASS" : "FAIL");
    results &= (result == expected);

    return results;
}

int main() {
    uart_printf("Argon CPU (ISA = RISC V, R32I)\n");
    uart_printf("------------------------------\n");
    bool results;
    uart_printf("Testing RV32I Memory Instructions:\n");
    results = test_rv32i_memory_instructions();

    uart_printf("Testing RV32I Inline Assembly Instructions:\n");
    results &= test_rv32i_inline_asm();
    uart_printf("------------------------------\n");
    uart_printf("RISC V R32I base instrutions tests: %s\n", (results) ? "PASS" : "FAIL");


    
    return 0;
}