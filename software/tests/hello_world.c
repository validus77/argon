#include "../libs/uart.h"

int main() {
    // Send a test message via UART
    uart_putstr("Hello World from Argon (RISC V)\n");

    // Buffer to store received input
    char buffer[100];

    // Echo loop: read characters from UART and send them back
    while (1) {
        // Receive a string (until newline or max length)
        uart_getstr(buffer, sizeof(buffer));
        
        // Echo the received string back to the UART
        uart_putstr("Echo: ");
        uart_putstr(buffer);
        uart_putstr("\n");
    }

    return 0;
}