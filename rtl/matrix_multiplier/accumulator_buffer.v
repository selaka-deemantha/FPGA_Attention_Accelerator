module accumulator_buffer #(
    parameter PE_SIZE                           = 4,
    parameter MAT_ROW                           = 16,
    parameter MAT_COL                           = 16,
    parameter ACC_WIDTH                         = 32
)
(
    input  wire                                 clk,
    input  wire                                 rst,

    input  wire signed [ACC_WIDTH-1:0]          w_data,
    input  wire                                 w_valid,

    output reg  signed [ACC_WIDTH-1:0]          r_data,
    output reg                                  r_valid,
    output reg                                  done
);

localparam NUM_ROUNDS                           = MAT_COL / PE_SIZE;

reg signed [ACC_WIDTH-1:0]                      buffer [0:MAT_ROW-1];

reg [31:0]                                      row_counter;
reg [31:0]                                      pe_col_counter;

integer                                         i;



// counters 
always @(posedge clk) begin
    if (rst) begin
        row_counter                             <= 0;
        pe_col_counter                          <= 0;
    end
    else begin
        if (w_valid) begin
            if (row_counter == MAT_ROW - 1) begin
                row_counter                     <= 0;
                if (pe_col_counter == NUM_ROUNDS - 1) begin
                    pe_col_counter              <= 0;
                end
                else begin
                    pe_col_counter              <= pe_col_counter + 1;
                end
            end
            else begin
                row_counter                     <= row_counter + 1;
            end
        end
        else begin
            row_counter                         <= row_counter;
            pe_col_counter                      <= pe_col_counter;
        end

    end

end

always @(posedge clk) begin

    if (rst) begin

        r_data                                  <= 0;
        r_valid                                 <= 0;
        done                                    <= 0;

    end
    else begin

        r_valid                                 <= 1'b0;
        done                                    <= 1'b0;

        if (w_valid) begin

            // First PE round
            if (pe_col_counter == 0) begin
                // pe size is equal to mat size
                if (NUM_ROUNDS == 1) begin

                    r_data                      <= w_data;
                    r_valid                     <= 1'b1;

                    if (row_counter == MAT_ROW-1)
                        done                    <= 1;
                    else
                        done                    <= 0;

                end
                else begin

                    buffer[row_counter]         <= w_data;
                    r_valid                     <= 0;
                    done                        <= 0;

                end

            end

            // Last PE round
            else if (pe_col_counter == NUM_ROUNDS-1) begin

                r_data                          <= buffer[row_counter] + w_data;
                r_valid                         <= 1'b1;
                
                if (row_counter == MAT_ROW-1)
                    done                        <= 1;
                else
                    done                        <= 0;

            end

            // Intermediate PE rounds
            else begin

                buffer[row_counter]             <= buffer[row_counter] + w_data;

            end

        end

    end

end

endmodule