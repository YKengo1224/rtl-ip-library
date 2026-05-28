class test_master_instr_tx_fifo_empty_seq extends tb_seq_base;
    `uvm_object_utils(test_master_instr_tx_fifo_empty_seq)

    function new(string name = "test_master_instr_tx_fifo_empty_seq");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "SEQ_START", UVM_LOW)

        wait (moni_vif.aresetn);
        wait (moni_vif.srstn_sysclk);

        `uvm_info("SEQ", "################# interrupt test #################", UVM_LOW)
        run_test(1);
        `uvm_info("SEQ", "################# no interrupt test #################", UVM_LOW)
        run_test(0);
    endtask : body

    task run_test(bit instr_en);
        bit [63:0] rdata;
        //instr
        if (instr_en) begin
            write_reg(.addr(32'h0014), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0000_0001));
        end else begin
            write_reg(.addr(32'h0014), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0000_0000));
        end

        `uvm_info("SEQ", $sformatf("intr:%0d", moni_vif.qspi_instr_aclk_o_r), UVM_LOW)

        //Single
        conf(.mode(0), .protocol_sel(1), .trans_dir(0), .word_width(8), .spi_slave_en(0), .order(0),
             .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));

        for (int i = 0; i < 2; i++) begin
           `uvm_info("SEQ", $sformatf("------- loop : %0d", i), UVM_LOW)
            for (int i = 0; i < 4; i++) begin
                bfm_push_data(0, 16'hAA + i);
            end
            for (int i = 0; i < 4; i++) begin
                write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hBB + i));
            end

            fork
                begin : TIME_OUT
                    int cnt = 0;
                    while (!(cnt > 1000)) begin
                        @(posedge moni_vif.aclk);
                        cnt++;
                    end
                    `uvm_error("SEQ", "timeout!")
                    disable WAIT_INSTR;
                end
                begin : WAIT_INSTR
                    if (instr_en) begin
                        wait (moni_vif.qspi_instr_aclk_o_r);
                        `uvm_info("SEQ", "detect instr", UVM_LOW)
                    end else begin
                        do begin
                            read_reg(.addr(32'h0020), .id(0), .prot(0), .data(rdata));
                        end while (rdata[0] == 0);

                        if (moni_vif.qspi_instr_aclk_o_r) `uvm_error("SEQ", "interrupt error")
                    end
                    disable TIME_OUT;


                    read_reg(.addr(32'h0024), .id(0), .prot(0), .data(rdata));
                    `uvm_info("SEQ", $sformatf("INSTR_MS:%0h", rdata), UVM_LOW)

                    read_reg(.addr(32'h0020), .id(0), .prot(0), .data(rdata));
                    `uvm_info("SEQ", $sformatf("INSTR_RS:%0h", rdata), UVM_LOW)


                    //result clear
                    write_reg(.addr(32'h0024), .id(0), .prot(0), .wstrb(4'b1111),
                              .data(32'h0000_0001));


                    read_reg(.addr(32'h0024), .id(0), .prot(0), .data(rdata));
                    `uvm_info("SEQ", $sformatf("INSTR_MS:%0h", rdata), UVM_LOW)

                    read_reg(.addr(32'h0020), .id(0), .prot(0), .data(rdata));
                    `uvm_info("SEQ", $sformatf("INSTR_RS:%0h", rdata), UVM_LOW)
                end
            join
        end

    endtask


endclass
