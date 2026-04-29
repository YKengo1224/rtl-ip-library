`ifndef _H_AXI4LITE_MASTER_AGENT_SV
`define _H_AXI4LITE_MASTER_AGENT_SV

class axi4lite_agent #(
    type t_if = axi4lite_default_interface,
    type t_trans = axi4lite_default_transfer
) extends uvm_agent;

    axi4lite_master_driver #(t_if, t_trans) drv;
    axi4lite_monitor #(t_if, t_trans) mntr;
    uvm_sequencer #(t_trans) seqr;


    `uvm_component_param_utils(axi4lite_agent#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mntr = axi4lite_monitor#(t_if, t_trans)::type_id::create("mntr", this);

        if (get_is_active() == UVM_ACTIVE) begin
            drv  = axi4lite_master_driver#(t_if, t_trans)::type_id::create("drv", this);
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
