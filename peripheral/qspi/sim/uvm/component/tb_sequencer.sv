`ifndef _H_TB_SEQUENCER_SV
`define _H_TB_SEQUENCER_SV

class tb_sequencer extends uvm_sequencer;
    `uvm_component_utils(tb_sequencer)

    uvm_sequencer #(axi4lite_trans) axi4lite_m_sqr;
    uvm_sequencer #(qspi_bfm_trans) qspi_sqr[4];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass
`endif
