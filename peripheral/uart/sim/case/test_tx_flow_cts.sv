`ifndef _H_TEST_TX_FLOW_CTS_SV
`define _H_TEST_TX_FLOW_CTS_SV

class test_tx_flow_cts extends uart_test_case_helper;
    `uvm_object_utils(test_tx_flow_cts)
    function new(string name = "test_tx_flow_cts"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_flow_cts ==========", UVM_LOW)
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
        uart_vif.rtsn = 1'b1;
        wait_clk(10);

        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        repeat (100) begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
            if (rdata[8] == 1'b1) begin
                `uvm_error("FLOW_CTRL", "DUT started transmitting even though CTS was High!")
            end
        end

        uart_vif.rtsn = 1'b0;
        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b0);

        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b1);

        check_seq("CTS Flow Control Transmission verified", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_flow_cts ==========", UVM_LOW)
    endtask
endclass

`endif
