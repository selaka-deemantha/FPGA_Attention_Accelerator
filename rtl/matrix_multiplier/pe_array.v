module pe_array #(
    parameter PE_SIZE                       = 4,
    parameter DATA_WIDTH                    = 16,
    parameter ACC_WIDTH                     = 32,
    parameter MAT_SIZE                      = 4,
    parameter DELAY_CHAIN_EN                = 1
)
(
    input wire                              clk,
    input wire                              rst,

    input wire signed   [DATA_WIDTH-1:0 ]   d_in        [PE_SIZE-1:0],
    input wire signed   [DATA_WIDTH-1:0 ]   w_in        [PE_SIZE-1:0],
    input wire          [PE_SIZE-1:0    ]   valid_in,

    output reg signed   [ACC_WIDTH-1:0 ]   acc_out     [PE_SIZE-1:0],
    output reg          [PE_SIZE-1:0    ]   valid_out
);

// internal signals

wire signed              [DATA_WIDTH-1:0 ]   d_delayed   [PE_SIZE-1:0];
wire signed              [DATA_WIDTH-1:0 ]   w_delayed   [PE_SIZE-1:0];

reg                                          clear_line  [PE_SIZE-1:0];

wire signed              [DATA_WIDTH-1:0 ]   d_bus       [0:PE_SIZE-1][0:PE_SIZE];
wire signed              [DATA_WIDTH-1:0 ]   w_bus       [0:PE_SIZE][0:PE_SIZE-1];
wire                                        clear_bus   [0:PE_SIZE-1][0:PE_SIZE];
wire signed              [ACC_WIDTH-1:0 ]   acc_bus     [0:PE_SIZE][0:PE_SIZE-1];

reg [31:0] col_counter;
reg [31:0] row_counter;
reg [31:0] valid_counter;

genvar a;
generate 
    for (a=0;a<PE_SIZE;a=a+1) begin
        assign clear_bus[a][0] = clear_line[a];
    end

endgenerate


// delay chain generation

genvar b;

generate

    if (DELAY_CHAIN_EN) begin : g_delay_chain

        for (b = 0; b < PE_SIZE; b = b + 1) begin : g_rows

            // Data delay chain
            delay_line #(
                .WIDTH(DATA_WIDTH),
                .DELAY(b)
            ) d_delay_inst (
                .clk  (clk),
                .rst  (rst),
                .din  (d_in[b]),
                .dout (d_bus[b][0])
            );

            // Weight delay chain
            delay_line #(
                .WIDTH(DATA_WIDTH),
                .DELAY(b)
            ) w_delay_inst (
                .clk  (clk),
                .rst  (rst),
                .din  (w_in[b]),
                .dout (w_bus[0][b])
            );

        end

    end
    else begin : g_no_delay

        for (b = 0; b < PE_SIZE; b = b + 1) begin : g_bypass

            assign d_bus[b][0] = d_in[b];
            assign w_bus[0][b] = w_in[b];

        end

    end

endgenerate




// col row counters

always @(posedge clk) begin
    if (rst) begin
        col_counter <= 0;
        row_counter <= 0;
    end
    else begin
        if (valid_in[0]) begin

            if (col_counter == MAT_SIZE - 1) begin
                col_counter <= 0;
                row_counter <= row_counter + 1;
            end
            else begin
                col_counter <= col_counter + 1;
            end

        end
    end
end


// first clear signal

always @(posedge clk) begin
    if (rst) begin
        clear_line[0] <= 1'b0;
    end
    else begin
        if (col_counter == MAT_SIZE - 2)
            clear_line[0] <= 1'b1;
        else
            clear_line[0] <= 1'b0;
    end
end


// clear shift register

integer k;

always @(posedge clk) begin
    if (rst) begin
        for (k = 1; k < PE_SIZE; k = k + 1)
            clear_line[k] <= 1'b0;
    end
    else begin
        for (k = 1; k < PE_SIZE; k = k + 1)
            clear_line[k] <= clear_line[k-1];
    end
end


// accumulator bus 

integer m;

always @(*) begin

    for (m = 0; m < PE_SIZE; m = m + 1) begin
        acc_out[m] = acc_bus[PE_SIZE][m];
    end

end


// accumulator valid

integer i;

always @(posedge clk) begin
    if (rst) begin
        valid_out[0] <= 1'b0;
    end
    else begin
        valid_out[0] <= 1'b0;

        for (i = 0; i < PE_SIZE; i = i + 1) begin
            if (clear_line[i])
                valid_out[0] <= 1'b1;
        end
    end
end


integer f;

always @(posedge clk) begin
    if (rst) begin
        for (f = 1; f < PE_SIZE; f = f + 1)
            valid_out[f] <= 1'b0;
    end
    else begin
        for (f = 1; f < PE_SIZE; f = f + 1)
            valid_out[f] <= valid_out[f-1];
    end
end

// acc_bus first row 

genvar d;
generate 
    for (d=0;d<PE_SIZE;d=d+1) begin
        assign acc_bus[0][d] = 0;
    end

endgenerate


// pe array 

genvar r, c;

generate

for (r = 0; r < PE_SIZE; r = r + 1) begin : gen_row

    for (c = 0; c < PE_SIZE; c = c + 1) begin : gen_col

        pe #(
            .DATA_WIDTH(DATA_WIDTH),
            .ACC_WIDTH (ACC_WIDTH)
        )
        u_pe (

            .clk(clk),
            .rst(rst),

            .d_in(d_bus[r][c]),
            .d_out(d_bus[r][c+1]),

            .w_in(w_bus[r][c]),
            .w_out(w_bus[r+1][c]),

            .clear_in(clear_bus[r][c]),
            .clear_out(clear_bus[r][c+1]),

            .acc_in(acc_bus[r][c]),
            .acc_out(acc_bus[r+1][c])

        );

    end

end

endgenerate




endmodule
