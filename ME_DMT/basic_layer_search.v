module Basic_layer_search(
	input clk,
	input rst_n,
	input [255:0] ref_input,
	input [511:0] current_64pixels
);

wire [31:0] Bank_sel;
wire [6:0] rd_address;
wire [7*32-1:0] write_address_all;
wire rd8R_en;
wire [3:0] rdR_sel;
wire [2047:0] ref_8R_32;
wire in_curr_enable;
wire CB_select;
wire [1:0] abs_Control;
wire change_ref;
wire [8191:0] abs_outs;
wire ref_input_control;

Ref_mem_ctrl ref_mem_ctrl(
	//input 待添加来自global的控制信号
	.clk(clk),
	.rst_n(rst_n),
	//output
	.Bank_sel(Bank_sel),
	.rd_address(rd_address),
	.write_address_all(write_address_all),
	.rd8R_en(rd8R_en),
	.rdR_sel(rdR_sel)
);

Ref_mem ref_mem(
	//input
	.clk(clk), 
	.rst_n(rst_n), 
	.ref_input(ref_input), 
	.Bank_sel(Bank_sel), 
	.rd_address(rd_address),
	.write_address_all(write_address_all), 
	.rd8R_en(rd8R_en), 
	.rdR_sel(rdR_sel),
	//output
	.ref_8R_32(ref_8R_32), 
	.Oda8R_va(), 
	.da1R_va()
);

PE_array_ctrl pe_array_ctrl(
	//input
	.clk(clk),
	.rst_n(rst_n),
	.begin_prepare(begin_prepare), // 待添加的来自global的开始信号
	//output
	.in_curr_enable(in_curr_enable),
	.CB_select(CB_select),
	.abs_Control(abs_Control),
	.change_ref(change_ref),
	.ref_input_control(ref_input_control)
);

PE_array pe_array(
	//input
	.clk(clk),
	.rst_n(rst_n), 
	.current_64pixels(current_64pixels), 
	.in_curr_enable(in_curr_enable),
	.CB_select(CB_select), 
	.abs_Control(abs_Control), 
	.ref_8R_32(ref_8R_32), 
	.change_ref(change_ref),
	.ref_input_control(ref_input_control), 
	//output
	.abs_outs(abs_outs)
);

SAD_Tree SAD_tree(
	//input
	.clk(clk),
	.rst_n(rst_n),
	.abs_outs(abs_outs),
	//output
	.SAD4x8(SAD4x8),
	.SAD8x4(SAD8x4),
	.SAD8x8(SAD8x8),
	.SAD8x16(SAD8x16),
	.SAD16x8(SAD16x8),
	.SAD16x16(SAD16x16),
	.SAD32x32(SAD32x32)
);

SAD_comp SAD_comp(
	//input
	.clk(clk),
	.rst_n(rst_n),
	.SAD4x8(SAD4x8),
	.SAD8x4(SAD8x4),
	.SAD8x8(SAD8x8),
	.SAD8x16(SAD8x16),
	.SAD16x8(SAD16x8),
	.SAD16x16(SAD16x16),
	.SAD32x32(SAD32x32),
	//output
	.min_SAD4x8(min_SAD4x8),
	.min_SAD8x4(min_SAD8x4),
	.min_SAD8x8(min_SAD8x8),
	.min_SAD8x16(min_SAD8x16),
	.min_SAD16x8(min_SAD16x8),
	.min_SAD16x16(min_SAD16x16),
	.min_SAD32x32(min_SAD32x32)
);

endmodule