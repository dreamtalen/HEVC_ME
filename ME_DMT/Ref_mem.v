`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Ref_mem(               //need to modify : 只需实现从8行选择一行的功能
input    	 		        clk,
input 				        rst_n,
input [32*`PIXEL-1:0] ref_input,     //input 4*8pixels, which is 32pixels*8bit=256bit
input [31:0]          Bank_sel,      //select one Bank (total is 32 Bank) to store, 32'b1-Bank1,32'b2-Bank2,....,32'b1000 0000_0000 0000_0000 0000_0000 0000-Bank32
input [6:0] 	        rd_address,    //控制读的是96行的哪一行address is the depth of Bank,value:0-95
input [7*32-1:0]      write_address_all, //32个ram的写地址集合
input 				        rd8R_en,       //read enable,read 8 rows from 32Bank, rd_en = 0 begin read
input [3:0]			      rdR_sel,       //控制读这一行(8小行像素)的第几小行read mode select(called:read rows select),it can select one row(row1~row8) or 8 rows output,synchronization with address,read_en.value：0-8 
output reg [2047:0]   ref_8R_32,     //output 8row*32clomn=256pixels,which is 256pixels*8bit=2048bit 
output reg            Oda8R_va,      //data vlid for 1 clk if get only one 8 rows data,synchronization with ref_8R_32
output reg            da1R_va        //valid for 8 clk,enough to read 8 rows,synchronization with ref_1R_32
);

wire [8*32*`PIXEL-1:0] ref_ou; 
genvar j;
generate for(j=0;j<32;j=j+1)
     begin:Bank_32     
      Bank in_Bank(
        .clk(clk),
        .rst_n(rst_n),
        .ref_in(ref_input[64*(j%4+1)-1:64*(j%4)]),  //reference input,8 pixels=64bit
        .Bank_sel(~Bank_sel[j]),                    //if Bank_sel=1,enable to storage
        .address(rd_address),                       //according address to select 1 data(8 pixels)
        .write_address(write_address_all[7*(j+1)-1:7*j]),
        .rd_en(rd8R_en),                                      //read_enable
        .ref_ou(ref_ou[8*`PIXEL*(j+1)-1:8*`PIXEL*j])   //output 1 data(8 pixels) of Bank
        );
    end   
endgenerate

//wire data_valid=&da8R_va;                                              //due to read data is according to row, combine all data_valid to one bit      
//-----------------------------------data_valid
reg da8R_va;                                                             //data_valid from Bank(8 rows)
always@(posedge clk or negedge rst_n)
begin
if(!rst_n) 
  da8R_va<=0;
else
  da8R_va<=rd8R_en;    
end

//-----------------------------------instance row(8 rows)
wire [32*`PIXEL-1:0] ref_row1;
wire [32*`PIXEL-1:0] ref_row2;
wire [32*`PIXEL-1:0] ref_row3;
wire [32*`PIXEL-1:0] ref_row4;
wire [32*`PIXEL-1:0] ref_row5;
wire [32*`PIXEL-1:0] ref_row6;
wire [32*`PIXEL-1:0] ref_row7;
wire [32*`PIXEL-1:0] ref_row8;

Row_sep in_row_sep(
					.ref_ou(ref_ou),
					.ref_row1(ref_row1),
					.ref_row2(ref_row2),
					.ref_row3(ref_row3),
					.ref_row4(ref_row4),
					.ref_row5(ref_row5),
					.ref_row6(ref_row6),
					.ref_row7(ref_row7),
					.ref_row8(ref_row8)
);
//assign ref_8R_32=ref_ou;

//da_va       0 1  1  1  1  1     //data valid for 8 rows data from 32 bank
//ref_ou        D  D  D  D  D
//ref_row1      D1 D1 D1 D1 D1
//ref_row2      D2 D2 D2 D2 D2
//....
//ref_row8      D8 D8 D8 D8 D8
//rdR_sel: s s s s

//-----------------------------------output 8 rows data or 1 row data, control signal is also synchronization

//reg da1R_va;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n) 
begin
    ref_8R_32<=0;
	da1R_va<=0;
end	
else 
  begin
   case(rdR_sel)   
   0:begin                     //read 8rows data each clock
       da1R_va<=0;
      if(da8R_va)              //if 8 rows data is valid
	     ref_8R_32<=ref_ou;
	  else  ref_8R_32<=0;
     end
   1:begin                     //read 1th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row1;
		 da1R_va<=1;
	  //else  ref_1R_32<=0;
     end
   2:begin                     //read 2th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row2;
		  da1R_va<=1;         
	 // else  ref_1R_32<=0;
     end
   3:begin                     //read 3th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row3;
		 da1R_va<=1;    
	 // else  ref_1R_32<=0;
     end
   4:begin                     //read 4th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row4;
		 da1R_va<=1;
	  //else  ref_1R_32<=0;
     end
   5:begin                     //read 5th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	      ref_8R_32[1*32*`PIXEL-1:0]<=ref_row5;
		  da1R_va<=1;
	  //else  ref_1R_32<=0;
     end
   6:begin                     //read 6th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row6;
		 da1R_va<=1;
	  //else  ref_1R_32<=0;
     end
   7:begin                     //read 7th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row7;
		 da1R_va<=1;
	  //else  ref_1R_32<=0;
     end
   8:begin                     //read 8th rows data each clock
      //if(da1R_va)              //if 8 rows data is valid
	     ref_8R_32[1*32*`PIXEL-1:0]<=ref_row8;
		 da1R_va<=1;
	  //else  ref_1R_32<=0;
     end 
   default:da1R_va<=0;
	 endcase
  end
end


//-----------------------------------output signal valid flag
//ref_8R_32 D32 D32 D32
//Oda8R_va  1   1   1

//reg Oda8R_va;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n) 
  Oda8R_va<=0;
else
  Oda8R_va<=da8R_va;           //data_valid delay for 1 clk,synchronization with ref_8R_32 
end

endmodule