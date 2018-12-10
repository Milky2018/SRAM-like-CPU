`timescale 10 ns / 1 ns

`include "mycpu.h"

module ID_Control(
	input  [31:0] instruction,

	output [3 :0] ALUsrc,
	output [13:0] ALUop,
	output [7 :0] MDop,

	output [10 :0] PCsrc,

	output [2 :0] RFdst,
	output [4 :0] RFsrc,
	output [6 :0] RFdtl,

	output        cp0wen,

	output        syscall_exception,
	output        break_exception,
	output        reserved_exception,

	output        eret,

	output        data_en,
	output [4 :0] data_dtl
);
	wire [5:0] op   = instruction[31:26];
	wire [4:0] rs   = instruction[25:21];
	wire [4:0] rt   = instruction[20:16];
	wire [4:0] rd   = instruction[15:11];
	wire [4:0] sa   = instruction[10:6];
	wire [5:0] func = instruction[5:0];
	wire [2:0] sel  = instruction[2:0];
	wire [7:0] undf = instruction[10:3];

	wire inst_sll    = (op == `INST_R_TYPE) && (func == `R_FUNC_SLL)  && (rs == 5'b00000);
	wire inst_srl    = (op == `INST_R_TYPE) && (func == `R_FUNC_SRL)  && (rs == 5'b00000);
	wire inst_sra    = (op == `INST_R_TYPE) && (func == `R_FUNC_SRA)  && (rs == 5'b00000);
	wire inst_jr     = (op == `INST_R_TYPE) && (func == `R_FUNC_JR)   && (rt == 5'b00000) && (rd == 5'b00000);
	wire inst_jalr   = (op == `INST_R_TYPE) && (func == `R_FUNC_JALR) && (rt == 5'b00000);
	wire inst_addu   = (op == `INST_R_TYPE) && (func == `R_FUNC_ADDU) && (sa == 5'b00000);
	wire inst_subu   = (op == `INST_R_TYPE) && (func == `R_FUNC_SUBU) && (sa == 5'b00000);
	wire inst_and    = (op == `INST_R_TYPE) && (func == `R_FUNC_AND)  && (sa == 5'b00000);
	wire inst_or     = (op == `INST_R_TYPE) && (func == `R_FUNC_OR)   && (sa == 5'b00000);
	wire inst_xor    = (op == `INST_R_TYPE) && (func == `R_FUNC_XOR)  && (sa == 5'b00000);
	wire inst_nor    = (op == `INST_R_TYPE) && (func == `R_FUNC_NOR)  && (sa == 5'b00000);
	wire inst_slt    = (op == `INST_R_TYPE) && (func == `R_FUNC_SLT)  && (sa == 5'b00000);
	wire inst_sltu   = (op == `INST_R_TYPE) && (func == `R_FUNC_SLTU) && (sa == 5'b00000);
	wire inst_add    = (op == `INST_R_TYPE) && (func == `R_FUNC_ADD)  && (sa == 5'b00000);
	wire inst_sub    = (op == `INST_R_TYPE) && (func == `R_FUNC_SUB)  && (sa == 5'b00000);
	wire inst_sllv   = (op == `INST_R_TYPE) && (func == `R_FUNC_SLLV) && (sa == 5'b00000);
	wire inst_srav   = (op == `INST_R_TYPE) && (func == `R_FUNC_SRAV) && (sa == 5'b00000);
	wire inst_srlv   = (op == `INST_R_TYPE) && (func == `R_FUNC_SRLV) && (sa == 5'b00000);
	wire inst_div    = (op == `INST_R_TYPE) && (func == `R_FUNC_DIV)  && (rd == 5'b00000) && (sa == 5'b00000);
	wire inst_divu   = (op == `INST_R_TYPE) && (func == `R_FUNC_DIVU) && (rd == 5'b00000) && (sa == 5'b00000);
	wire inst_mult   = (op == `INST_R_TYPE) && (func == `R_FUNC_MULT) && (rd == 5'b00000) && (sa == 5'b00000);
	wire inst_multu  = (op == `INST_R_TYPE) && (func == `R_FUNC_MULTU)&& (rd == 5'b00000) && (sa == 5'b00000);
	wire inst_mfhi   = (op == `INST_R_TYPE) && (func == `R_FUNC_MFHI) && (rs == 5'b00000) && (rt == 5'b00000) && (sa == 5'b00000);
	wire inst_mflo   = (op == `INST_R_TYPE) && (func == `R_FUNC_MFLO) && (rs == 5'b00000) && (rt == 5'b00000) && (sa == 5'b00000);
	wire inst_mthi   = (op == `INST_R_TYPE) && (func == `R_FUNC_MTHI) && (rt == 5'b00000) && (rd == 5'b00000) && (sa == 5'b00000);
	wire inst_mtlo   = (op == `INST_R_TYPE) && (func == `R_FUNC_MTLO) && (rt == 5'b00000) && (rd == 5'b00000) && (sa == 5'b00000);
	wire inst_syscall= (op == `INST_R_TYPE) && (func == `SYSCALL);
	wire inst_break  = (op == `INST_R_TYPE) && (func == `BREAK);
	wire inst_j      =  op == `INST_J;
	wire inst_jal    =  op == `INST_JAL;
	wire inst_addiu  =  op == `INST_ADDIU;
	wire inst_lui    =  op == `INST_LUI && (rs == 5'b00000);
	wire inst_lw     =  op == `INST_LW;
	wire inst_lwl    =  op == `INST_LWL;
	wire inst_lwr    =  op == `INST_LWR;
	wire inst_lb     =  op == `INST_LB;
	wire inst_lbu    =  op == `INST_LBU;
	wire inst_lh     =  op == `INST_LH;
	wire inst_lhu    =  op == `INST_LHU;
	wire inst_sw     =  op == `INST_SW;
	wire inst_swl    =  op == `INST_SWL;
	wire inst_swr    =  op == `INST_SWR;
	wire inst_sb     =  op == `INST_SB;
	wire inst_sh     =  op == `INST_SH;
	wire inst_addi   =  op == `INST_ADDI;
	wire inst_slti   =  op == `INST_SLTI;
	wire inst_sltiu  =  op == `INST_SLTIU;
	wire inst_andi   =  op == `INST_ANDI;
	wire inst_ori    =  op == `INST_ORI;
	wire inst_xori   =  op == `INST_XORI;
	wire inst_beq    =  op == `INST_BEQ;
	wire inst_bne    =  op == `INST_BNE;
	wire inst_blez   = (op == `INST_BLEZ) && (rt == 5'b00000);
	wire inst_bgtz   = (op == `INST_BGTZ) && (rt == 5'b00000);
	wire inst_bltz   = (op == `INST_REGIMM) && (rt == `REGIMM_BLTZ);
	wire inst_bgez   = (op == `INST_REGIMM) && (rt == `REGIMM_BGEZ);
	wire inst_bltzal = (op == `INST_REGIMM) && (rt == `REGIMM_BLTZAL);
	wire inst_bgezal = (op == `INST_REGIMM) && (rt == `REGIMM_BGEZAL);
	wire inst_mfc0   = (op == `INST_COP0) && (rs == `COP0_MF) && (undf == 8'b00000000);
	wire inst_mtc0   = (op == `INST_COP0) && (rs == `COP0_MT) && (undf == 8'b00000000);
	wire inst_eret   = (op == `INST_COP0) && (instruction[25:6] == 20'h80000) && (func == 6'b011000);

	// To ALUcontrol
	wire ALU_nop = inst_jr   | inst_jal | inst_beq    | inst_bne    | inst_div | inst_divu | inst_mult | inst_multu |
				   inst_mfhi | inst_mflo| inst_mthi   | inst_mtlo   | inst_j   | inst_jalr | inst_blez | inst_bgtz  |
				   inst_bltz | inst_bgez| inst_bltzal | inst_bgezal | inst_mfc0| inst_mtc0 | inst_syscall           | 
				   inst_break| inst_eret;

	assign ALUsrc[`ALU_from_rs_rt]        = inst_sltu | inst_addu |
							     			inst_subu | inst_and  |
							     			inst_or   | inst_xor  |
							     			inst_nor  | inst_slt  |
							     			inst_add  | inst_sub  |
							     			inst_sllv | inst_srav |
							     			inst_srlv;
	assign ALUsrc[`ALU_from_rs_imm]       = inst_lui  | inst_andi |
											inst_ori  | inst_xori;
	assign ALUsrc[`ALU_from_sa_rt] 	      = inst_sll  | inst_srl  |
						         			inst_sra;
	assign ALUsrc[`ALU_from_rs_signedimm] = inst_addiu| inst_lw   |
	                             			inst_sw   | inst_addi |
	                             			inst_slti | inst_sltiu|
											inst_lwl  | inst_lwr  |
											inst_lb   | inst_lbu  |
											inst_lh   | inst_lhu  |
											inst_swl  | inst_swr  |
											inst_sb   | inst_sh;        

	assign ALUop[`ALUOP_ADD ] = inst_add | inst_addi;
	assign ALUop[`ALUOP_SUB ] = inst_sub;
	assign ALUop[`ALUOP_AND ] = inst_and  | inst_andi;
	assign ALUop[`ALUOP_OR  ] = inst_or   | inst_ori;
	assign ALUop[`ALUOP_XOR ] = inst_xor  | inst_xori;
	assign ALUop[`ALUOP_NOR ] = inst_nor;
	assign ALUop[`ALUOP_SLL ] = inst_sll  | inst_sllv;
	assign ALUop[`ALUOP_SLT ] = inst_slt  | inst_slti;
	assign ALUop[`ALUOP_SLTU] = inst_sltu | inst_sltiu;
	assign ALUop[`ALUOP_SRL ] = inst_srl  | inst_srlv;
	assign ALUop[`ALUOP_SRA ] = inst_sra  | inst_srav;
	assign ALUop[`ALUOP_LUI ] = inst_lui;
	assign ALUop[`ALUOP_ADDU] = inst_addiu| inst_addu | inst_lw | inst_sw  | 
								inst_lwl  | inst_lwr  | inst_lb | inst_lbu | inst_lh  | inst_lhu  |
								inst_swl  | inst_swr  | inst_sb | inst_sh;
	assign ALUop[`ALUOP_SUBU] = inst_subu;

	// To MulDiv
	assign MDop = {inst_div, inst_divu, inst_mult, inst_multu, inst_mfhi, inst_mflo, inst_mthi, inst_mtlo};

	// To PCcontrol
	assign PCsrc[`PC_from_PCplus]    = ~(PCsrc[`PC_from_target] | PCsrc[`PC_from_reg]  | PCsrc[`PC_from_beq]       |
								  	     PCsrc[`PC_from_bne]    | PCsrc[`PC_from_bltz] | PCsrc[`PC_from_bgez]      |
									     PCsrc[`PC_from_blez]   | PCsrc[`PC_from_bgtz]| PCsrc[`PC_from_exception] |
										 PCsrc[`PC_from_EPC]);
	assign PCsrc[`PC_from_target]    = inst_jal | inst_j;
	assign PCsrc[`PC_from_reg]       = inst_jr  | inst_jalr;
	assign PCsrc[`PC_from_beq]       = inst_beq;
	assign PCsrc[`PC_from_bne]       = inst_bne;
	assign PCsrc[`PC_from_bltz]      = inst_bltz | inst_bltzal;
	assign PCsrc[`PC_from_bgez]      = inst_bgez | inst_bgezal;
	assign PCsrc[`PC_from_blez]      = inst_blez;
	assign PCsrc[`PC_from_bgtz]      = inst_bgtz;
	// assign PCsrc[`PC_from_exception] = inst_syscall;
	assign PCsrc[`PC_from_exception] = 1'b0;
	assign PCsrc[`PC_from_EPC]       = inst_eret;

	// To RFcontrol
	wire RF_nop = inst_sw | inst_jr   | inst_div  | inst_divu | inst_mult | inst_multu | inst_mthi | inst_mtlo |
				  inst_j  | inst_bltz | inst_bgez | inst_blez | inst_bgez | inst_swl   | inst_swr  | inst_sb   |
				  inst_sh | inst_mtc0 | inst_eret | inst_syscall          | inst_break;

	assign RFdst[`RF_in_rd] = inst_sll | inst_srl  | inst_sra  | inst_addu | inst_subu | inst_and | inst_or  |
						      inst_xor | inst_nor  | inst_slt  | inst_sltu | inst_add  | inst_sub | inst_sllv|
						      inst_srav| inst_srlv | inst_mfhi | inst_mflo | inst_jalr;
	assign RFdst[`RF_in_rt] = inst_lw  | inst_lui  | inst_addiu| inst_addi | inst_slti |inst_sltiu| inst_andi|
						      inst_ori | inst_xori | inst_lwl  | inst_lwr  | inst_lb   | inst_lbu | inst_lh  |
							  inst_lhu | inst_mfc0;
	assign RFdst[`RF_in_ra] = inst_jal |inst_bltzal|inst_bgezal;

	assign RFsrc[`RF_from_mem]     = inst_lw  | inst_lwl | inst_lwr   | inst_lb    | inst_lbu  | inst_lh  | inst_lhu;
	assign RFsrc[`RF_from_alu]     = inst_sll | inst_srl | inst_sra   | inst_addu  | inst_subu | inst_and | inst_or  |
						             inst_xor | inst_nor | inst_slt   | inst_sltu  | inst_addiu| inst_lui | inst_add |
						             inst_addi| inst_sub | inst_slti  | inst_sltiu | inst_andi | inst_ori | inst_xori|
						             inst_sllv| inst_srav| inst_srlv;
	assign RFsrc[`RF_from_PCplus8] = inst_jal | inst_jalr| inst_bltzal| inst_bgezal;
	assign RFsrc[`RF_from_MD]      = inst_mfhi| inst_mflo;
	assign RFsrc[`RF_from_CP0]     = inst_mfc0;

	assign RFdtl[`RF_dtl_lwl]  = inst_lwl;
	assign RFdtl[`RF_dtl_lwr]  = inst_lwr;
	assign RFdtl[`RF_dtl_lb]   = inst_lb;
	assign RFdtl[`RF_dtl_lbu]  = inst_lbu; 
	assign RFdtl[`RF_dtl_lh]   = inst_lh; 
	assign RFdtl[`RF_dtl_lhu]  = inst_lhu; 
	assign RFdtl[`RF_dtl_word] = inst_sll    | inst_srl  | inst_sra   | inst_addu  | inst_subu | inst_and | inst_or     |
						         inst_xor    | inst_nor  | inst_slt   | inst_sltu  | inst_addiu| inst_lui | inst_add    |
						         inst_addi   | inst_sub  | inst_slti  | inst_sltiu | inst_andi | inst_ori | inst_xori   |
						         inst_sllv   | inst_srav | inst_srlv  | inst_lw    | inst_jal  | inst_jalr| inst_bltzal |
								 inst_bgezal | inst_mfhi | inst_mflo  | inst_mfc0;

	// To cp0
	assign cp0wen = inst_mtc0;

	assign syscall_exception = inst_syscall;
	assign break_exception = inst_break;
	assign reserved_exception = ~(ALU_nop | (|ALUsrc));
	assign eret = inst_eret;

	// To MWcontrol
	assign data_en = inst_sw | inst_lw | inst_lwl | inst_lwr | inst_lb | inst_lbu |
	                 inst_lh | inst_lhu| inst_swl | inst_swr | inst_sb | inst_sh;
	assign data_dtl[`MEM_dtl_word] = inst_sw;
	assign data_dtl[`MEM_dtl_swl]  = inst_swl;
	assign data_dtl[`MEM_dtl_swr]  = inst_swr;
	assign data_dtl[`MEM_dtl_sb]   = inst_sb;
	assign data_dtl[`MEM_dtl_sh]   = inst_sh;

endmodule