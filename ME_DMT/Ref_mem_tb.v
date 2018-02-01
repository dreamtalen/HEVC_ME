`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Ref_mem_tb;
reg clk;
reg rst_n;
reg [32*`PIXEL-1:0] ref_input;     
reg beg_en;        
reg [6:0] rd_address;    
reg rd8R_en;       
reg [3:0] rdR_sel;       
wire [2047:0] ref_8R_32;     
wire Oda8R_va;      
wire da1R_va;

Ref_mem ref_mem(.clk(clk), .rst_n(rst_n), .ref_input(ref_input), .beg_en(beg_en), .rd_address(rd_address),
	.rd8R_en(rd8R_en), .rdR_sel(rdR_sel), .ref_8R_32(ref_8R_32), .Oda8R_va(Oda8R_va), .da1R_va(da1R_va));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	ref_input = { 32{8'b00001111} };
	beg_en = 1'b1;
	rd_address = 7'b0000000;
	rd8R_en = 1'b0;
	rdR_sel = 4'b0000;
	#5 rd_address = 7'b0000001;
end

initial
	$monitor($time, " ref_8R_32 = %h", ref_8R_32);

endmodule