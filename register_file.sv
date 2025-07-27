// TODO: add rst to register_file?
module register_file (
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    input logic [4:0] rd_addr,
    input logic [31:0] data_in,
    input logic write_enable,
    input logic clk,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);
    logic [31:0] registers[0:31]; // 32 registers of 32 bits

    typedef enum logic [4:0] { 
        ZERO, RA, SP, GP, TP, T0, T1, T2,
        S0FP, S1, A0, A1, A2, A3, A4, A5,
        A6, A7, S2, S3, S4, S5, S6, S7,
        S8, S9, S10, S11, T3, T4, T5, T6
    } register_alias;

    assign rs1_data = registers[rs1_addr];
    assign rs2_data = registers[rs2_addr];

    always_ff @( posedge clk ) begin
        if (write_enable && rd_addr != ZERO) begin
            registers[rd_addr] <= data_in;
        end
    end

    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'b0;
        end
    end
endmodule