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
