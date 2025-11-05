package axi_pkg;
    parameter [1:0] P_AXI_BURST_FIXED = 2'b00;
    parameter [1:0] P_AXI_BURST_INCR = 2'b01;
    parameter [1:0] P_AXI_BURST_WRAP = 2'b10;


   
    parameter [1:0] P_AXI_RESP_OKAY = 2'b00;
    parameter [1:0] P_AXI_RESP_EXOKAY = 2'b01;
    parameter [1:0] P_AXI_RESP_SLBERR = 2'b10;
    parameter [1:0] P_AXI_RESP_DECERR = 2'b11;
endpackage
