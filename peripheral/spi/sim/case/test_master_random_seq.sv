class test_master_random_seq extends tb_seq_base;
    `uvm_object_utils(test_master_random_seq)

    function new(string name = "test_master_random_seq");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task body();
        bit [63:0] rdata;
        `uvm_info("SEQ", "SEQ_START", UVM_LOW)

        wait (moni_vif.aresetn);
        wait (moni_vif.srstn_sysclk);

        $display("hoge");

        conf(.mode(0), .protocol_sel(1), .trans_dir(0), .word_width(8), .spi_slave_en(0), .order(0),
             .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));


        bfm_push_data(0, 16'h00CC);
        bfm_push_data(0, 16'h00DD);


        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h0000_005A));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h0000_00AA));


        repeat (1000) @(posedge moni_vif.sysclk);
        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));



        // $display("===============================================");
        // $display("MODE 0 TEST");
        // $display("===============================================");
        // std_seq(2'b00);

        // $display("===============================================");
        // $display("MODE 1 TEST");
        // $display("===============================================");
        // std_seq(2'b01);


        // $display("===============================================");
        // $display("MODE 2 TEST");
        // $display("===============================================");
        // std_seq(2'b10);

        // $display("===============================================");
        // $display("MODE 3 TEST");
        // $display("===============================================");
        // std_seq(2'b11);

    endtask

endclass
