`ifndef _H_TB_PKG_SV
`define _H_TB_PKG_SV

package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import common_pkg::*;
    import axi4lite_pkg::*;

    typedef virtual axi4lite_if axi4lite_master_vif;
    typedef axi4lite_transfer axi4lite_trans;

    `include "tb_sequencer.sv"
    `include "tb_scoreboard.sv"
    `include "tb_env.sv"
    `include "tb_sequence_base.sv"
    `include "tb_test_base.sv"

endpackage

`endif
