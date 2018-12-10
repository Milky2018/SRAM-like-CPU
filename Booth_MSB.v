module Booth_MSB(
	input [31:0] mulcand,
	input msb,
	input sign,

	output [31:0] pp
);

	assign pp = ((sign == 0)&&(msb == 1))? mulcand : 32'b0;
    
endmodule
