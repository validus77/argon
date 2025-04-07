module csr (
    input logic clk, 
    input logic reset,
    input logic i_instruction_valid,
    input logic [11:0] i_csr_id,
    output logic [31:0] o_csr_data
);
/* I am only going to implment a few of the CSR registers for now, namely the counters we can add 
more as we implment more and more features. 
*/
typedef enum logic [11:0] {
    CSR_MCYCLE   = 32'hC00,
    CSR_MCYCLEH  = 32'hC80,
    CSR_INSTRET  = 32'hC02,
    CSR_INSTRETH = 32'hC82
} csr_address_t;

// Actual CSR registers
logic [31:0] mcycle;
logic [31:0] mcycleh;
logic [31:0] instret;
logic [31:0] instreth;

// Count Cycles 
always_ff @(posedge clk) begin
    if (reset) begin
        mcycle  <= 32'd0;
        mcycleh <= 32'd0;
    end else begin
        {mcycleh, mcycle} <= ({mcycleh, mcycle} + 64'd1);
    end
end

//Count Instructions
always_ff @(posedge i_instruction_valid) begin
    if(reset) begin
        instret <= 32'd0;
        instreth <= 32'd0;
    end else begin 
        {instreth, instret} <= ({instreth, instret} + 64'd1);
    end
end

// just read the cycle count this will be more complex latter 
always_comb begin
    case (i_csr_id) 
        CSR_MCYCLE: o_csr_data = mcycle;
        CSR_MCYCLEH: o_csr_data = mcycleh;
        CSR_INSTRET: o_csr_data = instret;
        CSR_INSTRETH: o_csr_data = instreth;
        default: o_csr_data = 32'd0;
    endcase
end


endmodule
