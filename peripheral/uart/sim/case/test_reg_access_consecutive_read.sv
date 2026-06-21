class test_reg_access_consecutive_read extends uart_seq_base;
    `uvm_object_utils(test_reg_access_consecutive_read)

    function new(string name = "test_reg_access_consecutive_read");
        super.new(name);
    endfunction

    virtual task body();
        uvm_status_e status;
        bit [31:0] rdata;

        // Set testcase specific timeout
        uvm_top.set_timeout(20us);

        // Get regmodel from config_db
        if (!uvm_config_db#(uart_reg_block)::get(null, "", "regmodel", regmodel)) begin
            `uvm_fatal("REG_TEST", "regmodel not found in config_db")
        end

        `uvm_info("REG_TEST", "========== Starting test_reg_access_consecutive_read ==========", UVM_LOW)

        // Perform 50 consecutive Back-to-Back reads on configuration and status registers
        for (int i = 0; i < 50; i++) begin
            regmodel.uart_conf_frame.read(status, rdata, .parent(this));
            regmodel.uart_status.read(status, rdata, .parent(this));
        end

        `uvm_info("REG_TEST", "========== Finished test_reg_access_consecutive_read ==========", UVM_LOW)
    endtask
endclass
