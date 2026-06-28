`ifndef _H_TEST_RX_FRAMING_ERROR_SV
`define _H_TEST_RX_FRAMING_ERROR_SV

class test_rx_framing_error extends uart_test_case_helper;
    `uvm_object_utils(test_rx_framing_error)
    function new(string name = "test_rx_framing_error"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_framing_error ==========", UVM_LOW)
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
        
        // 1. Initial State: Disable all interrupts (including framing error interrupt)
        regmodel.uart_int_ctrl.write(status, 32'h0000_0000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.frame_err_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000.0 / 115200) * 12 * 1ps );
        wait_clk(200);

        // 2. Verify raw status: Framing Error occurred, raw status should be 32'h0001_0000
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Disabled) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0001_0000), UVM_LOW)
        check_seq("Raw Status has Framing Error set", rdata, 32'h0001_0000);

        // Verify that the interrupt pin is Low because it is disabled
        check_seq("Interrupt Signal (o_interrupt_aclkr) is Low when disabled", mon_vif.o_interrupt_aclkr, 1'b0);

        // 3. Enable Framing Error interrupt (bit 16)
        regmodel.uart_int_ctrl.write(status, 32'h0001_0000, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the interrupt pin now becomes High
        check_seq("Interrupt Signal (o_interrupt_aclkr) becomes High when enabled", mon_vif.o_interrupt_aclkr, 1'b1);

        // 4. Clear Framing Error interrupt (W1C to bit 16)
        regmodel.uart_int_rs.write(status, 32'h0001_0000, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the raw status register is cleared of Framing Error (expected value becomes 32'h0000_0000)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Cleared) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0000_0000), UVM_LOW)
        check_seq("Raw Status framing error is cleared", rdata, 32'h0000_0000);

        // Verify that the interrupt pin goes back to Low
        check_seq("Interrupt Signal (o_interrupt_aclkr) goes Low after clear", mon_vif.o_interrupt_aclkr, 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_rx_framing_error ==========", UVM_LOW)
    endtask
endclass

`endif
