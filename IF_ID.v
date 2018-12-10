`include "mycpu.h"

module IF_ID(
	input             clk,
	input             rst,
	input             IF_stall,
	input             ID_stall,
	input             IF_invalid,

	input      [31:0] IF_out_PC,
	input             IF_AdEF_exception,
	input      [31:0] IF_bad_inst,

	output     [31:0] ID_in_PC,
	output            ID_AdEF_exception,
	output     [31:0] ID_bad_inst
);

	reg [31:0] reg_PC;
	reg        reg_AdEF_exception;
	reg [31:0] reg_bad_inst;

	always @(posedge clk) begin
		if (rst | IF_invalid | (IF_stall & ~ID_stall)) begin
			reg_PC <= 32'hbfc00000;
			reg_AdEF_exception <= 1'b0;
			reg_bad_inst <= 32'hbfc00000;
		end else if (ID_stall) begin
		end else begin
			reg_PC <= IF_out_PC;
			reg_AdEF_exception <= IF_AdEF_exception;
			reg_bad_inst <= IF_bad_inst;
		end
	end

	assign ID_in_PC = reg_PC;
	assign ID_AdEF_exception = reg_AdEF_exception;
	assign ID_bad_inst = reg_bad_inst;

endmodule