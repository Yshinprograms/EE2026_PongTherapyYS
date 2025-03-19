`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 00:56:11
// Design Name: 
// Module Name: paddle_control
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


module paddle_control(
    input clk,
    input reset,
    input btnU,  // Up button (active high)
    input btnD,  // Down button (active high)
    output reg [7:0] paddle_y
);
    parameter MAX_Y = 64;  // Game area height

    // Initialize paddle position to the middle (e.g., 32)
    always @(posedge clk or posedge reset) begin
         if (reset)
             paddle_y <= MAX_Y / 2;
         else begin
             // Move up if btnU is pressed (ensure paddle_y doesn't go below 0)
             if (btnU && (paddle_y > 0))
                 paddle_y <= paddle_y - 1;
             // Move down if btnD is pressed (ensure paddle_y doesn't exceed MAX_Y-1)
             else if (btnD && (paddle_y < MAX_Y - 1))
                 paddle_y <= paddle_y + 1;
         end
    end
endmodule

