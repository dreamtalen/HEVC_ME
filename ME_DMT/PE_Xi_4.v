`define PIXEL 8

module PE_Xi_4(
input					clk,
input					rst_n,
	//当前帧
input	[`PIXEL-1:0]	in_curr1,         //1st pixel input
input	[`PIXEL-1:0]	in_curr2,         //2nd pixel input
input					in_curr_enable,  //transfer to next PE;norm 1
// input					change_curr,     //change current PE  ;norm 1 
input					CB_select,       //choose Current Block 1&2 or 3&4
// input	[1:0]			CB_select,       //exist to different register as different CB,values:0~3
    //差值控制
input	[1:0]			abs_Control,      //decide which CB block to decrease,          values:0~3

	//参考帧
input	[`PIXEL-1:0]	down_ref_adajecent_1,   
input	[`PIXEL-1:0]	down_ref_adajecent_8,
// input	[`PIXEL-1:0]	down_ref_adajecent_1,
// input	[`PIXEL-1:0]	down_ref_adajecent_8,
input                   change_ref,      //change reference PE;norm 1
input					ref_input_control,   //改为1bit，因为把down删了
    //差值输出
output reg[`PIXEL-1:0]	abs_out,
    //当前帧输出
output	[`PIXEL-1:0] 	next_pix1,
output	[`PIXEL-1:0] 	next_pix2,
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
	    case(ref_input_control)
		  1'b0: ref_pix<= down_ref_adajecent_1;
		  1'b1: ref_pix<= down_ref_adajecent_8;			
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
			if (CB_select)
			begin
				reg_next_pix_CB1_1 <= in_curr1;
				reg_next_pix_CB1_2 <= in_curr2;
			end
			else begin
				reg_next_pix_CB1_3 <= in_curr1;
				reg_next_pix_CB1_4 <= in_curr2;
			end
        end
        abs_out <= (curr_pix > ref_pix)?(curr_pix-ref_pix):(ref_pix-curr_pix);
	end                                            
end                                              //
                                                  

assign curr_pix = (
				(abs_Control==2'b00)?(reg_next_pix_CB1_1):(
                (abs_Control==2'b01)?(reg_next_pix_CB1_2):(
				(abs_Control==2'b10)?(reg_next_pix_CB1_3):(
				(abs_Control==2'b11)?(reg_next_pix_CB1_4):0
)))
);


assign next_pix1=(CB_select)?(reg_next_pix_CB1_1):(reg_next_pix_CB1_3);
assign next_pix2=(CB_select)?(reg_next_pix_CB1_2):(reg_next_pix_CB1_4);
	 

endmodule

