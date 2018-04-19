// radix-4 divider
module divider_r4
#(
parameter DATA_WIDTH = 32
)
(
  input wire rst_n,
  input wire clk,
  input wire [DATA_WIDTH - 1: 0] in1, //divident
  input wire [DATA_WIDTH - 1: 0] in2, //divisor
  input wire sign,
  input wire start,
  output reg [DATA_WIDTH - 1: 0] div_out_reg,
  output reg [DATA_WIDTH - 1: 0] rem_out_reg,
  output reg done_reg
);

localparam STATE_WIDTH = 2;
localparam CNT_WIDTH = 5;

//----------- 
  reg [STATE_WIDTH: 0] state_reg; 
  reg [CNT_WIDTH - 1: 0] cnt_reg; 

//-----------
  reg [DATA_WIDTH - 1: 0] result_reg, denom_reg, work_reg;
  reg done_1_reg;
  reg[DATA_WIDTH + 1: 0] denom3_reg;
  
  wire in1_sign = in1[DATA_WIDTH - 1] && sign;
  wire in2_sign = in2[DATA_WIDTH - 1] && sign;
  wire result_sign = (in1_sign ^ in2_sign) && (in2 != 0);
  
  wire [DATA_WIDTH - 1: 0] x = in1_sign? (~in1 + 1'b1): in1; //unsigned divident
  wire [DATA_WIDTH - 1: 0] y = in2_sign? (~in2 + 1'b1): in2; //unsigned divisor
	
  wire [DATA_WIDTH: 0] diff_y = {work_reg[DATA_WIDTH - 3: 0], result_reg[DATA_WIDTH - 1: DATA_WIDTH - 2]} - denom_reg; // work - y
  wire [DATA_WIDTH: 0] diff_2y_1 = {work_reg[DATA_WIDTH - 3: 0], result_reg[DATA_WIDTH - 1]} - denom_reg; // (work - 2 * y) >> 1
  wire [DATA_WIDTH + 1: 0] diff_2y = {diff_2y_1, result_reg[DATA_WIDTH - 2]}; // work - 2 * y
 
 // wire[DATA_WIDTH + 1: 0] denom_3 = denom_reg + {denom_reg, 1'b0}; // 3 * y
  wire [DATA_WIDTH + 2: 0] diff_3y = {work_reg[DATA_WIDTH - 3: 0], result_reg[DATA_WIDTH - 1: DATA_WIDTH - 2]} - denom3_reg; // work - 3 * y

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
	denom3_reg <= 0;
	work_reg <= 0;
	done_reg <= 0;
	done_1_reg <= 0;
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
		 denom3_reg <= y + {y, 1'b0};
	    work_reg <= 0;
	    cnt_reg <= DATA_WIDTH / 2 - 1;
		 done_1_reg <= 0;
	  end
	  // end of prev cycle
	  div_out_reg <= result_sign? (~result_reg + 1'b1): result_reg;
	  rem_out_reg <= in1_sign? (~work_reg[DATA_WIDTH - 1: 0] + 1'b1): work_reg[DATA_WIDTH - 1: 0];
	  done_reg <= done_1_reg;  
	end
    else if(state_reg == 1'b1)
	begin
	  done_reg <= 1'b0;	
	  if(diff_y[DATA_WIDTH]) // if (work - y) is negative
	  begin
	    work_reg <= {work_reg[DATA_WIDTH - 3: 0], result_reg[DATA_WIDTH - 1: DATA_WIDTH - 2]}; 
		 result_reg <= {result_reg[DATA_WIDTH - 2: 0], 2'b00};
	  end
	  else //if positive
	  begin 
	    if(diff_2y_1[DATA_WIDTH]) // if (work - 2y) is negative
		begin
		  work_reg <= diff_y[DATA_WIDTH - 1: 0];
		  result_reg <= {result_reg[DATA_WIDTH - 2: 0], 2'b01};
		end
		else
		begin
		  if(diff_3y[DATA_WIDTH + 1]) // if (work - 3y) is negative
		  begin
		    work_reg <= diff_2y[DATA_WIDTH - 1: 0]; 
			 result_reg <= {result_reg[DATA_WIDTH - 2: 0], 2'b10};
		  end
		  else
		  begin
	       work_reg <= diff_3y[DATA_WIDTH - 1:0];
			 result_reg <= {result_reg[DATA_WIDTH - 2: 0], 2'b11};
		  end
		end
	  end
	  if(cnt_reg == 0)
	  begin
	    state_reg <= 1'b0;
		 done_1_reg <= 1'b1;
	  end
	  cnt_reg <= cnt_next;
	end
  end
end

endmodule
