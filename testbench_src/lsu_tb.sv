`timescale 1ns / 1ps

module load_store_unit_tb;

    // Clock and Reset
    logic clk;
    logic reset;

    // Inputs to the LSU
    logic         i_is_reg_write;
    logic         i_is_mem_read;
    logic         i_is_mem_write;
    logic [31:0]  i_mem_address;
    logic [4:0]   i_rd_id;
    logic [31:0]  i_mem_data;
    logic [31:0]  i_reg_data;

    // Outputs from the LSU
    logic        o_stall;
    logic        o_write_enable;
    logic [4:0]  o_write_address;
    logic [31:0] o_write_data;

    // Wishbone Bus Interface
    wishbone_if wishbone_bus();

    // Instantiate the DUT
    load_store_unit dut (
        .clk(clk),
        .reset(reset),
        .i_is_reg_write(i_is_reg_write),
        .i_is_mem_read(i_is_mem_read),
        .i_is_mem_write(i_is_mem_write),
        .i_mem_address(i_mem_address),
        .i_rd_id(i_rd_id),
        .i_mem_data(i_mem_data),
        .i_reg_data(i_reg_data),
        .wishbone_bus(wishbone_bus.master),
        .o_stall(o_stall),
        .o_write_enable(o_write_enable),
        .o_write_address(o_write_address),
        .o_write_data(o_write_data)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Task to reset DUT
    task reset_dut();
        begin
            reset = 1;
            @(posedge clk);
            @(posedge clk);
            reset = 0;
        end
    endtask

    // Test sequence
    initial begin
        // Initialize inputs
        i_is_reg_write  = 0;
        i_is_mem_read   = 0;
        i_is_mem_write  = 0;
        i_mem_address   = 32'd0;
        i_rd_id         = 5'd0;
        i_mem_data      = 32'd0;
        i_reg_data      = 32'd0;

        // Reset the DUT
        reset_dut();

        // Test 1: Memory Read Operation
        $display("Test 1: Memory Read Operation");
        i_is_mem_read   = 1;
        i_is_reg_write  = 1;
        i_mem_address   = 32'h0000_1000;
        i_rd_id         = 5'd1; // Destination register

        // Simulate Wishbone Bus Acknowledgment
        fork
            // Simulate bus behavior
            begin
                @(posedge wishbone_bus.strobe);
                #10; // Simulate bus delay
                wishbone_bus.ack <= 1;
                wishbone_bus.data_out <= 32'hDEADBEEF; // Data from memory
               #20;
                wishbone_bus.ack <= 0;
                wishbone_bus.data_out <= 32'd0;
            end
            // Monitor outputs
            begin
                wait(o_write_enable);
                $display("Memory Read Complete:");
                $display("o_write_enable   = %b", o_write_enable);
                $display("o_write_address  = %d", o_write_address);
                $display("o_write_data     = 0x%h", o_write_data);
                $display("o_stall          = %b", o_stall);
            end
        join

        // Reset inputs
        i_is_mem_read   = 0;
        i_mem_address   = 32'd0;
        i_rd_id         = 5'd0;

        // Test 2: Memory Write Operation
        $display("Test 2: Memory Write Operation");
        i_is_mem_write  = 1;
        i_mem_address   = 32'h0000_2000;
        i_mem_data      = 32'hCAFEBABE;

        // Simulate Wishbone Bus Acknowledgment
        fork
            // Simulate bus behavior
            begin
                @(posedge wishbone_bus.strobe);
                #10; // Simulate bus delay
                wishbone_bus.ack <= 1;
                #20;
                wishbone_bus.ack <= 0;
            end
            // Monitor outputs
            begin
                wait(!o_stall);
                $display("Memory Write Complete:");
                $display("o_stall          = %b", o_stall);
            end
        join

        // Reset inputs
        i_is_mem_write  = 0;
        i_mem_address   = 32'd0;
        i_mem_data      = 32'd0;

        // Test 3: Register Write Operation (No Memory Access)
        $display("Test 3: Register Write Operation (No Memory Access)");
        i_is_reg_write  = 1;
        i_reg_data      = 32'h12345678;
        i_rd_id         = 5'd2;

        @(posedge clk);
        $display("Register Write:");
        $display("o_write_enable   = %b", o_write_enable);
        $display("o_write_address  = %d", o_write_address);
        $display("o_write_data     = 0x%h", o_write_data);
        $display("o_stall          = %b", o_stall);

        // Finish simulation
        #20;
        $finish;
    end

endmodule
