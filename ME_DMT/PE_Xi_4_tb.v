`define PIXEL 8

module PE_Xi_4_tb;
reg					clk;
reg					rst_n;
reg	[`PIXEL-1:0]	in_curr1;         
reg	[`PIXEL-1:0]	in_curr2;         
reg					in_curr_enable;      
reg					CB_select;       
reg	[1:0]			abs_Control;      
reg	[`PIXEL-1:0]	down_ref_adajecent_1;
reg	[`PIXEL-1:0]	down_ref_adajecent_8;
reg                 change_ref;     
reg					ref_input_Control;  

wire [`PIXEL-1:0]	abs_out;
wire [`PIXEL-1:0] 	next_pix1;
wire [`PIXEL-1:0] 	next_pix2;
wire [`PIXEL-1:0] 	ref_pix;

PE_Xi_4 pe_xi_1(.clk(clk), .rst_n(rst_n), .in_curr1(in_curr1), .in_curr2(in_curr2), .in_curr_enable(in_curr_enable),
				.CB_select(CB_select), .abs_Control(abs_Control), .up_ref_adajecent_1(up_ref_adajecent_1),
				.up_ref_adajecent_8(up_ref_adajecent_8), .down_ref_adajecent_1(down_ref_adajecent_1), .down_ref_adajecent_8(down_ref_adajecent_8),
				.change_ref(change_ref), .ref_input_Control(ref_input_Control), .abs_out(abs_out), .next_pix1(next_pix1),
				.next_pix2(next_pix2), .ref_pix(ref_pix));

initial
	clk = 1'b0;
always
	#5 clk = ~clk;

initial
begin
	rst_n = 1'b0;
	#10 rst_n = 1'b1;
	#5 in_curr_enable = 1'b1;
	in_curr1 = 8'b00001111;
	in_curr2 = 8'b00000111;
	CB_select = 1'b1;
	abs_Control = 2'b00;
	down_ref_adajecent_1 = 8'b00000001;
	down_ref_adajecent_8 = 8'b00000010;
	change_ref = 1'b1;
	ref_input_Control = 1'b0;
	#10 abs_Control = 2'b01;
	#10 ref_input_Control = 1'b1;
	#10 ref_input_Control = 1'b0;
end

initial
	$monitor($time, " abs_out = %b, next_pix1 = %b, next_pix2 = %b, ref_pix = %b", abs_out, next_pix1, next_pix2, ref_pix);

endmodule