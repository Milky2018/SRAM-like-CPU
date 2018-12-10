`timescale 10 ns / 1 ns

`include "mycpu.h"

module EX_ALU(
	input  [31:0] A,
	input  [31:0] B,
	input  [13:0] OHC_ALUop,
	output [31:0] result,

	output        overflow_exception
);

	wire op_add  = OHC_ALUop[`ALUOP_ADD];
	wire op_sub  = OHC_ALUop[`ALUOP_SUB];
	wire op_and  = OHC_ALUop[`ALUOP_AND];
	wire op_or   = OHC_ALUop[`ALUOP_OR];
	wire op_xor  = OHC_ALUop[`ALUOP_XOR];
	wire op_nor  = OHC_ALUop[`ALUOP_NOR];
	wire op_sll  = OHC_ALUop[`ALUOP_SLL];
	wire op_slt  = OHC_ALUop[`ALUOP_SLT];
	wire op_sltu = OHC_ALUop[`ALUOP_SLTU];
	wire op_srl  = OHC_ALUop[`ALUOP_SRL];
	wire op_sra  = OHC_ALUop[`ALUOP_SRA];
	wire op_lui  = OHC_ALUop[`ALUOP_LUI];
	wire op_addu = OHC_ALUop[`ALUOP_ADDU];
	wire op_subu = OHC_ALUop[`ALUOP_SUBU];

	wire signed [31:0] signedB;
	assign signedB = B;

	wire [31:0] add_result = A + B;
	wire [31:0] sub_result = A + ~B + 32'd1;
	wire [31:0] and_result = A&B;
	wire [31:0] or_result  = A|B;
	wire [31:0] xor_result = A^B;
	wire [31:0] nor_result = ~or_result;
	wire [31:0] sll_result = B << A[4:0];
	wire [31:0] slt_result = {31'b0, (A[31]&sub_result[31]) | (~B[31]&sub_result[31]) | (A[31]&~B[31]&~sub_result[31])};
	wire [31:0] sltu_result= A < B;
	wire [31:0] srl_result = B >> A[4:0];
	wire [31:0] sra_result = signedB >>> A[4:0];
	wire [31:0] lui_result = {B[15:0], 16'b0};
	wire [31:0] addu_result= A + B;
	wire [31:0] subu_result= A + ~B + 32'd1;

	assign result = ({32{op_add}} & add_result) |
	                ({32{op_sub}} & sub_result) | 
					({32{op_and}} & and_result) | 
					({32{op_or}}  & or_result)  | 
					({32{op_xor}} & xor_result) | 
					({32{op_nor}} & nor_result) | 
					({32{op_sll}} & sll_result) | 
					({32{op_slt}} & slt_result) | 
					({32{op_sltu}}& sltu_result)| 
					({32{op_srl}} & srl_result) | 
					({32{op_sra}} & sra_result) | 
					({32{op_lui}} & lui_result) |
					({32{op_addu}}& addu_result)|
					({32{op_subu}}& subu_result);

	assign overflow_exception = (op_add & ((A[31] & B[31] & ~add_result[31]) | (~A[31] & ~B[31] & add_result[31]))) |
								(op_sub & ((A[31] & ~B[31] & ~sub_result[31]) | (~A[31] & B[31] & sub_result[31])));

endmodule