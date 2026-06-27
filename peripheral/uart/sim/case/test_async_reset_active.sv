`ifndef _H_TEST_ASYNC_RESET_ACTIVE_SV
`define _H_TEST_ASYNC_RESET_ACTIVE_SV

class test_async_reset_active extends uart_test_case_helper;
    `uvm_object_utils(test_async_reset_active)
    function new(string name = "test_async_reset_active"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_async_reset_active ==========", UVM_LOW)
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

        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        wait_clk(50);

        vif.force_reset = 1'b1;
        wait_clk(20);
        vif.force_reset = 1'b0;
        wait_clk(50);

        regmodel.uart_ctrl.read(status, rdata, .parent(this));
        check_seq("UART_CTRL reset to 0", rdata, 32'h0);

        regmodel.uart_conf_frame.read(status, rdata, .parent(this));
        check_seq("UART_CONF_FRAME reset to default", rdata, 32'h0000_0810);
        `uvm_info("UART_SEQ", "========== Finished test_async_reset_active ==========", UVM_LOW)
    endtask
endclass

`endif
