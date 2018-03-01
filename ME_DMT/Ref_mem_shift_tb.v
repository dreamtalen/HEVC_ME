module Ref_mem_shift_tb;
reg [2047:0] ref_input;
reg [4:0] shift_value;
wire [2047:0] ref_output;

Ref_mem_shift ref_mem_shift(
	.ref_input(ref_input),
	.shift_value(shift_value),
	.ref_output(ref_output)
	);

initial
begin
	ref_input = {24{64'b1}, 8{64'b0}};
	shift_value = 8;
	#50 shift_value = 0;
	#50 shift_value = 16;
end

initial
	$monitor($time, " ref_output = %b", ref_output);

endmodule