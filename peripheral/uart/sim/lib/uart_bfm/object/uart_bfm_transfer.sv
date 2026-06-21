`ifndef _H_UART_BFM_TRANSFER_SV
`define _H_UART_BFM_TRANSFER_SV

class uart_bfm_transfer extends uvm_sequence_item;

    `uvm_object_utils(uart_bfm_transfer)

    function new(string name = "uart_bfm_transfer");
        super.new(name);
    endfunction

    UART_BFM_CMD_t       cmd;

    rand bit       [8:0] send_data;
    rand bit       [8:0] receive_data;
    rand bit       [1:0] over_samp_sel;

    rand int             baudrate;
    rand bit       [3:0] data_bit_width;
    rand bit       [1:0] stop_bit_width;
    rand bit       [1:0] parity_bit;
    rand bit             hw_flow_en;
    rand bit             tx_env;
    rand bit             rx_env;

    rand bit             parity_err_en;
    rand bit             frame_err_en;
    rand bit             noize_en;
    rand bit             start_noise_en;
    rand bit             start_fail_en;

    bit                  parity_err;
    bit                  frame_err;
    
    

endclass

`endif

