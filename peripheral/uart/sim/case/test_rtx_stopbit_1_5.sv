`ifndef _H_TEST_RTX_STOPBIT_1_5_SV
`define _H_TEST_RTX_STOPBIT_1_5_SV

class test_rtx_stopbit_1_5 extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_stopbit_1_5)
    function new(string name = "test_rtx_stopbit_1_5"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_stopbit_1_5 ==========", UVM_LOW)
        run_rtx_test(115200, 8, 2, 0, 1, 0, 0, 0);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_stopbit_1_5 ==========", UVM_LOW)
    endtask
endclass

`endif
