`ifndef _H_UART_BFM_SEQ_LIB_SV
`define _H_UART_BFM_SEQ_LIB_SV

class uart_bfm_seq_base #(
    type t_trans = uart_bfm_default_transfer
) extends uvm_sequence #(t_trans);

    `uvm_object_param_utils(uart_bfm_seq_base#(t_trans));

    function new(string name = "uart_bfm_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

endclass


class uart_bfm_config_seq #(
    type t_trans = uart_bfm_default_transfer
) extends uart_bfm_seq_base #(t_trans);

    `uvm_object_param_utils(uart_bfm_config_seq#(t_trans));

    rand int             baudrate         = 115200;
    rand bit       [3:0] data_bit_width   = 8;
    rand bit       [1:0] stop_bit_width   = 1;
    rand bit       [1:0] parity_bit       = 0;
    rand bit             hw_flow_en       = 0;
    rand bit             tx_env           = 0;
    rand bit             rx_env           = 0;
    rand bit       [1:0] over_samp_sel    = 1; // 0:8x, 1:16x, 2:32x

    function new(string name = "uart_bfm_config_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_create(req)
        req.cmd            = DRV_CFG;
        req.baudrate       = baudrate;
        req.data_bit_width = data_bit_width;
        req.stop_bit_width = stop_bit_width;
        req.parity_bit     = parity_bit;
        req.hw_flow_en     = hw_flow_en;
        req.tx_env         = tx_env;
        req.rx_env         = rx_env;
        req.over_samp_sel  = over_samp_sel;
        `uvm_send(req)
    endtask

endclass


class uart_bfm_tx_seq #(
    type t_trans = uart_bfm_default_transfer
) extends uart_bfm_seq_base #(t_trans);

    `uvm_object_param_utils(uart_bfm_tx_seq#(t_trans));

    rand bit [8:0] data;
    rand bit       parity_err_en  = 0;
    rand bit       frame_err_en   = 0;
    rand bit       noize_en       = 0;
    rand bit       start_noise_en = 0;
    rand bit       start_fail_en  = 0;

    function new(string name = "uart_bfm_tx_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_create(req)
        req.cmd            = DRV_TRANS;
        req.send_data      = data;
        req.parity_err_en  = parity_err_en;
        req.frame_err_en   = frame_err_en;
        req.noize_en       = noize_en;
        req.start_noise_en = start_noise_en;
        req.start_fail_en  = start_fail_en;
        `uvm_send(req)
    endtask

endclass

`endif
