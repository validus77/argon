`timescale 1ns / 1ps

module wishbone_crossbar_tb;

    // Clock and Reset signals
    logic clk;
    logic reset;

    // Instantiate the Wishbone interfaces
    wishbone_if wb_m0_if();
    wishbone_if wb_m1_if();
    wishbone_if wb_rom_if();
    wishbone_if wb_ram_if();
     wishbone_if wb_uart_if();

    // Declare virtual interfaces
    virtual wishbone_if wb_m0_vif;
    virtual wishbone_if wb_m1_vif;

    // Assign virtual interfaces
    initial begin
        wb_m0_vif = wb_m0_if;
        wb_m1_vif = wb_m1_if;
    end

    // Instantiate the crossbar module
    wishbone_crossbar uut (
        .clk(clk),
        .reset(reset),
        .wb_m0(wb_m0_if.slave),
        .wb_m1(wb_m1_if.slave),
        .wb_rom(wb_rom_if.master),
        .wb_ram(wb_ram_if.master),
        // We can tie off the UART interface since we're not using it
        .wb_uart(wb_uart_if.master)  // Not connected
    );

    // Instantiate the RAM and ROM modules
    rom rom_inst (
        .clk(clk),
        .reset(reset),
        .wishbone(wb_rom_if.slave)
    );

    ram ram_inst (
        .clk(clk),
        .reset(reset),
        .wishbone(wb_ram_if.slave)
    );

    // Clock generation (50 MHz clock)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Clock period = 20 ns
    end

    // Reset generation
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // Test variables
    logic [31:0] read_data_m0;
    logic [31:0] read_data_m1;

    // Test sequence
    initial begin
        // Wait for reset deassertion
        @(negedge reset);
        $display("Reset deasserted.");

        // Small delay
        #20;

        fork
            // Master 0 operations (higher priority)
            begin
                // Read from ROM
                $display("Master 0: Reading from ROM at address 0x00000000");
                wishbone_master_read(wb_m0_vif, 32'h00000000, read_data_m0);
                $display("Master 0: Read data 0x%0h from ROM", read_data_m0);

                // Write to RAM
                $display("Master 0: Writing 0xDEADBEEF to RAM at address 0x80000000");
                wishbone_master_write(wb_m0_vif, 32'h80000000, 32'hDEADBEEF);

                // Read back from RAM
                $display("Master 0: Reading from RAM at address 0x80000000");
                wishbone_master_read(wb_m0_vif, 32'h80000000, read_data_m0);
                $display("Master 0: Read data 0x%0h from RAM", read_data_m0);

                // Verify data
                if (read_data_m0 == 32'hDEADBEEF) begin
                    $display("Master 0: RAM read/write successful.");
                end else begin
                    $error("Master 0: RAM read/write failed.");
                end
            end

            // Master 1 operations (lower priority)
            begin
                // Small delay to allow Master 0 to take priority
                #10;

                // Write to RAM
                $display("Master 1: Writing 0xCAFEBABE to RAM at address 0x80000004");
                wishbone_master_write(wb_m1_vif, 32'h80000012, 32'hCAFEBABE);
                // Read back from RAM
                //$display("Master 1: Reading from RAM at address 0x80000012");
                //wishbone_master_read(wb_m1_vif, 32'h80000012, read_data_m1);
                //$display("Master 1: Read data 0x%0h from RAM", read_data_m1);

                // Verify data (IF never acces RAM, but look at this latter)
                //if (read_data_m1 == 32'hCAFEBABE) begin
               //     $display("Master 1: RAM read/write successful.");
               // end else begin
               //     $error("Master 1: RAM read/write failed.");
               // end

                // Attempt to read from ROM (should be delayed if Master 0 is active)
                //$display("Master 1: Reading from ROM at address 0x00000004");
                //#100;
                //wishbone_master_read(wb_m1_vif, 32'h00000004, read_data_m1);
                // $display("Master 1: Read data 0x%0h from ROM", read_data_m1);
            end
        join

        // Finish simulation
        $display("Testbench completed.");
        $finish;
    end

    // Task to perform Wishbone master read operation
    task wishbone_master_read(
        input virtual wishbone_if wb_if,
        input logic [31:0] addr,
        output logic [31:0] data
    );
        begin
            @(negedge clk);
            wb_if.master.address      <= addr;
            wb_if.master.write_enable <= 1'b0;
            wb_if.master.select       <= 4'b1111;  // Assuming 32-bit read
            wb_if.master.strobe       <= 1'b1;
            wb_if.master.cycle        <= 1'b1;

            // Wait for acknowledge
            wait (wb_if.master.ack == 1'b1);

            // Read data
            data = wb_if.master.data_out;

            // Deassert signals
            @(negedge clk);
            wb_if.master.strobe       <= 1'b0;
            wb_if.master.cycle        <= 1'b0;
            wb_if.master.address      <= 32'd0;
        end
    endtask

    // Task to perform Wishbone master write operation
    task wishbone_master_write(
        input virtual wishbone_if wb_if,
        input logic [31:0] addr,
        input logic [31:0] data
    );
        begin
            @(negedge clk);
            wb_if.master.address      <= addr;
            wb_if.master.data_in      <= data;
            wb_if.master.write_enable <= 1'b1;
            wb_if.master.select       <= 4'b1111;  // Assuming 32-bit write
            wb_if.master.strobe       <= 1'b1;
            wb_if.master.cycle        <= 1'b1;

            // Wait for acknowledge
            wait (wb_if.master.ack == 1'b1);

            // Deassert signals
            @(negedge clk);
            wb_if.master.strobe       <= 1'b0;
            wb_if.master.cycle        <= 1'b0;
            wb_if.master.write_enable <= 1'b0;
            wb_if.master.address      <= 32'd0;
            wb_if.master.data_in      <= 32'd0;
        end
    endtask

endmodule
