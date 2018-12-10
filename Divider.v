module Divider(
	input clk,
	input rst,
	input div,
	input sign, 
	input [31:0] x,
	input [31:0] y, 
	output [63:0] result,
	output complete
);

my_div u_my_div(
	.clk(clk),
	.rst(rst),
   
	.sign(sign),
	.x(x),
	.y(y),
	.start(div),
	.cancel(1'b0),
 
	.result(result),
	.complete(complete)
);

endmodule