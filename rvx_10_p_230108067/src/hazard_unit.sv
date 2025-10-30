// hazard_unit.sv
// Detects a load-use hazard: when EX stage is a load that will produce data
// needed by the instruction currently in ID stage. On detection, the unit
// requests a one-cycle stall and converts ID/EX into a bubble (flush EX).

module hazard_unit(
    input  logic MemReadE,        // true if instruction in EX stage is a load
    input  logic [4:0] RdE,       // destination reg of EX-stage instruction
    input  logic [4:0] Rs1D, Rs2D,// source regs of ID-stage instruction
    output logic stallF, stallD,  // stall IF and ID when load-use hazard detected
    output logic flushE           // flush ID/EX by inserting a bubble
);

  always_comb begin
    stallF = 1'b0;
    stallD = 1'b0;
    flushE = 1'b0;

    if (MemReadE && ((RdE == Rs1D) || (RdE == Rs2D))) begin
      // Freeze IF and ID, and inject bubble into EX
      stallF = 1'b1;
      stallD = 1'b1;
      flushE = 1'b1;
    end
  end

endmodule
