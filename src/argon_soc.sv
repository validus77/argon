`timescale 1ns / 1ps
`include "wishbone.svh"

/* This is the TOP file for the Argon SoC 
   This includes the CPU, ROM, RAM, and Wishbone CrossBar Switch
*/

module argon_soc (
    input logic sys_clk,
    input logic sys_rst_n,
    // UART signals
    input logic uart_rx,
    output logic uart_tx,
    //debuging
    output logic [1:0] leds,
    output logic [7:0] pmod_a
);

    // Internal Signals
    wishbone_if if_wishbone(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if lsu_wishbone(.clk(sys_clk), .rst(~sys_rst_n));
    //wishbone_if rom_wishbone_slave(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if ram_wishbone(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if uart_wishbone(.clk(sys_clk), .rst(~sys_rst_n));

    argon_riscv_cpu cpu(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .if_wishbone_master(if_wishbone.master),
        .lsu_wishbone_master(lsu_wishbone.master),
        .debug_leds(pmod_a)
    );

    rom instruction_memory(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wishbone(if_wishbone.slave)
    );

    ram data_memory(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wishbone(ram_wishbone.slave)
    );

    uart_wishbone uart(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wishbone(uart_wishbone.slave),
        .i_rx(uart_rx),
        .o_tx(uart_tx)
    );

    //wishbone_crossbar wishbone_switch(
    //    .clk(sys_clk),
    //    .reset(~sys_rst_n),
    //    .wb_m0(if_wishbone_master.slave),
    //    .wb_m1(lsu_wishbone_master.slave),
    //    .wb_rom(rom_wishbone_slave.master),
    //    .wb_ram(ram_wishbone_slave.master),
    //    .wb_uart(uart_wishbone_slave.master)
    //);
    
    simple_wishbone_switch wishbone_switch (
        .wb_m(lsu_wishbone.slave),
        .wb_ram(ram_wishbone.master),
        .wb_uart(uart_wishbone.master)
    );
    
    always_comb begin
        leds = 2'b11;
        leds[0] = ~if_wishbone.ack;
        leds[1] = ~uart_wishbone.ack;
    end
endmodule