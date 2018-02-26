`timescale 1ns/1ps
`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Ref_mem_tb;
reg clk;
reg rst_n;
reg [32*`PIXEL-1:0] ref_input;     
reg [31:0] Bank_sel;        
reg [6:0] rd_address;    
reg [7*32-1:0] write_address_all;
reg rd8R_en;       
reg [3:0] rdR_sel;       
wire [2047:0] ref_8R_32;     
wire Oda8R_va;      
wire da1R_va;

Ref_mem ref_mem(.clk(clk), .rst_n(rst_n), .ref_input(ref_input), .Bank_sel(Bank_sel), .rd_address(rd_address),
	.write_address_all(write_address_all), .rd8R_en(rd8R_en), .rdR_sel(rdR_sel), .ref_8R_32(ref_8R_32), .Oda8R_va(Oda8R_va), .da1R_va(da1R_va));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	// 给mem写数据
	ref_input = { 32{8'b00000001} };
	Bank_sel = 32'b00000000000000000000000000001111;
	write_address_all = 224'b0;
	#100 ref_input = { 32{8'b00000010} };
	Bank_sel = 32'b00000000000000000000000011110000;
	#100 rd_address = 7'b0000000;
	rd8R_en = 1'b0;
	rdR_sel = 4'b0000;
	#5 rd_address = 7'b0000000;

end

initial
	$monitor($time, " ref_8R_32 = %h", ref_8R_32[255:0]);

endmodule