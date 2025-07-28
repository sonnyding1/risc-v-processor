module controller(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic rst,
    output logic reg_write_enable,
    output logic mem_write_enable,
    output logic alu_source,
    output logic pc_source,
    output logic [1:0] reg_write_source,
    output logic [1:0] bit_half_word_select,
    output logic is_unsigned,
    output logic [2:0] imm_op,
    output logic [3:0] alu_op
);
    // alu_source:
    //   0: from register
    //   1: from immediate value
    // pc_source:
    //   0: next instruction
    //   1: branch/jump target
    // reg_write_source:
    //   00: ALU result
    //   01: memory read data
    //   10: PC
    // bit_half_word_select (only for memory operations):
    //   00: byte
    //   01: half word
    //   10: word
    // imm_op (only for immediate operations):
    //   000: I type immediate
    //   001: S type immediate
    //   010: B type immediate
    //   011: U type immediate
    //   100: J type immediate
    // alu_op:
    //   0000: ADD
    //   0001: SUB
    //   0010: AND
    //   0011: OR
    //   0100: XOR
    //   0101: SLL
    //   0110: SRL
    //   0111: SRA
    //   1000: SLT
    //   1001: SLTU

    always_comb begin
        if (rst) begin
            reg_write_enable = 0;
            mem_write_enable = 0;
            alu_source = 0;
            pc_source = 0;
            reg_write_source = 2'b00;
            bit_half_word_select = 2'b00; // TODO: it seems bit half word select is not necessary?
            is_unsigned = 0;
            imm_op = 3'b000;
            alu_op = 4'b0000;
        end else begin
            reg_write_enable = 0;
            mem_write_enable = 0; // TODO: are these necessary?

            case (opcode)
                7'b0110011: begin // R type
                    reg_write_enable = 1;
                    mem_write_enable = 0;
                    alu_source = 0;
                    pc_source = 0;
                    reg_write_source = 2'b00;
                    
                    case ({funct7, funct3})
                        {7'b0000000, 3'b000}: alu_op = 4'b0000; // ADD
                        {7'b0100000, 3'b000}: alu_op = 4'b0001; // SUB
                        {7'b0000000, 3'b100}: alu_op = 4'b0100; // XOR
                        {7'b0000000, 3'b110}: alu_op = 4'b0011; // OR
                        {7'b0000000, 3'b111}: alu_op = 4'b0010; // AND
                        {7'b0000000, 3'b001}: alu_op = 4'b0101; // SLL
                        {7'b0000000, 3'b101}: alu_op = 4'b0110; // SRL
                        {7'b0100000, 3'b101}: alu_op = 4'b0111; // SRA
                        {7'b0000000, 3'b010}: alu_op = 4'b1000; // SLT
                        {7'b0000000, 3'b011}: alu_op = 4'b1001; // SLTU
                        default: alu_op = 4'b0000; // TODO: invalid operation
                    endcase
                end
                7'b0010011: begin // I type register
                    reg_write_enable = 1;
                    mem_write_enable = 0;
                    alu_source = 1;
                    pc_source = 0;
                    reg_write_source = 2'b00;
                    imm_op = 3'b000;

                    case ({funct7, funct3})
                        {7'b0000000, 3'b000}: alu_op = 4'b0000; // ADDI
                        {7'b0000000, 3'b100}: alu_op = 4'b0100; // XORI
                        {7'b0000000, 3'b110}: alu_op = 4'b0011; // ORI
                        {7'b0000000, 3'b111}: alu_op = 4'b0010; // ANDI
                        {7'b0000000, 3'b001}: alu_op = 4'b0101; // SLLI
                        {7'b0000000, 3'b101}: alu_op = 4'b0110; // SRLI
                        {7'b0100000, 3'b101}: alu_op = 4'b0111; // SRAI
                        {7'b0100000, 3'b010}: alu_op = 4'b1000; // SLTI
                        {7'b0100000, 3'b011}: alu_op = 4'b1001; // SLTIU
                        default: alu_op = 4'b0000; // TODO: invalid operation
                    endcase
                end
                7'b0000011: begin // I type load
                    reg_write_enable = 1;
                    mem_write_enable = 0;
                    alu_source = 1;
                    pc_source = 0;
                    reg_write_source = 2'b01;
                    imm_op = 3'b000;
                    alu_op = 4'b0000;

                    case (funct3)
                        3'b000: begin // LB
                            bit_half_word_select = 2'b00;
                            is_unsigned = 0;
                        end
                        3'b001: begin // LH
                            bit_half_word_select = 2'b01;
                            is_unsigned = 0;
                        end
                        3'b010: begin // LW
                            bit_half_word_select = 2'b10;
                            is_unsigned = 0;
                        end
                        3'b100: begin // LBU
                            bit_half_word_select = 2'b00;
                            is_unsigned = 1;
                        end
                        3'b101: begin // LHU
                            bit_half_word_select = 2'b01;
                            is_unsigned = 1;
                        end
                        default: begin
                            bit_half_word_select = 2'b00; // TODO: invalid operation
                            is_unsigned = 0;
                        end
                    endcase
                end
                7'b0100011: begin // S type
                    reg_write_enable = 0;
                    mem_write_enable = 1;
                    alu_source = 1;
                    pc_source = 0;
                    imm_op = 3'b001;
                    alu_op = 4'b0000;

                    case (funct3)
                        3'b000: bit_half_word_select = 2'b00; // SB
                        3'b001: bit_half_word_select = 2'b01; // SH
                        3'b010: bit_half_word_select = 2'b10; // SW
                        default: bit_half_word_select = 2'b00; // TODO: invalid operation
                    endcase
                    is_unsigned = 0;
                end
                7'b1100011: begin // B type
                    reg_write_enable = 0;
                    mem_write_enable = 0; // B type instructions do not write to registers or memory
                end
                7'b0110111: begin // U type
                    reg_write_enable = 1;
                    mem_write_enable = 0;
                end
                7'b1101111: begin // J type
                    reg_write_enable = 1;
                    mem_write_enable = 0;
                end
                default: begin
                    reg_write_enable = 0;
                    mem_write_enable = 0;
                end
            endcase
        end
    end
endmodule