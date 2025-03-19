`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 00:54:58
// Design Name: 
// Module Name: seven_seg_mux
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


module seven_seg_mux(
    input clk,
    input reset,
    input [3:0] digit0,  // Rightmost digit
    input [3:0] digit1,
    input [3:0] digit2,
    input [3:0] digit3,  // Leftmost digit
    output reg [3:0] an, // Active-low anode signals for 4 digits
    output reg [6:0] seg // 7-segment segments (active low)
);
    // A simple counter to refresh digits
    reg [15:0] refresh_counter;
    reg [1:0] digit_sel;

    // Increment refresh counter to cycle through digits
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 0;
            digit_sel <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            // Change digit when counter overflows (adjust threshold if necessary)
            if (refresh_counter == 16'hFFFF)
                digit_sel <= digit_sel + 1;
        end
    end

    // Select current digit and corresponding anode
    reg [3:0] current_digit;
    always @(*) begin
        case(digit_sel)
            2'b00: begin current_digit = digit0; an = 4'b1110; end
            2'b01: begin current_digit = digit1; an = 4'b1101; end
            2'b10: begin current_digit = digit2; an = 4'b1011; end
            2'b11: begin current_digit = digit3; an = 4'b0111; end
            default: begin current_digit = 4'b0000; an = 4'b1111; end
        endcase
    end

    // 7-segment decoder (active low)
    always @(*) begin
        case(current_digit)
            4'd0: seg = 7'b1000000;
            4'd1: seg = 7'b1111001;
            4'd2: seg = 7'b0100100;
            4'd3: seg = 7'b0110000;
            4'd4: seg = 7'b0011001;
            4'd5: seg = 7'b0010010;
            4'd6: seg = 7'b0000010;
            4'd7: seg = 7'b1111000;
            4'd8: seg = 7'b0000000;
            4'd9: seg = 7'b0010000;
            default: seg = 7'b1111111; // Blank
        endcase
    end

endmodule
