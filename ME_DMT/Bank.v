//1 Bank: bitWidth=64bit(8 Pixels),depth is 96
//after store 24 clk period(8 pixel each clk),wait other Bank write 24 clk period seperately
//....
//this Bank will write 4 times(each time write 24 clk period)
//next time the data will coverage

`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Bank(
input clk,
input rst_n,
input [8*`PIXEL-1:0] ref_in, 	     //reference input,8 pixels=64bit
input Bank_sel,     				 //if Bank_sel=0,enable to storage
input [6:0] address,			      //according address to select 1 data(8 pixels)
input [6:0] write_address,
input rd_en,	
output [8*`PIXEL-1:0] ref_ou	     //output 1 data(8 pixels) of Bank
//output reg da_va                 	 //data valid,synchronization with ref_ou
);

S65NLLHSDPH_X40Y4D64 i_ram(
  .QA(ref_ou),
  .QB(),
  .CLKA(clk),
  .CLKB(clk),
  .CENA(rd_en),
  .CENB(Bank_sel),
  .WENA(1'b1),
  .WENB(Bank_sel),
  .AA({1'b0,address}),
  .AB({1'b0,write_address}),
  .DA(),
  .DB(ref_in)
);

endmodule
