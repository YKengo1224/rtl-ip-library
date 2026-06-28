`ifndef _H_TEST_TX_FIFO_THRESHOLD_SV
`define _H_TEST_TX_FIFO_THRESHOLD_SV

class test_tx_fifo_threshold extends uart_test_case_helper;
    `uvm_object_utils(test_tx_fifo_threshold)
    function new(string name = "test_tx_fifo_threshold"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_fifo_threshold ==========", UVM_LOW)
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
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0004, .parent(this));
        
        // 1. Initial State: Disable all interrupts
        regmodel.uart_int_ctrl.write(status, 32'h0000_0000, .parent(this));

        // Write 14 items (free space becomes 2, which is < threshold 4, so no trigger yet)
        for (int i = 0; i < 14; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX Threshold int inactive initially", rdata[4], 1'b0);

        // Start transmission
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        // Wait for free space to exceed the threshold, triggering the interrupt
        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        // 2. Verify raw status: TX Threshold interrupt occurred, raw status should be 32'h0000_0010
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Disabled) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0000_0010), UVM_LOW)
        check_seq("Raw Status has TX Threshold set", rdata, 32'h0000_0010);

        // Verify that the interrupt pin is Low because it is disabled
        check_seq("Interrupt Signal (o_interrupt_aclkr) is Low when disabled", mon_vif.o_interrupt_aclkr, 1'b0);

        // 3. Enable TX Threshold interrupt (bit 4)
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the interrupt pin now becomes High
        check_seq("Interrupt Signal (o_interrupt_aclkr) becomes High when enabled", mon_vif.o_interrupt_aclkr, 1'b1);

        // 4. Clear TX Threshold interrupt (W1C to bit 4)
        regmodel.uart_int_rs.write(status, 32'h0000_0010, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the raw status register is cleared of TX Threshold (expected value becomes 32'h0000_0000)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Cleared) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0000_0000), UVM_LOW)
        check_seq("Raw Status tx threshold is cleared", rdata, 32'h0000_0000);

        // Verify that the interrupt pin goes back to Low
        check_seq("Interrupt Signal (o_interrupt_aclkr) goes Low after clear", mon_vif.o_interrupt_aclkr, 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass

`endif
