`ifndef _H_UART_SEQUENCER_SV
`define _H_UART_SEQUENCER_SV

class uart_sequencer extends uvm_sequencer;
    `uvm_component_utils(uart_sequencer)

    // AXI4-Lite master sequencer handler
    uvm_sequencer #(axi4lite_transfer) axil_sqr;
    
    // UART BFM sequencer handler
    uvm_sequencer #(uart_bfm_transfer) uart_sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass

`endif
