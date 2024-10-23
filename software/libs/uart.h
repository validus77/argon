#pragma once

void uart_printf(const char *format, ...);
void uart_scanf(const char* format, ...);

void uart_putchar(char c);
void uart_putstr(const char* str);
char uart_getchar();
void uart_getstr(char* buffer, int maxlen);