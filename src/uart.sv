`timescale 1ns / 1ps

module uart_rx(
    input logic          clk,
    input logic          reset,
    input logic          i_rx,
    output logic         o_valid,
    output logic[7:0]    o_data,
    output logic         o_error
    );
    
    localparam CLK_FREQ = 50000000;
    localparam BAUD_RATE = 9600;
    localparam integer CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    typedef enum logic [1:0] {
        IDLE,      // 2'b00
        START,     // 2'b01
        DATA_RX,   // 2'b10
        STOP       // 2'b11
    } state_t;
    
    state_t state;
    logic [2:0] bit_index;
    logic [15:0] counter;
    logic rx_sync_temp, rx_synced;
    
    // Synchronize the i_rx signal
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_sync_temp <= 1'b1;
            rx_synced <= 1'b1;
        end else begin
            rx_sync_temp <= i_rx;
            rx_synced <= rx_sync_temp;
        end
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            counter <= 16'd0;
            bit_index <= 3'd0;
            o_valid <= 1'b0;
            o_error <= 1'b0;
            o_data <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    o_valid <= 1'b0;
                    o_error <= 1'b0;
                    if (rx_synced == 1'b0) begin
                         state <= START;
                         counter <= 16'd0;
                    end
                end

                START: begin
                    if (counter == (CYCLES_PER_BIT / 2) - 1) begin  // 1/2 way in to bit
                        if (rx_synced == 1'b0) begin
                            counter <= 16'd0; // reset counter
                            bit_index <= 3'd0; // zero the index 
                            state <= DATA_RX;  // start receving data 
                        end else begin
                            state <= IDLE; // False start bit
                        end
                    end else begin
                        counter++;
                    end  
                end

                DATA_RX: begin 
                    if (counter == CYCLES_PER_BIT - 1) begin // sample the bit
                        counter <= 16'd0; // reset counter
                        o_data[bit_index] <= rx_synced;
                        if (bit_index == 3'd7) begin
                            state <= STOP; // we haev gotten 8 bits so time to stop
                        end else begin
                            bit_index++;  // start the next bit
                        end
                    end else begin
                        counter++;
                    end
                end

                STOP: begin
                    if (counter == CYCLES_PER_BIT - 1) begin
                        counter <= 16'd0;
                         if (rx_synced == 1'b1) begin
                            o_valid <= 1'b1;
                         end else begin
                           o_error <= 1'b1;// Framing error
                           o_data <= 8'd0; // clear data on error
                         end
                         state <= IDLE; 
                    end else begin
                        counter++;
                    end
                end

                default: begin
                    state <= IDLE;
                end 
            endcase
        end
    end 
    
endmodule

module uart_tx (
    input  logic         clk, 
    input  logic         reset, 
    input  logic         i_valid,
    input  logic[7:0]    i_data, 
    output logic         o_ready,
    output logic         o_tx
);
    localparam CLK_FREQ = 50000000;
    localparam BAUD_RATE = 9600;
    localparam integer CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
    
    typedef enum logic [1:0] {
        IDLE,      // 2'b00
        START,     // 2'b01
        DATA_TX,   // 2'b10
        STOP       // 2'b11
    } state_t;

    state_t state;
    logic [2:0] bit_index;
    logic [15:0] counter;

    always_comb begin
        o_ready = 1'b0;
        if (state == IDLE) begin
            o_ready = 1'b1;  // Set to ready when idle
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            counter <= 16'd0;
            bit_index <= 3'd0;
            o_tx <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    o_tx <= 1'b1; 
                    if (i_valid) begin  // data to write is valid and we start start
                         state <= START;
                    end
                end

                START: begin
                    o_tx <= 1'b0; // send one bit low for the start bit
                     if (counter == CYCLES_PER_BIT - 1) begin
                        counter <= 16'd0;
                        state <= DATA_TX;
                     end else begin
                        counter++;
                     end 
                end

                DATA_TX: begin
                    o_tx <= i_data[bit_index];
                    if (counter == CYCLES_PER_BIT - 1) begin
                        counter <= 16'd0;
                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state <= STOP;
                        end else begin
                            bit_index++;
                        end
                    end else begin
                        counter++;
                    end
                 end

                STOP: begin
                    o_tx <= 1'b1;
                    if (counter == CYCLES_PER_BIT - 1) begin
                        counter <= 16'd0;
                        state <= IDLE;
                    end else begin
                        counter++;
                    end
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

module uart_wishbone (
    input  logic         clk, 
    input  logic         reset,  

    wishbone_if.slave wishbone,

    input  logic         i_rx,
    output logic         o_tx
);

    // uart address 
    typedef enum logic [31:0] {
        TDR_ADDR = 32'h10000000,   // Transmit Data Register
        RDR_ADDR = 32'h10000004,   // Receive Data Register
        SR_ADDR = 32'h10000008,    // Status Register
        CR_ADDR = 32'h1000000C     // Control Register (Not used right now)
    } uart_reg_addr_t;

    wire uart_reg_addr_t uart_addr = uart_reg_addr_t'(wishbone.address);

    // Status Register Bits
    logic tx_busy;
    logic rx_available;
    logic framing_error;
    logic overflow_error;

    // Internal Registers
    logic [7:0] rdr_reg;
    logic [7:0] sr_reg;
    // logic [7:0] cr_reg; (unused)

    // Internal Signals
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic rx_ready;
    logic tx_ready;
    logic tx_start;
    logic rx_data_read;


    uart_rx uart_rx_inst (
        .clk(clk),
        .reset(reset),
        .i_rx(i_rx),
        .o_valid(rx_available),
        .o_data(rx_data),
        .o_error(framing_error)
    );

    uart_tx uart_tx_inst (
        .clk(clk),
        .reset(reset),
        .i_valid(tx_start),
        .i_data(tx_data),
        .o_ready(tx_ready),
        .o_tx(o_tx)
    );

    // Acknowledge Logic
    always_ff @(posedge clk) begin
        if(reset) begin 
            wishbone.ack <= 1'b0;
        end else begin
            if (wishbone.cycle && wishbone.strobe && !wishbone.ack) begin
                wishbone.ack <=  1'b1; // Acknowledge in the next clock cycle
            end else begin
                wishbone.ack <= 1'b0;
            end 
        end

    end

     // Wishbone Read Logic
    always_comb begin
        if (wishbone.cycle && wishbone.strobe && !wishbone.write_enable) begin
            case (uart_addr) 
                RDR_ADDR: wishbone.data_out = {24'b0, rdr_reg}; // Read RDR
                SR_ADDR: wishbone.data_out = {24'b0, sr_reg}; // Read RDR
                default: wishbone.data_out = 32'b0;
            endcase
        end else begin
            wishbone.data_out = 32'd0;
        end
    end

    // Wishbone Write Logic
    always_ff @(posedge clk) begin
        if(reset) begin
            rdr_reg <= 8'd0;
            tx_data <= 8'd0;
        end else begin
             if (wishbone.cycle && 
                wishbone.strobe && 
                wishbone.write_enable) begin
                case (uart_addr)
                    TDR_ADDR: begin
                        tx_data <= wishbone.data_in[7:0];
                        tx_start <= 1'b1;
                    end 
                endcase
             end else if (tx_start && !tx_ready) begin
                tx_start <= tx_start; // keep tx_start high waiting for ready
             end else if (tx_start && tx_ready) begin
                tx_start <= 1'b0; // byte sent, set start low again
             end
        end
    end

    // Status Register Logic
    always_ff @(posedge clk) begin
    if (reset) begin
        rx_ready <= 1'b0;
        overflow_error <= 1'b0;
    end else begin
        if (rx_available) begin
            if (!rx_ready) begin
                rdr_reg <= rx_data;
                rx_ready <= 1'b1;
            end else begin
                rdr_reg <= rx_data;
                overflow_error <= 1'b1;
            end
        end

        if (wishbone.cycle && 
            wishbone.strobe && 
            !wishbone.write_enable && 
            wishbone.ack && 
            uart_addr == RDR_ADDR) begin
                rx_ready <= 1'b0;
                overflow_error <= 1'b0;
        end

        // Update Status Register
        sr_reg[0] <= rx_ready;        // Data ready to be read
        sr_reg[1] <= tx_ready;        // Transmitter ready for data
        sr_reg[2] <= framing_error;   // Framing error flag
        sr_reg[3] <= overflow_error;  // Overflow error flag
    end
end

endmodule
