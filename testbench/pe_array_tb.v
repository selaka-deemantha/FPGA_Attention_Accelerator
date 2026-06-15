`timescale 1ns/1ps

module pe_array_tb;

    localparam PE_SIZE    = 3;
    localparam DATA_WIDTH = 16;
    localparam ACC_WIDTH  = 32;
    localparam MAT_SIZE   = 9;

    // DUT signals
    reg clk;
    reg rst;

    reg signed [DATA_WIDTH-1:0] d_in [0:PE_SIZE-1];
    reg signed [DATA_WIDTH-1:0] w_in [0:PE_SIZE-1];
    reg        [PE_SIZE-1:0]    valid_in;

    wire signed [ACC_WIDTH-1:0] acc_out [0:PE_SIZE-1];
    wire        [PE_SIZE-1:0]    valid_out;

    // Test matrices
    reg signed [DATA_WIDTH-1:0] A [0:2][0:8];
    reg signed [DATA_WIDTH-1:0] B [0:8][0:2];

    integer i;
    integer j;
    integer cycle;

    //------------------------------------------------------------
    // DUT
    //------------------------------------------------------------

    pe_array #(
        .PE_SIZE       (PE_SIZE),
        .DATA_WIDTH    (DATA_WIDTH),
        .ACC_WIDTH     (ACC_WIDTH),
        .MAT_SIZE      (MAT_SIZE),
        .DELAY_CHAIN_EN(1)
    ) dut (
        .clk       (clk),
        .rst       (rst),
        .d_in      (d_in),
        .w_in      (w_in),
        .valid_in  (valid_in),
        .acc_out   (acc_out),
        .valid_out (valid_out)
    );

    //------------------------------------------------------------
    // Clock
    //------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //------------------------------------------------------------
    // Matrix initialization
    //------------------------------------------------------------

    initial begin

        // Matrix A (3x9)

        A[0][0]=1;  A[0][1]=2;  A[0][2]=3;  A[0][3]=4;  A[0][4]=5;
        A[0][5]=6;  A[0][6]=7;  A[0][7]=8;  A[0][8]=9;

        A[1][0]=10; A[1][1]=11; A[1][2]=12; A[1][3]=13; A[1][4]=14;
        A[1][5]=15; A[1][6]=16; A[1][7]=17; A[1][8]=18;

        A[2][0]=19; A[2][1]=20; A[2][2]=21; A[2][3]=22; A[2][4]=23;
        A[2][5]=24; A[2][6]=25; A[2][7]=26; A[2][8]=27;

        // Matrix B (9x3)

        B[0][0]=1;  B[0][1]=2;  B[0][2]=3;
        B[1][0]=4;  B[1][1]=5;  B[1][2]=6;
        B[2][0]=7;  B[2][1]=8;  B[2][2]=9;
        B[3][0]=10; B[3][1]=11; B[3][2]=12;
        B[4][0]=13; B[4][1]=14; B[4][2]=15;
        B[5][0]=16; B[5][1]=17; B[5][2]=18;
        B[6][0]=19; B[6][1]=20; B[6][2]=21;
        B[7][0]=22; B[7][1]=23; B[7][2]=24;
        B[8][0]=25; B[8][1]=26; B[8][2]=27;

    end

    //------------------------------------------------------------
    // Stimulus
    //------------------------------------------------------------

    initial begin

        rst      = 1'b1;
        valid_in = '0;

        for (i = 0; i < PE_SIZE; i = i + 1) begin
            d_in[i] = 0;
            w_in[i] = 0;
        end

        repeat (5) @(posedge clk);

        rst <= 1'b0;

        // Stream matrix data

        for (cycle = 0; cycle < MAT_SIZE; cycle = cycle + 1) begin

            d_in[0] <= A[0][cycle];
            d_in[1] <= A[1][cycle];
            d_in[2] <= A[2][cycle];

            w_in[0] <= B[cycle][0];
            w_in[1] <= B[cycle][1];
            w_in[2] <= B[cycle][2];

            valid_in <= 3'b111;

            @(posedge clk);

        end

        // Stop injecting data

        valid_in <= 3'b000;

        for (i = 0; i < PE_SIZE; i = i + 1) begin
            d_in[i] <= 0;
            w_in[i] <= 0;
        end

        // Allow pipeline to drain

        repeat (20) @(posedge clk);

        $finish;

    end

endmodule