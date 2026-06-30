`ifndef _H_TB_ENV_SV
`define _H_TB_ENV_SV

class tb_env extends uvm_env;
    `uvm_component_utils(tb_env)

    axi4lite_master_agent #(axi4lite_master_vif, axi4lite_trans) axi4lite_m_agent;
    tb_scoreboard scb;
    tb_sequencer sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi4lite_m_agent = axi4lite_master_agent#(axi4lite_master_vif, axi4lite_trans)::type_id::create(
            "axi4lite_m_agent", this);

        scb = tb_scoreboard::type_id::create("scb", this);
        sqr = tb_sequencer::type_id::create("sqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        axi4lite_m_agent.mntr.item_collected_port.connect(scb.reg_imp);
        sqr.axi4lite_m_sqr = axi4lite_m_agent.seqr;
    endfunction
endclass

`endif
