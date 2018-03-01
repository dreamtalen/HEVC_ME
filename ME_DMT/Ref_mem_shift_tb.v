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
	ref_input = {512{4'b1100}};
	shift_value = 1;
	#50 shift_value = 2;
	#50 shift_value = 7;
end

initial
	$monitor($time, " ref_output = %b", ref_output);

endmodule