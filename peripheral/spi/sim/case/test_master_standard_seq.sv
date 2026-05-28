class test_master_standard_seq extends tb_seq_base;
    `uvm_object_utils(test_master_standard_seq)

    function new(string name = "test_master_standard_seq");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "SEQ_START", UVM_LOW)

        wait (moni_vif.aresetn);
        wait (moni_vif.srstn_sysclk);

        $display("===============================================");
        $display("MODE 0 TEST");
        $display("===============================================");
        std_seq(2'b00);
        $display("===============================================");
        $display("MODE 1 TEST");
        $display("===============================================");
        std_seq(2'b01);


        $display("===============================================");
        $display("MODE 2 TEST");
        $display("===============================================");
        std_seq(2'b10);

        $display("===============================================");
        $display("MODE 3 TEST");
        $display("===============================================");
        std_seq(2'b11);

    endtask

    virtual task std_seq(bit [1:0] mode);
        bit [63:0] rdata;
        bit [15:0] spi_rdata;
        bit [31:0] write_data;

        //Single
        conf(.mode(mode), .protocol_sel(1), .trans_dir(0), .word_width(8), .spi_slave_en(0),
             .order(0), .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));

        for (int i = 0; i < 4; i++) begin
            bfm_push_data(0, 16'hAA + i);
        end
        for (int i = 0; i < 4; i++) begin
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hBB + i));
        end

        for (int i = 0; i < 4; i++) begin
            do begin
                read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
            end while (!rdata[0]);
            read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        end

        // Dual

        //receive
        conf(.mode(mode), .protocol_sel(2), .trans_dir(0), .word_width(8), .spi_slave_en(0),
             .order(0), .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));

        for (int i = 0; i < 4; i++) begin
            bfm_push_data(0, 16'hCC + i);
        end
        for (int i = 0; i < 4; i++) begin
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0));
        end

        for (int i = 0; i < 4; i++) begin
            do begin
                read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
            end while (!rdata[0]);
            read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        end

        //send
        conf(.mode(mode), .protocol_sel(2), .trans_dir(1), .word_width(8), .spi_slave_en(0),
             .order(0), .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));


        for (int i = 0; i < 4; i++) begin
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hDD + i));
        end


        do begin
            read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
        end while (rdata[24]);


        //Quad

        //receive
        conf(.mode(mode), .protocol_sel(4), .trans_dir(0), .word_width(8), .spi_slave_en(0),
             .order(0), .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));

        for (int i = 0; i < 4; i++) begin
            bfm_push_data(0, 16'hCC + i);
        end
        for (int i = 0; i < 4; i++) begin
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0));
        end

        for (int i = 0; i < 4; i++) begin
            do begin
                read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
            end while (!rdata[0]);
            read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        end

        //send
        conf(.mode(mode), .protocol_sel(4), .trans_dir(1), .word_width(8), .spi_slave_en(0),
             .order(0), .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));


        for (int i = 0; i < 4; i++) begin
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hDD + i));
        end


        do begin
            read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
        end while (rdata[24]);


    endtask

endclass
