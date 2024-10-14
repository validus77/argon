`timescale 1ns / 1ps

module execution_tb;

    // Inputs to the DUT
    logic [31:0] i_alu_op1;
    logic [31:0] i_alu_op2;
    alu_opcode_t i_alu_opcode;
    logic [4:0]  i_rd_id;

    logic        i_is_reg_write;
    logic        i_is_load;
    logic        i_is_store;
    logic        i_is_jump;
    logic [31:0] i_jump_address;
    logic        i_is_branch;
    logic [2:0]  i_branch_type;
    logic [31:0] i_store_data;

    // Outputs from the DUT
    logic        o_branch_enable;
    logic [31:0] o_branch_address;

    logic        o_is_reg_write;
    logic        o_is_mem_read;
    logic        o_is_mem_write;
    logic [31:0] o_mem_address;
    logic [4:0]  o_rd_id;
    logic [31:0] o_mem_data;
    logic [31:0] o_reg_data;

    // Instantiate the DUT
    execution dut (
        .i_alu_opcode(i_alu_opcode),
        .i_alu_op1(i_alu_op1),
        .i_alu_op2(i_alu_op2),
        .i_rd_id(i_rd_id),
        .i_is_reg_write(i_is_reg_write),
        .i_is_load(i_is_load),
        .i_is_store(i_is_store),
        .i_is_jump(i_is_jump),
        .i_jump_address(i_jump_address),
        .i_is_branch(i_is_branch),
        .i_branch_type(i_branch_type),
        .i_store_data(i_store_data),
        .o_branch_enable(o_branch_enable),
        .o_branch_address(o_branch_address),
        .o_is_reg_write(o_is_reg_write),
        .o_is_mem_read(o_is_mem_read),
        .o_is_mem_write(o_is_mem_write),
        .o_mem_address(o_mem_address),
        .o_rd_id(o_rd_id),
        .o_mem_data(o_mem_data),
        .o_reg_data(o_reg_data)
    );

    // Task to reset all inputs
    task reset_inputs();
        begin
            i_alu_op1       = 32'd0;
            i_alu_op2       = 32'd0;
            i_alu_opcode    = ALU_ADD;
            i_rd_id         = 5'd0;

            i_is_reg_write  = 1'b0;
            i_is_load       = 1'b0;
            i_is_store      = 1'b0;
            i_is_jump       = 1'b0;
            i_jump_address  = 32'd0;
            i_is_branch     = 1'b0;
            i_branch_type   = 3'd0;
            i_store_data    = 32'd0;
        end
    endtask

    // Task to display outputs
    task display_outputs(string test_name);
        begin
            $display("---- %s ----", test_name);
            $display("i_alu_op1      = %d", i_alu_op1);
            $display("i_alu_op2      = %d", i_alu_op2);
            $display("i_alu_opcode   = %0d", i_alu_opcode);
            $display("i_rd_id        = %0d", i_rd_id);
            $display("i_is_reg_write = %b", i_is_reg_write);
            $display("i_is_load      = %b", i_is_load);
            $display("i_is_store     = %b", i_is_store);
            $display("i_is_jump      = %b", i_is_jump);
            $display("i_jump_address = %h", i_jump_address);
            $display("i_is_branch    = %b", i_is_branch);
            $display("i_branch_type  = %b", i_branch_type);
            $display("i_store_data   = %d", i_store_data);
            $display("Outputs:");
            $display("o_branch_enable  = %b", o_branch_enable);
            $display("o_branch_address = %h", o_branch_address);
            $display("o_is_reg_write   = %b", o_is_reg_write);
            $display("o_is_mem_read    = %b", o_is_mem_read);
            $display("o_is_mem_write   = %b", o_is_mem_write);
            $display("o_mem_address    = %h", o_mem_address);
            $display("o_rd_id          = %0d", o_rd_id);
            $display("o_mem_data       = %d", o_mem_data);
            $display("o_reg_data       = %d", o_reg_data);
            $display("------------------------------\n");
        end
    endtask

    // Main test sequence
    initial begin
        // Initialize inputs
        reset_inputs();
        #10;

        // Test ALU ADD operation
        reset_inputs();
        i_alu_op1       = 32'd10;
        i_alu_op2       = 32'd15;
        i_alu_opcode    = ALU_ADD;
        i_rd_id         = 5'd1;
        i_is_reg_write  = 1'b1;
        #1;
        display_outputs("ALU ADD Operation");

        // Test ALU SUB operation
        reset_inputs();
        i_alu_op1       = 32'd20;
        i_alu_op2       = 32'd5;
        i_alu_opcode    = ALU_SUB;
        i_rd_id         = 5'd2;
        i_is_reg_write  = 1'b1;
        #1;
        display_outputs("ALU SUB Operation");

        // Test BEQ Branch Taken (rs1 == rs2)
        reset_inputs();
        i_alu_op1       = 32'd100;
        i_alu_op2       = 32'd100;
        i_alu_opcode    = ALU_SUB;
        i_is_branch     = 1'b1;
        i_branch_type   = 3'b000; // BEQ
        i_jump_address  = 32'h00001000;
        #1;
        display_outputs("BEQ Branch Taken");

        // Test BEQ Branch Not Taken (rs1 != rs2)
        reset_inputs();
        i_alu_op1       = 32'd100;
        i_alu_op2       = 32'd50;
        i_alu_opcode    = ALU_SUB;
        i_is_branch     = 1'b1;
        i_branch_type   = 3'b000; // BEQ
        i_jump_address  = 32'h00001000;
        #1;
        display_outputs("BEQ Branch Not Taken");

        // Test BNE Branch Taken (rs1 != rs2)
        reset_inputs();
        i_alu_op1       = 32'd100;
        i_alu_op2       = 32'd50;
        i_alu_opcode    = ALU_SUB;
        i_is_branch     = 1'b1;
        i_branch_type   = 3'b001; // BNE
        i_jump_address  = 32'h00002000;
        #1;
        display_outputs("BNE Branch Taken");

        // Test BLT Branch Taken (rs1 < rs2)
        reset_inputs();
        i_alu_op1       = 32'd10;
        i_alu_op2       = 32'd20;
        i_alu_opcode    = ALU_SUB;
        i_is_branch     = 1'b1;
        i_branch_type   = 3'b100; // BLT
        i_jump_address  = 32'h00003000;
        #1;
        display_outputs("BLT Branch Taken");

        // Test BGE Branch Not Taken (rs1 < rs2)
        reset_inputs();
        i_alu_op1       = 32'd10;
        i_alu_op2       = 32'd20;
        i_alu_opcode    = ALU_SUB;
        i_is_branch     = 1'b1;
        i_branch_type   = 3'b101; // BGE
        i_jump_address  = 32'h00004000;
        #1;
        display_outputs("BGE Branch Not Taken");

        // Test Jump Instruction (JAL)
        reset_inputs();
        i_is_jump       = 1'b1;
        i_jump_address  = 32'h00005000;
        i_rd_id         = 5'd3;
        i_is_reg_write  = 1'b1;
        i_alu_op1       = 32'd100; // PC
        i_alu_op2       = 32'd4;
        i_alu_opcode    = ALU_ADD;
        #1;
        display_outputs("Jump Instruction (JAL)");

        // Test Load Operation (LW)
        reset_inputs();
        i_alu_op1       = 32'd1000; // Base address
        i_alu_op2       = 32'd20;   // Offset
        i_alu_opcode    = ALU_ADD;
        i_is_load       = 1'b1;
        i_is_reg_write  = 1'b1;
        i_rd_id         = 5'd4;
        #1;
        display_outputs("Load Operation (LW)");

        // Test Store Operation (SW)
        reset_inputs();
        i_alu_op1       = 32'd2000; // Base address
        i_alu_op2       = 32'd30;   // Offset
        i_alu_opcode    = ALU_ADD;
        i_is_store      = 1'b1;
        i_store_data    = 32'd12345;
        #1;
        display_outputs("Store Operation (SW)");

        // Finish simulation
        #10;
        $finish;
    end

endmodule
