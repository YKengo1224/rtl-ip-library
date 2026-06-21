`ifndef _H_UART_SCOREBOARD_SV
`define _H_UART_SCOREBOARD_SV

import common_pkg::*;

class uart_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(uart_scoreboard)

    test_result result_obj;

    // AXI4-Lite and UART BFM TLM FIFOs
    uvm_tlm_analysis_fifo #(axi4lite_transfer) axil_fifo;
    uvm_tlm_analysis_fifo #(uart_bfm_transfer) uart_fifo;

    // Expected data queue
    protected bit [8:0] expected_tx_queue[$];

    // Status counters
    int match_count = 0;
    int mismatch_count = 0;

    function new(string name = "uart_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axil_fifo = new("axil_fifo", this);
        uart_fifo = new("uart_fifo", this);
        
        // Instantiate and set test_result to config_db
        result_obj = test_result::type_id::create("test_result");
        uvm_config_db#(test_result)::set(null, "*", "test_result", result_obj);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            monitor_axi_writes();
            compare_uart_outputs();
        join
    endtask

    // Monitor AXI4-Lite writes to UART_DATA (0x10) to generate expected data
    virtual protected task monitor_axi_writes();
        axi4lite_transfer axil_trans;
        forever begin
            axil_fifo.get(axil_trans);

            // Check write to UART_DATA (Address offset 0x10)
            if ((axil_trans.cmd == WRITE) && (axil_trans.addr[7:0] == 8'h10)) begin
                bit [8:0] tx_data = axil_trans.data[8:0];
                expected_tx_queue.push_back(tx_data);
                `uvm_info("UART_SCOREBOARD", $sformatf("Expected TX Data Pushed: 'h%0x", tx_data),
                          UVM_HIGH)
            end
        end
    endtask

    // Compare actual UART serial transmission with expected data
    virtual protected task compare_uart_outputs();
        uart_bfm_transfer uart_trans;
        bit [8:0] expected_data;

        forever begin
            uart_fifo.get(uart_trans);

            if (expected_tx_queue.size() == 0) begin
                `uvm_error("UART_SCOREBOARD", $sformatf("Unexpected UART TX packet detected: 'h%0x",
                                                        uart_trans.receive_data))
                mismatch_count++;
                if (result_obj != null) result_obj.add_seq_cmp(1, 1);
                continue;
            end

            expected_data = expected_tx_queue.pop_front();

            // Mask according to config data bit width (can be 5 to 9 bits)
            begin
                bit [8:0] mask = (1 << uart_trans.data_bit_width) - 1;
                bit [8:0] masked_exp = expected_data & mask;
                bit [8:0] masked_act = uart_trans.receive_data & mask;

                if (masked_act === masked_exp) begin
                    match_count++;
                    if (result_obj != null) result_obj.add_seq_cmp(1, 0);
                    `uvm_info("UART_SCOREBOARD",
                              $sformatf("TX Data MATCH: Act 'h%0x, Exp 'h%0x (width: %0d)",
                                        masked_act, masked_exp, uart_trans.data_bit_width), UVM_LOW)
                end else begin
                    mismatch_count++;
                    if (result_obj != null) result_obj.add_seq_cmp(1, 1);
                    `uvm_error("UART_SCOREBOARD", $sformatf(
                               "TX Data MISMATCH: Act 'h%0x, Exp 'h%0x (width: %0d)",
                               masked_act,
                               masked_exp,
                               uart_trans.data_bit_width
                               ))
                end
            end

            // Validate expected parity error if flag is set
            if (uart_trans.parity_err) begin
                `uvm_info("UART_SCOREBOARD",
                          "Verified: Expected Parity Error was injected and captured.", UVM_MEDIUM)
            end

            // Validate expected framing error if flag is set
            if (uart_trans.frame_err) begin
                `uvm_info("UART_SCOREBOARD",
                          "Verified: Expected Framing Error was injected and captured.", UVM_MEDIUM)
            end
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("UART_SCOREBOARD", $sformatf("======================================="), UVM_LOW)
        `uvm_info("UART_SCOREBOARD", $sformatf("  UART Scoreboard Verification Summary:"), UVM_LOW)
        `uvm_info("UART_SCOREBOARD", $sformatf("  Total Matches      : %0d", match_count), UVM_LOW)
        `uvm_info("UART_SCOREBOARD", $sformatf("  Total Mismatches   : %0d", mismatch_count),
                  UVM_LOW)
        `uvm_info("UART_SCOREBOARD", $sformatf("======================================="), UVM_LOW)

        // Detailed Report
        if (result_obj != null) begin
            result_obj.report();
            
            // Overall Check
            if (result_obj.reg_cmp_error == 0 && result_obj.seq_cmp_error == 0 && 
                (result_obj.reg_cmp_count > 0 || result_obj.seq_cmp_count > 0)) begin
                `uvm_info("UART_SCOREBOARD", ">>> TEST RESULT: PASS <<<", UVM_LOW)
            end else begin
                `uvm_error("UART_SCOREBOARD", ">>> TEST RESULT: FAIL <<<")
            end
        end else begin
            `uvm_error("UART_SCOREBOARD", ">>> TEST RESULT: FAIL (test_result object not initialized) <<<")
        end
    endfunction
endclass

`endif
