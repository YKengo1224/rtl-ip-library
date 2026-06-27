`ifndef _H_TEST_RX_FIFO_EMPTY_READ_SV
`define _H_TEST_RX_FIFO_EMPTY_READ_SV

class test_rx_fifo_empty_read extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_empty_read)
    function new(string name = "test_rx_fifo_empty_read"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_empty_read ==========", UVM_LOW)
        get_regmodel_local();

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("RX FIFO is empty initially", rdata[4], 1'b1);

        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("RX FIFO empty read completed without hang", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_empty_read ==========", UVM_LOW)
    endtask
endclass

`endif
