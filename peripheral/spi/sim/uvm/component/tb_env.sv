

class tb_env extends uvm_env;

    `uvm_component_utils(tb_env)

    axi4lite_master_agent #(axi4lite_master_vif, axi4lite_trans) axi4lite_m_agent;
    qspi_bfm_agent #(qspi_bfm_vif, qspi_bfm_trans) qspi_b_agent[$];

    tb_sequencer sqr;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi4lite_m_agent = axi4lite_master_agent#(axi4lite_master_vif, axi4lite_trans)::type_id::create(
            "axi4lite_m_agent", this);

        for (int i = 0; i < 4; i++) begin

            qspi_b_agent.push_back(qspi_bfm_agent#(qspi_bfm_vif, qspi_bfm_trans)::type_id::create(
                                   $sformatf("qspi_b_agent_%0d", i), this));
        end


        sqr = tb_sequencer::type_id::create("sqr", this);

    endfunction


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        sqr.axi4lite_m_sqr = axi4lite_m_agent.seqr;

        // 4つの QSPI Sequencer のハンドルを渡す
        for (int i = 0; i < 4; i++) begin
            sqr.qspi_sqr[i] = qspi_b_agent[i].seqr;
        end
    endfunction
endclass
