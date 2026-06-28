`ifndef _H_TEST_RX_TIMEOUT_SV
`define _H_TEST_RX_TIMEOUT_SV

class test_rx_timeout extends uart_test_case_helper;
    `uvm_object_utils(test_rx_timeout)
    function new(string name = "test_rx_timeout"); super.new(name); endfunction
    virtual task body();
        bit [31:0]   rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_timeout ==========", UVM_LOW)
        get_regmodel_local();

        // 1. Configure BFM (Baudrate: 115200, 8-bit, 1 Stop, No Parity)
        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1; // 16x
        bfm_cfg.start(p_sequencer.uart_sqr);

        // 2. Enable UART IP and Configure Frame/Sampling via direct RAL
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        // Disable all interrupts initially
        regmodel.uart_int_ctrl.write(status, 32'h0000_0000, .parent(this));

        // Wait for registers write to complete and UART to be fully active
        wait_clk(100);

        // 3. Trigger BFM to transmit serial data 8'h5A to DUT
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        // Wait for transmission to finish
        wait_clk(20000);

        // Wait for timeout (needs ~83k cycles. Wait 120k cycles ~ 1.2ms)
        wait_clk(120000);

        // 4. Verify raw status: RX Timeout occurred, raw status should be 32'h0000_1000
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Disabled) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0000_1000), UVM_LOW)
        check_seq("Raw Status has RX Timeout set", rdata, 32'h0000_1000);

        // Verify that the interrupt pin is Low because it is disabled
        check_seq("Interrupt Signal (o_interrupt_aclkr) is Low when disabled", mon_vif.o_interrupt_aclkr, 1'b0);

        // 5. Enable RX Timeout interrupt (bit 12)
        regmodel.uart_int_ctrl.write(status, 32'h0000_1000, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the interrupt pin now becomes High
        check_seq("Interrupt Signal (o_interrupt_aclkr) becomes High when enabled", mon_vif.o_interrupt_aclkr, 1'b1);

        // 6. Clear RX Timeout interrupt (W1C to bit 12)
        regmodel.uart_int_rs.write(status, 32'h0000_1000, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the raw status register is cleared of RX Timeout (expected value becomes 32'h0000_0000)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Cleared) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0000_0000), UVM_LOW)
        check_seq("Raw Status rx timeout is cleared", rdata, 32'h0000_0000);

        // Verify that the interrupt pin goes back to Low
        check_seq("Interrupt Signal (o_interrupt_aclkr) goes Low after clear", mon_vif.o_interrupt_aclkr, 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_rx_timeout ==========", UVM_LOW)
    endtask
endclass

`endif
