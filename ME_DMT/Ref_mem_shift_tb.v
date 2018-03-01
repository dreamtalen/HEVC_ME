module Ref_mem_shift_tb;
reg clk;
reg rst_n;
reg [2047:0] ref_input;
reg [4:0] shift_value;
wire [2047:0] ref_output;

Ref_mem_shift ref_mem_shift(
	.clk(clk),
	.rst_n(rst_n),
	.ref_input(ref_input),
	.shift_value(shift_value),
	.ref_output(ref_output)
	);

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	ref_input = {24{64'b1}, 8{64'b0}};
	shift_value = 8;
	#50 shift_value = 0;
	#50 shift_value = 16;
end

initial
	$monitor($time, " ref_output = %b", ref_output);

endmodule