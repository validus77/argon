`timescale 1ns / 1ps

module wishbone_crossbar(
    input  logic         clk, 
    input  logic         reset,  
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

    typedef enum logic [1:0] {
        M0_ACTIVE,
        M1_ACTIVE,
        NONE_ACTIVE
    } active_mastere_t;

    typedef enum logic [1:0] {
        IDLE,
        BUSY,
        PULSE_ACK
    } device_state_t;

    active_mastere_t rom_active_master;
    active_mastere_t ram_active_master;
    active_mastere_t uart_active_master;

    device_state_t ram_state;
    device_state_t rom_state;
    device_state_t uart_state;

    always_ff @(posedge clk) begin
     if(reset) begin
        // Master defaults
        wb_m0.ack <= 1'b0;
        wb_m0.data_out <= 32'd0;
        wb_m1.ack <= 1'b0;
        wb_m1.data_out <= 32'd0;
        // Rom defaults 
        wb_rom.strobe <= 1'b0;
        wb_rom.cycle <= 1'b0;
        wb_rom.address <= 32'd0;
        wb_rom.select <= 4'd0;
        wb_rom.write_enable <= 1'b0;
        wb_rom.data_in <= 32'd0;
        // Ram defautls 
        wb_ram.strobe <= 1'b0;
        wb_ram.cycle <= 1'b0;
        wb_ram.address <= 32'd0;
        wb_ram.select <= 4'd0;
        wb_ram.write_enable <= 1'b0;
        wb_ram.data_in <= 32'd0;
        // Uart defaults
        wb_uart.strobe <= 1'b0;
        wb_uart.cycle <= 1'b0;
        wb_uart.address <= 32'd0;
        wb_uart.select <= 4'd0;
        wb_uart.write_enable <= 1'b0;
        wb_uart.data_in <= 32'd0;

        ram_state <= IDLE;
        rom_state <= IDLE;
        uart_state <= IDLE;

        rom_active_master <= NONE_ACTIVE;
        ram_active_master <= NONE_ACTIVE;
        uart_active_master <= NONE_ACTIVE;
     end else begin


        if(wb_m0.cycle && wb_m0.strobe && wb_m0.address >= ROM_START && wb_m0.address <= ROM_END) begin
            rom_active_master <= M0_ACTIVE;
        end else if (wb_m1.cycle && wb_m1.strobe && wb_m1.address >= ROM_START && wb_m1.address <= ROM_END) begin
            rom_active_master <= M1_ACTIVE;
        end

        // RAM arbitration (Master 0 has priority)
        if(wb_m0.cycle && wb_m0.strobe && wb_m0.address >= RAM_START && wb_m0.address <= RAM_END) begin
            ram_active_master <= M0_ACTIVE;
        end else if (wb_m1.cycle && wb_m1.strobe && wb_m1.address >= RAM_START && wb_m1.address <= RAM_END) begin
            ram_active_master <= M1_ACTIVE;
        end

        // UART arbitration (Master 0 has priority)
        if(wb_m0.cycle && wb_m0.strobe && wb_m0.address >= UART_START && wb_m0.address <= UART_END) begin
            uart_active_master <= M0_ACTIVE;
        end else if (wb_m1.cycle && wb_m1.strobe && wb_m1.address >= UART_START && wb_m1.address <= UART_END) begin
            uart_active_master <= M1_ACTIVE;
        end

        // Rom switch
        case(rom_state)
            IDLE: begin
                if(rom_active_master == M0_ACTIVE) begin
                    wb_rom.address <= wb_m0.address;
                    wb_rom.cycle <= wb_m0.cycle;
                    wb_rom.strobe <= wb_m0.strobe;
                    wb_rom.write_enable <= wb_m0.write_enable;
                    wb_rom.data_in <= wb_m0.data_in;
                    wb_rom.select <= wb_m0.select;
                    rom_state <= BUSY;
                end else if (rom_active_master == M1_ACTIVE) begin
                    wb_rom.address <= wb_m1.address;
                    wb_rom.cycle <= wb_m1.cycle;
                    wb_rom.strobe <= wb_m1.strobe;
                    wb_rom.write_enable <= wb_m1.write_enable;
                    wb_rom.data_in <= wb_m1.data_in;
                    wb_rom.select <= wb_m1.select;
                    rom_state <= BUSY;
                end
            end
            BUSY: begin
                if(wb_rom.ack) begin 
                    if(rom_active_master == M0_ACTIVE) begin
                        wb_m0.ack <= 1'b1;
                        wb_m0.data_out <= wb_rom.data_out;
                    end else if (rom_active_master == M1_ACTIVE) begin
                        wb_m1.ack <= 1'b1;
                        wb_m1.data_out <= wb_rom.data_out;
                    end
                    rom_state <= PULSE_ACK;
                end
            end
            PULSE_ACK: begin
                if(rom_active_master == M0_ACTIVE) begin
                        wb_m0.ack <= 1'b0;
                        wb_m0.data_out <= wb_rom.data_out;
                end else if (rom_active_master == M1_ACTIVE) begin
                        wb_m1.ack <= 1'b0;
                        wb_m1.data_out <= wb_rom.data_out;
                end
                rom_active_master <= NONE_ACTIVE;
                rom_state <= IDLE;
            end
        endcase

         // Ram switch
        case(ram_state)
            IDLE: begin
                if(ram_active_master == M0_ACTIVE) begin
                    wb_ram.address <= wb_m0.address - RAM_START;
                    wb_ram.cycle <= wb_m0.cycle;
                    wb_ram.strobe <= wb_m0.strobe;
                    wb_ram.write_enable <= wb_m0.write_enable;
                    wb_ram.data_in <= wb_m0.data_in;
                    wb_ram.select <= wb_m0.select;
                    ram_state <= BUSY;
                end else if (ram_active_master == M1_ACTIVE) begin
                    wb_ram.address <= wb_m1.address - RAM_START;
                    wb_ram.cycle <= wb_m1.cycle;
                    wb_ram.strobe <= wb_m1.strobe;
                    wb_ram.write_enable <= wb_m1.write_enable;
                    wb_ram.data_in <= wb_m1.data_in;
                    wb_ram.select <= wb_m1.select;
                    ram_state <= BUSY;
                end
            end
            BUSY: begin
                if(wb_ram.ack) begin 
                    if(ram_active_master == M0_ACTIVE) begin
                        wb_m0.ack <= 1'b1;
                        wb_m0.data_out = wb_ram.data_out;
                    end else if (ram_active_master == M1_ACTIVE) begin
                        wb_m1.ack <= 1'b1;
                        wb_m1.data_out = wb_ram.data_out;
                    end
                    ram_state <= PULSE_ACK;
                end
            end
            PULSE_ACK: begin
                if(ram_active_master == M0_ACTIVE) begin
                        wb_m0.ack <= 1'b0;
                end else if (ram_active_master == M1_ACTIVE) begin
                        wb_m1.ack <= 1'b0;
                end
                ram_active_master <= NONE_ACTIVE;
                ram_state <= IDLE;
            end
        endcase

        // Uart switch
        case(uart_state)
            IDLE: begin
                if(uart_active_master == M0_ACTIVE) begin
                    wb_uart.address <= wb_m0.address;
                    wb_uart.cycle <= wb_m0.cycle;
                    wb_uart.strobe <= wb_m0.strobe;
                    wb_uart.write_enable <= wb_m0.write_enable;
                    wb_uart.data_in <= wb_m0.data_in;
                    wb_uart.select <= wb_m0.select;
                    uart_state <= BUSY;
                end else if (uart_active_master == M1_ACTIVE) begin
                    wb_uart.address <= wb_m1.address;
                    wb_uart.cycle <= wb_m1.cycle;
                    wb_uart.strobe <= wb_m1.strobe;
                    wb_uart.write_enable <= wb_m1.write_enable;
                    wb_uart.data_in <= wb_m1.data_in;
                    wb_uart.select <= wb_m1.select;
                    uart_state <= BUSY;
                end
            end
            BUSY: begin
                if(wb_uart.ack) begin 
                    if(uart_active_master == M0_ACTIVE) begin
                        wb_m0.ack <= 1'b1;
                        wb_m0.data_out = wb_uart.data_out;
                    end else if (uart_active_master == M1_ACTIVE) begin
                        wb_m1.ack <= 1'b1;
                        wb_m1.data_out <= wb_uart.data_out;
                    end
                    uart_state <= PULSE_ACK;
                end
            end
            PULSE_ACK: begin
                if(uart_active_master == M0_ACTIVE) begin
                        wb_m0.ack <= 1'b0;
                end else if (uart_active_master == M1_ACTIVE) begin
                        wb_m1.ack <= 1'b0;
                end
                uart_active_master <= NONE_ACTIVE;
                uart_state <= IDLE;
            end
        endcase

     end
    end
endmodule
