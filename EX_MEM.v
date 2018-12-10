`include "mycpu.h"

module EX_MEM(
    input         clk,
    input         rst,
    input         EX_stall,
    input         MEM_stall,
	input         EX_invalid,

    input  [31:0] EX_out_ALUresult,
    input  [31:0] EX_out_MD_data,
    input  [31:0] EX_out_PC,
	input  [31:0] EX_bad_inst,
    input  [31:0] EX_out_instruction,
    input  [31:0] EX_out_data_sram_addr,
    input  [31:0] EX_out_data_sram_wdata,
	input         EX_out_data_sram_en,
    input  [2 :0] EX_out_RFdst,
    input  [4 :0] EX_out_RFsrc,
	input  [6 :0] EX_out_RFdtl,
	input  [31:0] EX_out_cp0_data,
	input         EX_syscall_exception,
	input         EX_break_exception,
	input         EX_reserved_exception,
	input         EX_overflow_exception,
	input         EX_AdES_exception,
	input         EX_AdEF_exception,
	input         EX_slot,

    output [31:0] MEM_in_ALUresult,
    output [31:0] MEM_in_MD_data,
    output [31:0] MEM_in_PC,
	output [31:0] MEM_bad_inst,
    output [31:0] MEM_in_instruction,
    output [31:0] MEM_in_data_sram_addr,
    output [31:0] MEM_in_data_sram_wdata,
	output        MEM_in_data_sram_en,
    output [2 :0] MEM_in_RFdst,
    output [4 :0] MEM_in_RFsrc,
	output [6 :0] MEM_in_RFdtl,
	output [31:0] MEM_in_cp0_data,
	output        MEM_syscall_exception,
	output        MEM_break_exception,
	output        MEM_reserved_exception,
	output        MEM_overflow_exception,
	output        MEM_AdES_exception,
	output        MEM_AdEF_exception,
	output        MEM_slot 
);
	
	reg [31:0] reg_ALUresult;
	reg [31:0] reg_MD_data;
    reg [31:0] reg_PC;
	reg [31:0] reg_bad_inst;
    reg [31:0] reg_instruction;
    reg [31:0] reg_data_sram_addr;
    reg [31:0] reg_data_sram_wdata;
	reg        reg_data_sram_en;
    reg [2 :0] reg_RFdst;
    reg [4 :0] reg_RFsrc;
	reg [6 :0] reg_RFdtl;
	reg [31:0] reg_cp0_data;
	reg        reg_syscall_exception;
	reg        reg_break_exception;
	reg		   reg_reserved_exception;
	reg        reg_overflow_exception;
	reg        reg_AdES_exception;
	reg        reg_AdEF_exception;
	reg        reg_slot;

    assign MEM_in_ALUresult       = reg_ALUresult;
    assign MEM_in_MD_data         = reg_MD_data;
    assign MEM_in_PC              = reg_PC;
	assign MEM_bad_inst           = reg_bad_inst;
    assign MEM_in_instruction     = reg_instruction;
    assign MEM_in_data_sram_addr  = reg_data_sram_addr;
    assign MEM_in_data_sram_wdata = reg_data_sram_wdata;
	assign MEM_in_data_sram_en    = reg_data_sram_en;
    assign MEM_in_RFdst           = reg_RFdst;
    assign MEM_in_RFsrc           = reg_RFsrc;
	assign MEM_in_RFdtl           = reg_RFdtl;
	assign MEM_in_cp0_data        = reg_cp0_data;
	assign MEM_syscall_exception  = reg_syscall_exception;
	assign MEM_break_exception    = reg_break_exception;
	assign MEM_reserved_exception = reg_reserved_exception;
	assign MEM_overflow_exception = reg_overflow_exception;
	assign MEM_AdES_exception     = reg_AdES_exception;
	assign MEM_AdEF_exception     = reg_AdEF_exception;
	assign MEM_slot               = reg_slot;

	always @(posedge clk) begin
		if (rst | (EX_stall & ~MEM_stall) | EX_invalid) begin
	        reg_ALUresult       <= 32'd0;
	        reg_MD_data         <= 32'd0;
	        reg_PC              <= 32'hbfc00000;
			reg_bad_inst        <= 32'hbfc00000;
	        reg_instruction     <= 32'd0;
	        reg_data_sram_addr  <= 32'd0;
	        reg_data_sram_wdata <= 32'd0;
			reg_data_sram_en    <= 1'b0;
	        reg_RFdst           <= 3'b000;
	        reg_RFsrc           <= 5'b00000;
			reg_RFdtl           <= 6'd0;
			reg_cp0_data        <= 32'd0;
			reg_syscall_exception <= 1'b0;
			reg_break_exception <= 1'b0;
			reg_reserved_exception <= 1'b0;
			reg_overflow_exception <= 1'b0;
			reg_AdES_exception  <= 1'b0;
			reg_AdEF_exception  <= 1'b0;
			reg_slot            <= 1'b0;
		end else if (MEM_stall) begin
		end else begin
	        reg_ALUresult       <= EX_out_ALUresult;
	        reg_MD_data         <= EX_out_MD_data;
	        reg_PC              <= EX_out_PC;
			reg_bad_inst        <= EX_bad_inst;
	        reg_instruction     <= EX_out_instruction;
	        reg_data_sram_addr  <= EX_out_data_sram_addr;
	        reg_data_sram_wdata <= EX_out_data_sram_wdata;
			reg_data_sram_en    <= EX_out_data_sram_en;
	        reg_RFdst           <= EX_out_RFdst;
	        reg_RFsrc           <= EX_out_RFsrc;
			reg_RFdtl           <= EX_out_RFdtl;
			reg_cp0_data        <= EX_out_cp0_data;
			reg_syscall_exception <= EX_syscall_exception;
			reg_break_exception <= EX_break_exception;
			reg_reserved_exception <= EX_reserved_exception;
			reg_overflow_exception <= EX_overflow_exception;
			reg_AdES_exception  <= EX_AdES_exception;
			reg_AdEF_exception  <= EX_AdEF_exception;
			reg_slot            <= EX_slot;
		end
	end

endmodule