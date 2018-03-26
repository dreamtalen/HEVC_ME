module SAD_comp_tb;
reg clk;
reg rst_n;
reg [415:0] SAD4x8;
reg [415:0] SAD8x4;
reg [223:0] SAD8x8;
reg [119:0] SAD8x16;
reg [119:0] SAD16x8;
reg [63:0] SAD16x16;
wire [415:0] min_SAD4x8;
wire [415:0] min_SAD8x4;
wire [223:0] min_SAD8x8;
wire [119:0] min_SAD8x16;
wire [119:0] min_SAD16x8;
wire [63:0] min_SAD16x16;

SAD_comp sad_comp(.clk(clk), .rst_n(rst_n), .SAD4x8(SAD4x8), .SAD8x4(SAD8x4), .SAD8x8(SAD8x8),
	.SAD8x16(SAD8x16), .SAD16x8(SAD16x8), .SAD16x16(SAD16x16), .min_SAD4x8(min_SAD4x8),
	.min_SAD8x4(min_SAD8x4), .min_SAD8x8(min_SAD8x8), .min_SAD8x16(min_SAD8x16), 
	.min_SAD16x8(min_SAD16x8), .min_SAD16x16(min_SAD16x16));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	SAD4x8 = { 32{13'b0000000000011} };
	#10
	SAD4x8 = { 32{13'b0000000000001} };
end

endmodule
