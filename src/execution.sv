`timescale 1ns / 1ps

module execution (
    // ID -> EXE
    input alu_opcode_t i_alu_opcode,
    input logic [31:0] i_alu_op1,
    input logic [31:0] i_alu_op2,
    input logic [4:0]  i_rd_id,

    input logic        i_is_reg_write,
    input logic        i_is_load,
    input logic        i_is_store,
    input logic        i_is_jump,
    input logic [31:0] i_jump_address,
    input logic        i_is_branch,
    input logic [2:0]  i_branch_type,
    input logic [31:0] i_store_data,

    // EX -> IF
    output logic        o_branch_enable,
    output logic [31:0] o_branch_address,

    // EX -> LSU
    output logic        o_is_reg_write,
    output logic        o_is_mem_read,
    output logic        o_is_mem_write,
    output logic [31:0] o_mem_address,
    output logic [4:0]  o_rd_id,
    output logic [31:0] o_mem_data,
    output logic [31:0] o_reg_data
);
    typedef enum logic [2:0] {
    BEQ     = 3'b000,
    BNE     = 3'b001,
    BLT     = 3'b100,
    BGE     = 3'b101,
    BLTU    = 3'b110,
    BGEU    = 3'b111
    } branch_code_t;

    logic [31:0] alu_result;
    logic zero_flag;
    logic sign_flag;
    logic overflow_flag;
    logic carry_flag;

    alu alu_inst (
        .i_op1(i_alu_op1),
        .i_op2(i_alu_op2),
        .i_alu_op(i_alu_opcode),
        .o_result(alu_result)
    );

    always_comb begin

        // Default assignments
        o_branch_enable     = 1'b0;
        o_branch_address    = i_jump_address;
        o_is_reg_write      = 1'b0;
        o_is_mem_read       = 1'b0;
        o_is_mem_write      = 1'b0;
        o_mem_address       = 32'd0;
        o_rd_id             = i_rd_id;
        o_mem_data          = 32'd0;
        o_reg_data          = 32'd0;

        // ALU flags
        zero_flag = (alu_result == 0);
        sign_flag = alu_result[31];
        overflow_flag = (i_alu_op1[31] != i_alu_op2[31]) && (alu_result[31] != i_alu_op1[31]);
        carry_flag = (i_alu_op1 < i_alu_op2);



        // Set up LSU for reg access 
        if(i_is_reg_write == 1'b1 && i_is_load == 1'b0) begin
            /* For OPCODE_RTYPE, OPCODE_ITYPE, OPCODE_LUI, OPCODE_AUIPC, OPCODE_JAL, OPCODE_JALR
               we can just have the LSU write the results of the ALU to rd. OPCODE_LOAD is diffrent
               and we need it's own handling
            */
            o_is_reg_write = 1'b1;
            o_reg_data = alu_result;
        end

        // Brach and Jump logic 
        if(i_is_branch == 1'b1) begin
            case(branch_code_t'(i_branch_type))
                BEQ:        o_branch_enable = zero_flag;
                BNE:        o_branch_enable = ~zero_flag;
                BLT:        o_branch_enable = (sign_flag != overflow_flag);
                BGE:        o_branch_enable = (sign_flag == overflow_flag);
                BLTU:       o_branch_enable = carry_flag;
                BGEU:       o_branch_enable = ~carry_flag;
                default:    o_branch_enable = 1'b0;
            endcase
        end else if (i_is_jump) begin
            o_branch_enable = 1'b1;
        end

        // Setup LSU for Mem access
        if(i_is_load == 1'b1) begin
            o_is_mem_read = 1'b1;
            o_is_reg_write = 1'b1;
            o_mem_address = alu_result;
        end else if (i_is_store) begin
            o_is_mem_write = 1'b1;
            o_mem_address = alu_result;
            o_mem_data = i_store_data;
        end

    end



endmodule