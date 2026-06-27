`ifndef _H_TEST_SAMP_NUM_3_NORMAL_SV
`define _H_TEST_SAMP_NUM_3_NORMAL_SV

class test_samp_num_3_normal extends uart_test_case_helper;
    `uvm_object_utils(test_samp_num_3_normal)
    function new(string name = "test_samp_num_3_normal"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_samp_num_3_normal ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 1, 1, 0, 0);
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_3_normal ==========", UVM_LOW)
    endtask
endclass

`endif
