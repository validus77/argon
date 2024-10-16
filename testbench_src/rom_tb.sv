`timescale 1ns/1ps

module rom_tb;

    // Clock and Reset signals
    logic clk;
    logic reset;

    // Instantiate the Wishbone interface
    wishbone_if wishbone_m(.clk(clk), .rst(reset));



    // Instantiate the uart_wishbone module
    rom uut (
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
        // Wait for reset deassertion
        @(negedge reset);
        wishbone_m.sim_read(32'h00000000,, read_data);
        #20;
        $display("READ(h00000000): 0x%0h", read_data);

        wishbone_m.sim_read(32'h00000004,, read_data);
        #20;
        $display("READ(h00000004): 0x%0h", read_data);

    end


endmodule