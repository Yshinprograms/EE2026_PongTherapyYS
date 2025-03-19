module Paddle(
    // System inputs
    input clk,                    // Clock input
    input reset,                  // Reset signal
    
    // Mouse inputs
    input new_event,              // Mouse event signal
    input [11:0] x_position,      // X position from mouse
    input left,                   // Left mouse button input
    
    // Display inputs
    input [5:0] current_pixel_y,  // Current Y being drawn
    input [6:0] current_pixel_x,  // Current X being drawn
    
    // Outputs
    output [6:0] paddle_x_pos,    // Paddle X position (for game logic)
    output paddle_pixel,          // Whether to draw paddle at current pixel
    output [3:0] led,             // LED indicators for sensitivity
    output [10:0] scaled_x_boundary, // Max X boundary sent to MouseCtl
    output reg setmax_pulse       // Pulse to update MouseCtl boundary
);   
    // ==========================================
    // Module parameters
    // ==========================================
    parameter PADDLE_WIDTH = 14;
    parameter PADDLE_HEIGHT = 3;
    parameter X_BOUNDARY = 96;
    parameter Y_BOUNDARY = 64;
    
    // ==========================================
    // Mouse sensitivity control
    // ==========================================
    // Mouse sensitivity state and divider tracking
    reg [1:0] sensitivity_state;
    reg [4:0] current_divider;
    reg [4:0] prev_divider;
    reg [3:0] sens_led;
    
    // Debounce left mouse click
    wire debounced_left;
    Debouncer debounce_left (.clk(clk), .button_in(left), .button_posedge(debounced_left));
    
    // Dynamic boundary calculation based on current sensitivity
    wire [11:0] offset_paddle_boundary = (X_BOUNDARY * current_divider) - PADDLE_WIDTH;
    
    // ==========================================
    // Paddle position control
    // ==========================================
    // Reset position calculation
    wire [11:0] reset_position = ((X_BOUNDARY * current_divider) / 2) - PADDLE_WIDTH;
    reg [6:0] paddle_x;
    
    // ==========================================
    // Initialization
    // ==========================================
    reg initialization_done = 0;
    initial begin
        sensitivity_state <= 2'b00;
        current_divider <= 16;
        prev_divider <= 16;
        sens_led <= 4'b0001;
        paddle_x <= reset_position;
    end
    
    // ==========================================
    // Main state machine & logic
    // ==========================================
    always @(posedge clk) begin
        // Edge detection for boundary update pulse
        prev_divider <= current_divider;       
        setmax_pulse <= (current_divider != prev_divider) ? 1'b1 : 1'b0;
    
        // Reset handling
        if (reset) begin
            sensitivity_state <= 2'b00;
            current_divider <= 16;
            sens_led <= 4'b0001;
            paddle_x <= reset_position;
        end else if (!initialization_done) begin
            setmax_pulse <= 1;
            initialization_done <= 1;
        end else begin
            // Sensitivity control - cycles through DPI settings with left mouse button
            if (debounced_left) begin
                sensitivity_state <= sensitivity_state + 1;
                paddle_x <= reset_position;
                
                case(sensitivity_state)
                    2'b00: begin
                        current_divider <= 16;
                        sens_led <= 4'b0001;
                    end
                    2'b01: begin
                        current_divider <= 8;
                        sens_led <= 4'b0010;
                    end
                    2'b10: begin
                        current_divider <= 4;
                        sens_led <= 4'b0100;
                    end
                    2'b11: begin
                        current_divider <= 2;
                        sens_led <= 4'b1000;
                    end
                    default: begin 
                        current_divider <= 16;
                        sens_led <= 4'b0001;
                    end
                endcase
            end
            
            // Paddle position update based on mouse movement
            if (new_event) begin
                if (x_position <= offset_paddle_boundary)
                    paddle_x <= x_position / current_divider;
                else
                    paddle_x <= X_BOUNDARY - PADDLE_WIDTH;
            end
        end
    end
    
    // ==========================================
    // Output assignments
    // ==========================================
    // Determine if current pixel is part of the paddle
    assign paddle_pixel = (current_pixel_y >= (Y_BOUNDARY - PADDLE_HEIGHT) && 
                          current_pixel_y < Y_BOUNDARY &&
                          current_pixel_x >= paddle_x && 
                          current_pixel_x < (paddle_x + PADDLE_WIDTH));
    
    // Control and status outputs
    assign paddle_x_pos = paddle_x;
    assign led = sens_led;
    assign scaled_x_boundary = (X_BOUNDARY * current_divider) - 1;
    
endmodule
