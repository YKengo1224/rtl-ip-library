`ifndef _H_TEST_TX_FIFO_FULL_PROTECT_SV
`define _H_TEST_TX_FIFO_FULL_PROTECT_SV

class test_tx_fifo_full_protect extends uart_test_case_helper;
    `uvm_object_utils(test_tx_fifo_full_protect)
    function new(string name = "test_tx_fifo_full_protect"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_fifo_full_protect ==========", UVM_LOW)
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

        for (int i = 0; i < 35; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        repeat (32) begin
            wait_clk(1000);
        end

        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("TX FIFO is empty after transfers", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_full_protect ==========", UVM_LOW)
    endtask
endclass

`endif
