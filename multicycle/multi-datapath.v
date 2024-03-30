`timescale 1ns/1ns

module ALU(input [31:0] scrA,srcB,input [2:0] Aluop,output Zero,blt,bge,output reg [31:0] ALUResult);

  assign Zero = ~(|ALUResult);
  assign blt =(ALUResult[31]==1)?1'b1:1'b0;
  assign bge =(ALUResult[31]==0)?1'b1:1'b0;

  always @(Aluop, scrA,srcB)begin
    case(Aluop)
        3'b000 : ALUResult = scrA + srcB;
        3'b001 : ALUResult = scrA-srcB;
        3'b010 : ALUResult = scrA&srcB;
        3'b011 : ALUResult = scrA|srcB;
        3'b101 : ALUResult = (scrA<srcB) ? 32'd1 : 32'd0;
        3'b111 : ALUResult=scrA^srcB; 
    endcase
  end
endmodule

module Extend (input [24:0] in,input [2:0]ImmSrc, output reg [31:0] out);
    always@(in,ImmSrc)begin
        case(ImmSrc)
            3'b000: out = {{20{in[24]}},in[24:13]};
            3'b001: out = {{20{in[24]}},in[24:18],in[4:0]};
            3'b010: out = {{19{in[24]}},in[24],in[0],in[23:18], in[4:1], 1'b0};
            3'b011: out = {in[24:5],12'b0};
            3'b100: out = {{11{in[24]}},in[24],in[12:5],in[13],in[23:18], in[17:14],1'b0};
        endcase
    end
endmodule


module mux2to1 (input [31:0] A, B,input sel,output [31:0] out);

  assign out = ~sel? A:B;

endmodule

module mux3to1 (input [31:0] A, B, C,input [1:0] sel,output [31:0] out);

  assign out = (sel == 2'b00) ? A :
               (sel == 2'b01) ? B :
               (sel == 2'b10) ? C :
               32'bx;
endmodule

module mux4to1 (input [31:0] A, B, C,D,input [1:0] sel,output [31:0] out);

  assign out = (sel == 2'b00) ? A :
               (sel == 2'b01) ? B :
               (sel == 2'b10) ? C :
               (sel == 2'b11) ? D :
               32'bx;

endmodule

module Inst_DataMemory(input clk,WE,input [31:0] Address,WD, output [31:0] ReadData);
  reg [31:0] memory [0:30];

  always @(posedge clk)begin
    if(WE)
      memory[Address] <=WD;
  end

initial begin
    $readmemh("test2.txt",memory);
  end    
  assign ReadData = memory[Address];
  
endmodule

module RegisterFile (input clk,rst,input [4:0] A1, A2, A3,input WE,input [31:0] write_data,output [31:0] RD1, RD2);

  reg [31:0] registers [0:31];
  integer i;

 always @ (posedge clk) begin
    if (rst) begin
      for(i=0;i<32;i=i+1)begin
        registers[i]<=0;
      end
    end
	  else if (WE && A3 != 5'd0)
        registers[A3] <= write_data;
  end
    
    assign RD1 = registers[A1];
    assign RD2 = registers[A2];
    

endmodule


module Adder(input [31:0] A, B,output [31:0] sum);
  assign sum = A + B;
endmodule


module PC(input clk, rst,En,input [31:0] pc, output reg [31:0] pc_out);

  always @(posedge clk)begin
    if(rst)
      pc_out<= 32'd0;
    else if(En)
      pc_out<= pc;
  end
endmodule

module Register(input clk, En, input [31:0]in,output reg [31:0] out);
  always@(posedge clk)begin
    if(En)
      out <= in;
  end
endmodule

module doubleRegister(input clk, En, input [31:0]in1,in2,output reg [31:0] out1,out2);
  always@(posedge clk)begin
    if(En)begin
      out1 <= in1;
      out2 <= in2;
      end
     else begin
       out1 <= out1;
       out2 <= out2;
	end
  end
endmodule


  
module datapath(clk, rst,AdrSrc,RegWrite, ALUSrcA,ALUSrcB,MemWrite,IRwrite,ResultSrc,AluControl,ImmSrc,PCWrite,Zero,blt,bge,OPC,func3,func7);
 
    input RegWrite,MemWrite,clk,rst,PCWrite,AdrSrc,IRwrite;
    input [1:0] ResultSrc,ALUSrcA,ALUSrcB;
    input [2:0] AluControl;
    input [2:0]ImmSrc;
    wire [31:0] PCNext,inst,immExt,result,srcB,PCOut,ReadData,Adr,AluOut,OldPC,Data,A,B;
    wire [31:0] RD1,RD2,ALUResult;
    output Zero,blt,bge;
    output [6:0] OPC,func7; 
    output [2:0]func3;
    wire [31:0] srcA;
    assign OPC = inst[6:0];
    assign func3 = inst[14:12];
    assign func7 = inst[31:25];
	
    PC pc(clk,rst,PCWrite,result,PCOut);
    mux2to1 adrsrc(PCOut,result,AdrSrc,Adr);
    Inst_DataMemory idm(clk,MemWrite,{2'b00,Adr[31:2]},B,ReadData);
    doubleRegister Dr(clk,IRwrite,ReadData,PCOut,inst,OldPC);
    RegisterFile RF(clk,rst,inst[19:15],inst[24:20],inst[11:7],RegWrite,result,RD1, RD2);
    Extend signextend(inst[31:7],ImmSrc,immExt);
    Register MDR(clk,1'b1,ReadData,Data);
    doubleRegister absrc(clk,1'b1,RD1,RD2,A,B);
    mux3to1 mux1(PCOut,OldPC,A,ALUSrcA,srcA);
    mux3to1 mux2(B,immExt,32'd4,ALUSrcB,srcB);
    ALU alu(srcA,srcB,AluControl,Zero,blt,bge,ALUResult);
    Register aluresult(clk,1'b1,ALUResult,AluOut);
    mux4to1 mux3(AluOut,Data,ALUResult,immExt,ResultSrc,result);
endmodule
