// forwarding_unit.sv
// Simple forwarding unit used in EX stage.
// If a previous instruction produces a result that the current EX instruction needs,
// select forwarded data from EX/MEM (higher priority) or MEM/WB stages.

module forwarding_unit(
    input  logic [4:0] Rs1E, Rs2E,     // source registers for the EX-stage instruction
    input  logic [4:0] RdM, RdW,       // destination registers in MEM and WB stages
    input  logic       RegWriteM, RegWriteW, // are those stages writing registers?
    output logic [1:0] ForwardA, ForwardB   // 00 = use reg data, 01 = from MEM, 10 = from WB
);

  always_comb begin
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    // Priority: MEM stage forwarding (newer data) > WB stage
    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs1E))
      ForwardA = 2'b01;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs1E))
      ForwardA = 2'b10;

    if (RegWriteM && (RdM != 5'd0) && (RdM == Rs2E))
      ForwardB = 2'b01;
    else if (RegWriteW && (RdW != 5'd0) && (RdW == Rs2E))
      ForwardB = 2'b10;
  end

endmodule
