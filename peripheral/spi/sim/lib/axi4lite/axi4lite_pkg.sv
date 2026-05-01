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

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "axi4lite_transfer.sv"
    `include "axi4lite_adapter.sv"

    typedef axi4lite_transfer axi4lite_default_transfer;
    typedef virtual axi4lite_if axi4lite_default_interface;

    `include "axi4lite_monitor.sv"
    `include "axi4lite_master_driver.sv"
    `include "axi4lite_master_agent.sv"

    `include "axi4lite_master_seq_lib.sv"

endpackage


`endif
