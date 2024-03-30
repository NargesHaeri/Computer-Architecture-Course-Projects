`timescale 1ns/1ns

module Controller (
  input [6:0] OPC,
  input [2:0] func3,
  input [6:0] func7,
  input Zero,blt,bge,
  output reg RegWrite,
  output reg MemWrite,
  output reg ALUSrc,
  output reg [1:0] ResultSrc,
  output reg [2:0] AluControl,
  output reg [2:0] ImmSrc,
  output reg [1:0] PCSrc
);


  reg branchEq,branchNe,branchge,branchlt,jump;



  always @* begin
    RegWrite   = 1'b0;
    MemWrite   = 1'b0;
    ALUSrc     = 1'b0;
    ResultSrc  = 2'b00;
    AluControl = 3'b000;
    ImmSrc     = 3'b000;
    PCSrc      = 2'b00;
    branchEq   = 1'b0;
    branchNe   = 1'b0;
    branchge   = 1'b0;
    branchlt   = 1'b0;
    jump = 1'b0;
    case (OPC)
      //R-type
      7'b0110011: begin
        RegWrite   = 1'b1;
        ResultSrc  = 2'b00;
        AluControl = 3'b000;
        ImmSrc     = 3'b000;
        PCSrc      = 2'b00;

        case (func3)
          3'b000: begin
            case (func7)
              7'b0000000: AluControl = 3'b000; // ADD
              7'b0100000: AluControl = 3'b001; // SUB
            endcase
            end
          3'b111: AluControl = (func7==7'b0000000)?3'b010:3'bx;//And
          3'b110: AluControl = (func7==7'b0000000)?3'b011:3'bx;//or
          3'b010: AluControl = (func7==7'b0000000)?3'b101:3'bx;//slt
          
        endcase
      end

      // I-type
      7'b0010011: begin
        RegWrite   = 1'b1;
        ALUSrc = 1'b1;
       // PCSrc  = 2'b00;
	ImmSrc     = 3'b000;
	
       
        case (func3)
          3'b000: AluControl = 3'b000;//addi
          3'b100: AluControl = 3'b111;//xori
          3'b010: AluControl = 3'b101;//slti
          3'b110: AluControl = 3'b001;//ori

        endcase

      end

      // S-type
      7'b0100011: begin
        MemWrite   = 1'b1;
        ALUSrc = 1'b1;
        ResultSrc  = 2'b10;
        PCSrc      = 2'b00;
        ImmSrc = 3'b001;

        case (func3)
          3'b010: AluControl = 3'b000;   // Sw
        endcase
      end

      // B-type
      7'b1100011: begin
        ImmSrc= 3'b010;
        AluControl = 3'b001;
	      ALUSrc = 1'b0;
        PCSrc=(func3==3'b000 && Zero==1'b1)?2'b01:
              (func3==3'b001 && Zero==1'b0)?2'b01:
              (func3==3'b100 && bge==1'b1)?2'b01:
              (func3==3'b101 && blt==1'b1)?2'b01:2'b00;
              
      end

      // U-type
      7'b0110111: begin
        RegWrite  = 1'b1;
        ResultSrc = 2'b11;
        ImmSrc    = 3'b011;
      end

      // J-type
      7'b1101111: begin
        RegWrite   = 1'b1;
        ALUSrc = 1'b1;
        ImmSrc     = 3'b100;
        AluControl = 3'b000;
        ResultSrc  = 2'b11;
        PCSrc = 2'b01;
        jump = 1'b1;
      end
     //lw
     7'b0000011: begin
        RegWrite   = 1'b1;
        ALUSrc = 1'b1;
        ImmSrc     = 3'b000;
        AluControl = 3'b000;
        ResultSrc  = 2'b01;
     end
     //jalr
     7'b1100111:begin
        PCSrc=2'b10;
        AluControl = 3'b000;
        RegWrite   = 1'b1;
        ALUSrc = 1'b1;
        ImmSrc     = 3'b000;
        ResultSrc  = 2'b11;
      end

    endcase
  end

 endmodule
