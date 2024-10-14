`timescale 1ns/1ps

// Include the Wishbone interface definition
//`include "wishbone.svh"

module uart_wishbone_tb;

    // Define baud rate and calculate bit time
    parameter BAUD_RATE = 9600;
    parameter BIT_TIME = 1_000_000_000 / BAUD_RATE;  // Bit time in nanoseconds
    parameter BIT_TIME_HALF = BIT_TIME / 2; 
    parameter BIT_TIME_10 = BIT_TIME * 10;  // Bit time in nanoseconds
    // Clock and Reset signals
    logic clk;
    logic reset;

    // Instantiate the Wishbone interface
    wishbone_if wishbone_m();

    // UART signals
    logic i_rx;
    logic o_tx;

    // Instantiate the uart_wishbone module
    uart_wishbone uut (
        .clk(clk),
        .reset(reset),
        .wishbone(wishbone_m.slave),
        .i_rx(i_rx),
        .o_tx(o_tx)
    );
    
     // Declare variables at the module level
    integer i;
    logic [7:0] received_data;

    // Clock generation (50 MHz clock)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Clock period = 10 ns
    end

    // Reset generation
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // Test variables
    logic [7:0] tx_data_to_send;
    logic [7:0] rx_data_received;
    logic [31:0] read_data;
    logic [3:0] sr_data;

    // Task to perform Wishbone write operation
    task wishbone_write(input logic [31:0] addr, input logic [31:0] data);
        begin
            @(negedge clk);
            wishbone_m.master.address      <= addr;
            wishbone_m.master.data_in      <= data;
            wishbone_m.master.write_enable <= 1'b1;
            wishbone_m.master.select       <= 4'b1111;  // Assuming 32-bit write
            wishbone_m.master.strobe       <= 1'b1;
            wishbone_m.master.cycle        <= 1'b1;

            // Wait for acknowledge
            @(posedge clk);
            wait (uut.wishbone.ack);

            // Deassert signals
            @(negedge clk);
            wishbone_m.master.strobe       <= 1'b0;
            wishbone_m.master.cycle        <= 1'b0;
            wishbone_m.master.write_enable <= 1'b0;
            wishbone_m.master.address      <= 32'd0;
            wishbone_m.master.data_in      <= 32'd0;
        end
    endtask

    // Task to perform Wishbone read operation
    task wishbone_read(input logic [31:0] addr, output logic [31:0] data);
        begin
            @(negedge clk);
            wishbone_m.master.address      <= addr;
            wishbone_m.master.write_enable <= 1'b0;
            wishbone_m.master.select       <= 4'b1111;  // Assuming 32-bit read
            wishbone_m.master.strobe       <= 1'b1;
            wishbone_m.master.cycle        <= 1'b1;

            // Wait for acknowledge
            @(posedge clk);
            wait (uut.wishbone.ack);

            // Read data
            data = wishbone_m.master.data_out;

            // Deassert signals
            @(negedge clk);
            wishbone_m.master.strobe       <= 1'b0;
            wishbone_m.master.cycle        <= 1'b0;
            wishbone_m.master.address      <= 32'd0;
        end
    endtask

    // UART transmission task (Sending data to i_rx)
    task uart_transmit(input logic [7:0] data);
        integer i;
        begin
            // Start bit
            i_rx = 0;
            #BIT_TIME;  // Assuming baud rate of 9600, bit time ~104.16 us
            // Data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                i_rx = data[i];
                #BIT_TIME;
            end
            // Stop bit
            i_rx = 1;
            #BIT_TIME;
        end
    endtask

    // UART reception monitor (Capturing data from o_tx)
    initial begin
        forever begin
            // Wait for start bit (falling edge)
            @(negedge o_tx);
            // Wait half a bit time to sample in the middle of the bit
            #BIT_TIME_HALF;  // Half of a bit
            received_data = 8'd0;
            // Read data bits
            for (i = 0; i < 8; i = i + 1) begin
                #BIT_TIME;
                received_data[i] = o_tx;
            end
            // Check stop bit (should be high)
            #BIT_TIME;
            if (o_tx !== 1) begin
                $error("UART reception error: Stop bit not detected");
            end else begin
                $display("Received data via UART: 0x%0h", received_data);
            end
        end
    end

    // Test procedure
    initial begin
        // Initialize signals
        i_rx = 1;  // Idle state
        sr_data = 8'd0;

        // Wait for reset deassertion
        @(negedge reset);
        $display("Reset deasserted.");

        // Small delay
        #100;

                wishbone_read(32'h10000008, read_data);
                #100
                sr_data = read_data[3:0];


        // Test UART transmission
        tx_data_to_send = 8'hA5;  // Example data
        $display("Writing data to TDR: 0x%0h", tx_data_to_send);
        wishbone_write(32'h10000000, {24'd0, tx_data_to_send});

        // Wait sufficient time for transmission
        #BIT_TIME_10;  // Adjust based on baud rate and UART implementation

        //$finish;
        // Test UART reception
        $display("Simulating UART reception with data: 0x%0h", 8'h3C);
        fork
            begin
                uart_transmit(8'h3C);
            end
            begin
                // Wait for data to be available in RDR
                // Poll the status register bit for RX Data Ready

                // READ SR
                // Loop until sr_data[0] == 1
                while (sr_data[0] != 1'b1) begin
                    wishbone_read(32'h10000008, read_data);
                    sr_data = read_data[3:0];  // Extract bits [3:0] from read_data
                    #100;  // Wait for 100 time units before checking again
                end
                $display("Data available in RDR.");
                //if (sr_data[0] == 1'b1) begin
                //    $display("Data available in RDR.");
                //end else begin
                //    $display("Data NOT available in RDR.");
                //end
                // Read data from RDR
                wishbone_read(32'h10000004, read_data);
                rx_data_received = read_data[7:0];
                $display("Read data from RDR: 0x%0h", rx_data_received);

                // Verify received data
                if (rx_data_received == 8'h3C) begin
                    $display("UART Reception Successful.");
                end else begin
                    $error("UART Reception Failed: Expected 0x3C, Received 0x%0h", rx_data_received);
                end

                uart_transmit(8'hAA);
                while (sr_data[0] != 1'b1) begin
                    wishbone_read(32'h10000008, read_data);
                    sr_data = read_data[3:0];  // Extract bits [3:0] from read_data
                    #100;  // Wait for 100 time units before checking again
                end
                $display("Data available in RDR But we will not read it to test overflow.");
                uart_transmit(8'hBB);
                #BIT_TIME_10; // wait a long time
                wishbone_read(32'h10000008, read_data);
                sr_data = read_data[3:0];  // Extract bits [3:0] from read_data
                if(sr_data[3] == 1'b1) begin
                    $display("SR shows overflow, this is expected");
                end else begin
                    $display("SR NOT showing overflow, we should have seen it");
                end
                
                wishbone_read(32'h10000004, read_data);
                rx_data_received = read_data[7:0];
                $display("Read data from RDR: 0x%0h expect 0xbb", rx_data_received);

                wishbone_read(32'h10000008, read_data);
                sr_data = read_data[3:0];
                $display("Read data from SR: 0x%0h expect 0x0", sr_data);
            end
        join

        // Finish simulation
        $display("Testbench completed.");
        $finish;
    end

endmodule
