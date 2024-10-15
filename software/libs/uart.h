#ifndef UART_H
#define UART_H

void uart_putchar(char c);
void uart_putstr(const char* str);
int uart_tx_ready();
int uart_rx_ready();
char uart_getchar();
void uart_getstr(char* buffer, int maxlen);

#endif // UART_H