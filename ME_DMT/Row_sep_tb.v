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
	.ref_row5(ref_row5), .ref_row6(ref_row6), .ref_row7(ref_row7), .ref_row8(ref_row8),);

initial 
begin
ref_ou = { 32{64'b1111111111111111111111111111111100000000000000000000000000000000} };
end

initial
	$monitor($time, " ref_row1 = %b", ref_row1);
	$monitor($time, " ref_row2 = %b", ref_row2);
	$monitor($time, " ref_row3 = %b", ref_row3);
	$monitor($time, " ref_row4 = %b", ref_row4);
	$monitor($time, " ref_row5 = %b", ref_row5);
	$monitor($time, " ref_row6 = %b", ref_row6);
	$monitor($time, " ref_row7 = %b", ref_row7);
	$monitor($time, " ref_row8 = %b", ref_row8);

endmodule

