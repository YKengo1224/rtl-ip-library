`ifndef _H_QSPI_BFM_AGENT_SV
`define _H_QSPI_BFM_AGENT_SV

class qspi_bfm_agent #(
    type t_if = qspi_bfm_default_interface,
    type t_trans = qspi_bfm_default_transfer
) extends uvm_agent;

    qspi_bfm_driver #(t_if, t_trans) drv;

    uvm_sequencer #(t_trans) seqr;


    `uvm_component_param_utils(qspi_bfm_agent#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // mntr = axi4lite_monitor#(t_if, t_trans)::type_id::create("mntr", this);

        if (get_is_active() == UVM_ACTIVE) begin
            drv  = qspi_bfm_driver#(t_if, t_trans)::type_id::create("drv", this);
            seqr = uvm_sequencer#(t_trans)::type_id::create("seqr", this);
        end
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction
endclass

`endif
