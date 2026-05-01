`ifndef _H_AXI4LITE_TRANSFER_SV
`define _H_AXI4LITE_TRANSFER_SV


class axi4lite_transfer extends uvm_sequence_item;


    `uvm_object_utils(axi4lite_transfer)

    function new(string name="axi4lite_transfer");
        super.new(name);
    endfunction

    AXI4LITE_CMD_t        cmd;
    rand bit       [15:0] id;
    rand bit       [63:0] addr;
    rand bit       [ 2:0] prot;
    rand bit       [63:0] data;
    rand bit       [ 7:0] wstrb;
    rand bit       [ 1:0] resp;



endclass

`endif
