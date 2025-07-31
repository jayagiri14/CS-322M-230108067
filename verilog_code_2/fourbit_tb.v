`timescale 1ns / 1ns
`include "fourbit.v"
module tb_equality_comparator_4bit;
    reg [3:0] A, B;
    wire equal;
    equality_comparator_4bit uut (
        .A(A),
        .B(B),
        .equal(equal)
    );
    
    initial begin
        $dumpfile("fourbit.vcd");
        $dumpvars(0, tb_equality_comparator_4bit);
        A = 4'b0000; B = 4'b0000; 
        #10;
        
        A = 4'b1010; B = 4'b1010; 
        #10;
        
        
        A = 4'b1111; B = 4'b1111; 
        #10;
        A = 4'b0000; B = 4'b0001; 
        #10;
        
        
        
        $finish;
    end
    
endmodule

