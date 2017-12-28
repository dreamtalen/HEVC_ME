`define PIXEL 8
`define X 32
`define BAND_WIDTH_X `PIXEL*`X

module current_comb_32pixel(             //串并转换 2pixels to 32pixels
input clk,
input rst_n,
input [2*`PIXEL-1:0] current_2pixels,
input in_curr_enable,
output reg[`BAND_WIDTH_X-1:0] current_pixels, //the 255 254 ...0bit
output reg curr_ready_32
);

reg [3:0] cnt_15;

//--------------------because the first clk input is xxxx,in ordet the input ahead 1 clk ,or accept the data delay 1clk
reg in_curr_enable_delay_1;
always@(posedge clk)
in_curr_enable_delay_1<=in_curr_enable;


always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  cnt_15<=0;
else if((cnt_15<4'd15)&&in_curr_enable_delay_1)
  cnt_15<=cnt_15+4'd1;                      //0 1 2 3 4 ...... 15 0
else
  cnt_15<=0;   
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
 begin
  current_pixels<=256'd0;
  curr_ready_32<=0;
 end
else if(in_curr_enable_delay_1)
  begin
    case(cnt_15)
	'd0 :begin
	     curr_ready_32<=0;
	     current_pixels[2*`PIXEL-1 :0                  ]<=current_2pixels; //the 2pix,1pix
		end
	'd1 :current_pixels[4*`PIXEL-1 :4 *`PIXEL-2 *`PIXEL]<=current_2pixels; //the 4pix,3pix
	'd2 :current_pixels[6*`PIXEL-1 :6 *`PIXEL-2 *`PIXEL]<=current_2pixels; //the 6pix,5pix
	'd3 :current_pixels[8*`PIXEL-1 :8 *`PIXEL-2 *`PIXEL]<=current_2pixels; //...
	'd4 :current_pixels[10*`PIXEL-1:10*`PIXEL-2 *`PIXEL]<=current_2pixels; 
	'd5 :current_pixels[12*`PIXEL-1:12*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd6 :current_pixels[14*`PIXEL-1:14*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd7 :current_pixels[16*`PIXEL-1:16*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd8 :current_pixels[18*`PIXEL-1:18*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd9 :current_pixels[20*`PIXEL-1:20*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd10:current_pixels[22*`PIXEL-1:22*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd11:current_pixels[24*`PIXEL-1:24*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd12:current_pixels[26*`PIXEL-1:26*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd13:current_pixels[28*`PIXEL-1:28*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd14:current_pixels[30*`PIXEL-1:30*`PIXEL-2*`PIXEL]<=current_2pixels; 
	'd15:begin
	     current_pixels[32*`PIXEL-1:32*`PIXEL-2*`PIXEL]<=current_2pixels; //the 32pix,31pix	
		 curr_ready_32<=1;
		 end
	endcase
  end
end

endmodule