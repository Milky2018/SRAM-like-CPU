`include "mycpu.h"

module MEM_RFcontrol(
	input  [2 :0] RFdst,
	input  [4 :0] RFsrc,

	input  [31:0] mem_data,
	input  [31:0] alu_result,
	input  [31:0] PC,
	input  [31:0] MD_data,
	input  [31:0] cp0_data,
	input         exception,

	input  [4 :0] rd,
	input  [4 :0] rt,

	output [31:0] RF_wdata,
	output [4 :0] RF_waddr,
	output        RF_wen
);

	wire [31:0] PCplus8 = PC + 32'd8;

	assign RF_wdata = ({32{RFsrc[`RF_from_mem]}}     &   mem_data) | 
					  ({32{RFsrc[`RF_from_alu]}}     & alu_result) |
					  ({32{RFsrc[`RF_from_PCplus8]}} &    PCplus8) |
					  ({32{RFsrc[`RF_from_MD]}}      &    MD_data) |
					  ({32{RFsrc[`RF_from_CP0]}}     &   cp0_data);

	assign RF_waddr = ({5{RFdst[`RF_in_rd]}} &    rd) |
					  ({5{RFdst[`RF_in_rt]}} &    rt) |
					  ({5{RFdst[`RF_in_ra]}} & 5'd31);

	assign RF_wen = (RFdst != 3'b000) & ~exception;

endmodule