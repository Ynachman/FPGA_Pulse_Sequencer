module top_pulse_sequencer (
    input logic clk,
    input logic reset,
    input logic start_signal,
    output logic pulse_out_A,
    output logic pulse_out_B
);

    // --- Internal Wires ---
    // Signals from FSM to start the timers
    logic trigger_A, trigger_delay, trigger_B;
    
    // Signals from Timers back to FSM saying done
    logic timer_A_done, timer_delay_done, timer_B_done;

    // TIME SETTINGS (Uncomment the option you would like to use)

    // --- OPTION 1: SIMULATION VALUES ---
    // Use these for Vivado Simulation waveforms. 
    // 10 ticks = 100ns (visible in simulation but not to human eye)
    
    localparam WIDTH_A_VAL     = 10;
    localparam WIDTH_DELAY_VAL = 20;
    localparam WIDTH_B_VAL     = 10;
    

    // --- OPTION 2: BOARD VALUES ---
    // Use these for normal operation on the Basys 3 Board (visible to human eye).
    // 100,000,000 ticks = 1 second @ 100 MHz
    
    /*
    localparam WIDTH_A_VAL     = 100_000_000; // 1 Second Pulse A
    localparam WIDTH_DELAY_VAL = 50_000_000;  // 0.5 Second Delay
    localparam WIDTH_B_VAL     = 100_000_000; // 1 Second Pulse B
    */

    // --- OPTION 3: PWM PROOF ---
    // Use this to prove "Fast Logic" works physically without extra equipment.
    // High Delay vs Short Pulse = Very Dim LEDs (1% Duty Cycle).
    /*
    localparam WIDTH_A_VAL     = 1_000;    // Short Pulse
    localparam WIDTH_DELAY_VAL = 98_000;   // Long Delay
    localparam WIDTH_B_VAL     = 1_000;    // Short Pulse
    */


    // MODULE INSTANTIATIONS

    // --- 1. Instantiate the FSM Controller ---
    sequencer_fsm fsm_inst (
        .clk(clk), 
        .reset(reset),
        .start_signal(start_signal),
        
        // Timer Inputs 
        .timer_A_done(timer_A_done),
        .timer_delay_done(timer_delay_done),
        .timer_B_done(timer_B_done),
        
        // Timer Outputs 
        .trigger_A(trigger_A),
        .trigger_delay(trigger_delay),
        .trigger_B(trigger_B),
        
        // Physical Outputs
        .pulse_out_A(pulse_out_A),
        .pulse_out_B(pulse_out_B)
    );

    // --- 2. Instantiate the Timers ---
    
    // Timer for Pulse A
    clk_div timer_A (
        .clk(clk), 
        .reset(reset),
        .start_pulse(trigger_A),
        .period(WIDTH_A_VAL),     
        .timer_done(timer_A_done)
    );

    // Timer for the Delay
    clk_div timer_delay (
        .clk(clk), 
        .reset(reset),
        .start_pulse(trigger_delay),
        .period(WIDTH_DELAY_VAL), 
        .timer_done(timer_delay_done)
    );

    // Timer for Pulse B
    clk_div timer_B (
        .clk(clk), 
        .reset(reset),
        .start_pulse(trigger_B),
        .period(WIDTH_B_VAL),     
        .timer_done(timer_B_done)
    );

endmodule