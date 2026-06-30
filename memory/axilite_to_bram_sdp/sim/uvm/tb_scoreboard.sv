`ifndef _H_TB_SCOREBOARD_SV
`define _H_TB_SCOREBOARD_SV

import common_pkg::*;

`uvm_analysis_imp_decl(_reg)

class tb_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp_reg #(axi4lite_trans, tb_scoreboard) reg_imp;

    `uvm_component_utils(tb_scoreboard)

    test_result result_obj;

    // Shadow Memory for BRAM (depth = 1024, 32-bit width)
    bit [31:0] shadow_mem [1024];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        // Initialize shadow memory to 0
        for (int i = 0; i < 1024; i++) begin
            shadow_mem[i] = 32'h0;
        end
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reg_imp = new("reg_imp", this);

        // Instantiate and set test_result to config_db
        result_obj = test_result::type_id::create("test_result");
        uvm_config_db#(test_result)::set(null, "*", "test_result", result_obj);
    endfunction

    function void write_reg(axi4lite_trans trans);
        bit [9:0] word_addr;
        word_addr = trans.addr[11:2]; // byte address to word address

        if (trans.cmd == axi4lite_pkg::WRITE) begin
            bit [31:0] old_data;
            bit [31:0] new_data;
            old_data = shadow_mem[word_addr];
            
            // Apply byte write strobe
            for (int i = 0; i < 4; i++) begin
                if (trans.wstrb[i]) begin
                    new_data[i*8 +: 8] = trans.data[i*8 +: 8];
                end else begin
                    new_data[i*8 +: 8] = old_data[i*8 +: 8];
                end
            end
            shadow_mem[word_addr] = new_data;
            `uvm_info("SCB_WRITE", $sformatf("Write Addr: 0x%0h (Word: %0d), Data: 0x%0h, WSTRB: 4'b%0b, Shadow updated: 0x%0h -> 0x%0h", 
                                            trans.addr, word_addr, trans.data, trans.wstrb, old_data, new_data), UVM_HIGH)
        end
        else if (trans.cmd == axi4lite_pkg::READ) begin
            bit [31:0] expected_data;
            expected_data = shadow_mem[word_addr];
            
            `uvm_info("SCB_READ", $sformatf("Read Addr: 0x%0h (Word: %0d), Expected: 0x%0h, Actual: 0x%0h", 
                                           trans.addr, word_addr, expected_data, trans.data), UVM_LOW)
            
            result_obj.reg_cmp_count++;
            if (trans.data[31:0] !== expected_data) begin
                `uvm_error("SCB_MISMATCH", $sformatf("Data mismatch at Addr 0x%0h! Expected: 0x%0h, Actual: 0x%0h", 
                                                    trans.addr, expected_data, trans.data))
                result_obj.reg_cmp_error++;
            end
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        if (result_obj != null) begin
            result_obj.report();
            
            // Overall Check
            if (result_obj.reg_cmp_error == 0 && result_obj.reg_cmp_count > 0) begin
                `uvm_info("TB_SCOREBOARD", ">>> TEST RESULT: PASS <<<", UVM_LOW)
            end else begin
                `uvm_error("TB_SCOREBOARD", ">>> TEST RESULT: FAIL <<<")
            end
        end else begin
            `uvm_error("TB_SCOREBOARD", ">>> TEST RESULT: FAIL (test_result object not initialized) <<<")
        end
    endfunction

endclass
`endif
