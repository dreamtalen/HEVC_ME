`define PIXEL 8

module Row_sep_tb;
reg [8*32*`PIXEL-1:0] ref_ou;
wire [32*`PIXEL-1:0] ref_row1;
wire [32*`PIXEL-1:0] ref_row2;
wire [32*`PIXEL-1:0] ref_row3;
wire [32*`PIXEL-1:0] ref_row4;
wire [32*`PIXEL-1:0] ref_row5;
wire [32*`PIXEL-1:0] ref_row6;
wire [32*`PIXEL-1:0] ref_row7;
wire [32*`PIXEL-1:0] ref_row8;

Row_sep row_sep(.ref_ou(ref_ou), .ref_row1(ref_row1), .ref_row2(ref_row2), .ref_row3(ref_row3), .ref_row4(ref_row4),
	.ref_row5(ref_row5), .ref_row6(ref_row6), .ref_row7(ref_row7), .ref_row8(ref_row8));

initial 
begin
//ref_ou = { 32{64'b1111111111111111111111111111111100000000000000000000000000000000} };
ref_ou={{8{8'h1f}},{8{8'h1e}},{8{8'h1d}},{8{8'h1c}},{8{8'h1b}},{8{8'h1a}},{8{8'h19}},{8{8'h18}},
	{8{8'h17}},{8{8'h16}},{8{8'h15}},{8{8'h14}},{8{8'h13}},{8{8'h12}},{8{8'h11}},{8{8'h10}},
	{8{8'h0f}},{8{8'h0e}},{8{8'h0d}},{8{8'h0c}},{8{8'h0b}},{8{8'h0a}},{8{8'h09}},{8{8'h08}},
	{8{8'h07}},{8{8'h06}},{8{8'h05}},{8{8'h04}},{8{8'h03}},{8{8'h02}},{8{8'h01}},{8{8'h00}}};
end

initial
	$monitor($time, " ref_row1 = %b, ref_row5 = %b", ref_row1, ref_row5);

endmodule

