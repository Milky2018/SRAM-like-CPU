module EX_MulDiv(
	input clk,
	input rst,

	input        MEM_exception,
	input [ 7:0] MDop,
	input [31:0] rs_data,
	input [31:0] rt_data,

	output [31:0] MD_data,
	output        EX_MD_stall
);
	parameter state_wait = 5'b00001;
	parameter state_mul  = 5'b00010;
	parameter state_div  = 5'b00100;
	parameter state_divr = 5'b01000;
	parameter state_mulr = 5'b10000;

	reg  [31:0] HI, LO;
	reg  [4 :0] state;
	reg         start_div, end_reg;
	wire        end_div;
	wire [63:0] mul_result, div_result, result;

	wire div   = MDop[7] & ~MEM_exception;
	wire divu  = MDop[6] & ~MEM_exception;
	wire mult  = MDop[5] & ~MEM_exception;
	wire multu = MDop[4] & ~MEM_exception;
	wire mfhi  = MDop[3] & ~MEM_exception;
	wire mflo  = MDop[2] & ~MEM_exception;
	wire mthi  = MDop[1] & ~MEM_exception;
	wire mtlo  = MDop[0] & ~MEM_exception;

	wire sign = div | mult;

	assign MD_data     = ({32{mfhi}} & HI) | ({32{mflo}} & LO);
	assign result      = ({64{div|divu}} & div_result) | ({64{mult|multu}} & mul_result);
	assign EX_MD_stall = end_reg? 1'b0 : 
		                 (state == state_wait && (div|divu) == 1'b1) | 
		                 (state == state_div) |
		                 (state == state_wait && (mult|multu) == 1'b1) |
		                 (state == state_mul);

	always @(posedge clk) begin
		if (rst) begin
			// HI <= 32'd0;
			// LO <= 32'd0;
			state <= state_wait;
			start_div <= 1'b0;
			end_reg <= 1'b0;
		end else begin
			case (state)
				state_wait: begin
					if (div|divu) begin
						state <= state_div;
						start_div <= 1'b1;
						end_reg <= 1'b0;
					end else if (mult|multu) begin
						state <= state_mul;
					end else if (mthi) begin
						HI <= rs_data;
					end else if (mtlo) begin
						LO <= rs_data;
					end else begin
						state <= state;
					end
				end
				state_mul: begin
					HI <= result[63:32];
					LO <= result[31:0];
					state <= state_mulr;
				end
				state_mulr: begin
					state <= state_wait;
				end
				state_div: begin
					if (end_div) begin
						HI <= result[63:32];
						LO <= result[31:0];
						state <= state_divr;
						end_reg <= 1'b1;
						start_div <= 1'b0;
					end
				end
				state_divr: begin
					state <= state_wait;
					end_reg <= 1'b0;
				end
			endcase
		end
	end

	Multiplier u_Multiplier(
		.clk(clk),
		.rst(rst),
		.sign(sign),
		.a(rs_data),
		.b(rt_data),

		.result(mul_result)
	);

	Divider u_Divider(
		.clk(clk),
		.rst(rst),
		.div(start_div),
		.sign(sign), 
		.x(rs_data),
		.y(rt_data), 
		.result(div_result),
		.complete(end_div)
	);

endmodule