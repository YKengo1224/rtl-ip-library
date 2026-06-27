`ifndef _H_TEST_UART_DISABLE_MID_TRANSFER_SV
`define _H_TEST_UART_DISABLE_MID_TRANSFER_SV

class test_uart_disable_mid_transfer extends uart_test_case_helper;
    `uvm_object_utils(test_uart_disable_mid_transfer)
    function new(string name = "test_uart_disable_mid_transfer"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_uart_disable_mid_transfer ==========", UVM_LOW)
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

        regmodel.uart_data.write(status, 32'h0000_00A5, .parent(this));
        wait_clk(100);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));

        wait_clk(100);
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("UART disabled status check success", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_uart_disable_mid_transfer ==========", UVM_LOW)
    endtask
endclass

`endif
