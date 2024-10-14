`timescale 1ns/1ps

module ram_tb;

// Clock and Reset signals
    logic clk;
    logic reset;

    // Instantiate the Wishbone interface
    wishbone_if wishbone_m();



    // Instantiate the uart_wishbone module
    ram uut (
        .clk(clk),
        .reset(reset),
        .wishbone(wishbone_m.slave)
    );

    // Clock generation (50 MHz clock)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Clock period = 10 ns
    end

    // Reset generation
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    logic [31:0] read_data;
    
    initial begin
        @(negedge reset);
        // WTIRE data to the RAM
        wishbone_m.sim_write(32'h00000000, 32'hA0001234);
        #20;
        wishbone_m.sim_read(32'h00000000, read_data);
        #20;
        $display("READ(h00000000): 0x%0h, expect 0xa0001234", read_data);

        // WTIRE data to the RAM
        wishbone_m.sim_write(32'h00000256, 32'hDEADBEEF);
        #20;
        wishbone_m.sim_read(32'h00000256, read_data);
        #20;
        $display("READ(h00000256): 0x%0h, expect 0xDEADBEEF", read_data);
        $finish;
    end

endmodule
