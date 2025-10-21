`timescale 1ns / 1ps
`include "define.sv"

module control_unit (
    input  logic [31:0] instr_code,
    output logic [ 3:0] alu_controls,
    output logic        aluSrcMuxSel,
    output logic        reg_wr_en,
    output logic [ 2:0] RegWdataSel,
    output logic        d_wr_en,
    output logic        branch,
    output logic        JAL,
    output logic        JAIR
);

    //    rom [0] = 32'h004182B3; //32'b0000_0000_0100_0001_1000_0010_1011_0011; // add x5, x3, x4
    wire  [6:0] funct7 = instr_code[31:25];
    wire  [2:0] funct3 = instr_code[14:12];
    wire  [6:0] opcode = instr_code[6:0];

    logic [8:0] controls;

    assign {RegWdataSel[2],RegWdataSel[1],RegWdataSel[0] , aluSrcMuxSel, reg_wr_en, d_wr_en, branch,JAL,JAIR} = controls;

    always_comb begin
        case (opcode)
            // aluSrcMuxSel, reg_wr_en, d_wr_en
            `OP_R_TYPE:       controls = 9'b000_010000;  // R-type
            `OP_S_TYPE:       controls = 9'b000_101000;  // S-type
            `OP_IL_TYPE:      controls = 9'b001_110000;  // IL-type
            `OP_I_TYPE:       controls = 9'b000_110000;  // I-type
            `OP_B_TYPE:       controls = 9'b000_000100;
            `OP_U_TYPE_LUI:   controls = 9'b010_110000;
            `OP_U_TYPE_AUIPC: controls = 9'b011_110000;
            `OP_JAL_TYPE:     controls = 9'b100_010010;
            `OP_JALR_TYPE:    controls = 9'b100_010011;
            default:          controls = 9'b000000000;
        endcase
    end

    always_comb begin
        case (opcode)
            // {function[6],function[2:0]}
            `OP_R_TYPE:       alu_controls = {funct7[5], funct3};  // R-type
            `OP_S_TYPE:       alu_controls = `ADD;  // S-type
            `OP_IL_TYPE:      alu_controls = `ADD;  // IL-type
            `OP_I_TYPE: begin
                if ({funct7[5], funct3} == 4'b1101)
                    alu_controls = {1'b1, funct3};
                else alu_controls = {1'b0, funct3};
            end
            `OP_B_TYPE:       alu_controls = {1'b0, funct3};
            `OP_U_TYPE_LUI:   alu_controls = 4'b0;
            `OP_U_TYPE_AUIPC: alu_controls = 4'b0;
            `OP_JAL_TYPE:     alu_controls = 4'b0;
            `OP_JALR_TYPE:    alu_controls = 4'b0;
            default:          alu_controls = 4'bx;
        endcase
    end


endmodule
