`ifndef _H_UART_SEQUENCE_BASE_SV
`define _H_UART_SEQUENCE_BASE_SV

// Import dependent packages
import uvm_pkg::*;
`include "uvm_macros.svh"
import axi4lite_pkg::*;
import uart_bfm_pkg::*;

class uart_seq_base extends uvm_sequence;
    `uvm_object_utils(uart_seq_base)
    `uvm_declare_p_sequencer(uart_sequencer)

    uart_reg_block regmodel;
    axi4lite_default_interface vif;

    // Instantiated sequences inside the base sequence
    axi4lite_write_seq    axil_write;
    axi4lite_read_seq     axil_read;
    uart_bfm_config_seq   bfm_cfg;
    uart_bfm_tx_seq       bfm_tx;

    function new(string name = "uart_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);
        
        // Get virtual interface from config_db
        if (!uvm_config_db#(axi4lite_default_interface)::get(null, "", "axil_vif", vif)) begin
            `uvm_fatal("UART_SEQ", "axil_vif virtual interface not found in config_db")
        end
        
        // Create instances of all sequences
        axil_write = axi4lite_write_seq::type_id::create("axil_write");
        axil_read  = axi4lite_read_seq::type_id::create("axil_read");
        bfm_cfg    = uart_bfm_config_seq::type_id::create("bfm_cfg");
        bfm_tx     = uart_bfm_tx_seq::type_id::create("bfm_tx");
    endfunction

    // Clock wait task
    virtual task wait_clk(int i);
        repeat (i) begin
            @(posedge vif.aclk);
        end
    endtask

endclass



`endif
