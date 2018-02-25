`timescale 1ns/1ps
`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Bank_tb;
reg clk;
reg rst_n;
reg [8*`PIXEL-1:0] ref_in;
reg Bank_sel;
reg [6:0] address;
reg [6:0] write_address;
reg rd_en;
wire [8*`PIXEL-1:0] ref_ou;

Bank bank(.clk(clk), .rst_n(rst_n), .ref_in(ref_in), .Bank_sel(Bank_sel),
	.address(address), .write_address(write_address), .rd_en(rd_en), .ref_ou(ref_ou));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	// 已修改，（先从B端口写入一些数据，地址由bank自动生成1，2，..96）
	Bank_sel = 1'b0;
	write_address = 7'b0000000;
	ref_in = { 8{8'b00000000} };
	#30 ref_in = { 8{8'b00000001} };
	write_address = 7'b0000001;
	#30 ref_in = { 8{8'b00000011} };
	write_address = 7'b0000011;
	#30 ref_in = { 8{8'b00000100} };
	write_address = 7'b0000100;
	#30 ref_in = { 8{8'b00000101} };
	write_address = 7'b0000101;
	

	#100 address = 7'b0000000;
	rd_en = 1'b0;
	#10 address = 7'b0000001;
	#10 address = 7'b0000011;
	#10 address = 7'b0000100;
	#10 address = 7'b0000101;
end

initial
	$monitor($time, " ref_ou = %b", ref_ou);
endmodule
