`timescale 1ns/1ns

module multicycle(input clk,rst);

wire RegWrite,MemWrite,Zero,blt,bge,AdrSrc,IRwrite,PCWrite;
wire [1:0] ResultSrc, PCSrc,ALUSrcA,ALUSrcB;
wire [2:0] AluControl,func3,ImmSrc;
wire [6:0] OPC,func7;

datapath dp(clk, rst,AdrSrc,RegWrite, ALUSrcA,ALUSrcB,MemWrite,IRWrite,ResultSrc,AluControl,ImmSrc,PCWrite,Zero,blt,bge,OPC,func3,func7);
Controller cntrl(clk,rst,OPC,func3,func7,Zero,blt,bge,RegWrite,MemWrite,ALUSrcA,ALUSrcB,IRWrite,AdrSrc,ResultSrc,AluControl,ImmSrc,PCWrite);


endmodule

module multi_cycle_TB();
  reg clk = 1'b0, rst = 1'b1;
  always #50 clk = ~clk;
  multicycle CUT(clk, rst);
  initial begin
    #51 rst = 1'b0;
    #100000 $stop;
  end
endmodule
