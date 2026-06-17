module matrix_multiplier_ws #(
    parameter DATA_WIDTH    = 16,
    parameter ACC_WIDTH     = 32,
    parameter PE_SIZE       = 4,
    parameter MAT_ROW       = 16,
    parameter MAT_COL       = 16
)
(
    input wire clk,
    input wire rst,
    input wire start,

    input wire signed [DATA_WIDTH-1:0] d_in [PE_SIZE-1:0],
    input wire d_valid,

    
    input wire signed [DATA_WIDTH-1:0] w_in [PE_SIZE-1:0],
    

    output reg w_ready,
    output reg acc_valid,
    output reg signed [ACC_WIDTH-1:0] acc_out [PE_SIZE-1:0]
);

    // -------------------------------------------------
    // Control signals
    // -------------------------------------------------
    reg w0_fill;
    reg w1_fill;
    reg selected_w;

    reg [31:0] col_counter;
    reg [31:0] row_counter;

    // -------------------------------------------------
    // PE ARRAY OUTPUT WIRES
    // -------------------------------------------------
    wire signed [ACC_WIDTH-1:0] acc_bus [PE_SIZE-1:0];

    // -------------------------------------------------
    // PE ARRAY INSTANTIATION
    // -------------------------------------------------
    pe_array_ws #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH (ACC_WIDTH),
        .PE_SIZE   (PE_SIZE),
        .MAT_ROW   (MAT_ROW),
        .MAT_COL   (MAT_COL)
    ) u_pe_array (
        .clk      (clk),
        .rst      (rst),

        .d_in     (d_in),
        .w_in     (w_in),

        .w1_fill  (w1_fill),
        .w0_fill  (w0_fill),

        .acc_out  (acc_bus)
    );

    // -------------------------------------------------
    // CONTROL LOGIC
    // -------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            col_counter  <= 0;
            row_counter  <= 0;

            w0_fill      <= 0;
            w1_fill      <= 0;
            selected_w   <= 0;

            w_ready      <= 0;
            acc_valid    <= 0;
        end

        else if (start) begin
            col_counter  <= 0;
            row_counter  <= 0;

            w0_fill      <= 0;
            w1_fill      <= 0;
            selected_w   <= 0;

            w_ready      <= 0;
            acc_valid    <= 0;
        end

        else begin

            // ----------------------------
            // COLUMN COUNTER (stream control)
            // ----------------------------
            if (d_valid) begin
                if (col_counter == MAT_COL-1) begin
                    col_counter <= 0;
                    row_counter <= row_counter + 1;
                end
                else begin
                    col_counter <= col_counter + 1;
                end
            end

            // ----------------------------
            // SIMPLE WEIGHT DOUBLE BUFFER TOGGLE
            // ----------------------------
            if (d_valid) begin
                selected_w <= ~selected_w;
                w0_fill    <= ~selected_w;
                w1_fill    <= selected_w;
            end
            else begin
                w0_fill <= 0;
                w1_fill <= 0;
            end

            // ----------------------------
            // OUTPUT VALID SIGNAL (simple version)
            // ----------------------------
            acc_valid <= (row_counter > 0);

            // pass output
            acc_out <= acc_bus;

            // ready signal (simplified)
            w_ready <= 1'b1;

        end
    end

endmodule