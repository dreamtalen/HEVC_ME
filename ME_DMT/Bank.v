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
input beg_en,               	 	 //input enable,synchronization with data 
input [8*`PIXEL-1:0] ref_in, 	     //reference input,8 pixels=64bit
input Bank_sel,     				 //if Bank_sel=1,enable to storage
input [6:0] address,			      //according address to select 1 data(8 pixels)
input rd_en,	
output reg [8*`PIXEL-1:0] ref_ou	     //output 1 data(8 pixels) of Bank
//output reg da_va                 	 //data valid,synchronization with ref_ou
);

//beg_en   x 1 1 1 1
//Bank_sel _ 1 1 1 1 
//ref_in   x D D D
//me_cnt     0 1 2

//这行删去，下面已经实例化了Memory
// reg [8*`PIXEL-1:0] mem [95:0]; //to create a memery, width is 64 bit,depth is 96

reg [6:0] me_cnt;            //when the memeroy is full,write again(coverage previous data)
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  me_cnt<=0;
else if(beg_en)
begin
	 if(Bank_sel)
		  begin
		  if(me_cnt<95)       //mem_cnt:0-95
			 me_cnt<=me_cnt+1;
		  else 
			 me_cnt<=0;
		  end
		  
end
end

S65NLLHSDPH_X40Y4D64 i_ram(
  .QA(ref_ou),
  .QB(),
  .CLKA(clk),
  .CLKB(clk),
  .CENA(rd_en),
  .CENB(Bank_sel),
  .WENA(1'b0),
  .WENB(Bank_sel),
  .AA({1'b0,address}),
  .AB({1'b0,me_cnt }),
  .DA(),
  .DB(ref_in)
);

endmodule
