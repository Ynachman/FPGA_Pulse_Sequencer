module clk_div (
    input logic clk,             // 100 MHz input clock
    input logic reset,           // Synchronous reset signal
    input logic start_pulse,     // Signal to begin counting
    input int unsigned period,   // The number of clock cycles to count
    output logic timer_done      // High for one clock cycle when period is reached
);

parameter COUNTER_WIDTH = 32; // Max ~4,000,000,000

logic [COUNTER_WIDTH-1:0] counter_reg;

logic running; 

always_ff @(posedge clk) begin
    if (reset) begin
        counter_reg <= 0;
        timer_done <= 0;
        running <= 0;        // Reset running
    end else if (start_pulse) begin
        // Reset the counter and start counting
        counter_reg <= 0;
        timer_done <= 0;
        running <= 1;        // Set running to START
    end else if (running) begin // <--- Only count if running is TRUE
        // The main counting logic
        if (counter_reg == period - 1) begin
            counter_reg <= 0;
            timer_done <= 1;
            running <= 0;    // <--- Set running to STOP 
        end else begin
            counter_reg <= counter_reg + 1;
            timer_done <= 0;
        end
    end else begin
        // If not running, output stays low
        timer_done <= 0;
    end
end

endmodule