`ifndef _H_TEST_RX_TIMEOUT_SV
`define _H_TEST_RX_TIMEOUT_SV

class test_rx_timeout extends uart_test_case_helper;
    `uvm_object_utils(test_rx_timeout)
    function new(string name = "test_rx_timeout"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_timeout ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_1000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000.0 / 115200) * 12 * 1ps );
        wait_clk(100);

        #( (1000000000000.0 / 115200) * 5 * 10 * 1ps );
        wait_clk(1000);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout Raw Status is High", rdata[12], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_timeout ==========", UVM_LOW)
    endtask
endclass

`endif
