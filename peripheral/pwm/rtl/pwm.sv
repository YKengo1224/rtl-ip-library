`default_nettype none

module pwm #(
    parameter int P_ADDR_BITWIDTH = 32,
    parameter int P_DATA_BITWIDTH = 32
) (
    input  wire                            PCLK,
    input  wire                            PRESETn,
    input  wire  [    P_ADDR_BITWIDTH-1:0] PADDR,
    input  wire                            PPROT,
    input  wire                            PSEL,
    input  wire                            PENABLE,
    input  wire                            PWRITE,
    input  wire  [    P_DATA_BITWIDTH-1:0] PWDATA,
    input  wire  [(P_DATA_BITWIDTH/8)-1:0] PSTRB,
    output logic                           PREADY,
    output logic                           PRDATA,
    output logic                           PSLVERR,
    output logic                           PWM_OUT0,
    output logic                           PWM_OUT1,
    output logic                           PWM_OUT2,
    output logic                           PWM_OUT3
);
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    logic               PWM_CLKE;               // From pwm_prescaler_inst of pwm_prescaler.v
    logic [7:0]         PWM_DIV;                // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_DUTY0;              // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_DUTY1;              // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_DUTY2;              // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_DUTY3;              // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_EN0;                // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_EN1;                // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_EN2;                // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_EN3;                // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_INV0;               // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_INV1;               // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_INV2;               // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic               PWM_INV3;               // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_PERIOD0;            // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_PERIOD1;            // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_PERIOD2;            // From pwm_apb_slv_inst of pwm_apb_slv.v
    logic [15:0]        PWM_PERIOD3;            // From pwm_apb_slv_inst of pwm_apb_slv.v
    // End of automatics


    pwm_apb_slv #(
        .P_ADDR_BITWIDTH(P_ADDR_BITWIDTH),
        .P_DATA_BITWIDTH(P_DATA_BITWIDTH)
    ) pwm_apb_slv_inst (
    /*AUTOINST*/
                        // Outputs
                        .PREADY         (PREADY),
                        .PRDATA         (PRDATA),
                        .PSLVERR        (PSLVERR),
                        .PWM_DIV        (PWM_DIV[7:0]),
                        .PWM_EN0        (PWM_EN0),
                        .PWM_INV0       (PWM_INV0),
                        .PWM_PERIOD0    (PWM_PERIOD0[15:0]),
                        .PWM_DUTY0      (PWM_DUTY0[15:0]),
                        .PWM_EN1        (PWM_EN1),
                        .PWM_INV1       (PWM_INV1),
                        .PWM_PERIOD1    (PWM_PERIOD1[15:0]),
                        .PWM_DUTY1      (PWM_DUTY1[15:0]),
                        .PWM_EN2        (PWM_EN2),
                        .PWM_INV2       (PWM_INV2),
                        .PWM_PERIOD2    (PWM_PERIOD2[15:0]),
                        .PWM_DUTY2      (PWM_DUTY2[15:0]),
                        .PWM_EN3        (PWM_EN3),
                        .PWM_INV3       (PWM_INV3),
                        .PWM_PERIOD3    (PWM_PERIOD3[15:0]),
                        .PWM_DUTY3      (PWM_DUTY3[15:0]),
                        // Inputs
                        .PCLK           (PCLK),
                        .PRESETn        (PRESETn),
                        .PADDR          (PADDR[P_ADDR_BITWIDTH-1:0]),
                        .PPROT          (PPROT),
                        .PSEL           (PSEL),
                        .PENABLE        (PENABLE),
                        .PWRITE         (PWRITE),
                        .PWDATA         (PWDATA[P_DATA_BITWIDTH-1:0]),
                        .PSTRB          (PSTRB[(P_DATA_BITWIDTH/8)-1:0]));


    pwm_prescaler pwm_prescaler_inst (
    /*AUTOINST*/
                                      // Outputs
                                      .PWM_CLKE         (PWM_CLKE),
                                      // Inputs
                                      .CLK              (CLK),
                                      .RST_N            (RST_N),
                                      .PWM_DIV          (PWM_DIV[7:0]));


    pwm_core pwm_core_inst (
    /*AUTOINST*/
                            // Outputs
                            .PWM_OUT0           (PWM_OUT0),
                            .PWM_OUT1           (PWM_OUT1),
                            .PWM_OUT2           (PWM_OUT2),
                            .PWM_OUT3           (PWM_OUT3),
                            // Inputs
                            .CLK                (CLK),
                            .RST_N              (RST_N),
                            .PWM_CLKE           (PWM_CLKE),
                            .PWM_EN0            (PWM_EN0),
                            .PWM_INV0           (PWM_INV0),
                            .PWM_PERIOD0        (PWM_PERIOD0[15:0]),
                            .PWM_DUTY0          (PWM_DUTY0[15:0]),
                            .PWM_EN1            (PWM_EN1),
                            .PWM_INV1           (PWM_INV1),
                            .PWM_PERIOD1        (PWM_PERIOD1[15:0]),
                            .PWM_DUTY1          (PWM_DUTY1[15:0]),
                            .PWM_EN2            (PWM_EN2),
                            .PWM_INV2           (PWM_INV2),
                            .PWM_PERIOD2        (PWM_PERIOD2[15:0]),
                            .PWM_DUTY2          (PWM_DUTY2[15:0]),
                            .PWM_EN3            (PWM_EN3),
                            .PWM_INV3           (PWM_INV3),
                            .PWM_PERIOD3        (PWM_PERIOD3[15:0]),
                            .PWM_DUTY3          (PWM_DUTY3[15:0]));


endmodule
// Local Variables:
// verilog-library-flags:("-y rtl/")
// verilog-auto-inst-column:24  ;; Min. 24?
// indent-tabs-mode:nil
// End:
`default_nettype wire
