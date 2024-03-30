`timescale 1ns/1ns
module singlecycle(input clk,rst);

  wire RegWrite,ALUSrc,MemWrite,Zero,blt,bge;
  wire [1:0] ResultSrc, PCSrc;
  wire [2:0] AluControl,func3,ImmSrc;
  wire [6:0] OPC,func7;

  datapath dp(clk, rst, RegWrite, ALUSrc,MemWrite,ResultSrc,AluControl,ImmSrc,PCSrc,Zero,blt,bge,OPC,func3,func7);
  Controller cntrl(OPC,func3,func7,Zero,blt,bge,RegWrite,MemWrite,ALUSrc, ResultSrc,AluControl,ImmSrc,PCSrc);

endmodule

module single_cycle_TB();
  reg clk = 1'b0, rst = 1'b1;
  singlecycle CUT(clk, rst);
  always #50 clk = ~clk;
  initial begin
    #100 rst = 1'b0;
    #10000 $stop;
  end
endmodule