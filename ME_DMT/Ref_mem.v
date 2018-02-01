`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X

module Ref_mem(               //need to modify : 只需实现从8行选择一行的功能
input    	 		        clk,
input 				        rst_n,
input [32*`PIXEL-1:0] ref_input,     //input 4*8pixels, which is 32pixels*8bit=256bit
input 				        beg_en,        //begin to input data, beg_en = 1 begin write                                  
input [6:0] 	        rd_address,    //address is the depth of Bank,value:0-95
input 				        rd8R_en,       //read enable,read 8 rows from 32Bank, rd_en = 0 begin read
input [3:0]			      rdR_sel,       //read mode select(called:read rows select),it can select one row(row1~row8) or 8 rows output,synchronization with address,read_en.value：0-8 
output reg [2047:0]   ref_8R_32,     //output 8row*32clomn=256pixels,which is 256pixels*8bit=2048bit 
output reg            Oda8R_va,      //data vlid for 1 clk if get only one 8 rows data,synchronization with ref_8R_32
output reg            da1R_va        //valid for 8 clk,enough to read 8 rows,synchronization with ref_1R_32
);



reg [31:0] Bank_sel;         //select one Bank (total is 32 Bank) to store, 32'b1-Bank1,32'b2-Bank2,....,32'b1000 0000_0000 0000_0000 0000_0000 0000-Bank32

reg [4:0] stor_cnt;          //to count the number,which have stored in one Bank, normaly,there need 24 clk to store a Bank
always@(posedge clk or negedge rst_n)
if(!rst_n)
    stor_cnt<=0;
else if(beg_en)             //beg_en   : 0 1 1 1 
  begin                     //reg_input: x D D D
    if(stor_cnt<24)         //stor_cnt : 0 0 1 2 ........24 1 2 3...
	  stor_cnt<=stor_cnt+1;
	else 
	  stor_cnt<=1;
  end

reg [4:0] Bank_cnt;          //to count the number,which bank is in writing
always@(posedge clk or negedge rst_n)
if(!rst_n)
    Bank_cnt<=0;
else if(beg_en)             //beg_en   : 0 1 1 1 
  begin                     //reg_input: x D D D
    if(stor_cnt==24)        //stor_cnt : 0 0 1 2 ........24 1 2 3...24 1 2 3 ......24 1  2  3  ...24 1 2 ..24
	  begin                   //Bank_cnt : 0 0 0 0 .........0 1 1 1...1  2 2 2 ......30 31 31 31 ...31 0 0 ..0
	    if(Bank_cnt<31)
		  Bank_cnt<=Bank_cnt+1;
		else 
		  Bank_cnt<=0;
	  end
  end

//beg_en   : 0 1 1 1   
//reg_input: x D D D
//stor_cnt : 0 0 1 2 ........24 1 2 3...24 1 2 3 ......24 1  2  3  ...24 1 2 ..24 this time write is correct
//Bank_cnt : 0 0 0 0 .........0 1 1 1...1  2 2 2 ......30 31 31 31 ...31 0 0 ..0
//Bank_sel :       1          1 1 2 2   2  2 3 3       31 31 32 32 ...32 32 1
//reg_input after delay 2clk
//         :     x D D D
//beg_en after delay 2clk  
//         :     0 1 1 1
always@(posedge clk or negedge rst_n)
if(!rst_n)
    Bank_sel<=32'b0;
else if(beg_en)
begin
   case(Bank_cnt)
   'd0 :begin
        if(stor_cnt>=1)
          Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0000_0001; //select Bank1,to ignore after initial will ahead 1 clk in write
		else 
		  Bank_sel<=0;  
		end
   'd1 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0000_0010; //select Bank2
   'd2 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0000_0100; //select Bank3
   'd3 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0000_1000; //select Bank4
   'd4 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0001_0000; //select Bank5
   'd5 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0010_0000; //select Bank6
   'd6 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_0100_0000; //select Bank7
   'd7 :Bank_sel<=32'b0000_0000_0000_0000_0000_0000_1000_0000; //select Bank8
   
   'd8 :Bank_sel<=32'b0000_0000_0000_0000_0000_0001_0000_0000; //select Bank9
   'd9 :Bank_sel<=32'b0000_0000_0000_0000_0000_0010_0000_0000; //select Bank10
   'd10:Bank_sel<=32'b0000_0000_0000_0000_0000_0100_0000_0000; //select Bank11
   'd11:Bank_sel<=32'b0000_0000_0000_0000_0000_1000_0000_0000; //select Bank12
   'd12:Bank_sel<=32'b0000_0000_0000_0000_0001_0000_0000_0000; //select Bank13
   'd13:Bank_sel<=32'b0000_0000_0000_0000_0010_0000_0000_0000; //select Bank14
   'd14:Bank_sel<=32'b0000_0000_0000_0000_0100_0000_0000_0000; //select Bank15
   'd15:Bank_sel<=32'b0000_0000_0000_0000_1000_0000_0000_0000; //select Bank16

   'd16:Bank_sel<=32'b0000_0000_0000_0001_0000_0000_0000_0000; //select Bank17
   'd17:Bank_sel<=32'b0000_0000_0000_0010_0000_0000_0000_0000; //select Bank18
   'd18:Bank_sel<=32'b0000_0000_0000_0100_0000_0000_0000_0000; //select Bank19
   'd19:Bank_sel<=32'b0000_0000_0000_1000_0000_0000_0000_0000; //select Bank20
   'd20:Bank_sel<=32'b0000_0000_0001_0000_0000_0000_0000_0000; //select Bank21
   'd21:Bank_sel<=32'b0000_0000_0010_0000_0000_0000_0000_0000; //select Bank22
   'd22:Bank_sel<=32'b0000_0000_0100_0000_0000_0000_0000_0000; //select Bank23
   'd23:Bank_sel<=32'b0000_0000_1000_0000_0000_0000_0000_0000; //select Bank24

   'd24:Bank_sel<=32'b0000_0001_0000_0000_0000_0000_0000_0000; //select Bank25
   'd25:Bank_sel<=32'b0000_0010_0000_0000_0000_0000_0000_0000; //select Bank26
   'd26:Bank_sel<=32'b0000_0100_0000_0000_0000_0000_0000_0000; //select Bank27
   'd27:Bank_sel<=32'b0000_1000_0000_0000_0000_0000_0000_0000; //select Bank28
   'd28:Bank_sel<=32'b0001_0000_0000_0000_0000_0000_0000_0000; //select Bank29
   'd29:Bank_sel<=32'b0010_0000_0000_0000_0000_0000_0000_0000; //select Bank30
   'd30:Bank_sel<=32'b0100_0000_0000_0000_0000_0000_0000_0000; //select Bank31
   'd31:Bank_sel<=32'b1000_0000_0000_0000_0000_0000_0000_0000; //select Bank32   
   //default:
   endcase
end

//beg_en also need to delay 2 clk to  Synchronization with data
reg beg_en_delay1;
reg beg_en_delay2;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  beg_en_delay1<=0;
else if(beg_en)
  beg_en_delay1<=beg_en;
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  beg_en_delay2<=0;
else if(beg_en)
  beg_en_delay2<=beg_en_delay1;
end


//reference input delay 2 clk,then input the Bank with Bank_sel(enable the Bank to storage)
reg [255:0] ref_input_delay1;
reg [255:0] ref_input_delay2;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  ref_input_delay1<=256'b0;
else if(beg_en)
  ref_input_delay1<=ref_input;
end

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  ref_input_delay2<=256'b0;
else if(beg_en_delay1)
  ref_input_delay2<=ref_input_delay1;
end

//-----------------------------------instance 32 Bank
//if read time sequence is as follows
//rd_address: x 1 2 3 4 
//rd8R_en   : 0 1 1 1 1                 //read enable,it is also read clock,synchronization with rd_address
//rdR_sel   :   s s s s 

//output
//ref_ou    :   x D D D D
//data_valid:   0 1 1 1 1
//rdR_sel_dlay:   s s s s
//


wire [8*32*`PIXEL-1:0] ref_ou; 		    //each Bank is 8 pixels,32 Bank is 8*32pixels,total is 8*32*8bit
//wire [6:0] rd_address;      			//according address to select 1 data(8 pixels)，value:=0~95(the depth of one Bank)
//wire [31:0] da_va;

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

//-----------------------------------read row select needs to delay 1 clk
reg [3:0] rdR_sel_dlay;
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
  rdR_sel_dlay<=0;
else //if(rd8R_en)                                                   //although don't read data from bank,we can still read data from 8 rows lately
  rdR_sel_dlay<=rdR_sel;
end

genvar j;
generate for(j=0;j<32;j=j+1)
     begin:Bank_32     
      Bank in_Bank(
        .clk(clk),
        .rst_n(rst_n),
        .beg_en(beg_en_delay2),
        .ref_in(ref_input_delay2[64*(j%4+1)-1:64*(j%4)]),  //reference input,8 pixels=64bit
        .Bank_sel(~Bank_sel[j]),                    //if Bank_sel=1,enable to storage
        .address(rd_address),                       //according address to select 1 data(8 pixels)
        .rd_en(rd8R_en),                                      //read_enable
        .ref_ou(ref_ou[8*`PIXEL*(j+1)-1:8*`PIXEL*j])   //output 1 data(8 pixels) of Bank
        );
    end   
endgenerate

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
//rdR_sel_dlay: s s s s

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
   case(rdR_sel_dlay)   
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