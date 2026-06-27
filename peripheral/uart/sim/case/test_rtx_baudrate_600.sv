`ifndef _H_TEST_RTX_BAUDRATE_600_SV
`define _H_TEST_RTX_BAUDRATE_600_SV

class test_rtx_baudrate_600 extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_baudrate_600)
    function new(string name = "test_rtx_baudrate_600"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_baudrate_600 ==========", UVM_LOW)
        run_rtx_test(600, 8, 1, 0, 1, 0, 0, 0);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_baudrate_600 ==========", UVM_LOW)
    endtask
endclass

`endif
