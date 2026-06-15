module pe #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH  = 32
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire signed [DATA_WIDTH-1:0] d_in,
    input  wire signed [DATA_WIDTH-1:0] w_in,
    input  wire                         clear_in,

    output reg  signed [DATA_WIDTH-1:0] d_out,
    output reg  signed [DATA_WIDTH-1:0] w_out,
    output reg                          clear_out,

    input  wire signed [ACC_WIDTH-1:0] acc_in,
    output wire signed [ACC_WIDTH-1:0] acc_out
);

    // Internal registers
    reg signed [ACC_WIDTH-1:0] acc_reg;
    reg signed [ACC_WIDTH-1:0] acc_out_reg;
    reg acc_valid;

    // product has width 2*DATA_WIDTH
    wire signed [2*DATA_WIDTH-1:0] product;

    assign product = d_in * w_in;

    always @(posedge clk) begin
        if (rst) begin
            acc_reg     <= 0;
            acc_out_reg <= 0;

            d_out       <= 0;
            w_out       <= 0;
            clear_out   <= 0;

            acc_valid   <= 0;
        end
        else begin

            // pipeline signals
            d_out     <= d_in;
            w_out     <= w_in;
            clear_out <= clear_in;

            // accumulation logic
            if (clear_in) begin
                acc_out_reg <= acc_reg + {{(ACC_WIDTH-2*DATA_WIDTH){product[2*DATA_WIDTH-1]}}, product};
                acc_reg     <= 0;
                acc_valid   <= 1'b1;
            end
            else begin
                acc_reg   <= acc_reg + {{(ACC_WIDTH-2*DATA_WIDTH){product[2*DATA_WIDTH-1]}}, product};
                acc_valid <= 1'b0;
            end
        end
    end

    // output mux (same as VHDL concurrent assignment)
    assign acc_out = (acc_valid) ? acc_out_reg : acc_in;

    

endmodule