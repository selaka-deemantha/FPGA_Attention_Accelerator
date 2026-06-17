module pe_ws #(
    parameter DATA_WIDTH = 16,
    parameter ACC_WIDTH  = 32
)
(
    input  wire                         clk,
    input  wire                         rst,

    // Data path
    input  wire signed [DATA_WIDTH-1:0] d_in,
    output reg  signed [DATA_WIDTH-1:0] d_out,

    // Partial sum path
    input  wire signed [ACC_WIDTH-1:0]  acc_in,
    output reg  signed [ACC_WIDTH-1:0]  acc_out,

    // Weight loading path
    input  wire signed [DATA_WIDTH-1:0] w_in,
    output reg  signed [DATA_WIDTH-1:0] w_out,

    // Control
    input  wire                         load_weight,
    input  wire                         active_bank
);

    //----------------------------------------------------------
    // Double-buffered weight storage
    //----------------------------------------------------------

    reg signed [DATA_WIDTH-1:0] weight_bank [0:1];

    wire signed [DATA_WIDTH-1:0] active_weight;

    assign active_weight = weight_bank[active_bank];

    //----------------------------------------------------------
    // Multiply
    //----------------------------------------------------------

    wire signed [2*DATA_WIDTH-1:0] product;

    assign product = d_in * active_weight;

    //----------------------------------------------------------
    // Main pipeline
    //----------------------------------------------------------

    always @(posedge clk) begin
        if (rst) begin

            d_out <= '0;
            w_out <= '0;

            acc_out <= '0;

            weight_bank[0] <= '0;
            weight_bank[1] <= '0;

        end
        else begin

            //--------------------------------------------------
            // Forward systolic streams
            //--------------------------------------------------

            d_out <= d_in;
            w_out <= w_in;

            //--------------------------------------------------
            // Load inactive bank
            //--------------------------------------------------

            if (load_weight) begin

                if (active_bank)
                    weight_bank[0] <= w_in; // computing with bank1
                else
                    weight_bank[1] <= w_in; // computing with bank0

            end

            //--------------------------------------------------
            // MAC
            //--------------------------------------------------

            acc_out <= acc_in + $signed(product);

        end
    end

endmodule