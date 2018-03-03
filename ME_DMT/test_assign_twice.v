module test_assign_twice;
reg [2:0] a;
reg clk;
reg sign;

initial
	clk = 1'b0;
	sign = 1'b0;
always
	#5 clk = ~clk;

always @(posedge clk) begin
	a <= a + 1'd1;
	if (sign == 0) begin
		a <= a - 1'd1;
		sing <= 1;
	end
end
endmodule