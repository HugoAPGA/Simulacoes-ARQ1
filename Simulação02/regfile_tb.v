`timescale 1ns/1ns

module regfile_tb;
    // Declare testbench variables
    reg clk, we3;
    reg [31:0] test_vector [0:7];
    integer i;
    reg [4:0] ra1, ra2, wa3;
    reg [31:0] wd3;
    wire [31:0] rd1, rd2;

    // VCD waveform generation, $monitor formating, clock generation
    initial begin
        $dumpfile("regfile_tb.vcd");
        $dumpvars(0, regfile_tb);
        $readmemh("../values.tv", test_vector);
        $monitor("Time: %2t, ra1:%d, ra2:%d, wa3:%d, we3:%b, wd3: %h, rd2: %h, rd1: %h", $time, ra1, ra2, wa3, we3, wd3, rd2, rd1);
        clk = 0; we3 = 0;
        forever #5 clk = ~clk;
    end

    // Instantiate the design under test
    regfile dut (clk, we3, ra1, ra2, wa3, wd3, rd1, rd2);

    initial begin
        // Teste dos 8 registradores ($x1 a $x8)
        for (i = 0; i < 9; i = i + 1) begin
            // Sincroniza a descida do clock
            @(negedge clk)

            // Regra 1 e 2: Modificar endereços e dados na borda de descida e habilitar escrita
            we3 = 1;               // Habilita escrita
            wa3 = i + 1;           // Escreve no registrador $xi + 1
            wd3 = test_vector[i];  // Dado que quero escrever

            // Regra 3: Na porta 2 é lido o mesmo registrador da escrita
            ra2 = i + 1;

            // Regra 4: Na porta 1 é lido o registrador anterior
            ra1 = wa3 - 1;

        end
        we3 = 0;
        
        $finish;
    end

endmodule