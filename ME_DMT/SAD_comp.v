module SAD_comp(
	input clk,
	input rst_n,
	input [415:0] SAD4x8,
	input [415:0] SAD8x4,
	input [223:0] SAD8x8,
	input [119:0] SAD8x16,
	input [119:0] SAD16x8,
	input [63:0] SAD16x16,
	input [17:0] SAD32x32,
	output reg [415:0] min_SAD4x8,
	output reg [415:0] min_SAD8x4,
	output reg [223:0] min_SAD8x8,
	output reg [119:0] min_SAD8x16,
	output reg [119:0] min_SAD16x8,
	output reg [63:0] min_SAD16x16,
	output reg [17:0] min_SAD32x32
);

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
		min_SAD4x8 <= -1;
		min_SAD8x4 <= -1;
		min_SAD8x8 <= -1;
		min_SAD8x16 <= -1;
		min_SAD16x8 <= -1;
		min_SAD16x16 <= -1;
		min_SAD32x32 <= -1;
	end
end

generate
	genvar i;
	for (i = 0; i < 32; i = i + 1)
	begin: cal_min_32
	always @(posedge clk) begin
		if (min_SAD4x8[(i*13+12):(i*13)] > SAD4x8[(i*13+12):(i*13)]) begin
			min_SAD4x8[(i*13+12):(i*13)] <= SAD4x8[(i*13+12):(i*13)];
		end
		if (min_SAD8x4[(i*13+12):(i*13)] > SAD8x4[(i*13+12):(i*13)]) begin
			min_SAD8x4[(i*13+12):(i*13)] <= SAD8x4[(i*13+12):(i*13)];
		end
	end
	end
	genvar j;
	for (j = 0; j < 16; j = j + 1)
	begin: cal_min_64
	always @(posedge clk) begin
		if (min_SAD8x8[(j*14+13):(j*14)] > SAD8x8[(j*14+13):(j*14)]) begin
			min_SAD8x8[(j*14+13):(j*14)] <= SAD8x8[(j*14+13):(j*14)];
		end
	end
	end
	genvar k;
	for (k = 0; k < 8; k = k + 1)
	begin: cal_min_128
	always @(posedge clk) begin
		if (min_SAD8x16[(k*15+14):(k*15)] > SAD8x16[(k*15+14):(k*15)]) begin
			min_SAD8x16[(k*15+14):(k*15)] <= SAD8x16[(k*15+14):(k*15)];
		end
		if (min_SAD16x8[(k*15+14):(k*15)] > SAD16x8[(k*15+14):(k*15)]) begin
			min_SAD16x8[(k*15+14):(k*15)] <= SAD16x8[(k*15+14):(k*15)];
		end
	end
	end
	genvar l;
	for (l = 0; l < 4; l = l + 1)
	begin: cal_min_256
	always @(posedge clk) begin
		if (min_SAD16x16[(l*16+15):(l*16)] > SAD16x16[(l*16+15):(l*16)]) begin
			min_SAD16x16[(l*16+15):(l*16)] <= SAD16x16[(l*16+15):(l*16)];
		end
	end
	end
endgenerate

always @(posedge clk) begin
	if (min_SAD32x32 > SAD32x32) begin
		min_SAD32x32 <= SAD32x32;
	end
end

endmodule