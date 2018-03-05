module test_assign_twice;
reg [2:0] a;
reg [7:0] b;
reg clk;
reg sign;
reg [1:0] b1 = 2'b01;
reg [1:0] b2 = 2'b10;
initial begin
	clk = 1'b0;
	sign = 1'b0;
	a = 3'b0;
	b = 8'b0;
end
always
	#5 clk = ~clk;

always @(posedge clk) begin
	b <= {{2{b1}}, {2{b2}}};
	if (sign == 0) begin
		sign <= 1;
	end
	if (sign == 1) begin
		a <= a + 1'd1;	
		sign <= 0;
	end
end
endmodule