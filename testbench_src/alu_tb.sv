`timescale 1ns / 1ps

module tb_alu;

    // register signals
    reg [31:0] op1;
    reg [31:0] op2;
    reg [3:0] opcode;
    wire [31:0] result;

    alu dut ( 
        .i_op1(op1),
        .i_op2(op2),
        .i_alu_op(opcode),
        .o_result(result)
    );

    initial begin
        // Test ADD
        $display("test ADD");
        opcode <= 4'b0000; // ADD
        op1 <= 31'd10;
        op2 <= 31'd5;
        #1;
        if(result == 32'd15) begin
            $display("ADD OK: 10 + 5 = 0x%02X", result);
        end else begin
            $display("ADD NOK: 10 + 5 = 0x%02X", result);
        end

        // Test SUB
        $display("test SUB");
        opcode <= 4'b1000; // SUB
        op1 <= 31'd10;
        op2 <= 31'd5;
        #1;
        if(result == 32'd5) begin
            $display("SUB OK: 10 - 5 = 0x%02X", result);
        end else begin
            $display("SUB NOK: 10 - 5 = 0x%02X", result);
        end

        // Test SLL
        $display("test SLL");
        opcode <= 4'b0001; // SLL
        op1 <= 31'd2;
        op2 <= 31'd3;
        #1;
        if(result == 32'd16) begin
            $display("SLL OK: 2 << 3 = 0x%02X", result);
        end else begin
            $display("SLL NOK: 2 << 3 = 0x%02X", result);
        end

        // Test SLT
        $display("test SLT");
        opcode <= 4'b0010; // SLT
        op1 <= 31'd5;
        op2 <= 31'd10;
        #1;
        if(result == 32'd1) begin
            $display("SLT OK: 5 < 10 = 0x%02X", result);
        end else begin
            $display("SLT NOK: 5 < 10 = 0x%02X", result);
        end

        // Test SLTU
        $display("test SLTU");
        opcode <= 4'b0011; // SLTU
        op1 <= 32'd5;
        op2 <= 32'd10;
        #1;
        if(result == 32'd1) begin
            $display("SLTU OK: 5 < 10 (unsigned) = 0x%02X", result);
        end else begin
            $display("SLTU NOK: 5 < 10 (unsigned) = 0x%02X", result);
        end

        // Test XOR
        $display("test XOR");
        opcode <= 4'b0100; // XOR
        op1 <= 32'hF0F0F0F0;
        op2 <= 32'h0F0F0F0F;
        #1;
        if(result == 32'hFFFFFFFF) begin
            $display("XOR OK: F0F0F0F0 ^ 0F0F0F0F = 0x%02X", result);
        end else begin
            $display("XOR NOK: F0F0F0F0 ^ 0F0F0F0F = 0x%02X", result);
        end

        // Test SRL
        $display("test SRL");
        opcode <= 4'b0101; // SRL
        op1 <= 32'd16;
        op2 <= 32'd3;
        #1;
        if(result == 32'd2) begin
            $display("SRL OK: 16 >> 3 = 0x%02X", result);
        end else begin
            $display("SRL NOK: 16 >> 3 = 0x%02X", result);
        end

        // Test SRA
        $display("test SRA");
        opcode <= 4'b1010; // SRA
        op1 <= -32'd16;
        op2 <= 32'd2;
        #1;
        if(result == -32'd4) begin
            $display("SRA OK: -16 >>> 2 = 0x%02X", result);
        end else begin
            $display("SRA NOK: -16 >>> 2 = 0x%02X", result);
        end

        // Test OR
        $display("test OR");
        opcode <= 4'b0110; // OR
        op1 <= 32'hF0F0F0F0;
        op2 <= 32'h0F0F0F0F;
        #1;
        if(result == 32'hFFFFFFFF) begin
            $display("OR OK: F0F0F0F0 | 0F0F0F0F = 0x%02X", result);
        end else begin
            $display("OR NOK: F0F0F0F0 | 0F0F0F0F = 0x%02X", result);
        end

        // Test AND
        $display("test AND");
        opcode <= 4'b0111; // AND
        op1 <= 32'hF0F0F0F0;
        op2 <= 32'h0F0F0F0F;
        #1;
        if(result == 32'h00000000) begin
            $display("AND OK: F0F0F0F0 & 0F0F0F0F = 0x%02X", result);
        end else begin
            $display("AND NOK: F0F0F0F0 & 0F0F0F0F = 0x%02X", result);
        end

        $finish;
    end

endmodule
