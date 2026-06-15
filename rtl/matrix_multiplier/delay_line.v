module delay_line #(
    parameter WIDTH = 16,
    parameter DELAY = 0
)
(
    input wire clk,
    input wire rst,

    input wire signed [WIDTH-1:0] din,
    output wire signed [WIDTH-1:0] dout

);


generate 

// no delay
if (DELAY == 0) begin : g_no_delay
    assign dout = din;
end 

// delay chain

else begin : g_delay

    reg signed [WIDTH-1:0] shift_reg [0:DELAY-1];

    integer i;

    always @(posedge clk) begin
        if (rst) begin

            for (i = 0; i < DELAY; i = i + 1)
                shift_reg[i] <= '0;

        end
        else begin

            shift_reg[0] <= din;

            for (i = 1; i < DELAY; i = i + 1)
                shift_reg[i] <= shift_reg[i-1];

        end
    end

    assign dout = shift_reg[DELAY-1];

end


endgenerate



endmodule