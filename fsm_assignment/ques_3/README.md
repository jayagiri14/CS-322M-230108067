
# Vending Machine (Mealy) Project

## Goal
Price = 20. Accept coins 5 or 10. When total ≥ 20: dispense=1 (1 cycle). If total=25: also chg5=1 (1 cycle). Reset total after vend.

* coin[1:0]: 01=5, 10=10, 00=idle (ignore 11). One coin max per cycle.
* Type: Mealy
* Reset: synchronous, active-high.

## Deliverables
- State diagram + brief justification for Mealy.
- Waveform highlighting vend & change pulses
- Verilog code and testbench

---

## Verilog Code: vending_mealy.v

```verilog
`timescale 1ns / 1ps
module vending_mealy(
 input wire clk,
 input wire rst,
 input wire[1:0]coin,
 output wire dispense,
 output wire chg5
 );
	 reg [1:0] pres_state,next_state;
	 parameter total_0= 0,total_5= 1, total_10=2, total_15= 3;
	 always@(posedge clk)
	 begin
		  if(rst)
				pres_state<= total_0;
		  else
				pres_state=next_state; 
	 end
	 always@(*)
	 begin
		  case(pres_state)
		  total_0: if(coin==0)
						  next_state=total_0;
					  else if(coin==1)
						  next_state=total_5;
					  else
						  next_state=total_10;
		  total_5: if(coin==0)
						  next_state=total_0;
					  else if(coin==1)
						  next_state=total_10;
					  else
						  next_state=total_15;
		  total_10: if(coin==0)
						  next_state=total_0;
					  else if(coin==1)
						  next_state=total_15;
					  else
						  next_state=total_0;
		  total_15: next_state= total_0;
		 endcase
	 end
	 assign dispense= (pres_state==total_10& coin==2'b10) || (pres_state==total_15& coin==2'b01) || (pres_state==total_15& coin==2'b10);
	 assign chg5= (pres_state==total_15& coin==2'b10);
endmodule
```

## Testbench: tb_vending_mealy.v

```verilog
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
```

---

## State Diagram & Mealy Justification

The Mealy machine is chosen because the outputs (dispense, chg5) depend on both the current state (total value) and the current input (coin value). This allows immediate response to coin insertion without waiting for a full state transition.

**State Diagram:**

- States: total_0 (0), total_5 (5), total_10 (10), total_15 (15)
- Transitions based on coin input (00, 01, 10)
- Output pulses (dispense, chg5) are generated on transitions where total ≥ 20

---

## Waveform

Refer to the simulation output for waveforms. Ensure to highlight the cycles where `dispense` and `chg5` pulses occur.
