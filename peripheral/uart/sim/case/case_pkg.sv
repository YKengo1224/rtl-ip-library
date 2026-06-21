`ifndef _H_CASE_PKG_SV
`define _H_CASE_PKG_SV

package case_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import validation packages
    import axi4lite_pkg::*;
    import uart_bfm_pkg::*;
    import uart_val_pkg::*;

    // Include individual sequences
    `include "uart_tx_sample_seq.sv"
    `include "sample_ral_seq.sv"
    `include "test_reg_access_basic.sv"
    `include "test_reg_access_consecutive_read.sv"
    `include "test_reg_access_alternate_rw.sv"
    `include "test_tx_normal.sv"
    `include "test_rx_normal.sv"

endpackage

`endif
