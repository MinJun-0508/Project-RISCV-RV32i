`timescale 1ns / 1ps

`include "define.sv"

module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [ 3:0] alu_controls,
    input  logic        reg_wr_en,
    input  logic        aluSrcMuxSel,
    input  logic [ 2:0] RegWdataSel,
    input  logic        branch,
    input  logic        JAL,
    input  logic        JAIR,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [31:0] w_regfile_rd1, w_regfile_rd2, w_alu_result;
    logic [31:0] w_RegWdataOut;
    logic [31:0]
        w_imm_Ext, w_aluSrcMux_out, w_pc_MuxOut, w_pc_next, w_pc_rd_muxout;
    logic branch_btaken_out, btaken, pc_mux_sel;
    logic [31:0] w_pc_ext_adder_out, w_pc_adder_out;
    logic [31:0] w_imm_adder_out;


    assign branch_btaken_out = branch & btaken;
    assign pc_mux_sel = branch_btaken_out | JAL;


    mux_2x1 U_RD_PC_MUX (
        .sel(JAIR),
        .x0 (instr_rAddr),    // 0 : 4
        .x1 (w_regfile_rd1),  // 1 : imm_Ext
        .y  (w_pc_rd_muxout)
    );


    mux_2x1 U_PC_MUX (
        .sel(pc_mux_sel),
        .x0 (w_pc_adder_out),   // 0 : 4
        .x1 (w_imm_adder_out),  // 1 : imm_Ext
        .y  (w_pc_MuxOut)
    );

    pc_adder U_IMM_ADDER (
        .a  (w_imm_Ext),
        .b  (w_pc_rd_muxout),
        .sum(w_imm_adder_out)
    );

    pc_adder U_PC_ADDER (
        .a  (instr_rAddr),
        .b  (32'd4),
        .sum(w_pc_adder_out)
    );

    program_counter U_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_Next(w_pc_MuxOut),
        .pc     (instr_rAddr)
    );

    register_file U_REG_FILE (
        .clk      (clk),
        .RA1      (instr_code[19:15]),  // read address 1
        .RA2      (instr_code[24:20]),  // read address 2
        .WA       (instr_code[11:7]),   // write address
        .reg_wr_en(reg_wr_en),          // write enable
        .WData    (w_RegWdataOut),      // write data
        .RD1      (w_regfile_rd1),      // read data 1
        .RD2      (w_regfile_rd2)       // read data 2
    );


    assign dAddr  = w_alu_result;
    assign dWdata = w_regfile_rd2;

    ALU U_ALU (
        .a           (w_regfile_rd1),
        .b           (w_aluSrcMux_out),
        .alu_controls(alu_controls),
        .alu_result  (w_alu_result),
        .btaken      (btaken)
    );

    // mux_2x1 U_REGWdataMux (
    //     .sel(RegWdataSel),
    //     .x0 (w_alu_result),  // 0 : regfile R2
    //     .x1 (dRdata),        // 1 : imm [31:0]
    //     .y  (w_RegWdataOut)  // to ARU
    // );

    mux_5x1 U_ALU_REG_EXT_MUX (
        .sel(RegWdataSel),
        .x0(w_alu_result),   // 0 : ALU
        .x1(dRdata),   // 1 : dRdata
        .x2(w_imm_Ext),   // 2 : imm
        .x3(w_imm_adder_out),   // 3 : PC + imm
        .x4(w_pc_adder_out),
        .y(w_RegWdataOut)     // to ARU
    );


    mux_2x1 U_AluSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (w_regfile_rd2),
        .x1 (w_imm_Ext),
        .y  (w_aluSrcMux_out)
    );

    extend U_Extend (
        .instr_code(instr_code),
        .imm_Ext(w_imm_Ext)
    );

    // pc_adder U_PC_EXTEND_ADDER (
    //     .a  (instr_rAddr),
    //     .b  (w_imm_Ext),
    //     .sum(w_pc_ext_adder_out)
    // );

endmodule

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_Next,
    output logic [31:0] pc
);
    register U_PC_REG (
        .clk  (clk),
        .reset(reset),
        .d    (pc_Next),
        .q    (pc)
    );
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

module register_file (
    input  logic        clk,
    input  logic [ 4:0] RA1,        // read address 1
    input  logic [ 4:0] RA2,        // read address 2
    input  logic [ 4:0] WA,         // write address
    input  logic        reg_wr_en,  // write enable
    input  logic [31:0] WData,      // write data
    output logic [31:0] RD1,        // read data 1
    output logic [31:0] RD2         // read data 2
);

    logic [31:0] reg_file[0:31];  // 32bit 32개.

    initial begin
        for (int i = 0; i < 32; i++) begin
            reg_file[i] = i;
            //reg_file[4] = 32'b1111_1111_1111_1111_1111_1111_1111_1111; // R타입 전용
            reg_file[2] = 32'h87654321; //S타입 전용
            reg_file[3] = 32'b1111_0000_0000_0000_0000_0000_0000_0000;//L타입 전용
        end
    end

    always_ff @(posedge clk) begin
        if (reg_wr_en) begin
            reg_file[WA] <= WData;
        end
    end

    assign RD1 = (RA1 != 0) ? reg_file[RA1] : 0;
    assign RD2 = (RA2 != 0) ? reg_file[RA2] : 0;

endmodule

module ALU (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_controls,
    output logic [31:0] alu_result,
    output logic btaken
);


    always_comb begin
        case (alu_controls)
            `ADD: alu_result = a + b;
            `SUB: alu_result = a - b;
            `SLL: alu_result = a << b[4:0];
            `SRL: alu_result = a >> b[4:0];  // 0 으로 extended
            `SRA:
            alu_result = $signed(a) >>> b[4:0];  // [31] extneded by singed bit
            `SLT: alu_result = $signed(a) < $signed(b) ? 1 : 32'h0;
            `SLTU: alu_result = a < b ? 1 : 0;
            `XOR: alu_result = a ^ b;
            `AND: alu_result = a & b;
            `OR: alu_result = a | b;
            default: alu_result = 32'bx;
        endcase
    end

    // branch

    always_comb begin
        case (alu_controls[2:0])
            `BEQ: btaken = ($signed(a) == $signed(b));
            `BNE: btaken = ($signed(a) != $signed(b));
            `BLT: btaken = ($signed(a) < $signed(b));
            `BGE: btaken = ($signed(a) >= $signed(b));
            `BLTU: btaken = ($unsigned(a) < $unsigned(b));
            `BGEU: btaken = ($unsigned(a) >= $unsigned(b));
            default: btaken = 1'b0;
        endcase
    end


endmodule

module extend (
    input  logic [31:0] instr_code,
    output logic [31:0] imm_Ext
);

    wire [6:0] opcode = instr_code[6:0];
    wire [2:0] funct3 = instr_code[14:12];
    wire funct7 = instr_code[30];

    always_comb begin
        case (opcode)
            `OP_R_TYPE: imm_Ext = 32'bx;
            // 20 literal 1'b0, imm[11:5] 7bits, imm[4:0] 5bits
            `OP_S_TYPE:
            imm_Ext = {
                {20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]
            };
            `OP_IL_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            `OP_I_TYPE:
             imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};


            `OP_B_TYPE:
            imm_Ext = {
                {19{instr_code[31]}},
                instr_code[7],
                instr_code[30:25],
                instr_code[11:8],
                1'b0
            };
            `OP_U_TYPE_LUI: imm_Ext = {instr_code[31:12], 12'b0};
            `OP_U_TYPE_AUIPC: imm_Ext = {instr_code[31:12], 12'b0};
            `OP_JAL_TYPE:
            imm_Ext = {
                {11{instr_code[31]}},
                instr_code[31],
                instr_code[19:12],
                instr_code[20],
                instr_code[30:21],
                1'b0
            };
            `OP_JALR_TYPE: imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            default: imm_Ext = 32'bx;
        endcase
    end

endmodule

module mux_2x1 (
    input               sel,
    input  logic [31:0] x0,   // 0 : regfile R2
    input  logic [31:0] x1,   // 1 : imm [31:0]
    output logic [31:0] y     // to ARU
);

    assign y = sel ? x1 : x0;

endmodule

module pc_adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);

    assign sum = a + b;

endmodule

module mux_5x1 (
    input        [ 2:0] sel,
    input  logic [31:0] x0,   // 0 : ALU
    input  logic [31:0] x1,   // 1 : dRdata
    input  logic [31:0] x2,   // 2 : imm
    input  logic [31:0] x3,   // 3 : PC + imm
    input  logic [31:0] x4,   // jal,jarl
    output logic [31:0] y     // to ARU
);

    always_comb begin
        case (sel)
            3'b000:  y = x0;
            3'b001:  y = x1;
            3'b010:  y = x2;
            3'b011:  y = x3;
            3'b100:  y = x4;
            default: y = x0;
        endcase
    end
endmodule
