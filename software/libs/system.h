#pragma once

#define SYS_FREQ        50000000UL

//UART 
#define UART_BAUD       115200
#define UART_TDR_ADDR  0x10000000  // Transmit Data Register
#define UART_RDR_ADDR  0x10000004  // Receive Data Register
#define UART_SR_ADDR   0x10000008  // Status Register

// MEMEORY 
#define ROM_BASE = 0x00000000UL
#define RAM_BASE = 0x80000000UL



