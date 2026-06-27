`ifndef _H_TEST_POLARITY_MISMATCH_SV
`define _H_TEST_POLARITY_MISMATCH_SV

class test_polarity_mismatch extends uart_test_case_helper;
    `uvm_object_utils(test_polarity_mismatch)
    function new(string name = "test_polarity_mismatch"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_polarity_mismatch ==========", UVM_LOW)
        get_regmodel_local();
        
        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.tx_env = 0;
        bfm_cfg.rx_env = 0;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_mode.write(status, 32'h0000_0010, .parent(this)); // rx_inv = 1
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0001_0000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000.0 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Framing error detected", rdata[16], 1'b1);
        
        `uvm_info("UART_SEQ", "========== Finished test_polarity_mismatch ==========", UVM_LOW)
    endtask
endclass

`endif
