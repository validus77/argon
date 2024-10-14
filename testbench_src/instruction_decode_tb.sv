`timescale 1ns / 1ps

module instruction_decode_tb;

    // Inputs to the DUT
    logic [31:0] i_pc;
    logic [31:0] i_instruction;
    logic [31:0] i_rs1_data;
    logic [31:0] i_rs2_data;

    // Outputs from the DUT
    logic [4:0] o_rs1_id;
    logic [4:0] o_rs2_id;
    alu_opcode_t o_alu_opcode;
    logic [31:0] o_alu_op1;
    logic [31:0] o_alu_op2;
    logic [4:0]  o_rd_id;
    logic        o_is_reg_write;
    logic        o_is_load;
    logic        o_is_store;
    logic        o_is_jump;
    logic [31:0] o_jump_address;
    logic        o_is_branch;
    logic [2:0]  o_branch_type;
    logic [31:0] o_store_data;

    // Instantiate the DUT
    instruction_decode dut (
        .i_pc(i_pc),
        .i_instruction(i_instruction),
        .o_rs1_id(o_rs1_id),
        .o_rs2_id(o_rs2_id),
        .i_rs1_data(i_rs1_data),
        .i_rs2_data(i_rs2_data),
        .o_alu_opcode(o_alu_opcode),
        .o_alu_op1(o_alu_op1),
        .o_alu_op2(o_alu_op2),
        .o_rd_id(o_rd_id),
        .o_is_reg_write(o_is_reg_write),
        .o_is_load(o_is_load),
        .o_is_store(o_is_store),
        .o_is_jump(o_is_jump),
        .o_jump_address(o_jump_address),
        .o_is_branch(o_is_branch),
        .o_branch_type(o_branch_type),
        .o_store_data(o_store_data)
    );

    // Task to apply instruction and display results
    task test_instruction(
        input logic [31:0] instruction,
        input logic [31:0] pc,
        input logic [31:0] rs1_data,
        input logic [31:0] rs2_data,
        input string instruction_name
    );
        begin
            i_instruction = instruction;
            i_pc = pc;
            i_rs1_data = rs1_data;
            i_rs2_data = rs2_data;

            // Wait for combinational logic to settle
            #1;

            // Display results
            $display("---- %s ----", instruction_name);
            $display("Instruction: %h", instruction);
            $display("PC: %h", i_pc);
            $display("RS1 ID: %0d, RS1 Data: %0d", o_rs1_id, i_rs1_data);
            $display("RS2 ID: %0d, RS2 Data: %0d", o_rs2_id, i_rs2_data);
            $display("RD ID: %0d", o_rd_id);
            $display("ALU Opcode: %b", o_alu_opcode);
            $display("ALU Op1: %0d", o_alu_op1);
            $display("ALU Op2: %0d", o_alu_op2);
            $display("Is Reg Write: %b", o_is_reg_write);
            $display("Is Load: %b", o_is_load);
            $display("Is Store: %b", o_is_store);
            $display("Is Jump: %b", o_is_jump);
            $display("Jump Address: %h", o_jump_address);
            $display("Is Branch: %b", o_is_branch);
            $display("Branch Type: %b", o_branch_type);
            $display("Store Data: %0d", o_store_data);
            $display("------------------------------\n");

            // Wait before next instruction
            #10;
        end
    endtask

    // Apply test stimuli
    initial begin
        // Initialize inputs
        i_pc = 32'h00000000;
        i_rs1_data = 32'd0;
        i_rs2_data = 32'd0;

        // Wait for a short time to observe initial state
        #10;

        // Test R-type ADD instruction
        test_instruction(32'b0000000_00010_00001_000_00011_0110011, 32'h00000000, 32'd5, 32'd10, "R-type ADD");

        // Test I-type ADDI instruction
        test_instruction(32'b000000000101_00001_000_00011_0010011, 32'h00000004, 32'd15, 32'd0, "I-type ADDI");

        // Test Load (LW) instruction
        test_instruction(32'b000000000100_00001_010_00010_0000011, 32'h00000008, 32'd100, 32'd0, "Load LW");

        // Test Store (SW) instruction
        test_instruction(32'b0000000_00010_00001_010_01000_0100011, 32'h0000000C, 32'd200, 32'd300, "Store SW");

        // Test Branch (BEQ) instruction
        test_instruction(32'b0000000_00010_00001_000_00000_1100011, 32'h00000010, 32'd400, 32'd400, "Branch BEQ");

        // Test JAL instruction
        test_instruction(32'b00000000000100000000_00000_1101111, 32'h00000014, 32'd0, 32'd0, "JAL");

        // Test JALR instruction
        test_instruction(32'b000000000100_00001_000_00010_1100111, 32'h00000018, 32'd500, 32'd0, "JALR");

        // Test LUI instruction
        test_instruction(32'b00000000000100000000_00010_0110111, 32'h0000001C, 32'd0, 32'd0, "LUI");

        // Test AUIPC instruction
        test_instruction(32'b00000000000100000000_00010_0010111, 32'h00000020, 32'd0, 32'd0, "AUIPC");

        // Finish simulation
        #10;
        $finish;
    end

endmodule
