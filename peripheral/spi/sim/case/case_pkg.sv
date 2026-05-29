package case_pkg;
    import uvm_pkg::*;
    import base_pkg::*;
    `include "uvm_macros.svh"
    // `include

    `include "sample_seq.sv"
    `include "test_master_standard_seq.sv"
    `include "test_master_cs_ctrl_seq.sv"
    `include "test_master_random_seq.sv"
    `include "test_master_instr_tx_fifo_empty_seq.sv"
    `include "test_master_instr_rx_fifo_not_empty_seq.sv"
    `include "test_master_instr_tx_fifo_threshold_seq.sv"
    `include "test_master_instr_rx_fifo_threshold_seq.sv"

endpackage

