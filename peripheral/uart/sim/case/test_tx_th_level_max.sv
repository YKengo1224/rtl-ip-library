`ifndef _H_TEST_TX_TH_LEVEL_MAX_SV
`define _H_TEST_TX_TH_LEVEL_MAX_SV

class test_tx_th_level_max extends uart_test_case_helper;
    `uvm_object_utils(test_tx_th_level_max)
    function new(string name = "test_tx_th_level_max"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_th_level_max ==========", UVM_LOW)
        get_regmodel_local();

        regmodel.uart_int_conf_th.write(status, 32'h0000_001F, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX FIFO count 0 <= th 31: int active", rdata[4], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_th_level_max ==========", UVM_LOW)
    endtask
endclass

`endif
