`timescale 1ns / 1ps

module rom(
    input logic clk, 
    input logic reset,
    wishbone_if.slave wishbone
);

    localparam SIZE = 1024 * 16; // 16KB ROM 
    // Instruction memory - BRAM
    (* rom_style = "block" *) reg [31:0] memory [0:SIZE-1];
    
    initial begin
        $readmemh("D:/Dev/Dump/hello_world.hex", memory);  // For simulation or FPGA memory init
        #10;  // Wait for some time to ensure memory is loaded
        $display("Memory[0]: %h", memory[0]);
        $display("Memory[1]: %h", memory[1]);
        $display("Memory[2]: %h", memory[2]);
        $display("Memory[3]: %h", memory[3]);
    end

    // Compute the word address
    logic [$clog2(SIZE)-1:0] word_address;
    //assign word_address = wishbone.address[15:2];

    always_comb begin
        word_address = wishbone.address[15:2];
    end

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