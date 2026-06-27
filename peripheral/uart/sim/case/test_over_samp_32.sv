`ifndef _H_TEST_OVER_SAMP_32_SV
`define _H_TEST_OVER_SAMP_32_SV

class test_over_samp_32 extends uart_test_case_helper;
    `uvm_object_utils(test_over_samp_32)
    function new(string name = "test_over_samp_32"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_over_samp_32 ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 2, 0, 0, 0);
        `uvm_info("UART_SEQ", "========== Finished test_over_samp_32 ==========", UVM_LOW)
    endtask
endclass

`endif
