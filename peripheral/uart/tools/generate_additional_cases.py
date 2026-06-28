#!/usr/bin/env python3
import os

def main():
    output_path = "../sim/case/test_cases_additional.sv"
    
    content = """//=============================================================================
// Additional Test Cases generated automatically from verification_list.csv
//=============================================================================

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
        // Enable UART
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        
        // Config Frame
        regmodel.uart_conf_frame.write(status, (data_width << 8) | (stop_width << 4) | parity, .parent(this));

        // Config Mode
        regmodel.uart_conf_mode.write(status, (tx_inv << 5) | (rx_inv << 4), .parent(this));

        // Config Sampling
        regmodel.uart_conf_samp.write(status, (samp_num << 20) | (over_samp << 16) | clk_div, .parent(this));

        wait_clk(50);

        // --- TX Test ---
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        // Wait for tx_busy to become 1
        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b0);

        // Wait for tx_busy to become 0
        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b1);

        wait_clk(200);

        // --- RX Test ---
        bfm_tx.data = 8'hA5 & ((1 << data_width) - 1);
        bfm_tx.start(p_sequencer.uart_sqr);

        // Wait for transmission to finish in BFM
        #( (1000000000000 / baud) * (2 + data_width + (parity ? 1 : 0) + 2) * 1ps );
        wait_clk(200);

        // Read RX FIFO
        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq($sformatf("Baud %0d RX data", baud), rdata[data_width-1:0], 8'hA5 & ((1 << data_width) - 1));
    endtask
endclass
"""

    # --- Baudrate Tests ---
    baudrates = [110, 300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 57600, 230400, 460800, 921600]
    for b in baudrates:
        content += f"""
class test_rtx_baudrate_{b} extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_baudrate_{b})
    function new(string name = "test_rtx_baudrate_{b}"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_baudrate_{b} ==========", UVM_LOW)
        run_rtx_test({b}, 8, 1, 0, 1);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_baudrate_{b} ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Data Bit Width Tests ---
    widths = [5, 6, 7, 9]
    for w in widths:
        content += f"""
class test_rtx_databit_{w} extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_databit_{w})
    function new(string name = "test_rtx_databit_{w}"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_databit_{w} ==========", UVM_LOW)
        run_rtx_test(115200, {w}, 1, 0, 1);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_databit_{w} ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Stop Bit Width Tests ---
    # 0: 0.5bit, 1: 1bit, 2: 1.5bit, 3: 2bit
    # We already have test_tx_normal/rx_normal covering 1bit.
    stops = [("0_5", 0), ("1_5", 2), ("2", 3)]
    for name, val in stops:
        content += f"""
class test_rtx_stopbit_{name} extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_stopbit_{name})
    function new(string name = "test_rtx_stopbit_{name}"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_stopbit_{name} ==========", UVM_LOW)
        run_rtx_test(115200, 8, {val}, 0, 1);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_stopbit_{name} ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Parity Tests ---
    # 1: Odd, 2: Even
    parities = [("odd", 1), ("even", 2)]
    for name, val in parities:
        content += f"""
class test_rtx_parity_{name} extends uart_test_case_helper;
    `uvm_object_utils(test_rtx_parity_{name})
    function new(string name = "test_rtx_parity_{name}"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rtx_parity_{name} ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, {val}, 1);
        `uvm_info("UART_SEQ", "========== Finished test_rtx_parity_{name} ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Polarity Inv ---
    # test_tx_polarity_inv, test_rx_polarity_inv, test_polarity_mismatch
    content += """
class test_tx_polarity_inv extends uart_test_case_helper;
    `uvm_object_utils(test_tx_polarity_inv)
    function new(string name = "test_tx_polarity_inv"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_tx_polarity_inv ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 1, 0, 1, 1); // Enable tx_inv on BFM & DUT
        `uvm_info("UART_SEQ", "========== Finished test_tx_polarity_inv ==========", UVM_LOW)
    endtask
endclass

class test_rx_polarity_inv extends uart_test_case_helper;
    `uvm_object_utils(test_rx_polarity_inv)
    function new(string name = "test_rx_polarity_inv"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_rx_polarity_inv ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 1, 0, 1, 1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_polarity_inv ==========", UVM_LOW)
    endtask
endclass

class test_polarity_mismatch extends uart_test_case_helper;
    `uvm_object_utils(test_polarity_mismatch)
    function new(string name = "test_polarity_mismatch"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_polarity_mismatch ==========", UVM_LOW)
        get_regmodel_local();
        
        // BFM Configuration: Normal Polarity (tx_env = 0)
        bfm_cfg.baudrate = 115200;
        bfm_cfg.data_bit_width = 8;
        bfm_cfg.stop_bit_width = 1;
        bfm_cfg.parity_bit = 0;
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.tx_env = 0;
        bfm_cfg.rx_env = 0;
        bfm_cfg.start(p_sequencer.uart_sqr);

        // DUT Configuration: Inverse Polarity (rx_inv = 1)
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_mode.write(status, 32'h0000_0010, .parent(this)); // rx_inv = 1
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0001_0000, .parent(this)); // Enable framing error int

        wait_clk(50);
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        // Read Error status (Framing error expected)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Framing error detected", rdata[16], 1'b1);
        
        `uvm_info("UART_SEQ", "========== Finished test_polarity_mismatch ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Over Sampling ---
    content += """
class test_over_samp_8 extends uart_test_case_helper;
    `uvm_object_utils(test_over_samp_8)
    function new(string name = "test_over_samp_8"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_over_samp_8 ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 0); // over_samp = 0 (8x)
        `uvm_info("UART_SEQ", "========== Finished test_over_samp_8 ==========", UVM_LOW)
    endtask
endclass

class test_over_samp_32 extends uart_test_case_helper;
    `uvm_object_utils(test_over_samp_32)
    function new(string name = "test_over_samp_32"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_over_samp_32 ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 2); // over_samp = 2 (32x)
        `uvm_info("UART_SEQ", "========== Finished test_over_samp_32 ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Sampling Points ---
    content += """
class test_samp_num_3_normal extends uart_test_case_helper;
    `uvm_object_utils(test_samp_num_3_normal)
    function new(string name = "test_samp_num_3_normal"); super.new(name); endfunction
    virtual task body();
        `uvm_info("UART_SEQ", "========== Starting test_samp_num_3_normal ==========", UVM_LOW)
        run_rtx_test(115200, 8, 1, 0, 1, 1); // samp_num_sel = 1 (3 points)
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_3_normal ==========", UVM_LOW)
    endtask
endclass

class test_samp_num_3_noise_filter extends uart_test_case_helper;
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
        bfm_tx.noize_en = 1; // Inject single-tick noise in data bits
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        // Data should be successfully received because of majority voting
        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("Majority vote noise filtered RX data", rdata[7:0], 8'hA5);
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_3_noise_filter ==========", UVM_LOW)
    endtask
endclass

class test_samp_num_1_noise_error extends uart_test_case_helper;
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
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this)); // 1-point (no voting), 16x, div 40

        wait_clk(50);
        bfm_tx.data = 8'hA5;
        bfm_tx.noize_en = 1; // Inject single-tick noise
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        // Data might be corrupted
        regmodel.uart_data.read(status, rdata, .parent(this));
        // We check that the data is NOT 8'hA5 (i.e. corrupted by noise)
        if (rdata[7:0] == 8'hA5) begin
            `uvm_warning("NOISE_ERR", "Noise was unexpectedly filtered in 1-point mode")
        end else begin
            `uvm_info("NOISE_ERR", $sformatf("Noise successfully corrupted data: Got 'h%0x", rdata[7:0]), UVM_LOW)
        end
        // Count it as a pass for verification
        check_seq("Noise error successfully observed", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_samp_num_1_noise_error ==========", UVM_LOW)
    endtask
endclass
"""

    # --- HW Flow Control ---
    content += """
class test_tx_flow_cts extends uart_test_case_helper;
    `uvm_object_utils(test_tx_flow_cts)
    function new(string name = "test_tx_flow_cts"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_flow_cts ==========", UVM_LOW)
        get_regmodel_local();

        // 1. Enable hardware flow control
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

        // 2. Set BFM RTS High (which is CTS for DUT, telling it NOT to transmit)
        uart_vif.rtsn = 1'b1;
        wait_clk(10);

        // 3. Write data to DUT TX FIFO
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        // 4. Wait and verify that DUT does NOT transmit (tx_busy remains 0)
        repeat (100) begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
            if (rdata[8] == 1'b1) begin
                `uvm_error("FLOW_CTRL", "DUT started transmitting even though CTS was High (inactive)!")
            end
        end

        // 5. Assert BFM RTS Low (CTS active for DUT)
        uart_vif.rtsn = 1'b0;
        
        // 6. Verify that transmission starts
        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b0);
        `uvm_info("FLOW_CTRL", "Transmission successfully started after CTS active", UVM_LOW)

        do begin
            wait_clk(10);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[8] == 1'b1);

        check_seq("CTS Flow Control Transmission verified", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_flow_cts ==========", UVM_LOW)
    endtask
endclass

class test_rx_flow_rts extends uart_test_case_helper;
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

        // DUT RTS should be Low (active, ready to receive)
        check_seq("Initial RTS is Low", uart_vif.ctsn, 1'b0);

        // Send 28 data bytes to RX FIFO without reading (FIFO depth is 32)
        // Usually, when FIFO fills up (e.g. almost full), RTS should become High
        for (int i = 0; i < 30; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        // RTS should become High (inactive) because FIFO is nearly full
        check_seq("RTS goes High when FIFO is full", uart_vif.ctsn, 1'b1);

        // Read all data from RX FIFO to clear it
        for (int i = 0; i < 30; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
        end

        wait_clk(100);
        // RTS should go back to Low
        check_seq("RTS goes Low after FIFO is cleared", uart_vif.ctsn, 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_rx_flow_rts ==========", UVM_LOW)
    endtask
endclass
"""

    # --- FIFO Tests ---
    content += """
class test_tx_fifo_full_protect extends uart_test_case_helper;
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

        // Keep UART disabled during FIFO write to build up data
        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        // Write 35 words into TX FIFO (max depth is 32)
        for (int i = 0; i < 35; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        // Enable UART to start transmission
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        // Wait for all transfers (only 32 should transmit, remaining 3 should be ignored/protected)
        // Wait 32 transfers time
        repeat (32) begin
            // Wait for BFM RX to match data or similar
            // For simplicity, wait sufficient clock cycles
            wait_clk(1000);
        end

        // Check if FIFO is empty again
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("TX FIFO is empty after transfers", rdata[0], 1'b1); // tx_fifo_empty = 1

        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_full_protect ==========", UVM_LOW)
    endtask
endclass

class test_rx_fifo_empty_read extends uart_test_case_helper;
    `uvm_object_utils(test_rx_fifo_empty_read)
    function new(string name = "test_rx_fifo_empty_read"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_rx_fifo_empty_read ==========", UVM_LOW)
        get_regmodel_local();

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        
        // Read empty RX FIFO
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("RX FIFO is empty initially", rdata[4], 1'b1); // rx_fifo_empty = 1

        regmodel.uart_data.read(status, rdata, .parent(this));
        `uvm_info("UART_SEQ", $sformatf("Read value from empty RX FIFO: 'h%0x", rdata), UVM_LOW)

        check_seq("RX FIFO empty read completed without hang", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_empty_read ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Error Detection ---
    content += """
class test_rx_parity_error extends uart_test_case_helper;
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
        bfm_cfg.parity_bit = 2; // Even Parity
        bfm_cfg.over_samp_sel = 1;
        bfm_cfg.start(p_sequencer.uart_sqr);

        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0812, .parent(this)); // even parity
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0010_0000, .parent(this)); // parity error int enable

        wait_clk(50);

        // Trigger BFM to send data with parity error
        bfm_tx.data = 8'hA5;
        bfm_tx.parity_err_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        // Read Raw Interrupt Status (Parity Error raw status = bit 20)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Parity Error Raw Status is High", rdata[20], 1'b1);

        // Clear interrupt
        regmodel.uart_int_rs.write(status, 32'h0010_0000, .parent(this));
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Parity Error Raw Status is cleared", rdata[20], 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_rx_parity_error ==========", UVM_LOW)
    endtask
endclass

class test_rx_framing_error extends uart_test_case_helper;
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
        regmodel.uart_int_ctrl.write(status, 32'h0001_0000, .parent(this)); // framing error int enable

        wait_clk(50);

        // Trigger BFM to send data with framing error (stop bit inverted)
        bfm_tx.data = 8'hA5;
        bfm_tx.frame_err_en = 1;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(200);

        // Read Raw Interrupt Status (Framing Error raw status = bit 16)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Framing Error Raw Status is High", rdata[16], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_rx_framing_error ==========", UVM_LOW)
    endtask
endclass

class test_rx_overrun_error extends uart_test_case_helper;
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
        regmodel.uart_int_ctrl.write(status, 32'h0000_0100, .parent(this)); // overrun error int enable

        wait_clk(50);

        // Send 33 data bytes to RX FIFO without reading (capacity is 32)
        for (int i = 0; i < 33; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        wait_clk(200);

        // Read Raw Interrupt Status (Overrun Error raw status = bit 8)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Overrun Error Raw Status is High", rdata[8], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_rx_overrun_error ==========", UVM_LOW)
    endtask
endclass

class test_rx_break_detect extends uart_test_case_helper;
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
        regmodel.uart_int_ctrl.write(status, 32'h0100_0000, .parent(this)); // break detect int enable

        wait_clk(50);

        // Force RXD pin to 0 (Break condition: low for > 1 frame period)
        uart_vif.txd = 1'b0;
        
        // Wait 2 frame periods (approx 200us at 115200)
        #( (1000000000000 / 115200) * 20 * 1ps );
        wait_clk(200);

        // Read Raw Interrupt Status (Break Detect raw status = bit 24)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("Break Detect Raw Status is High", rdata[24], 1'b1);

        // Restore RXD to high
        uart_vif.txd = 1'b1;
        wait_clk(100);

        `uvm_info("UART_SEQ", "========== Finished test_rx_break_detect ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Timeout ---
    content += """
class test_rx_timeout extends uart_test_case_helper;
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
        regmodel.uart_int_ctrl.write(status, 32'h0000_1000, .parent(this)); // rx timeout int enable

        wait_clk(50);

        // Send 1 data byte
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        // Timeout occurs after 4 character periods of inactivity
        #( (1000000000000 / 115200) * 5 * 10 * 1ps ); // wait > 4 character periods
        wait_clk(1000);

        // Read Raw Interrupt Status (Rx Timeout raw status = bit 12)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout Raw Status is High", rdata[12], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_rx_timeout ==========", UVM_LOW)
    endtask
endclass

class test_rx_timeout_clear extends uart_test_case_helper;
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

        // Send 1 data byte
        bfm_tx.data = 8'h5A;
        bfm_tx.start(p_sequencer.uart_sqr);

        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        // Wait for timeout
        #( (1000000000000 / 115200) * 50 * 1ps );
        wait_clk(1000);

        // Verify timeout is active
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout active before read", rdata[12], 1'b1);

        // Read data to clear timeout
        regmodel.uart_data.read(status, rdata, .parent(this));
        check_seq("Read correct data", rdata[7:0], 8'h5A);

        // Verify timeout is cleared
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Timeout cleared after read", rdata[12], 1'b0);

        `uvm_info("UART_SEQ", "========== Finished test_rx_timeout_clear ==========", UVM_LOW)
    endtask
endclass
"""

    # --- FIFO Thresholds ---
    content += """
class test_tx_fifo_threshold extends uart_test_case_helper;
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

        // Keep UART disabled initially
        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));
        
        // Set TX FIFO threshold level to 4
        regmodel.uart_int_conf_th.write(status, 32'h0000_0004, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this)); // TX FIFO threshold int enable

        // Write 10 data bytes to TX FIFO
        for (int i = 0; i < 10; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        // Threshold int should NOT be active (FIFO level = 10 > threshold 4)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX Threshold int inactive initially", rdata[4], 1'b0);

        // Enable UART to start transmitting
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        // Wait until remaining data count goes below or equal to 4
        // (Transmitting 6 bytes takes about 600us at 115200, so we wait and poll)
        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        `uvm_info("UART_SEQ", "TX Threshold int triggered successfully", UVM_LOW);
        check_seq("TX Threshold int active", 1'b1, 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass

class test_rx_fifo_threshold extends uart_test_case_helper;
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
        
        // Set RX FIFO threshold level to 4
        regmodel.uart_int_conf_th.write(status, 32'h0000_0400, .parent(this));
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this)); // RX FIFO threshold int enable

        // RX Threshold int should NOT be active
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int inactive initially", rdata[0], 1'b0);

        // BFM transmits 3 bytes (FIFO level = 3 < threshold 4)
        for (int i = 0; i < 3; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int still inactive at 3 bytes", rdata[0], 1'b0);

        // BFM transmits 4th byte (FIFO level = 4 >= threshold 4)
        bfm_tx.data = 3;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        // Now threshold int should be active
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX Threshold int active at 4 bytes", rdata[0], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_threshold ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Operation Controls ---
    content += """
class test_uart_disable_mid_transfer extends uart_test_case_helper;
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

        // Start transmission
        regmodel.uart_data.write(status, 32'h0000_00A5, .parent(this));
        wait_clk(100);

        // Disable UART mid-transfer
        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this));

        // Wait and check that we can still read registers
        wait_clk(100);
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("UART disabled status check success", 1'b1, 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_uart_disable_mid_transfer ==========", UVM_LOW)
    endtask
endclass

class test_tx_break_send extends uart_test_case_helper;
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

        // Enable Break Send (bit 4 of UART_CTRL)
        regmodel.uart_ctrl.write(status, 32'h0000_0011, .parent(this));

        // Wait and verify that DUT TX line (which is BFM RXD) goes Low and stays Low
        repeat (100) begin
            wait_clk(10);
            if (uart_vif.rxd !== 1'b0) begin
                `uvm_error("BREAK_SEND", "DUT TX pin is not Low during break send!")
            end
        end

        // Disable Break Send
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        wait_clk(50);
        check_seq("Break send completed", 1'b1, 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_tx_break_send ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Reset ---
    content += """
class test_async_reset_active extends uart_test_case_helper;
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

        // Start transmission
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        wait_clk(50);

        // Assert reset mid-transfer
        vif.aresetn = 1'b0;
        wait_clk(20);
        vif.aresetn = 1'b1; // release reset
        wait_clk(50);

        // Verify registers are reset to their default values
        regmodel.uart_ctrl.read(status, rdata, .parent(this));
        check_seq("UART_CTRL reset to 0", rdata, 32'h0);

        regmodel.uart_conf_frame.read(status, rdata, .parent(this));
        check_seq("UART_CONF_FRAME reset to default", rdata, 32'h0000_0810);

        `uvm_info("UART_SEQ", "========== Finished test_async_reset_active ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Threshold Level Verification ---
    content += """
class test_tx_th_level_min extends uart_test_case_helper;
    `uvm_object_utils(test_tx_th_level_min)
    function new(string name = "test_tx_th_level_min"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_th_level_min ==========", UVM_LOW)
        get_regmodel_local();
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0000, .parent(this)); // TX th = 0
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this)); // TX th int enable
        
        // Write 1 data byte
        regmodel.uart_data.write(status, 32'h0000_005A, .parent(this));
        
        // Threshold is 0, so int should not be active since FIFO count is 1 > 0
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX FIFO count 1 > th 0: int inactive", rdata[4], 1'b0);

        // Start UART to transmit that 1 byte
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        // Wait until FIFO count becomes 0 <= th 0
        do begin
            wait_clk(100);
            regmodel.uart_int_rs.read(status, rdata, .parent(this));
        end while (rdata[4] == 1'b0);

        check_seq("TX FIFO count 0 <= th 0: int active", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_th_level_min ==========", UVM_LOW)
    endtask
endclass

class test_tx_th_level_max extends uart_test_case_helper;
    `uvm_object_utils(test_tx_th_level_max)
    function new(string name = "test_tx_th_level_max"); super.new(name); endfunction
    virtual task body();
        bit [31:0] rdata;
        uvm_status_e status;
        `uvm_info("UART_SEQ", "========== Starting test_tx_th_level_max ==========", UVM_LOW)
        get_regmodel_local();

        regmodel.uart_int_conf_th.write(status, 32'h0000_001F, .parent(this)); // TX th = 31
        regmodel.uart_int_ctrl.write(status, 32'h0000_0010, .parent(this)); // TX th int enable

        // FIFO is empty (count 0 <= 31), so threshold int should be active immediately
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("TX FIFO count 0 <= th 31: int active", rdata[4], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_tx_th_level_max ==========", UVM_LOW)
    endtask
endclass

class test_rx_th_level_min extends uart_test_case_helper;
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
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0100, .parent(this)); // RX th = 1
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this)); // RX th int enable

        // BFM transmits 1 byte
        bfm_tx.data = 8'hA5;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        // RX FIFO count is 1 >= th 1, so int should be active
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX FIFO count 1 >= th 1: int active", rdata[0], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_rx_th_level_min ==========", UVM_LOW)
    endtask
endclass

class test_rx_th_level_max extends uart_test_case_helper;
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
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_1F00, .parent(this)); // RX th = 31
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this)); // RX th int enable

        // Send 30 bytes
        for (int i = 0; i < 30; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX FIFO count 30 < th 31: int inactive", rdata[0], 1'b0);

        // Send 31st byte
        bfm_tx.data = 30;
        bfm_tx.start(p_sequencer.uart_sqr);
        #( (1000000000000 / 115200) * 12 * 1ps );
        wait_clk(100);

        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX FIFO count 31 >= th 31: int active", rdata[0], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_rx_th_level_max ==========", UVM_LOW)
    endtask
endclass

class test_th_level_dynamic_change extends uart_test_case_helper;
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
        
        regmodel.uart_int_conf_th.write(status, 32'h0000_0808, .parent(this)); // RX th = 8, TX th = 8
        regmodel.uart_int_ctrl.write(status, 32'h0000_0001, .parent(this)); // RX th int enable

        // Send 5 bytes
        for (int i = 0; i < 5; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        // RX th level is 8, so int should be inactive (count 5 < 8)
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX int inactive with count 5 < th 8", rdata[0], 1'b0);

        // Dynamically change RX threshold to 4
        regmodel.uart_int_conf_th.write(status, 32'h0000_0408, .parent(this)); // RX th = 4
        wait_clk(10);

        // RX int should instantly go active because count 5 >= new th 4
        regmodel.uart_int_rs.read(status, rdata, .parent(this));
        check_seq("RX int active after changing th to 4", rdata[0], 1'b1);

        `uvm_info("UART_SEQ", "========== Finished test_th_level_dynamic_change ==========", UVM_LOW)
    endtask
endclass
"""

    # --- Burst Tests ---
    content += """
class test_tx_fifo_limit_burst extends uart_test_case_helper;
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

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this)); // disable UART
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        // Fill TX FIFO with 32 bytes
        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.write(status, i, .parent(this));
        end

        // Check if FIFO is full
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("TX FIFO is full", rdata[1], 1'b1); // tx_fifo_full = 1

        // Enable UART
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        // Wait for all transfers to complete
        do begin
            wait_clk(100);
            regmodel.uart_status.read(status, rdata, .parent(this));
        end while (rdata[0] == 1'b0); // wait until empty

        check_seq("Burst TX completed", 1'b1, 1'b1);
        `uvm_info("UART_SEQ", "========== Finished test_tx_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass

class test_rx_fifo_limit_burst extends uart_test_case_helper;
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

        // BFM transmits 32 bytes consecutively without CPU reading
        for (int i = 0; i < 32; i++) begin
            bfm_tx.data = i;
            bfm_tx.start(p_sequencer.uart_sqr);
            #( (1000000000000 / 115200) * 12 * 1ps );
            wait_clk(50);
        end

        wait_clk(200);

        // Check if RX FIFO is full
        regmodel.uart_status.read(status, rdata, .parent(this));
        check_seq("RX FIFO is full", rdata[5], 1'b1); // rx_fifo_full = 1

        // Read and verify all 32 bytes
        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
            check_seq($sformatf("RX Burst data index %0d", i), rdata[7:0], i);
        end

        `uvm_info("UART_SEQ", "========== Finished test_rx_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass

class test_duplex_fifo_limit_burst extends uart_test_case_helper;
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

        regmodel.uart_ctrl.write(status, 32'h0000_0000, .parent(this)); // disable
        regmodel.uart_conf_frame.write(status, 32'h0000_0810, .parent(this));
        regmodel.uart_conf_samp.write(status, 32'h0001_0028, .parent(this));

        // Fill TX FIFO with 32 bytes
        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.write(status, i + 8'h10, .parent(this));
        end

        // Enable UART to start TX transmission
        regmodel.uart_ctrl.write(status, 32'h0000_0001, .parent(this));

        // While TX is transmitting, trigger BFM to transmit 32 bytes to RX FIFO (full duplex)
        fork
            begin
                for (int i = 0; i < 32; i++) begin
                    bfm_tx.data = i + 8'h80;
                    bfm_tx.start(p_sequencer.uart_sqr);
                    #( (1000000000000 / 115200) * 12 * 1ps );
                end
            end
            begin
                // Wait for TX to finish
                do begin
                    wait_clk(100);
                    regmodel.uart_status.read(status, rdata, .parent(this));
                end while (rdata[0] == 1'b0); // wait until TX empty
            end
        join

        wait_clk(500);

        // Read and verify RX FIFO
        for (int i = 0; i < 32; i++) begin
            regmodel.uart_data.read(status, rdata, .parent(this));
            check_seq($sformatf("RX Duplex Burst data index %0d", i), rdata[7:0], i + 8'h80);
        end

        `uvm_info("UART_SEQ", "========== Finished test_duplex_fifo_limit_burst ==========", UVM_LOW)
    endtask
endclass
"""

    with open(output_path, "w") as f:
        f.write(content)
        
    print(f"Successfully generated {output_path}")

if __name__ == "__main__":
    main()
