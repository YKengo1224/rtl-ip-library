`ifndef _H_UART_ENV_SV
`define _H_UART_ENV_SV

class uart_env extends uvm_env;
    `uvm_component_utils(uart_env)

    // Agents
    axi4lite_master_agent #(axi4lite_default_interface, axi4lite_default_transfer) axil_agent;
    uart_bfm_agent #(uart_bfm_default_interface, uart_bfm_default_transfer)        uart_agent;

    // Scoreboard & Virtual Sequencer
    uart_scoreboard scb;
    uart_sequencer  sqr;

    // RAL register model and Adapter
    uart_reg_block   regmodel;
    axi4lite_adapter axi_adapter;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Instantiate Agents
        axil_agent = axi4lite_master_agent#(axi4lite_default_interface, axi4lite_default_transfer)::type_id::create("axil_agent", this);
        uart_agent = uart_bfm_agent#(uart_bfm_default_interface, uart_bfm_default_transfer)::type_id::create("uart_agent", this);

        // Instantiate Scoreboard & Virtual Sequencer
        scb = uart_scoreboard::type_id::create("scb", this);
        sqr = uart_sequencer::type_id::create("sqr", this);

        // Instantiate RAL Register Model and Adapter
        if (!uvm_config_db#(uart_reg_block)::get(this, "", "regmodel", regmodel)) begin
            regmodel = uart_reg_block::type_id::create("regmodel", this);
            regmodel.build();
            regmodel.lock_model();
        end
        axi_adapter = axi4lite_adapter::type_id::create("axi_adapter", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect Monitors to Scoreboard FIFOs
        axil_agent.mntr.item_collected_port.connect(scb.axil_fifo.analysis_export);
        uart_agent.ap.connect(scb.uart_fifo.analysis_export);

        // Connect Sequencers to Virtual Sequencer
        sqr.axil_sqr = axil_agent.seqr;
        if (uart_agent.get_is_active() == UVM_ACTIVE) begin
            sqr.uart_sqr = uart_agent.seqr;
        end

        // Connect Regmodel to AXI4-Lite Sequencer via Adapter
        regmodel.default_map.set_sequencer(axil_agent.seqr, axi_adapter);
        regmodel.default_map.set_auto_predict(1);
    endfunction
endclass

`endif
