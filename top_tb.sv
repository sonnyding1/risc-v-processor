`timescale 1ns / 1ps

module rv32i_top_tb();
    logic clk;
    logic rst;
    logic [31:0] instruction;
    logic [31:0] mem_data;
    logic [31:0] pc;
    logic [31:0] mem_addr;
    logic mem_write_enable;
    logic [31:0] mem_write_data;
    logic [31:0] i_mem [0:255]; // instruction memory
    logic [31:0] mem [0:255]; // data memory

    rv32i_top dut (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .mem_data(mem_data),
        .pc(pc),
        .mem_addr(mem_addr),
        .mem_write_enable(mem_write_enable),
        .mem_write_data(mem_write_data)
    );

    assign instruction = i_mem[pc >> 2];
    assign mem_data = mem[mem_addr >> 2];

    initial begin
        $readmemh("tests/branch/i_mem.hex", i_mem);
        $readmemh("tests/branch/mem.hex", mem);
    end

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

    always_ff @(posedge clk) begin
        if (mem_write_enable) begin
            mem[mem_addr >> 2] <= mem_write_data;
        end
    end
endmodule