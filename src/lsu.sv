`timescale 1ns / 1ps 

module load_store_unit (
    input logic         clk,
    input logic         reset,

    // EX -> LSU
    input logic         i_is_reg_write,
    input logic         i_is_mem_read,
    input logic         i_is_mem_write,
    input logic [31:0]  i_mem_address,
    input logic [4:0]   i_rd_id,
    input logic [31:0]  i_mem_data,
    input logic [31:0]  i_reg_data,
    input logic [2:0]   i_load_store_type,
    // IF -> LSU
    input logic i_instruction_valid,

    // Bus for memory acess 
    wishbone_if.master  wishbone_bus,

    // LSU -> IF
    output logic        o_stall,

    // LSU -> REG_FILE
    output  logic        o_write_enable,        
    output  logic [4:0]  o_write_address,        
    output  logic [31:0] o_write_data
);

typedef enum logic [1:0] {
    READY,     // Idle state
    READ_MEM,   // Read transaction state
    WRITE_MEM,
    DONE_MEM_ACCESS
} lsu_state_t;

typedef enum logic {
    BUS_READY,     // Idle state
    BUS_BUSY     // Read transaction state
} bus_state_t;

typedef enum logic [2:0] {
    BYTE = 3'b000,    
    HALF_WORD = 3'b001,
    WORD = 3'b010,
    UBYTE = 3'b100,
    UHALF = 3'b101
} load_store_type_t;

load_store_type_t load_store_type;


lsu_state_t     lsu_state;
bus_state_t     bus_state;
logic [31:0]    reg_data;

always_ff @(posedge clk) begin
    if(reset) begin
        o_write_enable <= 1'b0;
        o_write_address <= 5'd0;
        o_write_data <= 32'd0;
        o_stall <= 1'b0;
        lsu_state <= READY;
        bus_state <= BUS_READY;
        reg_data <= 32'd0;

        wishbone_bus.strobe <= 1'b0;
        wishbone_bus.cycle <= 1'b0;
        wishbone_bus.select <= 4'b1111;
        wishbone_bus.address <= 32'd0;
        wishbone_bus.write_enable<= 1'b0;
        wishbone_bus.data_in <= 32'd0;
        load_store_type <= BYTE;

    end else begin
        case (lsu_state)
            READY: begin
                if(i_instruction_valid) begin
                    reg_data <= i_reg_data;
                    load_store_type <= load_store_type_t'(i_load_store_type);
                    if(i_is_mem_read == 1'b1) begin
                        o_stall <= 1'b1;
                        lsu_state <= READ_MEM;
                    end else if (i_is_mem_write) begin
                        o_stall <= 1'b1;
                        lsu_state <= WRITE_MEM;
                    end else begin
                        lsu_state <= DONE_MEM_ACCESS;
                    end
                end
            end

            READ_MEM: begin
                case(bus_state) 
                    BUS_READY: begin
                        wishbone_bus.strobe <= 1'b1;
                        wishbone_bus.cycle <= 1'b1;
                        wishbone_bus.address <= i_mem_address;
                        bus_state <= BUS_BUSY;
                    end

                    BUS_BUSY: begin 
                        if(wishbone_bus.ack == 1'b1) begin
                            case(load_store_type)
                                WORD: begin
                                    reg_data <= wishbone_bus.data_out;
                                end
                                HALF_WORD: begin
                                    /*  look at the lower 2 bits to see what part of the word we want
                                        HEX addr 0x000, (bin 0000 0000 0000): the word arrd is [31:2] 0000 0000 00, Word 0 and byte offset 00
                                        HEX addr 0x001, (bin 0000 0000 0001): the word arrd is [31:2] 0000 0000 00, Word 0 and byte offset 01
                                        HEX addr 0x002, (bin 0000 0000 0010): the word arrd is [31:2] 0000 0000 00, Word 0 and byte offset 10
                                        HEX addr 0x003, (bin 0000 0000 0011): the word arrd is [31:2] 0000 0000 00, Word 0 and byte offset 11
                                        HEX addr 0x004, (bin 0000 0000 0100): the word arrd is [31:2] 0000 0000 01, Word 1 and byte offset 00
                                     */
                                    case(i_mem_address[1:0]) 
                                        2'b00:      reg_data <= {{16{wishbone_bus.data_out[15]}}, wishbone_bus.data_out[15:0]};
                                        2'b10:      reg_data <= {{16{wishbone_bus.data_out[31]}}, wishbone_bus.data_out[31:16]};
                                        default:    reg_data <= 32'd0; // Misaligned (EXCEPTION)
                                    endcase
                                end
                                UHALF: begin
                                    case(i_mem_address[1:0])
                                        2'b00:      reg_data <= {16'd0, wishbone_bus.data_out[15:0]};
                                        2'b10:      reg_data <= {16'd0, wishbone_bus.data_out[31:16]};
                                        default:    reg_data <= 32'd0; // Misaligned (EXCEPTION)
                                    endcase
                                end
                                BYTE: begin
                                    case(i_mem_address[1:0])
                                        2'b00: reg_data <= {{24{wishbone_bus.data_out[7]}}, wishbone_bus.data_out[7:0]};
                                        2'b01: reg_data <= {{24{wishbone_bus.data_out[15]}}, wishbone_bus.data_out[15:8]};
                                        2'b10: reg_data <= {{24{wishbone_bus.data_out[23]}}, wishbone_bus.data_out[23:16]};
                                        2'b11: reg_data <= {{24{wishbone_bus.data_out[31]}}, wishbone_bus.data_out[31:24]};
                                        default: reg_data <= 32'd0;
                                    endcase
                                    end
                                UBYTE: begin
                                    case(i_mem_address[1:0])
                                        2'b00: reg_data <= {24'd0, wishbone_bus.data_out[7:0]};
                                        2'b01: reg_data <= {24'd0, wishbone_bus.data_out[15:8]};
                                        2'b10: reg_data <= {24'd0, wishbone_bus.data_out[23:16]};
                                        2'b11: reg_data <= {24'd0, wishbone_bus.data_out[31:24]};
                                        default: reg_data <= 32'd0;
                                    endcase
                                end
                                default: reg_data <= wishbone_bus.data_out;
                            endcase
                            wishbone_bus.strobe <= 1'b0;
                            wishbone_bus.cycle <= 1'b0;
                            wishbone_bus.write_enable<= 1'b0;
                            wishbone_bus.address <= 32'd0;
                            bus_state <= BUS_READY;
                            lsu_state <= DONE_MEM_ACCESS;
                        end
                    end
                endcase
            end

            WRITE_MEM: begin
                o_stall <= 1'b1;
                case(bus_state)
                    BUS_READY: begin
                        case(load_store_type)
                                WORD: begin
                                    wishbone_bus.select <= 4'b1111;
                                end
                                HALF_WORD: begin
                                    case(i_mem_address[1:0])
                                        2'b00:      wishbone_bus.select = 4'b0011;
                                        2'b10:      wishbone_bus.select = 4'b1100;
                                        default:    wishbone_bus.select = 4'b0000; // Misaligned
                                    endcase
                                end
                                BYTE: begin
                                    case(i_mem_address[1:0])
                                        2'b00:      wishbone_bus.select = 4'b0001;
                                        2'b01:      wishbone_bus.select = 4'b0010;
                                        2'b10:      wishbone_bus.select = 4'b0100;
                                        2'b11:      wishbone_bus.select = 4'b1000;
                                        default:    wishbone_bus.select = 4'b0000;
                                    endcase
                                end
                                default: wishbone_bus.select <= 4'b1111;
                            endcase
                        wishbone_bus.strobe <= 1'b1;
                        wishbone_bus.cycle <= 1'b1;
                        wishbone_bus.write_enable<= 1'b1;
                        wishbone_bus.address <= i_mem_address;
                        wishbone_bus.data_in <= i_mem_data;
                        bus_state <= BUS_BUSY;
                    end

                    BUS_BUSY: begin
                        if(wishbone_bus.ack == 1'b1) begin
                            wishbone_bus.strobe <= 1'b0;
                            wishbone_bus.cycle <= 1'b0;
                            wishbone_bus.write_enable<= 1'b0;
                            wishbone_bus.address <= 32'd0;
                            wishbone_bus.data_in <= 32'd0;
                            bus_state <= BUS_READY;
                            lsu_state <= DONE_MEM_ACCESS;
                        end
                    end
                endcase
            end

            DONE_MEM_ACCESS: begin
                if(i_is_reg_write) begin
                    o_write_enable <= 1'b1;
                    o_write_address <= i_rd_id;
                    o_write_data <= reg_data;
                end
                o_stall <= 1'b0;
                lsu_state <= READY;
            end
        endcase
    
    end
end

endmodule