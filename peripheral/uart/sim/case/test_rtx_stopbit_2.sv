`ifndef _H_TEST_RTX_STOPBIT_2_SV
`define _H_TEST_RTX_STOPBIT_2_SV

class test_rtx_stopbit_2 extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_stopbit_2)
    function new(string name = "test_rtx_stopbit_2"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_stopbit_2 ==========", UVM_LOW)
        run_rtx_test(115200, 8, 3, 0, 1, 0, 0, 0);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_stopbit_2 ==========", UVM_LOW)
    endtask
endclass

`endif
