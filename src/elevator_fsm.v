`timescale 1ns / 1ps

/*
 * Module: elevator_fsm
 * Description: Main control unit for a 3-floor elevator system. 
 * Implements an FSM to manage floor requests and positioning using FPGA (Basys 3).
 */
module elevator_fsm (
    input CLK100MHZ,          
    input [2:0] reed_switch,  // Magnetic sensors for floor detection (Active Low)
    input [2:0] button,       // User floor requests (Active Low)
    output servo,             // PWM signal output for servo motor
    output [2:0] LED,         // Visual indication of current requests
    output [6:0] seg,         // 7-Segment display segments
    output [3:0] an           // 7-Segment digit selectors
);

    // *Signal Inversion*
    // Physical buttons and reed switches are wired with pull-up resistors (Active Low).
    // Inverting them here allows the FSM to work with standard positive logic (Active High).
    wire [2:0] button_inverted;
    wire [2:0] reed_switch_inverted;
    assign button_inverted = ~button;
    assign reed_switch_inverted = ~reed_switch;
  
    // Map inverted buttons to LEDs for immediate user feedback
    assign LED = button_inverted;
   
    // Internal State Registers
    reg [1:0] direction;      // Current motor command (STOP, UP, DOWN)
    reg [1:0] last_direction; // Memory for last known direction (to prevent jitter)
    reg [2:0] target_floor;   // Register to store the desired destination
    
    // Motor Control Parameters
    parameter STOP = 2'b00, UP = 2'b10, DOWN = 2'b01;
    
    // Request and Memory Logic
    always @(posedge CLK100MHZ) begin
        // Update last_direction only when physically at a floor
        if (reed_switch_inverted != 3'b000)
            last_direction <= direction;
            
        // Latch the floor request when a button is pressed
        if (button_inverted != 3'b000)
            target_floor <= button_inverted;  
    end 
            
    // *Servo Driver Instantiation*
    // Translates direction commands into precise PWM pulses (50Hz)
    servomotor_operation inst (
        .CLK100MHZ(CLK100MHZ),
        .direction_control(direction),
        .pwm(servo)
    );
    
    // *FSM State Transition Logic*
    // Defines the elevator's behavior at each floor relative to the target floor
    parameter floor0 = 3'b001, floor1 = 3'b010, floor2 = 3'b100;
    
    always @(*) begin
        case (reed_switch_inverted)
            // Case: Elevator is at Ground Floor
            floor0: begin
                if (target_floor == floor0) 
                    direction = STOP;
                else if (target_floor != floor0) 
                    direction = UP;
                else 
                    direction = STOP;
            end
            
            // Case: Elevator is at 1st Floor
            floor1: begin
                if (target_floor == floor0) 
                    direction = DOWN;
                else if (target_floor == floor1) 
                    direction = STOP;
                else if (target_floor == floor2) 
                    direction = UP;
                else 
                    direction = STOP;
            end
            
            // Case: Elevator is at 2nd Floor
            floor2: begin
                if (target_floor != floor2)        
                    direction = DOWN;
                else if (target_floor == floor2) 
                    direction = STOP;
                else 
                    direction = STOP;
            end
            
            // Case: Elevator is between floors (Transitions)
            // Maintain previous movement until the next sensor is reached
            default: begin
                direction = last_direction;
            end 
        endcase
    end
    
    // Display Logic (7-Segment)
    reg [6:0] seg_out;
    reg [2:0] current_floor;
    assign seg = seg_out;
    assign an = 4'b1110;   // Enable only the rightmost digit on the Basys 3 board
    
    // Record current floor based on sensor feedback
    always @(posedge CLK100MHZ) begin
        if (reed_switch_inverted == 3'b001 || reed_switch_inverted == 3'b010 || reed_switch_inverted == 3'b100) begin
            current_floor <= reed_switch_inverted;
        end 
    end 

    // Segment decoding for numbers 0, 1, 2
    always @(*) begin
        case(current_floor)
            3'b001: seg_out = 7'b1000000;  // Display "0"
            3'b010: seg_out = 7'b1111001;  // Display "1"
            3'b100: seg_out = 7'b0100100;  // Display "2"
            default: seg_out = 7'b0111111; // Display "-" (Transition/Unknown)
        endcase
    end
    
    // Initial State Configuration
    initial begin
        direction = DOWN;
        last_direction = DOWN;
        target_floor = floor0;
    end

endmodule
        
        
          
                     
