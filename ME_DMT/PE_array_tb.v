`define PIXEL 8
`define X 32
`define Y 32
`define BAND_WIDTH_X `PIXEL*`X //256
`define BAND_WIDTH_Y `PIXEL*`Y //256
`define ARRAY_SIZE `X*`Y //1024
`define ARRAY_PIXELS `ARRAY_SIZE*`PIXEL //8192

module PE_array_tb;
reg clk;
reg rst_n;
reg [2*`BAND_WIDTH_X-1:0] current_64pixels;
reg in_curr_enable;
reg CB_select;
reg [1:0] abs_Control;
reg [`BAND_WIDTH_X*8-1:0] ref_8R_32;
reg change_ref;
reg ref_input_Control;
wire [`ARRAY_PIXELS-1:0] abs_outs;
	reg [3:0] A = 4'b0001;
	reg [3:0] B = 4'b0010;

PE_array pe_array(.clk(clk), .rst_n(rst_n), .current_64pixels(current_64pixels), .in_curr_enable(in_curr_enable),
	.CB_select(CB_select), .abs_Control(abs_Control), .ref_8R_32(ref_8R_32), .change_ref(change_ref),
	.ref_input_Control(ref_input_Control), .abs_outs(abs_outs));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;


initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	#5 in_curr_enable = 1'b1;
	current_64pixels = { 16{4'b0011} };
	ref_8R_32 = { 256{8'b01010101} };
	CB_select = 1'b1;
	abs_Control = 2'b00;
	change_ref = 1'b1;
	ref_input_Control = 1'b1;
	#10 abs_Control = 2'b01;
end

initial
	$monitor($time, " abs_outs = %b", abs_outs);

endmodule
