module rv32i_top (
    input logic clk,
    input logic rst,
    input logic [31:0] instruction,
    input logic [31:0] mem_data,
    output logic [31:0] pc,
    output logic [31:0] mem_addr, // TODO: will this cause problem in simulation?
    output logic mem_write_enable,
    output logic [31:0] mem_write_data
);
    logic [31:0] rs1_data, rs2_data, imm, alu_second_input, alu_result, mem_data_processed, reg_write_data, pc_write_data;
    logic reg_write_enable, is_unsigned;
    logic [1:0] alu_source, pc_source, bit_half_word_select, reg_write_source;
    logic [2:0] imm_op;
    logic [3:0] alu_op;

    assign alu_second_input = alu_source ? imm : rs2_data;
    assign mem_addr = alu_result;
    assign mem_write_data = bit_half_word_select[1] ? rs2_data : (
        bit_half_word_select[0] ? 
        {{16{rs2_data[15]}}, rs2_data[15:0]} :
        {{24{rs2_data[7]}}, rs2_data[7:0]}
    );
    assign mem_data_processed = is_unsigned ? (
        bit_half_word_select[0] ? 
        {24'b0, mem_data[7:0]} : 
        {16'b0, mem_data[15:0]}
        ) : (bit_half_word_select[1] ? mem_data : (
        bit_half_word_select[0] ? 
        {{16{mem_data[15]}}, mem_data[15:0]} : 
        {{24{mem_data[7]}}, mem_data[7:0]}
    ));
    assign reg_write_data = (reg_write_source == 2'b00) ? alu_result :
                        (reg_write_source == 2'b01) ? mem_data_processed :
                        (reg_write_source == 2'b10) ? pc + 4 : 32'b0; // TODO: jump logic
    assign pc_write_data = pc_source[1] ? (rs1_data + imm) :
                        pc_source[0] ? 
                        alu_result ? pc + imm : pc + 4
                         : pc + 4; // TODO: syntax here is messy af, consider making into always_comb

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end else begin
            pc <= pc_write_data;
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
        .is_unsigned(is_unsigned),
        .imm_op(imm_op),
        .alu_op(alu_op)
    );
    
    register_file register_file_inst(
        .rs1_addr(instruction[19:15]),
        .rs2_addr(instruction[24:20]),
        .rd_addr(instruction[11:7]),
        .data_in(reg_write_data),
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