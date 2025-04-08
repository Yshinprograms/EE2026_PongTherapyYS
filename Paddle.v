// Description:
// Manages the player's paddle for a Breakout-style game.
// - The paddle is positioned horizontally based on mouse input.
// - It is fixed vertically at the bottom of the screen.
// - It calculates its own visibility for rendering (paddle_pixel).
// - It outputs its current horizontal position for game logic (e.g., ball collision).
//
// Target Environment:
// - Screen Resolution: 96x64 pixels
// - Input: Absolute mouse X coordinate (12-bit)
//-----------------------------------------------------------------------------
module Paddle (
    // --- Inputs ---
    input clk,                    // System clock input (for synchronous updates)
    input reset,                  // System reset signal (synchronous)
    input new_event,              // Signal pulsed high for one clock cycle when a new mouse reading (x_position) is available
    input [11:0] x_position,      // Raw absolute X position from the mouse (0 to 4095)
    input [5:0] current_pixel_y,  // Current Y coordinate being drawn by the display controller (0 to 63)
    input [6:0] current_pixel_x,  // Current X coordinate being drawn by the display controller (0 to 95)

    // --- Outputs ---
    output [6:0] paddle_x_pos,    // Current X position of the *left edge* of the paddle (0 to 82). Used for ball collision detection.
    output paddle_pixel     // High (1) if the current pixel (current_pixel_x, current_pixel_y) is part of the paddle; otherwise Low (0).
);
    
    // Module parameters
    parameter PADDLE_WIDTH = 14;
    parameter PADDLE_HEIGHT = 3;
    
    // Scaling factor for mouse movement. A larger number means less sensitive mouse control.
    // Maps the raw mouse X range (0-4095) to the paddle's on-screen X range (0-82).
    // Example: Mouse at 160 -> Paddle at 160/16 = 10. Mouse at 1312 -> Paddle at 1312/16 = 82.
    parameter MOUSE_SENSITIVITY_DIVIDER = 16;
    parameter SCREEN_WIDTH = 96;
    parameter SCREEN_HEIGHT = 64;
    
    // Initial horizontal position (left edge) of the paddle on reset.
    // Calculated to center the paddle roughly horizontally: (96 / 2) - (14 / 2) = 48 - 7 = 41
    parameter RESET_POSITION = (SCREEN_WIDTH / 2) - (PADDLE_WIDTH / 2);    
    parameter PADDLE_OFFSET_BOUNDARY = (SCREEN_WIDTH - PADDLE_WIDTH) * MOUSE_SENSITIVITY_DIVIDER;
    
    // Paddle position register
    reg [6:0] paddle_x = RESET_POSITION;
    
    // Update paddle position based on mouse events
    always @(posedge clk) begin
        if (reset) begin
            paddle_x <= RESET_POSITION;
        end else if (new_event) begin
            // Keep paddle within screen boundaries
            if (x_position <= PADDLE_OFFSET_BOUNDARY)
                paddle_x <= x_position / MOUSE_SENSITIVITY_DIVIDER;
            else
                paddle_x <= SCREEN_WIDTH - PADDLE_WIDTH;
        end
    end
    
    // Determine if current pixel is part of the paddle
    assign paddle_pixel = (current_pixel_y >= (SCREEN_HEIGHT - PADDLE_HEIGHT) && 
                         current_pixel_y < SCREEN_HEIGHT &&
                         current_pixel_x >= paddle_x && 
                         current_pixel_x < (paddle_x + PADDLE_WIDTH));
    
    // Output paddle position for game logic
    assign paddle_x_pos = paddle_x;
    
endmodule
