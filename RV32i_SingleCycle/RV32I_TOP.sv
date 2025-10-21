`timescale 1ns / 1ps
module RV32I_TOP (
    input logic clk,
    input logic reset
);
    logic [31:0] instr_code, instr_rAddr;
    logic [31:0] dAddr, dWdata;
    logic d_wr_en;
    logic [2:0] RegWdataSel;
    logic RegWdataOut;
    logic [31:0] dRdata;


    RVI32I_Core U_RVI32I_CPU (
        .*,
        .dRdata(dRdata)
    );

    instr_mem U_Instr_Mem (.*);

    data_mem U_Data_Mem (
        .clk(clk),
        .d_wr_en(d_wr_en),
        .dAddr(dAddr),
        .dWdata(dWdata),
        .funct3(instr_code[14:12]),
        .dRdata(dRdata)
    );

endmodule

module RVI32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    output logic [31:0] instr_rAddr,
    output logic        d_wr_en,
    output logic [31:0] dRdata,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [3:0] alu_controls;
    logic reg_wr_en, w_aluSrcMuxSel;
    logic [2:0] w_RegWdataSel;
    logic branch;
    logic JAIR, JAL;

    control_unit U_Control_unit (
        .instr_code  (instr_code),
        .alu_controls(alu_controls),
        .aluSrcMuxSel(w_aluSrcMuxSel),
        .reg_wr_en   (reg_wr_en),
        .d_wr_en     (d_wr_en),
        .RegWdataSel (w_RegWdataSel),
        .branch      (branch),
        .JAIR        (JAIR),
        .JAL         (JAL)
    );
    datapath U_Data_Path (
        .clk         (clk),
        .reset       (reset),
        .instr_code  (instr_code),
        .alu_controls(alu_controls),
        .reg_wr_en   (reg_wr_en),
        .aluSrcMuxSel(w_aluSrcMuxSel),
        .RegWdataSel (w_RegWdataSel),
        .dRdata      (dRdata),
        .instr_rAddr (instr_rAddr),
        .dAddr       (dAddr),
        .dWdata      (dWdata),
        .branch      (branch),
        .JAIR        (JAIR),
        .JAL         (JAL)
    );

endmodule
