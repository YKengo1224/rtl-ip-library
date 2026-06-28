`ifndef _H_UART_MONITOR_IF_SV
`define _H_UART_MONITOR_IF_SV

interface uart_monitor_if(input bit clk, input bit rst_n);
    logic o_interrupt_aclkr;
endinterface

`endif
