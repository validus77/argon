`timescale 1ns / 1ps

module ram (
    input logic clk,
    input logic reset, 
    wishbone_if.slave wishbone
);

    // Data memory - BRAM
    localparam SIZE = 1024 * 32; // 32KB RAM
    (* ram_style = "block" *) reg [31:0] memory [0:SIZE - 1]; 

    // Compute the word address
    logic [$clog2(SIZE)-1:0] word_address;
    //assign word_address = wishbone.address[15:2];

    typedef enum logic [1:0] {
        IDLE,          // 2'b00
        WRITE,         // 2'b01
        READ,          // 2'b10
        DONE           // 2'b11
    } state_t;

    state_t state;

    // Write Mask
    logic [31:0] write_mask;
    
    // Temporary storage for modified data
    logic [31:0] temp_data;

    always_comb begin
        word_address =  wishbone.address[15:2];
        // Generate write mask based on select
        write_mask = (wishbone.select[3] ? 32'hFF000000 : 32'h00000000) |
                     (wishbone.select[2] ? 32'h00FF0000 : 32'h00000000) |
                     (wishbone.select[1] ? 32'h0000FF00 : 32'h00000000) |
                     (wishbone.select[0] ? 32'h000000FF : 32'h00000000);
        
        // Compute modified data for partial writes
        temp_data = (memory[word_address] & ~write_mask) | (wishbone.data_in & write_mask);
    end

        always_ff @(posedge clk) begin
        if(reset) begin
            wishbone.data_out <= 32'd0;
            wishbone.ack <= 1'b0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if(wishbone.cycle && wishbone.strobe) begin
                        wishbone.ack <= 1'b0; // Clear previous ack
                        if(wishbone.write_enable) begin
                            state <= WRITE;
                        end else begin
                            state <= READ;
                        end
                    end
                end
                
                READ: begin
                    // For read operations, output the full word
                    wishbone.data_out <= memory[word_address];
                    wishbone.ack <= 1'b1;
                    state <= DONE;
                end

                WRITE: begin
                    // Perform partial write using temp_data
                    memory[word_address] <= temp_data;
                    wishbone.ack <= 1'b1;
                    state <= DONE;
                end

                DONE: begin 
                    // De-assert ack and return to IDLE
                    wishbone.ack <= 1'b0;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule