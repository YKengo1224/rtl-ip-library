`ifndef _H_TEST_RESULT_SV
`define _H_TEST_RESULT_SV

class test_result extends uvm_object;
    `uvm_object_utils(test_result)

    int reg_cmp_count;
    int reg_cmp_error;
    int seq_cmp_count;
    int seq_cmp_error;

    function new(string name = "test_result");
        super.new(name);
        reg_cmp_count = 0;
        reg_cmp_error = 0;
        seq_cmp_count = 0;
        seq_cmp_error = 0;
    endfunction

    function void add_reg_cmp(int count, int error);
        reg_cmp_count += count;
        reg_cmp_error += error;
    endfunction

    function void add_seq_cmp(int count, int error);
        seq_cmp_count += count;
        seq_cmp_error += error;
    endfunction

    function void report();
        `uvm_info("TEST_RESULT", $sformatf("=== Test Verification Report ==="), UVM_LOW)
        `uvm_info("TEST_RESULT", $sformatf("  Register Compare count: %0d (Errors: %0d)", reg_cmp_count, reg_cmp_error), UVM_LOW)
        `uvm_info("TEST_RESULT", $sformatf("  Sequence Compare count: %0d (Errors: %0d)", seq_cmp_count, seq_cmp_error), UVM_LOW)
        `uvm_info("TEST_RESULT", $sformatf("================================="), UVM_LOW)
    endfunction
endclass

`endif
