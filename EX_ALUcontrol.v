`include "mycpu.h"

module EX_ALUcontrol(
	input  [3 :0] ALUsrc,

	input  [31:0] rs_data,
	input  [31:0] rt_data,
	input  [15:0] imm,
	input  [4 :0] shamt,

	output [31:0] A,
	output [31:0] B
);
	wire [31:0] unsignedimm   = {16'd0, imm};
	wire [31:0] signedimm     = {{16{imm[15]}}, imm};
	wire [31:0] unsignedshamt = {27'd0, shamt};

	assign A = ({32{ALUsrc[`ALU_from_rs_rt]}}        & rs_data) |
			   ({32{ALUsrc[`ALU_from_rs_imm]}}       & rs_data) |
			   ({32{ALUsrc[`ALU_from_rs_signedimm]}} & rs_data) |
			   ({32{ALUsrc[`ALU_from_sa_rt]}}        & unsignedshamt);
	assign B = ({32{ALUsrc[`ALU_from_rs_rt]}}        & rt_data) |
			   ({32{ALUsrc[`ALU_from_sa_rt]}}        & rt_data) |
			   ({32{ALUsrc[`ALU_from_rs_imm]}}       & unsignedimm) |
			   ({32{ALUsrc[`ALU_from_rs_signedimm]}} & signedimm);

endmodule