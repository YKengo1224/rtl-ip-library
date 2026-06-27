//=============================================================================
// Common helper base sequence for generated test cases
//=============================================================================
`ifndef _H_UART_TEST_CASE_HELPER_SV
`define _H_UART_TEST_CASE_HELPER_SV

class uart_test_case_helper extends uart_seq_base;
    `uvm_object_utils(uart_test_case_helper)

    function new(string name = "uart_test_case_helper");
        super.new(name);
    endfunction

    task get_regmodel_local();
        if (regmodel == null) begin
            if (!uvm_config_db#(uart_reg_block)::get(null, "", "regmodel", regmodel)) begin
                `uvm_fatal("UART_SEQ", "regmodel not found in config_db")
            end
        end
    endtask

    task run_rtx_test(
        int baud,
        int data_width,
        int stop_width,
        int parity,
        int over_samp,
        int samp_num = 0,
        bit tx_inv = 0,
        bit rx_inv = 0
    );
        bit [31:0] rdata;
        uvm_status_e status;
        int clk_div;
        int over_samp_ratio;

        get_regmodel_local();

        case (over_samp)
            0: over_samp_ratio = 8;
            1: over_samp_ratio = 16;
            2: over_samp_ratio = 32;
            default: over_samp_ratio = 16;
        endcase

        // clk_div = 73,750,000 / (baud * over_samp_ratio)
        clk_div = 73750000 / (baud * over_samp_ratio);

        `uvm_info("UART_SEQ", $sformatf("Configuring RTX Test: Baud=%0d, DataWidth=%0d, Stop=%0d, Parity=%0d, OverSamp=%0d, Div=%0d", 
                  baud, data_width, stop_width, parity, over_samp, clk_div), UVM_LOW)

        // BFM Configuration
        bfm_cfg.baudrate = baud;
        bfm_cfg.data_bit_width = data_width;
        bfm_cfg.stop_bit_width = stop_width;
        bfm_cfg.parity_bit = parity;
        bfm_cfg.over_samp_sel = over_samp;
        bfm_cfg.tx_env = tx_inv;
        bfm_cfg.rx_env = rx_inv;
        bfm_cfg.start(p_sequencer.uart_sqr);

        // DUT Configuration
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, (data_width << 8) | (stop_width << 4) | parity, .parent(this));
        regmodel.uart_conf_mode.write(status, (tx_inv << 5) | (rx_inv << 4), .parent(this));
        regmodel.uart_conf_samp.write(status, (samp_num << 20) | (over_samp << 16) | clk_div, .parent(this));

        wait_clk(50);

        // --- TX Test ---
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b0);

        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b1);

        wait_clk(200);

        // --- RX Test ---
        bfm_tx.data = 8'hA5 & ((1 << data_width) - 1);
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000.0 / baud) * (2 + data_width + (parity ? 1 : 0) + 2) * 1ps );
        wait_clk(200);

        begin
            bit [31:0] expected_data;
            bit [31:0] masked_rdata;
            
            regmodel.uart_data.read(status, rdata, .parent(this));
            
            expected_data = 8'hA5 & ((1 << data_width) - 1);
            masked_rdata = rdata & ((1 << data_width) - 1);
            check_seq($sformatf("Baud %0d RX data", baud), masked_rdata, expected_data);
        end
    endtask
endclass

`endif
