`ifndef _H_TEST_RTX_PARITY_EVEN_SV
`define _H_TEST_RTX_PARITY_EVEN_SV

class test_rtx_parity_even extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_parity_even)
    function new(string name = "test_rtx_parity_even"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_parity_even ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 2, 1, 0, 0, 0);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_parity_even ==========", UVM_LOW)
    endtask
endclass

`endif
