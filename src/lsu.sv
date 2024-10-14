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
    end else begin
        case (lsu_state)
            READY: begin
                if(i_instruction_valid) begin
                    reg_data <= i_reg_data;
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
                           reg_data <= wishbone_bus.data_out;
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