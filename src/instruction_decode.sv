`timescale 1ns / 1ps

module instruction_decode (

    // IF -> ID
    input logic [31:0] i_pc,
    input logic [31:0] i_instruction,

    // ID <-> RegFile
    output logic [4:0] o_rs1_id,
    output logic [4:0] o_rs2_id,
    input logic [31:0] i_rs1_data,
    input logic [31:0] i_rs2_data,

    // ID <-> CSR
    output logic [11:0] o_csr_id,
    input logic [31:0]  i_csr_data,

    // ID -> EXE
    output alu_opcode_t o_alu_opcode,
    output logic [31:0] o_alu_op1,
    output logic [31:0] o_alu_op2,
    output logic [4:0]  o_rd_id,

    output logic        o_is_reg_write,
    output logic        o_is_load,
    output logic        o_is_store,
    output logic [2:0]  o_load_store_type,
    output logic        o_is_jump,
    output logic [31:0] o_jump_address,
    output logic        o_is_branch,
    output logic [2:0]  o_branch_type,
    output logic [31:0] o_store_data         
);

// opcodes 
typedef enum logic [6:0] {
    OPCODE_RTYPE  = 7'b0110011,
    OPCODE_ITYPE  = 7'b0010011,
    OPCODE_LOAD   = 7'b0000011,
    OPCODE_STORE  = 7'b0100011,
    OPCODE_BRANCH = 7'b1100011,
    OPCODE_LUI    = 7'b0110111,
    OPCODE_AUIPC  = 7'b0010111,
    OPCODE_JAL    = 7'b1101111,
    OPCODE_JALR   = 7'b1100111,
    OPCODE_SYSTEM = 7'b1110011
} opcode_t;

// This module is all combinational logic
always_comb begin
     // Declarations
    opcode_t opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [31:0] Uimm;
    logic [31:0] Iimm;
    logic [31:0] Simm;
    logic [31:0] Bimm;
    logic [31:0] Jimm;
    
    // Assignments
    o_rs1_id    = i_instruction[19:15];
    o_rs2_id    = i_instruction[24:20];
    o_rd_id     = i_instruction[11:7];

    // Assignments for the CSR
    o_csr_id = i_instruction[31:20];

    opcode = opcode_t'(i_instruction[6:0]);
    
    funct3 = i_instruction[14:12];
    funct7 = i_instruction[31:25];

    Uimm={    i_instruction[31],   i_instruction[30:12], {12{1'b0}}};
    Iimm={{21{i_instruction[31]}}, i_instruction[30:20]};
    Simm={{21{i_instruction[31]}}, i_instruction[30:25],i_instruction[11:7]};
    Bimm={{20{i_instruction[31]}}, i_instruction[7],i_instruction[30:25],i_instruction[11:8],1'b0};
    Jimm={{12{i_instruction[31]}}, i_instruction[19:12],i_instruction[20],i_instruction[30:21],1'b0};

    o_is_reg_write = 1'b0;
    o_is_load = 1'b0;
    o_is_store = 1'b0;
    o_load_store_type = 3'd0;
    o_is_jump = 1'b0;
    o_jump_address = 32'd0;
    o_is_branch = 1'b0;
    o_branch_type = 3'd0;
    o_store_data = 32'd0;
    o_alu_opcode = alu_opcode_t'(0);
    o_alu_op1 = 32'd0;
    o_alu_op2 = 32'd0;

    case (opcode)
        OPCODE_RTYPE: begin  // rd <- rs1 OP rs2 
            o_alu_opcode = alu_opcode_t'({funct7[5], funct3});
            o_alu_op1 = i_rs1_data;
            o_alu_op2 = i_rs2_data;
            o_is_reg_write = 1'b1;
        end

        OPCODE_ITYPE: begin  // rd <- rs1 OP Iimm
            o_alu_opcode = alu_opcode_t'({1'b0, funct3});
            o_alu_op1 = i_rs1_data;
            o_alu_op2 = Iimm;
            o_is_reg_write = 1'b1;
        end

        OPCODE_LOAD: begin // rd <- mem[rs1+Iimm]
            o_alu_opcode = ALU_ADD;
            o_alu_op1 = i_rs1_data;
            o_alu_op2 = Iimm;
            o_is_load = 1'b1;
            o_load_store_type = funct3;
            o_is_reg_write = 1'b1;
        end

        OPCODE_STORE: begin //  mem[rs1+Simm] <- rs2
             o_alu_opcode = ALU_ADD;
             o_alu_op1 = i_rs1_data;
             o_alu_op2 = Simm;
             o_store_data = i_rs2_data;
             o_load_store_type = funct3;
             o_is_store = 1'b1;
        end

        OPCODE_BRANCH: begin // if(rs1 OP rs2) PC <- PC+Bimm
             o_alu_opcode = ALU_SUB;
             o_alu_op1 = i_rs1_data;
             o_alu_op2 = i_rs2_data;
             o_branch_type = funct3;
             o_jump_address = i_pc + Bimm;
             o_is_branch = 1'b1;
        end

        OPCODE_LUI: begin // rd <- Uimm 
            o_alu_opcode = ALU_ADD;
            o_alu_op1 = Uimm;
            o_alu_op2 = 32'd0; // this is a bit cheeky. to amke it like the others we do rd <- Uimm + 0
            o_is_reg_write = 1'b1;
        end

        OPCODE_AUIPC: begin //  rd <- PC + Uimm
            o_alu_opcode = ALU_ADD;
            o_alu_op1 = i_pc;
            o_alu_op2 = Uimm;
            o_is_reg_write = 1'b1;
        end

        OPCODE_JAL: begin // rd <- PC+4; PC <- PC+Jimm
            o_alu_opcode = ALU_ADD;
            o_alu_op1 = i_pc;
            o_alu_op2 = 32'd4;
            o_jump_address = i_pc + Jimm;
            o_is_reg_write = 1'b1;
            o_is_jump = 1'b1;
        end

        OPCODE_JALR : begin // rd <- PC+4; PC <- rs1+Iimm
            o_alu_opcode = ALU_ADD;
            o_alu_op1 = i_pc;
            o_alu_op2 = 32'd4;
            o_jump_address = i_rs1_data + Iimm;
            o_is_reg_write = 1'b1;
            o_is_jump = 1'b1;
        end

        OPCODE_SYSTEM: begin
                // FOR NOW ONLY SUPPORT ONE INSTRUCTION CSRRS (b010), and only when rs is x0
                // basicly CSR is readonly at this point
                // very limited functionaly for reading the cycel and instr counter 
                if(funct3 == 3'b010 && o_rs1_id == 5'd0) begin
                    o_alu_opcode <= ALU_ADD;
                    o_alu_op1 <= i_csr_data;
                    o_alu_op2 <= 32'd0; 
                    o_is_reg_write <= 1'b1;
                end   
        end
        
        default: begin
        end

    endcase
end

endmodule