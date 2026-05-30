class test_master_instr_fifo_overflow_seq extends tb_seq_base;
    `uvm_object_utils(test_master_instr_fifo_overflow_seq)

    function new(string name = "test_master_instr_fifo_overflow_seq");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task body();
        `uvm_info("SEQ", "SEQ_START", UVM_LOW)

        wait (moni_vif.aresetn);
        wait (moni_vif.srstn_sysclk);

        `uvm_info("SEQ", "################# TX FIFO Overflow Test #################", UVM_LOW)
        run_tx_overflow_test();

        `uvm_info("SEQ", "################# RX FIFO Overflow Test #################", UVM_LOW)
        run_rx_overflow_test();

        `uvm_info("SEQ", "SEQ_END", UVM_LOW)
    endtask : body

    // ---------------------------------------------------------
    // TX FIFO Overflow
    // ---------------------------------------------------------
    task run_tx_overflow_test();
        bit [63:0] rdata;

        // 1. tx_fifo_overflow 割り込み有効化 (Bit 16)
        write_reg(.addr(32'h0014), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0001_0000));

        // 2. QSPI動作を無効化 (送信が開始されないようにする)
        write_reg(.addr(32'h0000), .id(0), .prot(0), .wstrb(4'b0001), .data(0));

        // 3. FIFOサイズ(32)を超える33回書き込みを行いオーバーフローを発生させる
        for (int i = 0; i < 33; i++) begin
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hAA + i));
        end

        // 4. 割り込み発生待ち
        fork
            begin : TIME_OUT_TX
                int cnt = 0;
                while (!(cnt > 1000)) begin
                    @(posedge moni_vif.aclk);
                    cnt++;
                end
                `uvm_error("SEQ", "TX Overflow timeout!")
                disable WAIT_INSTR_TX;
            end
            begin : WAIT_INSTR_TX
                wait (moni_vif.qspi_instr_aclk_o_r);
                `uvm_info("SEQ", "TX FIFO Overflow interrupt detected", UVM_LOW)
                disable TIME_OUT_TX;

                // ステータス確認
                read_reg(.addr(32'h0024), .id(0), .prot(0), .data(rdata));
                `uvm_info("SEQ", $sformatf("INSTR_MS:%0h", rdata), UVM_LOW)

                // 5. 割り込みクリア (QSPI_INT_MS の Bit 16 に1を書き込む)
                write_reg(.addr(32'h0024), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0001_0000));
                `uvm_info("SEQ", "TX FIFO Overflow interrupt cleared", UVM_LOW)

                // --- ワークアラウンド: TX FIFO ゴリ押しクリア ---
                `uvm_info("SEQ", "Workaround: Flushing TX FIFO by enabling transmission...",
                          UVM_LOW)

                // 通信設定 (適当にダミーで送信させる)
                conf(.mode(0), .protocol_sel(1), .trans_dir(0), .word_width(8), .spi_slave_en(0),
                     .order(0), .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));

                // QSPI動作有効化 (溜まったデータを無理やり送信させる)
                write_reg(.addr(32'h0000), .id(0), .prot(0), .wstrb(4'b0001), .data(1));

                // 送信完了(busy=0)を待機
                forever begin
                    read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
                    if (!rdata[24]) break;  // rdata[24] が busy フラグの想定
                end

                // 念のため RX FIFO に溜まったゴミ（ダミー受信データ）を捨てる
                forever begin
                    read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
                    if (rdata[12]) break;  // rdata[12] が rx_empty フラグの想定
                    else read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));  // 読み捨て
                end
                `uvm_info("SEQ", "TX FIFO Flush done.", UVM_LOW)
                // ------------------------------------------------
            end
        join
    endtask

    // ---------------------------------------------------------
    // RX FIFO Overflow
    // ---------------------------------------------------------
    task run_rx_overflow_test();
        bit [63:0] rdata;

        // 1. rx_fifo_overflow 割り込み有効化 (Bit 20)
        write_reg(.addr(32'h0014), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0010_0000));

        // 2. 通信設定
        conf(.mode(0), .protocol_sel(1), .trans_dir(0), .word_width(8), .spi_slave_en(0), .order(0),
             .rx_latch_delay(0), .bfm_sel(0), .clock_period_ps(2500));

        // QSPI無効化
        write_reg(.addr(32'h0000), .id(0), .prot(0), .wstrb(4'b0001), .data(0));

        // 3. 通信を33回発生させるため、BFMとTX_FIFOに33個データをプッシュ
        for (int i = 0; i < 32; i++) begin
            bfm_push_data(0, 16'hBB + i);
            write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hCC + i));
        end

        // QSPI動作有効化 (転送開始)
        write_reg(.addr(32'h0000), .id(0), .prot(0), .wstrb(4'b0001), .data(1));

        wait_clk(10);
        bfm_push_data(0, 16'hBB);
        write_reg(.addr(32'h0010), .id(0), .prot(0), .wstrb(4'b1111), .data(32'hCC));


        // 4. 割り込み発生待ち
        fork
            begin : TIME_OUT_RX
                int cnt = 0;
                while (!(cnt > 5000)) begin  // 通信があるので少し長めに待つ
                    @(posedge moni_vif.aclk);
                    cnt++;
                end
                `uvm_error("SEQ", "RX Overflow timeout!")
                disable WAIT_INSTR_RX;
            end
            begin : WAIT_INSTR_RX
                wait (moni_vif.qspi_instr_aclk_o_r);
                `uvm_info("SEQ", "RX FIFO Overflow interrupt detected", UVM_LOW)
                disable TIME_OUT_RX;

                // ステータス確認
                read_reg(.addr(32'h0024), .id(0), .prot(0), .data(rdata));
                `uvm_info("SEQ", $sformatf("INSTR_MS:%0h", rdata), UVM_LOW)

                // 5. 割り込みクリア (QSPI_INT_MS の Bit 20 に1を書き込む)
                write_reg(.addr(32'h0024), .id(0), .prot(0), .wstrb(4'b1111), .data(32'h0010_0000));
                `uvm_info("SEQ", "RX FIFO Overflow interrupt cleared", UVM_LOW)

                // 後処理: 通信完了(busy=0)を待機
                forever begin
                    read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
                    if (!rdata[24]) break;  // busy
                end

                // --- ワークアラウンド: RX FIFO ゴリ押しクリア ---
                `uvm_info("SEQ", "Workaround: Flushing RX FIFO by dummy reads...", UVM_LOW)

                // RX_EMPTY(rdata[12]) が 1 になるまでひたすらReadして捨てる
                forever begin
                    read_reg(.addr(32'h001C), .id(0), .prot(0), .data(rdata));
                    if (rdata[12]) break;
                    else read_reg(.addr(32'h0010), .id(0), .prot(0), .data(rdata));  // 読み捨て
                end
                `uvm_info("SEQ", "RX FIFO Flush done.", UVM_LOW)
                // ------------------------------------------------
            end
        join
    endtask

endclass
