`timescale 1ns/1ns

module basic_layer_search_tb;
	reg clk;
	reg rst_n;
	reg [255:0] ref_input;
	reg [511:0] current_64pixels;
	reg ref_begin_prepare;
	reg pe_begin_prepare;
	wire [415:0] SAD4x8;
	wire [415:0] SAD8x4;
	wire [223:0] SAD8x8;
	wire [119:0] SAD8x16;
	wire [119:0] SAD16x8;
	wire [63:0] SAD16x16;
	wire [33:0] SAD16x32;
	wire [33:0] SAD32x16;
	wire [17:0] SAD32x32;
	wire [4:0] search_column_count;
	wire [6:0] search_row_count;

	reg [255:0] ref_input_mem1 [767:0];
	reg [255:0] ref_input_mem2 [383:0];
	reg [511:0] current_mem [63:0];
	integer i1,i2,i3,i4;

Basic_layer_search basic_layer_search(
	.clk(clk), .rst_n(rst_n), .ref_input(ref_input), .current_64pixels(current_64pixels),
	.ref_begin_prepare(ref_begin_prepare), .pe_begin_prepare(pe_begin_prepare),
	.SAD4x8(SAD4x8), .SAD8x4(SAD8x4), .SAD8x8(SAD8x8), .SAD8x16(SAD8x16), .SAD16x8(SAD16x8),
	.SAD16x16(SAD16x16), .SAD16x32(SAD16x32), .SAD32x16(SAD32x16), .SAD32x32(SAD32x32), 
	.search_column_count(search_column_count), .search_row_count(search_row_count)
);

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	ref_begin_prepare = 1;
	$readmemh("ref_mem192x192_768x64_384x64_1.txt", ref_input_mem1);
	$readmemh("ref_mem192x192_768x64_384x64_2.txt", ref_input_mem2);
	$readmemh("current64x64.txt", current_mem);
	#7010
	pe_begin_prepare = 1;
end

initial
begin
	#20	
	for(i1=0;i1<768;i1=i1+1)
	#10 ref_input = ref_input_mem1[i1];
end

initial
begin
	#7030	
	for(i2=0;i2<64;i2=i2+1)
	#10 current_64pixels = current_mem[i2];
end

initial
begin
	#10770	
	for(i3=0;i3<192;i3=i3+1)
	#10 ref_input = ref_input_mem2[i3];
end

initial
begin
	#20280	
	for(i4=192;i4<384;i4=i4+1)
	#10 ref_input = ref_input_mem2[i4];
end

endmodule
