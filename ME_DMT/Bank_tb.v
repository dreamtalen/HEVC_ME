`timescale 1ns/1ps
`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Bank_tb;
reg clk;
reg rst_n;
reg beg_en;
reg [8*`PIXEL-1:0] ref_in;
reg Bank_sel;
reg [6:0] address;
reg rd_en;
wire [8*`PIXEL-1:0] ref_ou;

Bank bank(.clk(clk), .rst_n(rst_n), .beg_en(beg_en), .ref_in(ref_in), .Bank_sel(Bank_sel),
	.address(address), .rd_en(rd_en), .ref_ou(ref_ou));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	beg_en = 1'b1;
	ref_in = { 8{8'b00001111} };
	Bank_sel = 1'b1;
	address = 7'b0;
	rd_en = 1'b0;
	#30 ref_in = { 8{8'b01010101} };
	#30 ref_in = { 8{8'b00110011} };
end

initial
	$monitor($time, " ref_ou = %b", ref_ou);
endmodule
