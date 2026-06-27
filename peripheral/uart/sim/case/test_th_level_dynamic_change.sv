`ifndef _H_TEST_TH_LEVEL_DYNAMIC_CHANGE_SV
`define _H_TEST_TH_LEVEL_DYNAMIC_CHANGE_SV

class test_th_level_dynamic_change extends uart_test_case_helper;
    `uvm_object_utils(test_th_level_dynamic_change)
    function new(string name = "test_th_level_dynamic_change"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_th_level_dynamic_change ==========", UVM_LOW)
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
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0808, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this));

        for (int i = 0; i < 5; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000.0 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX int inactive with count 5 < th 8", rdata[0], 1'b0);

        regmodel.uart_int_conf_th.write(status, 32'h0000_0408, .parent(this));
        wait_clk(10);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX int active after changing th to 4", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_th_level_dynamic_change ==========", UVM_LOW)
    endtask
endclass

`endif
