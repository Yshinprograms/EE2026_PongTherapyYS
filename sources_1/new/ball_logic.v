`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 00:01:18
// Design Name: 
// Module Name: ball_logic
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


module ball_logic (
    input clk,
    input reset,
    input [7:0] paddle_y,  // Paddle vertical position from paddle_control module
    output reg [7:0] ball_x,
    output reg [7:0] ball_y,
    output reg [15:0] score,
    output reg [3:0] lives,
    output reg game_over
);

    // Game area parameters
    parameter MAX_X = 128;
    parameter MAX_Y = 64;
    parameter PADDLE_X = 10;      // X position for collision (and paddle display)
    parameter PADDLE_RANGE = 2;   // Allowed vertical offset for collision

    // Ball direction (using signed values)
    reg signed [3:0] dx;
    reg signed [3:0] dy;

    // Clock divider to slow down ball updates for demo visibility
    reg [23:0] counter;
    wire tick = (counter == 0);

    always @(posedge clk or posedge reset) begin
        if (reset)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // Ball movement and collision logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
             ball_x    <= MAX_X - 1;
             ball_y    <= MAX_Y / 2;
             dx        <= -1;  // Ball starts moving leftwards
             dy        <= 1;   // Ball starts moving downwards
             score     <= 0;
             lives     <= 3;
             game_over <= 0;
        end else if (tick && !game_over) begin
             // Update ball position
             ball_x <= ball_x + dx;
             ball_y <= ball_y + dy;
             
             // Bounce off top or bottom edges
             if ((ball_y == 0) || (ball_y == MAX_Y - 1))
                 dy <= -dy;
             
             // When ball reaches the paddle's X position:
             if (ball_x == PADDLE_X) begin
                  if ((paddle_y >= ball_y - PADDLE_RANGE) && (paddle_y <= ball_y + PADDLE_RANGE)) begin
                         dx <= -dx;
                         score <= score + 1;
                  end else begin
                         if (lives > 0)
                             lives <= lives - 1;
                         if (lives == 1)
                             game_over <= 1;
                         
                         // Reset ball position/direction after a miss
                         ball_x <= MAX_X - 1;
                         ball_y <= MAX_Y / 2;
                         dx <= -1;
                         dy <= 1;
                  end
             end else if (ball_x == MAX_X - 1) begin
                  dx <= -dx; // Bounce off the right edge
             end
        end
    end

endmodule



//module ball_logic (
//    input clk,
//    input reset,
//    input [7:0] paddle_y,  // Paddle vertical position (from Member 1)
//    output reg [7:0] ball_x,
//    output reg [7:0] ball_y,
//    output reg [15:0] score,
//    output reg [3:0] lives,
//    output reg game_over
//);

//// Parameters for game area and paddle
//parameter MAX_X = 128;
//parameter MAX_Y = 64;
//parameter PADDLE_X = 10;      // X position of the paddle
//parameter PADDLE_RANGE = 2;   // Allowed vertical offset for collision

//// Ball direction (signed values to allow negative increments)
//reg signed [3:0] dx;
//reg signed [3:0] dy;

//// Clock divider to slow down ball movement updates
//reg [23:0] counter;
//wire tick = (counter == 0);

//always @(posedge clk or posedge reset) begin
//    if (reset)
//        counter <= 0;
//    else
//        counter <= counter + 1;
//end

//// Main game logic: ball movement, collision detection, scoring, and life management.
//always @(posedge clk or posedge reset) begin
//    if (reset) begin
//         // Reset ball to starting position at the right edge and center vertically.
//         ball_x    <= MAX_X - 1;
//         ball_y    <= MAX_Y / 2;
//         dx        <= -1;     // Initially move leftwards
//         dy        <= 1;      // Initially move downwards
//         score     <= 0;
//         lives     <= 3;      // Starting lives
//         game_over <= 0;
//    end else if (tick && !game_over) begin
//         // Update ball position
//         ball_x <= ball_x + dx;
//         ball_y <= ball_y + dy;
         
//         // Bounce off top or bottom edges
//         if ((ball_y == 0) || (ball_y == MAX_Y - 1))
//             dy <= -dy;
         
//         // Check collision when ball reaches the paddle's X position
//         if (ball_x == PADDLE_X) begin
//              // If the paddle is in range (paddle_y within ±PADDLE_RANGE of ball_y)
//              if ((paddle_y >= ball_y - PADDLE_RANGE) && (paddle_y <= ball_y + PADDLE_RANGE)) begin
//                     // Successful hit: reverse horizontal direction and increment score
//                     dx <= -dx;
//                     score <= score + 1;
//              end else begin
//                     // Missed the ball: decrement life and reset ball position
//                     if (lives > 0)
//                         lives <= lives - 1;
//                     if (lives == 1) // After decrement, lives would reach 0
//                         game_over <= 1;
                     
//                     // Reset ball to starting position
//                     ball_x <= MAX_X - 1;
//                     ball_y <= MAX_Y / 2;
//                     dx <= -1;
//                     dy <= 1;
//              end
//         end
//         // Bounce off the right edge of the screen
//         else if (ball_x == MAX_X - 1) begin
//              dx <= -dx;
//         end
//    end
//end

//endmodule
