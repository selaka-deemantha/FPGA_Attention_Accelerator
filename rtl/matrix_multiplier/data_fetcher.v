module data_fetcher #(
    parameter MAT_ROW = 3,
    parameter MAT_COL = 9,
    parameter PE_SIZE = 3,
    parameter DATA_WIDTH = 16,
    parameter ACC_WIDTH = 32
)
(
    input wire clk,
    input wire rst,

    input wire signed [DATA_WIDTH-1:0] d_in,
    input wire signed [DATA_WIDTH-1:0] wq_in,
    input wire signed [DATA_WIDTH-1:0] wk_in,
    input wire signed [DATA_WIDTH-1:0] wv_in,

    output reg signed [DATA_WIDTH-1:0] d_in [0:PE_SIZE-1],
    output reg signed [DATA_WIDTH-1:0] w_in [0:PE_SIZE-1],
    output reg [PE_SIZE-1:0    ]   valid_in



);






endmodule