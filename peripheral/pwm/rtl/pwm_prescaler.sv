`default_nettype none
module pwm_prescaler (
    input wire CLK,
    input wire RST_N,
    input wire [7:0] PWM_DIV,
    output logic PWM_CLKE

);

    logic [7:0] cnt_div;
    logic [7:0] cnt_div_next;
    wire        cnt_max;

    assign cnt_max = (cnt_div == PWM_DIV);  // f_{clke} = 1 / (PWM_DIV + 1)

    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            cnt_div <= '0;
        end else if (cnt_max) begin
            cnt_div <= '0;
        end else begin
            cnt_div <= cnt_div + 8'd1;
        end
    end


    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            PWM_CLKE <= 1'b0;
        end else begin
            PWM_CLKE <= cnt_max;
        end
    end


endmodule
`default_nettype wire
