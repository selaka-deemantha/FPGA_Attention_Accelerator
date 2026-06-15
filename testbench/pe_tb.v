`timescale 1ns/1ps

module pe_tb;

    parameter DATA_WIDTH = 8;
    parameter ACC_WIDTH  = 32;

    reg clk;
    reg rst;

    reg signed [DATA_WIDTH-1:0] d_in;
    reg signed [DATA_WIDTH-1:0] w_in;
    reg clear_in;

    wire signed [DATA_WIDTH-1:0] d_out;
    wire signed [DATA_WIDTH-1:0] w_out;
    wire clear_out;

    reg signed [ACC_WIDTH-1:0] acc_in;
    wire signed [ACC_WIDTH-1:0] acc_out;

    // Instantiate DUT
    pe #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),

        .d_in(d_in),
        .w_in(w_in),
        .clear_in(clear_in),

        .d_out(d_out),
        .w_out(w_out),
        .clear_out(clear_out),

        .acc_in(acc_in),
        .acc_out(acc_out)
    );

    // Clock generation
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    // Stimulus
    initial begin

        // init
        rst      = 1;
        d_in     = 0;
        w_in     = 0;
        clear_in = 0;
        acc_in   = 0;

        @(posedge clk);
        @(posedge clk);

        rst = 0;

        // -----------------------------
        // Apply test vectors
        // -----------------------------

        // Cycle 1
        @(posedge clk);
        d_in = 3;
        w_in = 2;
        clear_in = 0;
        acc_in = 0;

        // Cycle 2
        @(posedge clk);
        d_in = 4;
        w_in = 5;
        clear_in = 0;

        // Cycle 3 (force clear)
        @(posedge clk);
        d_in = 1;
        w_in = 7;
        clear_in = 1;

        // Cycle 4
        @(posedge clk);
        clear_in = 0;

        // Cycle 5
        @(posedge clk);
        d_in = 2;
        w_in = 3;

        // Finish after some cycles
        repeat (5) @(posedge clk);

        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("t=%0t | d_in=%d w_in=%d clear=%b | acc_out=%d",
                 $time, d_in, w_in, clear_in, acc_out);
    end

endmodule