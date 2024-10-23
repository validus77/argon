#include "../libs/uart.h"

#define MAX_LIMIT 1000  // Maximum limit for prime finding

// Prime number array
int is_prime[MAX_LIMIT + 1];

// Sieve of Eratosthenes to find primes up to 'limit'
void find_primes(int limit) {
    // Initialize all numbers as prime
    for (int i = 2; i <= limit; i++) {
        is_prime[i] = 1;
    }

    // Sieve of Eratosthenes
    for (int i = 2; i * i <= limit; i++) {
        if (is_prime[i]) {
            for (int j = i * i; j <= limit; j += i) {
                is_prime[j] = 0;  // Mark as not prime
            }
        }
    }
}

// Print prime numbers up to 'limit'
void print_primes(int limit) {
    uart_printf("Prime numbers up to %d:\n", limit);
    for (int i = 2; i <= limit; i++) {
        if (is_prime[i]) {
            uart_printf("%d ", i);
        }
    }
    uart_printf("\n");
}

int main() {
    int limit;

    // Get the user-defined limit
    uart_printf("Enter the limit (max %d): ", MAX_LIMIT);
    uart_scanf("%d", &limit);

    // Check if the limit is valid
    if (limit < 2 || limit > MAX_LIMIT) {
        uart_printf("Invalid limit! Please enter a value between 2 and %d.\n", MAX_LIMIT);
        return 0;
    }

    // Find and print primes up to 'limit'
    find_primes(limit);
    print_primes(limit);

    return 0;
}
