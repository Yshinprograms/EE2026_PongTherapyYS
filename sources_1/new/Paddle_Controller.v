`timescale 1ns / 1ps

module Paddle_Controller(
    input clk,
    input reset,
    input activate,         // Active-high: game running
    input btnR,             // Debounced right button
    input btnL,             // Debounced left button
    output reg [6:0] paddle_x
);
    parameter SCREEN_WIDTH  = 96;
    parameter PADDLE_WIDTH  = 40;
    parameter PADDLE_MOVE_COUNT_LIMIT = 833333;
    
    reg [31:0] move_counter;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            move_counter <= 0;
            paddle_x <= 0;
        end else if (activate) begin
            if (move_counter < PADDLE_MOVE_COUNT_LIMIT)
                move_counter <= move_counter + 1;
            else begin
                move_counter <= 0;
                if (btnR && (paddle_x < SCREEN_WIDTH - PADDLE_WIDTH))
                    paddle_x <= paddle_x + 1;
                else if (btnL && (paddle_x > 0))
                    paddle_x <= paddle_x - 1;
            end
        end
    end
endmodule
