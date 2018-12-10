`include "mycpu.h"

module ID_EX(
	input         clk,
	input         rst,
	input         ID_stall,
	input         EX_stall,
	input         ID_invalid,

	input  [31:0] ID_out_PC,
	input  [31:0] ID_bad_inst,
	input  [31:0] ID_out_instruction,
	input  [10:0] ID_out_PCsrc,
	input  [2 :0] ID_out_RFdst,
	input  [4 :0] ID_out_RFsrc,
	input  [6 :0] ID_out_RFdtl,
	input         ID_out_cp0wen,
	input  [31:0] ID_out_cp0_data,
	input  [3 :0] ID_out_ALUsrc,
	input  [13:0] ID_out_ALUop,
	input  [7 :0] ID_out_MDop,
	input         ID_out_data_sram_en,
	input  [4 :0] ID_out_data_dtl,
	input  [31:0] ID_out_RF_rs_data,
	input  [31:0] ID_out_RF_rt_data,
	input         ID_syscall_exception,
	input         ID_break_exception,
	input         ID_reserved_exception,
	input         ID_AdEF_exception,
	input         ID_slot,

	output [31:0] EX_in_PC,
	output [31:0] EX_bad_inst,
	output [31:0] EX_in_instruction,
	output [10:0] EX_in_PCsrc,
	output [2 :0] EX_in_RFdst,
	output [4 :0] EX_in_RFsrc,
	output [6 :0] EX_in_RFdtl,
	output        EX_in_cp0wen,
	output [31:0] EX_in_cp0_data,
	output [3 :0] EX_in_ALUsrc,
	output [13:0] EX_in_ALUop,
	output [7 :0] EX_in_MDop,
	output        EX_in_data_sram_en,
	output [4 :0] EX_in_data_dtl,
	output [31:0] EX_in_RF_rs_data,
	output [31:0] EX_in_RF_rt_data,
	output        EX_syscall_exception,
	output        EX_break_exception,
	output        EX_reserved_exception,
	output        EX_AdEF_exception,
	output        EX_slot
);

	reg [31:0] reg_PC;
	reg [31:0] reg_bad_inst;
	reg [31:0] reg_instruction;
	reg [10:0] reg_PCsrc;
	reg [2 :0] reg_RFdst;
	reg [4 :0] reg_RFsrc;
	reg [6 :0] reg_RFdtl;
	reg        reg_cp0wen;
	reg [31:0] reg_cp0_data;
	reg [3 :0] reg_ALUsrc;
	reg [13:0] reg_ALUop;
	reg [7 :0] reg_MDop;
	reg        reg_data_sram_en;
	reg [4 :0] reg_data_dtl;
	reg [31:0] reg_RF_rs_data;
	reg [31:0] reg_RF_rt_data;
	reg        reg_syscall_exception;
	reg        reg_break_exception;
	reg        reg_reserved_exception;
	reg        reg_AdEF_exception;
	reg        reg_slot;

	assign EX_in_PC            = reg_PC;
	assign EX_bad_inst         = reg_bad_inst;
	assign EX_in_instruction   = reg_instruction;
	assign EX_in_PCsrc         = reg_PCsrc;
	assign EX_in_RFdst         = reg_RFdst;
	assign EX_in_RFsrc         = reg_RFsrc;
	assign EX_in_RFdtl         = reg_RFdtl;
	assign EX_in_cp0wen        = reg_cp0wen;
	assign EX_in_cp0_data      = reg_cp0_data;
	assign EX_in_ALUsrc        = reg_ALUsrc;
	assign EX_in_ALUop         = reg_ALUop;
	assign EX_in_MDop          = reg_MDop;
	assign EX_in_data_sram_en  = reg_data_sram_en;
	assign EX_in_data_dtl      = reg_data_dtl;
	assign EX_in_RF_rs_data    = reg_RF_rs_data;
	assign EX_in_RF_rt_data    = reg_RF_rt_data;
	assign EX_syscall_exception= reg_syscall_exception;
	assign EX_break_exception  = reg_break_exception;
	assign EX_reserved_exception = reg_reserved_exception;
	assign EX_AdEF_exception   = reg_AdEF_exception;
	assign EX_slot             = reg_slot;

	always @(posedge clk) begin
		if (rst | (ID_stall & ~EX_stall) | ID_invalid) begin
			reg_PC            <= 32'hbfc00000;
			reg_bad_inst      <= 32'hbfc00000;
			reg_instruction   <= 32'd0;
			reg_PCsrc         <= 11'd0;
			reg_RFdst         <= 3'b000;
			reg_RFsrc         <= 5'b00000;
			reg_RFdtl         <= 3'd0;
			reg_cp0wen        <= 1'b0;
			reg_cp0_data      <= 32'd0;
			reg_ALUsrc        <= 4'b0000;
			reg_ALUop         <= 14'd0;
			reg_MDop          <= 8'd0;
			reg_data_sram_en  <= 1'b0;
			reg_data_dtl      <= 5'b00000;
			reg_RF_rs_data    <= 32'd0;
			reg_RF_rt_data    <= 32'd0;
			reg_syscall_exception <= 1'b0;
			reg_break_exception <= 1'b0;
			reg_reserved_exception <= 1'b0;
			reg_AdEF_exception <= 1'b0;
			reg_slot          <= 1'b0;
		end else if (EX_stall) begin
		end else begin
			reg_PC            <= ID_out_PC;
			reg_bad_inst      <= ID_bad_inst;
			reg_instruction   <= ID_out_instruction;
			reg_PCsrc         <= ID_out_PCsrc;
			reg_RFdst         <= ID_out_RFdst;
			reg_RFsrc         <= ID_out_RFsrc;
			reg_RFdtl         <= ID_out_RFdtl;
			reg_cp0wen        <= ID_out_cp0wen;
			reg_cp0_data      <= ID_out_cp0_data;
			reg_ALUsrc        <= ID_out_ALUsrc;
			reg_ALUop         <= ID_out_ALUop;
			reg_MDop          <= ID_out_MDop;
			reg_data_sram_en  <= ID_out_data_sram_en;
			reg_data_dtl      <= ID_out_data_dtl;
			reg_RF_rs_data    <= ID_out_RF_rs_data;
			reg_RF_rt_data    <= ID_out_RF_rt_data;
			reg_syscall_exception <= ID_syscall_exception;
			reg_break_exception <= ID_break_exception;
			reg_reserved_exception <= ID_reserved_exception;
			reg_AdEF_exception <= ID_AdEF_exception;
			reg_slot          <= ID_slot;
		end
	end

endmodule