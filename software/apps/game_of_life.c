#include "../libs/uart.h"

#define WIDTH 20
#define HEIGHT 20
#define GENERATIONS 100

// Define the grid
int grid[HEIGHT][WIDTH];
int next_grid[HEIGHT][WIDTH];

// Initialize the grid with a simple glider pattern
void initialize_grid() {
    // Clear the grid
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            grid[y][x] = 0;
        }
    }

    // Add a glider pattern
    grid[1][2] = 1;
    grid[2][3] = 1;
    grid[3][1] = 1;
    grid[3][2] = 1;
    grid[3][3] = 1;
}

// Print the grid to UART
void print_grid() {
    uart_printf("\033[H");  // Move cursor to the top-left
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            if (grid[y][x]) {
                uart_putchar('#');  // Alive cell
            } else {
                uart_putchar(' ');  // Dead cell
            }
        }
        uart_putchar('\n');
    }
}

// Count the number of live neighbors for a cell
int count_neighbors(int y, int x) {
    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            if (dy == 0 && dx == 0) continue;  // Skip the cell itself
            int ny = (y + dy + HEIGHT) % HEIGHT;  // Wrap around vertically
            int nx = (x + dx + WIDTH) % WIDTH;    // Wrap around horizontally
            count += grid[ny][nx];
        }
    }
    return count;
}

// Update the grid based on the Game of Life rules
void update_grid() {
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            int neighbors = count_neighbors(y, x);

            // Apply the rules of Conway's Game of Life
            if (grid[y][x] == 1) {
                // Cell is alive
                next_grid[y][x] = (neighbors == 2 || neighbors == 3) ? 1 : 0;
            } else {
                // Cell is dead
                next_grid[y][x] = (neighbors == 3) ? 1 : 0;
            }
        }
    }

    // Copy next_grid to grid
    for (int y = 0; y < HEIGHT; y++) {
        for (int x = 0; x < WIDTH; x++) {
            grid[y][x] = next_grid[y][x];
        }
    }
}

int main() {
    // Initialize the grid with a starting pattern
    initialize_grid();

    // Run the simulation for a certain number of generations
    for (int gen = 0; gen < GENERATIONS; gen++) {
        print_grid();       // Print the current grid
        update_grid();      // Update the grid
        uart_printf("\n");  // Add a line break between generations

        // Simple delay to slow down the simulation
        for (volatile int i = 0; i < 1000000; i++);

        uart_printf("Generation %d\n", gen + 1);
    }

    return 0;
}
