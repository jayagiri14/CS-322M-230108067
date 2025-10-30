// datapath.sv
`timescale 1ns/1ps
module datapath(
    input logic clk, reset,
    output logic [31:0] PC,
    input  logic [31:0] InstrIF,
    output logic MemWrite_out,
    output logic [31:0] DataAdr_out, WriteData_out,
    input  logic [31:0] ReadData
);

  logic [31:0] cycle_count, instr_retired, stall_count, flush_count, branch_count;

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      cycle_count <= 32'd0;
      instr_retired <= 32'd0;
      stall_count <= 32'd0;
      flush_count <= 32'd0;
      branch_count <= 32'd0;
    end else begin
      cycle_count <= cycle_count + 32'd1;
      if (stallF || stallD) stall_count <= stall_count + 32'd1; // Track stall cycles
      if (flushE) flush_count <= flush_count + 32'd1;           // Track flushed instructions
    end
  end

  logic [31:0] PC_reg, PC_next, PC_plus4;
  assign PC = PC_reg;
  assign PC_plus4 = PC_reg + 32'd4;

  // IF/ID pipeline registers
  logic [31:0] IFID_PC, IFID_Instr;

  // Stall/flush signals controlled by hazard unit or EX stage
  logic stallF, stallD, flushE, flushD;

  // Branch/Jump selection
  logic PCSrc;
  logic [31:0] PCTarget;
  assign PC_next = PCSrc ? PCTarget : PC_plus4;

  always_ff @(posedge clk, posedge reset) begin
    if (reset)
      PC_reg <= 32'd0;
    else if (!stallF)
      PC_reg <= PC_next;
  end

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      IFID_PC    <= 32'd0;
      IFID_Instr <= 32'h00000013; // NOP instruction
    end else begin
      if (flushD) begin
        // Insert bubble for branch/jump taken
        IFID_PC    <= 32'd0;
        IFID_Instr <= 32'h00000013;
      end else if (!stallD) begin
        IFID_PC    <= PC_reg;
        IFID_Instr <= InstrIF;
      end
      // When stalled, IF/ID retains its value
    end
  end

  logic [31:0] RegFile [0:31];
  integer i;
  initial for (i=0;i<32;i=i+1) RegFile[i]=32'd0;

  // Source and destination register fields
  logic [4:0] Rs1D, Rs2D, RdD;
  logic [31:0] ReadData1D, ReadData2D;
  logic [31:0] InstrD;
  assign InstrD = IFID_Instr;
  assign Rs1D = InstrD[19:15];
  assign Rs2D = InstrD[24:20];
  assign RdD  = InstrD[11:7];

  // Read data from register file (x0 is always zero)
  assign ReadData1D = (Rs1D != 5'd0) ? RegFile[Rs1D] : 32'd0;
  assign ReadData2D = (Rs2D != 5'd0) ? RegFile[Rs2D] : 32'd0;

  // Control signals from instruction decoder
  logic RegWriteD, MemWriteD, MemToRegD, ALUSrcD, BranchD, JumpD;
  logic [1:0] ALUOpD, ImmSrcD, ResultSrcD;
  controller ctrl(
      .opcode(InstrD[6:0]),
      .RegWrite(RegWriteD), .MemWrite(MemWriteD), .MemToReg(MemToRegD),
      .ALUSrc(ALUSrcD), .ALUOp(ALUOpD), .ImmSrc(ImmSrcD), .ResultSrc(ResultSrcD),
      .Branch(BranchD), .Jump(JumpD)
  );

  // Immediate extraction
  logic [11:0] immI, immS;
  logic [12:0] immB;
  logic [20:0] immJ;
  assign immI = InstrD[31:20];
  assign immS = {InstrD[31:25], InstrD[11:7]};
  assign immB = {InstrD[31], InstrD[7], InstrD[30:25], InstrD[11:8], 1'b0};
  assign immJ = {InstrD[31], InstrD[19:12], InstrD[20], InstrD[30:21], 1'b0};

  logic [31:0] ImmExtD;
  always_comb begin
    case (ImmSrcD)
      2'b00: ImmExtD = {{20{immI[11]}}, immI};
      2'b01: ImmExtD = {{20{immS[11]}}, immS};
      2'b10: ImmExtD = {{19{immB[12]}}, immB};
      2'b11: ImmExtD = {{11{immJ[20]}}, immJ};
      default: ImmExtD = 32'd0;
    endcase
  end

  logic [31:0] IDEX_ReadData1, IDEX_ReadData2, IDEX_Imm, IDEX_PC;
  logic [4:0]  IDEX_Rs1, IDEX_Rs2, IDEX_Rd;
  logic IDEX_RegWrite, IDEX_MemWrite, IDEX_MemToReg, IDEX_ALUSrc, IDEX_Branch, IDEX_Jump;
  logic [1:0] IDEX_ALUOp, IDEX_ResultSrc;
  logic [2:0] IDEX_funct3;
  logic [6:0] IDEX_funct7, IDEX_opcode;

  always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
      IDEX_ReadData1 <= 32'd0; IDEX_ReadData2 <= 32'd0; IDEX_Imm <= 32'd0; IDEX_PC <= 32'd0;
      IDEX_Rs1 <= 5'd0; IDEX_Rs2 <= 5'd0; IDEX_Rd <= 5'd0;
      IDEX_RegWrite <= 1'b0; IDEX_MemWrite <= 1'b0; IDEX_MemToReg <= 1'b0;
      IDEX_ALUSrc <= 1'b0; IDEX_Branch <= 1'b0; IDEX_Jump <= 1'b0;
      IDEX_ALUOp <= 2'd0; IDEX_ResultSrc <= 2'd0;
      IDEX_funct3 <= 3'd0; IDEX_funct7 <= 7'd0; IDEX_opcode <= 7'd0;
    end else begin
      if (flushE) begin
        // Insert bubble in EX stage for flush
        IDEX_ReadData1 <= 32'd0; IDEX_ReadData2 <= 32'd0; IDEX_Imm <= 32'd0; IDEX_PC <= 32'd0;
        IDEX_Rs1 <= 5'd0; IDEX_Rs2 <= 5'd0; IDEX_Rd <= 5'd0;
        IDEX_RegWrite <= 1'b0; IDEX_MemWrite <= 1'b0; IDEX_MemToReg <= 1'b0;
        IDEX_ALUSrc <= 1'b0; IDEX_Branch <= 1'b0; IDEX_Jump <= 1'b0;
        IDEX_ALUOp <= 2'd0; IDEX_ResultSrc <= 2'd0;
        IDEX_funct3 <= 3'd0; IDEX_funct7 <= 7'd0; IDEX_opcode <= 7'b0010011; // NOP placeholder
      end else if (!stallD) begin
        // Normal pipeline transfer from ID to EX
        IDEX_ReadData1 <= ReadData1D;
        IDEX_ReadData2 <= ReadData2D;
        IDEX_Imm <= ImmExtD;
        IDEX_PC <= IFID_PC;
        IDEX_Rs1 <= Rs1D; IDEX_Rs2 <= Rs2D; IDEX_Rd <= RdD;
        IDEX_RegWrite <= RegWriteD; IDEX_MemWrite <= MemWriteD;
        IDEX_MemToReg <= MemToRegD; IDEX_ALUSrc <= ALUSrcD;
        IDEX_Branch <= BranchD; IDEX_Jump <= JumpD;
        IDEX_ALUOp <= ALUOpD; IDEX_ResultSrc <= ResultSrcD;
        IDEX_funct3 <= InstrD[14:12];
        IDEX_funct7 <= InstrD[31:25];
        IDEX_opcode <= InstrD[6:0];
      end
      // On stall, hold current IDEX values
    end
  end

  localparam [4:0] ALU_ADD  = 5'b00000, ALU_SUB  = 5'b00001,
                   ALU_AND  = 5'b00010, ALU_OR   = 5'b00011,
                   ALU_XOR  = 5'b00100, ALU_SLT  = 5'b00101,
                   ALU_SLL  = 5'b00110, ALU_SRL  = 5'b00111,
                   ALU_ANDN = 5'b01000, ALU_ORN  = 5'b01001,
                   ALU_XNOR = 5'b01010, ALU_MIN  = 5'b01011,
                   ALU_MAX  = 5'b01100, ALU_MINU = 5'b01101,
                   ALU_MAXU = 5'b01110, ALU_ROL  = 5'b01111,
                   ALU_ROR  = 5'b10000, ALU_ABS  = 5'b10001;

  function automatic [4:0] aluctrl(
      input logic [1:0] ALUOp,
      input logic [2:0] f3,
      input logic [6:0] f7,
      input logic [6:0] opcode
  );
    aluctrl = ALU_ADD;
    if (opcode == 7'b0001011) begin
      // CUSTOM-0 instruction decoding
      unique case ({f7,f3})
        {7'b0000000,3'b000}: aluctrl = ALU_ANDN;
        {7'b0000000,3'b001}: aluctrl = ALU_ORN;
        {7'b0000000,3'b010}: aluctrl = ALU_XNOR;
        {7'b0000001,3'b000}: aluctrl = ALU_MIN;
        {7'b0000001,3'b001}: aluctrl = ALU_MAX;
        {7'b0000001,3'b010}: aluctrl = ALU_MINU;
        {7'b0000001,3'b011}: aluctrl = ALU_MAXU;
        {7'b0000010,3'b000}: aluctrl = ALU_ROL;
        {7'b0000010,3'b001}: aluctrl = ALU_ROR;
        {7'b0000011,3'b000}: aluctrl = ALU_ABS;
        default: aluctrl = ALU_ADD;
      endcase
    end else begin
      // Standard R-type/I-type instruction
      if (ALUOp == 2'b00) aluctrl = ALU_ADD;
      else if (ALUOp == 2'b01) aluctrl = ALU_SUB;
      else begin
        unique case (f3)
          3'b000: aluctrl = (f7[5]) ? ALU_SUB : ALU_ADD;
          3'b010: aluctrl = ALU_SLT;
          3'b110: aluctrl = ALU_OR;
          3'b111: aluctrl = ALU_AND;
          default: aluctrl = ALU_ADD;
        endcase
      end
    end
  endfunction