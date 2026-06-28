`ifndef _H_TB_TEST_BASE_SV
`define _H_TB_TEST_BASE_SV

class tb_test_base extends uvm_test;
    `uvm_component_utils(tb_test_base)

    uart_env env;
    
    // Virtual interfaces to get from config_db and pass to agents
    axi4lite_default_interface axil_vif;
    uart_bfm_default_interface uart_vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        my_report_server custom_server;
        string test_case;

        super.build_phase(phase);

        // Set default simulation timeout to prevent test hang
        uvm_top.set_timeout(300ms);

        // Override timeout specifically for known problematic testcases
        if ($value$plusargs("TEST_CASE=%s", test_case)) begin
            if (test_case == "test_rtx_stopbit_2") begin
                uvm_top.set_timeout(500us);
            end
        end

        // Instantiate custom report server for standard output format
        custom_server = new();
        uvm_report_server::set_server(custom_server);

        // Instantiate verification environment
        env = uart_env::type_id::create("env", this);

        // Retrieve and distribute virtual interfaces
        if (!uvm_config_db#(axi4lite_default_interface)::get(this, "", "axil_vif", axil_vif)) begin
            `uvm_fatal("UART_TEST", "axil_vif virtual interface not found in uvm_config_db")
        end
        uvm_config_db#(axi4lite_default_interface)::set(this, "env.axil_agent*", "vif", axil_vif);

        if (!uvm_config_db#(uart_bfm_default_interface)::get(this, "", "uart_vif", uart_vif)) begin
            `uvm_fatal("UART_TEST", "uart_vif virtual interface not found in uvm_config_db")
        end
        uvm_config_db#(uart_bfm_default_interface)::set(this, "env.uart_agent*", "vif", uart_vif);
    endfunction

    virtual task run_phase(uvm_phase phase);
        string test_case;
        uart_seq_base seq;

        phase.raise_objection(this);

        // Fetch command line +TEST_CASE argument
        if (!$value$plusargs("TEST_CASE=%s", test_case)) begin
            `uvm_fatal("UART_TEST", "No +TEST_CASE plusarg found!")
        end

        // Dynamically instantiate the requested sequence
        $cast(seq, uvm_factory::get().create_object_by_name(test_case, "", test_case));

        if (seq == null) begin
            `uvm_fatal("UART_TEST", $sformatf("Failed to create sequence: %s", test_case))
        end

        // Pass regmodel handle to config_db for sequence to retrieve
        uvm_config_db#(uart_reg_block)::set(null, "", "regmodel", env.regmodel);

        // Wait for reset release before starting sequence
        `uvm_info("UART_TEST", "Waiting for reset release...", UVM_LOW)
        wait(axil_vif.aresetn === 1'b1);
        repeat(5) @(posedge axil_vif.aclk);
        `uvm_info("UART_TEST", "Reset released. Starting sequence.", UVM_LOW)

        `uvm_info("UART_TEST", $sformatf("Starting sequence: %s", test_case), UVM_LOW)
        seq.start(env.sqr);

        phase.drop_objection(this);
    endtask

endclass

`endif
