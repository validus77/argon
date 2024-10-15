`timescale 1ns / 1ps
`include "alu.svh"
module alu (
    input logic [31:0]  i_op1,
    input logic [31:0]  i_op2,
    input alu_opcode_t  i_alu_op,

    output logic [31:0] o_result
);


always_comb begin
    o_result = 32'd0;
    
    case (i_alu_op)
        ALU_ADD: begin
            o_result = i_op1 + i_op2;
        end
        ALU_SUB: begin
            o_result = i_op1 - i_op2;
        end
        ALU_SLL: begin
            o_result = i_op1 << i_op2[4:0];
        end
        ALU_SLT: begin
            o_result = ($signed(i_op1) < $signed(i_op2)) ? 32'b1 : 32'b0;
        end
        ALU_SLTU: begin
            o_result = (i_op1 < i_op2) ? 32'b1 : 32'b0;
        end
        ALU_XOR: begin
            o_result = i_op1 ^ i_op2;
        end
        ALU_SRL: begin
            o_result = i_op1 >> i_op2[4:0];
        end
        ALU_SRA: begin
            o_result = $signed(i_op1) >>> i_op2[4:0];
        end
        ALU_OR: begin
            o_result = i_op1 | i_op2;
        end
        ALU_AND: begin
            o_result = i_op1 & i_op2;
        end
        default: begin
            o_result = 32'b0;
        end
    endcase
end

endmodule
