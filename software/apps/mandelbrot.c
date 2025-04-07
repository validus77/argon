#include "../libs/uart.h"

#define WIDTH 80
#define HEIGHT 24
#define MAX_ITER 100

int main(void) {
    // Loop over each row of the display
    for (int y = 0; y < HEIGHT; y++) {
        char line[WIDTH + 1];  // Buffer for one line of output
        // Loop over each column of the display
        for (int x = 0; x < WIDTH; x++) {
            // Map pixel coordinates to the complex plane.
            // These constants define the region of the complex plane we are displaying.
            double cx = (x - WIDTH / 2.0) * 3.5 / WIDTH - 0.7;
            double cy = (y - HEIGHT / 2.0) * 2.0 / HEIGHT;
            double zx = 0.0, zy = 0.0;
            int iter;
            // Iterate the Mandelbrot function: z = z^2 + c
            for (iter = 0; iter < MAX_ITER; iter++) {
                double temp = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = temp;
                if (zx * zx + zy * zy > 4.0)
                    break;
            }
            // Select a character based on the number of iterations
            char ch;
            if (iter == MAX_ITER)
                ch = '#';  // Likely in the Mandelbrot set
            else {
                // Use a simple palette to create a gradient effect
                const char *palette = " .:-=+*#%@";
                int index = (iter * 9) / MAX_ITER;  // Scale iteration count to palette index (0-9)
                ch = palette[index];
            }
            line[x] = ch;
        }
        line[WIDTH] = '\0';  // Null-terminate the line
        uart_printf("%s\n", line);
    }
    return 0;
}