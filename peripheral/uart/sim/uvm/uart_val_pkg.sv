`timescale 1ns/1ps
`ifndef _H_UART_VAL_PKG_SV
`define _H_UART_VAL_PKG_SV

package uart_val_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Import dependent packages
    import common_pkg::*;
    import axi4lite_pkg::*;
    import uart_bfm_pkg::*;

    // Include RAL model
    `include "ral/uart_reg_model.sv"

    // Include verification components
    `include "component/uart_scoreboard.sv"
    `include "component/uart_sequencer.sv"
    `include "component/uart_env.sv"

    // Include sequences and tests
    `include "sequence/uart_sequence_base.sv"
    `include "test/tb_test_base.sv"

endpackage

`endif
