module MEM_WB(
 	input         clk,
    input         rst,
    input         MEM_stall,
	input         MEM_invalid,

	input  [31:0] MEM_out_data_sram_addr,
    input  [31:0] MEM_out_RF_wdata,
    input  [4 :0] MEM_out_RF_waddr,
	input  [3 :0] MEM_out_RF_strb,
    input         MEM_out_RF_wen,
    input  [31:0] MEM_out_PC,
	input  [31:0] MEM_bad_inst,
	input         MEM_syscall_exception,
	input         MEM_break_exception,
	input         MEM_reserved_exception,
	input         MEM_overflow_exception,
	input         MEM_AdES_exception,
	input         MEM_AdEL_exception,
	input         MEM_AdEF_exception,
	input         MEM_slot,

	output [31:0] WB_in_data_sram_addr,
    output [31:0] WB_in_RF_wdata,
    output [4 :0] WB_in_RF_waddr,
	output [3 :0] WB_in_RF_strb,
    output        WB_in_RF_wen,
    output [31:0] WB_in_PC,
	output [31:0] WB_bad_inst,
	output        WB_syscall_exception,
	output        WB_break_exception,
	output        WB_reserved_exception,
	output        WB_overflow_exception,
	output        WB_AdES_exception,
	output        WB_AdEL_exception,
	output        WB_AdEF_exception,
	output        WB_slot
);

	reg [31:0] reg_data_sram_addr;
    reg [31:0] reg_RF_wdata;
    reg [4 :0] reg_RF_waddr;
	reg [3 :0] reg_RF_strb;
    reg        reg_RF_wen;
    reg [31:0] reg_PC;
	reg [31:0] reg_bad_inst;
	reg        reg_syscall_exception;
	reg        reg_break_exception;
	reg        reg_reserved_exception;
	reg        reg_overflow_exception;
	reg        reg_AdES_exception;
	reg        reg_AdEL_exception;
	reg        reg_AdEF_exception;
	reg        reg_slot;

	assign WB_in_data_sram_addr  = reg_data_sram_addr;
    assign WB_in_RF_wdata        = reg_RF_wdata;
    assign WB_in_RF_waddr        = reg_RF_waddr;
	assign WB_in_RF_strb         = reg_RF_strb;
    assign WB_in_RF_wen          = reg_RF_wen;
    assign WB_in_PC              = reg_PC;
	assign WB_bad_inst           = reg_bad_inst;
	assign WB_syscall_exception  = reg_syscall_exception;
	assign WB_break_exception    = reg_break_exception;
	assign WB_reserved_exception = reg_reserved_exception;
	assign WB_overflow_exception = reg_overflow_exception;
	assign WB_AdES_exception     = reg_AdES_exception;
	assign WB_AdEL_exception     = reg_AdEL_exception;
	assign WB_AdEF_exception     = reg_AdEF_exception;
	assign WB_slot               = reg_slot;

	always @(posedge clk) begin
		if (rst | MEM_stall | MEM_invalid) begin
			reg_data_sram_addr     <= 32'd0;
			reg_RF_wdata           <= 32'd0;
			reg_RF_waddr           <= 5'd0;
			reg_RF_strb            <= 4'b1111;
			reg_RF_wen             <= 1'b0;
			reg_PC                 <= 32'hbfc00000;
			reg_bad_inst           <= 32'hbfc00000;
			reg_syscall_exception  <= 1'b0;
			reg_break_exception    <= 1'b0;
			reg_reserved_exception <= 1'b0;
			reg_overflow_exception <= 1'b0;
			reg_AdES_exception     <= 1'b0;
			reg_AdEL_exception     <= 1'b0;
			reg_AdEF_exception     <= 1'b0;
			reg_slot               <= 1'b0;
		end else begin
			reg_data_sram_addr     <= MEM_out_data_sram_addr;
			reg_RF_wdata           <= MEM_out_RF_wdata;
			reg_RF_waddr           <= MEM_out_RF_waddr;
			reg_RF_strb            <= MEM_out_RF_strb;
			reg_RF_wen             <= MEM_out_RF_wen;
			reg_PC                 <= MEM_out_PC;
			reg_bad_inst           <= MEM_bad_inst;
			reg_syscall_exception  <= MEM_syscall_exception;
			reg_break_exception    <= MEM_break_exception;
			reg_reserved_exception <= MEM_reserved_exception;
			reg_overflow_exception <= MEM_overflow_exception;
			reg_AdES_exception     <= MEM_AdES_exception;
			reg_AdEL_exception     <= MEM_AdEL_exception;
			reg_AdEF_exception     <= MEM_AdEF_exception;
			reg_slot               <= MEM_slot;
		end
	end

endmodule