class test_tx_normal extends uart_seq_base;
    `uvm_object_utils(test_tx_normal)

    function new(string name = "test_tx_normal");
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

        `uvm_info("UART_SEQ", "========== Starting test_tx_normal ==========", UVM_LOW)

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

        // UART_CONF_SAMP: over_samp=16, clk_div=40 (73.750MHz / (115200 * 16) = 40.01)
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        // 3. Write data to TX FIFO (UART_DATA = 8'hA5)
        regmodel.uart_data.write(status, 32'h0000_00A5, .parent(this));

        // Wait for tx_busy to become 1 (starting transmission)
        do begin
            wait_clk(50);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b0);
        `uvm_info("UART_SEQ", "tx_busy detected high. Waiting for it to become low...", UVM_LOW)

        // Wait for tx_busy to become 0 (transmission finished)
        do begin
            wait_clk(50);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b1);
        `uvm_info("UART_SEQ", "tx_busy detected low. Transmission finished.", UVM_LOW)

        `uvm_info("UART_SEQ", "========== Finished test_tx_normal ==========", UVM_LOW)
    endtask
endclass
