#include "../libs/uart.h"
#include <stdbool.h>
#include <stddef.h>

#define ROWS 20
#define COLS 40
#define GENERATIONS 1000
#define DELAY 100000

static unsigned long long seed = 42;
unsigned int rand(void) {
    seed = seed * 6364136223846793005ULL + 1;
    return (unsigned int)(seed >> 32);
}

void *memset(void *s, int c, size_t n) {
    unsigned char *p = s;
    while (n--) {
        *p++ = (unsigned char)c;
    }
    return s;
}

// Simple busy-wait delay
void delay(unsigned int count) {
    volatile unsigned int i;
    for (i = 0; i < count; i++);
}

// Print the grid; using ANSI escape to move cursor home if supported
void print_grid(bool grid[ROWS][COLS]) {
    uart_printf("\033[H");  // Move cursor to top-left
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            uart_printf("%c", grid[i][j] ? '#' : ' ');
        }
        uart_printf("\n");
    }
}

// Copy one grid into another
void copy_grid(bool src[ROWS][COLS], bool dest[ROWS][COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            dest[i][j] = src[i][j];
        }
    }
}

int main(void) {
    bool grid[ROWS][COLS] = {0};
    bool new_grid[ROWS][COLS] = {0};


    // Initialize with a glider pattern
    grid[1][2] = true;
    grid[2][3] = true;
    grid[3][1] = true;
    grid[3][2] = true;
    grid[3][3] = true;

    // Randomly initialize the grid.
    // For example, 30% chance for each cell to be alive.
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            if ((rand() % 10) < 3) {
                grid[i][j] = true;
            }
        }
    }

    // Clear the screen before starting (if terminal supports ANSI)
    uart_printf("\033[2J");

    // Main simulation loop
    for (int gen = 0; gen < GENERATIONS; gen++) {
        print_grid(grid);
        // Compute next generation
        for (int i = 0; i < ROWS; i++) {
            for (int j = 0; j < COLS; j++) {
                int live_neighbors = 0;
                for (int di = -1; di <= 1; di++) {
                    for (int dj = -1; dj <= 1; dj++) {
                        if (di == 0 && dj == 0)
                            continue;
                        int ni = i + di;
                        int nj = j + dj;
                        if (ni >= 0 && ni < ROWS && nj >= 0 && nj < COLS && grid[ni][nj])
                            live_neighbors++;
                    }
                }
                if (grid[i][j]) {
                    // Cell survives with 2 or 3 neighbors
                    new_grid[i][j] = (live_neighbors == 2 || live_neighbors == 3);
                } else {
                    // Cell becomes live with exactly 3 neighbors
                    new_grid[i][j] = (live_neighbors == 3);
                }
            }
        }
        // Update grid state
        copy_grid(new_grid, grid);
        delay(DELAY);
    }
    return 0;
}
