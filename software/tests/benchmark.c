#include "../libs/uart.h"

int fibonacci_benchmark() {
    int n = 20;  // Calculate 20th Fibonacci number
    int fib0 = 0, fib1 = 1, fibN = 0;

    for (int i = 2; i <= n; i++) {
        fibN = fib0 + fib1;
        fib0 = fib1;
        fib1 = fibN;
    }

    // Print 20th Fibonacci number
    return fibN;
}

int main() {
    uart_printf("20th Fib is: %d\n",fibonacci_benchmark());
}