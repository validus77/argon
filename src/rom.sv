`timescale 1ns / 1ps

module rom(
    input logic clk, 
    input logic reset,
    wishbone_if.slave wishbone
);

    localparam SIZE = 1024 * 16; // 16KB ROM 
    // Instruction memory - BRAM
    reg [31:0] memory [0:SIZE-1];

    initial begin
        //$readmemh("test_rom.hex", memory);  // For simulation or FPGA memory init
        memory[0] = 32'h00000093; // nop instruction
        memory[1] = 32'h0000DEAD; // nop instruction
        memory[2] = 32'h00000093; // nop instruction
    end

    // Compute the word address
    logic [$clog2(SIZE)-1:0] word_address;
    assign word_address = wishbone.address[15:2];


    typedef enum logic [1:0] {
        IDLE,          // 2'b00
        TRANSACTION,   // 2'b01
        DONE           // 2'b10
    } state_t;

    state_t state;

    always_ff @(posedge clk) begin
        if(reset) begin
            wishbone.data_out <= 32'd0;
            wishbone.ack <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if(wishbone.cycle && wishbone.strobe) begin
                        state <= TRANSACTION;
                    end
                end

                TRANSACTION: begin
                    wishbone.data_out <= memory[word_address];
                    wishbone.ack <= 1'b1;
                    state <= DONE;
                end

                DONE: begin
                    wishbone.ack <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule