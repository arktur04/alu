module sign_mul 
#(
  parameter DATA_WIDTH = 32,
  parameter REG_WIDTH = 5
)
(
  input wire rst_n,
  input wire clk,
  input wire [DATA_WIDTH - 1: 0] in1,
  input wire s1,
  input wire [DATA_WIDTH - 1: 0] in2,
  input wire s2,
  input wire [REG_WIDTH - 1: 0] r1,
  input wire [REG_WIDTH - 1: 0] r2,
  output reg [DATA_WIDTH - 1: 0] outl_reg,
  output reg [DATA_WIDTH - 1: 0] outh_reg,
  output reg [REG_WIDTH - 1: 0] r1_reg,
  output reg [REG_WIDTH - 1: 0] r2_reg
);

localparam SHORT_WIDTH = DATA_WIDTH / 2;
  
//the 1st stage registers
/*
reg [DATA_WIDTH - 1: 0] in1_s1_reg;
reg [DATA_WIDTH - 1: 0] in2_s1_reg;
reg s_s1_reg;*/
// 2nd stage
reg [DATA_WIDTH - 1: 0] mul11_reg;
reg [DATA_WIDTH - 1: 0] mul12_reg;
reg [DATA_WIDTH - 1: 0] mul21_reg;
reg [DATA_WIDTH - 1: 0] mul22_reg;
reg s_s2_reg;
  reg [REG_WIDTH - 1: 0] r1_s2_reg;
  reg [REG_WIDTH - 1: 0] r2_s2_reg;
/*
// 3rd stage
reg [DATA_WIDTH: 0] mid_s3_reg;
reg [DATA_WIDTH * 2 - 1: 0] base_s3_reg;
reg s_s3_reg; */
// 4rd stage
reg [SHORT_WIDTH - 1: 0] lo_s4_reg;
reg [SHORT_WIDTH * 3 - 1: 0] hi_s4_reg;
reg s_s4reg;
reg [REG_WIDTH - 1: 0] r1_s4_reg;
reg [REG_WIDTH - 1: 0] r2_s4_reg;
// 5th stage
// outputs
//----------------------------------------
wire in1_s = s1 & in1[DATA_WIDTH - 1];
wire in2_s = s2 & in2[DATA_WIDTH - 1];

wire [DATA_WIDTH - 1: 0] in1_s1 = in1_s? ~in1 + 1'b1: in1;
wire [DATA_WIDTH - 1: 0] in2_s1 = in2_s? ~in2 + 1'b1: in2;
wire s_s1 = in1_s ^ in2_s;

wire [DATA_WIDTH - 1: 0] mul11 = in1_s1[SHORT_WIDTH - 1: 0] * in2_s1[SHORT_WIDTH - 1: 0];
wire [DATA_WIDTH - 1: 0] mul12 = in1_s1[SHORT_WIDTH - 1: 0] * in2_s1[DATA_WIDTH - 1: SHORT_WIDTH];
wire [DATA_WIDTH - 1: 0] mul21 = in1_s1[DATA_WIDTH - 1: SHORT_WIDTH] * in2_s1[SHORT_WIDTH - 1: 0];
wire [DATA_WIDTH - 1: 0] mul22 = in1_s1[DATA_WIDTH - 1: SHORT_WIDTH] * in2_s1[DATA_WIDTH - 1: SHORT_WIDTH];

wire [DATA_WIDTH * 2 - 1: 0] base_s3 = {mul22_reg, mul11_reg};
wire [DATA_WIDTH: 0] mid_s3 = mul12_reg + mul21_reg;

//wire [SHORT_WIDTH - 1: 0] lo_s4 = base_s3[SHORT_WIDTH - 1: 0];
//wire [SHORT_WIDTH * 3 - 1: 0] hi_s4 = base_s3[2 * DATA_WIDTH - 1: SHORT_WIDTH] + mid_s3;	
	

always@(posedge clk, negedge rst_n)
begin
  if(!rst_n)
  begin
    // the 1st stage regs
	//in1_s1_reg <= 0;
	//in2_s1_reg <= 0;
	//s_s1_reg <= 0;
	// the 2nd stage regs
	mul11_reg <= 0;
	mul12_reg <= 0;
	mul21_reg <= 0;
	mul22_reg <= 0;
	s_s2_reg <= 0;
	r1_s2_reg <= 0;
	r2_s2_reg <= 0;
	// the 3rd stage regs
	//mid_s3_reg <= 0;
	//s_s3_reg <= 0;
	//base_s3_reg <= 0;
	// the 4rd stage regs
	lo_s4_reg <= 0;
   hi_s4_reg <= 0;
	s_s4reg <= 0;
	r1_s4_reg <= 0;
	r2_s4_reg <= 0;
	// output of the second stage
	outl_reg <= 0;
	outh_reg <= 0;
	r1_reg <= 0;
	r2_reg <= 0;
  end
  else
  begin  
    // 1st stage
   // in1_s1_reg <= in1_s? ~in1 + 1'b1: in1;
	// in2_s1_reg <= in2_s? ~in2 + 1'b1: in2;
   // s_s1_reg <= in1_s ^ in2_s;
    //-------------------
	// 2nd stage
	mul11_reg <= mul11;
	mul12_reg <= mul12;
	mul21_reg <= mul21;
	mul22_reg <= mul22;
	s_s2_reg <= s_s1; //s_s1_reg;
   r1_s2_reg <= r1;
	r2_s2_reg <= r2;
	//-------------------
	// 3rd stage
	/*
	mid_s3_reg <= mid_s3;
	base_s3_reg <= base_s3;
	s_s3_reg <= s_s2_reg;
	//-------------------
	// 4th stage
	lo_s4_reg <= base_s3_reg[SHORT_WIDTH - 1: 0];
	hi_s4_reg <= base_s3_reg[3 * SHORT_WIDTH - 1: SHORT_WIDTH] + mid_s3_reg;
	s_s4reg <= s_s3_reg;
	
	*/
	lo_s4_reg <= base_s3[SHORT_WIDTH - 1: 0];
	hi_s4_reg <= base_s3[2 * DATA_WIDTH - 1: SHORT_WIDTH] + mid_s3;
	s_s4reg <= s_s2_reg;
	r1_s4_reg <= r1_s2_reg;
	r2_s4_reg <= r2_s2_reg;
	//-------------------
	// 5th stage	
   outl_reg <= s_s4reg? ~lo_s4_reg + 1'b1: lo_s4_reg;
	outh_reg <= s_s4reg? ~hi_s4_reg + (lo_s4_reg == {SHORT_WIDTH{1'b0}}): hi_s4_reg;
	r1_reg <= r1_s4_reg;
	r2_reg <= r2_s4_reg;
  end
end

endmodule
