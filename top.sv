module rv32i_top (
    input logic clk,
    input logic rst,
    input logic [31:0] instruction,
    output logic [7:0] pc
);
    logic [31:0] rs1_data, rs2_data, imm, alu_second_input, alu_result;
    logic reg_write_enable, mem_write_enable, alu_source, pc_source;
    logic [1:0] reg_write_source, bit_half_word_select;
    logic [2:0] imm_op;
    logic [3:0] alu_op;

    assign alu_second_input = alu_source ? imm : rs2_data;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 8'h00;
        end else begin
            pc <= pc + 4;
            // TODO: add jump/branch logic
        end
    end

    controller controller_inst(
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .rst(rst),
        .reg_write_enable(reg_write_enable),
        .mem_write_enable(mem_write_enable),
        .alu_source(alu_source),
        .pc_source(pc_source),
        .reg_write_source(reg_write_source),
        .bit_half_word_select(bit_half_word_select),
        .imm_op(imm_op),
        .alu_op(alu_op)
    );
    
    register_file register_file_inst(
        .rs1_addr(instruction[19:15]),
        .rs2_addr(instruction[24:20]),
        .rd_addr(instruction[11:7]),
        .data_in(alu_result), // TODO: add mux
        .write_enable(reg_write_enable),
        .clk(clk),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    alu alu_inst(
        .a(rs1_data),
        .b(alu_second_input),
        .alu_op(alu_op),
        .result(alu_result)
    );

    imm_manager imm_manager_inst(
        .instruction(instruction),
        .imm_op(imm_op),
        .imm(imm)
    );
endmodule