`timescale 1ns / 1ps

module Oled_Graphics2(
    input [6:0] x,
    input [5:0] y,
    input [6:0] ball_x,
    input [5:0] ball_y,
    input ball_stuck,
    input [6:0] paddle_x,
    output reg [15:0] oled_data
);
    parameter BALL_SIZE = 5;
    parameter PADDLE_WIDTH = 40;
    parameter PADDLE_HEIGHT = 10;
    parameter PADDLE_Y_POS = 54;
    
    reg [4:0] background_blue;
    reg [5:0] background_green;
    reg [4:0] background_red;
    reg [15:0] background_color;
    
    always @(*) begin
     
        // Create a simple gradient background (blue varies with y).
        background_blue  = y[5:1];
        background_green = 6'd16;
        background_red   = 5'd0;
        background_color = {background_red, background_green, background_blue};
        
        oled_data = background_color;
        
        // Draw the ball.
        if ((x >= ball_x) && (x < ball_x + BALL_SIZE) &&
            (y >= ball_y) && (y < ball_y + BALL_SIZE)) begin
            if (ball_stuck)
                oled_data = 16'hFFE0; // Yellow when attached.
            else
                oled_data = 16'hFFFF; // White when free.
        end
        // Draw the paddle.
        else if ((x >= paddle_x) && (x < paddle_x + PADDLE_WIDTH) &&
                 (y >= PADDLE_Y_POS) && (y < PADDLE_Y_POS + PADDLE_HEIGHT))
            oled_data = 16'h07E0; // Green.
    end
endmodule
