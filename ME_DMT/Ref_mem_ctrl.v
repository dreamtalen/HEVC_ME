module Ref_mem_ctrl(
//input 待添加来自global的控制信号
input clk,
input rst_n,
input begin_prepare, //刚加 开始准备数据
//output
output reg [31:0] Bank_sel,
output reg [7*32-1:0] rd_address_all,
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
reg [6:0] pre_line_count;
reg [6:0] pre_rd_count;
reg [2:0] sub_area1_column_count; //每组搜索子区间1有7列，共两组
reg [6:0] sub_area1_row_count;
reg read_stall; //标志位，用来控制参考帧复用时输出地址停止+1
reg CB12or34; //标志位，记录在降采样区间当前计算的是子块12还是子块34
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
		current_state <= IDLE;
		Bank_sel <= 32'b0;
		rd_address_all <= 224'b0;
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
		rd_address_all <= 224'b0;
		write_address_all <= 224'b0;
		rd8R_en <= 1'b1;
		rdR_sel <= 4'b0;
		pre_count <= 10'd0;
		pre_rd_count <= 7'b0;
		pre_line_count <= 7'b0;
		sub_area1_column_count <= 3'b0;
		sub_area1_row_count <= 7'b0;
		CB12or34 <= 1'b0;
	end
	DATA_PRE: begin
		// 初始化，缓存好初始数据
		pre_count <= pre_count + 1'd1;
		if (pre_count < 96) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			write_address_all <= { 32{pre_count[6:0]} };
		end
		else if (pre_count >= 96 && pre_count < 192) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 95;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 192 && pre_count < 288) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 191;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 288 && pre_count < 384) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 287;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 384 && pre_count < 480) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 383;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 480 && pre_count < 576) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 479;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 576 && pre_count < 672) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 575;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 672 && pre_count < 768) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 671;
			write_address_all <= { 32{pre_line_count} };
		end
		// 在最后四个周期 给PE输出好第一个搜索点需要的参考帧数据: 32个ram的前四行
		if (pre_count >= 764 && pre_count < 768) begin
			pre_rd_count <= pre_count - 763;
			rd_address_all <= { 32{pre_rd_count} };
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
		end
	end
	SUB_AERA1: begin
		case(sub_area1_column_count)
		0: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			
			if (CB12or34 == 0) begin
				rd_address_all <= {32{sub_area1_row_count+4}};
				if (sub_area1_row_count >= 3 && sub_area1_row_count <= 15 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {32{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 19 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		1: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {24{sub_area1_row_count}, 8{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {24{sub_area1_row_count+24}， 8{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		2: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {16{sub_area1_row_count}, 16{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {16{sub_area1_row_count+24}， 16{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		3: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {8{sub_area1_row_count}, 24{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {8{sub_area1_row_count+24}， 24{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		4: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {32{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {32{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		5: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {24{sub_area1_row_count+24}, 8{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {24{sub_area1_row_count+48}, 8{sub_area1_row_count+72}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		6: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {16{sub_area1_row_count+24}, 16{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			else begin
				rd_address_all <= {16{sub_area1_row_count+48}, 16{sub_area1_row_count+72}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				sub_area1_column_count <= sub_area1_column_count + 1;
			end
			end
		endcase
	end
	default: begin
		Bank_sel <= 32'b0;
		rd_address_all <= 224'b0;
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