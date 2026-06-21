class test_rx_normal extends uart_seq_base;
    `uvm_object_utils(test_rx_normal)

    function new(string name = "test_rx_normal");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0]   rdata;
        uvm_status_e status;

        // Set testcase specific timeout
        uvm_top.set_timeout(200us);

        // Get regmodel from config_db
        if (!uvm_config_db#(uart_reg_block)::get(null, "", "regmodel", regmodel)) begin
            `uvm_fatal("UART_SEQ", "regmodel not found in config_db")
        end

        `uvm_info("UART_SEQ", "========== Starting test_rx_normal ==========", UVM_LOW)

        // 1. Configure BFM (Baudrate: 115200, 8-bit, 1 Stop, No Parity)
        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1; // 16x
        bfm_cfg.start(p_sequencer.uart_sqr);

        // 2. Enable UART IP and Configure Frame/Sampling via direct RAL
        // UART_CTRL: Enable UART (uart_enable = 1)
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        
        // UART_CONF_FRAME: data_bit_width=8, stop=1, parity=none
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));

        // UART_CONF_SAMP: over_samp=16, clk_div=54
        regmodel.uart_conf_samp.write(status, 32'h0001_0036, .parent(this));

        // 3. Trigger BFM to transmit serial data 8'h5A to DUT
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        // Wait for transmission to finish (100MHz clock: 20000 cycles = 200us)
        wait_clk(20000);

        // 4. Read RX FIFO data via UART_DATA register
        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("test_rx_normal receive data", rdata[7:0], 8'h5A);

        `uvm_info("UART_SEQ", "========== Finished test_rx_normal ==========", UVM_LOW)
    endtask
endclass
