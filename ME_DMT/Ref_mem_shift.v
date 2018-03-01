module Ref_mem_shift(
input [2047:0] ref_input,
input [4:0] shift_value, //循环右移的mem数量（把低位的mem移到最高位）
output wire [2047:0] ref_output
);

assign ref_output = (ref_input>>shift_value*256)|(ref_input<<(2048-shift_value*256));

endmodule