`ifndef _H_AXI4LITE_PKG_SV
`define _H_AXI4LITE_PKG_SV

package axi4lite_pkg;
    typedef enum {
        DRV_AW,
        DRV_W,
        DRV_B,
        DRV_AR,
        DRV_R,
        READ,
        WRITE
    } AXI4LITE_CMD_t;

endpackage


`endif
