`ifndef _H_QSPI_BFM_TRANSFER_SV
`define _H_QSPI_BFM_TRANSFER_SV

class qspi_bfm_transfer extends uvm_sequence_item;

    `uvm_object_utils(qspi_bfm_transfer)

    function new(string name = "qspi_bfm_transfer");
        super.new(name);
    endfunction

    QSPI_BFM_CMD_t        cmd;
    rand bit              master;
    rand bit              order;
    rand bit              clk_pha;
    rand bit              clk_pol;
    rand int              clk_period_ps;

    rand bit       [ 3:0] bus_width;
    rand bit              trans_dir;
    rand bit       [ 3:0] data_len;
    rand bit              cs_end;
    rand bit       [15:0] data;

endclass

`endif
