`ifndef _H_TEST_RX_POLARITY_INV_SV
`define _H_TEST_RX_POLARITY_INV_SV

class test_rx_polarity_inv extends uart_test_case_helper;
    `uvm_object_utils(test_rx_polarity_inv)
    function new(string name = "test_rx_polarity_inv"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rx_polarity_inv ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 1, 0, 0, 1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_polarity_inv ==========", UVM_LOW)
    endtask
endclass

`endif
