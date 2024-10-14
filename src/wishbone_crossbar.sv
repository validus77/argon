`timescale 1ns / 1ps

module wishbone_crossbar(
    input logic clk,
    input logic reset, 

    // Master 0 -- CPU IF, (the XBAR acts as slave to Master 0)
    wishbone_if.slave wb_m0,
    // Master 1 -- CPU LSU, (the XBAR acts as slave to Master 1)
    wishbone_if.slave wb_m1,
    // Slave 1 -- Instruction Memory (ROM), (the XBAR acts as master to Instruction Memory)
    wishbone_if.master wb_rom,
    // Slave 2 -- Data Memory (RAM), (the XBAR acts as master to Data Memory)
    wishbone_if.master wb_ram,
    // Slave 3 -- UART, (the XBAR acts as master to UART)
    wishbone_if.master wb_uart
);

    // Address ranges for the devices
    localparam ROM_START  = 32'h00000000;
    localparam ROM_END    = 32'h0FFFFFFF;  // ROM 256MB

    localparam RAM_START  = 32'h80000000;
    localparam RAM_END    = 32'hFFFFFFFF;  // RAM 2GB

    localparam UART_START = 32'h10000000;
    localparam UART_END   = 32'h1FFFFFFF;  // Peripherals block

    logic active_master;  // Track which master has the bus

    // Arbitration logic: give Master 0 (IF) priority over Master 1 (LSU)
    always_comb begin 
        if(wb_m0.cycle && wb_m0.strobe) begin
            active_master = 1'b0;  // Master 0 has priority
        end else if (wb_m1.cycle && wb_m1.strobe) begin
            active_master = 1'b1;  // Master 1 if Master 0 is not active
        end else begin
            active_master = 1'bx;  // No active master
        end
    end

    always_comb begin
        // Default assignments (no slave selected)
        wb_rom.strobe = 1'b0;
        wb_rom.cycle = 1'b0;
        wb_rom.address = 32'd0;
        wb_rom.select = 4'd0;
        wb_rom.write_enable = 1'b0;
        wb_rom.data_in = 32'd0;

        wb_ram.strobe = 1'b0;
        wb_ram.cycle = 1'b0;
        wb_ram.address = 32'd0;
        wb_ram.select = 4'd0;
        wb_ram.write_enable = 1'b0;
        wb_ram.data_in = 32'd0;

        wb_uart.strobe = 1'b0;
        wb_uart.cycle = 1'b0;
        wb_uart.address = 32'd0;
        wb_uart.select = 4'd0;
        wb_uart.write_enable = 1'b0;
        wb_uart.data_in = 32'd0;

        wb_m0.ack = 1'b0;
        wb_m0.data_out = 32'd0;

        wb_m1.ack = 1'b0;
        wb_m1.data_out = 32'd0;

        if(active_master == 1'b0) begin
            // Handle Master 0 requests
            if (wb_m0.address >= ROM_START && wb_m0.address <= ROM_END) begin
                // Access ROM
                wb_rom.address = wb_m0.address;
                wb_rom.cycle = wb_m0.cycle;
                wb_rom.strobe = wb_m0.strobe;
                wb_rom.write_enable = wb_m0.write_enable;
                wb_rom.data_in = wb_m0.data_in;
                wb_rom.select = wb_m0.select;
                if (wb_rom.ack) begin
                    wb_m0.ack = 1'b1;
                    wb_m0.data_out = wb_rom.data_out;
                end
            end else if (wb_m0.address >= RAM_START && wb_m0.address <= RAM_END) begin
                // Access RAM
                wb_ram.address = wb_m0.address - RAM_START; // Adjust if necessary
                wb_ram.cycle = wb_m0.cycle;
                wb_ram.strobe = wb_m0.strobe;
                wb_ram.write_enable = wb_m0.write_enable;
                wb_ram.data_in = wb_m0.data_in;
                wb_ram.select = wb_m0.select;
                if (wb_ram.ack) begin
                    wb_m0.ack = 1'b1;
                    wb_m0.data_out = wb_ram.data_out;
                end 
            end else if (wb_m0.address >= UART_START && wb_m0.address <= UART_END) begin
                // Access UART
                wb_uart.address = wb_m0.address;
                wb_uart.cycle = wb_m0.cycle;
                wb_uart.strobe = wb_m0.strobe;
                wb_uart.write_enable = wb_m0.write_enable;
                wb_uart.data_in = wb_m0.data_in;
                wb_uart.select = wb_m0.select;
                if (wb_uart.ack) begin
                    wb_m0.ack = 1'b1;
                    wb_m0.data_out = wb_uart.data_out;
                end 
            end
        end else if (active_master == 1'b1) begin
            // Handle Master 1 requests
            if (wb_m1.address >= ROM_START && wb_m1.address <= ROM_END) begin
                // Access ROM
                wb_rom.address = wb_m1.address;
                wb_rom.cycle = wb_m1.cycle;
                wb_rom.strobe = wb_m1.strobe;
                wb_rom.write_enable = wb_m1.write_enable;
                wb_rom.data_in = wb_m1.data_in;
                wb_rom.select = wb_m1.select;
                if (wb_rom.ack) begin
                    wb_m1.ack = 1'b1;
                    wb_m1.data_out = wb_rom.data_out;
                end
            end else if (wb_m1.address >= RAM_START && wb_m1.address <= RAM_END) begin
                // Access RAM
                wb_ram.address = wb_m1.address - RAM_START;
                wb_ram.cycle = wb_m1.cycle;
                wb_ram.strobe = wb_m1.strobe;
                wb_ram.write_enable = wb_m1.write_enable;
                wb_ram.data_in = wb_m1.data_in;
                wb_ram.select = wb_m1.select;
                if (wb_ram.ack) begin
                    wb_m1.ack = 1'b1;
                    wb_m1.data_out = wb_ram.data_out;
                end 
            end else if (wb_m1.address >= UART_START && wb_m1.address <= UART_END) begin
                // Access UART
                wb_uart.address = wb_m1.address;
                wb_uart.cycle = wb_m1.cycle;
                wb_uart.strobe = wb_m1.strobe;
                wb_uart.write_enable = wb_m1.write_enable;
                wb_uart.data_in = wb_m1.data_in;
                wb_uart.select = wb_m1.select;
                if (wb_uart.ack) begin
                    wb_m1.ack = 1'b1;
                    wb_m1.data_out = wb_uart.data_out;
                end 
            end
        end
    end

endmodule
