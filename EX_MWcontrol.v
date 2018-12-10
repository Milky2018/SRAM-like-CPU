`include "mycpu.h"

module EX_MWcontrol(
	input  [31:0] rt_data,
	input  [31:0] alu_result,

	input  [4 :0] data_dtl,

	output [31:0] data_wdata,
	output [31:0] data_addr,
	output [3 :0] data_strb,

	input         in_en,
	output        out_en,

	output        AdES_exception,

	input         MEM_exception
);

	wire [1:0] ea = alu_result[1:0];
	assign data_addr = alu_result;

	wire [31:0] word_data = rt_data;
	wire [31:0] swl_data = ({32{ea == 2'b00}} & {24'd0, word_data[31:24]}) |
						   ({32{ea == 2'b01}} & {16'd0, word_data[31:16]}) |
						   ({32{ea == 2'b10}} & { 8'd0, word_data[31: 8]}) |
						   ({32{ea == 2'b11}} &         word_data[31: 0] );
	wire [31:0] swr_data = ({32{ea == 2'b00}} &  word_data[31:0]        ) |
					       ({32{ea == 2'b01}} & {word_data[23:0],  8'd0}) |
					       ({32{ea == 2'b10}} & {word_data[15:0], 16'd0}) |
					       ({32{ea == 2'b11}} & {word_data[7 :0], 24'd0});
	wire [31:0] sb_data  = ({32{ea == 2'b00}} & {24'd0, word_data[7 :0]       }) |
					       ({32{ea == 2'b01}} & {16'd0, word_data[7 :0], 8'd0 }) |
					       ({32{ea == 2'b10}} & { 8'd0, word_data[7 :0], 16'd0}) |
					       ({32{ea == 2'b11}} & {       word_data[7 :0], 24'd0});
	wire [31:0] sh_data  = ({32{ea == 2'b00}} & {16'd0, word_data[15:0]       }) |
						   ({32{ea == 2'b10}} & {       word_data[15:0], 16'd0});

	assign data_strb = ({4{data_dtl[`MEM_dtl_word]               }} & 4'b1111) |
					   ({4{data_dtl[`MEM_dtl_sb]  & (ea == 2'b00)}} & 4'b0001) |
					   ({4{data_dtl[`MEM_dtl_sb]  & (ea == 2'b01)}} & 4'b0010) |
					   ({4{data_dtl[`MEM_dtl_sb]  & (ea == 2'b10)}} & 4'b0100) |
					   ({4{data_dtl[`MEM_dtl_sb]  & (ea == 2'b11)}} & 4'b1000) |
					   ({4{data_dtl[`MEM_dtl_sh]  & (ea == 2'b00)}} & 4'b0011) |
					   ({4{data_dtl[`MEM_dtl_sh]  & (ea == 2'b10)}} & 4'b1100) |
				  	   ({4{data_dtl[`MEM_dtl_swl] & (ea == 2'b00)}} & 4'b0001) |
					   ({4{data_dtl[`MEM_dtl_swl] & (ea == 2'b01)}} & 4'b0011) |
					   ({4{data_dtl[`MEM_dtl_swl] & (ea == 2'b10)}} & 4'b0111) |
					   ({4{data_dtl[`MEM_dtl_swl] & (ea == 2'b11)}} & 4'b1111) |
					   ({4{data_dtl[`MEM_dtl_swr] & (ea == 2'b00)}} & 4'b1111) |
					   ({4{data_dtl[`MEM_dtl_swr] & (ea == 2'b01)}} & 4'b1110) |
					   ({4{data_dtl[`MEM_dtl_swr] & (ea == 2'b10)}} & 4'b1100) |
					   ({4{data_dtl[`MEM_dtl_swr] & (ea == 2'b11)}} & 4'b1000);

	assign data_wdata = ({32{data_dtl[`MEM_dtl_word]}} & word_data) |
				 	    ({32{data_dtl[`MEM_dtl_swl ]}} &  swl_data) |
					    ({32{data_dtl[`MEM_dtl_swr ]}} &  swr_data) |
					    ({32{data_dtl[`MEM_dtl_sb  ]}} &   sb_data) |
					    ({32{data_dtl[`MEM_dtl_sh  ]}} &   sh_data);

	assign AdES_exception = (data_dtl[`MEM_dtl_word] & (ea != 2'b00)) |
						    (data_dtl[`MEM_dtl_sh] & (ea[0] == 1'b1));

	assign out_en = in_en & ~MEM_exception & ~AdES_exception;

endmodule