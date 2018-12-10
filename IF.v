`include "mycpu.h"

module IF(
	input         clk,
	input         rst,
	input         IF_stall,

	input  [31:0] next_PC,

	output [31:0] IF_in_PC,
	output        IF_AdEF_exception,
	output [31:0] IF_bad_inst
);
	reg    [31:0] reg_PC;
	always @(posedge clk) begin
		if (rst) begin
			reg_PC <= 32'hbfc00000;
		end else if (IF_stall) begin
		end else begin
			reg_PC <= next_PC;
		end
	end
	assign IF_in_PC = {reg_PC[31:2], 2'b00};
	assign IF_AdEF_exception = reg_PC[1:0] != 2'b00;
	assign IF_bad_inst = reg_PC;

endmodule