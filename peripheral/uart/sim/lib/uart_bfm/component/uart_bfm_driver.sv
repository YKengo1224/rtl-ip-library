`ifndef _H_UART_BFM_DRIVER_SV
`define _H_UART_BFM_DRIVER_SV

class uart_bfm_driver #(
    type t_if = uart_bfm_default_interface,
    type t_trans = uart_bfm_default_transfer
) extends uvm_driver #(t_trans);

    t_if            vif;
    uart_bfm_config uart_bfm_cfg;




    `uvm_component_param_utils(uart_bfm_driver#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
            `uvm_fatal("UART_BFM_DRV", "vif not found")

        if (!uvm_config_db#(uart_bfm_config)::get(this, "", "uart_bfm_cfg", uart_bfm_cfg))
            `uvm_fatal("UART_BFM_DRV", "uart_bfm_cfg not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_sig();

        forever begin
            get_and_drive();
        end

    endtask


    virtual protected task reset_sig();
        vif.txd  = 1'b1;
        vif.rtsn = 1'b1;
    endtask

    virtual protected task get_and_drive();
        t_trans trans;
        seq_item_port.get_next_item(trans);
        case (trans.cmd)
            DRV_CFG:   uart_config(trans);
            DRV_TRANS: send_data(trans);
        endcase
        seq_item_port.item_done();
    endtask

    virtual task uart_config(t_trans trans);
        uart_bfm_cfg.baudrate = trans.baudrate;
        uart_bfm_cfg.data_bit_width = trans.data_bit_width;
        uart_bfm_cfg.stop_bit_width = trans.stop_bit_width;
        uart_bfm_cfg.parity_bit = trans.parity_bit;
        uart_bfm_cfg.hw_flow_en = trans.hw_flow_en;
        uart_bfm_cfg.tx_env = trans.tx_env;
        uart_bfm_cfg.rx_env = trans.rx_env;
        uart_bfm_cfg.over_samp_sel = trans.over_samp_sel;

        vif.txd = !uart_bfm_cfg.tx_env;

    endtask

    virtual task send_data(t_trans trans);
        longint       period_ps;
        longint       over_samp;
        longint       tick_ps;
        bit           start_bit = 1'b0;
        bit           stop_bit = 1'b1;
        bit     [8:0] send_data = trans.send_data;
        bit           parity_bit;

        //=========================================
        // transオブジェクトから各種エラー制御(en)を読み出し
        //=========================================
        bit           parity_err_en = trans.parity_err_en;
        bit           frame_err_en = trans.frame_err_en;
        bit           noize_en = trans.noize_en;
        bit           start_noise_en = trans.start_noise_en;
        bit           start_fail_en = trans.start_fail_en;

        int           noize;
        int           noise_budget;
        int           slots_left;

        period_ps = 64'd1_000_000_000_000 / uart_bfm_cfg.baudrate;
        case (uart_bfm_cfg.over_samp_sel)
            2'b00:   over_samp = 8;
            2'b01:   over_samp = 16;
            2'b10:   over_samp = 32;
            default: over_samp = 1;
        endcase
        tick_ps = period_ps / over_samp;

        noize   = 3 << uart_bfm_cfg.over_samp_sel;

        if (uart_bfm_cfg.parity_bit[0]) begin
            parity_bit = ~(^send_data);
        end
        if (uart_bfm_cfg.parity_bit[1]) begin
            parity_bit = ^send_data;
        end

        if (uart_bfm_cfg.tx_env) begin
            start_bit  = ~start_bit;
            stop_bit   = ~stop_bit;
            send_data  = ~send_data;
            parity_bit = ~parity_bit;
        end

        //=========================================
        // 1. START Bit (ノイズ注入 & 検出制御)
        //=========================================
        if (start_noise_en || start_fail_en) begin
            slots_left = over_samp / 2;

            if (start_fail_en) begin
                noise_budget = $urandom_range(noize, slots_left);
            end else begin
                noise_budget = $urandom_range(1, noize - 1);
            end

            vif.txd = start_bit;
            #(tick_ps * 1ps);
            slots_left--;

            for (int i = 0; i < (over_samp / 2) - 1; i++) begin
                bit inject_noise;

                if (noise_budget >= slots_left) begin
                    inject_noise = 1'b1;
                end else if (noise_budget <= 0) begin
                    inject_noise = 1'b0;
                end else begin
                    inject_noise = $urandom_range(0, 1);
                end

                if (inject_noise) begin
                    vif.txd = ~start_bit;
                    noise_budget--;
                end else begin
                    vif.txd = start_bit;
                end

                #(tick_ps * 1ps);
                slots_left--;
            end

            vif.txd = start_bit;
            #( (period_ps - (tick_ps * (over_samp / 2))) * 1ps );

            if (start_fail_en) begin
                vif.txd = !uart_bfm_cfg.tx_env;
                return;
            end

        end else begin
            vif.txd = start_bit;
            #(period_ps * 1ps);
        end

        //=========================================
        // 2. Data Bits
        //=========================================
        for (int i = 0; i < uart_bfm_cfg.data_bit_width; i++) begin
            vif.txd = send_data[i];

            if (noize_en) begin
                longint wait_before = tick_ps * (over_samp / 2);
                longint wait_after = period_ps - wait_before - tick_ps;

                #(wait_before * 1ps);
                vif.txd = ~send_data[i];
                #(tick_ps * 1ps);
                vif.txd = send_data[i];
                #(wait_after * 1ps);
            end else begin
                #(period_ps * 1ps);
            end
        end

        //=========================================
        // 3. Parity Bit
        //=========================================
        if (^uart_bfm_cfg.parity_bit) begin
            if (parity_err_en) begin
                vif.txd = ~parity_bit;
            end else begin
                vif.txd = parity_bit;
            end
            #(period_ps * 1ps);
        end

        //=========================================
        // 4. STOP Bit
        //=========================================
        if (frame_err_en) begin
            vif.txd = ~stop_bit;
        end else begin
            vif.txd = stop_bit;
        end

        case (uart_bfm_cfg.stop_bit_width)
            2'b00: #((period_ps / 2) * 1ps);
            2'b01: #(period_ps * 1ps);
            2'b10: #((period_ps + (period_ps / 2)) * 1ps);
            2'b11: #((period_ps * 2) * 1ps);
        endcase

        vif.txd = !uart_bfm_cfg.tx_env;

    endtask

endclass

`endif
