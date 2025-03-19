`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2025 23:51:30
// Design Name: 
// Module Name: Score_Display
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


module Score_Display(
    input clk,
    input reset,         // When high, STOP mode is active.
    input [7:0] score,
    output reg [6:0] seg,
    output reg [3:0] an
);

    //--------------------------------------------------------------------------
    // Refresh logic for multiplexing the 4-digit 7-seg display.
    // The refresh counter cycles through current_digit (0 to 3) continuously.
    parameter SEG_REFRESH_LIMIT = 50000;
    reg [15:0] seg_refresh_counter;
    reg [1:0] current_digit;
    
    always @(posedge clk) begin
        if (seg_refresh_counter < SEG_REFRESH_LIMIT)
            seg_refresh_counter <= seg_refresh_counter + 1;
        else begin
            seg_refresh_counter <= 0;
            // Always cycle through 0-3 regardless of reset state.
            current_digit <= (current_digit == 3) ? 0 : current_digit + 1;
        end
    end

    //--------------------------------------------------------------------------
    // Determine number of digits needed for score (PLAY mode)
    reg [1:0] num_digits;
    always @(*) begin
        if (score < 10)
            num_digits = 1;
        else if (score < 100)
            num_digits = 2;
        else if (score < 1000)
            num_digits = 3;
        else 
            num_digits = 4;
    end

    //--------------------------------------------------------------------------
    // Break score into individual decimal digits.
    reg [3:0] digit0, digit1, digit2, digit3; // ones, tens, hundreds, thousands
    always @(*) begin
        digit0 = score % 10;
        digit1 = (score / 10) % 10;
        digit2 = (score / 100) % 10;
        digit3 = (score / 1000);  // For scores < 1000, this will be 0.
    end

    //--------------------------------------------------------------------------
    // Multiplexer for selecting which digit value to display.
    // In PLAY mode (reset low), we choose the digit from the score.
    // In STOP mode (reset high), we ignore the score and use the current_digit
    // value to select a fixed mapping that spells "STOP".
    reg [3:0] current_value;
    always @(*) begin
        if (reset) begin
            // Use current_digit directly for STOP mode.
            // The mapping below is:
            // current_digit = 0 -> display letter for "P"
            // current_digit = 1 -> display letter for "O"
            // current_digit = 2 -> display letter for "T"
            // current_digit = 3 -> display letter for "S"
            case(current_digit)
                2'd0: begin current_value = 4'd0; an = 4'b1110; end  // rightmost digit
                2'd1: begin current_value = 4'd1; an = 4'b1101; end
                2'd2: begin current_value = 4'd2; an = 4'b1011; end
                2'd3: begin current_value = 4'd3; an = 4'b0111; end  // leftmost digit
                default: begin current_value = 0; an = 4'b1111; end
            endcase
        end else begin
// In PLAY mode, only activate digits that are needed.
                case(current_digit)
                    2'd0: begin current_value = digit0; an = 4'b1110; end
                    2'd1: begin 
                        if (num_digits > 1) 
                            current_value = digit1; 
                        else 
                            current_value = 4'd0;
                        an = (num_digits > 1) ? 4'b1101 : 4'b1111;
                    end
                    2'd2: begin 
                        if (num_digits > 2)
                            current_value = digit2; 
                        else 
                            current_value = 4'd0;
                        an = (num_digits > 2) ? 4'b1011 : 4'b1111;
                    end
                    2'd3: begin 
                        if (num_digits > 3)
                            current_value = digit3; 
                        else 
                            current_value = 4'd0;
                        an = (num_digits > 3) ? 4'b0111 : 4'b1111;
                    end
                    default: begin current_value = 0; an = 4'b1111; end
                endcase
            end
        end
    //--------------------------------------------------------------------------
    // Define letter patterns for STOP.
    // Note: We use 8-bit constants here but then select the lower 7 bits.
    parameter S = 8'b10010010;
    parameter T = 8'b10000111;
    parameter O = 8'b11000000;
    parameter P = 8'b10001100;

    // Seven-segment decoder.
    // In STOP mode (reset high), decode current_value to letters:
    //  0 => P, 1 => O, 2 => T, 3 => S.
    // In PLAY mode, decode current_value as a digit (0-9).
    always @(*) begin
        if (reset) begin 
            case(current_value)
                4'd0: seg = P[6:0];  // P for digit 0.
                4'd1: seg = O[6:0];  // O for digit 1.
                4'd2: seg = T[6:0];  // T for digit 2.
                4'd3: seg = S[6:0];  // S for digit 3.
                default: seg = 8'b11111111;
            endcase
        end else begin
            case(current_value)
                4'd0: seg = 8'b11000000;
                4'd1: seg = 8'b11111001;
                4'd2: seg = 8'b10100100;
                4'd3: seg = 8'b10110000;
                4'd4: seg = 8'b10011001;
                4'd5: seg = 8'b10010010;
                4'd6: seg = 8'b10000010;
                4'd7: seg = 8'b11111000;
                4'd8: seg = 8'b10000000;
                4'd9: seg = 8'b10010000;
                default: seg = 8'b11111111;
            endcase
        end
    end

endmodule


//18th March 2219 iteration
//module Score_Display(
//    input clk,
//    input reset,
//    input [7:0] score,
//    output reg [6:0] seg,
//    output reg [3:0] an
//);

////because there can only be 1 display for the 7 segment,
////needs to cycle quickly to check which digit is on now
//    parameter SEG_REFRESH_LIMIT = 50000;
//    reg [15:0] seg_refresh_counter;
//    reg [1:0] current_digit;
//    reg [1:0] num_digits;
    
//    //In "PLAY" mode, determine how many digits are required to show on the scoreboard
    
//    always@(*) begin
//    if (score < 10)
//        num_digits <= 1;
//    else if (score < 100)
//        num_digits <= 2;
//    else if (score < 1000)
//        num_digits <= 3;
//    else 
//        num_digits <= 4;
//    end
  
 
    
    
//always @(posedge clk) begin

////remove the posedge reset part and check for reset condition here instead
//    if (reset) begin
//        // Even in reset mode, let the refresh counter run so that
//        // current_digit cycles through 0 to 3.
////        if (seg_refresh_counter < SEG_REFRESH_LIMIT)
////            seg_refresh_counter <= seg_refresh_counter + 1;
////        else begin
////            seg_refresh_counter <= 0;
////            current_digit <= (current_digit == 3) ? 0 : current_digit + 1;
////        end
////        end else begin
//            if(seg_refresh_counter < SEG_REFRESH_LIMIT)
//                seg_refresh_counter <= seg_refresh_counter + 1;
//            else begin
//                seg_refresh_counter <= 0;
//                 // Always cycle through 0-3 regardless of reset.
//                       current_digit <= (current_digit == 3) ? 0 : current_digit + 1;
                
//                //THIS LOGIC HERE means it will use up all the digits and show STOP
                
//                //MIGHT BE REDUNDANT HERE BECAUSE IF RESET, WILL JUST ENTER THE FIRST BRANCH
//                if(reset) begin
//                    // In stop mode, cycle through 0-3 always.
//                    //this means that all the digit will displayed once in any pt in time
//                    //HOWEVER, IT IS SO FAST THAT IT SEEMS THAT ALL IS turned on together
//                    current_digit <= (current_digit == 3) ? 0 : current_digit + 1;
//                end else begin
//                    // In normal mode, only cycle through needed digits.
//                    if(current_digit == num_digits - 1)
//                        current_digit <= 0;
//                    else
//                        current_digit <= current_digit + 1;
//                end
//            end
//        end
//    end
    
//    // Break score into decimal digits.
//    reg [3:0] digit0, digit1, digit2, digit3; // ones, tens, hundreds, thousands
//    always @(*) begin
//        digit0 = score % 10;
//        digit1 = (score / 10) % 10;
//        digit2 = (score / 100) % 10;
//        digit3 = (score / 1000);  // For scores < 1000, this will be 0.
//    end
    
//    reg [3:0] current_value;
//    always @(*) begin
//        case(current_digit)
//            2'd0: begin current_value = digit0; an = 4'b1110; end // ones active (active low)
//            2'd1: begin current_value = digit1; an = 4'b1101; end // tens active
//            2'd2: begin current_value = digit2; an = 4'b1011; end // hundreds active
//            2'd3: begin current_value = digit3; an = 4'b0111; end // thousands active
//            default: begin current_value = 0; an = 4'b1111; end
//        endcase
//    end
    
//    parameter S = 8'b11011001;
//    parameter T = 8'b10001110;
//    parameter O = 8'b11000000;
//    parameter P = 8'b10001100;

//    always @(*) begin
//        if (reset) begin 
//            case(current_value)
//                4'd0: seg = P;
//                4'd1: seg = O;
//                4'd2: seg = T;
//                4'd3: seg = S;
//                default: seg = 8'b11111111;
//            endcase
//        end else begin
        
//    // 7-segment decoder.
//        case(current_value)
//            4'd0: seg = 8'b11000000;
//            4'd1: seg = 8'b11111001;
//            4'd2: seg = 8'b10100100;
//            4'd3: seg = 8'b10110000;
//            4'd4: seg = 8'b10011001;
//            4'd5: seg = 8'b10010010;
//            4'd6: seg = 8'b10000010;
//            4'd7: seg = 8'b11111000;
//            4'd8: seg = 8'b10000000;
//            4'd9: seg = 8'b10010000;
//            default: seg = 8'b11111111;
//          endcase
//        end
//    end
    
//endmodule

