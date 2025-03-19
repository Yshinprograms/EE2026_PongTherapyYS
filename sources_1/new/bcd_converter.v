module bcd_converter(
    input  [7:0] number,  // Number to convert (assumed to be less than 100)
    output reg [3:0] tens,
    output reg [3:0] ones
);
    always @(*) begin
        // Using simple division and modulo operators (ensure synthesis tools support these for constant divisors)
        tens = number / 10;
        ones = number % 10;
    end
endmodule
