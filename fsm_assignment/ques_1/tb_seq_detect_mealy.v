`timescale 1ns / 1ps

module tb_seq_detect_mealy;

	reg clk;
	reg rst;
	reg din;
	wire y;

	seq_detect_mealy dut (
		.din(din),
		.clk(clk),
		.rst(rst),
		.y(y)
	);

	initial clk = 0;
	always #5 clk = ~clk;

	initial begin
		$dumpfile("seq_detect_mealy.vcd");
		$dumpvars(0, tb_seq_detect_mealy);

		rst = 1;
		din = 0;
		@(posedge clk);
		@(posedge clk);
		rst = 0;

		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=0; @(posedge clk);
		din=1; @(posedge clk);

		din=0; @(posedge clk);

		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=0; @(posedge clk);
		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=0; @(posedge clk);
		din=1; @(posedge clk);

		din=0; @(posedge clk);

		din=0; @(posedge clk);
		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=0; @(posedge clk);
		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=0; @(posedge clk);
		din=1; @(posedge clk);

		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=1; @(posedge clk);
		din=0; @(posedge clk);
		din=1; @(posedge clk);

		#20;
		$display("\n[TB] Simulation finished.");
		$finish;
	end

endmodule
