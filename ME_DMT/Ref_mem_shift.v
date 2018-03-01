module Ref_mem_shift(
input [2047:0] ref_input,
input [4:0] shift_value, //左移的mem数量
output wire [2047:0] ref_output
);

assign ref_output = (ref_input>>shift_value)|(ref_input<<(2048-shift_value));

endmodule