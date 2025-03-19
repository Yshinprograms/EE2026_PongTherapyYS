`timescale 1ns / 1ps

module Pong(
    input clk_100MHz,
    input btnC,
    inout PS2Clk,
    inout PS2Data,
    output [7:0] JC,
    output [3:0] led
    );
    wire clk_6p25MHz;
    Clock_Divider divider_6p25MHz (clk_100MHz, 7, clk_6p25MHz);

    // OLED signals
    wire [15:0] oled_data;
    wire [12:0] pixel_index;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    // Extract x and y coordinates from pixel_index
    wire [6:0] pixel_x = pixel_index % 96;
    wire [5:0] pixel_y = pixel_index / 96;    
    // Instantiate the OLED display module
    Oled_Display oled_display(
        .clk(clk_6p25MHz),
        .reset(btnC),
        .frame_begin(frame_begin),
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel),
        .pixel_index(pixel_index),
        .pixel_data(oled_data),
        .cs(JC[0]),
        .sdin(JC[1]),
        .sclk(JC[3]),
        .d_cn(JC[4]),
        .resn(JC[5]),
        .vccen(JC[6]),
        .pmoden(JC[7])
    );    
    
    // Mouse signals
    wire left, middle, right;
    wire [11:0] xpos, ypos;
    wire [3:0] zpos;
    wire new_event;
    wire [10:0] scaled_x_boundary;
    wire setmax_pulse;

    MouseCtl mouse_control (
        .clk(clk_100MHz), .rst(1'b0),
        .value(scaled_x_boundary),
        // Fix this setmax
        .setx(1'b0), .sety(1'b0), .setmax_x(setmax_pulse), .setmax_y(1'b0),
        .xpos(xpos), .ypos(ypos), .zpos(zpos),
        .left(left), .right(right), .middle(middle),
        .new_event(new_event),
        .ps2_clk(PS2Clk), .ps2_data(PS2Data)
    );
    
    // Paddle signals & instantiation
    wire paddle_pixel;
    wire [6:0] mod96_xpos;
    Paddle paddle_instance(
        .clk(clk_100MHz),
        .reset(btnC),
        .new_event(new_event),
        .x_position(xpos),
        .current_pixel_y(pixel_y),
        .current_pixel_x(pixel_x),
        .left(left),
        .paddle_x_pos(mod96_xpos),
        .paddle_pixel(paddle_pixel),
        .led(led),
        .scaled_x_boundary(scaled_x_boundary),
        .setmax_pulse(setmax_pulse)
    );
    
    // Determine pixel color based on paddle position
    assign oled_data = paddle_pixel ? 16'hFFFF : 16'h0000;

endmodule
