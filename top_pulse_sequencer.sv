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

    // --- Time Settings (Temporary Hardcoded Values) ---
    // 1000 ticks @ 100MHz = 10 microseconds
    int unsigned width_A     = 1000;
    int unsigned width_delay = 500;
    int unsigned width_B     = 1000;

    // --- 1. Instantiate the FSM Controller ---
    sequencer_fsm fsm_inst (
        .clk(clk), 
        .reset(reset),
        .start_signal(start_signal),
        
        // Timer Inputs (Status)
        .timer_A_done(timer_A_done),
        .timer_delay_done(timer_delay_done),
        .timer_B_done(timer_B_done),
        
        // Timer Outputs (Controls)
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
        .period(width_A),
        .timer_done(timer_A_done)
    );

    // Timer for the Delay (Dead Time)
    clk_div timer_delay (
        .clk(clk), 
        .reset(reset),
        .start_pulse(trigger_delay),
        .period(width_delay),
        .timer_done(timer_delay_done)
    );

    // Timer for Pulse B
    clk_div timer_B (
        .clk(clk), 
        .reset(reset),
        .start_pulse(trigger_B),
        .period(width_B),
        .timer_done(timer_B_done)
    );

endmodule