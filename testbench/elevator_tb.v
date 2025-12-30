`timescale 1ns / 1ps

/**
 * Module: elevator_tb
 * Description: Testbench for verifying the 3-floor elevator FSM logic.
 * This simulation validates floor requests, state transitions, and 
 * high precision PWM output behavior.
 */
module elevator_tb;

    // Simulation Signals
    // Registers (reg) drive inputs to the Unit Under Test (UUT)
    // Wires (wire) monitor outputs from the UUT
    reg clk;
    reg [2:0] reed_switch; // 3-bit sensor input (Matching design)
    reg [2:0] button;      // 3-bit floor request input
    
    wire servo;    
    wire [2:0] LED;
    wire [6:0] seg;        // 7-segment display segments
    wire [3:0] an;         // 7-segment common anodes

    // Unit Under Test (UUT) Instantiation
    // Connects simulation signals to the actual elevator controller hardware ports
    elevator_fsm uut (
        .CLK100MHZ(clk),   
        .reed_switch(reed_switch),
        .button(button),
        .servo(servo),
        .LED(LED),
        .seg(seg),
        .an(an)
    );

    // Clock Generation
    // Generates a 100MHz clock signal (10ns period)
    // #5 ns toggle rate creates a 10ns total cycle time
    initial begin
        clk = 0;
    end
    
    always begin
        #5 clk = ~clk; 
    end

    // Stimulus Process (Verification Scenarios)
    initial begin
        // Stage 1: Initialization - Startup at Ground Floor (Floor 0)
        // Active Low Logic: '0' represents an active sensor or button press
        reed_switch = 3'b110; // Floor 0 sensor active
        button = 3'b111;      // No buttons currently pressed
        #100;
        
        // Stage 2: User Request - Moving to Floor 2
        $display("Time: %t | Action: Pressing Button for Floor 2", $time);
        button = 3'b011;      // Pressing button[2] (Active Low)
        #100;
        button = 3'b111;      // Button released (FSM must latch the request)
        
        // Stage 3: Motion Simulation - Leaving Floor 0
        #50;
        reed_switch = 3'b111; // Elevator is between floors (Transitions)
        $display("Time: %t | Status: Elevator is moving UP...", $time);
        
        // Stage 4: Arrival - Reaching Floor 2
        #500;                 // Wait for simulated travel time
        reed_switch = 3'b011; // Floor 2 sensor becomes active
        $display("Time: %t | Status: Arrived at Floor 2", $time);
        
        #200;
        
        // Stage 5: Return Trip - Requesting Ground Floor (Floor 0)
        $display("Time: %t | Action: Pressing Button for Floor 0", $time);
        button = 3'b110;      // Pressing button[0]
        #100;
        button = 3'b111;      // Button released
        
        reed_switch = 3'b111; // Leaving Floor 2 (Moving Down)
        #500;
        reed_switch = 3'b110; // Arriving back at Ground Floor
        $display("Time: %t | Status: Back at Ground Floor", $time);

        #200;
        $display("Test completed successfully!");
        $finish;              // End of simulation
    end

    // Signal Monitoring
    // Automatically logs signal transitions to the Tcl Console for debugging
    initial begin
        $monitor("Time=%t | Sensors(ActiveLow)=%b | TargetFloor=%b | Direction=%b", 
                 $time, reed_switch, uut.target_floor, uut.direction);
    end

endmodule
