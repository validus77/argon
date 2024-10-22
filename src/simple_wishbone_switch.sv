`timescale 1ns / 1ps

module simple_wishbone_switch(
    wishbone_if.slave wb_lsu,
    wishbone_if.slave wb_if,
    wishbone_if.master wb_ram,
    wishbone_if.master wb_rom,
    wishbone_if.master wb_uart
);

    // Address ranges for the devices
    localparam ROM_START  = 32'h00000000; 
    localparam ROM_END    = 32'h0FFFFFFF;  // ROM 256MB

    localparam RAM_START  = 32'h80000000;
    localparam RAM_END    = 32'hFFFFFFFF;  // RAM 2GB

    localparam UART_START = 32'h10000000;
    localparam UART_END   = 32'h1FFFFFFF;  // Peripherals block

    always_comb begin 
        wb_lsu.ack = 1'b0;
        wb_lsu.data_out = 32'd0;

        wb_if.ack = 1'b0;
        wb_if.data_out = 32'd0;

        // Ram defautls 
        wb_rom.strobe = 1'b0;
        wb_rom.cycle = 1'b0;
        wb_rom.address = 32'd0;
        wb_rom.select = 4'd0;
        wb_rom.write_enable = 1'b0;
        wb_rom.data_in = 32'd0;
        // Rom defautls 
        wb_ram.strobe = 1'b0;
        wb_ram.cycle = 1'b0;
        wb_ram.address = 32'd0;
        wb_ram.select = 4'd0;
        wb_ram.write_enable = 1'b0;
        wb_ram.data_in = 32'd0;
        // Uart defaults
        wb_uart.strobe = 1'b0;
        wb_uart.cycle = 1'b0;
        wb_uart.address = 32'd0;
        wb_uart.select = 4'd0;
        wb_uart.write_enable = 1'b0;
        wb_uart.data_in = 32'd0;


        if(wb_lsu.address >= RAM_START && wb_lsu.address <= RAM_END) begin
            wb_ram.address = wb_lsu.address - RAM_START;
            wb_ram.cycle = wb_lsu.cycle;
            wb_ram.strobe = wb_lsu.strobe;
            wb_ram.write_enable = wb_lsu.write_enable;
            wb_ram.data_in = wb_lsu.data_in;
            wb_ram.select = wb_lsu.select;
            wb_lsu.ack = wb_ram.ack;
            wb_lsu.data_out = wb_ram.data_out;
        end 

        if(wb_lsu.address >= UART_START && wb_lsu.address <= UART_END) begin
            wb_uart.address = wb_lsu.address;
            wb_uart.cycle = wb_lsu.cycle;
            wb_uart.strobe = wb_lsu.strobe;
            wb_uart.write_enable = wb_lsu.write_enable;
            wb_uart.data_in = wb_lsu.data_in;
            wb_uart.select = wb_lsu.select;
            wb_lsu.ack = wb_uart.ack;
            wb_lsu.data_out = wb_uart.data_out;
        end

        // Both IF and LSE may need to read ROM 
        if(wb_lsu.address >= ROM_START && wb_lsu.address <= ROM_END ||
           wb_if.address >= ROM_START && wb_if.address <= ROM_END) begin
            if((wb_lsu.cycle && wb_lsu.strobe) &&
                wb_lsu.address >= ROM_START && wb_lsu.address <= ROM_END) begin
                wb_rom.address = wb_lsu.address;
                wb_rom.cycle = wb_lsu.cycle;
                wb_rom.strobe = wb_lsu.strobe;
                wb_rom.select = wb_lsu.select;
                wb_lsu.ack = wb_rom.ack;
                wb_lsu.data_out = wb_rom.data_out;
            end else if((wb_if.cycle && wb_if.strobe) && 
                         wb_if.address >= ROM_START && wb_if.address <= ROM_END) begin
                wb_rom.address = wb_if.address;
                wb_rom.cycle = wb_if.cycle;
                wb_rom.strobe = wb_if.strobe;
                wb_rom.select = wb_if.select;
                wb_if.ack = wb_rom.ack;
                wb_if.data_out = wb_rom.data_out;
            end
        end
    end
endmodule