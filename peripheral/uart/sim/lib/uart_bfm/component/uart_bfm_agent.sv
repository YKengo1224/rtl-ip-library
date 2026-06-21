`ifndef _H_UART_BFM_AGENT_SV
`define _H_UART_BFM_AGENT_SV

class uart_bfm_agent #(
    type t_if = uart_bfm_default_interface,
    type t_trans = uart_bfm_default_transfer
) extends uvm_agent;

    uart_bfm_driver #(t_if, t_trans) drv;
    uart_bfm_monitor #(t_if, t_trans) mntr;

    uvm_sequencer #(t_trans) seqr;

    uvm_analysis_port #(t_trans) ap;

    uart_bfm_config cfg;


    `uvm_component_param_utils(uart_bfm_agent#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(uart_bfm_config)::get(this, "", "uart_bfm_cfg", cfg)) begin
            `uvm_info("UART_BFM_AGT", "uart_bfm_cfg not found, creating a default config", UVM_LOW)
            cfg = uart_bfm_config::type_id::create("cfg");
            cfg.baudrate = 115200;
            cfg.data_bit_width = 8;
            cfg.stop_bit_width = 1;
            cfg.parity_bit = 0;
            cfg.hw_flow_en = 0;
            cfg.tx_env = 0;
            cfg.rx_env = 0;
            cfg.over_samp_sel = 1; // 16x
        end
        uvm_config_db#(uart_bfm_config)::set(this, "*", "uart_bfm_cfg", cfg);

        ap = new("ap", this);
        mntr = uart_bfm_monitor#(t_if, t_trans)::type_id::create("mntr", this);

        if (get_is_active() == UVM_ACTIVE) begin
            drv  = uart_bfm_driver#(t_if, t_trans)::type_id::create("drv", this);
            seqr = uvm_sequencer#(t_trans)::type_id::create("seqr", this);
        end
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        mntr.ap.connect(this.ap);

        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass

`endif
