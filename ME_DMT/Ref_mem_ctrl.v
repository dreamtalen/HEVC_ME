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
output reg [3:0] rdR_sel,
output reg [4:0] shift_value
);

parameter [2:0]
IDLE = 3'b000, 
DATA_PRE = 3'b001,
SUB_AERA1 = 3'b010,
SUB_AERA2 = 3'b011,
SUB_AERA3 = 3'b100;

reg [3:0] current_state, next_state;
reg [9:0] pre_count;
reg [6:0] pre_line_count;
reg [6:0] pre_rd_count;
// reg [2:0] sub_area1_column_count; //每组搜索子区间1有7列，共两组，不用了，直接用整体的列计数器
reg [6:0] sub_area1_row_count;
reg [6:0] sub_area2_row_count;
reg [6:0] sub_area3_row_count;
reg read_stall; //标志位，用来控制参考帧复用时输出地址停止+1
reg CB12or34; //标志位，记录在降采样区间当前计算的是子块12还是子块34
reg [1:0] CB1or2or3or4; //标志位，记录在全采样区间当前计算的子块是1或2或3或4
reg [4:0] search_column_count;

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
		shift_value <= 5'b0;
		search_column_count <= 5'b0;
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
		// sub_area1_column_count <= 3'b0;
		sub_area1_row_count <= 7'b0;
		sub_area2_row_count <= 7'b0;
		sub_area3_row_count <= 7'b0;
		CB12or34 <= 1'b0;
		search_column_count <= 5'b0;
		CB1or2or3or4 <= 2'b00;
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
		case(search_column_count)
		1: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			// sub_area1_row_count <= sub_area1_row_count + 1'd1;
			if (CB12or34 == 0) begin
				rd_address_all <= {32{sub_area1_row_count+4}};
				if (sub_area1_row_count >= 3 && sub_area1_row_count <= 15 && read_stall == 0) begin
					// sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {32{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					// sub_area1_row_count <= sub_area1_row_count - 1'd1;
					read_stall <= 1'b1;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end

			end
			if (sub_area1_row_count == 19 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
			end
		2: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (CB12or34 == 0) begin
				rd_address_all <= {{24{sub_area1_row_count}}, {8{sub_area1_row_count+24}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 8;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {{24{sub_area1_row_count+24}}, {8{sub_area1_row_count+48}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 8;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
		end
		3: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (CB12or34 == 0) begin
				rd_address_all <= {{16{sub_area1_row_count}}, {16{sub_area1_row_count+24}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 16;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {{16{sub_area1_row_count+24}}, {16{sub_area1_row_count+48}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 16;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
			end
		4: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (CB12or34 == 0) begin
				rd_address_all <= {{8{sub_area1_row_count}}, {24{sub_area1_row_count+24}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 24;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {{8{sub_area1_row_count+24}}, {24{sub_area1_row_count+48}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 24;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
			end
		5: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (CB12or34 == 0) begin
				rd_address_all <= {32{sub_area1_row_count+24}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {32{sub_area1_row_count+48}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
			end
		6: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (CB12or34 == 0) begin
				rd_address_all <= {{24{sub_area1_row_count+24}}, {8{sub_area1_row_count+48}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 8;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {{24{sub_area1_row_count+48}}, {8{sub_area1_row_count+72}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 8;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
			end
		7: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (CB12or34 == 0) begin
				rd_address_all <= {{16{sub_area1_row_count+24}}, {16{sub_area1_row_count+48}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 16;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			else begin
				rd_address_all <= {{16{sub_area1_row_count+48}}, {16{sub_area1_row_count+72}}};
				if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
					read_stall <= 1'b1;
					shift_value <= 16;
				end
				else begin
					sub_area1_row_count <= sub_area1_row_count + 1'd1;
					read_stall <= 1'b0;
				end
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
			end
			if (sub_area1_row_count == 23 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				// sub_area1_column_count <= sub_area1_column_count + 1;
				search_column_count <= search_column_count + 1;
			end
			end
		endcase
	end
	SUB_AERA2: begin
		case(search_column_count)
		8: begin
			if (sub_area2_row_count < 8) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+24}}, {24{sub_area2_row_count+48}}};
				else rd_address_all <= {{8{sub_area2_row_count+48}}, {24{sub_area2_row_count+72}}};
				shift_value <= 24;
				sub_area2_row_count <= sub_area2_row_count + 1;
			end
			else if (sub_area2_row_count >= 8 && sub_area2_row_count < 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+24}}, {24{sub_area2_row_count+48}}};
				else rd_address_all <= {{8{sub_area2_row_count+48}}, {24{sub_area2_row_count+72}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count == 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+24}}, {24{sub_area2_row_count+48}}};
				else rd_address_all <= {{8{sub_area2_row_count+48}}, {24{sub_area2_row_count+72}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 12 && sub_area2_row_count < 19) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 10;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b100011}}, {24{7'b0111011}}};
				else rd_address_all <= {{8{7'b100011 + 24}}, {24{7'b0111011 + 24}}};
				shift_value <= 24;
			end
			else if (sub_area2_row_count == 19) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+17}}, {24{sub_area2_row_count+41}}};
				else rd_address_all <= {{8{sub_area2_row_count+41}}, {24{sub_area2_row_count+65}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 20 && sub_area2_row_count < 27) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 18;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b0100100}}, {24{7'b0111100}}};
				else rd_address_all <= {{8{7'b0100100+24}}, {24{7'b0111100+24}}};
				shift_value <= 24;
			end
			else if (sub_area2_row_count >= 27 && sub_area2_row_count < 29) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+10}}, {24{sub_area2_row_count+34}}};
				else rd_address_all <= {{8{sub_area2_row_count+34}}, {24{sub_area2_row_count+58}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count == 29) begin
				rd8R_en <= 0;
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					rdR_sel <= 4'b0001;
					if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+10}}, {24{sub_area2_row_count+34}}};
					else rd_address_all <= {{8{sub_area2_row_count+34}}, {24{sub_area2_row_count+58}}};
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 30 && sub_area2_row_count < 37) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 28;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b0100111}}, {24{7'b0111111}}};
				else rd_address_all <= {{8{7'b0100111+24}}, {24{7'b0111111+24}}};
				shift_value <= 24;
			end
			else if (sub_area2_row_count == 37) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+3}}, {24{sub_area2_row_count+27}}};
				else rd_address_all <= {{8{sub_area2_row_count+27}}, {24{sub_area2_row_count+51}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 38 && sub_area2_row_count < 45) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 36;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b0101000}}, {24{7'b1000000}}};
				else rd_address_all <= {{8{7'b0101000+24}}, {24{7'b1000000+24}}};
				shift_value <= 24;
			end
			else if (sub_area2_row_count >= 45 && sub_area2_row_count < 49) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count-4}}, {24{sub_area2_row_count+20}}};
				else rd_address_all <= {{8{sub_area2_row_count + 20}}, {24{sub_area2_row_count+44}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 49 && sub_area2_row_count < 52) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count-4}}, {24{sub_area2_row_count+20}}};
				else rd_address_all <= {{8{sub_area2_row_count + 20}}, {24{sub_area2_row_count+44}}};
				shift_value <= 24;
				sub_area2_row_count <= sub_area2_row_count + 1;
			end
			else begin
				if (CB12or34 == 1'b0) begin
					CB12or34 <= 1'b1;
					sub_area2_row_count <= 0;
				end
				else begin
					CB12or34 <= 1'b0;	
					sub_area2_row_count <= 0;
					search_column_count <= search_column_count + 1;
				end
			end
		end
		16: begin
			if (sub_area2_row_count < 8) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+48}};
				else rd_address_all <= {32{sub_area2_row_count+72}};
				shift_value <= 0;
				sub_area2_row_count <= sub_area2_row_count + 1;
			end
			else if (sub_area2_row_count >= 8 && sub_area2_row_count < 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+48}};
				else rd_address_all <= {32{sub_area2_row_count+72}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count == 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+48}};
				else rd_address_all <= {32{sub_area2_row_count+72}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 12 && sub_area2_row_count < 19) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 10;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b0111011}};
				else rd_address_all <= {32{7'b0111011 + 24}};
				shift_value <= 0;
			end
			else if (sub_area2_row_count == 19) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+41}};
				else rd_address_all <= {32{sub_area2_row_count+65}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 20 && sub_area2_row_count < 27) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 18;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b0111100}};
				else rd_address_all <= {32{7'b0111100+24}};
				shift_value <= 0;
			end
			else if (sub_area2_row_count >= 27 && sub_area2_row_count < 29) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+34}};
				else rd_address_all <= {32{sub_area2_row_count+58}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count == 29) begin
				rd8R_en <= 0;
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					rdR_sel <= 4'b0001;
					if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+34}};
					else rd_address_all <= {32{sub_area2_row_count+58}};
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 30 && sub_area2_row_count < 37) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 28;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b0111111}};
				else rd_address_all <= {32{7'b0111111+24}};
				shift_value <= 0;
			end
			else if (sub_area2_row_count == 37) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+27}};
				else rd_address_all <= {32{sub_area2_row_count+51}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 38 && sub_area2_row_count < 45) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 36;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b1000000}};
				else rd_address_all <= {32{7'b1000000+24}};
				shift_value <= 0;
			end
			else if (sub_area2_row_count >= 45 && sub_area2_row_count < 49) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+20}};
				else rd_address_all <= {32{sub_area2_row_count+44}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 49 && sub_area2_row_count < 52) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+20}};
				else rd_address_all <= {32{sub_area2_row_count+44}};
				shift_value <= 0;
				sub_area2_row_count <= sub_area2_row_count + 1;
			end
			else begin
				if (CB12or34 == 1'b0) begin
					CB12or34 <= 1'b1;
					sub_area2_row_count <= 0;
				end
				else begin
					CB12or34 <= 1'b0;	
					sub_area2_row_count <= 0;
					search_column_count <= search_column_count + 1;
				end
			end
		end
		24: begin
			if (sub_area2_row_count < 8) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+48}}, {8{sub_area2_row_count+72}}};
				else rd_address_all <= {{24{sub_area2_row_count+72}}, {8{sub_area2_row_count}}};
				shift_value <= 8;
				sub_area2_row_count <= sub_area2_row_count + 1;
			end
			else if (sub_area2_row_count >= 8 && sub_area2_row_count < 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+48}}, {8{sub_area2_row_count+72}}};
				else rd_address_all <= {{24{sub_area2_row_count+72}}, {8{sub_area2_row_count}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count == 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+48}}, {8{sub_area2_row_count+72}}};
				else rd_address_all <= {{24{sub_area2_row_count+72}}, {8{sub_area2_row_count}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 12 && sub_area2_row_count < 19) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 10;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b0111011}}, {8{7'b1010011}}}; //59, 83
				else rd_address_all <= {{24{7'b0111011 + 24}}, {8{7'b0001011}}}; // 83, 11
				shift_value <= 8;
			end
			else if (sub_area2_row_count == 19) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+41}}, {8{sub_area2_row_count+65}}}; //60. 84
				else rd_address_all <= {{24{sub_area2_row_count+65}}, {8{sub_area2_row_count-7}}}; //84, 12
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 20 && sub_area2_row_count < 27) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 18;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b0111100}}, {8{7'b1010100}}};
				else rd_address_all <= {{24{7'b1010100}}, {8{7'b0001100}}};
				shift_value <= 8;
			end
			else if (sub_area2_row_count >= 27 && sub_area2_row_count < 29) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+34}}, {8{sub_area2_row_count+58}}};
				else rd_address_all <= {{24{sub_area2_row_count+58}}, {8{sub_area2_row_count-14}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count == 29) begin
				rd8R_en <= 0;
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					rdR_sel <= 4'b0001;
					if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+34}}, {8{sub_area2_row_count+58}}};
					else rd_address_all <= {{24{sub_area2_row_count+58}}, {8{sub_area2_row_count-14}}};
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 30 && sub_area2_row_count < 37) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 28;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b0111111}}, {8{7'b1010111}}}; //63, 87
				else rd_address_all <= {{24{7'b1010111}}, {8{7'b0001111}}}; //87, 15
				shift_value <= 8;
			end
			else if (sub_area2_row_count == 37) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+27}}, {8{sub_area2_row_count+51}}};
				else rd_address_all <= {{24{sub_area2_row_count+51}}, {8{sub_area2_row_count-21}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 38 && sub_area2_row_count < 45) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 36;
				sub_area2_row_count <= sub_area2_row_count + 1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b1000000}}, {8{7'b1011000}}}; // 64 88
				else rd_address_all <= {{24{7'b1011000}}, {8{7'b0010000}}}; // 88 16
				shift_value <= 8;
			end
			else if (sub_area2_row_count >= 45 && sub_area2_row_count < 49) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+20}}, {8{sub_area2_row_count+44}}};
				else rd_address_all <= {{24{sub_area2_row_count + 44}}, {8{sub_area2_row_count-28}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 1;
				end
			end
			else if (sub_area2_row_count >= 49 && sub_area2_row_count < 52) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+20}}, {8{sub_area2_row_count+44}}};
				else rd_address_all <= {{24{sub_area2_row_count + 44}}, {8{sub_area2_row_count-28}}};
				shift_value <= 8;
				sub_area2_row_count <= sub_area2_row_count + 1;
			end
			else begin
				if (CB12or34 == 1'b0) begin
					CB12or34 <= 1'b1;
					sub_area2_row_count <= 0;
				end
				else begin
					CB12or34 <= 1'b0;	
					sub_area2_row_count <= 0;
					search_column_count <= search_column_count + 1;
				end
			end
		end
		endcase
	end
	SUB_AERA3: begin
		case (search_column_count)
		9: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 25;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7{sub_area3_row_count+31}}, {25{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{7{sub_area3_row_count+35}}, {25{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{7{sub_area3_row_count+55}}, {25{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{7{sub_area3_row_count+59}}, {25{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7{7'b0100011}}, {25{7'b0111011}}};
				2'b01: rd_address_all <= {{7{7'b0100011+4}}, {25{7'b0111011+4}}};
				2'b10: rd_address_all <= {{7{7'b0100011+24}}, {25{7'b0111011+24}}};
				2'b11: rd_address_all <= {{7{7'b0100011+28}}, {25{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7{7'b0100100}}, {25{7'b0111100}}};
				2'b01: rd_address_all <= {{7{7'b0100100+4}}, {25{7'b0111100+4}}};
				2'b10: rd_address_all <= {{7{7'b0100100+24}}, {25{7'b0111100+24}}};
				2'b11: rd_address_all <= {{7{7'b0100100+28}}, {25{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		10: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 26;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{6{sub_area3_row_count+31}}, {26{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{6{sub_area3_row_count+35}}, {26{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{6{sub_area3_row_count+55}}, {26{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{6{sub_area3_row_count+59}}, {26{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{6{7'b0100011}}, {26{7'b0111011}}};
				2'b01: rd_address_all <= {{6{7'b0100011+4}}, {26{7'b0111011+4}}};
				2'b10: rd_address_all <= {{6{7'b0100011+24}}, {26{7'b0111011+24}}};
				2'b11: rd_address_all <= {{6{7'b0100011+28}}, {26{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{6{7'b0100100}}, {26{7'b0111100}}};
				2'b01: rd_address_all <= {{6{7'b0100100+4}}, {26{7'b0111100+4}}};
				2'b10: rd_address_all <= {{6{7'b0100100+24}}, {26{7'b0111100+24}}};
				2'b11: rd_address_all <= {{6{7'b0100100+28}}, {26{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		11: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 27;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{5{sub_area3_row_count+31}}, {27{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{5{sub_area3_row_count+35}}, {27{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{5{sub_area3_row_count+55}}, {27{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{5{sub_area3_row_count+59}}, {27{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{5{7'b0100011}}, {27{7'b0111011}}};
				2'b01: rd_address_all <= {{5{7'b0100011+4}}, {27{7'b0111011+4}}};
				2'b10: rd_address_all <= {{5{7'b0100011+24}}, {27{7'b0111011+24}}};
				2'b11: rd_address_all <= {{5{7'b0100011+28}}, {27{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{5{7'b0100100}}, {27{7'b0111100}}};
				2'b01: rd_address_all <= {{5{7'b0100100+4}}, {27{7'b0111100+4}}};
				2'b10: rd_address_all <= {{5{7'b0100100+24}}, {27{7'b0111100+24}}};
				2'b11: rd_address_all <= {{5{7'b0100100+28}}, {27{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		12: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 28;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{4{sub_area3_row_count+31}}, {28{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{4{sub_area3_row_count+35}}, {28{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{4{sub_area3_row_count+55}}, {28{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{4{sub_area3_row_count+59}}, {28{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{4{7'b0100011}}, {28{7'b0111011}}};
				2'b01: rd_address_all <= {{4{7'b0100011+4}}, {28{7'b0111011+4}}};
				2'b10: rd_address_all <= {{4{7'b0100011+24}}, {28{7'b0111011+24}}};
				2'b11: rd_address_all <= {{4{7'b0100011+28}}, {28{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{4{7'b0100100}}, {28{7'b0111100}}};
				2'b01: rd_address_all <= {{4{7'b0100100+4}}, {28{7'b0111100+4}}};
				2'b10: rd_address_all <= {{4{7'b0100100+24}}, {28{7'b0111100+24}}};
				2'b11: rd_address_all <= {{4{7'b0100100+28}}, {28{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		13: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 29;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{3{sub_area3_row_count+31}}, {29{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{3{sub_area3_row_count+35}}, {29{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{3{sub_area3_row_count+55}}, {29{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{3{sub_area3_row_count+59}}, {29{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{3{7'b0100011}}, {29{7'b0111011}}};
				2'b01: rd_address_all <= {{3{7'b0100011+4}}, {29{7'b0111011+4}}};
				2'b10: rd_address_all <= {{3{7'b0100011+24}}, {29{7'b0111011+24}}};
				2'b11: rd_address_all <= {{3{7'b0100011+28}}, {29{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{3{7'b0100100}}, {29{7'b0111100}}};
				2'b01: rd_address_all <= {{3{7'b0100100+4}}, {29{7'b0111100+4}}};
				2'b10: rd_address_all <= {{3{7'b0100100+24}}, {29{7'b0111100+24}}};
				2'b11: rd_address_all <= {{3{7'b0100100+28}}, {29{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		14: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 30;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{2{sub_area3_row_count+31}}, {30{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{2{sub_area3_row_count+35}}, {30{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{2{sub_area3_row_count+55}}, {30{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{2{sub_area3_row_count+59}}, {30{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{2{7'b0100011}}, {30{7'b0111011}}};
				2'b01: rd_address_all <= {{2{7'b0100011+4}}, {30{7'b0111011+4}}};
				2'b10: rd_address_all <= {{2{7'b0100011+24}}, {30{7'b0111011+24}}};
				2'b11: rd_address_all <= {{2{7'b0100011+28}}, {30{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{2{7'b0100100}}, {30{7'b0111100}}};
				2'b01: rd_address_all <= {{2{7'b0100100+4}}, {30{7'b0111100+4}}};
				2'b10: rd_address_all <= {{2{7'b0100100+24}}, {30{7'b0111100+24}}};
				2'b11: rd_address_all <= {{2{7'b0100100+28}}, {30{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		15: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 31;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{sub_area3_row_count+31}, {31{sub_area3_row_count+55}}};
				2'b01: rd_address_all <= {{sub_area3_row_count+35}, {31{sub_area3_row_count+59}}};
				2'b10: rd_address_all <= {{sub_area3_row_count+55}, {31{sub_area3_row_count+79}}};
				2'b11: rd_address_all <= {{sub_area3_row_count+59}, {31{sub_area3_row_count+83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7'b0100011}, {31{7'b0111011}}};
				2'b01: rd_address_all <= {{7'b0100011+4}, {31{7'b0111011+4}}};
				2'b10: rd_address_all <= {{7'b0100011+24}, {31{7'b0111011+24}}};
				2'b11: rd_address_all <= {{7'b0100011+28}, {31{7'b0111011+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7'b0100100}, {31{7'b0111100}}};
				2'b01: rd_address_all <= {{7'b0100100+4}, {31{7'b0111100+4}}};
				2'b10: rd_address_all <= {{7'b0100100+24}, {31{7'b0111100+24}}};
				2'b11: rd_address_all <= {{7'b0100100+28}, {31{7'b0111100+28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		17: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 1;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{31{sub_area3_row_count+55}}, {sub_area3_row_count+79}};
				2'b01: rd_address_all <= {{31{sub_area3_row_count+59}}, {sub_area3_row_count+83}};
				2'b10: rd_address_all <= {{31{sub_area3_row_count+79}}, {sub_area3_row_count+7}};
				2'b11: rd_address_all <= {{31{sub_area3_row_count+83}}, {sub_area3_row_count+11}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{31{7'b0111011}}, {7'b1010011}};
				2'b01: rd_address_all <= {{31{7'b0111011+4}}, {7'b1010011+4}};
				2'b10: rd_address_all <= {{31{7'b0111011+24}}, {7'b1010011-72}};
				2'b11: rd_address_all <= {{31{7'b0111011+28}}, {7'b1010011-68}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{31{7'b0111100}}, {7'b1010100}};
				2'b01: rd_address_all <= {{31{7'b0111100+4}}, {7'b1010100+4}};
				2'b10: rd_address_all <= {{31{7'b0111100+24}}, {7'b1010100-72}};
				2'b11: rd_address_all <= {{31{7'b0111100+28}}, {7'b1010100-68}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		18: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 2;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{30{sub_area3_row_count+55}}, {2{sub_area3_row_count+79}}};
				2'b01: rd_address_all <= {{30{sub_area3_row_count+59}}, {2{sub_area3_row_count+83}}};
				2'b10: rd_address_all <= {{30{sub_area3_row_count+79}}, {2{sub_area3_row_count+7}}};
				2'b11: rd_address_all <= {{30{sub_area3_row_count+83}}, {2{sub_area3_row_count+11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{30{7'b0111011}}, {2{7'b1010011}}};
				2'b01: rd_address_all <= {{30{7'b0111011+4}}, {2{7'b1010011+4}}};
				2'b10: rd_address_all <= {{30{7'b0111011+24}}, {2{7'b1010011-72}}};
				2'b11: rd_address_all <= {{30{7'b0111011+28}}, {2{7'b1010011-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{30{7'b0111100}}, {2{7'b1010100}}};
				2'b01: rd_address_all <= {{30{7'b0111100+4}}, {2{7'b1010100+4}}};
				2'b10: rd_address_all <= {{30{7'b0111100+24}}, {2{7'b1010100-72}}};
				2'b11: rd_address_all <= {{30{7'b0111100+28}}, {2{7'b1010100-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		19: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 3;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{29{sub_area3_row_count+55}}, {3{sub_area3_row_count+79}}};
				2'b01: rd_address_all <= {{29{sub_area3_row_count+59}}, {3{sub_area3_row_count+83}}};
				2'b10: rd_address_all <= {{29{sub_area3_row_count+79}}, {3{sub_area3_row_count+7}}};
				2'b11: rd_address_all <= {{29{sub_area3_row_count+83}}, {3{sub_area3_row_count+11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{29{7'b0111011}}, {3{7'b1010011}}};
				2'b01: rd_address_all <= {{29{7'b0111011+4}}, {3{7'b1010011+4}}};
				2'b10: rd_address_all <= {{29{7'b0111011+24}}, {3{7'b1010011-72}}};
				2'b11: rd_address_all <= {{29{7'b0111011+28}}, {3{7'b1010011-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{29{7'b0111100}}, {3{7'b1010100}}};
				2'b01: rd_address_all <= {{29{7'b0111100+4}}, {3{7'b1010100+4}}};
				2'b10: rd_address_all <= {{29{7'b0111100+24}}, {3{7'b1010100-72}}};
				2'b11: rd_address_all <= {{29{7'b0111100+28}}, {3{7'b1010100-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		20: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 4;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{28{sub_area3_row_count+55}}, {4{sub_area3_row_count+79}}};
				2'b01: rd_address_all <= {{28{sub_area3_row_count+59}}, {4{sub_area3_row_count+83}}};
				2'b10: rd_address_all <= {{28{sub_area3_row_count+79}}, {4{sub_area3_row_count+7}}};
				2'b11: rd_address_all <= {{28{sub_area3_row_count+83}}, {4{sub_area3_row_count+11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{28{7'b0111011}}, {4{7'b1010011}}};
				2'b01: rd_address_all <= {{28{7'b0111011+4}}, {4{7'b1010011+4}}};
				2'b10: rd_address_all <= {{28{7'b0111011+24}}, {4{7'b1010011-72}}};
				2'b11: rd_address_all <= {{28{7'b0111011+28}}, {4{7'b1010011-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{28{7'b0111100}}, {4{7'b1010100}}};
				2'b01: rd_address_all <= {{28{7'b0111100+4}}, {4{7'b1010100+4}}};
				2'b10: rd_address_all <= {{28{7'b0111100+24}}, {4{7'b1010100-72}}};
				2'b11: rd_address_all <= {{28{7'b0111100+28}}, {4{7'b1010100-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		21: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 5;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{27{sub_area3_row_count+55}}, {5{sub_area3_row_count+79}}};
				2'b01: rd_address_all <= {{27{sub_area3_row_count+59}}, {5{sub_area3_row_count+83}}};
				2'b10: rd_address_all <= {{27{sub_area3_row_count+79}}, {5{sub_area3_row_count+7}}};
				2'b11: rd_address_all <= {{27{sub_area3_row_count+83}}, {5{sub_area3_row_count+11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{27{7'b0111011}}, {5{7'b1010011}}};
				2'b01: rd_address_all <= {{27{7'b0111011+4}}, {5{7'b1010011+4}}};
				2'b10: rd_address_all <= {{27{7'b0111011+24}}, {5{7'b1010011-72}}};
				2'b11: rd_address_all <= {{27{7'b0111011+28}}, {5{7'b1010011-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{27{7'b0111100}}, {5{7'b1010100}}};
				2'b01: rd_address_all <= {{27{7'b0111100+4}}, {5{7'b1010100+4}}};
				2'b10: rd_address_all <= {{27{7'b0111100+24}}, {5{7'b1010100-72}}};
				2'b11: rd_address_all <= {{27{7'b0111100+28}}, {5{7'b1010100-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		22: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 6;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{26{sub_area3_row_count+55}}, {6{sub_area3_row_count+79}}};
				2'b01: rd_address_all <= {{26{sub_area3_row_count+59}}, {6{sub_area3_row_count+83}}};
				2'b10: rd_address_all <= {{26{sub_area3_row_count+79}}, {6{sub_area3_row_count+7}}};
				2'b11: rd_address_all <= {{26{sub_area3_row_count+83}}, {6{sub_area3_row_count+11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{26{7'b0111011}}, {6{7'b1010011}}};
				2'b01: rd_address_all <= {{26{7'b0111011+4}}, {6{7'b1010011+4}}};
				2'b10: rd_address_all <= {{26{7'b0111011+24}}, {6{7'b1010011-72}}};
				2'b11: rd_address_all <= {{26{7'b0111011+28}}, {6{7'b1010011-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{26{7'b0111100}}, {6{7'b1010100}}};
				2'b01: rd_address_all <= {{26{7'b0111100+4}}, {6{7'b1010100+4}}};
				2'b10: rd_address_all <= {{26{7'b0111100+24}}, {6{7'b1010100-72}}};
				2'b11: rd_address_all <= {{26{7'b0111100+28}}, {6{7'b1010100-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		23: begin
		 	rd8R_en <= 0;
			sub_area3_row_count <= sub_area3_row_count + 1;
			shift_value <= 7;
			if (sub_area3_row_count < 4) begin
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{25{sub_area3_row_count+55}}, {7{sub_area3_row_count+79}}};
				2'b01: rd_address_all <= {{25{sub_area3_row_count+59}}, {7{sub_area3_row_count+83}}};
				2'b10: rd_address_all <= {{25{sub_area3_row_count+79}}, {7{sub_area3_row_count+7}}};
				2'b11: rd_address_all <= {{25{sub_area3_row_count+83}}, {7{sub_area3_row_count+11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				rdR_sel <= sub_area3_row_count[3:0] - 3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{25{7'b0111011}}, {7{7'b1010011}}};
				2'b01: rd_address_all <= {{25{7'b0111011+4}}, {7{7'b1010011+4}}};
				2'b10: rd_address_all <= {{25{7'b0111011+24}}, {7{7'b1010011-72}}};
				2'b11: rd_address_all <= {{25{7'b0111011+28}}, {7{7'b1010011-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				rdR_sel <= sub_area3_row_count[3:0] - 11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{25{7'b0111100}}, {7{7'b1010100}}};
				2'b01: rd_address_all <= {{25{7'b0111100+4}}, {7{7'b1010100+4}}};
				2'b10: rd_address_all <= {{25{7'b0111100+24}}, {7{7'b1010100-72}}};
				2'b11: rd_address_all <= {{25{7'b0111100+28}}, {7{7'b1010100-68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else begin
				sub_area3_row_count <= 7'b0;
				case (CB1or2or3or4)
				2'b00: CB1or2or3or4 <= 2'b01;
				2'b01: CB1or2or3or4 <= 2'b10;
				2'b10: CB1or2or3or4 <= 2'b11;
				2'b11: begin
					CB1or2or3or4 <= 2'b00;
					search_column_count <= search_column_count + 1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
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
	DATA_PRE: if (pre_count < 768)
		next_state = DATA_PRE;
		else begin
		next_state = SUB_AERA1;
		search_column_count = 1;
		end
	SUB_AERA1: if (search_column_count < 7)
		next_state = SUB_AERA1;
		else 
		next_state = SUB_AERA2;
	SUB_AERA2: if (search_column_count == 8 | search_column_count == 16)
		next_state = SUB_AERA3;
		else 
		next_state = SUB_AERA1;
	SUB_AERA3: if (search_column_count == 15 | search_column_count == 23)
		next_state = SUB_AERA2;
		else 
		next_state = SUB_AERA3;
	default: next_state = IDLE;
	endcase
end

endmodule