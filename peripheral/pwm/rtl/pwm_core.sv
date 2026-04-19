`default_nettype none
module pwm_core (
    input  wire         CLK,
    input  wire         RST_N,
    input  wire         PWM_CLKE,
    //PWM0 Register                 
    input  logic        PWM_EN0,
    input  logic        PWM_INV0,
    input  logic [15:0] PWM_PERIOD0,
    input  logic [15:0] PWM_DUTY0,
    //PWM1 Register                 
    input  logic        PWM_EN1,
    input  logic        PWM_INV1,
    input  logic [15:0] PWM_PERIOD1,
    input  logic [15:0] PWM_DUTY1,
    //PWM2 Register                 
    input  logic        PWM_EN2,
    input  logic        PWM_INV2,
    input  logic [15:0] PWM_PERIOD2,
    input  logic [15:0] PWM_DUTY2,
    //PWM3 Register                 
    input  logic        PWM_EN3,
    input  logic        PWM_INV3,
    input  logic [15:0] PWM_PERIOD3,
    input  logic [15:0] PWM_DUTY3,
    //output 
    output logic        PWM_OUT0,
    output logic        PWM_OUT1,
    output logic        PWM_OUT2,
    output logic        PWM_OUT3
);

    /*pwm_ch AUTO_TEMPLATE(      
        .PWM_\(.*\) (PWM_\10[]),
     )
     */
    pwm_ch pwm_ch0 (
        .CLK       (CLK),
        .RST_N     (RST_N),
        .PWM_CLKE  (PWM_CLKE),
        /*AUTOINST*/
        // Outputs
        .PWM_OUT   (PWM_OUT0),           // Templated
        // Inputs
        .PWM_EN    (PWM_EN0),            // Templated
        .PWM_INV   (PWM_INV0),           // Templated
        .PWM_PERIOD(PWM_PERIOD0[15:0]),  // Templated
        .PWM_DUTY  (PWM_DUTY0[15:0])
    );  // Templated

    /*pwm_ch AUTO_TEMPLATE(      
        .PWM_\(.*\) (PWM_\11[]),
     )
     */
    pwm_ch pwm_ch1 (
        .CLK       (CLK),
        .RST_N     (RST_N),
        .PWM_CLKE  (PWM_CLKE),
        /*AUTOINST*/
        // Outputs
        .PWM_OUT   (PWM_OUT1),           // Templated
        // Inputs
        .PWM_EN    (PWM_EN1),            // Templated
        .PWM_INV   (PWM_INV1),           // Templated
        .PWM_PERIOD(PWM_PERIOD1[15:0]),  // Templated
        .PWM_DUTY  (PWM_DUTY1[15:0])
    );  // Templated

    /*pwm_ch AUTO_TEMPLATE(      
        .PWM_\(.*\) (PWM_\12[]),
     )
     */
    pwm_ch pwm_ch2 (
        .CLK       (CLK),
        .RST_N     (RST_N),
        .PWM_CLKE  (PWM_CLKE),
        /*AUTOINST*/
        // Outputs
        .PWM_OUT   (PWM_OUT2),           // Templated
        // Inputs
        .PWM_EN    (PWM_EN2),            // Templated
        .PWM_INV   (PWM_INV2),           // Templated
        .PWM_PERIOD(PWM_PERIOD2[15:0]),  // Templated
        .PWM_DUTY  (PWM_DUTY2[15:0])
    );  // Templated


    /*pwm_ch AUTO_TEMPLATE(      
        .PWM_\(.*\) (PWM_\13[]),
     )
     */
    pwm_ch pwm_ch3 (
        .CLK       (CLK),
        .RST_N     (RST_N),
        .PWM_CLKE  (PWM_CLKE),
        /*AUTOINST*/
        // Outputs
        .PWM_OUT   (PWM_OUT3),           // Templated
        // Inputs
        .PWM_EN    (PWM_EN3),            // Templated
        .PWM_INV   (PWM_INV3),           // Templated
        .PWM_PERIOD(PWM_PERIOD3[15:0]),  // Templated
        .PWM_DUTY  (PWM_DUTY3[15:0])
    );  // Templated

endmodule : pwm_core
// Local Variables:
// verilog-library-flags:("-y rtl/")
// verilog-auto-inst-column:24  ;; Min. 24?
// indent-tabs-mode:nil
// End:
`default_nettype wire
