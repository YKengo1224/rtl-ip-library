`ifndef _H_TEST_DUPLEX_FIFO_LIMIT_BURST_SV
`define _H_TEST_DUPLEX_FIFO_LIMIT_BURST_SV

class test_duplex_fifo_limit_burst extends uart_test_case_helper;
    `uvm_object_utils(test_duplex_fifo_limit_burst)
    function new(string name = "test_duplex_fifo_limit_burst"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_duplex_fifo_limit_burst ==========", UVM_LOW)
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

        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.write(status, i + 8'h10, .parent(this));
        end

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        fork
            begin
                for (int i = 0; i < 32; i++) begin
                    bfm_tx.data = i + 8'h80;
                    bfm_tx.start(p_sequencer.uart_sqr);
                    #( (1000000000000.0 / 115200) * 12 * 1ps );
                end
            end
            begin
                do begin
                    wait_clk(100);
                    regmodel.uart_status.read(status, rdata, .parent(this));
                end while (rdata[0] == 1'b0);
            end
        join

        wait_clk(500);

        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
            check_seq($sformatf("RX Duplex Burst data index %0d", i), rdata[7:0], i + 8'h80);
        end
        `uvm_info("UART_SEQ", "========== Finished test_duplex_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass

`endif
