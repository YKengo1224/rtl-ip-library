`ifndef _H_TEST_RX_FLOW_RTS_SV
`define _H_TEST_RX_FLOW_RTS_SV

class test_rx_flow_rts extends uart_test_case_helper;
    `uvm_object_utils(test_rx_flow_rts)
    function new(string name = "test_rx_flow_rts"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_flow_rts ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_mode.write(status, 32'h0000_0001, .parent(this)); // hw_flow_en = 1
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        wait_clk(50);
        check_seq("Initial RTS is Low", uart_vif.ctsn, 1'b0);

        for (int i = 0; i < 30; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000.0 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        check_seq("RTS goes High when FIFO is full", uart_vif.ctsn, 1'b1);

        for (int i = 0; i < 30; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
        end

        wait_clk(100);
        check_seq("RTS goes Low after FIFO is cleared", uart_vif.ctsn, 1'b0);
        `uvm_info("UART_SEQ", "========== Finished test_rx_flow_rts ==========", UVM_LOW)
    endtask
endclass

`endif
