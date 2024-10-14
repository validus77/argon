typedef enum logic [3:0] {
    ALU_ADD  = 4'b0000, // Addition
    ALU_SUB  = 4'b1000, // Subtraction
    ALU_XOR  = 4'b0100, // Bitwise XOR
    ALU_OR   = 4'b0110, // Bitwise OR
    ALU_AND  = 4'b0111, // Bitwise AND
    ALU_SLL  = 4'b0001, // Logical left shift
    ALU_SRL  = 4'b0101, // Logical right shift
    ALU_SRA  = 4'b1101, // Arithmetic right shift
    ALU_SLT  = 4'b0010, // Set less than (signed)
    ALU_SLTU = 4'b0011  // Set less than (unsigned)
} alu_opcode_t;