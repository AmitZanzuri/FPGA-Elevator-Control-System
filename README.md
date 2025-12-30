# FPGA-Elevator-Control-System
## Project Overview
This project presents a digital control system for a 3-floor elevator model, implemented on a Xilinx Artix-7 FPGA (Basys 3). The system utilizes a Finite State Machine (FSM) to handle real-time user requests, positional feedback from magnetic sensors, and high-precision motor actuation.
The core of the design is written in Verilog HDL, featuring a closed-loop control architecture that ensures reliable transitions and accurate floor positioning.

## Key Technical Features

**1. Finite State Machine (FSM) Logic**
- Logic Design: Implemented a robust FSM that compares target_floor (latch from user buttons) with current_floor (detected via sensors).
- State Persistence: Features a last_direction memory register to ensure continuity during transitions between sensors.
- Active-Low Integration: Designed to interface with physical hardware using Internal Pull-up Resistors, handling the logic inversion within the digital domain for improved readability.

**2. High-Precision PWM Actuation**
- Resolution: Developed a PWM generator with a $10\text{ns}$ resolution, utilizing the $100\text{MHz}$ system clock.
- Servo Control: Generates a stable $50\text{Hz}$ ($20\text{ms}$ period) signal tailored for continuous rotation servo motors:
  - $1.5\text{ms}$ Pulse: Neutral/Stop.
  - $1.56\text{ms}$ / $1.44\text{ms}$ Pulses: Precise directional control (CW/CCW).
- Clock Management: Implemented efficient 21-bit counters to manage timing constraints without the need for external PLLs.

**3. Verification & Simulation**
- Testbench Development: A comprehensive testbench (elevator_tb.v) was developed to validate the FSM state transitions and PWM outputs prior to hardware deployment.
- Hardware Constraints: Detailed .xdc mapping for the Artix-7, including specific I/O standards and timing constraints for the $100\text{MHz}$ oscillator.

# Hardware Requirements
- FPGA Board: Digilent Basys 3 (Artix-7).
- Actuator: Continuous Rotation Servo Motor.
- Sensors: 3x Magnetic Reed Switches.
- Interface: Push Buttons & 7-Segment Display (On-board).
