module ID_Regfile(
	input         clk,
	input         rst,

	input  [4 :0] raddr1,
	input  [4 :0] raddr2,

	input  [4 :0] waddr,
	input  [31:0] wdata,
	input         wen,
	input  [3 :0] strb,

	output [31:0] rdata1,
	output [31:0] rdata2,
	output [31:0] debug_wb_rf_wdata
);

	reg [31:0] r [31:0];
	
	wire [7:0] byte1 = strb[0]? wdata[7 : 0] : r[waddr][7 : 0];
	wire [7:0] byte2 = strb[1]? wdata[15: 8] : r[waddr][15: 8];
	wire [7:0] byte3 = strb[2]? wdata[23:16] : r[waddr][23:16];
	wire [7:0] byte4 = strb[3]? wdata[31:24] : r[waddr][31:24];
	
	always @(posedge clk or posedge rst) begin
		if (rst == 1) begin
			r[0] <= 32'd0;
		end
	end
		
	always @(posedge clk) begin
		if (wen == 1 && waddr != 0) begin
			r[waddr] <= {byte4, byte3, byte2, byte1};
		end
	end
		
	assign rdata1 = r[raddr1];
	assign rdata2 = r[raddr2];
	assign debug_wb_rf_wdata = {byte4, byte3, byte2, byte1};

endmodule