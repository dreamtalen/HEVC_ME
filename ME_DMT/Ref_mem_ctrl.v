module Ref_mem_ctrl(
//input 待添加来自global的控制信号
input clk,
input rst_n,
input begin_prepare, //刚加 开始准备数据
//output
output reg [31:0] Bank_sel,
output reg [6:0] rd_address,
output reg [7*32-1:0] write_address_all,
output reg rd8R_en,
output reg [3:0] rdR_sel
);

parameter [2:0]
IDLE = 3'b000, 
DATA_PRE = 3'b001,
SUB_AERA1 = 3'b010;

reg [3:0] current_state, next_state;
reg [9:0] pre_count;

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
		current_state <= IDLE;
		Bank_sel <= 32'b0;
		rd_address <= 7'b0;
		write_address_all <= 224'b0;
		rd8R_en <= 1'b1;
		rdR_sel <= 4'b0;
	end
else
	begin
		current_state <= next_state;
	end
end

// 输出
always @(posedge clk)
begin
	case(current_state)
	IDLE: begin
		Bank_sel <= 32'b0;
		rd_address <= 7'b0;
		write_address_all <= 224'b0;
		rd8R_en <= 1'b1;
		rdR_sel <= 4'b0;
		pre_count <= 10'd0;
	end
	DATA_PRE: begin
		// 初始化，缓存好初始数据
		pre_count <= pre_count + 1'd1;
		if (pre_count < 96) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			write_address_all <= { 32{pre_count[6:0]} };
		end
		else if (pre_count >= 96 & pre_count < 192) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		else if (pre_count >= 192 & pre_count < 288) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		else if (pre_count >= 288 & pre_count < 384) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		else if (pre_count >= 384 & pre_count < 480) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		else if (pre_count >= 480 & pre_count < 576) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		else if (pre_count >= 576 & pre_count < 672) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		else if (pre_count >= 672 & pre_count < 768) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			write_address_all <= { 32{pre_count%96[6:0]} };
		end
		// 在最后四个周期 给PE输出好第一个搜索点需要的参考帧数据: 32个ram的前四行
		if (pre_count >= 764 & pre_count < 768) begin
			rd_address <= pre_count - 764;
			rd8R_en <= 0;
			rdR_sel <= 4;
		end
	end
	SUB_AERA1: begin
		
	end
	default: begin
		Bank_sel <= 32'b0;
		rd_address <= 7'b0;
		write_address_all <= 224'b0;
		rd8R_en <= 1'b1;
		rdR_sel <= 4'b0;
	end
	endcase
end

// 状态转换
always @(current_state or begin_prepare or pre_count)
begin
	case(current_state)
	IDLE: if (begin_prepare)
		next_state = DATA_PRE;
		else
		next_state = IDLE;
	DATA_PRE: begin
		if (pre_count < 768)
		next_state = DATA_PRE;
		else
		next_state = SUB_AERA1;  	
	end
	default: next_state = IDLE;
	endcase
end

endmodule