`timescale 1ns / 1ps

module simple_wishbone_switch(
    wishbone_if.slave wb_m,
    wishbone_if.master wb_ram,
    wishbone_if.master wb_uart
);

    // Address ranges for the devices
    localparam ROM_START  = 32'h00000000; 
    localparam ROM_END    = 32'h0FFFFFFF;  // ROM 256MB
    // ROM not used but keeping the comemnt for reffrance 

    localparam RAM_START  = 32'h80000000;
    localparam RAM_END    = 32'hFFFFFFFF;  // RAM 2GB

    localparam UART_START = 32'h10000000;
    localparam UART_END   = 32'h1FFFFFFF;  // Peripherals block

    always_comb begin 
        wb_m.ack <= 1'b0;
        wb_m.data_out <= 32'd0;

        // Ram defautls 
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


        if(wb_m.address >= RAM_START && wb_m.address <= RAM_END) begin
            wb_ram.address = wb_m.address - RAM_START;
            wb_ram.cycle = wb_m.cycle;
            wb_ram.strobe = wb_m.strobe;
            wb_ram.write_enable = wb_m.write_enable;
            wb_ram.data_in = wb_m.data_in;
            wb_ram.select = wb_m.select;
            wb_m.ack = wb_ram.ack;
            wb_m.data_out = wb_ram.data_out;
        end 

        if(wb_m.address >= UART_START && wb_m.address <= UART_END) begin
            wb_uart.address = wb_m.address;
            wb_uart.cycle = wb_m.cycle;
            wb_uart.strobe = wb_m.strobe;
            wb_uart.write_enable = wb_m.write_enable;
            wb_uart.data_in = wb_m.data_in;
            wb_uart.select = wb_m.select;
            wb_m.ack = wb_uart.ack;
            wb_m.data_out = wb_uart.data_out;
        end 
    end
endmodule