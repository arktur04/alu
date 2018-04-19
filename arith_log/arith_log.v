module arith_log 
#(
  parameter DATA_WIDTH = 32;
  parameter CMD_WIDTH = 3
)
(
  input wire rst_n,
  input wire clk,
  input wire [DATA_WIDTH - 1: 0] in1, //divident
  input wire [DATA_WIDTH - 1: 0] in2, //divisor
  input wire sign, // for SLT/SLTU command: if sign = 1 (signed input), SLT performs, otherwise SLTU
  // command codes
  // 0 - AND
  // 1 - OR
  // 2 - XOR
  // 3 - SLT/SLTU  
  // 4 - ADD
  // 5 - SUB
  input wire [CMD_WIDTH - 1: 0] cmd, // command code
  output reg [DATA_WIDTH - 1: 0] out_reg
);
  localparam AND_CMD = 0;
  localparam OR_CMD = 1;
  localparam XOR_CMD = 2;
  localparam SLT_CMD = 3;
  localparam ADD_CMD = 4;
  localparam SUB_CMD = 5;
  
  wire [DATA_WIDTH - 1: 0] and_res = in1 & in2;
  wire [DATA_WIDTH - 1: 0] or_res = in1 | in2;
  wire [DATA_WIDTH - 1: 0] xor_res = in1 ^ in2;
  wire sltu = in1 > in2;
  wire slt = {~in1[DATA_WIDTH - 1], in1[DATA_WIDTH - 2: 0]} > {~in2[DATA_WIDTH - 1], in2[DATA_WIDTH - 2: 0]};
  wire [DATA_WIDTH - 1: 0] slt_res = {{DATA_WIDTH - 1{1'b0}}, sign? slt: sltu};
  wire [DATA_WIDTH - 1: 0] add_res = in1 + in2;
  wire [DATA_WIDTH - 1: 0] sub_res = in1 - in2;
  
  always@(posedge clk, negedge rst_n)
  begin
    if(!rst_n)
    begin
      out_reg <= 0;
    end
    else
    begin
      if(cmd == AND_CMD)
      begin
	    out_reg <= and_res;
      end
	  else if(cmd == OR_CMD)
      begin
	    out_reg <= or_res;
      end
	  else if(cmd == XOR_CMD)
      begin
	    out_reg <= xor_res;
      end
	  else if(cmd == SLT_CMD)
      begin
	    out_reg <= slt_res;
      end
	  else if(cmd == ADD_CMD)
      begin
	    out_reg <= add_res;
      end
	  else if(cmd == SUB_CMD)
      begin
	    out_reg <= sub_res;
      end
    end
end

endmodule
