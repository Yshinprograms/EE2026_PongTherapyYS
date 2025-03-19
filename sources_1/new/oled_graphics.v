`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 00:18:38
// Design Name: 
// Module Name: oled_graphics
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


module oled_graphics (
   input [12:0] pixel_index,
   input [7:0] ball_x,
   input [7:0] ball_y,
   input [7:0] paddle_y,   // Paddle vertical position from paddle_control
   output reg [15:0] pixel_data
);
   // Assume OLED resolution: 96 x 64.
   // Calculate pixel coordinates from pixel_index.
   wire [6:0] x;
   wire [5:0] y;
   assign x = pixel_index % 96;
   assign y = pixel_index / 96;
   
   // Scale ball_x from range 0..127 to OLED width 0..95.
   wire [6:0] oled_ball_x;
   assign oled_ball_x = (ball_x * 96) / 128;
   // Assume ball_y is already in range 0..63.
   
   // Paddle drawing parameters:
   // Draw the paddle as a vertical green block at x positions 8 to 10, centered at paddle_y.
   localparam PADDLE_X_MIN = 8;
   localparam PADDLE_X_MAX = 10;
   localparam PADDLE_HEIGHT = 11;  // Total height; paddle covers ±5 pixels from center.
   wire [5:0] paddle_y_min = (paddle_y > 5) ? (paddle_y - 5) : 0;
   wire [5:0] paddle_y_max = (paddle_y < 59) ? (paddle_y + 5) : 63;
   
   always @(*) begin
       // Default: black background.
       pixel_data = 16'h0000;
       // Draw the ball as a 5×5 white block.
       if ((x >= oled_ball_x - 2) && (x <= oled_ball_x + 2) &&
           (y >= ball_y - 2) && (y <= ball_y + 2))
           pixel_data = 16'hFFFF;  // White.
       // Draw the paddle as a green rectangle.
       else if ((x >= PADDLE_X_MIN) && (x <= PADDLE_X_MAX) &&
                (y >= paddle_y_min) && (y <= paddle_y_max))
           pixel_data = 16'h07E0;  // Green (RGB565).
       else
           pixel_data = 16'h0000;  // Black background.
   end
endmodule