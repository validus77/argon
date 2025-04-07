`timescale 1ns / 1ps
`include "wishbone.svh"

/* This is the TOP file for the Argon SoC 
   This includes the CPU, ROM, RAM, and Wishbone CrossBar Switch
*/

module argon_soc (
    input logic sysclk_50,
    input logic sys_rst_n,
    // UART signals
    input logic uart_rx,
    output logic uart_tx
);

    // Internal Signals
    wishbone_if if_wishbone(.clk(sysclk_50), .rst(~sys_rst_n));
    wishbone_if lsu_wishbone(.clk(sysclk_50), .rst(~sys_rst_n));
    wishbone_if rom_wishbone(.clk(sysclk_50), .rst(~sys_rst_n));
    wishbone_if ram_wishbone(.clk(sysclk_50), .rst(~sys_rst_n));
    wishbone_if uart_wishbone(.clk(sysclk_50), .rst(~sys_rst_n));

    argon_riscv_cpu cpu(
        .clk(sysclk_50),
        .reset(~sys_rst_n),
        .if_wishbone_master(if_wishbone.master),
        .lsu_wishbone_master(lsu_wishbone.master)
    );

    rom instruction_memory(
        .clk(sysclk_50),
        .reset(~sys_rst_n),
        .wishbone(rom_wishbone.slave)
    );

    ram data_memory(
        .clk(sysclk_50),
        .reset(~sys_rst_n),
        .wishbone(ram_wishbone.slave)
    );

    uart_wishbone uart(
        .clk(sysclk_50),
        .reset(~sys_rst_n),
        .wishbone(uart_wishbone.slave),
        .i_rx(uart_rx),
        .o_tx(uart_tx)
    );

    //wishbone_crossbar wishbone_switch(
    //    .clk(sys_clk),
    //    .reset(~sys_rst_n),
    //    .wb_m0(if_wishbone.slave),
    //    .wb_m1(lsu_wishbone.slave),
    //    .wb_rom(rom_wishbone.master),
    //    .wb_ram(ram_wishbone.master),
    //    .wb_uart(uart_wishbone.master)
    //);
    
    simple_wishbone_switch wishbone_switch (
        .wb_lsu(lsu_wishbone.slave),
        .wb_if(if_wishbone.slave),
        .wb_ram(ram_wishbone.master),
        .wb_rom(rom_wishbone.master),
        .wb_uart(uart_wishbone.master)
    );

endmodule