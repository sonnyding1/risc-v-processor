`timescale 1ns / 1ps

module rv32i_top_tb();
    logic clk;
    logic rst;
    logic [31:0] instruction;
    logic [7:0] pc;
    logic [31:0] i_mem [0:255]; // instruction memory

    rv32i_top dut (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .pc(pc)
    );

    initial begin
        $readmemh("instructions.hex", i_mem);
    end

    assign instruction = i_mem[pc >> 2];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #20;
        rst = 0;

        #1000;

        $finish;
    end

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, dut);
        // dump register contents
        for (int i = 0; i < 32; i = i + 1) begin
            $dumpvars(0, dut.register_file_inst.registers[i]);
        end
    end
endmodule