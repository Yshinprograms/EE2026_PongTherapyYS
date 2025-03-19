`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 16:51:30
// Design Name: 
// Module Name: Top_Student
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



module Top_Student (
    input clk,           // Board clock (PACKAGE_PIN W5)
    input btnC,          // Reset button (btnC, PACKAGE_PIN U18)
    input btnU,          // Up button (for paddle movement; e.g., PACKAGE_PIN T18)
    input btnD,          // Down button (for paddle movement; e.g., PACKAGE_PIN U17)
    // OLED interface signals (mapped to Pmod JB header)
    output [7:0] JB,          // pmoden
    // 7-Segment Display outputs
    output [6:0] seg,    // 7-segment segments
    output [3:0] an,     // 7-seg anodes
    output dp            // 7-seg decimal point
);

    // Generate clocks for the OLED using your flexible_clock modules.
    wire clk_sixpt25mHz;
    wire clk_25MHz;
    flexible_clock sixpt25MHz_inst (
        .clk(clk),
        .divisor(7),
        .clk_out(clk_sixpt25mHz)
    );
    flexible_clock twenty5MHz_inst (
        .clk(clk),
        .divisor(1),
        .clk_out(clk_25MHz)
    );
    
    // Instantiate the paddle control module.
    wire [7:0] paddle_y;
    paddle_control u_paddle_control (
        .clk(clk),
        .reset(btnC),
        .btnU(btnU),
        .btnD(btnD),
        .paddle_y(paddle_y)
    );
    
    // Instantiate the ball logic module.
    wire [7:0] ball_x;
    wire [7:0] ball_y;
    wire [15:0] score;
    wire [3:0] lives;
    wire game_over;
    
    ball_logic u_ball_logic (
        .clk(clk),
        .reset(btnC),
        .paddle_y(paddle_y),  // Provided by paddle_control module.
        .ball_x(ball_x),
        .ball_y(ball_y),
        .score(score),
        .lives(lives),
        .game_over(game_over)
    );
    
    // Instantiate the OLED graphics module (drawing both ball and paddle).
    wire [12:0] pixel_index;
    wire [15:0] pixel_data;
    
    oled_graphics u_oled_graphics (
        .pixel_index(pixel_index),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddle_y(paddle_y),
        .pixel_data(pixel_data)
    );
    
    // Instantiate your provided Oled_Display module.
    wire fb;
    wire samp_pix;
    wire send_pix;
    
    Oled_Display oled_unit_A (
        .clk(clk_sixpt25mHz), 
        .reset(0),         // For demo, tied low; you may connect btnC if desired.
        .frame_begin(fb), 
        .sending_pixels(send_pix),
        .sample_pixel(samp_pix), 
        .pixel_index(pixel_index), 
        .pixel_data(pixel_data), 
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7])
    );
    
    // --- Seven-Segment Display for Ball Positions ---
    // Scale ball_x from 0..127 to OLED width range (0..95) for display.
    wire [7:0] scaled_ball_x;
    assign scaled_ball_x = (ball_x * 96) / 128;
    // Use ball_y as is (0..63).
    
    // Instantiate BCD converters (assumes numbers are less than 100).
    wire [3:0] ball_x_tens, ball_x_ones;
    wire [3:0] ball_y_tens, ball_y_ones;
    
    bcd_converter conv_x (
        .number(scaled_ball_x),
        .tens(ball_x_tens),
        .ones(ball_x_ones)
    );
    
    bcd_converter conv_y (
        .number(ball_y),
        .tens(ball_y_tens),
        .ones(ball_y_ones)
    );
    
    // Instantiate seven-seg multiplexer.
    // We'll display: [Digit3 Digit2] = ball_x, [Digit1 Digit0] = ball_y.
    seven_seg_mux u_seven_seg_mux (
        .clk(clk), 
        .reset(btnC),
        .digit0(ball_y_ones),  // Rightmost digit: ones of ball_y
        .digit1(ball_y_tens),  // Tens of ball_y
        .digit2(ball_x_ones),  // Ones of ball_x
        .digit3(ball_x_tens),  // Tens of ball_x
        .an(an),
        .seg(seg)
    );
    assign dp = 1'b1; // Turn off the decimal point (active low; adjust as needed)
    
endmodule



//2nd Try 0030 hrs 16th march
//module Top_Student(
//input clk,          // Board clock (PACKAGE_PIN W5)
//    input btnC,         // Reset button (PACKAGE_PIN U18)
//    input [15:0] sw,    // Switches (using sw[7:0] for paddle_y)
//    output [15:0] led,  // LEDs: lower 8 for ball_x, upper 8 for ball_y (for debug)
//    // OLED interface signals mapped to Pmod JB header:
//    output [7:0] JB
//);

//    // Generate clocks for OLED:
//    wire clk_sixpt25mHz;
//    wire clk_25MHz;
//    flexible_clock sixpt25MHz_inst (
//        .clk(clk),
//        .divisor(7),
//        .clk_out(clk_sixpt25mHz)
//    );
//    flexible_clock twenty5MHz_inst (
//        .clk(clk),
//        .divisor(1),
//        .clk_out(clk_25MHz)
//    );
    
//    // Instantiate the ball logic module.
//    wire [7:0] ball_x;
//    wire [7:0] ball_y;
//    wire [15:0] score;
//    wire [3:0] lives;
//    wire game_over;
    
//    ball_logic u_ball_logic (
//        .clk(clk),
//        .reset(btnC),
//        .paddle_y(sw[7:0]),
//        .ball_x(ball_x),
//        .ball_y(ball_y),
//        .score(score),
//        .lives(lives),
//        .game_over(game_over)
//    );
    
//    // For debugging: map ball_x and ball_y to the 16 onboard LEDs.
//    assign led[7:0]  = ball_x;
//    assign led[15:8] = ball_y;
    
//    // Instantiate the OLED graphics module.
//    wire [12:0] pixel_index;
//    wire [15:0] pixel_data;
    
//    oled_graphics u_oled_graphics (
//        .pixel_index(pixel_index),
//        .ball_x(ball_x),
//        .ball_y(ball_y),
//        .score(score),
//        .lives(lives),
//        .game_over(game_over),
//        .pixel_data(pixel_data)
//    );
    
//    // Instantiate the provided Oled_Display module.
//    wire fb;
//    wire samp_pix;
//    wire send_pix;
    
//    Oled_Display oled_unit_A (
//        .clk(clk_sixpt25mHz), 
//        .reset(0),         // For demo, we tie reset low (or connect btnC if preferred)
//        .frame_begin(fb), 
//        .sending_pixels(send_pix),
//        .sample_pixel(samp_pix), 
//        .pixel_index(pixel_index), 
//        .pixel_data(pixel_data), 
//        .cs(JB[0]), 
//        .sdin(JB[1]), 
//        .sclk(JB[3]), 
//        .d_cn(JB[4]), 
//        .resn(JB[5]), 
//        .vccen(JB[6]),
//        .pmoden(JB[7])
//    );
    
//endmodule


//module Top_Student(
//input CLOCK,
//    input sw,              // (Unused in this task; reserved for future use)
//    input activate_task,
//    input reset_task,      // Reset signal from the integration module
//    input btnR,          // Pushbutton for right movement
//    input btnL,          // Pushbutton for left movement
//    input btnU,          // Pushbutton for upward movement
//    input btnD,          // Pushbutton for downward movement
//    output [7:0] JB
//);



//    // Clock generation and OLED interface signals
//    wire clk_sixpt25mHz;
//    wire clk_25MHz;
//    wire fb;
//    wire samp_pix;
//    wire send_pix;
//    wire [12:0] pixel_index;
//    reg [15:0] oled_data;
    
//    flexible_clock sixpt25MHz (CLOCK, 7, clk_sixpt25mHz);
//    flexible_clock twenty5MHz (CLOCK, 1, clk_25MHz);
    
//    Oled_Display oled_unit_A(
//            .clk(clk_sixpt25mHz), 
//            .reset(0), 
//            .frame_begin(fb), 
//            .sending_pixels(send_pix),
//            .sample_pixel(samp_pix), 
//            .pixel_index(pixel_index), 
//            .pixel_data(oled_data), 
//            .cs(JB[0]), 
//            .sdin(JB[1]), 
//            .sclk(JB[3]), 
//            .d_cn(JB[4]), 
//            .resn(JB[5]), 
//            .vccen(JB[6]),
//            .pmoden(JB[7])
//        );
        
        
//            // Screen dimensions and coordinate conversion
//        parameter SCREEN_WIDTH  = 96;
//        parameter SCREEN_HEIGHT = 64;
        
//        // x and y are derived from pixel_index
//        wire [6:0] x;
//        wire [5:0] y;
//        assign x = pixel_index % SCREEN_WIDTH;
//        assign y = pixel_index / SCREEN_WIDTH;
//        endmodule
        