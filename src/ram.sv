`timescale 1ns / 1ps

module ram (
    input logic clk,
    input logic reset, 
    wishbone_if.slave wishbone
);

    // Data memory - BRAM
    localparam SIZE = 1024 * 32; // 32KB RAM
    reg [31:0] memory [0:SIZE - 1]; 

    // Compute the word address
    logic [$clog2(SIZE)-1:0] word_address;
    assign word_address = wishbone.address[15:2];

    typedef enum logic [1:0] {
        IDLE,          // 2'b00
        WRITE,         // 2'b01
        READ,          // 2'b10
        DONE           // 2'b11
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
                        if(wishbone.write_enable) begin
                            state <= WRITE;
                        end else begin
                            state <= READ;
                        end
                    end
                end

                READ: begin
                    wishbone.data_out <= memory[word_address];
                    wishbone.ack <= 1'b1;
                    state <= DONE;
                end

                WRITE: begin
                    memory[word_address] <= wishbone.data_in;
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