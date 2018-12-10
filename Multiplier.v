module Multiplier(
	input clk,
	input rst,
	input sign,
	input [31:0] a,
	input [31:0] b,

	output [63:0] result
);

FastMultiplier u_FastMultiplier(
	.a(a), 
	.b(b), 
	.sign(sign), 
	.product(result)
);

endmodule