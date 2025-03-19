`timescale 1ns / 1ps

module Ball_Controller(
    input clk,
    input reset,
    input activate,         // Active-high: game running
    input shoot,            // Debounced shoot signal
    input [6:0] paddle_x,   // Current paddle horizontal position
    output reg [6:0] ball_x,
    output reg [5:0] ball_y,
    output reg [7:0] score,
    output reg ball_stuck
);
    parameter SCREEN_WIDTH = 96;
    parameter PADDLE_Y_POS = 54;  // Example: 64 - PADDLE_HEIGHT (10)
    parameter BALL_SIZE    = 5;
    parameter PADDLE_WIDTH = 40;
    parameter BALL_MOVE_COUNT_LIMIT = 750000;  //controls the ball speed
    
    reg signed [1:0] ball_dx;
    reg signed [1:0] ball_dy;
    reg [31:0] ball_move_counter;
    reg shoot_prev;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ball_stuck <= 1; // Ball starts attached to the paddle.
            ball_x <= paddle_x + ((PADDLE_WIDTH - BALL_SIZE) >> 1);
            ball_y <= PADDLE_Y_POS - BALL_SIZE;
            ball_move_counter <= 0;
            ball_dx <= 0;
            ball_dy <= 0;
            shoot_prev <= 0;
            score <= 0;
        end else if (activate) begin
            if (ball_stuck) begin
                // Follow the paddle.
                ball_x <= paddle_x + ((PADDLE_WIDTH - BALL_SIZE) >> 1);
                ball_y <= PADDLE_Y_POS - BALL_SIZE;
                ball_move_counter <= 0;
                // Launch the ball on a rising edge of shoot.
                if (shoot && !shoot_prev) begin
                    ball_stuck <= 0;
                    ball_dx <= 1;    // Fixed horizontal velocity.
                    ball_dy <= -1;   // Fixed upward velocity.
                end
            end else begin
                // Ball is free; update its position.
                if (ball_move_counter < BALL_MOVE_COUNT_LIMIT)
                    ball_move_counter <= ball_move_counter + 1;
                else begin
                    ball_move_counter <= 0;
                    ball_x <= ball_x + ball_dx;
                    ball_y <= ball_y + ball_dy;
                    
                    // Bounce off side walls.
                    if (ball_x <= 0 || ball_x >= SCREEN_WIDTH - BALL_SIZE)
                        ball_dx <= -ball_dx;
                    // Bounce off top wall.
                    if (ball_y <= 0)
                        ball_dy <= -ball_dy;
                    
                    // Bounce off the paddle (only if moving downward).
                    if ((ball_y + BALL_SIZE >= PADDLE_Y_POS) && (ball_dy > 0)) begin
                        if ((ball_x + BALL_SIZE > paddle_x) && (ball_x < paddle_x + PADDLE_WIDTH)) begin
                            ball_dy <= -ball_dy;
                            score <= score + 1;
                        end
                    end
                end
            end
            shoot_prev <= shoot;
        end
    end
endmodule
