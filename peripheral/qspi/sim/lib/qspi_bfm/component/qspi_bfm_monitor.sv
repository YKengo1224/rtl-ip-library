// `ifndef _H_QAPI_BFM_MONITOR_SV
// `define _H_QAPI_BFM_MONITOR_SV
// class qspi_bfm_monitor #(
//     type t_if = qspi_bfm_default_interface,
//     type t_trans = qspi_bfm_default_transfer
// ) extends uvm_monitor;

//     t_if vif;

//     uvm_analysis_imp #(t_trans, qspi_bfm_monitor) send_imp;
//     uvm_analysis_imp #(t_trans, qspi_bfm_monitor) rsv_imp;

//     uvm_analysis_port #(t_trans) ap;

//     `uvm_component_utils(qspi_bfm_monitor(qspi_bfm_monitor#(t_if, t_trans)))

//     function new(string name, uvm_component parent);
//         super.new(name, parent);

//     endfunction  // new

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         send_imp = new("send_imp", this);
//         rsv_imp = new("rsv_imp", this);

//         ap = new("ap", this);
//         if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
//             `uvm_fatal("QSPI_MONI", "vif not found")
//     endfunction

//     function void write_send_imp(t_trans trans);
      

// endclass
// `endif
