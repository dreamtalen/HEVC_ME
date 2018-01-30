`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X //256
`define BAND_WIDTH_Y `PIXEL*`Y //256
`define ARRAY_SIZE `X*`Y //1024
`define ARRAY_PIXELS `ARRAY_SIZE*`PIXEL //8192

module PE_array(            //need to remove the horizontal connections
  input clk,
  input rst_n,
  //current frame
  input [2*`BAND_WIDTH_X-1:0] current_64pixels,  //each clock input(2*32 PIXEL)
  input in_curr_enable,  //transfer to next PE;norm 1
  // input 						change_curr,     //change current PE  ;norm 1
  input CB_select,       //choose Current Block 1&2 or 3&4
  // input	[1:0]				CB_select,       //exist to different register as different CB,values:0~3
  //abs_Control
  input	[1:0] abs_Control,      //decide which CB block to decrease,          values:0~3
  //reference frame
  //when each clk input one row(32 PIXEL )
  // 这里up down没有看懂，这么写的话输入带宽不是翻倍了么，把down删了，top调用的时候down端口是悬空的
  // 把up也删了，只传进来ref_8R_32
  // input [`BAND_WIDTH_X-1:0] up_ref_adajecent_1,
  // input [`BAND_WIDTH_X-1:0] down_ref_adajecent_1,
  //when each clk input 8 row(8rowX32 PIXEL)
  input [`BAND_WIDTH_X*8-1:0] ref_8R_32,
  // input [`BAND_WIDTH_X*8-1:0] down_ref_adajecent_8,
  input change_ref,        //current PE  reference PIXEL change
  input [1:0] ref_input_Control,   //this control signal decide the input of PE of reference frame values:0~3
  output [`ARRAY_PIXELS-1:0] abs_outs
);

//inner connection between PE unit
wire [`ARRAY_PIXELS-1:0] next_pix1s;
wire [`ARRAY_PIXELS-1:0] next_pix2s;
wire [`ARRAY_PIXELS-1:0] ref_pixs;

//the divided construction
//1_1 1_2 1_3 1_4 ... 1_31 1_32   //north 1row

//2_1 2_2 2_3 2_4 ... 2_31 2_32   //north 7row
//...
//8_1 8_2 8_3 8_4 ... 8_31 8_32   

//9_1 9_2 9_3 9_4 ... 9_31 9_32   //midle 16row
//...
//...
//24_1 24_2       ... 24_31 24_32

//25_1 25_2       ... 25_31 25_32 //south 7row
//...
//31_1 31_2       ... 31_31 31_32

//32_1 32_2       ... 32_31 32_32 //south 1row

genvar i;    
genvar j;    

// (i, j)

generate for(i=0;i<`X;i=i+1)
  begin:X_row
    for(j=0;j<`Y;j=j+1)
      begin:Y_column
        if (i == 0) begin
          PE_Xi_4 pe_xi_4(
            .clk(clk), 
            .rst_n(rst_n),
            .in_curr1(current_64pixels[(j+1)*`PIXEL-1:j*`PIXEL]),
            .in_curr2(current_64pixels[(`Y+j+1)*`PIXEL-1:(`Y+j)*`PIXEL]]),
            .in_curr_enable(in_curr_enable),
            .CB_select(CB_select), 
            .abs_Control(abs_Control), 
            .up_ref_adajecent_1(ref_8R_32[(j+1)*`PIXEL-1:j*`PIXEL]),
            .up_ref_adajecent_8(ref_8R_32[(j+1)*`PIXEL-1:j*`PIXEL]),
            // .up_ref_adajecent_8(ref_8R_32[8*(j+1)*`PIXEL-1:(8*j+7)*`PIXEL]), 
            .change_ref(change_ref), 
            .ref_input_Control(ref_input_Control),
            .abs_out(abs_outs[(j+1)*`PIXEL-1:j*`PIXEL]), 
            .next_pix1(next_pix1s[(j+1)*`PIXEL-1:j*`PIXEL]),
            .next_pix2(next_pix2s[(j+1)*`PIXEL-1:j*`PIXEL]), 
            .ref_pix(ref_pixs[(j+1)*`PIXEL-1:j*`PIXEL])
          );
        end


     end
  end
endgenerate

//-------------------------------------------------------north 1row
generate for(j=1;j<=`X;j=j+1)
     begin:X_row_nor1        //----水平方向
      PE_Xi_4 inst_north_1row(
	    .clk(clk),
      .rst_n(rst_n),
	//当前帧
      .in_curr(next_pixs[(`X*1+j)*`PIXEL-1: (`X*1+j)*`PIXEL-`PIXEL]),         //one pixel input
      .in_curr_enable(in_curr_enable&curr_ready_32),  //transfer to next PE;norm 1
	  .change_curr(change_curr),     //change current PE  ;norm 1
	  .CB_select(CB_select),       //exist to different register as different CB,values:0~3
    //差值控制
	  .abs_Control(abs_Control),      //decide which CB block to decrease,          values:0~3

	//参考帧
      .up_ref_adajecent_1(up_ref_adajecent_1[j*`PIXEL-1:j*`PIXEL-`PIXEL]),  
      .up_ref_adajecent_8(up_ref_adajecent_8[(8*(j-1)+1)*`PIXEL-1:(8*(j-1)+1)*`PIXEL-`PIXEL]),
      .down_ref_adajecent_1(ref_pixs[(`X*1+j)*`PIXEL-1:(`X*1+j)*`PIXEL-`PIXEL]),
	  .down_ref_adajecent_8(ref_pixs[(`X*8+j)*`PIXEL-1:(`X*8+j)*`PIXEL-`PIXEL]),
      .change_ref(change_ref),      //change reference PE;norm 1
      .ref_input_Control(ref_input_Control),   //this control signal decide the input of PE of reference frame values:0~3
    //差值输出
      .abs_out(abs_outs[(`X*0+j)*`PIXEL-1:(`X*0+j)*`PIXEL-`PIXEL]),
    //当前帧输出
	  .next_pix(next_pixs[(`X*0+j)*`PIXEL-1:(`X*0+j)*`PIXEL-`PIXEL]),
    //参考帧输出
      .ref_pix(ref_pixs[(`X*0+j)*`PIXEL-1:(`X*0+j)*`PIXEL-`PIXEL])
	  ); 
	  end
endgenerate

//-------------------------------------------------------north 7row
generate for(j=1;j<=`X;j=j+1)
  begin:X_row_nor7                //----水平方向
    for(i=2;i<=`Y/4;i=i+1)   //          |
     begin:Y_column_nor7           //竖直方向  |
	  PE_Xi_4 inst_north_7row(
	   .clk(clk),
	   .rst_n(rst_n),
    //当前帧
	   .in_curr(next_pixs[(32*i+j)*`PIXEL-1:(32*i+j)*`PIXEL-`PIXEL]),  //one pixel input
	   .in_curr_enable(in_curr_enable&curr_ready_32),  //transfer to next PE;norm 1
	   .change_curr(change_curr),     //change current PE  ;norm 1
	   .CB_select(CB_select),       //exist to different register as different CB,values:0~7
    //差值控制
	   .abs_Control(abs_Control),      //decide which CB block to decrease,          values:0~7

	//参考帧
      .up_ref_adajecent_1(ref_pixs[(`X*(i-2)+j)*`PIXEL-1:(`X*(i-2)+j)*`PIXEL-`PIXEL]),  
      .up_ref_adajecent_8(up_ref_adajecent_8[(8*(j-1)+i)*`PIXEL-1:(8*(j-1)+i)*`PIXEL-`PIXEL]),
      .down_ref_adajecent_1(ref_pixs[(`X*i+j)*`PIXEL-1:(`X*i+j)*`PIXEL-`PIXEL]),
	  .down_ref_adajecent_8(ref_pixs[(`X*(i+7)+j)*`PIXEL-1:(`X*(i+7)+j)*`PIXEL-`PIXEL]),
      .change_ref(change_ref),      //change reference PE;norm 1
      .ref_input_Control(ref_input_Control),   //this control signal decide the input of PE of reference frame values:0~3
    //差值输出
      .abs_out(abs_outs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL]),
    //当前帧输出
	  .next_pix(next_pixs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL]),
    //参考帧输出
      .ref_pix(ref_pixs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL])
	  ); 
	  end
  end
endgenerate

//-------------------------------------------------------middle 16row
generate for(j=1;j<=`X;j=j+1)
  begin:X_row_mid16                //----水平方向
    for(i=9;i<=24;i=i+1)      //          |
     begin:Y_column_mid16           //竖直方向  |
	  PE_Xi_4 inst_middle_16row(
	   .clk(clk),
	   .rst_n(rst_n),
    //当前帧
	   .in_curr(next_pixs[(32*i+j)*`PIXEL-1:(32*i+j)*`PIXEL-`PIXEL]),  //one pixel input
	   .in_curr_enable(in_curr_enable&curr_ready_32),  //transfer to next PE;norm 1
	   .change_curr(change_curr),     //change current PE  ;norm 1
	   .CB_select(CB_select),       //exist to different register as different CB,values:0~7
    //差值控制
	   .abs_Control(abs_Control),      //decide which CB block to decrease,          values:0~7

	//参考帧
      .up_ref_adajecent_1(ref_pixs[(`X*(i-2)+j)*`PIXEL-1:(`X*(i-2)+j)*`PIXEL-`PIXEL]),  
      .up_ref_adajecent_8(ref_pixs[(`X*(i-9)+j)*`PIXEL-1:(`X*(i-9)+j)*`PIXEL-`PIXEL]),
      .down_ref_adajecent_1(ref_pixs[(`X*i+j)*`PIXEL-1:(`X*i+j)*`PIXEL-`PIXEL]),
	  .down_ref_adajecent_8(ref_pixs[(`X*(i+7)+j)*`PIXEL-1:(`X*(i+7)+j)*`PIXEL-`PIXEL]),
      .change_ref(change_ref),      //change reference PE;norm 1
      .ref_input_Control(ref_input_Control),   //this control signal decide the input of PE of reference frame values:0~3
    //差值输出
      .abs_out(abs_outs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL]),
    //当前帧输出
	  .next_pix(next_pixs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL]),
    //参考帧输出
      .ref_pix(ref_pixs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL])
	  ); 
	  end
 end
endgenerate

//-------------------------------------------------------south 7row
generate for(j=1;j<=`X;j=j+1)
  begin:X_row_sou7                //----水平方向
    for(i=25;i<=31;i=i+1)      //          |
     begin:Y_column_sou7           //竖直方向  |
	  PE_Xi_4 inst_south_7row(
	   .clk(clk),
	   .rst_n(rst_n),
    //当前帧
	   .in_curr(next_pixs[(32*i+j)*`PIXEL-1:(32*i+j)*`PIXEL-`PIXEL]),  //one pixel input
	   .in_curr_enable(in_curr_enable&curr_ready_32),  //transfer to next PE;norm 1
	   .change_curr(change_curr),     //change current PE  ;norm 1
	   .CB_select(CB_select),       //exist to different register as different CB,values:0~7
    //差值控制
	   .abs_Control(abs_Control),      //decide which CB block to decrease,          values:0~7

	//参考帧
      .up_ref_adajecent_1(ref_pixs[(`X*(i-2)+j)*`PIXEL-1:(`X*(i-2)+j)*`PIXEL-`PIXEL]),  
      .up_ref_adajecent_8(ref_pixs[(`X*(i-9)+j)*`PIXEL-1:(`X*(i-9)+j)*`PIXEL-`PIXEL]),
      .down_ref_adajecent_1(ref_pixs[(`X*i+j)*`PIXEL-1:(`X*i+j)*`PIXEL-`PIXEL]),
	  .down_ref_adajecent_8(down_ref_adajecent_8[(8*(j-1)+i-24)*`PIXEL-1:(8*(j-1)+i-24)*`PIXEL-`PIXEL]),
      .change_ref(change_ref),      //change reference PE;norm 1
      .ref_input_Control(ref_input_Control),   //this control signal decide the input of PE of reference frame values:0~3
    //差值输出
      .abs_out(abs_outs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL]),
    //当前帧输出
	  .next_pix(next_pixs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL]),
    //参考帧输出
      .ref_pix(ref_pixs[(`X*(i-1)+j)*`PIXEL-1:(`X*(i-1)+j)*`PIXEL-`PIXEL])
	  ); 
	  end
  end
endgenerate

//-------------------------------------------------------south 1row
generate for(j=1;j<=`X;j=j+1)
  begin:X_row_sou1                //----水平方向
   PE_Xi_4 inst_south_1row(
	   .clk(clk),
	   .rst_n(rst_n),
    //当前帧
	   .in_curr(current_pixels[j*`PIXEL-1:j*`PIXEL-`PIXEL]),  //one pixel input
	   .in_curr_enable(in_curr_enable&curr_ready_32),  //transfer to next PE;norm 1
	   .change_curr(change_curr),     //change current PE  ;norm 1
	   .CB_select(CB_select),       //exist to different register as different CB,values:0~7
    //差值控制
	   .abs_Control(abs_Control),      //decide which CB block to decrease,          values:0~7

	//参考帧
      .up_ref_adajecent_1(ref_pixs[(`X*(32-2)+j)*`PIXEL-1:(`X*(32-2)+j)*`PIXEL-`PIXEL]),  
      .up_ref_adajecent_8(ref_pixs[(`X*(32-9)+j)*`PIXEL-1:(`X*(32-9)+j)*`PIXEL-`PIXEL]),
      .down_ref_adajecent_1(down_ref_adajecent_1[j*`PIXEL-1:j*`PIXEL-`PIXEL]),
	  .down_ref_adajecent_8(down_ref_adajecent_8[(8*(j-1)+32-24)*`PIXEL-1:(8*(j-1)+32-24)*`PIXEL-`PIXEL]),
      .change_ref(change_ref),      //change reference PE;norm 1
      .ref_input_Control(ref_input_Control),   //this control signal decide the input of PE of reference frame values:0~3
    //差值输出
      .abs_out(abs_outs[(`X*(32-1)+j)*`PIXEL-1:(`X*(32-1)+j)*`PIXEL-`PIXEL]),
    //当前帧输出
	  .next_pix(next_pixs[(`X*(32-1)+j)*`PIXEL-1:(`X*(32-1)+j)*`PIXEL-`PIXEL]),
    //参考帧输出
      .ref_pix(ref_pixs[(`X*(32-1)+j)*`PIXEL-1:(`X*(32-1)+j)*`PIXEL-`PIXEL])
	  ); 
	  end
endgenerate
  
endmodule

