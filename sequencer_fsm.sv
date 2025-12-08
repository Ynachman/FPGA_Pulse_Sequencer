module sequencer_fsm (
    input logic clk, 
    input logic reset,
    input logic start_signal,
    // Timer Inputs (Status from clk_div)
    input logic timer_A_done, 
    input logic timer_delay_done, 
    input logic timer_B_done, 
    // Timer Outputs (Controls to start clk_div)
    output logic trigger_A, 
    output logic trigger_delay, 
    output logic trigger_B,         
    // Physical Outputs
    output logic pulse_out_A, 
    output logic pulse_out_B
);

    // 1. Define States
    typedef enum logic [1:0] {
        S_IDLE,
        S_PULSE_A,
        S_DELAY,
        S_PULSE_B
    } state_t;

    state_t current_state, next_state;

    // 2. State Memory (Sequential)
    always_ff @(posedge clk) begin
        if (reset) 
            current_state <= S_IDLE;
        else       
            current_state <= next_state;
    end

    // 3. Next State Logic & Output Logic (Combinational)
    always_comb begin
        // Defaults (prevent latches by setting default values)
        next_state = current_state;
        trigger_A = 0; 
        trigger_delay = 0; 
        trigger_B = 0;
        pulse_out_A = 0; 
        pulse_out_B = 0;

        case (current_state)
            S_IDLE: begin
                pulse_out_A = 0;
                pulse_out_B = 0;
                if (start_signal) begin
                    next_state = S_PULSE_A;
                    trigger_A = 1; // Fire Timer A
                end
            end
            
            S_PULSE_A: begin
                pulse_out_A = 1; // Output A is HIGH
                pulse_out_B = 0;
                if (timer_A_done) begin
                    next_state = S_DELAY;
                    trigger_delay = 1; // Fire Delay Timer
                end
            end

            S_DELAY: begin
                pulse_out_A = 0; // Both LOW
                pulse_out_B = 0;
                if (timer_delay_done) begin
                    next_state = S_PULSE_B;
                    trigger_B = 1; // Fire Timer B
                end
            end

            S_PULSE_B: begin
                pulse_out_A = 0;
                pulse_out_B = 1; // Output B is HIGH
                if (timer_B_done) begin
                    next_state = S_IDLE; // Sequence Complete
                end
            end
            
            default: next_state = S_IDLE;
        endcase
    end
endmodule