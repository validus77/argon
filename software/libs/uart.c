#define TDR_ADDR  0x10000000  // Transmit Data Register
#define RDR_ADDR  0x10000004  // Receive Data Register
#define SR_ADDR   0x10000008  // Status Register

volatile unsigned int* const uart_tdr = (unsigned int*) TDR_ADDR;
volatile unsigned int* const uart_sr  = (unsigned int*) SR_ADDR;
volatile unsigned int* const uart_rdr = (unsigned int*) RDR_ADDR;

// Function to check if UART is ready to transmit
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
        uart_putchar(*str++);
    }
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

// Function to receive a string via UART (reads until a newline or null terminator)
void uart_getstr(char* buffer, int maxlen) {
    char c;
    int i = 0;
    
    // Loop until we hit a newline or the max length
    while (i < maxlen - 1) {
        c = uart_getchar();  // Read a character
        if (c == '\n' || c == '\0') {
            break;
        }
        buffer[i++] = c;  // Store the character in the buffer
    }
    buffer[i] = '\0';  // Null-terminate the string
}

