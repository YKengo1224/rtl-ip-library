interface monitor_if (
    //clk
    input wire aclk,
    input wire sysclk,
    //reset
    input wire aresetn,
    input wire srstn_sysclk,
    //interrupt
    input wire qspi_instr_aclk_o_r
);
endinterface
