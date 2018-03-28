module SAD_Tree(
	input clk,
	input rst_n,
	input [8191:0] abs_outs,
	output reg [415:0] SAD4x8,
	output reg [415:0] SAD8x4,
	output reg [223:0] SAD8x8,
	output reg [119:0] SAD8x16,
	output reg [119:0] SAD16x8,
	output reg [63:0] SAD16x16,
	output reg [17:0] SAD32x32
);


endmodule