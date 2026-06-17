module pe_array_ws #(
    parameter DATA_WIDTH                        = 16,
    parameter ACC_WIDTH                         = 32,
    parameter PE_SIZE                           = 4,
    parameter MAT_ROW                           = 16,
    parameter MAT_COL                           = 16,
    parameter DELAY_LINE_EN                     = 1,
    parameter DIP_EN                            = 1
)
(
    input wire clk,
    input wire rst,

    input wire signed   [DATA_WIDTH-1:0 ]       d_in        [PE_SIZE-1:0],
    input wire signed   [DATA_WIDTH-1:0 ]       w_in        [PE_SIZE-1:0],
    input wire                                  sel_in,
    input wire                                  w1_fill,
    input wire                                  w0_fill,

    output reg signed   [ACC_WIDTH-1:0 ]        acc_out     [PE_SIZE-1:0]

);

wire signed              [DATA_WIDTH-1:0 ]      d_bus          [0:PE_SIZE-1][0:PE_SIZE];
wire signed              [DATA_WIDTH-1:0 ]      w_bus          [0:PE_SIZE][0:PE_SIZE-1];
wire signed              [ACC_WIDTH-1:0 ]       acc_bus        [0:PE_SIZE][0:PE_SIZE-1];
wire                                            sel_bus        [0:PE_SIZE][0:PE_SIZE-1];
reg                                             sel_line       [PE_SIZE-1:0];


// first accumulator row zeroing
genvar i;
generate
    for (i = 0; i < PE_SIZE; i = i + 1) begin
        assign acc_bus[0][i]                    = '0;
    end
endgenerate

// last accumultor row output
integer k;
always @(*) begin
    for (k = 0; k < PE_SIZE; k = k + 1) begin
        acc_out[k]                              = acc_bus[PE_SIZE][k];
    end
end

// take the sel_in signal for first element of sel_line
always @(*) begin
    sel_line[0]                                 = sel_in;
end

// shift register for remaining bits
integer m;

always @(posedge clk) begin
    if (rst) begin
        for (m = 1; m < PE_SIZE; m = m + 1)
            sel_line[m]                         <= 1'b0;
    end
    else begin
        for (m = 1; m < PE_SIZE; m = m + 1)
            sel_line[m]                         <= sel_line[m-1];
    end
end


genvar n;
generate 
    for (n=0;n<PE_SIZE;n=n+1) begin
        assign sel_bus[0][n]                    = sel_line[n];
    end

endgenerate



// delay line for d bus and d in
genvar a;
generate

    if (DELAY_CHAIN_EN) begin : g_delay_chain
        for (a = 0; a < PE_SIZE; a = a + 1) begin : g_rows
            delay_line #(
                .WIDTH                          (DATA_WIDTH),
                .DELAY                          (a)
            ) d_delay_inst (
                .clk                            (clk),
                .rst                            (rst),
                .din                            (d_in[a]),
                .dout                           (d_bus[a][0])
            );
        end
    end
    else begin : g_no_delay
        for (a = 0; a < PE_SIZE; a = a + 1) begin : g_bypass
            assign d_bus[a][0]                  = d_in[a];
        end

    end
endgenerate


// pe array
genvar r, c;

generate

if (DIP_EN) begin : g_dip

    for (r = 0; r < PE_SIZE; r = r + 1) begin : gen_row

        for (c = 0; c < PE_SIZE; c = c + 1) begin : gen_col

            if (r == 0) begin : row0_ws

                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH (ACC_WIDTH)
                ) u_pe (
                    .clk     (clk),
                    .rst     (rst),

                    .d_in    (d_bus[0][c]),
                    .d_out   (d_bus[1][c]),

                    .w_in    (w_bus[0][c]),
                    .w_out   (w_bus[1][c]),

                    .acc_in  (acc_bus[0][c]),
                    .acc_out (acc_bus[1][c]),

                    .w0_fill (w0_fill),
                    .w1_fill (w1_fill),

                    .sel_in  (sel_bus[0][c]),
                    .sel_out (sel_bus[1][c])
                );

            end
            else begin : dip_rows

                localparam integer NEXT_C = (c == PE_SIZE - 1) ? (0) : (c+1);

                pe #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH (ACC_WIDTH)
                ) u_pe (
                    .clk     (clk),
                    .rst     (rst),

                    // DiP diagonal shift (clean version)
                    .d_in    (d_bus[r][NEXT_C]),

                    .d_out   (d_bus[r+1][c]),

                    .w_in    (w_bus[r][c]),
                    .w_out   (w_bus[r+1][c]),

                    .acc_in  (acc_bus[r][c]),
                    .acc_out (acc_bus[r+1][c]),

                    .w0_fill (w0_fill),
                    .w1_fill (w1_fill),

                    .sel_in  (sel_bus[r][c]),
                    .sel_out (sel_bus[r+1][c])
                );

            end

        end

    end

end

else begin : g_ws

    for (r = 0; r < PE_SIZE; r = r + 1) begin : ws_row

        for (c = 0; c < PE_SIZE; c = c + 1) begin : ws_col

            pe #(
                .DATA_WIDTH(DATA_WIDTH),
                .ACC_WIDTH (ACC_WIDTH)
            ) u_pe (
                .clk     (clk),
                .rst     (rst),

                .d_in    (d_bus[r][c]),
                .d_out   (d_bus[r][c+1]),

                .w_in    (w_bus[r][c]),
                .w_out   (w_bus[r+1][c]),

                .acc_in  (acc_bus[r][c]),
                .acc_out (acc_bus[r+1][c]),

                .w0_fill (w0_fill),
                .w1_fill (w1_fill),

                .sel_in  (sel_bus[r][c]),
                .sel_out (sel_bus[r+1][c])
            );

        end

    end

end

endgenerate



// pe array DIP
genvar r, c;

generate

for (r = 0; r < PE_SIZE; r = r + 1) begin : gen_row

    for (c = 0; c < PE_SIZE; c = c + 1) begin : gen_col

        pe #(
            .DATA_WIDTH                         (DATA_WIDTH),
            .ACC_WIDTH                          (ACC_WIDTH)
        )
        u_pe (

            .clk                                (clk),
            .rst                                (rst),

            .d_in                               (d_bus[r][c]),
            .d_out                              (d_bus[r][c+1]),

            .w_in                               (w_bus[r][c]),
            .w_out                              (w_bus[r+1][c]),

            .acc_in                             (acc_bus[r][c]),
            .acc_out                            (acc_bus[r+1][c]),

            .w0_fill                            (w0_fill),
            .w1_fill                            (w1_fill),

            .sel_in                             (sel_bus[r][c]),
            .sel_out                            (sel_bus[r+1][c])

        );

    end

end

endgenerate





endmodule