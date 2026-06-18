`timescale 1ns/1ps

module tb_accumulator_buffer;

    parameter PE_SIZE   = 3;
    parameter MAT_ROW   = 6;
    parameter MAT_COL   = 6;
    parameter ACC_WIDTH = 32;

    reg clk;
    reg rst;

    reg  signed [ACC_WIDTH-1:0] w_data;
    reg w_valid;

    wire signed [ACC_WIDTH-1:0] r_data;
    wire r_valid;
    wire done;

    accumulator_buffer #(
        .PE_SIZE(PE_SIZE),
        .MAT_ROW(MAT_ROW),
        .MAT_COL(MAT_COL),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .w_data(w_data),
        .w_valid(w_valid),
        .r_data(r_data),
        .r_valid(r_valid),
        .done(done)
    );

    // clock
    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        rst = 1;
        w_valid = 0;
        w_data = 0;

        repeat(5) @(posedge clk);
        rst = 0;

        $display("START STREAMING");

        // 6x6 matrix streamed 1 value per clock
        for (i = 0; i < (MAT_ROW*MAT_COL); i = i + 1) begin
            @(posedge clk);
            w_valid = 1;
            w_data  = i + 1;   // simple pattern 1..36
        end

        @(posedge clk);
        w_valid = 0;

        repeat(10) @(posedge clk);

        $display("DONE");
        $finish;
    end



endmodule