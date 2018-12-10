`define INST_R_TYPE  6'b000000
`define INST_REGIMM  6'b000001
`define INST_J       6'b000010
`define INST_JAL     6'b000011
`define INST_BEQ     6'b000100
`define INST_BNE     6'b000101
`define INST_BLEZ    6'b000110
`define INST_BGTZ    6'b000111
`define INST_ADDI    6'b001000
`define INST_ADDIU   6'b001001
`define INST_SLTI    6'b001010
`define INST_SLTIU   6'b001011
`define INST_ANDI    6'b001100
`define INST_ORI     6'b001101
`define INST_XORI    6'b001110
`define INST_LUI     6'b001111
`define INST_COP0    6'b010000

`define INST_LB      6'b100000
`define INST_LH      6'b100001
`define INST_LWL     6'b100010
`define INST_LW      6'b100011
`define INST_LBU     6'b100100
`define INST_LHU     6'b100101
`define INST_LWR     6'b100110

`define INST_SB      6'b101000
`define INST_SH      6'b101001
`define INST_SWL     6'b101010
`define INST_SW      6'b101011

`define INST_SWR     6'b101110

`define R_FUNC_SLL   6'b000000

`define R_FUNC_SRL   6'b000010
`define R_FUNC_SRA   6'b000011
`define R_FUNC_SLLV  6'b000100

`define R_FUNC_SRLV  6'b000110
`define R_FUNC_SRAV  6'b000111
`define R_FUNC_JR    6'b001000
`define R_FUNC_JALR  6'b001001

`define SYSCALL      6'b001100
`define BREAK        6'b001101

`define R_FUNC_MFHI  6'b010000
`define R_FUNC_MTHI  6'b010001
`define R_FUNC_MFLO  6'b010010
`define R_FUNC_MTLO  6'b010011

`define R_FUNC_MULT  6'b011000
`define R_FUNC_MULTU 6'b011001
`define R_FUNC_DIV   6'b011010
`define R_FUNC_DIVU  6'b011011

`define R_FUNC_ADD   6'b100000
`define R_FUNC_ADDU  6'b100001
`define R_FUNC_SUB   6'b100010
`define R_FUNC_SUBU  6'b100011
`define R_FUNC_AND   6'b100100
`define R_FUNC_OR    6'b100101
`define R_FUNC_XOR   6'b100110
`define R_FUNC_NOR   6'b100111

`define R_FUNC_SLT   6'b101010
`define R_FUNC_SLTU  6'b101011

`define REGIMM_BLTZ   5'b00000
`define REGIMM_BGEZ   5'b00001
`define REGIMM_BLTZAL 5'b10000
`define REGIMM_BGEZAL 5'b10001

`define COP0_MF       5'b00000
`define COP0_MT       5'b00100
`define COP0_ERET     6'b011000

`define ALUop_width 13
`define ALUOP_ADD   4'd0
`define ALUOP_SUB   4'd1
`define ALUOP_AND   4'd2
`define ALUOP_OR    4'd3
`define ALUOP_XOR   4'd4
`define ALUOP_NOR   4'd5
`define ALUOP_SLL   4'd6
`define ALUOP_SLT   4'd7
`define ALUOP_SLTU  4'd8
`define ALUOP_SRL   4'd9
`define ALUOP_SRA   4'd10
`define ALUOP_LUI   4'd11
`define ALUOP_ADDU  4'd12
`define ALUOP_SUBU  4'd13

`define PCsrc_width 10
`define PC_from_PCplus    4'd0
`define PC_from_target    4'd1
`define PC_from_reg       4'd2
`define PC_from_beq       4'd3
`define PC_from_bne       4'd4
`define PC_from_bltz      4'd5
`define PC_from_bgez      4'd6
`define PC_from_blez      4'd7
`define PC_from_bgtz      4'd8
`define PC_from_exception 4'd9
`define PC_from_EPC       4'd10

`define RFdst_width 2
`define RF_in_rd 2'd0
`define RF_in_rt 2'd1
`define RF_in_ra 2'd2

`define RFsrc_width     4
`define RF_from_mem     3'd0
`define RF_from_alu     3'd1
`define RF_from_PCplus8 3'd2
`define RF_from_MD      3'd3
`define RF_from_CP0     3'd4

`define RFdtl_width 6
`define RF_dtl_word     3'd0
`define RF_dtl_lwl      3'd1
`define RF_dtl_lwr      3'd2
`define RF_dtl_lb       3'd3
`define RF_dtl_lbu      3'd4
`define RF_dtl_lh       3'd5
`define RF_dtl_lhu      3'd6

`define ALUsrc_width 3
`define ALU_from_rs_rt        2'd0
`define ALU_from_rs_imm       2'd1
`define ALU_from_sa_rt        2'd2
`define ALU_from_rs_signedimm 2'd3

`define MEMdtl_width 4
`define MEM_dtl_word 3'd0
`define MEM_dtl_swl  3'd1
`define MEM_dtl_swr  3'd2
`define MEM_dtl_sb   3'd3
`define MEM_dtl_sh   3'd4

`define BadVAddr 5'd8
`define Count    5'd9
`define Compare  5'd11
`define Status   5'd12
`define Cause    5'd13
`define EPC      5'd14