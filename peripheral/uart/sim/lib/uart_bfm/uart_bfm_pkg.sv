`ifndef _H_UART_BFM_PKG_SV
`define _H_UART_BFM_PKG_SV

package uart_bfm_pkg;
    typedef enum {
        DRV_CFG,
        DRV_TRANS,
        DRV_DATA_PUSH
    } UART_BFM_CMD_t;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "uart_bfm_transfer.sv"
    `include "uart_bfm_config.sv"

    typedef uart_bfm_transfer uart_bfm_default_transfer;
    typedef virtual uart_bfm_if uart_bfm_default_interface;

    `include "uart_bfm_monitor.sv"
    `include "uart_bfm_driver.sv"
    `include "uart_bfm_agent.sv"

    `include "uart_bfm_seq_lib.sv"

endpackage


`endif
