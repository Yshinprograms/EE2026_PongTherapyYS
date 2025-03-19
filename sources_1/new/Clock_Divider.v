`timescale 1ns / 1ps
module Clock_Divider( 
    input CLOCK, 
    input [31:0] m, 
    output reg SLOW_CLOCK
    );
    
    reg [31:0] count;
    initial begin
        count = 0;
        SLOW_CLOCK = 0;
    end

    always @(posedge CLOCK) begin
        count <= (count == m)? 0: count +1;
        SLOW_CLOCK <= (count == 0)? ~SLOW_CLOCK : SLOW_CLOCK;
    end
   
endmodule