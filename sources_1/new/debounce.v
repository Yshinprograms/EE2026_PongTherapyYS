`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 23:48:28
// Design Name: 
// Module Name: debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debounce(
    input clk,
    input reset,
    input noisy,
    output reg clean
);
    parameter DEBOUNCE_LIMIT = 500000; // Adjust for desired debounce time.
    reg [31:0] counter;
    reg last_state;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clean <= 0;
            counter <= 0;
            last_state <= noisy;
        end else begin
            if (noisy == last_state) begin
                if (counter < DEBOUNCE_LIMIT)
                    counter <= counter + 1;
                else
                    clean <= noisy;
            end else begin
                counter <= 0;
                last_state <= noisy;
            end
        end
    end
endmodule
