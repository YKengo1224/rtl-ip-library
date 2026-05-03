
package base_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import common_pkg::*;
    import axi4lite_pkg::*;
    import qspi_bfm_pkg::*;

    typedef virtual axi4lite_if axi4lite_master_vif;
    typedef axi4lite_transfer axi4lite_trans;

    typedef virtual qspi_bfm_if qspi_bfm_vif;
    typedef qspi_bfm_transfer qspi_bfm_trans;

    typedef virtual monitor_if monitor_vif;

    `include "tb_sequencer.sv"
    `include "tb_env.sv"
    `include "tb_sequence_base.sv"
    `include "tb_test_base.sv"

endpackage
