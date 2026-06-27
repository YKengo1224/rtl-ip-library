`ifndef _H_TEST_TX_FIFO_THRESHOLD_SV
`define _H_TEST_TX_FIFO_THRESHOLD_SV

class test_tx_fifo_threshold extends uart_test_case_helper;
    `uvm_object_utils(test_tx_fifo_threshold)
    function new(string name = "test_tx_fifo_threshold"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_fifo_threshold ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0004, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));

        for (int i = 0; i < 10; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX Threshold int inactive initially", rdata[4], 1'b0);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        check_seq("TX Threshold int active", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass

`endif
