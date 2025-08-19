`timescale 1ns / 1ps
module tb_vending_mealy();
	reg clk;
	reg reset;
	reg [1:0] coin;
	wire dispense;
	wire chg5;
	vending_mealy dut (
		.clk(clk),
		.rst(reset),
		.coin(coin),
		.dispense(dispense),
		.chg5(chg5)
	);
	initial clk = 0;
	always #5 clk = ~clk;
		initial begin
			$dumpfile("dump.vcd");
			$dumpvars(0, tb_vending_mealy);
			reset = 1; coin = 2'b00;
			#20; 
			reset = 0;
			@(posedge clk); coin = 2'b01;
			@(posedge clk); coin = 2'b01;
			@(posedge clk); coin = 2'b10;
			@(posedge clk); coin = 2'b00;
			repeat(2) @(posedge clk); coin = 2'b10;
			@(posedge clk); coin = 2'b10;
			@(posedge clk); coin = 2'b01;
			@(posedge clk); coin = 2'b00;
			repeat(2) @(posedge clk); coin = 2'b01;
			@(posedge clk); coin = 2'b00;
			@(posedge clk); coin = 2'b10;
			@(posedge clk); coin = 2'b01;
			@(posedge clk); coin = 2'b10;
			#50;
			$stop;
		end
endmodule
