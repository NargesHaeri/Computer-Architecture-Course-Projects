`timescale 1ns/1ns

module Controller (
  input clk,rst,
  input [6:0] OPC,
  input [2:0] func3,
  input [6:0] func7,
  input Zero,blt,bge,
  output reg RegWrite,
  output reg MemWrite,
  output reg [1:0]ALUSrcA,
  output reg [1:0]ALUSrcB,
  output reg IRWrite,
  output reg AdrSrc,
  output reg [1:0] ResultSrc,
  output reg [2:0] AluControl,
  output reg [2:0] ImmSrc,
  output reg PCWrite
);
reg branchEq,branchNe,branchge,branchlt;
 reg [4:0] ns, ps;
  parameter [4:0] IF = 0, ID = 1, Btype= 2,lui= 3,Sw = 4, lw= 5,jalr = 6,  jal= 7,Rtype=8,Itype=9,
                    mem1=10,mem2=11,mem3=12,mem4=13,mem5=14,mem6=15,wb1=16,wb2=17,wb3=18;
  always@* begin
    RegWrite   = 1'b0;
    MemWrite   = 1'b0;
    ALUSrcA    = 2'b00;
    ALUSrcB    = 2'b00;
    ResultSrc  = 2'b00;
    AluControl = 3'b000;
    ImmSrc     = 3'b000;
    PCWrite    = 1'b0;
    branchEq   = 1'b0;
    branchNe   = 1'b0;
    branchge   = 1'b0;
    branchlt   = 1'b0;
    AdrSrc     = 1'b0;
    IRWrite    = 1'b0;

    ns = IF;
    case(ps)
      IF :begin
         ns = ID;
         IRWrite=1'b1;
         ALUSrcA=2'b00;
         ALUSrcB=2'b10;
         AluControl=3'b000;
         ResultSrc=2'b10;
         PCWrite=1'b1;
      end

      ID :begin
        ALUSrcA=2'b01;
        ALUSrcB=2'b01;
        AluControl=3'b000;
        ImmSrc=3'b010;
        case(OPC)
          7'b0110011 : ns = Rtype;
          7'b0010011 : ns = Itype;
          7'b0100011 : ns = Sw;
          7'b1100011 : ns = Btype;
          7'b0110111 : ns = lui;
          7'b1101111 : ns = jal;
          7'b1100111 : ns = jalr;
          7'b0000011 : ns = lw;
        endcase
      end

      Rtype:begin 
        ns = mem1;
        ALUSrcA=2'b10;
        ALUSrcB=2'b00;
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
      
      mem1:begin 
        ResultSrc=2'b00;
        RegWrite=1'b1;
      end

      Itype:begin 
        ns=mem3;
        ALUSrcA=2'b10;
        ALUSrcB=2'b01;
	      ImmSrc=3'b000;
        case(func3)
          3'b000: AluControl = 3'b000;//addi
          3'b100: AluControl = 3'b111;//xori
          3'b010: AluControl = 3'b101;//slti
          3'b110: AluControl = 3'b001;//ori 
        endcase
      end

      lw : begin 
        ns=mem4;
        ALUSrcA=2'b10;
        ALUSrcB=2'b01;
        AluControl = 3'b000;
        ImmSrc=3'b000;
      end
        
      mem3 :begin 
        ns=IF;
        RegWrite=1'b1;
        ResultSrc=2'b00;
      end

      mem4 :begin 
        ns=wb1;
        ResultSrc=2'b00;
        AdrSrc=1'b1;
      end

      wb1 :begin 
        ns=IF;
        ResultSrc=2'b01;
        RegWrite=1'b1;
      end

      Sw : begin 
        ns=mem2;
        ImmSrc=3'b001;
        AluControl = 3'b000;
        ALUSrcA=2'b10;
        ALUSrcB=2'b01;
      end

      mem2 :begin 
        ns=IF;
        MemWrite=1'b1;
        ResultSrc=2'b00;
        AdrSrc=1'b1;
      end

      Btype : begin //BTYPE
        ns=IF;
        ALUSrcA=2'b10;
        ALUSrcB=2'b00;
        AluControl = 3'b001;
        ResultSrc=2'b00;
        PCWrite=(func3==3'b000 && Zero==1'b1)?1'b1:
	            (func3==3'b001 && Zero==1'b0)?1'b1:
              (func3==3'b100 && bge==1'b1)?1'b1:
              (func3==3'b101 && blt==1'b1)?1'b1:1'b0;
      end

      lui :begin
        ns = IF;
        ResultSrc=2'b11;
        ImmSrc=3'b011;
        RegWrite=1'b1;
      end

      jal :begin
        ns = mem5;
        ALUSrcA=2'b01;
        ALUSrcB=2'b01;
        AluControl = 3'b000;
        ImmSrc=3'b100;
      end

      mem5:begin
        ns = wb2;
        ResultSrc=2'b00;
        ALUSrcA=2'b01;
        ALUSrcB=2'b10;
        AluControl=3'b000;
        PCWrite=1'b1;
      end

      wb2 :begin 
        ns=IF;
        ResultSrc=2'b00;
        RegWrite=1'b1;
      end

      jalr :begin
        ns = mem6;
        ALUSrcA=2'b10;
        ALUSrcB=2'b01;
        AluControl = 3'b000;
        ImmSrc=3'b000;
      end

      mem6:begin
        ns = wb3;
        ResultSrc=2'b00;
        ALUSrcA=2'b01;
        ALUSrcB=2'b10;
        AluControl=3'b000;
        PCWrite=1'b1;
      end

      wb3 :begin 
        ns=IF;
        ResultSrc=2'b00;
        RegWrite=1'b1;
      end 

    endcase
  end

  always@(posedge clk, posedge rst)begin
    if(rst)
      ps <= IF;
    else
      ps <= ns;
  end
  
endmodule
