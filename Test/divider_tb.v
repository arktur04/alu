`timescale 1ns/1ns

module divider_tb();

`define DATA_WIDTH 32
`define MAX_LINE_LENGTH 1000 

reg clk, rst_n, start;
integer test_file, status, i, sign_char;
reg [`DATA_WIDTH - 1: 0] in1, in2, div_expected, rem_expected;
reg sign;
wire [`DATA_WIDTH - 1: 0] div_actual, rem_actual;
wire done;
reg [`MAX_LINE_LENGTH * 8: 1] comment;
reg error;

always #5 clk = ~clk;

initial
begin
  error = 0;
  clk = 1'b0;
  rst_n = 1'b0;
  start = 0;
  #10 rst_n = 1'b1;
  #10;
  //------------
  test_file = $fopen("test_file.txt", "r");  // open file
  i = 0;
  while ( ! $feof(test_file)) //loop for file
  begin  
    @(negedge clk); 
    status = $fscanf(test_file,"%c %h %h %h %h", sign_char, in1, in2, div_expected, rem_expected); // парсим очередную строку
    status = $fgets(comment, test_file); // skip comment
    i = i + 1;
	if(sign_char == "u")
	  sign = 0; //unsigned
	else
	  sign = 1; //signed
	// start pulse
	start = 1;
    @(negedge clk);
	 start = 0;
	 //wait when DUT finish calculation
	@(posedge done);
	// compare the answer with expected
	if(div_expected != div_actual || rem_expected != rem_actual)
      error = 1;
  end
  // close file and stop
  $fclose(test_file);
  #100 $stop; 
end

divider divider_i(
   //inputs
  .rst_n(rst_n),
  .clk(clk),
  .in1(in1),
  .in2(in2),
  .sign(sign),
  .start(start),
  //outputs
  .div_out_reg(div_actual),
  .rem_out_reg(rem_actual),
  .done_reg(done)
);

endmodule
