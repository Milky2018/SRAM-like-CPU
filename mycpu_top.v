`timescale 10 ns / 1 ns

module mycpu_top(
    input clk,
    input resetn,            //low active

    output        inst_sram_en,
    output [3 :0] inst_sram_wen,
    output [31:0] inst_sram_addr,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    
    output        data_sram_en,
    output [3 :0] data_sram_wen,
    output [31:0] data_sram_addr,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,

    //debug interface
    output [31:0] debug_wb_pc,
    output [3 :0] debug_wb_rf_wen,
    output [4 :0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

wire rst = ~resetn;

assign inst_sram_wen = 4'b0000;
assign inst_sram_wdata = 32'd0;
assign inst_sram_en = resetn;

wire [31:0] IF_in_PC;
wire [31:0] IF_out_PC = IF_in_PC;
wire [31:0] ID_in_PC;
// wire [31:0] ID_out_PC = ID_in_PC;
wire [31:0] ID_out_PC;
wire [31:0] EX_in_PC;
wire [31:0] EX_out_PC = EX_in_PC;
wire [31:0] MEM_in_PC;
wire [31:0] MEM_out_PC = MEM_in_PC;
wire [31:0] WB_in_PC;

wire [31:0] ID_in_instruction;
wire [31:0] ID_out_instruction = ID_in_instruction;
wire [31:0] EX_in_instruction;
wire [31:0] EX_out_instruction = EX_in_instruction;
wire [31:0] MEM_in_instruction;

wire [10:0] ID_out_PCsrc;
wire [10:0] EX_in_PCsrc;

wire [31:0] ID_out_nextPC;

wire [31:0] IF_bad_inst;
wire [31:0] ID_bad_inst;
wire [31:0] EX_bad_inst;
wire [31:0] MEM_bad_inst;
wire [31:0] WB_bad_inst;

wire [2:0] ID_out_RFdst;
wire [2:0] EX_in_RFdst;
wire [2:0] EX_out_RFdst = EX_in_RFdst;
wire [2:0] MEM_in_RFdst;

wire [4:0] ID_out_RFsrc;
wire [4:0] EX_in_RFsrc;
wire [4:0] EX_out_RFsrc = EX_in_RFsrc;
wire [4:0] MEM_in_RFsrc;

wire [6:0] ID_out_RFdtl;
wire [6:0] EX_in_RFdtl;
wire [6:0] EX_out_RFdtl = EX_in_RFdtl;
wire [6:0] MEM_in_RFdtl;

wire [31:0] ID_out_RF_rs_data;
wire [31:0] EX_in_RF_rs_data;

wire [31:0] ID_out_RF_rt_data;
wire [31:0] EX_in_RF_rt_data;

wire [31:0] ID_out_cp0_data;
wire [31:0] EX_in_cp0_data;
wire [31:0] EX_out_cp0_data = EX_in_cp0_data;
wire [31:0] MEM_in_cp0_data;
wire eret; 

wire ID_out_cp0wen;
wire EX_in_cp0wen;

wire [31:0] EX_out_ALUresult;
wire [31:0] MEM_in_ALUresult;

wire [31:0] EX_out_MD_data;
wire [31:0] MEM_in_MD_data;

wire [3:0] ID_out_ALUsrc;
wire [3:0] EX_in_ALUsrc;

wire [13:0] ID_out_ALUop;
wire [13:0] EX_in_ALUop;

wire [7:0] ID_out_MDop;
wire [7:0] EX_in_MDop;

wire ID_out_data_sram_en;
wire EX_in_data_sram_en;
wire EX_out_data_sram_en;
wire MEM_in_data_sram_en;

wire [4:0] MEM_out_RF_waddr;
wire [4:0] WB_in_RF_waddr;

wire [31:0] MEM_out_RF_wdata;
wire [31:0] WB_in_RF_wdata;

wire MEM_out_RF_wen;
wire WB_in_RF_wen;

wire [3:0] MEM_out_RF_strb;
wire [3:0] WB_in_RF_strb;

wire [31:0] EX_out_data_sram_wdata;
wire [31:0] MEM_in_data_sram_wdata;

wire [31:0] EX_out_data_sram_addr;
wire [31:0] MEM_in_data_sram_addr;
wire [31:0] MEM_out_data_sram_addr = MEM_in_data_sram_addr;
wire [31:0] WB_in_data_sram_addr;

wire [31:0] MEM_in_mem_rdata = data_sram_rdata;
wire [31:0] MEM_out_mem_rdata;

wire [4:0] ID_out_data_dtl;
wire [4:0] EX_in_data_dtl;

wire [3:0] EX_out_data_sram_strb;

wire IF_stall, ID_stall, EX_stall, MEM_stall;
wire ID_bypass_stall, EX_MD_stall;
wire IF_invalid, ID_invalid, EX_invalid, MEM_invalid;

wire interrupt;

wire IF_exception,
     IF_AdEF_exception; // IF stage
wire ID_exception, 
     ID_syscall_exception, 
     ID_break_exception,
     ID_reserved_exception,
     ID_AdEF_exception; // ID stage
wire EX_exception, 
     EX_overflow_exception, 
     EX_syscall_exception, 
     EX_break_exception,
     EX_reserved_exception,
     EX_AdES_exception,
     EX_AdEF_exception; // EX stage
wire MEM_exception, 
     MEM_overflow_exception, 
     MEM_syscall_exception,
     MEM_break_exception,
     MEM_reserved_exception,
     MEM_AdES_exception,
     MEM_AdEL_exception,
     MEM_AdEF_exception; // MEM stage
wire exception, 
     WB_exception, 
     WB_syscall_exception, 
     WB_break_exception,
     WB_overflow_exception,
     WB_reserved_exception,
     WB_AdES_exception,
     WB_AdEL_exception,
     WB_AdEF_exception; // WB stage

// branch delay slot?
wire ID_slot, EX_slot, MEM_slot, WB_slot;
// assign ID_slot = ~(ID_out_PC + 32'd4 == IF_in_PC);
assign ID_slot = ~EX_in_PCsrc[0];

assign IF_exception = IF_AdEF_exception;
assign ID_exception = ID_syscall_exception | ID_break_exception | ID_reserved_exception | ID_AdEF_exception;
assign EX_exception = EX_overflow_exception | EX_syscall_exception | EX_break_exception | EX_reserved_exception |
                      EX_AdES_exception | EX_AdEF_exception;
assign MEM_exception = MEM_overflow_exception | MEM_syscall_exception | MEM_break_exception | MEM_reserved_exception | 
                       MEM_AdES_exception | MEM_AdEL_exception | MEM_AdEF_exception;
assign WB_exception = WB_syscall_exception | WB_overflow_exception | WB_break_exception | WB_reserved_exception | 
                      WB_AdES_exception | WB_AdEL_exception | WB_AdEF_exception;
// Exception control

// Stall control
assign IF_stall = ID_stall;
assign ID_stall = EX_stall | ID_bypass_stall;
assign EX_stall = MEM_stall | EX_MD_stall;
assign MEM_stall = 1'b0;

// invalid control
assign IF_invalid = ID_invalid | eret | ID_exception | interrupt;
assign ID_invalid = EX_invalid | EX_exception | interrupt;
assign EX_invalid = MEM_invalid | MEM_exception;
assign MEM_invalid = WB_exception;

// IF
IF u_IF(
    .clk(clk),
    .rst(rst),
    .IF_stall(IF_stall),

    .next_PC(ID_out_nextPC),

    .IF_in_PC(IF_in_PC),
    .IF_AdEF_exception(IF_AdEF_exception),
    .IF_bad_inst(IF_bad_inst)
);

assign inst_sram_addr = IF_in_PC;

// IF_ID
IF_ID u_IF_ID(
    .clk(clk),
    .rst(rst),
    .IF_stall(IF_stall),
    .ID_stall(ID_stall),
    .IF_invalid(IF_invalid),

    .IF_out_PC(IF_out_PC),
    .IF_AdEF_exception(IF_AdEF_exception),
    .IF_bad_inst(IF_bad_inst),

    .ID_in_PC(ID_in_PC),
    .ID_AdEF_exception(ID_AdEF_exception),
    .ID_bad_inst(ID_bad_inst)
);

// ID
ID_Control u_ID_Control(
    .instruction(ID_in_instruction),

    .ALUsrc(ID_out_ALUsrc),
    .ALUop(ID_out_ALUop),
    .MDop(ID_out_MDop),

    .PCsrc(ID_out_PCsrc),

    .RFdst(ID_out_RFdst),
    .RFsrc(ID_out_RFsrc),
    .RFdtl(ID_out_RFdtl),
    .cp0wen(ID_out_cp0wen),

    .syscall_exception(ID_syscall_exception),
    .break_exception(ID_break_exception),
    .reserved_exception(ID_reserved_exception),
    .eret(eret),

    .data_en(ID_out_data_sram_en),
    .data_dtl(ID_out_data_dtl)
);

ID_IRbuffer u_ID_IRbuffer(
    .clk(clk),
    .rst(rst),
    .ID_stall(ID_stall),
    .IF_invalid(IF_invalid),
    .inst_sram_rdata(inst_sram_rdata),
    .ID_in_PC(ID_in_PC),
    
    .ID_instruction(ID_in_instruction),
    .ID_out_PC(ID_out_PC)
);

wire [31:0] RF_rs_data, RF_rt_data;
ID_Regfile u_ID_Regfile(   
    .clk(clk),
    .rst(rst),

    .raddr1(ID_in_instruction[25:21]),
    .raddr2(ID_in_instruction[20:16]),

    .waddr(WB_in_RF_waddr),
    .wdata(WB_in_RF_wdata),
    .wen(WB_in_RF_wen),
    .strb(WB_in_RF_strb),

    .rdata1(RF_rs_data),
    .rdata2(RF_rt_data),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

wire [31:0] EPC;
ID_cp0 u_ID_cp0(
    .clk(clk),
    .rst(rst),

    .raddr(ID_in_instruction[15:11]),
    .wen(EX_in_cp0wen),
    .waddr(EX_in_instruction[15:11]),
    .wdata(EX_in_RF_rt_data),

    // .IF_PC(IF_in_PC),
    .ID_PC(ID_out_PC),
    // .EX_PC(EX_in_PC),
    // .MEM_PC(MEM_in_PC),
    .WB_PC(WB_in_PC),
    .ID_slot(ID_slot),
    .WB_slot(WB_slot),

    .data_addr(WB_in_data_sram_addr),
    .bad_inst_addr(WB_bad_inst),

    .IF_AdEF_exception(WB_AdEF_exception),
    .ID_syscall_exception(WB_syscall_exception),
    .ID_break_exception(WB_break_exception),
    .ID_reserved_exception(WB_reserved_exception),
    .EX_overflow_exception(WB_overflow_exception),
    .EX_AdES_exception(WB_AdES_exception),
    .MEM_AdEL_exception(WB_AdEL_exception),
    .ID_eret(eret),

    .rdata(ID_out_cp0_data),
    .EPC_data(EPC),
    .exception(exception),
    .interrupt(interrupt)
);

ID_RAWbypass u_ID_RAWbypass(
    .ID_instruction(ID_in_instruction),
    .EX_instruction(EX_in_instruction),
    .MEM_RF_waddr(MEM_out_RF_waddr),
    .WB_RF_waddr(WB_in_RF_waddr),

    .EX_RFsrc(EX_in_RFsrc),

    .EX_RFdst(EX_in_RFdst),

    .rs_data(RF_rs_data),
    .rt_data(RF_rt_data),

    .EX_ALUresult(EX_out_ALUresult),
    .EX_MD_data(EX_out_MD_data),
	.EX_PC(EX_in_PC),
    .EX_cp0_data(EX_in_cp0_data),
    .MEM_RF_wdata(MEM_out_RF_wdata),
    .WB_RF_wdata(WB_in_RF_wdata),

    .ID_out_RF_rs_data(ID_out_RF_rs_data),
    .ID_out_RF_rt_data(ID_out_RF_rt_data),
    .ID_bypass_stall(ID_bypass_stall)
);

ID_PCcontrol u_ID_PCcontrol(
    .oriPC(ID_out_PC),
    .curPC(IF_in_PC),
    .target(ID_in_instruction[25:0]),
    .offset(ID_in_instruction[15:0]),

    .rs_data(ID_out_RF_rs_data),
    .rt_data(ID_out_RF_rt_data),

    .EPC(EPC),
    .exception(exception),

    .PCsrc(ID_out_PCsrc),

    .nextPC(ID_out_nextPC)
);

// ID_EX
ID_EX u_ID_EX(
    .clk(clk),
    .rst(rst),
    .ID_stall(ID_stall),
    .EX_stall(EX_stall),
    .ID_invalid(ID_invalid),

    .ID_out_PC(ID_out_PC),
    .ID_bad_inst(ID_bad_inst),
    .ID_out_instruction(ID_out_instruction),
    .ID_out_PCsrc(ID_out_PCsrc),
    .ID_out_RFdst(ID_out_RFdst),
    .ID_out_RFsrc(ID_out_RFsrc),
    .ID_out_RFdtl(ID_out_RFdtl),
    .ID_out_cp0wen(ID_out_cp0wen),
    .ID_out_cp0_data(ID_out_cp0_data),
    .ID_out_ALUsrc(ID_out_ALUsrc),
    .ID_out_ALUop(ID_out_ALUop),
    .ID_out_MDop(ID_out_MDop),
    .ID_out_data_sram_en(ID_out_data_sram_en),
    .ID_out_data_dtl(ID_out_data_dtl),
    .ID_out_RF_rs_data(ID_out_RF_rs_data),
    .ID_out_RF_rt_data(ID_out_RF_rt_data),
    .ID_syscall_exception(ID_syscall_exception),
    .ID_break_exception(ID_break_exception),
    .ID_reserved_exception(ID_reserved_exception),
    .ID_AdEF_exception(ID_AdEF_exception),
    .ID_slot(ID_slot),

    .EX_in_PC(EX_in_PC),
    .EX_bad_inst(EX_bad_inst),
    .EX_in_instruction(EX_in_instruction),
    .EX_in_PCsrc(EX_in_PCsrc),
    .EX_in_RFdst(EX_in_RFdst),
    .EX_in_RFsrc(EX_in_RFsrc),
    .EX_in_RFdtl(EX_in_RFdtl),
    .EX_in_cp0wen(EX_in_cp0wen),
    .EX_in_cp0_data(EX_in_cp0_data),
    .EX_in_ALUsrc(EX_in_ALUsrc),
    .EX_in_ALUop(EX_in_ALUop),
    .EX_in_MDop(EX_in_MDop),
    .EX_in_data_sram_en(EX_in_data_sram_en),
    .EX_in_data_dtl(EX_in_data_dtl),
    .EX_in_RF_rs_data(EX_in_RF_rs_data),
    .EX_in_RF_rt_data(EX_in_RF_rt_data),
    .EX_syscall_exception(EX_syscall_exception),
    .EX_break_exception(EX_break_exception),
    .EX_reserved_exception(EX_reserved_exception),
    .EX_AdEF_exception(EX_AdEF_exception),
    .EX_slot(EX_slot)
);

// EX
wire [31:0] ALU_inputA, ALU_inputB;
EX_ALUcontrol u_EX_ALUcontrol(
    .ALUsrc(EX_in_ALUsrc),

    .rs_data(EX_in_RF_rs_data),
    .rt_data(EX_in_RF_rt_data),
    .imm(EX_in_instruction[15:0]),
    .shamt(EX_in_instruction[10:6]),

    .A(ALU_inputA),
    .B(ALU_inputB)
);

EX_ALU u_EX_ALU(
    .A(ALU_inputA),
    .B(ALU_inputB),
    .OHC_ALUop(EX_in_ALUop),

    .result(EX_out_ALUresult),
    .overflow_exception(EX_overflow_exception)
);

EX_MulDiv u_EX_MulDiv(
    .clk(clk),
    .rst(rst),

    .MEM_exception(MEM_exception),
    .MDop(EX_in_MDop),
    .rs_data(EX_in_RF_rs_data),
    .rt_data(EX_in_RF_rt_data),

    .MD_data(EX_out_MD_data),
    .EX_MD_stall(EX_MD_stall)
);

EX_MWcontrol u_EX_MWcontrol(
    .rt_data(EX_in_RF_rt_data),
    .alu_result(EX_out_ALUresult),

    .data_dtl(EX_in_data_dtl),

    .data_wdata(EX_out_data_sram_wdata),
    .data_addr(EX_out_data_sram_addr),
    .data_strb(EX_out_data_sram_strb),

    .in_en(EX_in_data_sram_en),
    .out_en(EX_out_data_sram_en),

    .AdES_exception(EX_AdES_exception),

    .MEM_exception(MEM_exception)
);
assign data_sram_wdata = EX_out_data_sram_wdata;
assign data_sram_addr  = {EX_out_data_sram_addr[31:2], 2'b00};
assign data_sram_en    = EX_out_data_sram_en;
assign data_sram_wen   = EX_out_data_sram_strb;

// EX_MEM
EX_MEM u_EX_MEM(
    .clk(clk),
    .rst(rst),
    .EX_stall(EX_stall),
    .MEM_stall(MEM_stall),
    .EX_invalid(EX_invalid),

    .EX_out_ALUresult(EX_out_ALUresult),
    .EX_out_MD_data(EX_out_MD_data),
    .EX_out_PC(EX_out_PC),
    .EX_bad_inst(EX_bad_inst),
    .EX_out_instruction(EX_out_instruction),
    .EX_out_data_sram_addr(EX_out_data_sram_addr),
    .EX_out_data_sram_wdata(EX_out_data_sram_wdata),
    .EX_out_data_sram_en(EX_out_data_sram_en),
    .EX_out_RFdst(EX_out_RFdst),
    .EX_out_RFsrc(EX_out_RFsrc),
    .EX_out_RFdtl(EX_out_RFdtl),
    .EX_out_cp0_data(EX_out_cp0_data),
    .EX_syscall_exception(EX_syscall_exception),
    .EX_break_exception(EX_break_exception),
    .EX_reserved_exception(EX_reserved_exception),
    .EX_overflow_exception(EX_overflow_exception),
    .EX_AdES_exception(EX_AdES_exception),
    .EX_AdEF_exception(EX_AdEF_exception),
    .EX_slot(EX_slot),

    .MEM_in_ALUresult(MEM_in_ALUresult),
    .MEM_in_MD_data(MEM_in_MD_data),
    .MEM_in_PC(MEM_in_PC),
    .MEM_bad_inst(MEM_bad_inst),
    .MEM_in_instruction(MEM_in_instruction),
    .MEM_in_data_sram_addr(MEM_in_data_sram_addr),
    .MEM_in_data_sram_wdata(MEM_in_data_sram_wdata),
    .MEM_in_data_sram_en(MEM_in_data_sram_en),
    .MEM_in_RFdst(MEM_in_RFdst),
    .MEM_in_RFsrc(MEM_in_RFsrc),
    .MEM_in_RFdtl(MEM_in_RFdtl),
    .MEM_in_cp0_data(MEM_in_cp0_data),
    .MEM_syscall_exception(MEM_syscall_exception),
    .MEM_break_exception(MEM_break_exception),
    .MEM_reserved_exception(MEM_reserved_exception),
    .MEM_overflow_exception(MEM_overflow_exception),
    .MEM_AdES_exception(MEM_AdES_exception),
    .MEM_AdEF_exception(MEM_AdEF_exception),
    .MEM_slot(MEM_slot)
);

// MEM
MEM_MRcontrol u_MEM_MRcontrol(
    .data_rdata(MEM_in_mem_rdata),
    .data_en(MEM_in_data_sram_en),
    .RFdtl(MEM_in_RFdtl),
	.ea(MEM_in_ALUresult[1:0]),

    .mem_data(MEM_out_mem_rdata),
    .RF_strb(MEM_out_RF_strb),

    .AdEL_exception(MEM_AdEL_exception)
);

MEM_RFcontrol u_MEM_RFcontrol(
    .RFdst(MEM_in_RFdst),
    .RFsrc(MEM_in_RFsrc),

    .mem_data(MEM_out_mem_rdata),
    .alu_result(MEM_in_ALUresult),
    .PC(MEM_in_PC),
    .MD_data(MEM_in_MD_data),
    .cp0_data(MEM_in_cp0_data),
    .exception(MEM_exception),

    .rd(MEM_in_instruction[15:11]),
    .rt(MEM_in_instruction[20:16]),
    //output
    .RF_wdata(MEM_out_RF_wdata),
    .RF_waddr(MEM_out_RF_waddr),
    .RF_wen(MEM_out_RF_wen)
);

// MEM_WB
MEM_WB u_MEM_WB(
    .clk(clk),
    .rst(rst),
    .MEM_stall(MEM_stall),
    .MEM_invalid(MEM_invalid),

    .MEM_out_data_sram_addr(MEM_out_data_sram_addr),
    .MEM_out_RF_wdata(MEM_out_RF_wdata),
    .MEM_out_RF_waddr(MEM_out_RF_waddr),
    .MEM_out_RF_strb(MEM_out_RF_strb),
    .MEM_out_RF_wen(MEM_out_RF_wen),
    .MEM_out_PC(MEM_out_PC),
    .MEM_bad_inst(MEM_bad_inst),
    .MEM_syscall_exception(MEM_syscall_exception),
    .MEM_break_exception(MEM_break_exception),
    .MEM_reserved_exception(MEM_reserved_exception),
    .MEM_overflow_exception(MEM_overflow_exception),
    .MEM_AdES_exception(MEM_AdES_exception),
    .MEM_AdEL_exception(MEM_AdEL_exception),
    .MEM_AdEF_exception(MEM_AdEF_exception),
    .MEM_slot(MEM_slot),

    .WB_in_data_sram_addr(WB_in_data_sram_addr),
    .WB_in_RF_wdata(WB_in_RF_wdata),
    .WB_in_RF_waddr(WB_in_RF_waddr),
    .WB_in_RF_strb(WB_in_RF_strb),
    .WB_in_RF_wen(WB_in_RF_wen),
    .WB_in_PC(WB_in_PC),
    .WB_bad_inst(WB_bad_inst),
    .WB_syscall_exception(WB_syscall_exception),
    .WB_break_exception(WB_break_exception),
    .WB_reserved_exception(WB_reserved_exception),
    .WB_overflow_exception(WB_overflow_exception),
    .WB_AdES_exception(WB_AdES_exception),
    .WB_AdEL_exception(WB_AdEL_exception),
    .WB_AdEF_exception(WB_AdEF_exception),
    .WB_slot(WB_slot)
);

// WB
assign debug_wb_rf_wnum = WB_in_RF_waddr;
assign debug_wb_pc = WB_in_PC;
assign debug_wb_rf_wen = {4{WB_in_RF_wen}};
	
endmodule