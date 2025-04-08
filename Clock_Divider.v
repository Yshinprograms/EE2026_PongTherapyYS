module Clock_Divider (
    input clk_100MHz,
    input rst,
    input [31:0] divisor,
    output clk
);

    reg [31:0] count;
    reg clk_reg;

    // By default already halves the 100MHz frequency because toggles every 10ns posedge
    // Calculate period from desired frequency, F = 1/T
    // Every posedge happens in 10ns intervals
    // If we want period T, that means toggle every T/2 = (divisor + 1) * 10ns
    // Therefore, divisor = (50,000,000 / freq) - 1

    always @(posedge clk_100MHz, posedge rst) begin // Use asynchronous or synchronous reset
        if (rst) begin
            count <= 32'b0;
            clk_reg <= 1'b0;
        end else begin
            if (count == divisor) begin
                count <= 32'b0;
                clk_reg <= ~clk_reg;
            end else begin
                count <= count + 1;
            end
        end
    end

    assign clk = clk_reg;

endmodule