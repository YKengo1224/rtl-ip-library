`ifndef _H_QSPI_BFM_PKG_SV
`define _H_QSPI_BFM_PKG_SV

package qspi_bfm_pkg;
    typedef enum {
        DRV_CFG,
        DRV_TRANS,
        DRV_DATA_PUSH
    } QSPI_BFM_CMD_t;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "qspi_bfm_transfer.sv"

    typedef qspi_bfm_transfer qspi_bfm_default_transfer;
    typedef virtual qspi_bfm_if qspi_bfm_default_interface;

    // `include "qspi_bfm_monitor.sv"
    `include "qspi_bfm_driver.sv"
    `include "qspi_bfm_agent.sv"

    `include "qspi_bfm_seq_lib.sv"

endpackage


`endif
