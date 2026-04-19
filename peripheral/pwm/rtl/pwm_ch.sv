`default_nettype none
module pwm_ch (
    input  wire         CLK,
    input  wire         RST_N,
    input  wire         PWM_CLKE,
    //PWM0 Register                 
    input  logic        PWM_EN,
    input  logic        PWM_INV,
    input  logic [15:0] PWM_PERIOD,
    input  logic [15:0] PWM_DUTY,
    output logic        PWM_OUT
);
    // internal register
    //PWM0 Register                 
    logic        pwm_en_r;
    logic        pwm_inv_r;
    logic [15:0] pwm_period_r;
    logic [15:0] pwm_duty_r;

    logic        pwm_en_next;
    logic        pwm_inv_next;
    logic [15:0] pwm_period_next;
    logic [15:0] pwm_duty_next;

    logic [15:0] cnt_pwm;
    wire         cnt_max;
    wire         cnt_active;
    wire         reg_update;
    logic        pwm_out_next;



    assign cnt_max    = (cnt_pwm == pwm_period_r);
    assign cnt_active = (cnt_pwm < pwm_duty_r);
    assign reg_update = (PWM_CLKE && (cnt0_max || ~pwm_en0_r));


    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            cnt_pwm <= '0;
        end else if (!pwm_en_r) begin
            cnt_pwm <= '0;
        end else if (PWM_CLKE) begin
            if (cnt_max) begin
                cnt_pwm <= '0;
            end else begin
                cnt_pwm <= cnt_pwm + 16'd1;
            end
        end
    end

    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            pwm_en_r <= '0;
            pwm_inv_r <= '0;
            pwm_period_r <= '0;
            pwm_duty_r <= '0;
        end else if (reg_update) begin
            pwm_en_r <= PWM_EN;
            pwm_inv_r <= PWM_INV;
            pwm_period_r <= PWM_PERIOD;
            pwm_duty_r <= PWM_DUTY;
        end
    end



    //#######################3
    //PWM OUT
    //#######################3
    always_comb begin
        if (!pwm_en_r) begin
            pwm_out_next = 1'b0;
        end else if (pwm_active) begin
            pwm_out_next = 1'b1;
        end else begin
            pwm_out_next = 1'b0;
        end
    end

    always_ff @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            PWM_OUT <= 1'b0;
        end else if (pwm_inv_r) begin
            PWM_OUT <= ~pwm_out_next;
        end else begin
            PWM_OUT <= pwm_out_next;
        end
    end

endmodule
`default_nettype wire
