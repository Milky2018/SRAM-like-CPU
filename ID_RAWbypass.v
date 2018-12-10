`include "mycpu.h"

module ID_RAWbypass(
	input  [31:0] ID_instruction,
	input  [31:0] EX_instruction,
	input  [4 :0] MEM_RF_waddr,
	input  [4 :0] WB_RF_waddr,

	input  [4 :0] EX_RFsrc,

	input  [2 :0] EX_RFdst,

	input  [31:0] rs_data,
	input  [31:0] rt_data,

	input  [31:0] EX_ALUresult,
	input  [31:0] EX_MD_data,
	input  [31:0] EX_PC,
	input  [31:0] EX_cp0_data,
	input  [31:0] MEM_RF_wdata,
	input  [31:0] WB_RF_wdata,

	output [31:0] ID_out_RF_rs_data,
	output [31:0] ID_out_RF_rt_data,
	output        ID_bypass_stall
);

	wire [4:0] EX_RF_waddr, EX_rt, EX_rd, EX_ra, ID_rs, ID_rt;
	wire [31:0] EX_RF_wdata;

	wire [31:0] EX_PCplus8 = EX_PC + 32'd8;
	assign EX_RF_wdata = ({32{EX_RFsrc[`RF_from_alu]}}     & EX_ALUresult) |
					     ({32{EX_RFsrc[`RF_from_PCplus8]}} &   EX_PCplus8) |
					     ({32{EX_RFsrc[`RF_from_MD]}}      &   EX_MD_data) |
						 ({32{EX_RFsrc[`RF_from_CP0]}}     &  EX_cp0_data);

	assign EX_rt = EX_instruction[20:16];
	assign EX_rd = EX_instruction[15:11];
	assign EX_ra = 5'd31;
	assign EX_RF_waddr = ({5{EX_RFdst[`RF_in_rd]}} & EX_rd) |
					     ({5{EX_RFdst[`RF_in_rt]}} & EX_rt) |
					     ({5{EX_RFdst[`RF_in_ra]}} & EX_ra);
	assign ID_rs = ID_instruction[25:21];
	assign ID_rt = ID_instruction[20:16];

	assign ID_bypass_stall = (EX_instruction[31:29] == 3'b100) && 
							 ((EX_RF_waddr == ID_rs) || (EX_RF_waddr == ID_rt));

	assign ID_out_RF_rs_data = ID_rs == 5'd0        ? 32'd0        : 
							   ID_rs == EX_RF_waddr ? EX_RF_wdata  :
							   ID_rs == MEM_RF_waddr? MEM_RF_wdata :
							   ID_rs == WB_RF_waddr ? WB_RF_wdata  :
							   rs_data;
	assign ID_out_RF_rt_data = ID_rt == 5'd0        ? 32'd0        : 
							   ID_rt == EX_RF_waddr ? EX_RF_wdata  :
							   ID_rt == MEM_RF_waddr? MEM_RF_wdata :
							   ID_rt == WB_RF_waddr ? WB_RF_wdata  :
							   rt_data;
	
endmodule