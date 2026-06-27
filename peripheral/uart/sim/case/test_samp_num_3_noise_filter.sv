`ifndef _H_TEST_SAMP_NUM_3_NOISE_FILTER_SV
`define _H_TEST_SAMP_NUM_3_NOISE_FILTER_SV

class test_samp_num_3_noise_filter extends uart_test_case_helper;
    `uvm_object_utils(test_samp_num_3_noise_filter)
    function new(string name = "test_samp_num_3_noise_filter"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_samp_num_3_noise_filter ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0011_0028, .parent(this)); // 3-point, 16x, div 40

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.noize_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000.0 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("Majority vote noise filtered RX data", rdata[7:0], 8'hA5);
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_3_noise_filter ==========", UVM_LOW)
    endtask
endclass

`endif
