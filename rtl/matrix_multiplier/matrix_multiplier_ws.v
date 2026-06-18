module matrix_multiplier_ws #(
    parameter DATA_WIDTH                            = 16,
    parameter ACC_WIDTH                             = 32,
    parameter PE_SIZE                               = 4,
    parameter MAT_ROW                               = 16,
    parameter MAT_COL                               = 16,
    parameter PE_PER_ROW                            = 4
)
(
    input wire                                      clk,
    input wire                                      rst,
    input wire                                      start,

    input wire signed           [DATA_WIDTH-1:0]    d_in        [PE_SIZE-1:0],
    input wire                                      d_valid,
    output reg                                      d_ready,

    input wire signed           [DATA_WIDTH-1:0]    w_in        [PE_SIZE-1:0],
    input wire                                      w_valid,
    output reg                                      w_ready,

    
    output reg signed           [ACC_WIDTH-1:0]     acc_out     [PE_SIZE-1:0],
    output reg                                      acc_valid,

    output reg                                      done
);

    // -------------------------------------------------
    // Control signals
    // -------------------------------------------------
    reg                                             active_bank_reg;
    reg                                             load_weight_reg;
    reg                                             weight_pre_load;


    wire                                            active_bank;
    wire                                            load_weight;

    reg [31:0]                                      col_counter;
    reg [31:0]                                      row_counter;
    reg [31:0]                                      pe_counter;
    reg [31:0]                                      pe_row_counter;

    assign load_weight                              = load_weight_reg;
    assign active_bank                              = active_bank_reg;

  
    // -------------------------------------------------
    // PE ARRAY INSTANTIATION
    // -------------------------------------------------
    pe_array_ws #(
        .DATA_WIDTH                                 (DATA_WIDTH),
        .ACC_WIDTH                                  (ACC_WIDTH),
        .PE_SIZE                                    (PE_SIZE),
        .MAT_ROW                                    (MAT_ROW),
        .MAT_COL                                    (MAT_COL)
    ) u_pe_array (
        .clk                                        (clk),
        .rst                                        (rst),

        .d_in                                       (d_in),
        .w_in                                       (w_in),

        .load_weight                                (load_weight),
        .active_bank                                (active_bank),

        .acc_out                                    (acc_bus)
    );

    // -------------------------------------------------
    // CONTROL LOGIC
    // -------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            col_counter                             <= 0;
            row_counter                             <= 0;
            active_bank_reg                         <= 0;
            load_weight                             <= 0;
            w_ready                                 <= 0;
            d_ready                                 <= 0;
            acc_valid                               <= 0;
            weight_pre_load                         <= 0;
            pe_counter                              <= 0;
            pe_row_counter                          <= 0;
            done                                    <= 0;
        end

        else if (start) begin
            col_counter                             <= 0;
            row_counter                             <= 0;
            active_bank_reg                         <= 1;
            load_weight                             <= 1;
            w_ready                                 <= 1;
            d_ready                                 <= 0;
            acc_valid                               <= 0;
            weight_pre_load                         <= 1;
            pe_counter                              <= 0;
            pe_row_counter                          <= 0;
            done                                    <= 0;
        end

        // weight pre loading for first time
        else if (weight_pre_load) begin
            if (w_valid) begin
                if (pe_counter ==  PE_SIZE - 1) begin
                    pe_counter <= 0;
                    weight_pre_load <= 0;
                    d_ready <= 1;
                    w_ready <= 0;
                    active_bank_reg <= 0;
                end
                else begin
                    pe_counter <= pe_counter + 1;
                end
            end

        end
        // normal data operation
        else begin

            // counter for data matrix
            if (d_valid) begin
                if (row_counter == MAT_ROW-1) begin
                    row_counter <= 0;
                    if (pe_row_counter == PE_PER_ROW - 1) begin
                        done <= 1;
                        d_ready <= 0;
                        w_ready <= 0
                    end
                    else begin
                        pe_row_counter <= pe_row_counter + 1;
                    end
                end
                else begin
                    row_counter <= row_counter + 1;
                end
            end

            // weight double buffer toggle
            if (row_counter == MAT_ROW-1) begin
                active_bank <= ~active_bank;
            end 
            else begin
                active_bank <= active_bank;
            end

            // weight loading signal handling
            if (row_counter == 0) begin
                load_weight <= 1;
                w_ready <= 1;
            end
            else if (row_counter == PE_SIZE-1) begin
                load_weight <= 0;
                w_ready <= 0;
            end
            else begin
                load_weight <= load_weight;
                w_ready <= w_ready;
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