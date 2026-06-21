`ifndef _H_UART_BFM_CONFIG_SV
`define _H_UART_BFM_CONFIG_SV

class uart_bfm_config extends uvm_object;

    int       baudrate;
    bit [3:0] data_bit_width;
    bit [1:0] stop_bit_width;
    bit [1:0] parity_bit;
    bit       hw_flow_en;
    bit       tx_env;
    bit       rx_env;
    bit [1:0] over_samp_sel;


    `uvm_object_utils_begin(uart_bfm_config)
        `uvm_field_int(baudrate, UVM_DEFAULT)
        `uvm_field_int(data_bit_width, UVM_DEFAULT)
        `uvm_field_int(stop_bit_width, UVM_DEFAULT)
        `uvm_field_int(parity_bit, UVM_DEFAULT)
        `uvm_field_int(hw_flow_en, UVM_DEFAULT)
        `uvm_field_int(tx_env, UVM_DEFAULT)
        `uvm_field_int(rx_env, UVM_DEFAULT)
        `uvm_field_int(over_samp_sel, UVM_DEFAULT)
    `uvm_object_utils_end


    function new(string name = "uart_bfm_config");
        super.new(name);
    endfunction


endclass

`endif
