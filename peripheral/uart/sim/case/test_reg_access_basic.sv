class test_reg_access_basic extends uart_seq_base;
    `uvm_object_utils(test_reg_access_basic)

    function new(string name = "test_reg_access_basic");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;
        bit [31:0] rdata;

        // Set testcase specific timeout
        uvm_top.set_timeout(10us);

        // Get regmodel from config_db
        if (!uvm_config_db#(uart_reg_block)::get(null, "", "regmodel", regmodel)) begin
            `uvm_fatal("REG_TEST", "regmodel not found in config_db")
        end

        `uvm_info("REG_TEST", "========== Starting test_reg_access_basic ==========", UVM_LOW)

        // 1. RW Registers Write & Read checks
        // UART_CONF_FRAME: Init 'h810. Write 'h921 and verify.
        regmodel.uart_conf_frame.write(status, 32'h0000_0921, .parent(this));
        regmodel.uart_conf_frame.read(status, rdata, .parent(this));
        if (rdata !== 32'h0000_0921) begin
            `uvm_error("REG_TEST", $sformatf("UART_CONF_FRAME RW error: Exp 'h921, Act 'h%0x", rdata))
        end

        // UART_CONF_MODE: Write 'h21 and verify.
        regmodel.uart_conf_mode.write(status, 32'h0000_0021, .parent(this));
        regmodel.uart_conf_mode.read(status, rdata, .parent(this));
        if (rdata !== 32'h0000_0021) begin
            `uvm_error("REG_TEST", $sformatf("UART_CONF_MODE RW error: Exp 'h21, Act 'h%0x", rdata))
        end

        // UART_CONF_SAMP: clk_div = 'h54, over_samp = 2, samp_num = 1 ('h120054) and verify.
        regmodel.uart_conf_samp.write(status, 32'h0012_0054, .parent(this));
        regmodel.uart_conf_samp.read(status, rdata, .parent(this));
        if (rdata !== 32'h0012_0054) begin
            `uvm_error("REG_TEST", $sformatf("UART_CONF_SAMP RW error: Exp 'h120054, Act 'h%0x", rdata))
        end

        // UART_INT_CTRL: Write 'h01010101 and verify.
        regmodel.uart_int_ctrl.write(status, 32'h0101_0101, .parent(this));
        regmodel.uart_int_ctrl.read(status, rdata, .parent(this));
        if (rdata !== 32'h0101_0101) begin
            `uvm_error("REG_TEST", $sformatf("UART_INT_CTRL RW error: Exp 'h01010101, Act 'h%0x", rdata))
        end

        // UART_INT_CONF_TH: rx_th = 'h10, tx_th = 'h10 ('h1010) and verify.
        regmodel.uart_int_conf_th.write(status, 32'h0000_1010, .parent(this));
        regmodel.uart_int_conf_th.read(status, rdata, .parent(this));
        if (rdata !== 32'h0000_1010) begin
            `uvm_error("REG_TEST", $sformatf("UART_INT_CONF_TH RW error: Exp 'h1010, Act 'h%0x", rdata))
        end

        // 2. RO Register Write Protection check
        // Verify UART_STATUS (RO) cannot be updated by bus writes.
        regmodel.uart_status.read(status, rdata, .parent(this));
        regmodel.uart_status.write(status, 32'hFFFF_FFFF, .parent(this));
        begin
            bit [31:0] next_rdata;
            regmodel.uart_status.read(status, next_rdata, .parent(this));
            if (next_rdata !== rdata) begin
                `uvm_error("REG_TEST", $sformatf("UART_STATUS RO Protection error: changed from 'h%0x to 'h%0x", rdata, next_rdata))
            end
        end

        `uvm_info("REG_TEST", "========== Finished test_reg_access_basic ==========", UVM_LOW)
    endtask
endclass
