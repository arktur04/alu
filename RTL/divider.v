module divider 
#(
  parameter DATA_WIDTH = 32
)
(
  input wire rst_n,
  input wire clk,
  input wire [DATA_WIDTH - 1: 0] in1, //divident
  input wire [DATA_WIDTH - 1: 0] in2, //divisor
  input wire sign, // signed division if sign == 1, unsigned otherwise
  input wire start, // start calculation
  output reg [DATA_WIDTH - 1: 0] div_out_reg,
  output reg [DATA_WIDTH - 1: 0] rem_out_reg,
  output reg done_reg // done == 1 when 
);
  localparam STATE_WIDTH = 2;
  localparam CNT_WIDTH = 5;

  //----------- 
  // state registers
  reg [STATE_WIDTH: 0] state_reg; 
  reg [CNT_WIDTH - 1: 0] cnt_reg; 
  //-----------
  // working registers
  reg [DATA_WIDTH - 1: 0] result_reg, denom_reg, work_reg;
  // wires
  wire in1_sign = in1[DATA_WIDTH - 1] && sign;
  wire in2_sign = in2[DATA_WIDTH - 1] && sign;
  wire result_sign = (in1_sign ^ in2_sign) && (in2 != 0);
  wire [DATA_WIDTH - 1: 0] x = in1_sign? (~in1 + 1'b1): in1; //unsigned divident
  wire [DATA_WIDTH - 1: 0] y = in2_sign? (~in2 + 1'b1): in2; //unsigned divisor
  wire [DATA_WIDTH: 0]  diff = {work_reg[DATA_WIDTH - 2: 0], result_reg[31]} - denom_reg;
  wire [4: 0] cnt_next = cnt_reg - 1'b1;
  
  always@(posedge clk, negedge rst_n)
  begin
    if(!rst_n)
    begin
      div_out_reg <= 0;
      rem_out_reg <= 0;
      state_reg <= 0;
      cnt_reg <= 0;
      result_reg <= 0;
      denom_reg <= 0;
      work_reg <= 0;
      done_reg <= 0;
    end
    else
    begin
      if(state_reg == 1'b0)
      begin
        if(start)
        begin
          state_reg <= 1'b1;
          result_reg <= x;
          denom_reg <= y;
          work_reg <= 0;
          cnt_reg <= 5'h1f;
          done_reg <= 1'b0;      
        end
        // the end of prev cycle
        div_out_reg <= result_sign? (~result_reg + 1'b1): result_reg;
        rem_out_reg <= in1_sign? (~work_reg[DATA_WIDTH - 1: 0] + 1'b1): work_reg[DATA_WIDTH - 1: 0];
        done_reg <= 1'b1;
      end
    else if(state_reg == 1'b1)
    begin
      if(diff[DATA_WIDTH]) // if negative
      begin
        work_reg <= {work_reg[DATA_WIDTH - 2:0], result_reg[DATA_WIDTH - 1]}; 
      end
      else //if positive
      begin 
        work_reg <= diff[DATA_WIDTH - 1:0]; 
      end
      result_reg <= {result_reg[DATA_WIDTH - 2: 0], !diff[DATA_WIDTH]}; 
      if(cnt_reg == 0)
      begin
        state_reg <= 1'b0;
      end
      cnt_reg <= cnt_next;
    end
  end
end

endmodule
