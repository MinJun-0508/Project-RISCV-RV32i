`timescale 1ns / 1ps

module data_mem (
    input  logic        clk,
    input  logic        d_wr_en,
    input  logic [ 2:0] funct3,
    input  logic [31:0] dAddr,
    input  logic [31:0] dWdata,
    output logic [31:0] dRdata
);

    logic [31:0] data_mem[0:15];

    initial begin
        for (int i = 0; i < 16; i++) begin
            data_mem[i] = i + 32'h8765_4321;
            //data_mem[2] = 32'b0000_0000_0000_0000_1000_0000_1000_0000; // IL용
        end
    end

    always_ff @(posedge clk) begin
        if (d_wr_en) begin
            case (funct3)
                3'b000:  data_mem[dAddr][7:0] <= {dWdata[7:0]};
                3'b001:  data_mem[dAddr][15:0] <= {dWdata[15:0]};
                3'b010:  data_mem[dAddr] <= dWdata;
                default: data_mem[dAddr] <= dWdata;
            endcase
        end
    end

    // always_ff @(posedge clk) begin
    //     if (d_wr_en) begin
    //         case (funct3)
    //             3'b000: begin
    //                 data_mem[dAddr][7:0] <= {dWdata[7:0]};
    //             end
    //             3'b001: begin
    //                 data_mem[dAddr+1] <= {dWdata[15:8]};
    //                 data_mem[dAddr]   <= {dWdata[7:0]};
    //             end
    //             3'b010: begin
    //                 data_mem[dAddr+3] <= dWdata[31:24];
    //                 data_mem[dAddr+2] <= dWdata[23:16];
    //                 data_mem[dAddr+1] <= dWdata[15:8];
    //                 data_mem[dAddr]   <= dWdata[7:0];
    //             end
    //             default: data_mem[dAddr] <= dWdata;
    //         endcase
    //     end
    // end


    assign dRdata = data_mem[dAddr];
    always_comb begin
        case (funct3)
            3'b000: dRdata = {{24{data_mem[dAddr][7]}}, data_mem[dAddr][7:0]};
            3'b001: dRdata = {{16{data_mem[dAddr][15]}}, data_mem[dAddr][15:0]};
            3'b010: dRdata = data_mem[dAddr];
            3'b100: dRdata = {24'b0, data_mem[dAddr][7:0]};
            3'b101: dRdata = {16'b0, data_mem[dAddr][15:0]};
            default: dRdata = data_mem[dAddr];
        endcase
    end

    
//     always_comb begin
//         case (funct3)
//             3'b000: begin
//                 dRdata[31:24] = {8{data_mem[dAddr][7]}};
//                 dRdata[23:16] = {8{data_mem[dAddr][7]}};
//                 dRdata[15:8]  = {8{data_mem[dAddr][7]}};
//                 dRdata[7:0]   = data_mem[dAddr];
//             end

//             3'b001: begin
//                 dRdata[31:24] = {16{data_mem[dAddr+3][7]}};
//                 dRdata[23:16] = {16{data_mem[dAddr+2][7]}};
//                 dRdata[15:8]  = data_mem[dAddr+1];
//                 dRdata[7:0]   = data_mem[dAddr];
//             end

//             3'b010: begin
//                 dRdata[31:24] = data_mem[dAddr+3];
//                 dRdata[23:16] = data_mem[dAddr+2];
//                 dRdata[15:8]  = data_mem[dAddr+1];
//                 dRdata[7:0]   = data_mem[dAddr];

//             end

//             3'b100: begin
//                 dRdata[31:24] = 8'b0;
//                 dRdata[23:16] = 8'b0;
//                 dRdata[15:8]  = 8'b0;
//                 dRdata[7:0]   = data_mem[dAddr];
//             end
//             3'b101: begin
//                 dRdata[31:24] = 8'b0;
//                 dRdata[23:16] = 8'b0;
//                 dRdata[15:8]  = data_mem[dAddr + 1];
//                 dRdata[7:0]   = data_mem[dAddr];
//             end
//             default: ;
//         endcase
//     end



 endmodule
