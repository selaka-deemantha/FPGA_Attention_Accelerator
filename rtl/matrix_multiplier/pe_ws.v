module pe_ws #(
    parameter DATA_WIDTH = 16,
    parameter ACC_WIDTH  = 32
)
(
    input  wire                         clk,
    input  wire                         rst,

    input  wire signed [DATA_WIDTH-1:0] d_in,
    output reg  signed [DATA_WIDTH-1:0] d_out,


    input  wire signed [ACC_WIDTH-1:0]  acc_in,
    output reg  signed [ACC_WIDTH-1:0]  acc_out,

    input  wire signed [DATA_WIDTH-1:0] w_in,
    output reg  signed [DATA_WIDTH-1:0] w_out,

    input  wire                         w0_fill,
    input  wire                         w1_fill,

    input  wire                         sel_in,
    output reg                          sel_out
);

    // Weight buffers
    reg signed [DATA_WIDTH-1:0]         w0;
    reg signed [DATA_WIDTH-1:0]         w1;

    // Active weight selection
    wire signed [DATA_WIDTH-1:0]        active_weight;
    assign active_weight                = sel_in ? w1 : w0;

    // Multiply
    wire signed [2*DATA_WIDTH-1:0]      product;
    assign product                      = d_in * active_weight;

    // Main pipeline
    always @(posedge clk) begin
        if (rst) begin

            d_out                       <= 0;
            w_out                       <= 0;
            acc_out                     <= 0;

            w0                          <= 0;
            w1                          <= 0;

            sel_out                     <= 0;


        end
        else begin

            // Pipeline forwarding
            d_out                       <= d_in;
            w_out                       <= w_in;
            sel_out                     <= sel_in;

            // Weight loading
            if (w0_fill)
                w0                      <= w_in;

            if (w1_fill)
                w1                      <= w_in;

            // MAC
            acc_out                     <= acc_in + {{(ACC_WIDTH-2*DATA_WIDTH){product[2*DATA_WIDTH-1]}}, product};
       
        end
    end

endmodule