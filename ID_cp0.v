`include "mycpu.h"

module ID_cp0(
    input         clk,
    input         rst,

    input  [4 :0] raddr,
    input         wen,
    input  [4 :0] waddr,
    input  [31:0] wdata,

    // input  [31:0] IF_PC,
    input  [31:0] ID_PC,
    // input  [31:0] EX_PC,
    // input  [31:0] MEM_PC,
    input  [31:0] WB_PC,
    input         ID_slot,
    input         WB_slot,

    input  [31:0] data_addr,
    input  [31:0] bad_inst_addr,

    input         IF_AdEF_exception,
    input         ID_syscall_exception,
    input         ID_break_exception,
    input         ID_reserved_exception,
    input         EX_overflow_exception,
    input         EX_AdES_exception,
    input         MEM_AdEL_exception,

    input         ID_eret,

    output [31:0] rdata,
    output [31:0] EPC_data,
    output        exception,
    output        interrupt
);

    wire Bev = 1'b1;
    reg [7:0] IM;
    reg Exl;
    reg IE;

    reg BD;
    reg TI;
    reg [7:0] IP;
    reg [4:0] ExcCode;

    reg [31:0] EPC;
    assign EPC_data = EPC;

    reg [31:0] BadVAddr;
    reg [31:0] Count;
    reg        Count_half;
    reg [31:0] Compare;
    wire       clock_int;
    wire       soft_int0;
    wire       soft_int1;

    assign interrupt = clock_int | soft_int0 | soft_int1;
    assign clock_int = IE & ~Exl & IM[7] & Count === Compare;
    assign soft_int0 = IE & ~Exl & IM[0] & IP[0];
    assign soft_int1 = IE & ~Exl & IM[1] & IP[1];

    wire bypass;
    wire [31:0] r [31:0];

    wire IF_exception = IF_AdEF_exception;
    wire ID_exception = ID_syscall_exception | ID_break_exception | ID_reserved_exception;
    wire EX_excetion = EX_overflow_exception | EX_AdES_exception;
    wire MEM_exception = MEM_AdEL_exception;

    assign exception = IF_exception | ID_exception | EX_excetion | MEM_exception |
                       interrupt;

    // BadVAddr 8
    wire [31:0] EX_data_addr = data_addr;
    wire [31:0] MEM_data_addr = data_addr;
    always @(posedge clk) begin
        if (rst)
            BadVAddr <= 32'hbfc00000;
        else if (IF_AdEF_exception)
            BadVAddr <= bad_inst_addr;
        else if (EX_AdES_exception)
            BadVAddr <= EX_data_addr;
        else if (MEM_AdEL_exception)
            BadVAddr <= MEM_data_addr;
    end

    assign r[`BadVAddr] = BadVAddr;

    // Count 9
    always @(posedge clk) begin
        if (rst)
            {Count, Count_half} <= 33'd0;
        else if (wen == 1'b1 && waddr == `Count)
            {Count, Count_half} <= {wdata, 1'b0};
        else
            {Count, Count_half} <= {Count, Count_half} + 33'd1;
    end

    assign r[`Count] = Count;

    // Compare 11
    always @(posedge clk) begin
        if (rst)
            Compare <= 32'd0;
        else if (wen == 1'b1 && waddr == `Compare)
            Compare <= wdata;
    end

    // Status 12
    always @(posedge clk) begin
        if (rst)
            IM <= 8'b0;
        else if (wen == 1'b1 && waddr == `Status)
            IM <= wdata[15:8];
    end

    always @(posedge clk) begin
        if (rst)
            Exl <= 1'b0;
        else if (exception)
            Exl <= 1'b1;
        else if (ID_eret)
            Exl <= 1'b0;
        else if (wen == 1'b1 && waddr == `Status)
            Exl <= wdata[1];
    end

    always @(posedge clk) begin
        if (rst)
            IE <= 1'b0;
        else if (wen == 1'b1 && waddr == `Status)
            IE <= wdata[0];
    end

    assign r[`Status] = {9'd0, Bev, 6'd0, IM, 6'd0, Exl, IE};

    // Cause 13
    always @(posedge clk) begin
        if (rst)
            BD <= 1'b0;
        else if (Exl)
            ;
        else if (IF_AdEF_exception)
            BD <= 1'b0;
        else if (exception)
            BD <= WB_slot ? 1'b1 : 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            TI <= 1'b0;
        else if (clock_int)
            TI <= 1'b1;
        else if (wen == 1'b1 && waddr == `Compare)
            TI <= 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            IP[0] <= 1'b0;
        else if (wen == 1'b1 && waddr == `Cause)
            IP[0] <= wdata[8];
    end

    always @(posedge clk) begin
        if (rst)
            IP[1] <= 1'b0;
        else if (wen == 1'b1 && waddr == `Cause)
            IP[1] <= wdata[9];
    end

    always @(posedge clk) begin
        if (rst)
            IP[7] <= 1'b0;
        else 
            IP[7] <= clock_int;
    end

    always @(posedge clk) begin
        if (rst)
            IP[2] <= 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            IP[3] <= 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            IP[4] <= 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            IP[5] <= 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            IP[6] <= 1'b0;
    end

    always @(posedge clk) begin
        if (rst)
            ExcCode <= 5'd0;
        else if (interrupt)
            ExcCode <= 5'h0;
        else if (IF_AdEF_exception)
            ExcCode <= 5'h4;
        else if (ID_reserved_exception)
            ExcCode <= 5'ha;
        else if (ID_syscall_exception)
            ExcCode <= 5'h8;
        else if (ID_break_exception)
            ExcCode <= 5'h9;
        else if (EX_AdES_exception)
            ExcCode <= 5'h5;
        else if (EX_overflow_exception)
            ExcCode <= 5'hc;
        else if (MEM_AdEL_exception)
            ExcCode <= 5'h4;
    end

    assign r[`Cause] = {BD, TI, 14'd0, IP, 1'b0, ExcCode, 2'b00};

    // EPC 14
    always @(posedge clk) begin
        if (rst)
            EPC <= 32'hbfc00000;
        else if (interrupt)
            EPC <= ID_slot ? ID_PC - 32'd4 : ID_PC;
        else if (~Exl & IF_AdEF_exception)
            EPC <= bad_inst_addr;
        else if (~Exl & exception)
            EPC <= WB_slot ? WB_PC - 32'd4 : WB_PC;
        else if (wen == 1'b1 && waddr == `EPC)
            EPC <= wdata;
    end

    assign r[`EPC] = EPC;

    // all in all
    assign bypass = wen & (waddr == raddr);

    assign rdata = bypass ? wdata : r[raddr];

endmodule