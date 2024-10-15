int main() {
    volatile int result;
    int a = 10;
    int b = 20;

    // Test addition
    result = a + b; // result should be 30
    if (result != 30) {
        while (1); // Error: Loop forever
    }

    // Test subtraction
    result = b - a; // result should be 10
    if (result != 10) {
        while (1); // Error: Loop forever
    }

    // Test memory (load/store)
    volatile int memory[1];
    memory[0] = result;   // Store 10 into memory
    result = memory[0];   // Load from memory
    if (result != 10) {
        while (1); // Error: Loop forever
    }

    // All tests passed
    while (1); // Loop forever to halt
    return 0;
}

