//  Common data structure and type definitions for wishbone devices
interface wishbone_if (
    input logic clk,
    input logic rst
);
    // Wishbone signals
    logic cycle;
    logic strobe;
    logic write_enable;
    logic [31:0] address;
    logic [31:0] data_in;
    logic [3:0] select;
    logic ack;
    logic [31:0] data_out;

    // Modports for master and slave
    modport master (
        input ack, data_out,                             
        output cycle, strobe, write_enable, address, data_in, select  
    );

    modport slave (
        input cycle, strobe, write_enable, address, data_in, select,  
        output ack, data_out                                          
    );

    task automatic sim_read(input logic [31:0] addr, 
                            input logic [3:0] sel = 4'b1111, 
                            output logic [31:0] data);
        begin
            @(negedge clk);
            address      <= addr;
            write_enable <= 1'b0;
            select       <= sel;
            strobe       <= 1'b1;
            cycle        <= 1'b1;

            // Wait for acknowledge
            @(posedge clk);
            wait (ack);

            // Read data
            data = data_out;

            // Deassert signals
            @(negedge clk);
            strobe       <= 1'b0;
            cycle        <= 1'b0;
            address      <= 32'd0;
        end
    endtask

    task automatic sim_write(input logic [31:0] addr, 
                             input logic [3:0] sel = 4'b1111,  
                             input logic [31:0] data);
        begin
            @(negedge clk);
            address      <= addr;
            data_in      <= data;
            write_enable <= 1'b1;
            select       <= sel;
            strobe       <= 1'b1;
            cycle        <= 1'b1;

            // Wait for acknowledge
            @(posedge clk);
            wait (ack);

            // Deassert signals
            @(negedge clk);
            strobe       <= 1'b0;
            cycle        <= 1'b0;
            write_enable <= 1'b0;
            address      <= 32'd0;
            data_in      <= 32'd0;
        end
    endtask

endinterface
