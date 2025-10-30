// controller.sv
// Combinational instruction decoder for the ID stage.
// Produces simple control signals that are captured into ID/EX pipeline registers.
module controller(
    input  logic [6:0] opcode,
    output logic RegWrite,    // write back to register file
    output logic MemWrite,    // write to data memory
    output logic MemToReg,    // select memory data for WB
    output logic ALUSrc,      // ALU second operand: 0=reg, 1=imm
    output logic Branch,      // branch instruction
    output logic Jump,        // jump (JAL / JALR)
    output logic [1:0] ALUOp, // used by ALU-control to generate ALU control code
    output logic [1:0] ImmSrc,// immediate type selector (I/S/B/J/U)
    output logic [1:0] ResultSrc // optional: allows selecting PC+4 in WB
);

  // Opcode constants for readability
  localparam [6:0]
    OP_LOAD   = 7'b0000011,
    OP_STORE  = 7'b0100011,
    OP_OP     = 7'b0110011,
    OP_OP_IMM = 7'b0010011,
    OP_BRANCH = 7'b1100011,
    OP_JAL    = 7'b1101111,
    OP_JALR   = 7'b1100111,
    OP_LUI    = 7'b0110111,
    OP_AUIPC  = 7'b0010111,
    OP_CUSTOM = 7'b0001011; // RVX10 custom opcode (example)

  always_comb begin
    // defaults (safe)
    RegWrite  = 1'b0;
    MemWrite  = 1'b0;
    MemToReg  = 1'b0;
    ALUSrc    = 1'b0;
    Branch    = 1'b0;
    Jump      = 1'b0;
    ALUOp     = 2'b00;
    ImmSrc    = 2'b00;
    ResultSrc = 2'b00;

    case (opcode)
      OP_LOAD: begin
        // lw rd, offset(rs1)
        RegWrite = 1'b1;
        ALUSrc   = 1'b1; // address = rs1 + imm
        MemToReg = 1'b1; // write data from memory
        ALUOp    = 2'b00; // add for address calc
        ImmSrc   = 2'b00; // I-type
      end

      OP_STORE: begin
        // sw rs2, offset(rs1)
        MemWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = 2'b01; // S-type
      end

      OP_OP: begin
        // R-type ALU instructions
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        ALUOp    = 2'b10; // detailed decode later (funct3/funct7)
        ImmSrc   = 2'b00;
      end

      OP_OP_IMM: begin
        // I-type ALU (addi, andi, ori...)
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b10;
        ImmSrc   = 2'b00;
      end

      OP_BRANCH: begin
        // BEQ/BNE/BLT/etc: ALU used for compare
        Branch = 1'b1;
        ALUOp  = 2'b01;
        ImmSrc = 2'b10; // B-type
      end

      OP_JAL: begin
        // JAL: write PC+4 to rd, then jump
        RegWrite  = 1'b1;
        Jump      = 1'b1;
        ResultSrc = 2'b10; // PC+4
        ImmSrc    = 2'b11; // J-type
      end

      OP_JALR: begin
        // JALR: write PC+4 and jump to rs1+imm
        RegWrite  = 1'b1;
        Jump      = 1'b1;
        ALUSrc    = 1'b1;  // compute target = rs1 + imm
        ResultSrc = 2'b10; // PC+4
        ImmSrc    = 2'b00; // I-type
        ALUOp     = 2'b00; // add for target calc
      end

      OP_LUI: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = 2'b11; // U-type
      end

      OP_AUIPC: begin
        RegWrite = 1'b1;
        ALUSrc   = 1'b1;
        ALUOp    = 2'b00;
        ImmSrc   = 2'b11; // U-type (handled as PC+imm in EX)
      end

      OP_CUSTOM: begin
        // custom RVX10 treated like an R-type (decode by funct3/funct7 in EX)
        RegWrite = 1'b1;
        ALUSrc   = 1'b0;
        ALUOp    = 2'b10;
        ImmSrc   = 2'b00;
      end

      default: begin
        // unsupported opcode — keep defaults (no operation)
      end
    endcase
  end

endmodule
