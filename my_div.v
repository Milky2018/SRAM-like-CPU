`define DivFree            2'b00
`define DivByZero          2'b01
`define DivOn              2'b10
`define DivEnd             2'b11

module my_div(
	input  	          clk,
	input  	          rst,

	input             sign,
	input      [31:0] x,
	input      [31:0] y,
	input             start,
	input             cancel,

	output reg [63:0] result,
	output reg        complete
);

	wire [32:0] div_temp;

	reg [5 :0] cnt;
	reg [64:0] dividend;
	reg [1 :0] state;
	reg [31:0] divisor; 
	reg [31:0] temp_x;
	reg [31:0] temp_y;

	assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			state    <= `DivFree;
			complete  <= 1'b0;
			result <= {32'd0,32'd0};
		end else begin
			case (state)
				`DivFree: begin 
					if(start == 1'b1 && cancel == 1'b0) begin
			  			if(y == 32'd0) begin
			    			state <= `DivByZero; 
			  			end else begin
			    			state <= `DivOn; 
			    			cnt <= 6'b000000;
			    			if(sign == 1'b1 && x[31] == 1'b1 ) begin
			      				temp_x = ~x + 1; 
			    			end else begin
			      				temp_x = x;
			    			end
			    			if(sign == 1'b1 && y[31] == 1'b1 ) begin
			      				temp_y = ~y + 1; 
			    			end else begin
			      				temp_y = y;
			    			end
				    		dividend <= {32'd0,32'd0};
				    		dividend[32:1] <= temp_x;
				    		divisor <= temp_y;
			  			end
					end else begin 
			  			complete <= 1'b0;
			  			result <= {32'd0,32'd0};
					end
				end
				`DivByZero: begin 
					dividend <= {32'd0,32'd0};
					state <= `DivEnd;		 		
				end
				`DivOn: begin 
					if(cancel == 1'b0) begin
			  			if(cnt != 6'b100000) begin 
			    			if(div_temp[32] == 1'b1) begin 
			          			dividend <= {dividend[63:0] , 1'b0};
			    			end else begin
			          			dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
			    			end
			    			cnt <= cnt + 1;
			  			end else begin 
			    			if((sign == 1'b1) && ((x[31] ^ y[31]) == 1'b1)) begin
			        			dividend[31:0] <= (~dividend[31:0] + 1);
			    			end
			    			if((sign == 1'b1) && ((x[31] ^ dividend[64]) == 1'b1)) begin              
			        			dividend[64:33] <= (~dividend[64:33] + 1);
			    			end
			    			state <= `DivEnd; 
			    			cnt <= 6'd0; 
			  			end
					end else begin
			  			state <= `DivFree; 
					end	
				end
				`DivEnd: begin 
					result <= {dividend[64:33], dividend[31:0]};  
					complete <= 1'b1;
					if(start == 1'b0) begin
			 	 		state <= `DivFree;
			  			complete <= 1'b0;
			  			result <= {32'd0,32'd0}; 
					end		  	
				end
			endcase
	   	end
	end

endmodule