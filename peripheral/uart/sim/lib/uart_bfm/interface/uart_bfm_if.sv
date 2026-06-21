interface uart_bfm_if(
    input wire rst_n
);
    logic txd;
    logic rxd;
    logic rtsn;
    logic ctsn;
endinterface
