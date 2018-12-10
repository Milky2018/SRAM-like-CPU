`include "mycpu.h"

module MEM_MRcontrol(
	input  [31:0] data_rdata,
	input         data_en,
	input  [6 :0] RFdtl,
	input  [1 :0] ea,

	output [31:0] mem_data,
	output [3 :0] RF_strb,

	output        AdEL_exception
);

	wire [31:0] word_data = data_rdata;
	wire [31:0] lwl_data = ({32{ea == 2'b00}} & {word_data[7 :0], 24'd0}) |
						   ({32{ea == 2'b01}} & {word_data[15:0], 16'd0}) |
						   ({32{ea == 2'b10}} & {word_data[23:0],  8'd0}) |
						   ({32{ea == 2'b11}} &  word_data[31:0]        );
	wire [31:0] lwr_data = ({32{ea == 2'b00}} &         word_data[31: 0] ) |
					       ({32{ea == 2'b01}} & { 8'd0, word_data[31: 8]}) |
					       ({32{ea == 2'b10}} & {16'd0, word_data[31:16]}) |
					       ({32{ea == 2'b11}} & {24'd0, word_data[31:24]});
	wire [31:0] lb_data  = ({32{ea == 2'b00}} & {{24{word_data[ 7]}}, word_data[7 : 0]}) |
					       ({32{ea == 2'b01}} & {{24{word_data[15]}}, word_data[15: 8]}) |
					       ({32{ea == 2'b10}} & {{24{word_data[23]}}, word_data[23:16]}) |
					       ({32{ea == 2'b11}} & {{24{word_data[31]}}, word_data[31:24]});
	wire [31:0] lbu_data = ({32{ea == 2'b00}} & {24'd0, word_data[7 : 0]}) |
					       ({32{ea == 2'b01}} & {24'd0, word_data[15: 8]}) |
					       ({32{ea == 2'b10}} & {24'd0, word_data[23:16]}) |
						   ({32{ea == 2'b11}} & {24'd0, word_data[31:24]});
	wire [31:0] lh_data  = ({32{ea == 2'b00}} & {{16{word_data[15]}}, word_data[15: 0]}) |
						   ({32{ea == 2'b10}} & {{16{word_data[31]}}, word_data[31:16]});
	wire [31:0] lhu_data = ({32{ea == 2'b00}} & {16'd0, word_data[15: 0]}) |
						   ({32{ea == 2'b10}} & {16'd0, word_data[31:16]});

	assign RF_strb = ({4{
						 RFdtl[`RF_dtl_word] | RFdtl[`RF_dtl_lb] | 
	                     RFdtl[`RF_dtl_lbu ] | RFdtl[`RF_dtl_lh] | 
						 RFdtl[`RF_dtl_lhu ]
					 }} & 4'b1111)                                       |
					 ({4{RFdtl[`RF_dtl_lwl] & (ea == 2'b00)}} & 4'b1000) |
					 ({4{RFdtl[`RF_dtl_lwl] & (ea == 2'b01)}} & 4'b1100) |
					 ({4{RFdtl[`RF_dtl_lwl] & (ea == 2'b10)}} & 4'b1110) |
					 ({4{RFdtl[`RF_dtl_lwl] & (ea == 2'b11)}} & 4'b1111) |
					 ({4{RFdtl[`RF_dtl_lwr] & (ea == 2'b00)}} & 4'b1111) |
					 ({4{RFdtl[`RF_dtl_lwr] & (ea == 2'b01)}} & 4'b0111) |
					 ({4{RFdtl[`RF_dtl_lwr] & (ea == 2'b10)}} & 4'b0011) |
					 ({4{RFdtl[`RF_dtl_lwr] & (ea == 2'b11)}} & 4'b0001);

	assign mem_data = ({32{RFdtl[`RF_dtl_word]}} & word_data) |
					  ({32{RFdtl[`RF_dtl_lwl ]}} &  lwl_data) |
					  ({32{RFdtl[`RF_dtl_lwr ]}} &  lwr_data) |
					  ({32{RFdtl[`RF_dtl_lb  ]}} &   lb_data) |
					  ({32{RFdtl[`RF_dtl_lbu ]}} &  lbu_data) |
					  ({32{RFdtl[`RF_dtl_lh  ]}} &   lh_data) |
					  ({32{RFdtl[`RF_dtl_lhu ]}} &  lhu_data);

	assign AdEL_exception = (data_en & RFdtl[`RF_dtl_word] & (ea != 2'b00)) |
							(RFdtl[`RF_dtl_lh] & (ea[0] == 1'b1)) | 
							(RFdtl[`RF_dtl_lhu] & (ea[0] == 1'b1));

endmodule