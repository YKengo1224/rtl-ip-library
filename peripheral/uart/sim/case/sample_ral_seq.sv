class sample_ral_seq extends uart_seq_base;
    `uvm_object_utils(sample_ral_seq)

    function new(string name = "sample_ral_seq");
        super.new(name);
    endfunction

    virtual task body();
        bit [31:0]   rdata;
        uvm_status_e status;

        // Set testcase specific timeout
        uvm_top.set_timeout(10us);

        // Get regmodel from config_db
        if (!uvm_config_db#(uart_reg_block)::get(null, "", "regmodel", regmodel)) begin
            `uvm_fatal("RAL_SEQ", "regmodel not found in config_db")
        end

        `uvm_info("RAL_SEQ", "========== Starting RAL Verification Sequence ==========", UVM_LOW)

        //---------------------------------------------------------
        // Test 1: Reset Value Check (Mirror & Read)
        //---------------------------------------------------------
        `uvm_info("RAL_SEQ", "--- Test 1: Checking Reset Values ---", UVM_LOW)
        
        // UART_CTRL reset check (Expected: 32'h0000_0000)
        regmodel.uart_ctrl.read(status, rdata, .parent(this));
        check_reg("uart_ctrl Reset Value", rdata, 32'h0);

        // UART_CONF_FRAME reset check (Expected: 32'h0000_0810)
        regmodel.uart_conf_frame.read(status, rdata, .parent(this));
        check_reg("uart_conf_frame Reset Value", rdata, 32'h0000_0810);

        //---------------------------------------------------------
        // Test 2: Write/Read check on Read/Write Register
        //---------------------------------------------------------
        `uvm_info("RAL_SEQ", "--- Test 2: Checking Write/Read on RW Register ---", UVM_LOW)
        
        // Write to UART_CONF_FRAME
        regmodel.uart_conf_frame.write(status, 32'h0000_0921, .parent(this)); // 9-bit width, 1.5 stop, odd parity
        regmodel.uart_conf_frame.read(status, rdata, .parent(this));
        check_reg("uart_conf_frame RW test", rdata, 32'h0000_0921);

        //---------------------------------------------------------
        // Test 3: Write check on Read-Only Register (Should not change value)
        //---------------------------------------------------------
        `uvm_info("RAL_SEQ", "--- Test 3: Checking Write on Read-Only Register ---", UVM_LOW)
        
        // Read current status
        regmodel.uart_status.read(status, rdata, .parent(this));
        `uvm_info("RAL_SEQ", $sformatf("Initial status: 'h%0x", rdata), UVM_LOW)
        
        // Attempt write to RO Register
        regmodel.uart_status.write(status, ~rdata, .parent(this));
        
        // Read again to verify it has NOT changed
        begin
            bit [31:0] next_rdata;
            regmodel.uart_status.read(status, next_rdata, .parent(this));
            check_reg("uart_status RO test", next_rdata, rdata);
        end

        `uvm_info("RAL_SEQ", "========== RAL Verification Sequence Finished ==========", UVM_LOW)
    endtask
endclass
