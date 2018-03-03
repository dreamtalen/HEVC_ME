module test_assign_twice;
reg [2:0] a;
reg clk;
reg sign;

initial begin
	clk = 1'b0;
	sign = 1'b0;
	a = 3'b0;
end
always
	#5 clk = ~clk;

always @(posedge clk) begin
	
	if (sign == 0) begin
		sign <= 1;
	end
	if (sign == 1) begin
		a <= a + 1'd1;	
		sign <= 0;
	end
end
endmodule