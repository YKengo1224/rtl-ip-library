`ifndef _H_TEST_RX_FIFO_LIMIT_BURST_SV
`define _H_TEST_RX_FIFO_LIMIT_BURST_SV

class test_rx_fifo_limit_burst extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_limit_burst)
    function new(string name = "test_rx_fifo_limit_burst"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_limit_burst ==========", UVM_LOW)
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

        wait_clk(50);

        for (int i = 0; i < 17; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000.0 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        wait_clk(200);

        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("RX FIFO is full", rdata[5], 1'b1);

        for (int i = 0; i < 17; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
            check_seq($sformatf("RX Burst data index %0d", i), rdata[7:0], i);
        end
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass

`endif
