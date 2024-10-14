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
    output logic uart_tx
);

    // Internal Signals
    wishbone_if if_wishbone_master(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if lsu_wishbone_master(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if rom_wishbone_slave(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if ram_wishbone_slave(.clk(sys_clk), .rst(~sys_rst_n));
    wishbone_if uart_wishbone_slave(.clk(sys_clk), .rst(~sys_rst_n));

    argon_riscv_cpu cpu(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .if_wishbone_master(if_wishbone_master),
        .lsu_wishbone_master(lsu_wishbone_master)
    );

    rom instruction_memory(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wishbone(rom_wishbone_slave)
    );

    ram data_memory(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wishbone(ram_wishbone_slave)
    );

    uart_wishbone uart(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wishbone(uart_wishbone_slave),
        .i_rx(uart_rx),
        .o_tx(uart_tx)
    );

    wishbone_crossbar xbar_switch(
        .clk(sys_clk),
        .reset(~sys_rst_n),
        .wb_m0(if_wishbone_master),
        .wb_m1(lsu_wishbone_master),
        .wb_rom(rom_wishbone_slave),
        .wb_ram(ram_wishbone_slave),
        .wb_uart(uart_wishbone_slave)
    );

endmodule