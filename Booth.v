module Booth(
	input [31:0] a,
	input [31:0] b,
	input  sign,

	output [15:0] i,
	output [33:0] pp0,
	output [33:0] pp1,
	output [33:0] pp2,
	output [33:0] pp3,
	output [33:0] pp4,
	output [33:0] pp5,
	output [33:0] pp6,
	output [33:0] pp7,
	output [33:0] pp8,
	output [33:0] pp9,
	output [33:0] pp10,
	output [33:0] pp11,
	output [33:0] pp12,
	output [33:0] pp13,
	output [33:0] pp14,
	output [33:0] pp15,
	output [31:0] pp16
);

assign i[15:0] = {b[31], b[29], b[27], b[25], b[23], b[21], b[19], b[17], b[15], b[13], b[11], b[9], b[7], b[5], b[3], b[1]};

Booth_Norm 
	Norm_0 (.mulcand(a), .r4input({b[1:0],1'b0}), .sign(sign), .pp(pp0)),
 	Norm_1 (.mulcand(a), .r4input(b[3:1]),        .sign(sign), .pp(pp1)),
 	Norm_2 (.mulcand(a), .r4input(b[5:3]),        .sign(sign), .pp(pp2)),
	Norm_3 (.mulcand(a), .r4input(b[7:5]),        .sign(sign), .pp(pp3)),
	Norm_4 (.mulcand(a), .r4input(b[9:7]),        .sign(sign), .pp(pp4)),
	Norm_5 (.mulcand(a), .r4input(b[11:9]),       .sign(sign), .pp(pp5)),
	Norm_6 (.mulcand(a), .r4input(b[13:11]),      .sign(sign), .pp(pp6)),
	Norm_7 (.mulcand(a), .r4input(b[15:13]),      .sign(sign), .pp(pp7)),
	Norm_8 (.mulcand(a), .r4input(b[17:15]),      .sign(sign), .pp(pp8)),
	Norm_9 (.mulcand(a), .r4input(b[19:17]),      .sign(sign), .pp(pp9)),
	Norm_10(.mulcand(a), .r4input(b[21:19]),      .sign(sign), .pp(pp10)),
	Norm_11(.mulcand(a), .r4input(b[23:21]),      .sign(sign), .pp(pp11)),
	Norm_12(.mulcand(a), .r4input(b[25:23]),      .sign(sign), .pp(pp12)),
	Norm_13(.mulcand(a), .r4input(b[27:25]),      .sign(sign), .pp(pp13)),
	Norm_14(.mulcand(a), .r4input(b[29:27]),      .sign(sign), .pp(pp14)),
	Norm_15(.mulcand(a), .r4input(b[31:29]),      .sign(sign), .pp(pp15));
Booth_MSB    u_MSB(.mulcand(a), .msb(b[31]),             .sign(sign), .pp(pp16));
    
endmodule
