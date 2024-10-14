`timescale 1ns / 1ps

module instruction_fetch (
    input logic             clk,
    input logic             reset,

    input logic             i_branch_enable, 
    input logic  [31:0]     i_branch_address,
    input logic             i_stall,
    
    wishbone_if.master      wishbone_bus,

    output logic [31:0]     o_instruction,
    output logic            o_instruction_valid, 
    output logic [31:0]     o_pc
);

typedef enum logic {
    READY,     // Idle state
    READ     // Read transaction state
} mem_state_t;

// internal signals 
logic [31:0] current_pc;
logic [31:0] next_pc;
mem_state_t bus_state;

always_ff @(posedge clk) begin
    if (reset) begin
        o_pc <= 32'd0;
        o_instruction <= 32'd0;
        o_instruction_valid <= 1'b0;
        current_pc <= 32'd0;
        wishbone_bus.strobe <= 1'b0;
        wishbone_bus.cycle <= 1'b0;
        wishbone_bus.select <= 4'b1111;
        wishbone_bus.address <= 32'd0;
        wishbone_bus.write_enable<= 1'b0;
        wishbone_bus.data_in <= 32'd0;
        bus_state <= READY;
    end else begin
        // LOAD instruction
        case (bus_state)
        READY: begin
            if(i_stall == 1'b0) begin 
                if (i_branch_enable == 1'b1) begin
                    // if we are branching then flush the pc address early
                    current_pc <= next_pc;
                end
                bus_state <= READ;
            end 

        end

        READ: begin 
            if(wishbone_bus.ack == 1'b1) begin

                o_instruction <= wishbone_bus.data_out;
                o_instruction_valid <= 1'b1;
                wishbone_bus.strobe <= 1'b0;
                wishbone_bus.cycle <= 1'b0;
                current_pc <= next_pc;

                bus_state <= READY;
            end else begin
                o_instruction_valid <= 1'b0;
                wishbone_bus.address <= current_pc;
                o_pc <= current_pc;
                wishbone_bus.strobe <= 1'b1;
                wishbone_bus.cycle <= 1'b1;
            end 
        end

        default: bus_state <= READY;
        endcase
    end
end

always_comb begin
    if(i_branch_enable == 1'b1) begin
        next_pc = i_branch_address;
    end else begin
        next_pc = current_pc + 4;
    end
end

endmodule