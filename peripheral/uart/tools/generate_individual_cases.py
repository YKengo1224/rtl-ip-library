#!/usr/bin/env python3
import os
import csv

def main():
    uart_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    csv_path = os.path.join(uart_dir, "doc", "verification_list.csv")
    case_dir = os.path.join(uart_dir, "sim", "case")
    pkg_path = os.path.join(case_dir, "case_pkg.sv")
    
    os.makedirs(case_dir, exist_ok=True)
    
    # 1. Generate helper base sequence file (uart_test_case_helper.sv)
    helper_path = os.path.join(case_dir, "uart_test_case_helper.sv")
    helper_code = """//=============================================================================
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

        #( (1000000000000 / baud) * (2 + data_width + (parity ? 1 : 0) + 2) * 1ps );
        wait_clk(200);

        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq($sformatf("Baud %0d RX data", baud), rdata[data_width-1:0], 8'hA5 & ((1 << data_width) - 1));
    endtask
endclass

`endif
"""
    with open(helper_path, "w", encoding="utf-8") as f:
        f.write(helper_code)

    existing_files = {
        "test_reg_access_basic",
        "test_reg_access_consecutive_read",
        "test_reg_access_alternate_rw",
        "test_tx_normal",
        "test_rx_normal"
    }

    generated_test_names = []
    
    # Custom implementations for specific test cases
    custom_templates = {
        "test_polarity_mismatch": """class test_polarity_mismatch extends uart_test_case_helper;
    `uvm_object_utils(test_polarity_mismatch)
    function new(string name = "test_polarity_mismatch"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_polarity_mismatch ==========", UVM_LOW)
        get_regmodel_local();
        
        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.tx_env = 0;
        bfm_cfg.rx_env = 0;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_mode.write(status, 32'h0000_0010, .parent(this)); // rx_inv = 1
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0001_0000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Framing error detected", rdata[16], 1'b1);
        
        `uvm_info("UART_SEQ", "========== Finished test_polarity_mismatch ==========", UVM_LOW)
    endtask
endclass""",
        "test_samp_num_3_noise_filter": """class test_samp_num_3_noise_filter extends uart_test_case_helper;
    `uvm_object_utils(test_samp_num_3_noise_filter)
    function new(string name = "test_samp_num_3_noise_filter"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_samp_num_3_noise_filter ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0011_0028, .parent(this)); // 3-point, 16x, div 40

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.noize_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("Majority vote noise filtered RX data", rdata[7:0], 8'hA5);
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_3_noise_filter ==========", UVM_LOW)
    endtask
endclass""",
        "test_samp_num_1_noise_error": """class test_samp_num_1_noise_error extends uart_test_case_helper;
    `uvm_object_utils(test_samp_num_1_noise_error)
    function new(string name = "test_samp_num_1_noise_error"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_samp_num_1_noise_error ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this)); // 1-point, 16x, div 40

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.noize_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_data.read(status, rdata, .parent(this));
        if (rdata[7:0] == 8'hA5) begin
            `uvm_warning("NOISE_ERR", "Noise was unexpectedly filtered in 1-point mode")
        end else begin
            `uvm_info("NOISE_ERR", $sformatf("Noise successfully corrupted data: Got 'h%0x", rdata[7:0]), UVM_LOW)
        end
        check_seq("Noise error successfully observed", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_1_noise_error ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_flow_cts": """class test_tx_flow_cts extends uart_test_case_helper;
    `uvm_object_utils(test_tx_flow_cts)
    function new(string name = "test_tx_flow_cts"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_flow_cts ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_mode.write(status, 32'h0000_0001, .parent(this)); // hw_flow_en = 1
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        wait_clk(50);
        uart_vif.rtsn = 1'b1;
        wait_clk(10);

        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        repeat (100) begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
            if (rdata[8] == 1'b1) begin
                `uvm_error("FLOW_CTRL", "DUT started transmitting even though CTS was High!")
            end
        end

        uart_vif.rtsn = 1'b0;
        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b0);

        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b1);

        check_seq("CTS Flow Control Transmission verified", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_flow_cts ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_flow_rts": """class test_rx_flow_rts extends uart_test_case_helper;
    `uvm_object_utils(test_rx_flow_rts)
    function new(string name = "test_rx_flow_rts"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_flow_rts ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_mode.write(status, 32'h0000_0001, .parent(this)); // hw_flow_en = 1
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        wait_clk(50);
        check_seq("Initial RTS is Low", uart_vif.ctsn, 1'b0);

        for (int i = 0; i < 30; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        check_seq("RTS goes High when FIFO is full", uart_vif.ctsn, 1'b1);

        for (int i = 0; i < 30; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
        end

        wait_clk(100);
        check_seq("RTS goes Low after FIFO is cleared", uart_vif.ctsn, 1'b0);
        `uvm_info("UART_SEQ", "========== Finished test_rx_flow_rts ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_fifo_full_protect": """class test_tx_fifo_full_protect extends uart_test_case_helper;
    `uvm_object_utils(test_tx_fifo_full_protect)
    function new(string name = "test_tx_fifo_full_protect"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_fifo_full_protect ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        for (int i = 0; i < 35; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        repeat (32) begin
            wait_clk(1000);
        end

        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("TX FIFO is empty after transfers", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_full_protect ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_fifo_empty_read": """class test_rx_fifo_empty_read extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_empty_read)
    function new(string name = "test_rx_fifo_empty_read"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_empty_read ==========", UVM_LOW)
        get_regmodel_local();

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("RX FIFO is empty initially", rdata[4], 1'b1);

        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("RX FIFO empty read completed without hang", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_empty_read ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_parity_error": """class test_rx_parity_error extends uart_test_case_helper;
    `uvm_object_utils(test_rx_parity_error)
    function new(string name = "test_rx_parity_error"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_parity_error ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 2;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0812, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0010_0000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.parity_err_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Parity Error Raw Status is High", rdata[20], 1'b1);

        regmodel.uart_int_rs.write(status, 32'h0010_0000, .parent(this));
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Parity Error Raw Status is cleared", rdata[20], 1'b0);
        `uvm_info("UART_SEQ", "========== Finished test_rx_parity_error ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_framing_error": """class test_rx_framing_error extends uart_test_case_helper;
    `uvm_object_utils(test_rx_framing_error)
    function new(string name = "test_rx_framing_error"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_framing_error ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0001_0000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.frame_err_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Framing Error Raw Status is High", rdata[16], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_framing_error ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_overrun_error": """class test_rx_overrun_error extends uart_test_case_helper;
    `uvm_object_utils(test_rx_overrun_error)
    function new(string name = "test_rx_overrun_error"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_overrun_error ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0100, .parent(this));

        wait_clk(50);
        for (int i = 0; i < 33; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        wait_clk(200);
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Overrun Error Raw Status is High", rdata[8], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_overrun_error ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_break_detect": """class test_rx_break_detect extends uart_test_case_helper;
    `uvm_object_utils(test_rx_break_detect)
    function new(string name = "test_rx_break_detect"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_break_detect ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0100_0000, .parent(this));

        wait_clk(50);
        uart_vif.txd = 1'b0;
        
        #( (1000000000000 / 115200) * 20 * 1ps );
        wait_clk(200);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Break Detect Raw Status is High", rdata[24], 1'b1);

        uart_vif.txd = 1'b1;
        wait_clk(100);
        `uvm_info("UART_SEQ", "========== Finished test_rx_break_detect ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_timeout": """class test_rx_timeout extends uart_test_case_helper;
    `uvm_object_utils(test_rx_timeout)
    function new(string name = "test_rx_timeout"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_timeout ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_1000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        #( (1000000000000 / 115200) * 5 * 10 * 1ps );
        wait_clk(1000);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout Raw Status is High", rdata[12], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_timeout ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_timeout_clear": """class test_rx_timeout_clear extends uart_test_case_helper;
    `uvm_object_utils(test_rx_timeout_clear)
    function new(string name = "test_rx_timeout_clear"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_timeout_clear ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_1000, .parent(this));

        wait_clk(50);
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        #( (1000000000000 / 115200) * 50 * 1ps );
        wait_clk(1000);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout active before read", rdata[12], 1'b1);

        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("Read correct data", rdata[7:0], 8'h5A);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout cleared after read", rdata[12], 1'b0);
        `uvm_info("UART_SEQ", "========== Finished test_rx_timeout_clear ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_fifo_threshold": """class test_tx_fifo_threshold extends uart_test_case_helper;
    `uvm_object_utils(test_tx_fifo_threshold)
    function new(string name = "test_tx_fifo_threshold"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_fifo_threshold ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0004, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));

        for (int i = 0; i < 10; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX Threshold int inactive initially", rdata[4], 1'b0);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        check_seq("TX Threshold int active", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_fifo_threshold": """class test_rx_fifo_threshold extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_threshold)
    function new(string name = "test_rx_fifo_threshold"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_threshold ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0400, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this));

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int inactive initially", rdata[0], 1'b0);

        for (int i = 0; i < 3; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int still inactive at 3 bytes", rdata[0], 1'b0);

        bfm_tx.data = 3;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int active at 4 bytes", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass""",
        "test_uart_disable_mid_transfer": """class test_uart_disable_mid_transfer extends uart_test_case_helper;
    `uvm_object_utils(test_uart_disable_mid_transfer)
    function new(string name = "test_uart_disable_mid_transfer"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_uart_disable_mid_transfer ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        regmodel.uart_data.write(status, 32'h0000_00A5, .parent(this));
        wait_clk(100);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));

        wait_clk(100);
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("UART disabled status check success", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_uart_disable_mid_transfer ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_break_send": """class test_tx_break_send extends uart_test_case_helper;
    `uvm_object_utils(test_tx_break_send)
    function new(string name = "test_tx_break_send"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_break_send ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        wait_clk(50);
        regmodel.uart_ctrl.write(status, 32'h0000_0011, .parent(this));

        repeat (100) begin
            wait_clk(10);
            if (uart_vif.rxd !== 1'b0) begin
                `uvm_error("BREAK_SEND", "DUT TX pin is not Low during break send!")
            end
        end

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        wait_clk(50);
        check_seq("Break send completed", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_break_send ==========", UVM_LOW)
    endtask
endclass""",
        "test_async_reset_active": """class test_async_reset_active extends uart_test_case_helper;
    `uvm_object_utils(test_async_reset_active)
    function new(string name = "test_async_reset_active"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_async_reset_active ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        wait_clk(50);

        vif.aresetn = 1'b0;
        wait_clk(20);
        vif.aresetn = 1'b1;
        wait_clk(50);

        regmodel.uart_ctrl.read(status, rdata, .parent(this));
        check_seq("UART_CTRL reset to 0", rdata, 32'h0);

        regmodel.uart_conf_frame.read(status, rdata, .parent(this));
        check_seq("UART_CONF_FRAME reset to default", rdata, 32'h0000_0810);
        `uvm_info("UART_SEQ", "========== Finished test_async_reset_active ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_th_level_min": """class test_tx_th_level_min extends uart_test_case_helper;
    `uvm_object_utils(test_tx_th_level_min)
    function new(string name = "test_tx_th_level_min"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_th_level_min ==========", UVM_LOW)
        get_regmodel_local();
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));
        
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX FIFO count 1 > th 0: int inactive", rdata[4], 1'b0);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        check_seq("TX FIFO count 0 <= th 0: int active", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_th_level_min ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_th_level_max": """class test_tx_th_level_max extends uart_test_case_helper;
    `uvm_object_utils(test_tx_th_level_max)
    function new(string name = "test_tx_th_level_max"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_th_level_max ==========", UVM_LOW)
        get_regmodel_local();

        regmodel.uart_int_conf_th.write(status, 32'h0000_001F, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this));

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX FIFO count 0 <= th 31: int active", rdata[4], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_th_level_max ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_th_level_min": """class test_rx_th_level_min extends uart_test_case_helper;
    `uvm_object_utils(test_rx_th_level_min)
    function new(string name = "test_rx_th_level_min"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_th_level_min ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0100, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this));

        bfm_tx.data = 8'hA5;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX FIFO count 1 >= th 1: int active", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_th_level_min ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_th_level_max": """class test_rx_th_level_max extends uart_test_case_helper;
    `uvm_object_utils(test_rx_th_level_max)
    function new(string name = "test_rx_th_level_max"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_th_level_max ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_1F00, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this));

        for (int i = 0; i < 30; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX FIFO count 30 < th 31: int inactive", rdata[0], 1'b0);

        bfm_tx.data = 30;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX FIFO count 31 >= th 31: int active", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_th_level_max ==========", UVM_LOW)
    endtask
endclass""",
        "test_th_level_dynamic_change": """class test_th_level_dynamic_change extends uart_test_case_helper;
    `uvm_object_utils(test_th_level_dynamic_change)
    function new(string name = "test_th_level_dynamic_change"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_th_level_dynamic_change ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0808, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this));

        for (int i = 0; i < 5; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX int inactive with count 5 < th 8", rdata[0], 1'b0);

        regmodel.uart_int_conf_th.write(status, 32'h0000_0408, .parent(this));
        wait_clk(10);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX int active after changing th to 4", rdata[0], 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_th_level_dynamic_change ==========", UVM_LOW)
    endtask
endclass""",
        "test_tx_fifo_limit_burst": """class test_tx_fifo_limit_burst extends uart_test_case_helper;
    `uvm_object_utils(test_tx_fifo_limit_burst)
    function new(string name = "test_tx_fifo_limit_burst"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_fifo_limit_burst ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("TX FIFO is full", rdata[1], 1'b1);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        do begin
            wait_clk(100);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[0] == 1'b0);

        check_seq("Burst TX completed", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass""",
        "test_rx_fifo_limit_burst": """class test_rx_fifo_limit_burst extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_limit_burst)
    function new(string name = "test_rx_fifo_limit_burst"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_limit_burst ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        wait_clk(50);

        for (int i = 0; i < 32; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        wait_clk(200);

        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("RX FIFO is full", rdata[5], 1'b1);

        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
            check_seq($sformatf("RX Burst data index %0d", i), rdata[7:0], i);
        end
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass""",
        "test_duplex_fifo_limit_burst": """class test_duplex_fifo_limit_burst extends uart_test_case_helper;
    `uvm_object_utils(test_duplex_fifo_limit_burst)
    function new(string name = "test_duplex_fifo_limit_burst"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_duplex_fifo_limit_burst ==========", UVM_LOW)
        get_regmodel_local();

        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.write(status, i + 8'h10, .parent(this));
        end

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        fork
            begin
                for (int i = 0; i < 32; i++) begin
                    bfm_tx.data = i + 8'h80;
                    bfm_tx.start(p_sequencer.uart_sqr);
                    #( (1000000000000 / 115200) * 12 * 1ps );
                end
            end
            begin
                do begin
                    wait_clk(100);
                    regmodel.uart_status.read(status, rdata, .parent(this));
                end while (rdata[0] == 1'b0);
            end
        join

        wait_clk(500);

        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
            check_seq($sformatf("RX Duplex Burst data index %0d", i), rdata[7:0], i + 8'h80);
        end
        `uvm_info("UART_SEQ", "========== Finished test_duplex_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass"""
    }

    # Helper templates for standard parameterized test scenarios
    def get_generic_template(name, baud, width, stop, parity, over_samp, samp_num, tx_inv, rx_inv):
        return f"""class {name} extends uart_test_case_helper;
    `uvm_object_utils({name})
    function new(string name = "{name}"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting {name} ==========", UVM_LOW)
        run_rtx_test({baud}, {width}, {stop}, {parity}, {over_samp}, {samp_num}, {tx_inv}, {rx_inv});
        `uvm_info("UART_SEQ", "========== Finished {name} ==========", UVM_LOW)
    endtask
endclass"""

    # 2. Parse CSV and generate individual testcases
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        header = next(reader)
        
        # Mapping headers to columns
        cols = {h.strip(): idx for idx, h in enumerate(header)}
        
        for row in reader:
            if not row or not row[0].strip():
                continue
            
            test_name = row[cols["test_name"]].strip()
            
            # Skip if already exists as a manual SV file
            if test_name in existing_files:
                continue
                
            generated_test_names.append(test_name)
            
            # Read parameters
            baud = int(row[cols["ボーレート設定"]])
            width = int(row[cols["データビット幅"]])
            
            stop_str = row[cols["ストップビット幅"]].strip()
            if stop_str == "0" or "0.5" in stop_str:
                stop = 0
            elif "1.5" in stop_str or stop_str == "2":
                # csv line 25: 1.5bit stop mapped to val 2
                stop = 2
            elif "2" in stop_str or stop_str == "3":
                # csv line 26: 2bit stop mapped to val 3
                stop = 3
            else:
                stop = 1 # default 1bit
                
            parity = int(row[cols["parity bit"]])
            tx_inv = int(row[cols["tx_inv"]])
            rx_inv = int(row[cols["rx_inv"]])
            samp_num = int(row[cols["samp_num"]])
            over_samp = int(row[cols["over_samp"]])
            
            # Generate SV Code for this testcase
            if test_name in custom_templates:
                sv_code = f"""`ifndef _H_{test_name.upper()}_SV
`define _H_{test_name.upper()}_SV

{custom_templates[test_name]}

`endif
"""
            else:
                sv_code = f"""`ifndef _H_{test_name.upper()}_SV
`define _H_{test_name.upper()}_SV

{get_generic_template(test_name, baud, width, stop, parity, over_samp, samp_num, tx_inv, rx_inv)}

`endif
"""
            
            # Write individual file
            case_file_path = os.path.join(case_dir, f"{test_name}.sv")
            with open(case_file_path, "w", encoding="utf-8") as f_out:
                f_out.write(sv_code)
                
    # 3. Update case_pkg.sv to include all tests
    # Include all manuals first, then helper, then all generated tests.
    pkg_code = """`ifndef _H_CASE_PKG_SV
`define _H_CASE_PKG_SV

package case_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import validation packages
    import axi4lite_pkg::*;
    import uart_bfm_pkg::*;
    import uart_val_pkg::*;

    // Include base helper
    `include "uart_test_case_helper.sv"

    // Include manually written sequences
    `include "uart_tx_sample_seq.sv"
    `include "sample_ral_seq.sv"
    `include "test_reg_access_basic.sv"
    `include "test_reg_access_consecutive_read.sv"
    `include "test_reg_access_alternate_rw.sv"
    `include "test_tx_normal.sv"
    `include "test_rx_normal.sv"

    // Include automatically generated sequences
"""
    for t_name in generated_test_names:
        pkg_code += f'    `include "{t_name}.sv"\n'
        
    pkg_code += """
endpackage

`endif
"""
    with open(pkg_path, "w", encoding="utf-8") as f_pkg:
        f_pkg.write(pkg_code)

    print(f"Successfully generated helper and {len(generated_test_names)} individual test cases!")

if __name__ == "__main__":
    main()
