module Debouncer (
    input clk,
    input button_in,
    output button_out,
    output button_posedge,  // Rising edge (0?1)
    output button_negedge   // Falling edge (1?0)
);
    // Your 5 FF chain
    reg q1, q2, q3, q4, q5;
    
    always @(posedge clk) begin
        q1 <= button_in;
        q2 <= q1;
        q3 <= q2;
        q4 <= q3;
        q5 <= q4;
    end
    
    // Debounced output
    wire stable_out = q1 & q2 & q3 & q4 & q5;
    
    // Edge detection
    reg prev_out = 0;
    always @(posedge clk) begin
        prev_out <= stable_out;
    end
    
    assign button_out = stable_out;
    assign button_posedge = stable_out & ~prev_out;
    assign button_negedge = ~stable_out & prev_out;
endmodule