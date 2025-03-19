`timescale 1ns / 1ps
module Ball(
    input clk,
    input reset,
    input frame_update,
    input [6:0] paddle_x,
    input [6:0] paddle_width,
    output [6:0] ball_x,
    output [5:0] ball_y,
    output [1:0] ball_size
);
    // Internal ball state registers
    reg [6:0] ball_x_reg = 48;
    reg [5:0] ball_y_reg = 32;
    reg signed [2:0] ball_dx = 1;
    reg signed [2:0] ball_dy = 1;
    parameter BALL_SIZE = 2;
    
    // Update ball position
    always @(posedge clk) begin
        if (reset) begin
            // Reset logic
            ball_x_reg <= 48;
            ball_y_reg <= 32;
            ball_dx <= 1;
            ball_dy <= 1;
        end else if (frame_update) begin
            // Update position
            ball_x_reg <= ball_x_reg + ball_dx;
            ball_y_reg <= ball_y_reg + ball_dy;
            
            // Collision logic
            // Wall collisions
            if (ball_x_reg <= 0 || ball_x_reg >= 95)
                ball_dx <= -ball_dx;
            if (ball_y_reg <= 0)
                ball_dy <= -ball_dy;
            
            // Paddle collision
            if (ball_y_reg >= 58 && ball_y_reg < 64 && 
                ball_x_reg >= paddle_x && ball_x_reg < (paddle_x + paddle_width))
                ball_dy <= -ball_dy;
        end
    end
    
    // Assign outputs
    assign ball_x = ball_x_reg;
    assign ball_y = ball_y_reg;
    assign ball_size = BALL_SIZE;
endmodule
