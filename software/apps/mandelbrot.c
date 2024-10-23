#include "../libs/uart.h"

#define W 46
#define H 46

#define mandel_shift 10
#define mandel_mul (1 << mandel_shift)
#define xmin -2*mandel_mul
#define ymax  2*mandel_mul
#define ymin -2*mandel_mul
#define xmax  2*mandel_mul
#define dx (xmax-xmin)/H
#define dy (ymax-ymin)/H
#define norm_max (4 << mandel_shift)

// ASCII characters for different iterations
const char ascii_map[21] = {
    ' ', '.', ':', '-', '=', '+', '*', '#', '%', '@',
    ' ', '.', ':', '-', '=', '+', '*', '#', '%', '@',
    '@'  // Last color for full iteration
};

int main() {
    int frame = 0;
    for (;;) {
        uart_printf("\033[H");  // Move cursor to top-left
        int Ci = ymin;

        for (int Y = 0; Y < H; ++Y) {
            int Cr = xmin;

            for (int X = 0; X < W; ++X) {
                int Zr = Cr;
                int Zi = Ci;
                int iter = 20;

                while (iter > 0) {
                    int Zrr = (Zr * Zr) >> mandel_shift;
                    int Zii = (Zi * Zi) >> mandel_shift;
                    int Zri = (Zr * Zi) >> (mandel_shift - 1);

                    Zr = Zrr - Zii + Cr;
                    Zi = Zri + Ci;

                    if (Zrr + Zii > norm_max) {
                        break;
                    }
                    --iter;
                }

                // Use ASCII mapping for output
                char symbol = ascii_map[(iter + frame) % 21];
                uart_putchar(symbol);
                uart_putchar(symbol);  // Double for better visibility

                Cr += dx;
            }

            Ci += dy;
            uart_putchar('\n');  // Move to next line
        }

        ++frame;
    }

    return 0;
}