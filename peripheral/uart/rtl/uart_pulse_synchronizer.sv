`default_nettype none
module uart_pulse_synchronizer #(
    parameter int FF_DEPTH = 2
)(
    // Source domain
    input  wire src_clk,
    input  wire src_rst_n,
    input  wire src_pulse,    // 1-clock width input pulse

    // Destination domain
    input  wire dest_clk,
    input  wire dest_rst_n,
    output wire dest_pulse    // Restored 1-clock width output pulse
);

    //=========================================
    // 1. Source domain: Convert pulse to toggle (level) signal
    //=========================================
    reg src_toggle_r;

    always_ff @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            src_toggle_r <= 1'b0;
        end else if (src_pulse) begin
            src_toggle_r <= ~src_toggle_r; // Toggle between 0->1 or 1->0 on pulse
        end
    end

    //=========================================
    // 2. Destination domain: Synchronize toggle signal & Edge detection
    //=========================================
    // FF_DEPTH-stage synchronizer + 1-stage delay register for edge detection
    (* ASYNC_REG = "TRUE" *) reg [FF_DEPTH:0] dest_sync_r;

    always_ff @(posedge dest_clk or negedge dest_rst_n) begin
        if (!dest_rst_n) begin
            dest_sync_r <= '0;
        end else begin
            dest_sync_r[0] <= src_toggle_r;
            for (int i = 1; i <= FF_DEPTH; i++) begin
                dest_sync_r[i] <= dest_sync_r[i-1];
            end
        end
    end

    //=========================================
    // 3. Output: Generate pulse when level changes (rising or falling edge)
    //=========================================
    // XOR current and previous values to detect edge
    assign dest_pulse = dest_sync_r[FF_DEPTH] ^ dest_sync_r[FF_DEPTH-1];

endmodule
`default_nettype wire
