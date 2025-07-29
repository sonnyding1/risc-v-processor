module alu (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_op,
    output logic [31:0] result
);
    typedef enum logic [3:0] {
        ADD  = 4'b0000,
        SUB  = 4'b0001,
        AND  = 4'b0010,
        OR   = 4'b0011,
        XOR  = 4'b0100,
        SLL  = 4'b0101,
        SRL  = 4'b0110,
        SRA  = 4'b0111,
        SLT  = 4'b1000,
        SLTU = 4'b1001,
        EQ   = 4'b1010,
        B    = 4'b1011
    } alu_op_type;

    always_comb begin
        case (alu_op)
            ADD:  result = a + b;
            SUB:  result = a - b;
            AND:  result = a & b;
            OR:   result = a | b;
            XOR:  result = a ^ b;
            SLL:  result = a << b[4:0];
            SRL:  result = a >> b[4:0];
            SRA:  result = $signed(a) >>> b[4:0];
            SLT:  result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            SLTU: result = (a < b) ? 32'b1 : 32'b0;
            EQ:   result = (a == b) ? 32'b1 : 32'b0;
            B:    result = b;
            default: result = 32'b0;
        endcase
    end
endmodule