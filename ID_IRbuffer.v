module ID_IRbuffer(
	input         clk,
	input         rst,
	input         ID_stall,
	input         IF_invalid,
	input  [31:0] inst_sram_rdata,
	input  [31:0] ID_in_PC,
	
	output [31:0] ID_instruction,
	output [31:0] ID_out_PC
);

	reg    [31:0] IR_buffer;
	reg    [31:0] PC_buffer;
	reg           ID_stall_reg;
	reg           IF_invalid_reg;

	always @(posedge clk) begin
		if (rst) begin
			IR_buffer      <= 32'd0;
			PC_buffer      <= 32'hbfc00000;
			ID_stall_reg   <= 1'b0;
			IF_invalid_reg <= 1'b0;
		end else begin
			IR_buffer      <= ID_instruction;
			PC_buffer      <= ID_out_PC;
			ID_stall_reg   <= ID_stall;
			IF_invalid_reg <= IF_invalid;
		end
	end

	assign ID_instruction = ID_stall_reg ? IR_buffer : IF_invalid_reg ? 32'h0 : inst_sram_rdata;
	assign ID_out_PC      = ID_stall_reg ? PC_buffer : IF_invalid_reg ? 32'hbfc00000 : ID_in_PC;

endmodule