`timescale 1ns / 1ps

// Simple Wishbone slave model for testing
module wishbone_slave_model(
    input  logic             clk,
    input  logic             reset,
    wishbone_if.slave        wishbone_bus
);
    // Simple memory to store instructions
    logic [31:0] memory [0:255]; // Adjust size as needed

    // Initialize memory with some instructions
    initial begin
        // For example purposes, load memory with incremental values
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'h00AA0000 + i; // NOP instructions with variation
        end
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wishbone_bus.ack <= 1'b0;
        end else begin
            if (wishbone_bus.cycle && wishbone_bus.strobe) begin
                if (!wishbone_bus.ack) begin
                    // Simulate one cycle delay for memory read
                    wishbone_bus.ack <= 1'b1;
                    wishbone_bus.data_out <= memory[wishbone_bus.address[9:2]]; // Assuming word-aligned addresses
                end
            end else begin
                wishbone_bus.ack <= 1'b0;
            end
        end
    end
endmodule

// Testbench module
module instruction_fetch_tb;
    // Clock and reset signals
    logic clk;
    logic reset;

    // Branch control signals
    logic             i_branch_enable;
    logic [31:0]      i_branch_address;
    logic             i_stall;

    // Outputs from instruction fetch
    logic [31:0]      o_instruction;
    logic [31:0]      o_pc;
    logic             o_valid;


    // Wishbone interface
    wishbone_if       wishbone_bus(clk, reset);

    // Instantiate the instruction_fetch module
    instruction_fetch dut (
        .clk(clk),
        .reset(reset),
        .i_branch_enable(i_branch_enable),
        .i_branch_address(i_branch_address),
        .wishbone_bus(wishbone_bus.master),
        .o_instruction(o_instruction),
        .o_pc(o_pc),
        .o_instruction_valid(o_valid),
        .i_stall(i_stall)
    );

    // Instantiate the Wishbone slave model
    wishbone_slave_model memory_model (
        .clk(clk),
        .reset(reset),
        .wishbone_bus(wishbone_bus.slave)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Test sequences
    initial begin
        $display("TEST START");
        // Initialize inputs
        reset = 1'b1;
        i_branch_enable = 1'b0;
        i_branch_address = 32'd0;
        i_stall = 1'b0;

        // Wait for a few clock cycles
        #20;
        reset = 1'b0;

        // Wait for instruction fetch to complete
        wait(o_valid);
        $display("Time %0t: PC=%h, Instruction=%h", $time, o_pc, o_instruction);
        wait(~o_valid);
        
        
        // Wait for next instruction fetch
        wait(o_valid);
        $display("Time %0t: PC=%h, Instruction=%h", $time, o_pc, o_instruction);
        // Simulate a branch
        i_stall = 1'b1;
        i_branch_enable = 1'b1;
        i_branch_address = 32'h00000020; // Branch to address 0x20
        #40
        i_stall = 1'b0;
        wait(~o_valid);
        i_branch_enable = 1'b0; // Deassert branch enable
        // Wait for instruction fetch after branch
        wait(o_valid);
        $display("Time %0t: PC=%h, Instruction=%h (After Branch)", $time, o_pc, o_instruction);
        wait(~o_valid);
        #10;
        // Wait for another instruction fetch
        wait(o_valid);
        $display("Time %0t: PC=%h, Instruction=%h", $time, o_pc, o_instruction);
        wait(~o_valid);
        #10;

        // End simulation
        #50;
        $finish;
    end
endmodule
