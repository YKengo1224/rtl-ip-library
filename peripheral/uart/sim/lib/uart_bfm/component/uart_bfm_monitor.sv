`ifndef _H_UART_BFM_MONITOR_SV
`define _H_UART_BFM_MONITOR_SV

class uart_bfm_monitor #(
    type t_if = uart_bfm_default_interface,
    type t_trans = uart_bfm_default_transfer
) extends uvm_monitor;

    t_if            vif;
    uart_bfm_config uart_bfm_cfg;

    uvm_analysis_port #(t_trans) ap;

    `uvm_component_param_utils(uart_bfm_monitor#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
            `uvm_fatal("UART_BFM_MONI", "vif not found")
        if (!uvm_config_db#(uart_bfm_config)::get(this, "", "uart_bfm_cfg", uart_bfm_cfg))
            `uvm_fatal("UART_BFM_MONI", "uart_bfm_cfg not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            monitor_tx();
        end
    endtask

    virtual protected task monitor_tx();
        t_trans trans;
        longint period_ps;
        bit [8:0] rx_data;
        bit       start_val;
        bit       parity_val;
        bit       stop_val;

        // Wait for start bit edge.
        // BFM's RXD pin (vif.rxd) is connected to DUT's TXD pin.
        // If rx_env is enabled, signal is inverted (idle = low, start = high).
        if (uart_bfm_cfg.rx_env) begin
            @(posedge vif.rxd);
        end else begin
            @(negedge vif.rxd);
        end

        // Wait to the middle of the start bit
        period_ps = 64'd1_000_000_000_000 / uart_bfm_cfg.baudrate;
        #((period_ps / 2) * 1ps);

        // Check if start bit is still valid
        start_val = uart_bfm_cfg.rx_env ? 1'b1 : 1'b0;
        if (vif.rxd !== start_val) begin
            return; // Glitch, abort
        end

        // Sample data bits at the middle of each bit period
        for (int i = 0; i < uart_bfm_cfg.data_bit_width; i++) begin
            #(period_ps * 1ps);
            rx_data[i] = vif.rxd;
        end

        // Restore original data if polarity was inverted
        if (uart_bfm_cfg.rx_env) begin
            rx_data = ~rx_data;
        end

        // Send transaction to scoreboard
        trans = t_trans::type_id::create("trans");
        trans.receive_data = rx_data;
        trans.baudrate = uart_bfm_cfg.baudrate;
        trans.data_bit_width = uart_bfm_cfg.data_bit_width;
        trans.stop_bit_width = uart_bfm_cfg.stop_bit_width;
        trans.parity_bit = uart_bfm_cfg.parity_bit;
        trans.hw_flow_en = uart_bfm_cfg.hw_flow_en;
        trans.rx_env = uart_bfm_cfg.rx_env;
        trans.tx_env = uart_bfm_cfg.tx_env;

        // Sample parity bit if enabled
        if (^uart_bfm_cfg.parity_bit) begin
            #(period_ps * 1ps);
            parity_val = vif.rxd;
            
            // Check parity
            begin
                bit expected_parity;
                bit corrected_parity = uart_bfm_cfg.rx_env ? ~parity_val : parity_val;
                bit [8:0] masked_data = rx_data & ((1 << uart_bfm_cfg.data_bit_width) - 1);
                
                if (uart_bfm_cfg.parity_bit[0]) begin
                    expected_parity = ~(^masked_data); // Odd parity
                end else if (uart_bfm_cfg.parity_bit[1]) begin
                    expected_parity = ^masked_data;  // Even parity
                end
                
                if (corrected_parity !== expected_parity) begin
                    trans.parity_err = 1'b1;
                    `uvm_warning("UART_BFM_MONI", $sformatf("Parity error detected! Data: 'h%0x, Parity: %b (Expected: %b)", rx_data, corrected_parity, expected_parity))
                end else begin
                    trans.parity_err = 1'b0;
                end
            end
        end else begin
            trans.parity_err = 1'b0;
        end

        // Sample stop bit
        #(period_ps * 1ps);
        stop_val = vif.rxd;

        // Check frame error (Stop bit should be high under normal polarity, low under rx_env polarity)
        begin
            bit expected_stop = uart_bfm_cfg.rx_env ? 1'b0 : 1'b1;
            if (stop_val !== expected_stop) begin
                trans.frame_err = 1'b1;
                `uvm_warning("UART_BFM_MONI", $sformatf("Framing error detected! Stop bit: %b (Expected: %b)", stop_val, expected_stop))
            end else begin
                trans.frame_err = 1'b0;
            end
        end

        ap.write(trans);
    endtask

endclass

`endif
