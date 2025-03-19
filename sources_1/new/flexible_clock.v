`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2025 16:22:29
// Design Name: 
// Module Name: flexible_clock
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


module flexible_clock(input clk,input [31:0] divisor,output reg clk_out = 0);

    reg [31:0] COUNT = 32'b0000;
    always @ (posedge clk)
    begin
    COUNT <= ( COUNT == divisor) ? 0 : COUNT + 1;
    clk_out <= (COUNT == 32'b0000)? ~clk_out : clk_out;
    end
    
endmodule
