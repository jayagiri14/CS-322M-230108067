// tb_pipeline.sv
`timescale 1ns/1ps
module tb_pipeline();
  logic clk, reset;
  logic [31:0] WriteData, DataAdr;
  logic MemWrite;

  // DUT: top-level pipeline that includes IMEM and DMEM
  top_pipeline dut(.clk(clk), .reset(reset), .WriteData(WriteData), .DataAdr(DataAdr), .MemWrite(MemWrite));

  initial begin
    $dumpfile("pipeline_tb.vcd");
    $dumpvars(0, tb_pipeline);
    // reset pulse
    reset = 1; #22; reset = 0;
  end

  // 100 MHz clock (10 ns period)
  initial clk = 0;
  always #5 clk = ~clk;

  // Monitor DMEM writes: tests store 25 at address 100 on success
  always @(negedge clk) begin
    if (MemWrite) begin
      $display("STORE @ %0d = 0x%08h (t=%0t)", DataAdr, WriteData, $time);
      if ((DataAdr === 32'd100) && (WriteData === 32'd25)) begin
        $display("Simulation succeeded: memory[100] == 25");
        // Print register x28 (if available in DUT)
        // Note: hierarchical access is allowed in modelsim/iverilog but may be simulator-specific
        $display("CHECKSUM (x28) = %0d (0x%08h)", dut.cpu.dp.RegFile[28], dut.cpu.dp.RegFile[28]);
        $finish;
      end else if (DataAdr !== 32'd96) begin
        // If a store occurs at an unexpected address (not part of boot), fail
        $display("Simulation failed: unexpected store at %0d (data=0x%08h)", DataAdr, WriteData);
        $finish;
      end
    end
  end

  // Safety timeout to avoid infinite simulation
  initial begin
    #2000000;
    $display("TIMEOUT: simulation did not finish in time");
    $finish;
  end

endmodule
