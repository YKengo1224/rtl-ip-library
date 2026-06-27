`ifndef _H_TEST_TX_TH_LEVEL_MIN_SV
`define _H_TEST_TX_TH_LEVEL_MIN_SV

class test_tx_th_level_min extends uart_test_case_helper;
    `uvm_object_utils(test_tx_th_level_min)
    function new(string name = "test_tx_th_level_min"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_th_level_min ==========", UVM_LOW)
        get_regmodel_local();
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));
        
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX FIFO count 1 > th 0: int inactive", rdata[4], 1'b0);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        check_seq("TX FIFO count 0 <= th 0: int active", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_th_level_min ==========", UVM_LOW)
    endtask
endclass

`endif
