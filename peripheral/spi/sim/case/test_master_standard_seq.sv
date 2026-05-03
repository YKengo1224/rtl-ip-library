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
        




        //single SPI
        `uvm_info("SEQ", "Start Single SPI Test", UVM_LOW)
        write_data = {8'h0, 2'h0, mode, 4'h0, 16'h8001};

        write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
        config_qspi(.bfm_sel(0), .is_master(0), .is_lsb(0), .pha(mode[0]), .pol(mode[1]),
                    .clock_period_ps(2500));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_005A));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_00AA));
        trans_qspi(.bfm_sel(0), .bus_width(1), .trans_dir(1), .data_len(8), .cs_end(0), .data('hBB),
                   .rdata(spi_rdata));
        `uvm_info("SEQ", $sformatf("rdata:%h", spi_rdata), UVM_LOW)
        trans_qspi(.bfm_sel(0), .bus_width(1), .trans_dir(1), .data_len(8), .cs_end(0), .data('hAA),
                   .rdata(spi_rdata));
        `uvm_info("SEQ", $sformatf("rdata:%h", spi_rdata), UVM_LOW)


        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("reg rdata:%x:", rdata), UVM_LOW)
        repeat (2) @(posedge moni_vif.aclk);
        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("reg rdata:%x:", rdata), UVM_LOW)


        //Dual SPI
        `uvm_info("SEQ", "Start Dual SPI Send Test", UVM_LOW)

        write_data = {8'h0, 2'h0, mode, 4'h0, 16'h8211};
        write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
        config_qspi(.bfm_sel(0), .is_master(0), .is_lsb(0), .pha(mode[0]), .pol(mode[1]),
                    .clock_period_ps(2500));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0011));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0012));
        trans_qspi(.bfm_sel(0), .bus_width(2), .trans_dir(1), .data_len(8), .cs_end(0), .data('h00),
                   .rdata(spi_rdata));
        `uvm_info("SEQ", $sformatf("rdata:%h", spi_rdata), UVM_LOW)
        trans_qspi(.bfm_sel(0), .bus_width(2), .trans_dir(1), .data_len(8), .cs_end(0), .data('h00),
                   .rdata(spi_rdata));
        `uvm_info("SEQ", $sformatf("rdata:%h", spi_rdata), UVM_LOW)


        `uvm_info("SEQ", "Start Dual SPI Reseive Test", UVM_LOW)

        write_data = {8'h0, 2'h0, mode, 4'h0, 16'h8201};
        write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0000));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0000));
        trans_qspi(.bfm_sel(0), .bus_width(2), .trans_dir(0), .data_len(8), .cs_end(0), .data('hCC),
                   .rdata(spi_rdata));
        trans_qspi(.bfm_sel(0), .bus_width(2), .trans_dir(0), .data_len(8), .cs_end(0), .data('hDD),
                   .rdata(spi_rdata));



        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("reg rdata:%x:", rdata), UVM_LOW)
        repeat (2) @(posedge moni_vif.aclk);
        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("reg rdata:%x:", rdata), UVM_LOW)



        //Quad SPI
        `uvm_info("SEQ", "Start Quad SPI Send Test", UVM_LOW)

        write_data = {8'h0, 2'h0, mode, 4'h0, 16'h8311};
        write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
        config_qspi(.bfm_sel(0), .is_master(0), .is_lsb(0), .pha(mode[0]), .pol(mode[1]),
                    .clock_period_ps(2500));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0013));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0014));
        trans_qspi(.bfm_sel(0), .bus_width(4), .trans_dir(1), .data_len(8), .cs_end(0), .data('h00),
                   .rdata(spi_rdata));
        `uvm_info("SEQ", $sformatf("rdata:%h", spi_rdata), UVM_LOW)
        trans_qspi(.bfm_sel(0), .bus_width(4), .trans_dir(1), .data_len(8), .cs_end(0), .data('h00),
                   .rdata(spi_rdata));
        `uvm_info("SEQ", $sformatf("rdata:%h", spi_rdata), UVM_LOW)



        `uvm_info("SEQ", "Start Dual SPI reseive Test", UVM_LOW)

        write_data = {8'h0, 2'h0, mode, 4'h0, 16'h8301};
        write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0000));
        write_reg(.addr(32'h0010), .id(0), .prot(0), .xfer_bytes(4), .data(32'h_0000_0000));
        trans_qspi(.bfm_sel(0), .bus_width(4), .trans_dir(0), .data_len(8), .cs_end(0), .data('hEE),
                   .rdata(spi_rdata));
        trans_qspi(.bfm_sel(0), .bus_width(4), .trans_dir(0), .data_len(8), .cs_end(0), .data('hFF),
                   .rdata(spi_rdata));


        repeat (2) @(posedge moni_vif.aclk);
        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("reg rdata:%x:", rdata), UVM_LOW)
        repeat (2) @(posedge moni_vif.aclk);
        read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("reg rdata:%x:", rdata), UVM_LOW)


    endtask

endclass
