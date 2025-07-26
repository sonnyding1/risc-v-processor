module controller(
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic clk,
    output logic reg_write_enable,
    output logic mem_write_enable,
    output logic alu_source,
    output logic pc_source,
    output logic [1:0] reg_write_source,
    output logic [1:0] bit_half_word_select,
    output logic [2:0] imm_op,
    output logic [3:0] alu_op,
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
    //   01: half-word
    //   10: word
    // imm_op (only for immediate operations):
    //   000: I-type immediate
    //   001: S-type immediate
    //   010: B-type immediate
    //   011: U-type immediate
    //   100: J-type immediate
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

    typedef enum logic [6:0] {
        R_TYPE = 7'b0110011,
        I_TYPE = 7'b0010011,
        S_TYPE = 7'b0100011,
        B_TYPE = 7'b1100011,
        U_TYPE = 7'b0110111,
        J_TYPE = 7'b1101111,
    } opcode_type;

    typedef enum logic [9:0] {
        ADD  = {7'b0000000, 3'b000},
        SUB  = {7'b0100000, 3'b000},
        XOR  = {7'b0000000, 3'b100},
        OR   = {7'b0000000, 3'b110},
        AND  = {7'b0000000, 3'b111},
        SLL  = {7'b0000000, 3'b001},
        SRL  = {7'b0000000, 3'b101},
        SRA  = {7'b0100000, 3'b101},
        SLT  = {7'b0000000, 3'b010},
        SLTU = {7'b0000000, 3'b011},
    } r_type_funct;

    always_ff @(posedge clk) begin
        reg_write_enable <= 0;
        mem_write_enable <= 0;

        case (opcode)
            R_TYPE: begin
                reg_write_enable <= 1;
                mem_write_enable <= 0;
                alu_source <= 0;
                pc_source <= 0;
                reg_write_source <= 2'b00;
                
                case ({funct7, funct3})
                    ADD: alu_op <= 4'b0000;
                    SUB: alu_op <= 4'b0001;
                    XOR: alu_op <= 4'b0100;
                    OR:  alu_op <= 4'b0011;
                    AND: alu_op <= 4'b0010;
                    SLL: alu_op <= 4'b0101;
                    SRL: alu_op <= 4'b0110;
                    SRA: alu_op <= 4'b0111;
                    SLT: alu_op <= 4'b1000;
                    SLTU: alu_op <= 4'b1001;
                    default: alu_op <= 4'b0000; // TODO: invalid operation
                endcase
            end
            I_TYPE: begin
                reg_write_enable <= 1;
                mem_write_enable <= 0;
            end
            S_TYPE: begin
                reg_write_enable <= 0;
                mem_write_enable <= 1;
            end
            B_TYPE: begin
                reg_write_enable <= 0;
                mem_write_enable <= 0; // Branch instructions do not write to registers or memory
            end
            U_TYPE: begin
                reg_write_enable <= 1;
                mem_write_enable <= 0;
            end
            J_TYPE: begin
                reg_write_enable <= 1;
                mem_write_enable <= 0;
            end
            default: begin
                reg_write_enable <= 0;
                mem_write_enable <= 0; // Default case, no operation
            end
        endcase
    end
endmodule