`default_nettype none `timescale 1ns / 1ps
module tb_top ();


    //################
    //define signal
    //################
    reg pclk;
    reg presetn;
    apb_if apb (
        .pclk(pclk),
        .presetn(presetn)
    );
    wire pwm_out0;
    wire pwm_out1;
    wire pwm_out2;
    wire pwm_out3;

    //################
    //DUT and APB Interface
    //################
    pwm #(
        .P_ADDR_BITWIDTH(32),
        .P_DATA_BITWIDTH(32)
    ) pwm_inst (
        .PCLK(pclk),
        .PRESETn(presetn),
        .PADDR(apb.paddr),
        .PSEL(apb.psel),
        .PENABLE(apb.penable),
        .PWRITE(apb.pwrite),
        .PWDATA(apb.pwdata),
        .PREADY(apb.pready),
        .PRDATA(apb.prdata),
        .PSLVERR(apb.pslverr),
        .PWM_OUT0(pwm_out0),
        .PWM_OUT1(pwm_out1),
        .PWM_OUT2(pwm_out2),
        .PWM_OUT3(pwm_out3)
    );



   
endmodule

`default_nettype wire
