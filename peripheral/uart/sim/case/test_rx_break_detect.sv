`ifndef _H_TEST_RX_BREAK_DETECT_SV
`define _H_TEST_RX_BREAK_DETECT_SV

class test_rx_break_detect extends uart_test_case_helper;
    `uvm_object_utils(test_rx_break_detect)
    function new(string name = "test_rx_break_detect"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_break_detect ==========", UVM_LOW)
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
        
        // 1. Initial State: Disable all interrupts
        regmodel.uart_int_ctrl.write(status, 32'h0000_0000, .parent(this));

        wait_clk(50);
        uart_vif.txd = 1'b0;
        
        #( (1000000000000.0 / 115200) * 20 * 1ps );
        wait_clk(200);

        // 2. Verify raw status: Break Detect occurred, raw status should be 32'h0100_0000
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Disabled) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0100_0000), UVM_LOW)
        check_seq("Raw Status has Break Detect set", rdata, 32'h0100_0000);

        // Verify that the interrupt pin is Low because it is disabled
        check_seq("Interrupt Signal (o_interrupt_aclkr) is Low when disabled", mon_vif.o_interrupt_aclkr, 1'b0);

        // 3. Enable Break Detect interrupt (bit 24)
        regmodel.uart_int_ctrl.write(status, 32'h0100_0000, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the interrupt pin now becomes High
        check_seq("Interrupt Signal (o_interrupt_aclkr) becomes High when enabled", mon_vif.o_interrupt_aclkr, 1'b1);

        // Restore txd to High to allow clearing
        uart_vif.txd = 1'b1;
        wait_clk(100);

        // 4. Clear Break Detect interrupt (W1C to bit 24)
        regmodel.uart_int_rs.write(status, 32'h0100_0000, .parent(this));
        wait_clk(5); // Wait for signal propagation to the output pin

        // Verify that the raw status register is cleared of Break Detect (expected value becomes 32'h0000_0000)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Register Comparison (Cleared) - uart_int_rs: Act='h%08x, Exp='h%08x", rdata, 32'h0000_0000), UVM_LOW)
        check_seq("Raw Status break detect is cleared", rdata, 32'h0000_0000);

        // Verify that the interrupt pin goes back to Low
        check_seq("Interrupt Signal (o_interrupt_aclkr) goes Low after clear", mon_vif.o_interrupt_aclkr, 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_rx_break_detect ==========", UVM_LOW)
    endtask
endclass

`endif
