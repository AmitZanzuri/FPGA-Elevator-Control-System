`timescale 1ns / 1ps

/*
 * Module: servomotor_operation
 * Description: High precision PWM generator designed for continuous rotation servo control.
 * It translates directional commands into standard 50Hz PWM signals with 10ns resolution.
 */
module servomotor_operation (
    input CLK100MHZ,              
    input [1:0] direction_control, // Command from FSM (00: Stop, 01: CW, 10: CCW)
    output reg [0:0] pwm           // PWM output signal to the servo motor
    );
    
    // Pulse Width Parameters (Calculated for 100MHz Clock
    // Formula: (Desired Time / 10ns Clock Period) = Count Value
    parameter stop = 150000;                  // 1.5 ms pulse (Neutral position/Stop)
    parameter spin_clockwise = 156000;        // 1.56 ms pulse (Forward/Clockwise)
    parameter spin_counterclockwise = 144000; // 1.44 ms pulse (Backward/Counter-clockwise)
        
    // 21-bit register to count up to 2,000,000 (Enough for 20ms period)
    reg [20:0] count = 0;
    
    // Period and Pulse Generation Logic
    always @(posedge CLK100MHZ) begin
        // Period Timer: 2,000,000 counts * 10ns = 20ms (Standard 50Hz PWM)
        if (count < 2000000)
            count <= count + 1;
        else
            count <= 0;
            
        // Duty Cycle Comparison Logic
        case (direction_control)
            // STOP command: Generate 1.5ms pulse
            2'b00: begin
                if (count < stop) 
                    pwm[0] <= 1;
                else 
                    pwm[0] <= 0;
            end
            
            // CLOCKWISE command: Generate 1.56ms pulse
            2'b01: begin
                if (count < spin_clockwise) 
                    pwm[0] <= 1;
                else
                    pwm[0] <= 0;
            end
            
            // COUNTER-CLOCKWISE command: Generate 1.44ms pulse
            2'b10: begin
                if (count < spin_counterclockwise)
                    pwm[0] <= 1;
                else
                    pwm[0] <= 0;
            end
            
            // Safety Default: Ensure motor stops on undefined states
            default: begin
                if (count < stop)
                    pwm[0] <= 1;
                else
                    pwm[0] <= 0;
            end
            
        endcase
    end 
        
endmodule
