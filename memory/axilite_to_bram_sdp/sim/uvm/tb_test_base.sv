`ifndef _H_TB_TEST_BASE_SV
`define _H_TB_TEST_BASE_SV

class tb_test_base extends uvm_test;
    `uvm_component_utils(tb_test_base)

    tb_env env;
    axi4lite_master_vif axi4lite_m_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        my_report_server custom_server;

        super.build_phase(phase);

        // UVM Timeout Configuration
        uvm_top.set_timeout(5000000ns, 0); // 5ms timeout

        custom_server = new();
        uvm_report_server::set_server(custom_server);

        env = tb_env::type_id::create("env", this);

        if (!uvm_config_db#(axi4lite_master_vif)::get(this, "", "axi4lite_m_vif", axi4lite_m_vif)) begin
            `uvm_fatal("TEST", "Failed to get axi4lite_m_vif from config_db")
        end
        uvm_config_db#(axi4lite_master_vif)::set(this, "env.axi4lite_m_agent*", "vif", axi4lite_m_vif);
    endfunction

    task run_phase(uvm_phase phase);
        string test_case;
        tb_seq_base seq;

        phase.raise_objection(this);
        if (!$value$plusargs("TEST_CASE=%s", test_case)) begin
            `uvm_fatal("TEST", "No +TEST_CASE argument found!")
        end

        $cast(seq, uvm_factory::get().create_object_by_name(test_case, "", test_case));

        if (seq == null) begin
            `uvm_fatal("TEST", $sformatf("Failed to create sequence: %s", test_case))
        end

        `uvm_info("TEST", $sformatf("Starting Sequence: %s", test_case), UVM_LOW)
        seq.start(env.sqr);

        phase.drop_objection(this);
    endtask
endclass

`endif
