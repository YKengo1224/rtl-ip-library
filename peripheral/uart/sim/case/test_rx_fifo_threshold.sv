`ifndef _H_TEST_RX_FIFO_THRESHOLD_SV
`define _H_TEST_RX_FIFO_THRESHOLD_SV

class test_rx_fifo_threshold extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_threshold)
    function new(string name = "test_rx_fifo_threshold"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_threshold ==========", UVM_LOW)
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
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0400, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this));

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int inactive initially", rdata[0], 1'b0);

        for (int i = 0; i < 3; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000.0 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int still inactive at 3 bytes", rdata[0], 1'b0);

        bfm_tx.data = 3;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000.0 / 115200) * 12 * 1ps );
        wait_clk(100);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int active at 4 bytes", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass

`endif
