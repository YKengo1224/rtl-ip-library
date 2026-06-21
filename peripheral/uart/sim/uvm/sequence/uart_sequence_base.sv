`ifndef _H_UART_SEQUENCE_BASE_SV
`define _H_UART_SEQUENCE_BASE_SV

// Import dependent packages
import uvm_pkg::*;
`include "uvm_macros.svh"
import axi4lite_pkg::*;
import uart_bfm_pkg::*;
import common_pkg::*;

class uart_seq_base extends uvm_sequence;
    `uvm_object_utils(uart_seq_base)
    `uvm_declare_p_sequencer(uart_sequencer)

    uart_reg_block regmodel;
    axi4lite_default_interface vif;
    test_result result_obj;

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

    // Retrieve comparison result object
    virtual function void get_result_obj();
        if (result_obj == null) begin
            if (!uvm_config_db#(test_result)::get(null, "", "test_result", result_obj)) begin
                `uvm_info("UART_SEQ", "test_result object not found in config_db", UVM_DEBUG)
            end
        end
    endfunction

    // Perform register value comparison and count it in result_obj
    virtual function void check_reg(string msg, bit [31:0] act, bit [31:0] exp);
        bit err = (act !== exp);
        get_result_obj();
        if (result_obj != null) begin
            result_obj.add_reg_cmp(1, err);
        end
        if (err) begin
            `uvm_error("REG_CMP", $sformatf("%s error: Exp 'h%0x, Act 'h%0x", msg, exp, act))
        end else begin
            `uvm_info("REG_CMP", $sformatf("%s check: PASS ('h%0x)", msg, act), UVM_HIGH)
        end
    endfunction

    // Perform sequence/data value comparison and count it in result_obj
    virtual function void check_seq(string msg, bit [31:0] act, bit [31:0] exp);
        bit err = (act !== exp);
        get_result_obj();
        if (result_obj != null) begin
            result_obj.add_seq_cmp(1, err);
        end
        if (err) begin
            `uvm_error("SEQ_CMP", $sformatf("%s error: Exp 'h%0x, Act 'h%0x", msg, exp, act))
        end else begin
            `uvm_info("SEQ_CMP", $sformatf("%s check: PASS ('h%0x)", msg, act), UVM_HIGH)
        end
    endfunction

endclass



`endif
