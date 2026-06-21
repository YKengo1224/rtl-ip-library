`ifndef _H_TB_SCOREBOARD_SV
`define _H_TB_SCOREBOARD_SV

import common_pkg::*;

`uvm_analysis_imp_decl(_reg)

class tb_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp_reg #(axi4lite_trans, tb_scoreboard) reg_imp;

    `uvm_component_utils(tb_scoreboard)

    test_result result_obj;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction  // new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reg_imp = new("reg_imp", this);

        // Instantiate and set test_result to config_db
        result_obj = test_result::type_id::create("test_result");
        uvm_config_db#(test_result)::set(null, "*", "test_result", result_obj);
    endfunction

    function void write_reg(axi4lite_trans trans);

    endfunction

    task run_phase(uvm_phase phase);

    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        if (result_obj != null) begin
            result_obj.report();
            
            // Overall Check
            if (result_obj.reg_cmp_error == 0 && result_obj.seq_cmp_error == 0 && 
                (result_obj.reg_cmp_count > 0 || result_obj.seq_cmp_count > 0)) begin
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
