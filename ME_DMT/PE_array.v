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
  input ref_input_control,   //this control signal decide the input of PE of reference frame values:0~3
  output [`ARRAY_PIXELS-1:0] abs_outs
);

//inner connection between PE unit
wire [`ARRAY_PIXELS-1:0] next_pix1s;
wire [`ARRAY_PIXELS-1:0] next_pix2s;
wire [`ARRAY_PIXELS-1:0] ref_pixs;

genvar i;    
genvar j;    

// (i, j)
// 把up改为down，从最下面一行读入当前帧，最下面8行读入参考帧，慢慢向上传递
generate for(i=0;i<`X;i=i+1)
  begin:X_row
    for(j=0;j<`Y;j=j+1)
      begin:Y_column
        if (i == 31) begin
          PE_Xi_4 pe_xi_4(
            .clk(clk), 
            .rst_n(rst_n),
            .in_curr1(current_64pixels[ (j+1)*`PIXEL-1:j*`PIXEL]),
            .in_curr2(current_64pixels[(32+j+1)*`PIXEL-1:(32+j)*`PIXEL]),
            .in_curr_enable(in_curr_enable),
            .CB_select(CB_select), 
            .abs_Control(abs_Control), 
            .down_ref_adajecent_1(ref_8R_32[ (j+1)*`PIXEL-1:j*`PIXEL]), // ref_8R_32的第一行
            .down_ref_adajecent_8(ref_8R_32[ (32*(i-24)+j+1)*`PIXEL-1:(32*(i-24)+j)*`PIXEL]), // ref_8R_32的第八行
            // .down_ref_adajecent_8(ref_8R_32[8*(j+1)*`PIXEL-1:(8*j+7)*`PIXEL]), 
            .change_ref(change_ref), 
            .ref_input_control(ref_input_control),
            .abs_out(abs_outs[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]), 
            .next_pix1(next_pix1s[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]),
            .next_pix2(next_pix2s[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]), 
            .ref_pix(ref_pixs[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL])
          );
        end
        else if (i >= 24 && i < 31) begin
          PE_Xi_4 pe_xi_4(
            .clk(clk), 
            .rst_n(rst_n),
            .in_curr1(next_pix1s[(32*(i+1)+j+1)*`PIXEL-1:(32*(i+1)+j)*`PIXEL]), 
            .in_curr2(next_pix2s[(32*(i+1)+j+1)*`PIXEL-1:(32*(i+1)+j)*`PIXEL]), 
            .in_curr_enable(in_curr_enable),
            .CB_select(CB_select), 
            .abs_Control(abs_Control), 
            .down_ref_adajecent_1(ref_pixs[(32*(i+1)+j+1)*`PIXEL-1:(32*(i+1)+j)*`PIXEL]),
            .down_ref_adajecent_8(ref_8R_32[(32*(i-24)+j+1)*`PIXEL-1:(32*(i-24)+j)*`PIXEL]),
            // .down_ref_adajecent_8(ref_8R_32[8*(j+1)*`PIXEL-1:(8*j+7)*`PIXEL]), 
            .change_ref(change_ref), 
            .ref_input_control(ref_input_control),
            .abs_out(abs_outs[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]), 
            .next_pix1(next_pix1s[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]),
            .next_pix2(next_pix2s[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]), 
            .ref_pix(ref_pixs[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL])
          );
        end
        else begin
          PE_Xi_4 pe_xi_4(
            .clk(clk), 
            .rst_n(rst_n),
            .in_curr1(next_pix1s[(32*(i+1)+j+1)*`PIXEL-1:(32*(i+1)+j)*`PIXEL]), 
            .in_curr2(next_pix2s[(32*(i+1)+j+1)*`PIXEL-1:(32*(i+1)+j)*`PIXEL]), 
            .in_curr_enable(in_curr_enable),
            .CB_select(CB_select), 
            .abs_Control(abs_Control), 
            .down_ref_adajecent_1(ref_pixs[(32*(i+1)+j+1)*`PIXEL-1:(32*(i+1)+j)*`PIXEL]),
            .down_ref_adajecent_8(ref_pixs[(32*(i+8)+j+1)*`PIXEL-1:(32*(i+8)+j)*`PIXEL]),
            // .down_ref_adajecent_8(ref_8R_32[8*(j+1)*`PIXEL-1:(8*j+7)*`PIXEL]), 
            .change_ref(change_ref), 
            .ref_input_control(ref_input_control),
            .abs_out(abs_outs[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]), 
            .next_pix1(next_pix1s[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]),
            .next_pix2(next_pix2s[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL]), 
            .ref_pix(ref_pixs[(32*i+j+1)*`PIXEL-1:(32*i+j)*`PIXEL])
          );
        end
     end
  end
endgenerate
  
endmodule

