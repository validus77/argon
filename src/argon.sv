`timescale 1ns / 1ps
module argon_riscv_cpu(
        input logic         clk,
        input logic         reset,
        wishbone_if.master  if_wishbone_master,
        wishbone_if.master  lsu_wishbone_master
    );

    // EXE -> IF
    logic           branch_enable;
    logic [31:0]    branch_address;

    // LSU -> IF 
    logic           stall;

    // IF -> ID
    logic [31:0]    instruction;
    logic [31:0]    pc;

    // IF -> LSU
    logic           instruction_valid;

    // ID -> RegFile
    logic [4:0]     rs1_id;
    logic [4:0]     rs2_id;

    // LSU -> REG_FILE
    logic           write_enable;        
    logic [4:0]     write_address;        
    logic [31:0]    write_data;

    // RegFile -> ID
    logic [31:0]    rs1_data;
    logic [31:0]    rs2_data;

    // ID -> EXE
    alu_opcode_t    alu_opcode;
    logic [31:0]    alu_op1;
    logic [31:0]    alu_op2;
    logic [4:0]     rd_id;
    logic           is_reg_write;
    logic           is_load;
    logic           is_store;
    logic           is_jump;
    logic [31:0]    jump_address;
    logic           is_branch;
    logic [2:0]     branch_type;
    logic [31:0]    store_data;
    logic [2:0]     load_store_type;

    // EX -> LSU
    logic           ex_is_reg_write;
    logic           ex_is_mem_read;
    logic           ex_is_mem_write;
    logic [31:0]    ex_mem_address;
    logic [4:0]     ex_rd_id;
    logic [31:0]    ex_mem_data;
    logic [31:0]    ex_reg_data;
    logic [2:0]     ex_load_store_type;

    instruction_fetch ins_f(
        .clk(clk),
        .reset(reset),
        .i_branch_enable(branch_enable),
        .i_branch_address(branch_address),
        .i_stall(stall),
        .wishbone_bus(if_wishbone_master),
        .o_instruction(instruction),
        .o_instruction_valid(instruction_valid),
        .o_pc(pc)
    );

    instruction_decode id(
        .i_pc(pc),
        .i_instruction(instruction),
        .o_rs1_id(rs1_id),
        .o_rs2_id(rs2_id),
        .i_rs1_data(rs1_data),
        .i_rs2_data(rs2_data),
        .o_alu_opcode(alu_opcode),
        .o_alu_op1(alu_op1),
        .o_alu_op2(alu_op2),
        .o_rd_id(rd_id),
        .o_is_reg_write(is_reg_write),
        .o_is_load(is_load),
        .o_is_store(is_store),
        .o_load_store_type(load_store_type),
        .o_is_jump(is_jump),
        .o_jump_address(jump_address),
        .o_is_branch(is_branch),
        .o_branch_type(branch_type),
        .o_store_data(store_data) 
    );

    execution exe (
        .i_alu_opcode(alu_opcode),
        .i_alu_op1(alu_op1),
        .i_alu_op2(alu_op2),
        .i_rd_id(rd_id),
        .i_is_reg_write(is_reg_write),
        .i_is_load(is_load),
        .i_is_store(is_store),
        .i_is_jump(is_jump),
        .i_jump_address(jump_address),
        .i_is_branch(is_branch),
        .i_branch_type(branch_type),
        .i_store_data(store_data),
        .i_load_store_type(load_store_type),
        .o_branch_enable(branch_enable),
        .o_branch_address(branch_address),
        .o_is_reg_write(ex_is_reg_write),
        .o_is_mem_read(ex_is_mem_read),
        .o_is_mem_write(ex_is_mem_write),
        .o_mem_address(ex_mem_address),
        .o_rd_id(ex_rd_id),
        .o_mem_data(ex_mem_data),
        .o_reg_data(ex_reg_data),
        .o_load_store_type(ex_load_store_type)
    );

    load_store_unit lsu(
        .clk(clk),
        .reset(reset),
        .i_is_reg_write(ex_is_reg_write),
        .i_is_mem_read(ex_is_mem_read),
        .i_is_mem_write(ex_is_mem_write),
        .i_mem_address(ex_mem_address),
        .i_rd_id(ex_rd_id),
        .i_mem_data(ex_mem_data),
        .i_reg_data(ex_reg_data),
        .i_load_store_type(ex_load_store_type),
        .i_instruction_valid(instruction_valid),
        .wishbone_bus(lsu_wishbone_master),
        .o_stall(stall),
        .o_write_enable(write_enable),        
        .o_write_address(write_address),        
        .o_write_data(write_data)
    );

    register_file reg_file(
        .clk(clk), 
        .reset(reset),    
        .i_write_enable(write_enable),        
        .i_write_address(write_address),        
        .i_write_data(write_data),      
        .i_read_address_1(rs1_id),      
        .o_read_data_1(rs1_data),      
        .i_read_address_2(rs2_id),       
        .o_read_data_2(rs2_data)     
    );

endmodule
