module Ref_mem_shift(
input clk,
input rst_n,
input [2047:0] ref_input,
input [4:0] shift_value, //左移的mem数量
output reg [2047:0] ref_output
);

always @(posedge clk or negedge rst_n) begin
	if (!rst) begin
		ref_output <= ref_input;
	end
	else begin
		if (shift_value == 0) begin
			ref_output <= ref_input;
		end
		else begin
			ref_output <= {ref_input[shift_value*256-1:0], ref_input[2047:shift_value*256]};
		end
	end
end
