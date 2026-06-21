class test_reg_access_alternate_rw extends uart_seq_base;
    `uvm_object_utils(test_reg_access_alternate_rw)

    function new(string name = "test_reg_access_alternate_rw");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;
        bit [31:0] rdata;
        bit [31:0] wdata;

        // Set testcase specific timeout
        uvm_top.set_timeout(20us);

        // Get regmodel from config_db
        if (!uvm_config_db#(uart_reg_block)::get(null, "", "regmodel", regmodel)) begin
            `uvm_fatal("REG_TEST", "regmodel not found in config_db")
        end

        `uvm_info("REG_TEST", "========== Starting test_reg_access_alternate_rw ==========", UVM_LOW)

        // Perform 50 alternate write and read cycles consecutively
        for (int i = 0; i < 50; i++) begin
            wdata = i; // Target the clk_div field in UART_CONF_SAMP
            regmodel.uart_conf_samp.write(status, wdata, .parent(this));
            regmodel.uart_conf_samp.read(status, rdata, .parent(this));
            
            if (rdata[15:0] !== wdata[15:0]) begin
                `uvm_error("REG_TEST", $sformatf("UART_CONF_SAMP alternate RW check failed: Exp 'h%0x, Act 'h%0x", wdata[15:0], rdata[15:0]))
            end
        end

        `uvm_info("REG_TEST", "========== Finished test_reg_access_alternate_rw ==========", UVM_LOW)
    endtask
endclass
