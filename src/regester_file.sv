module register_file (
    input  logic        clk, 
    input  logic        reset,    

    input  logic        i_write_enable,        
    input  logic [4:0]  i_write_address,        
    input  logic [31:0] i_write_data,    

    input  logic [4:0]  i_read_address_1,      
    output logic [31:0] o_read_data_1,      

    input  logic [4:0]  i_read_address_2,       
    output logic [31:0] o_read_data_2       
);

    logic [31:0] registers[31:0];

    // Read Logic combinational
    // fetch the data from rd1 and rd from tghe adress ra1 and ra2. 
    // If any eather address is 0 then return 0, x0 is specal case 
    always_comb begin
        o_read_data_1 = (i_read_address_1 != 5'd0) ? registers[i_read_address_1] : 32'b0;
        o_read_data_2 = (i_read_address_2 != 5'd0) ? registers[i_read_address_2] : 32'b0;
    end

    // Write Operation
    always_ff @(posedge clk) begin
        if(reset) begin
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'd0;
            end
        end else begin
            // in each clock if write enabled is high and the adress is not 0 then store the data
            if (i_write_enable && (i_write_address != 5'd0)) begin
                registers[i_write_address] <= i_write_data;
            end
        // No else needed; registers hold their value if not written
        end
    end
endmodule