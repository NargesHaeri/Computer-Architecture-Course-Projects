`timescale 1ns/1ns
module pipeline(input clk,rst);

wire RegWriteD,MemWriteD,AluSrcD;
wire[6:0] OPC,func7;
wire[2:0]func3;
wire [1:0]JumpD;
wire [1:0]ResultSrcD;
wire [2:0]ImmSrcD,AluControlD,BranchD; 

Controller cntrl(clk,rst,OPC,func7,func3,RegWriteD,MemWriteD,JumpD, AluSrcD,ResultSrcD,ImmSrcD,BranchD,AluControlD);
datapath dp(clk,rst,RegWriteD,MemWriteD,JumpD,BranchD,AluSrcD,ImmSrcD,ResultSrcD,AluControlD,OPC,func3,func7);

endmodule

module pipeline_TB();
  reg clk = 1'b0, rst = 1'b1;
  always #50 clk = ~clk;
  pipeline CUT(clk, rst);
  initial begin
    #100 rst = 1'b0;
    #100000 $stop;
  end
endmodule