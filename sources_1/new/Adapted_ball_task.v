`timescale 1ns / 1ps

module Adapted_ball_task_top(
    input clk,            // Board clock (e.g., PACKAGE_PIN W5)
    input sw,             // Unused
    input activate_task,  // Active-high: system running; low = paused
    input reset_task,     // Active-high reset signal
    input btnR,           // Right movement button
    input btnL,           // Left movement button
    input shoot,          // Shoot/launch button
    input btnD,           // Unused
    output [7:0] JB,      // OLED interface signals (JB[0] to JB[7])
    output [6:0] seg,     // 7-seg segments output
    output [3:0] an,      // 7-seg digit enable signals (active low)
    output [15:0] led     // LED outputs: show reset/paused status
);
    
    parameter S = 8'b10010010;   //[S]
    parameter T = 8'b10000111;   //[T]
    parameter O = 8'b11000000;   //[O]
    parameter P = 8'b10110010;   //[P]
       
    //-------------------------------------------------------------------------
    // LED control: For example, assign LED[1] = reset, LED[0] = paused.
    assign led[1] = reset_task; 
    assign led[0] = ~activate_task;
  
    // The remaining bits of led can be tied to 0 or used as needed.
    
    //-------------------------------------------------------------------------
    // Clock Generation (assuming flexible_clock modules are available).
    wire clk_sixpt25mHz;
    wire clk_25MHz;
    flexible_clock clkGen1 (.clk(clk), .divisor(7), .clk_out(clk_sixpt25mHz));
    flexible_clock clkGen2 (.clk(clk), .divisor(1), .clk_out(clk_25MHz));
    
    //-------------------------------------------------------------------------
    // Debouncers for buttons.
    wire btnR_db, btnL_db, shoot_db;
    debounce dbR (.clk(clk_25MHz), .reset(reset_task), .noisy(btnR), .clean(btnR_db));
    debounce dbL (.clk(clk_25MHz), .reset(reset_task), .noisy(btnL), .clean(btnL_db));
    debounce dbShoot (.clk(clk_25MHz), .reset(reset_task), .noisy(shoot), .clean(shoot_db));
    
    //-------------------------------------------------------------------------
    // Instantiate Paddle_Controller.
    wire [6:0] paddle_x;
    Paddle_Controller paddleCtrl(
        .clk(clk_25MHz),
        .reset(reset_task),
        .activate(activate_task),
        .btnR(btnR_db),
        .btnL(btnL_db),
        .paddle_x(paddle_x)
    );
    
    //-------------------------------------------------------------------------
    // Instantiate Ball_Controller.
    wire [6:0] ball_x;
    wire [5:0] ball_y;
    wire [7:0] score;
    wire ball_stuck;
    Ball_Controller ballCtrl(
        .clk(clk_25MHz),
        .reset(reset_task),
        .activate(activate_task),
        .shoot(shoot_db),
        .paddle_x(paddle_x),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .score(score),
        .ball_stuck(ball_stuck)
    );
    
    //-------------------------------------------------------------------------
    // Instantiate Score_Display.
    Score_Display scoreDisp(
        .clk(clk_25MHz),
        .reset(reset_task),
        .score(score),
        .seg(seg),
        .an(an)
    );
    
    //-------------------------------------------------------------------------
    // Instantiate the provided Oled_Display module.
    wire fb, samp_pix, send_pix;
    wire [12:0] pixel_index;
    wire [15:0] oled_data;   //change from reg to wire so that iit can be used to connect module outputs and inputs
    Oled_Display oled_unit_A(
        .clk(clk_sixpt25mHz),
        .reset(0),
        .frame_begin(fb),
        .sending_pixels(send_pix),
        .sample_pixel(samp_pix),
        .pixel_index(pixel_index),
        .pixel_data(oled_data),
        .cs(JB[0]),
        .sdin(JB[1]),
        .sclk(JB[3]),
        .d_cn(JB[4]),
        .resn(JB[5]),
        .vccen(JB[6]),
        .pmoden(JB[7])
    );
    
    //-------------------------------------------------------------------------
    // Extract pixel coordinates.
    wire [6:0] x;
    wire [5:0] y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    //-------------------------------------------------------------------------
    // Instantiate Oled_Graphics to compute pixel color.
    Oled_Graphics2 oledGraphics(
        .x(x),
        .y(y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .ball_stuck(ball_stuck),
        .paddle_x(paddle_x),
        .oled_data(oled_data)
    );
endmodule
