`timescale 1ns/1ns

module Controller(
    input clk,rst,
    input [6:0]OPC,func7,
    input [2:0]func3,
    output reg RegWriteD,MemWriteD,
    output reg [1:0]JumpD,
    output reg ALUSrcD,
    output reg [1:0]ResultSrcD,
    output reg [2:0]ImmSrcD,BranchD,
    output reg [2:0]AluControlD);


  always @* begin
    RegWriteD   = 1'b0;
    MemWriteD   = 1'b0;
    ALUSrcD     = 1'b0;
    ResultSrcD  = 2'b00;
    AluControlD = 3'b000;
    ImmSrcD     = 3'b000;
    BranchD   = 3'b000;
    JumpD = 2'b00;

    case (OPC)
      //R-type
      7'b0110011: begin
        RegWriteD   = 1'b1;
        ResultSrcD  = 2'b00;
        AluControlD = 3'b000;
        ImmSrcD     = 3'b000;

        case (func3)
          3'b000: begin
            case (func7)
              7'b0000000: AluControlD = 3'b000; // ADD
              7'b0100000: AluControlD = 3'b001; // SUB
            endcase
            end
          3'b111: AluControlD = (func7==7'b0000000)?3'b010:3'bx;//And
          3'b110: AluControlD = (func7==7'b0000000)?3'b011:3'bx;//or
          3'b010: AluControlD = (func7==7'b0000000)?3'b101:3'bx;//slt
          
        endcase
      end

      // I-type
      7'b0010011: begin
        RegWriteD   = 1'b1;
        ALUSrcD = 1'b1;
	      ImmSrcD = 3'b000;
	
        case (func3)
          3'b000: AluControlD = 3'b000;//addi
          3'b100: AluControlD = 3'b111;//xori
          3'b010: AluControlD = 3'b101;//slti
          3'b110: AluControlD = 3'b001;//ori

        endcase

      end

      // S-type
      7'b0100011: begin
        MemWriteD   = 1'b1;
        ALUSrcD = 1'b1;
        ResultSrcD  = 2'b10;
        ImmSrcD = 3'b001;
        case (func3)
          3'b010: AluControlD = 3'b000;   // Sw
        endcase
      end

      // B-type
      7'b1100011: begin
        ImmSrcD= 3'b010;
        AluControlD = 3'b001;
	      ALUSrcD = 1'b0;
	      case (func3)
          3'b000: BranchD = 3'b001;
          3'b001: BranchD = 3'b010;
          3'b100: BranchD = 3'b011;
          3'b101: BranchD = 3'b100;
        endcase    
      end

      // U-type
      7'b0110111: begin
          RegWriteD  = 1'b1;
          ResultSrcD = 2'b11;
          ImmSrcD    = 3'b011;
          AluControlD = 3'b100;
          ALUSrcD     = 1'b1;
      end

      // jal
      7'b1101111: begin
      	  RegWriteD   = 1'b1;
          ALUSrcD = 1'b1;
          ImmSrcD     = 3'b100;
          AluControlD = 3'b000;
          ResultSrcD  = 2'b11;
          JumpD = 2'b01;
      end
     //lw
     7'b0000011: begin
          RegWriteD   = 1'b1;
          ALUSrcD = 1'b1;
          ImmSrcD     = 3'b000;
          AluControlD = 3'b000;
          ResultSrcD  = 2'b01;
     end
     //jalr
     7'b1100111:begin
          JumpD = 2'b10;
          AluControlD = 3'b000;
          RegWriteD   = 1'b1;
          ALUSrcD = 1'b1;
          ImmSrcD = 3'b000;
          ResultSrcD  = 2'b11;
	end
    endcase
  end

endmodule