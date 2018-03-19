module PE_array_ctrl(
	input clk,
	input rst_n,
	input begin_prepare,
	output reg in_curr_enable,
	output reg CB_select,
	output reg [1:0] abs_Control,
	output reg change_ref,
	output reg ref_input_control
);

parameter [2:0]
IDLE = 3'b000, 
DATA_PRE = 3'b001,
SUB_AERA1 = 3'b010,
SUB_AERA2 = 3'b011,
SUB_AERA3 = 3'b100;

reg [3:0] current_state, next_state;
reg [5:0] pre_count;
reg [4:0] search_column_count;
reg [6:0] sub_area1_row_count;
reg [6:0] sub_area2_row_count;
reg [6:0] sub_area3_row_count;
reg CB12or34; //标志位，记录在降采样区间当前计算的是子块12还是子块34

always@(posedge clk or negedge rst_n)
begin
if(!rst_n)
	begin
		current_state <= IDLE;
		in_curr_enable <= 1'b0;
		CB_select <= 1'b1; //为1时是子块12
		abs_Control <= 2'b0;
		change_ref <= 1'b0;
		ref_input_control <= 1'b0;
		search_column_count <= 5'b0;
		sub_area1_row_count <= 7'b0;
		sub_area2_row_count <= 7'b0;
		sub_area3_row_count <= 7'b0;
		pre_count <= 6'b0;
		CB12or34 <= 1'b0;

	end
else
	begin
		current_state <= next_state;
	end
end

always @(posedge clk)
begin
	case(current_state)
	IDLE: begin
		in_curr_enable <= 1'b0;
		CB_select <= 1'b1;
		abs_Control <= 2'b0;
		change_ref <= 1'b0;
		ref_input_control <= 1'b0;
		search_column_count <= 5'b0;
		sub_area1_row_count <= 7'b0;
		sub_area2_row_count <= 7'b0;
		sub_area3_row_count <= 7'b0;
		pre_count <= 6'b0;
		CB12or34 <= 1'b0;

	end
	DATA_PRE: begin
		pre_count <= pre_count + 1'd1;
		in_curr_enable <= 1;
		if (pre_count < 32) begin
			CB_select <= 1;
		end 
		else begin
			CB_select <= 0;
		end
	end
	SUB_AERA1: begin
		in_curr_enable <= 0;
		ref_input_control <= 1;
		if (CB12or34 == 0) begin
			CB_select <= 1;
			if (sub_area1_row_count < 8) begin
				abs_Control <= 0;
				change_ref <= 1;
			end
			else if (sub_area1_row_count < 34) begin
				if (sub_area1_row_count % 2 == 0) begin
					abs_Control <= 1;
					change_ref <= 0;
				end
				else begin
					abs_Control <= 0;
					change_ref <= 1;
				end
			end
			else begin
				abs_Control <= 1;
				change_ref <= 1;
			end
		end
		else begin
			CB_select <= 0;
			if (sub_area1_row_count < 8) begin
				abs_Control <= 2;
				change_ref <= 1;
			end
			else if (sub_area1_row_count < 34) begin
				if (sub_area1_row_count % 2 == 0) begin
					abs_Control <= 3;
					change_ref <= 0;
				end
				else begin
					abs_Control <= 2;
					change_ref <= 1;
				end
			end
			else begin
				abs_Control <= 3;
				change_ref <= 1;
			end
		end
		if (sub_area1_row_count == 37 && CB12or34 == 1'b0) begin
			CB12or34 <= 1'b0;
			sub_area1_row_count <= 0;
		end
		if (sub_area1_row_count == 37 && CB12or34 == 1'b1) begin
			CB12or34 <= 1'b1;	
			sub_area1_row_count <= 0;
			search_column_count <= search_column_count + 1;
		end
	end
	endcase
end
// 状态转换
always @(current_state or begin_prepare or pre_count or search_column_count)
begin
	case(current_state)
	IDLE: if (begin_prepare)
		next_state = DATA_PRE;
		else
		next_state = IDLE;
	// 准备当前帧数据，共需64个周期 32*32*4 / 32*2 = 64
	DATA_PRE: if (pre_count < 64)
		next_state = DATA_PRE;
		else begin
		next_state = SUB_AERA1;
		search_column_count = 1;
		end
	SUB_AERA1: if (search_column_count == 7)
		next_state = SUB_AERA2;
		else if (search_column_count == 31)
		next_state = IDLE;	
		else 
		next_state = SUB_AERA1;
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