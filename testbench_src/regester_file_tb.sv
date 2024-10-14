`timescale 1ns / 1ps

module tb_register_file;  

    parameter CLK_FREQ = 100000000;

    // Clock and reset signals
    reg clk;
    reg rst;

    // register signals
    reg             we;        // Write Enable
    reg      [4:0]  wa;        // Write Address
    reg      [31:0] wd;        // Write Data

    reg      [4:0]  ra1;       // Read Address 1
    wire     [31:0]  rd1;       // Read Data 1

    reg      [4:0]  ra2;       // Read Address 2
    wire     [31:0]  rd2;        // Read Data 2


    // Clock Generation
    initial begin
        clk = 0;
        forever #(5) clk = ~clk; // 100 MHz clock (10 ns period)
    end


   register_file  dut ( 
        .clk(clk),
        .i_write_enable(we),
        .i_write_address(wa),
        .i_write_data(wd),
        .i_read_address_1(ra1),
        .o_read_data_1(rd1),
        .i_read_address_2(ra2),
        .o_read_data_2(rd2)
   );

    task writ_reg(
        input [4:0] address,
        input [31:0] data
    );
        begin
            @(posedge clk);
            wa = address;
            wd = data;
            we = 1'b1;
             @(posedge clk);
            we = 1'b0;
            wa = 1'b0;
            wd = 1'b0;
        end
    endtask

    initial begin
        clk = 0;
        we = 1'b0;
        wa = 5'd0;
        wd = 32'd0;
        ra1 = 5'd0;
        ra2 = 5'd0;
    end

    initial begin
        // Wtire AA or reg 0001
        writ_reg(4'b00001, 32'h000000AA);
        $display("Write 0XAA to reg 00001");
        writ_reg(4'b00010, 32'h000000AB);
        $display("Write 0XAB to reg 00010");
        writ_reg(4'b11111, 32'h00000042);
        $display("Write 0X42 to reg 11111");


        ra1 = 4'b00001;
        ra2 = 4'b00010;
        #1; // Wait for combinational logic to settle
        if(rd1 == 32'h000000AA) begin   
            $display("Reg: 00001 OK: 0x%02X", rd1);
        end else begin
            $display("Reg: 00001 NOK: 0x%02X", rd1);
        end;

        if(rd2 == 32'h000000AB) begin   
             $display("Reg: 00010 OK: 0x%02X", rd2);
        end else begin
            $display("Reg: 00010 NOK: 0x%02X", rd2);
        end;

        ra1 = 4'b11111;
        #1; // Wait for combinational logic to settle
        if(rd1 == 32'h00000042) begin   
            $display("Reg: 11111 OK: 0x%02X", rd1);
        end else begin
            $display("Reg: 11111 NOK: 0x%02X", rd1);
        end;

        // TEST Read from x0 (hardwared to 0)
        ra1 = 4'b000000;
        #1; // Wait for combinational logic to settle
        if(rd1 == 32'h00000000) begin   
            $display("Reg: 00000 OK: 0x%02X", rd1);
        end else begin
            $display("Reg: 00000 NOK: 0x%02X", rd1);
        end;

        // Try to write to x0(hardwared to 0)
        writ_reg(4'b00000, 32'h00000123);
        $display("Write 0X123 to reg 00000 -- should have no effect");
        #1; // Wait for combinational logic to settle
        if(rd1 == 32'h00000000) begin   
            $display("Reg: 00000 OK: 0x%02X", rd1);
        end else begin
            $display("Reg: 00000 NOK: 0x%02X", rd1);
        end;

        // Overrite regester 
        writ_reg(4'b00001, 32'h000000FF);
        $display("Write 0XFF to reg 00001");

        ra1 = 4'b00001;
        #1; // Wait for combinational logic to settle
        if(rd1 == 32'h000000FF) begin   
            $display("Reg: 00001 OK: 0x%02X", rd1);
        end else begin
            $display("Reg: 00001 NOK: 0x%02X", rd1);
        end;




        
        $finish;
    end

endmodule