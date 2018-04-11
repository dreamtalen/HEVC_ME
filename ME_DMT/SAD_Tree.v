module SAD_Tree(            //
  input clk,
  input rst_n,
  input [8191:0] abs_outs,
  output reg [415:0] SAD4x8,//[12:0] SAD4x8 [31:0]
  output reg [415:0] SAD8x4,//[12:0] SAD8x4 [31:0]
  output reg [223:0] SAD8x8,//[13:0] SAD8x8 [15:0]
  output reg [119:0] SAD8x16,//[14:0] SAD8x16 [7:0]
  output reg [119:0] SAD16x8,//[14:0] SAD16x8 [7:0]
  output reg [63:0] SAD16x16,//[15:0] SAD16x16 [3:0]
  output reg [33:0] SAD16x32,//[16:0] SAD16x32 [1:0]
  output reg [33:0] SAD32x16,//[16:0] SAD32x16 [1:0]
  output reg [17:0] SAD32x32 //[17:0] SAD32x32
);

  wire [255:0] middle4x8 [31:0];
  wire [12:0]  SAD_1_middle4x8 [31:0];
  wire [415:0] SAD_2_middle4x8;

  wire [255:0] middle8x4 [31:0];
  wire [12:0]  SAD_1_middle8x4 [31:0];
  wire [415:0] SAD_2_middle8x4;

  wire [223:0] SAD_middle8x8;
  wire [119:0] SAD_middle8x16;
  wire [119:0] SAD_middle16x8;
  wire [63:0] SAD_middle16x16;
  wire [33:0] SAD_middle16x32;
  wire [33:0] SAD_middle32x16;
  wire [17:0] SAD_middle32x32;

 generate 
  genvar i1,i2;
  for(i1=0;i1<8;i1=i1+1)
  begin
    for(i2=0;i2<4;i2=i2+1)
    begin: level_i_1
    assign middle4x8[4*i1+i2][63:0] =    abs_outs[(i1*1024+i2*64+63):(i1*1024+i2*64)];
    assign middle4x8[4*i1+i2][127:64] =  abs_outs[(i1*1024+i2*64+319):(i1*1024+i2*64+256)];
    assign middle4x8[4*i1+i2][191:128] = abs_outs[(i1*1024+i2*64+575):(i1*1024+i2*64+512)];
    assign middle4x8[4*i1+i2][255:192] = abs_outs[(i1*1024+i2*64+831):(i1*1024+i2*64+768)];
    end
  end
 endgenerate
 
 generate 
  genvar j1,j2;
  for(j1=0;j1<4;j1=j1+1)
  begin
    for(j2=0;j2<8;j2=j2+1)
    begin: level_j_1
    assign middle8x4[8*j1+j2][31:0] =    abs_outs[(j1*2048+j2*32+31):(j1*2048+j2*32)];
    assign middle8x4[8*j1+j2][63:32] =   abs_outs[(j1*2048+j2*32+287):(j1*2048+j2*32+256)];
    assign middle8x4[8*j1+j2][95:64] =   abs_outs[(j1*2048+j2*32+543):(j1*2048+j2*32+512)];
    assign middle8x4[8*j1+j2][127:96] =  abs_outs[(j1*2048+j2*32+799):(j1*2048+j2*32+768)];
    assign middle8x4[8*j1+j2][159:128] = abs_outs[(j1*2048+j2*32+1055):(j1*2048+j2*32+1024)];
    assign middle8x4[8*j1+j2][191:160] = abs_outs[(j1*2048+j2*32+1311):(j1*2048+j2*32+1280)];
    assign middle8x4[8*j1+j2][223:192] = abs_outs[(j1*2048+j2*32+1567):(j1*2048+j2*32+1536)];
    assign middle8x4[8*j1+j2][255:224] = abs_outs[(j1*2048+j2*32+1823):(j1*2048+j2*32+1792)];
    end 
  end
 endgenerate

 generate 
  genvar i3;
  for(i3=0;i3<32;i3=i3+1)
  begin: level_i_2
  Add32 add32(middle4x8[i3],SAD_1_middle4x8[i3]);
  end
 endgenerate

 generate 
  genvar j3;
  for(j3=0;j3<32;j3=j3+1)
  begin: level_j_2
  Add32 add32(middle8x4[j3],SAD_1_middle8x4[j3]);
  end
 endgenerate

 generate 
  genvar i4;
  for(i4=0;i4<32;i4=i4+1)
  begin: level_i_3
  assign SAD_2_middle4x8[(i4*13+12):(i4*13)] = SAD_1_middle4x8[i4];
  end
 endgenerate

 generate 
  genvar j4;
  for(j4=0;j4<32;j4=j4+1)
  begin: level_j_3
  assign SAD_2_middle8x4[(j4*13+12):(j4*13)] = SAD_1_middle8x4[j4];
  end
 endgenerate
 
 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD4x8 <= SAD_2_middle4x8;
  end

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD8x4 <= SAD_2_middle8x4;
  end
//8x8
 generate 
  genvar k1;
  for(k1=0;k1<16;k1=k1+1)
  begin: level_k_1
  assign SAD_middle8x8[(k1*14+13):(k1*14)] = SAD_1_middle8x4[2*k1+1]+SAD_1_middle8x4[2*k1];
  end
 endgenerate

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD8x8 <= SAD_middle8x8;
  end
//8x16
 generate 
  genvar k2;
  for(k2=0;k2<8;k2=k2+1)
  begin: level_k_2
  assign SAD_middle8x16[(k2*15+14):(k2*15)] = SAD_middle8x8[((2*k2+1)*14+13):((2*k2+1)*14)]+SAD_middle8x8[(2*k2*14+13):(2*k2*14)];
  end
 endgenerate

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD8x16 <= SAD_middle8x16;
  end
//16x8
 generate 
  genvar k3;
  for(k3=0;k3<2;k3=k3+1)
  begin: level_k_3
  assign SAD_middle16x8[(k3*60+14):(k3*60)] =    SAD_middle8x8[((8*k3+4)*14+13):((8*k3+4)*14)]+SAD_middle8x8[((8*k3+0)*14+13):((8*k3+0)*14)];
  assign SAD_middle16x8[(k3*60+29):(k3*60+15)] = SAD_middle8x8[((8*k3+5)*14+13):((8*k3+5)*14)]+SAD_middle8x8[((8*k3+1)*14+13):((8*k3+1)*14)];
  assign SAD_middle16x8[(k3*60+44):(k3*60+30)] = SAD_middle8x8[((8*k3+6)*14+13):((8*k3+6)*14)]+SAD_middle8x8[((8*k3+2)*14+13):((8*k3+2)*14)];
  assign SAD_middle16x8[(k3*60+59):(k3*60+45)] = SAD_middle8x8[((8*k3+7)*14+13):((8*k3+7)*14)]+SAD_middle8x8[((8*k3+3)*14+13):((8*k3+3)*14)];
  end
 endgenerate

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD16x8 <= SAD_middle16x8;
  end
//16x16
 generate 
  genvar k4;
  for(k4=0;k4<4;k4=k4+1)
  begin: level_k_4
  assign SAD_middle16x16[(k4*16+15):(k4*16)] = SAD_middle16x8[((2*k4+1)*15+14):((2*k4+1)*15)]+SAD_middle16x8[(2*k4*15+14):(2*k4*15)];
  end
 endgenerate

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD16x16 <= SAD_middle16x16;
  end
//16x32
  assign SAD_middle16x32[16:0] = SAD_middle16x16[31:16]+SAD_middle16x16[15:0];
  assign SAD_middle16x32[33:17] = SAD_middle16x16[63:48]+SAD_middle16x16[47:32];

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD16x32 <= SAD_middle16x32;
  end
//32x16
  assign SAD_middle32x16[16:0] = SAD_middle16x16[47:32]+SAD_middle16x16[15:0];
  assign SAD_middle32x16[33:17] = SAD_middle16x16[63:48]+SAD_middle16x16[31:16];

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD32x16 <= SAD_middle32x16;
  end
//32x32
  assign SAD_middle32x32 = SAD_middle32x16[33:17]+SAD_middle32x16[16:0];

 always@(posedge clk or negedge rst_n)
  begin
  if(rst_n)
  SAD32x32 <= SAD_middle32x32;
  end

endmodule

module Add32(
  //input clk,
  //input rst_n,
  input [255:0] abs_outs,
  output [12:0] out32
);

  wire [7:0] myByte [31:0];
  wire [8:0]  w[15:0];
  wire [9:0]  x [7:0];
  wire [10:0]  y [3:0];
  wire [11:0]  z [1:0];
  
  genvar  i,j,k,l,m;
  generate
  for(m=0;m<32;m=m+1)
  begin:to8
    assign myByte[m] = abs_outs[(8*m+7):(8*m)];
  end
  endgenerate
  //16 eight bit adder
  generate
  for(i=0;i<16;i=i+1)
  begin:Q16
    assign w[i] = myByte[2*i] + myByte[2*i+1];
  end
  endgenerate
  //8 nine bit adder
  generate
  for(j=0;j<8;j=j+1)
  begin:Q8
    assign x[j] = w[2*j] + w[2*j+1];
  end
  endgenerate
  //4 ten bit adder
  generate
  for(k=0;k<4;k=k+1)
  begin:Q4
    assign y[k] = x[2*k] + x[2*k+1];
  end
  endgenerate
  //2 eleven bit adder
  generate
  for(l=0;l<2;l=l+1)
  begin:Q2
    assign z[l] = y[2*l] + y[2*l+1];
  end
  endgenerate
  
  assign out32 = z[0] + z[1];

// always@(posedge clk or negedge rst_n)
//  begin
//  if(!rst_n)
//  out32 <= z[0] + z[1];
//  end
  
endmodule
