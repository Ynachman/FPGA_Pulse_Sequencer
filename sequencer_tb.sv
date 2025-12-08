// --- For testing without hardware ---

`timescale 1ns / 1ps

module sequencer_tb;

    // --- Test Signals ---
    logic clk;
    logic reset;
    logic start_signal;
    logic pulse_out_A;
    logic pulse_out_B;

    // --- Instantiate the device under test) ---
    top_pulse_sequencer dut (
        .clk(clk),
        .reset(reset),
        .start_signal(start_signal),
        .pulse_out_A(pulse_out_A),
        .pulse_out_B(pulse_out_B)
    );

    // --- Clock Generation ---
    // Generate a 100 MHz clock (Period = 10ns)
    always begin
        #5 clk = ~clk; // Toggle state every 5 nanoseconds
    end

    // --- Test Procedure ---
    initial begin
        // 1. Initialize Outputs
        $display("Simulation Started...");
        clk = 0;
        reset = 1;
        start_signal = 0;

        // 2. Apply Reset
        #100;       // Wait 100ns
        reset = 0;  // Release reset
        #50;

        // 3. Trigger the Sequence
        $display("Applying Start Signal...");
        start_signal = 1;
        #20;             // Hold button for 20ns
        start_signal = 0; // Release button

        // 4. Wait for Sequence to Complete
        // The sequence is approx 2500 ticks long (25,000ns)
        // We wait 40,000ns to be safe and see the idle state after
        #40000;

        $display("Simulation Finished.");
        $finish; // Stop simulation
    end

endmodule