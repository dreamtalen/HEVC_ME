`define PIXEL 8

module PE_Xi_4(
input					clk,
input					rst_n,
	//当前帧
input	[`PIXEL-1:0]	in_curr,         //one pixel input
input					in_curr_enable,  //transfer to next PE;norm 1
input					change_curr,     //change current PE  ;norm 1
input	[1:0]			CB_select,       //exist to different register as different CB,values:0~3
    //差值控制
input	[1:0]			abs_Control,      //decide which CB block to decrease,          values:0~3

	//参考帧
input	[`PIXEL-1:0]	up_ref_adajecent_1,  
input	[`PIXEL-1:0]	up_ref_adajecent_8,
input	[`PIXEL-1:0]	down_ref_adajecent_1,
input	[`PIXEL-1:0]	down_ref_adajecent_8,
input                   change_ref,      //change reference PE;norm 1
input	[1:0]			ref_input_Control,   //this control signal decide the input of PE of reference frame values:0~3
    //差值输出
output	[`PIXEL-1:0]	abs_out,
    //当前帧输出
output	[`PIXEL-1:0] 	next_pix,
    //参考帧输出
output reg[`PIXEL-1:0] 	ref_pix
);


reg [`PIXEL-1:0] reg_next_pix_CB1_1;
reg [`PIXEL-1:0] reg_next_pix_CB1_2;
reg [`PIXEL-1:0] reg_next_pix_CB1_3;
reg [`PIXEL-1:0] reg_next_pix_CB1_4;
// reg [`PIXEL-1:0] reg_next_pix_CB2_1;
// reg [`PIXEL-1:0] reg_next_pix_CB2_2;
// reg [`PIXEL-1:0] reg_next_pix_CB2_3;
// reg [`PIXEL-1:0] reg_next_pix_CB2_4;

wire [`PIXEL-1:0] curr_pix;

//down_ref:0 1 2 3 4 5
//ref_pix: 0 0 1 2 3 4      
//2st PE
//down_ref:0 0 1 3 3 4
//ref_pix: 0 0 0 1 2 3
always@(posedge clk or negedge rst_n)
begin
	if(! rst_n)
		ref_pix <= 0;
	else
	begin 
	  if(change_ref)
	  begin
	    case(ref_input_Control)
		  2'b00: ref_pix<= up_ref_adajecent_1;
		  2'b01: ref_pix<= up_ref_adajecent_8;          		  
		  2'b10: ref_pix<= down_ref_adajecent_1;
		  2'b11: ref_pix<= down_ref_adajecent_8; 				
	    endcase
	  end
	end

end

//in_curr: 0 1 2 3 4 5   表示有直接输入的接口
//next_pix:0 0 1 2 3 4 5
//curr_pix:0 0 0 1 2 3 4
/////////下一个模块//////////
//in_curr: 0 0 1 2 3 4 5
//next_pix:0 0 0 1 2 3 411
//curr_pix:0 0 0 0 1 2 3
//...
always@(posedge clk or negedge rst_n)	//预加载下一个当前块
begin
	if(! rst_n)
	begin
		reg_next_pix_CB1_1 <=0;
		reg_next_pix_CB1_2 <=0;
		reg_next_pix_CB1_3 <=0;
		reg_next_pix_CB1_4 <=0;
		// reg_next_pix_CB2_1 <=0;
		// reg_next_pix_CB2_2 <=0;
		// reg_next_pix_CB2_3 <=0;
		// reg_next_pix_CB2_4 <=0;
	end
	else
	begin
		if(in_curr_enable)   //begin to input current PE register;norm 1
		begin
		case(CB_select)
		   2'b00:reg_next_pix_CB1_1 <=in_curr;  
           2'b01:reg_next_pix_CB1_2 <=in_curr;
		   2'b10:reg_next_pix_CB1_3 <=in_curr;  
           2'b11:reg_next_pix_CB1_4 <=in_curr;
		   // 3'b100:reg_next_pix_CB2_1 <=in_curr;  
     //       3'b101:reg_next_pix_CB2_2 <=in_curr;
		   // 3'b110:reg_next_pix_CB2_3 <=in_curr;  
     //       3'b111:reg_next_pix_CB2_4 <=in_curr;
		endcase
        end			
	end                                            
end                                              //
                                                  

assign curr_pix = (
				(abs_Control==2'b00)?(reg_next_pix_CB1_1):(
                (abs_Control==2'b01)?(reg_next_pix_CB1_2):(
				(abs_Control==2'b10)?(reg_next_pix_CB1_3):(
				(abs_Control==2'b11)?(reg_next_pix_CB1_4):0
				// (abs_Control==3'b100)?(reg_next_pix_CB2_1):(
				// (abs_Control==3'b101)?(reg_next_pix_CB2_2):(
				// (abs_Control==3'b110)?(reg_next_pix_CB2_3):(
				// (abs_Control==3'b111)?(reg_next_pix_CB2_4):0
)))
);

//selcet one CB block to decrease ref_pix
assign abs_out=(curr_pix > ref_pix)?(curr_pix-ref_pix):(ref_pix-curr_pix);

assign next_pix=((CB_select==2'b00)?reg_next_pix_CB1_1:(
                 (CB_select==2'b01)?reg_next_pix_CB1_2:(
				 (CB_select==2'b10)?reg_next_pix_CB1_3:(
				 (CB_select==2'b11)?reg_next_pix_CB1_4:0
				 // (CB_select==3'b100)?reg_next_pix_CB2_1:(
				 // (CB_select==3'b101)?reg_next_pix_CB2_2:(
				 // (CB_select==3'b110)?reg_next_pix_CB2_3:(
				 // (CB_select==3'b111)?reg_next_pix_CB2_4:0			 
)))
);


endmodule

