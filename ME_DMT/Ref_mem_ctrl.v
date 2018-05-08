module Ref_mem_ctrl(

input clk,
input rst_n,
input begin_prepare,

output reg [31:0] Bank_sel,
output reg [7*32-1:0] rd_address_all,
output reg [7*32-1:0] write_address_all,
output reg rd8R_en,
output reg [3:0] rdR_sel,
output reg [4:0] shift_value
);

parameter [3:0]
IDLE=4'b0000, SUB_AERA1=4'b0001, SUB_AERA2=4'b0010, SUB_AERA3=4'b0011,
W_IDLE=4'b1000, W_PRE96=4'b1001, W_UP24=4'b1010, W_RELAX=4'b1011, W_UPm24=4'b1100;

reg [3:0] current_state, next_state;
reg [9:0] pre_count;
reg [6:0] pre_line_count;
reg [6:0] pre_rd_count;
reg [6:0] sub_area1_row_count;
reg [6:0] sub_area2_row_count;
reg [6:0] sub_area3_row_count;
reg read_stall; //标志位，用来控制参考帧复用时输出地址停止+1
reg CB12or34; //标志位，记录在降采样区间当前计算的是子块12还是子块34
reg [1:0] CB1or2or3or4; //标志位，记录在全采样区间当前计算的子块是1或2或3或4
reg [4:0] search_column_count;
reg column_finish; //标志位，记录当前列是否计算完毕

reg [3:0] write_current_state, write_next_state;
reg clean_up24,clean_upm24;

//read rst
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
		column_finish <= 1'b0;
	end
else
	begin
		current_state <= next_state;
	end
end

//write rst
always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
		write_current_state <= W_IDLE;
		clean_up24 <= 1'b0;
		clean_upm24 <= 1'b0;
	end
else
	begin
		write_current_state <= write_next_state;
	end
end

//read out
always@(posedge clk)
begin
	case(current_state)
	IDLE: begin
		rd_address_all <= 224'b0;
		rd8R_en <= 1'b1;
		rdR_sel <= 4'b0;
		pre_rd_count <= 7'b0;
		// sub_area1_column_count <= 3'b0;
		sub_area1_row_count <= 7'b0;
		sub_area2_row_count <= 7'b0;
		sub_area3_row_count <= 7'b0;
		CB12or34 <= 1'b0;
		search_column_count <= 5'b00001;
		CB1or2or3or4 <= 2'b00;
		column_finish <= 1'b0;
	end
	SUB_AERA1: begin
		case(search_column_count)
		1: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {32{sub_area1_row_count+7'd4}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
				else begin
					rd_address_all <= {32{sub_area1_row_count+7'd24}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		2: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{24{sub_area1_row_count}}, {8{sub_area1_row_count+7'd24}}};
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
					rd_address_all <= {{24{sub_area1_row_count+7'd24}}, {8{sub_area1_row_count+7'd48}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 8;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
		end
		3: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{16{sub_area1_row_count}}, {16{sub_area1_row_count+7'd24}}};
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
					rd_address_all <= {{16{sub_area1_row_count+7'd24}}, {16{sub_area1_row_count+7'd48}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 16;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		4: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{8{sub_area1_row_count}}, {24{sub_area1_row_count+7'd24}}};
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
					rd_address_all <= {{8{sub_area1_row_count+7'd24}}, {24{sub_area1_row_count+7'd48}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 24;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end			
			end
			end
		5: begin clean_up24 <= 1'b1;
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {32{sub_area1_row_count+7'd24}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
				else begin
					rd_address_all <= {32{sub_area1_row_count+7'd48}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		6: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{24{sub_area1_row_count+7'd24}}, {8{sub_area1_row_count+7'd48}}};
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
					rd_address_all <= {{24{sub_area1_row_count+7'd48}}, {8{sub_area1_row_count+7'd72}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 8;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		7: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{16{sub_area1_row_count+7'd24}}, {16{sub_area1_row_count+7'd48}}};
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
					rd_address_all <= {{16{sub_area1_row_count+7'd48}}, {16{sub_area1_row_count+7'd72}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 16;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end	
			end
			end
		25: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{16{sub_area1_row_count+7'd48}}, {16{sub_area1_row_count+7'd72}}};
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
					rd_address_all <= {{16{sub_area1_row_count+7'd72}}, {16{sub_area1_row_count}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 16;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		26: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{8{sub_area1_row_count+7'd48}}, {24{sub_area1_row_count+7'd72}}};
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
					rd_address_all <= {{8{sub_area1_row_count+7'd72}}, {24{sub_area1_row_count}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 24;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		27: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {32{sub_area1_row_count+7'd72}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 0;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
				else begin
					rd_address_all <= {32{sub_area1_row_count}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 0;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		28: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{24{sub_area1_row_count+7'd72}}, {8{sub_area1_row_count}}};
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
					rd_address_all <= {{24{sub_area1_row_count}}, {8{sub_area1_row_count+7'd24}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 8;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		29: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{16{sub_area1_row_count+7'd72}}, {16{sub_area1_row_count}}};
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
					rd_address_all <= {{16{sub_area1_row_count}}, {16{sub_area1_row_count+7'd24}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 16;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end				
			end
			end
		30: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {{8{sub_area1_row_count+7'd72}}, {24{sub_area1_row_count}}};
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
					rd_address_all <= {{8{sub_area1_row_count}}, {24{sub_area1_row_count+7'd24}}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 24;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		31: begin
			rd8R_en <= 0;
			rdR_sel <= 4'b0;
			if (sub_area1_row_count == 24 && CB12or34 == 1'b0) begin
				CB12or34 <= 1'b1;
				sub_area1_row_count <= 0;
				column_finish <= 1'b0;
			end
			else if (sub_area1_row_count == 24 && CB12or34 == 1'b1) begin
				CB12or34 <= 1'b0;	
				sub_area1_row_count <= 0;
				search_column_count <= search_column_count + 1'd1;
				column_finish <= 1'b1;
			end
			else begin
				column_finish <= 1'b0;
				if (CB12or34 == 0) begin
					rd_address_all <= {32{sub_area1_row_count}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 0;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
				else begin
					rd_address_all <= {32{sub_area1_row_count+7'd24}};
					if (sub_area1_row_count >= 7 && sub_area1_row_count <= 19 && read_stall == 0) begin
						read_stall <= 1'b1;
						shift_value <= 0;
					end
					else begin
						sub_area1_row_count <= sub_area1_row_count + 1'd1;
						read_stall <= 1'b0;
					end
				end
			end
			end
		default: begin column_finish <= 1'b0; end
		endcase
	end
	SUB_AERA2: begin
		if (sub_area2_row_count == 52 && CB12or34 == 1'b1) begin
			column_finish <= 1'b1;
		end
		else begin
			column_finish <= 1'b0;
		end
		case(search_column_count)
		8: begin
			if (sub_area2_row_count < 8) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd24}}, {24{sub_area2_row_count+7'd48}}};
				else rd_address_all <= {{8{sub_area2_row_count+7'd48}}, {24{sub_area2_row_count+7'd72}}};
				shift_value <= 24;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 8 && sub_area2_row_count < 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd24}}, {24{sub_area2_row_count+7'd48}}};
				else rd_address_all <= {{8{sub_area2_row_count+7'd48}}, {24{sub_area2_row_count+7'd72}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd24}}, {24{sub_area2_row_count+7'd48}}};
				else rd_address_all <= {{8{sub_area2_row_count+7'd48}}, {24{sub_area2_row_count+7'd72}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 12 && sub_area2_row_count < 19) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd10;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b100011}}, {24{7'b0111011}}};
				else rd_address_all <= {{8{7'b100011 + 7'd24}}, {24{7'b0111011 + 7'd24}}};
				shift_value <= 24;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 19) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd17}}, {24{sub_area2_row_count+7'd41}}};
				else rd_address_all <= {{8{sub_area2_row_count+7'd41}}, {24{sub_area2_row_count+7'd65}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 20 && sub_area2_row_count < 27) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd18;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b0100100}}, {24{7'b0111100}}};
				else rd_address_all <= {{8{7'b0100100+7'd24}}, {24{7'b0111100+7'd24}}};
				shift_value <= 24;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 27 && sub_area2_row_count < 29) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd10}}, {24{sub_area2_row_count+7'd34}}};
				else rd_address_all <= {{8{sub_area2_row_count+7'd34}}, {24{sub_area2_row_count+7'd58}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
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
					if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd10}}, {24{sub_area2_row_count+7'd34}}};
					else rd_address_all <= {{8{sub_area2_row_count+7'd34}}, {24{sub_area2_row_count+7'd58}}};
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 30 && sub_area2_row_count < 37) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd28;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b0100111}}, {24{7'b0111111}}};
				else rd_address_all <= {{8{7'b0100111+7'd24}}, {24{7'b0111111+7'd24}}};
				shift_value <= 24;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 37) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count+7'd3}}, {24{sub_area2_row_count+7'd27}}};
				else rd_address_all <= {{8{sub_area2_row_count+7'd27}}, {24{sub_area2_row_count+7'd51}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 38 && sub_area2_row_count < 45) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd36;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{7'b0101000}}, {24{7'b1000000}}};
				else rd_address_all <= {{8{7'b0101000+7'd24}}, {24{7'b1000000+7'd24}}};
				shift_value <= 24;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 45 && sub_area2_row_count < 49) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count-7'd4}}, {24{sub_area2_row_count+7'd20}}};
				else rd_address_all <= {{8{sub_area2_row_count + 7'd20}}, {24{sub_area2_row_count+7'd44}}};
				shift_value <= 24;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 49 && sub_area2_row_count < 52) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{8{sub_area2_row_count-7'd4}}, {24{sub_area2_row_count+7'd20}}};
				else rd_address_all <= {{8{sub_area2_row_count + 7'd20}}, {24{sub_area2_row_count+7'd44}}};
				shift_value <= 24;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				// column_finish <= 1'b0;
			end
			else begin
				if (CB12or34 == 1'b0) begin
					CB12or34 <= 1'b1;
					sub_area2_row_count <= 0;
					// column_finish <= 1'b0;
				end
				else begin
					CB12or34 <= 1'b0;	
					sub_area2_row_count <= 0;
					search_column_count <= search_column_count + 1'd1;
					// column_finish <= 1'b1;
				end
			end
		end
		16: begin clean_upm24 <= 1'b1;
			if (sub_area2_row_count < 8) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd48}};
				else rd_address_all <= {32{sub_area2_row_count+7'd72}};
				shift_value <= 0;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 8 && sub_area2_row_count < 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd48}};
				else rd_address_all <= {32{sub_area2_row_count+7'd72}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd48}};
				else rd_address_all <= {32{sub_area2_row_count+7'd72}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 12 && sub_area2_row_count < 19) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd10;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b0111011}};
				else rd_address_all <= {32{7'b0111011 + 7'd24}};
				shift_value <= 0;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 19) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd41}};
				else rd_address_all <= {32{sub_area2_row_count+7'd65}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 20 && sub_area2_row_count < 27) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd18;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b0111100}};
				else rd_address_all <= {32{7'b0111100+7'd24}};
				shift_value <= 0;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 27 && sub_area2_row_count < 29) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd34}};
				else rd_address_all <= {32{sub_area2_row_count+7'd58}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
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
					if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd34}};
					else rd_address_all <= {32{sub_area2_row_count+7'd58}};
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 30 && sub_area2_row_count < 37) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd28;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b0111111}};
				else rd_address_all <= {32{7'b0111111+7'd24}};
				shift_value <= 0;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 37) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd27}};
				else rd_address_all <= {32{sub_area2_row_count+7'd51}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 38 && sub_area2_row_count < 45) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd36;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {32{7'b1000000}};
				else rd_address_all <= {32{7'b1000000+7'd24}};
				shift_value <= 0;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 45 && sub_area2_row_count < 49) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd20}};
				else rd_address_all <= {32{sub_area2_row_count+7'd44}};
				shift_value <= 0;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 49 && sub_area2_row_count < 52) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {32{sub_area2_row_count+7'd20}};
				else rd_address_all <= {32{sub_area2_row_count+7'd44}};
				shift_value <= 0;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				// column_finish <= 1'b0;
			end
			else begin
				if (CB12or34 == 1'b0) begin
					CB12or34 <= 1'b1;
					sub_area2_row_count <= 0;
					// column_finish <= 1'b0;
				end
				else begin
					CB12or34 <= 1'b0;	
					sub_area2_row_count <= 0;
					search_column_count <= search_column_count + 1'd1;
					// column_finish <= 1'b1;
				end
			end
		end
		24: begin
			if (sub_area2_row_count < 8) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd48}}, {8{sub_area2_row_count+7'd72}}};
				else rd_address_all <= {{24{sub_area2_row_count+7'd72}}, {8{sub_area2_row_count}}};
				shift_value <= 8;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 8 && sub_area2_row_count < 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd48}}, {8{sub_area2_row_count+7'd72}}};
				else rd_address_all <= {{24{sub_area2_row_count+7'd72}}, {8{sub_area2_row_count}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 11) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd48}}, {8{sub_area2_row_count+7'd72}}};
				else rd_address_all <= {{24{sub_area2_row_count+7'd72}}, {8{sub_area2_row_count}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 12 && sub_area2_row_count < 19) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd10;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b0111011}}, {8{7'b1010011}}}; //59, 83
				else rd_address_all <= {{24{7'b0111011 + 7'd24}}, {8{7'b0001011}}}; // 83, 11
				shift_value <= 8;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 19) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd41}}, {8{sub_area2_row_count+7'd65}}}; //60. 84
				else rd_address_all <= {{24{sub_area2_row_count+7'd65}}, {8{sub_area2_row_count-7'd7}}}; //84, 12
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 20 && sub_area2_row_count < 27) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd18;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b0111100}}, {8{7'b1010100}}};
				else rd_address_all <= {{24{7'b1010100}}, {8{7'b0001100}}};
				shift_value <= 8;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 27 && sub_area2_row_count < 29) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd34}}, {8{sub_area2_row_count+7'd58}}};
				else rd_address_all <= {{24{sub_area2_row_count+7'd58}}, {8{sub_area2_row_count-7'd14}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
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
					if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd34}}, {8{sub_area2_row_count+7'd58}}};
					else rd_address_all <= {{24{sub_area2_row_count+7'd58}}, {8{sub_area2_row_count-7'd14}}};
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 30 && sub_area2_row_count < 37) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd28;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b0111111}}, {8{7'b1010111}}}; //63, 87
				else rd_address_all <= {{24{7'b1010111}}, {8{7'b0001111}}}; //87, 15
				shift_value <= 8;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count == 37) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0001;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd27}}, {8{sub_area2_row_count+7'd51}}};
				else rd_address_all <= {{24{sub_area2_row_count+7'd51}}, {8{sub_area2_row_count-7'd21}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 38 && sub_area2_row_count < 45) begin
				rd8R_en <= 0;
				rdR_sel <= sub_area2_row_count[3:0] - 4'd36;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{7'b1000000}}, {8{7'b1011000}}}; // 64 88
				else rd_address_all <= {{24{7'b1011000}}, {8{7'b0010000}}}; // 88 16
				shift_value <= 8;
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 45 && sub_area2_row_count < 49) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd20}}, {8{sub_area2_row_count+7'd44}}};
				else rd_address_all <= {{24{sub_area2_row_count + 7'd44}}, {8{sub_area2_row_count-7'd28}}};
				shift_value <= 8;
				if (read_stall == 0) begin
					read_stall <= 1'b1;
				end
				else begin
					read_stall <= 1'b0;
					sub_area2_row_count <= sub_area2_row_count + 7'd1;
				end
				// column_finish <= 1'b0;
			end
			else if (sub_area2_row_count >= 49 && sub_area2_row_count < 52) begin
				rd8R_en <= 0;
				rdR_sel <= 4'b0;
				if (CB12or34 == 1'b0) rd_address_all <= {{24{sub_area2_row_count+7'd20}}, {8{sub_area2_row_count+7'd44}}};
				else rd_address_all <= {{24{sub_area2_row_count + 7'd44}}, {8{sub_area2_row_count-7'd28}}};
				shift_value <= 8;
				sub_area2_row_count <= sub_area2_row_count + 7'd1;
				// column_finish <= 1'b0;
			end
			else begin
				if (CB12or34 == 1'b0) begin
					CB12or34 <= 1'b1;
					sub_area2_row_count <= 0;
					// column_finish <= 1'b0;
				end
				else begin
					CB12or34 <= 1'b0;	
					sub_area2_row_count <= 0;
					search_column_count <= search_column_count + 1'd1;
					// column_finish <= 1'b1;
				end
			end
		end
		default: begin column_finish <= 1'b0; end
		endcase
	end
	SUB_AERA3: begin
		case (search_column_count)
		9: begin
		 	rd8R_en <= 0;
			shift_value <= 25;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7{sub_area3_row_count+7'd31}}, {25{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{7{sub_area3_row_count+7'd35}}, {25{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{7{sub_area3_row_count+7'd55}}, {25{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{7{sub_area3_row_count+7'd59}}, {25{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7{7'b0100011}}, {25{7'b0111011}}};
				2'b01: rd_address_all <= {{7{7'b0100011+7'd4}}, {25{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{7{7'b0100011+7'd24}}, {25{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{7{7'b0100011+7'd28}}, {25{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7{7'b0100100}}, {25{7'b0111100}}};
				2'b01: rd_address_all <= {{7{7'b0100100+7'd4}}, {25{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{7{7'b0100100+7'd24}}, {25{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{7{7'b0100100+7'd28}}, {25{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		10: begin
		 	rd8R_en <= 0;
			shift_value <= 26;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{6{sub_area3_row_count+7'd31}}, {26{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{6{sub_area3_row_count+7'd35}}, {26{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{6{sub_area3_row_count+7'd55}}, {26{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{6{sub_area3_row_count+7'd59}}, {26{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{6{7'b0100011}}, {26{7'b0111011}}};
				2'b01: rd_address_all <= {{6{7'b0100011+7'd4}}, {26{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{6{7'b0100011+7'd24}}, {26{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{6{7'b0100011+7'd28}}, {26{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{6{7'b0100100}}, {26{7'b0111100}}};
				2'b01: rd_address_all <= {{6{7'b0100100+7'd4}}, {26{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{6{7'b0100100+7'd24}}, {26{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{6{7'b0100100+7'd28}}, {26{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		11: begin
		 	rd8R_en <= 0;
			shift_value <= 27;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{5{sub_area3_row_count+7'd31}}, {27{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{5{sub_area3_row_count+7'd35}}, {27{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{5{sub_area3_row_count+7'd55}}, {27{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{5{sub_area3_row_count+7'd59}}, {27{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{5{7'b0100011}}, {27{7'b0111011}}};
				2'b01: rd_address_all <= {{5{7'b0100011+7'd4}}, {27{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{5{7'b0100011+7'd24}}, {27{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{5{7'b0100011+7'd28}}, {27{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{5{7'b0100100}}, {27{7'b0111100}}};
				2'b01: rd_address_all <= {{5{7'b0100100+7'd4}}, {27{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{5{7'b0100100+7'd24}}, {27{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{5{7'b0100100+7'd28}}, {27{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		12: begin
		 	rd8R_en <= 0;
			shift_value <= 28;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{4{sub_area3_row_count+7'd31}}, {28{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{4{sub_area3_row_count+7'd35}}, {28{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{4{sub_area3_row_count+7'd55}}, {28{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{4{sub_area3_row_count+7'd59}}, {28{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{4{7'b0100011}}, {28{7'b0111011}}};
				2'b01: rd_address_all <= {{4{7'b0100011+7'd4}}, {28{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{4{7'b0100011+7'd24}}, {28{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{4{7'b0100011+7'd28}}, {28{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{4{7'b0100100}}, {28{7'b0111100}}};
				2'b01: rd_address_all <= {{4{7'b0100100+7'd4}}, {28{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{4{7'b0100100+7'd24}}, {28{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{4{7'b0100100+7'd28}}, {28{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		13: begin
		 	rd8R_en <= 0;
			shift_value <= 29;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{3{sub_area3_row_count+7'd31}}, {29{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{3{sub_area3_row_count+7'd35}}, {29{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{3{sub_area3_row_count+7'd55}}, {29{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{3{sub_area3_row_count+7'd59}}, {29{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{3{7'b0100011}}, {29{7'b0111011}}};
				2'b01: rd_address_all <= {{3{7'b0100011+7'd4}}, {29{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{3{7'b0100011+7'd24}}, {29{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{3{7'b0100011+7'd28}}, {29{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{3{7'b0100100}}, {29{7'b0111100}}};
				2'b01: rd_address_all <= {{3{7'b0100100+7'd4}}, {29{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{3{7'b0100100+7'd24}}, {29{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{3{7'b0100100+7'd28}}, {29{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		14: begin
		 	rd8R_en <= 0;
			shift_value <= 30;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{2{sub_area3_row_count+7'd31}}, {30{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{2{sub_area3_row_count+7'd35}}, {30{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{2{sub_area3_row_count+7'd55}}, {30{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{2{sub_area3_row_count+7'd59}}, {30{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{2{7'b0100011}}, {30{7'b0111011}}};
				2'b01: rd_address_all <= {{2{7'b0100011+7'd4}}, {30{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{2{7'b0100011+7'd24}}, {30{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{2{7'b0100011+7'd28}}, {30{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{2{7'b0100100}}, {30{7'b0111100}}};
				2'b01: rd_address_all <= {{2{7'b0100100+7'd4}}, {30{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{2{7'b0100100+7'd24}}, {30{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{2{7'b0100100+7'd28}}, {30{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		15: begin
		 	rd8R_en <= 0;
			shift_value <= 31;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{sub_area3_row_count+7'd31}, {31{sub_area3_row_count+7'd55}}};
				2'b01: rd_address_all <= {{sub_area3_row_count+7'd35}, {31{sub_area3_row_count+7'd59}}};
				2'b10: rd_address_all <= {{sub_area3_row_count+7'd55}, {31{sub_area3_row_count+7'd79}}};
				2'b11: rd_address_all <= {{sub_area3_row_count+7'd59}, {31{sub_area3_row_count+7'd83}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7'b0100011}, {31{7'b0111011}}};
				2'b01: rd_address_all <= {{7'b0100011+7'd4}, {31{7'b0111011+7'd4}}};
				2'b10: rd_address_all <= {{7'b0100011+7'd24}, {31{7'b0111011+7'd24}}};
				2'b11: rd_address_all <= {{7'b0100011+7'd28}, {31{7'b0111011+7'd28}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{7'b0100100}, {31{7'b0111100}}};
				2'b01: rd_address_all <= {{7'b0100100+7'd4}, {31{7'b0111100+7'd4}}};
				2'b10: rd_address_all <= {{7'b0100100+7'd24}, {31{7'b0111100+7'd24}}};
				2'b11: rd_address_all <= {{7'b0100100+7'd28}, {31{7'b0111100+7'd28}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		17: begin
		 	rd8R_en <= 0;
			shift_value <= 1;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{31{sub_area3_row_count+7'd55}}, {sub_area3_row_count+7'd79}};
				2'b01: rd_address_all <= {{31{sub_area3_row_count+7'd59}}, {sub_area3_row_count+7'd83}};
				2'b10: rd_address_all <= {{31{sub_area3_row_count+7'd79}}, {sub_area3_row_count+7'd7}};
				2'b11: rd_address_all <= {{31{sub_area3_row_count+7'd83}}, {sub_area3_row_count+7'd11}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{31{7'b0111011}}, {7'b1010011}};
				2'b01: rd_address_all <= {{31{7'b0111011+7'd4}}, {7'b1010011+7'd4}};
				2'b10: rd_address_all <= {{31{7'b0111011+7'd24}}, {7'b1010011-7'd72}};
				2'b11: rd_address_all <= {{31{7'b0111011+7'd28}}, {7'b1010011-7'd68}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{31{7'b0111100}}, {7'b1010100}};
				2'b01: rd_address_all <= {{31{7'b0111100+7'd4}}, {7'b1010100+7'd4}};
				2'b10: rd_address_all <= {{31{7'b0111100+7'd24}}, {7'b1010100-7'd72}};
				2'b11: rd_address_all <= {{31{7'b0111100+7'd28}}, {7'b1010100-7'd68}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		18: begin
		 	rd8R_en <= 0;
			shift_value <= 2;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{30{sub_area3_row_count+7'd55}}, {2{sub_area3_row_count+7'd79}}};
				2'b01: rd_address_all <= {{30{sub_area3_row_count+7'd59}}, {2{sub_area3_row_count+7'd83}}};
				2'b10: rd_address_all <= {{30{sub_area3_row_count+7'd79}}, {2{sub_area3_row_count+7'd7}}};
				2'b11: rd_address_all <= {{30{sub_area3_row_count+7'd83}}, {2{sub_area3_row_count+7'd11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{30{7'b0111011}}, {2{7'b1010011}}};
				2'b01: rd_address_all <= {{30{7'b0111011+7'd4}}, {2{7'b1010011+7'd4}}};
				2'b10: rd_address_all <= {{30{7'b0111011+7'd24}}, {2{7'b1010011-7'd72}}};
				2'b11: rd_address_all <= {{30{7'b0111011+7'd28}}, {2{7'b1010011-7'd68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{30{7'b0111100}}, {2{7'b1010100}}};
				2'b01: rd_address_all <= {{30{7'b0111100+7'd4}}, {2{7'b1010100+7'd4}}};
				2'b10: rd_address_all <= {{30{7'b0111100+7'd24}}, {2{7'b1010100-7'd72}}};
				2'b11: rd_address_all <= {{30{7'b0111100+7'd28}}, {2{7'b1010100-7'd68}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		19: begin
		 	rd8R_en <= 0;
			shift_value <= 3;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{29{sub_area3_row_count+7'd55}}, {3{sub_area3_row_count+7'd79}}};
				2'b01: rd_address_all <= {{29{sub_area3_row_count+7'd59}}, {3{sub_area3_row_count+7'd83}}};
				2'b10: rd_address_all <= {{29{sub_area3_row_count+7'd79}}, {3{sub_area3_row_count+7'd7}}};
				2'b11: rd_address_all <= {{29{sub_area3_row_count+7'd83}}, {3{sub_area3_row_count+7'd11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{29{7'b0111011}}, {3{7'b1010011}}};
				2'b01: rd_address_all <= {{29{7'b0111011+7'd4}}, {3{7'b1010011+7'd4}}};
				2'b10: rd_address_all <= {{29{7'b0111011+7'd24}}, {3{7'b1010011-7'd72}}};
				2'b11: rd_address_all <= {{29{7'b0111011+7'd28}}, {3{7'b1010011-7'd68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{29{7'b0111100}}, {3{7'b1010100}}};
				2'b01: rd_address_all <= {{29{7'b0111100+7'd4}}, {3{7'b1010100+7'd4}}};
				2'b10: rd_address_all <= {{29{7'b0111100+7'd24}}, {3{7'b1010100-7'd72}}};
				2'b11: rd_address_all <= {{29{7'b0111100+7'd28}}, {3{7'b1010100-7'd68}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		20: begin
		 	rd8R_en <= 0;
			shift_value <= 4;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{28{sub_area3_row_count+7'd55}}, {4{sub_area3_row_count+7'd79}}};
				2'b01: rd_address_all <= {{28{sub_area3_row_count+7'd59}}, {4{sub_area3_row_count+7'd83}}};
				2'b10: rd_address_all <= {{28{sub_area3_row_count+7'd79}}, {4{sub_area3_row_count+7'd7}}};
				2'b11: rd_address_all <= {{28{sub_area3_row_count+7'd83}}, {4{sub_area3_row_count+7'd11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{28{7'b0111011}}, {4{7'b1010011}}};
				2'b01: rd_address_all <= {{28{7'b0111011+7'd4}}, {4{7'b1010011+7'd4}}};
				2'b10: rd_address_all <= {{28{7'b0111011+7'd24}}, {4{7'b1010011-7'd72}}};
				2'b11: rd_address_all <= {{28{7'b0111011+7'd28}}, {4{7'b1010011-7'd68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{28{7'b0111100}}, {4{7'b1010100}}};
				2'b01: rd_address_all <= {{28{7'b0111100+7'd4}}, {4{7'b1010100+7'd4}}};
				2'b10: rd_address_all <= {{28{7'b0111100+7'd24}}, {4{7'b1010100-7'd72}}};
				2'b11: rd_address_all <= {{28{7'b0111100+7'd28}}, {4{7'b1010100-7'd68}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		21: begin
		 	rd8R_en <= 0;
			shift_value <= 5;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{27{sub_area3_row_count+7'd55}}, {5{sub_area3_row_count+7'd79}}};
				2'b01: rd_address_all <= {{27{sub_area3_row_count+7'd59}}, {5{sub_area3_row_count+7'd83}}};
				2'b10: rd_address_all <= {{27{sub_area3_row_count+7'd79}}, {5{sub_area3_row_count+7'd7}}};
				2'b11: rd_address_all <= {{27{sub_area3_row_count+7'd83}}, {5{sub_area3_row_count+7'd11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{27{7'b0111011}}, {5{7'b1010011}}};
				2'b01: rd_address_all <= {{27{7'b0111011+7'd4}}, {5{7'b1010011+7'd4}}};
				2'b10: rd_address_all <= {{27{7'b0111011+7'd24}}, {5{7'b1010011-7'd72}}};
				2'b11: rd_address_all <= {{27{7'b0111011+7'd28}}, {5{7'b1010011-7'd68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{27{7'b0111100}}, {5{7'b1010100}}};
				2'b01: rd_address_all <= {{27{7'b0111100+7'd4}}, {5{7'b1010100+7'd4}}};
				2'b10: rd_address_all <= {{27{7'b0111100+7'd24}}, {5{7'b1010100-7'd72}}};
				2'b11: rd_address_all <= {{27{7'b0111100+7'd28}}, {5{7'b1010100-7'd68}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		22: begin
		 	rd8R_en <= 0;
			shift_value <= 6;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{26{sub_area3_row_count+7'd55}}, {6{sub_area3_row_count+7'd79}}};
				2'b01: rd_address_all <= {{26{sub_area3_row_count+7'd59}}, {6{sub_area3_row_count+7'd83}}};
				2'b10: rd_address_all <= {{26{sub_area3_row_count+7'd79}}, {6{sub_area3_row_count+7'd7}}};
				2'b11: rd_address_all <= {{26{sub_area3_row_count+7'd83}}, {6{sub_area3_row_count+7'd11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{26{7'b0111011}}, {6{7'b1010011}}};
				2'b01: rd_address_all <= {{26{7'b0111011+7'd4}}, {6{7'b1010011+7'd4}}};
				2'b10: rd_address_all <= {{26{7'b0111011+7'd24}}, {6{7'b1010011-7'd72}}};
				2'b11: rd_address_all <= {{26{7'b0111011+7'd28}}, {6{7'b1010011-7'd68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{26{7'b0111100}}, {6{7'b1010100}}};
				2'b01: rd_address_all <= {{26{7'b0111100+7'd4}}, {6{7'b1010100+7'd4}}};
				2'b10: rd_address_all <= {{26{7'b0111100+7'd24}}, {6{7'b1010100-7'd72}}};
				2'b11: rd_address_all <= {{26{7'b0111100+7'd28}}, {6{7'b1010100-7'd68}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		23: begin
		 	rd8R_en <= 0;
			shift_value <= 7;
			if (sub_area3_row_count < 4) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= 4'b0;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{25{sub_area3_row_count+7'd55}}, {7{sub_area3_row_count+7'd79}}};
				2'b01: rd_address_all <= {{25{sub_area3_row_count+7'd59}}, {7{sub_area3_row_count+7'd83}}};
				2'b10: rd_address_all <= {{25{sub_area3_row_count+7'd79}}, {7{sub_area3_row_count+7'd7}}};
				2'b11: rd_address_all <= {{25{sub_area3_row_count+7'd83}}, {7{sub_area3_row_count+7'd11}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 12) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd3;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{25{7'b0111011}}, {7{7'b1010011}}};
				2'b01: rd_address_all <= {{25{7'b0111011+7'd4}}, {7{7'b1010011+7'd4}}};
				2'b10: rd_address_all <= {{25{7'b0111011+7'd24}}, {7{7'b1010011-7'd72}}};
				2'b11: rd_address_all <= {{25{7'b0111011+7'd28}}, {7{7'b1010011-7'd68}}};
				default: rd_address_all <= 0;
				endcase
			end
			else if (sub_area3_row_count < 20) begin
				sub_area3_row_count <= sub_area3_row_count + 7'd1;
				column_finish <= 1'b0;
				rdR_sel <= sub_area3_row_count[3:0] - 4'd11;
				case (CB1or2or3or4)
				2'b00: rd_address_all <= {{25{7'b0111100}}, {7{7'b1010100}}};
				2'b01: rd_address_all <= {{25{7'b0111100+7'd4}}, {7{7'b1010100+7'd4}}};
				2'b10: rd_address_all <= {{25{7'b0111100+7'd24}}, {7{7'b1010100-7'd72}}};
				2'b11: rd_address_all <= {{25{7'b0111100+7'd28}}, {7{7'b1010100-7'd68}}};
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
					search_column_count <= search_column_count + 1'd1;
					column_finish <= 1'b1;
				end
				default: CB1or2or3or4 <= 2'b00;
				endcase
			end
		end
		default: begin column_finish <= 1'b0; end
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

//write out
always@(posedge clk)
begin
	case(write_current_state)
	W_IDLE: begin
		Bank_sel <= 32'b0;
		write_address_all <= 224'b0;
		pre_count <= 10'b0;
		pre_line_count <= 7'b0;
	end
	W_PRE96: begin
		pre_count <= pre_count + 1'd1;
		if (pre_count < 24) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			//pre_line_count <= pre_count;
			write_address_all <= { 32{pre_count[6:0]} };
		end
		else if (pre_count >= 24 && pre_count < 47) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 10'd23;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 47) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 48 && pre_count < 71) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 10'd47;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 71) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 72 && pre_count < 95) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 10'd71;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 95) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 96 && pre_count < 119) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 10'd95;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 119) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 120 && pre_count < 143) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 10'd119;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 143) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 144 && pre_count < 167) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 10'd143;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 167) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 168 && pre_count < 191) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 10'd167;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 191) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end


		else if (pre_count >= 192 && pre_count < 215) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= pre_count - 10'd167;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 215) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 216 && pre_count < 239) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 10'd191;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 239) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 240 && pre_count < 263) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 10'd215;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 263) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 264 && pre_count < 287) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 10'd239;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 287) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 288 && pre_count < 311) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 10'd263;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 311) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 312 && pre_count < 335) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 10'd287;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 335) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 336 && pre_count < 359) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 10'd311;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 359) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 360 && pre_count < 383) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 10'd335;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 383) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end


		else if (pre_count >= 384 && pre_count < 407) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= pre_count - 10'd335;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 407) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 408 && pre_count < 431) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 10'd359;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 431) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 432 && pre_count < 455) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 10'd383;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 455) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 456 && pre_count < 479) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 10'd407;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 479) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 480 && pre_count < 503) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 10'd431;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 503) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 504 && pre_count < 527) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 10'd455;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 527) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 528 && pre_count < 551) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 10'd479;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 551) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 552 && pre_count < 575) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 10'd503;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 575) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end


		else if (pre_count >= 576 && pre_count < 599) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= pre_count - 10'd503;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 599) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 600 && pre_count < 623) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 10'd527;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 623) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 624 && pre_count < 647) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 10'd551;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 647) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 648 && pre_count < 671) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 10'd575;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 671) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 672 && pre_count < 695) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 10'd599;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 695) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 696 && pre_count < 719) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 10'd623;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 719) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 720 && pre_count < 743) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 10'd647;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 743) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 744 && pre_count < 767) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 10'd671;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 767) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
	end
	W_UP24: begin
		pre_count <= pre_count + 1'd1;
		if (pre_count < 24) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			//pre_line_count <= pre_count;
			write_address_all <= { 32{pre_count[6:0]} };
		end
		else if (pre_count >= 24 && pre_count < 47) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 10'd23;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 47) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 48 && pre_count < 71) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 10'd47;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 71) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 72 && pre_count < 95) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 10'd71;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 95) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 96 && pre_count < 119) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 10'd95;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 119) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 120 && pre_count < 143) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 10'd119;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 143) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 144 && pre_count < 167) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 10'd143;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 167) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 168 && pre_count < 191) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 10'd167;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 191) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
	end
	W_RELAX: begin
		Bank_sel <= 32'b0;
		write_address_all <= 224'b0;
		pre_count <= 192;
		pre_line_count <= 7'b0;
	end
	W_UPm24: begin
		pre_count <= pre_count + 1'd1;
		if (pre_count >= 192 && pre_count < 215) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= pre_count - 10'd167;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 215) begin
			Bank_sel <= 32'b00000000000000000000000000001111;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 216 && pre_count < 239) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= pre_count - 10'd191;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 239) begin
			Bank_sel <= 32'b00000000000000000000000011110000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 240 && pre_count < 263) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= pre_count - 10'd215;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 263) begin
			Bank_sel <= 32'b00000000000000000000111100000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 264 && pre_count < 287) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= pre_count - 10'd239;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 287) begin
			Bank_sel <= 32'b00000000000000001111000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 288 && pre_count < 311) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= pre_count - 10'd263;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 311) begin
			Bank_sel <= 32'b00000000000011110000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 312 && pre_count < 335) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= pre_count - 10'd287;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 335) begin
			Bank_sel <= 32'b00000000111100000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 336 && pre_count < 359) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= pre_count - 10'd311;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 359) begin
			Bank_sel <= 32'b00001111000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count >= 360 && pre_count < 383) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= pre_count - 10'd335;
			write_address_all <= { 32{pre_line_count} };
		end
		else if (pre_count == 383) begin
			Bank_sel <= 32'b11110000000000000000000000000000;
			pre_line_count <= 7'd0;
			write_address_all <= { 32{pre_line_count} };
		end
	end
	default:begin
		Bank_sel <= 32'b0;
		write_address_all <= 224'b0;
		pre_count <= 10'b0;
		pre_line_count <= 7'b0;
	end
	endcase
end

//read update
always @(current_state or begin_prepare or pre96_complete or column_finish)
begin
	case(current_state)
	IDLE: if (begin_prepare && pre96_complete)
		next_state <= SUB_AERA1;
		//search_column_count <= 1;
		else
		next_state <= IDLE;
	SUB_AERA1: 
		if (column_finish) begin
			if (search_column_count == 8) next_state <= SUB_AERA2;
			else if (search_column_count == 0) next_state <= IDLE;
			else next_state <= SUB_AERA1;
		end
		else begin
			next_state <= SUB_AERA1;
		end
	SUB_AERA2:
		if (column_finish) begin
			if (search_column_count == 9 | search_column_count == 17)
				next_state <= SUB_AERA3;
			else 
				next_state <= SUB_AERA1;
		end
		else begin
			next_state <= SUB_AERA2;
		end
	SUB_AERA3:
		if (column_finish) begin
			if (search_column_count == 16 | search_column_count == 24)
				next_state <= SUB_AERA2;
			else 
				next_state <= SUB_AERA3;
		end
		else begin
			next_state <= SUB_AERA3;
		end
	default: next_state <= IDLE;
	endcase
end

//write update
always @(write_current_state or begin_prepare or pre_count)
begin
	case(write_current_state)
	W_IDLE: if (begin_prepare) write_next_state <= W_PRE96;
			else if (clean_up24 == 1'b1) write_next_state <= W_UP24;
			else write_next_state <= W_IDLE;
	W_PRE96:if (pre_count < 768) write_next_state <= W_PRE96;
			else write_next_state <= W_IDLE;
	W_UP24: if (pre_count < 192) write_next_state <= W_UP24;
			else write_next_state <= W_RELAX;
	W_RELAX:if (clean_upm24 == 1'b1) write_next_state <= W_UPm24;
			else write_next_state <= W_RELAX;
	W_UPm24:if (pre_count < 384) write_next_state <= W_UPm24;
			else write_next_state <= W_IDLE;
	default:
	endcase
end

endmodule
