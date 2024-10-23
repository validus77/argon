#include <stdarg.h>
#include "system.h"

volatile unsigned int* const uart_tdr = (unsigned int*) UART_TDR_ADDR;
volatile unsigned int* const uart_sr  = (unsigned int*) UART_SR_ADDR;
volatile unsigned int* const uart_rdr = (unsigned int*) UART_RDR_ADDR;

int uart_tx_ready() {
    return (*uart_sr & 0x2);  // Check if tx_ready is set (bit 1 of the Status Register)
}

// Function to send a single character via UART
void uart_putchar(char c) {
    // Wait until UART is ready to transmit
    while (!uart_tx_ready());

    // Write the character to the Transmit Data Register 
    *uart_tdr = c;
}

// Function to send a string via UART
void uart_putstr(const char* str) {
    while (*str) {
         if (*str == '\n') {
            uart_putchar('\r'); 
        }
        uart_putchar(*str++);
    }
}

void uart_putint(int num) {
    char buf[12];  // Buffer for int conversion (enough for 32-bit int)
    int i = 0;
    int is_negative = 0;

    // Handle negative numbers
    if (num < 0) {
        is_negative = 1;
        num = -num;
    }

    // Special case for zero
    if (num == 0) {
        uart_putchar('0');
        return;
    }

    // Manual modulus and division by 10
    while (num > 0) {
        int remainder = 0;
        int quotient = 0;
        int temp = num;

        // Calculate remainder
        while (temp >= 10) {
            temp -= 10;
            remainder++;
        }
        remainder = temp;

        // Calculate quotient
        temp = num;
        while (temp >= 10) {
            temp -= 10;
            quotient++;
        }
        num = quotient;

        // Store digit in buffer
        buf[i++] = remainder + '0';
    }

    // Add negative sign if needed
    if (is_negative) {
        buf[i++] = '-';
    }

    // Print the number in reverse order
    while (i--) {
        uart_putchar(buf[i]);
    }
}

void uart_printf(const char *format, ...) {
    va_list args;
    va_start(args, format);

    while (*format) {
        if (*format == '%') {
            format++;  // Move past '%'
            switch (*format) {
                case 'd': {  // Integer
                    int num = va_arg(args, int);
                    uart_putint(num);
                    break;
                }
                case 'c': {  // Character
                    char c = (char) va_arg(args, int);  // char is promoted to int
                    uart_putchar(c);
                    break;
                }
                case 's': {  // String
                    const char *str = va_arg(args, const char *);
                    uart_putstr(str);
                    break;
                }
                default: {
                    uart_putchar('%');  // Unknown format, just print '%'
                    uart_putchar(*format);
                    break;
                }
            }
        } else {
            // Regular character, print as is
            if (*format == '\n') {
                uart_putchar('\r');  // Add carriage return before line feed
            }
            uart_putchar(*format);
        }
        format++;
    }

    va_end(args);
}


// Function to check if UART has received data
int uart_rx_ready() {
    return (*uart_sr & 0x1);  // Check if rx_ready is set (bit 0 of the Status Register)
}

// Function to receive a single character via UART
char uart_getchar() {
    // Wait until data is available to be read
    while (!uart_rx_ready());

    // Read the character from the Receive Data Register
    return (char)(*uart_rdr);
}

int str_to_int(const char* str) {
    int result = 0;
    int sign = 1;
    int i = 0;
    
    // Handle negative numbers
    if (str[0] == '-') {
        sign = -1;
        i = 1;
    }

    // Convert each digit to an integer
    while (str[i] >= '0' && str[i] <= '9') {
        result = result * 10 + (str[i] - '0');
        i++;
    }

    return result * sign;
}

// Enhanced function to receive a string via UART with echo
void uart_getstr(char* buffer, int maxlen) {
    char c;
    int i = 0;
    
    // Loop until we hit a newline or the max length
    while (i < maxlen - 1) {
        c = uart_getchar();  // Read a character
        
        // Echo the character back to the user
        uart_putchar(c);
        
        // Break on newline or null terminator
        if (c == '\n' || c == '\0' || c == '\r') {
            break;
        }
        
        // Store the character in the buffer
        buffer[i++] = c;
    }
    buffer[i] = '\0';  // Null-terminate the string
}

void uart_scanf(const char* format, ...) {
    va_list args;
    va_start(args, format);

    char buffer[128];  // Temporary buffer for input
    uart_getstr(buffer, sizeof(buffer));

    const char *fmt_ptr = format;
    const char *buf_ptr = buffer;
    
    while (*fmt_ptr) {
        if (*fmt_ptr == '%') {
            fmt_ptr++;
            if (*fmt_ptr == 'd') {
                // Read an integer
                int *int_ptr = va_arg(args, int*);
                *int_ptr = str_to_int(buf_ptr);

                // Move buffer pointer past the integer
                while (*buf_ptr >= '0' && *buf_ptr <= '9') {
                    buf_ptr++;
                }
            } else if (*fmt_ptr == 's') {
                // Read a string
                char *str_ptr = va_arg(args, char*);
                int i = 0;

                // Copy the string from the buffer
                while (*buf_ptr != ' ' && *buf_ptr != '\0' && *buf_ptr != '\n' && *buf_ptr != '\r') {
                    str_ptr[i++] = *buf_ptr++;
                }
                str_ptr[i] = '\0';
            }
        }
        fmt_ptr++;
    }

    va_end(args);
}

