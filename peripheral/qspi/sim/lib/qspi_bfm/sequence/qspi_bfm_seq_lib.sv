`ifndef _H_QSPI_BFM_SEQ_LIB_SV
`define _H_QSPI_BFM_SEQ_LIB_SV
class qspi_bfm_seq_base #(
    type t_trans = qspi_bfm_default_transfer
) extends uvm_sequence #(t_trans);

    `uvm_object_param_utils(qspi_bfm_seq_base#(t_trans));

    function new(string name = "qspi_bfm_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

endclass


class qspi_bfm_config_seq #(
    type t_trans = qspi_bfm_default_transfer
) extends qspi_bfm_seq_base #(t_trans);

    `uvm_object_param_utils(qspi_bfm_config_seq#(t_trans));


    rand bit       master         = 0;
    rand bit       order          = 0;
    rand bit       clk_pha        = 0;
    rand bit       clk_pol        = 0;
    rand int       clk_period_ps;

    rand bit [3:0] bus_width      = 1;
    rand bit       trans_dir      = 0;
    rand bit [3:0] data_len       = 8;

    function new(string name = "qspi_bfm_config_seq");
        super.new(name);
    endfunction


    virtual task body();
        `uvm_create(req)
        req.cmd = DRV_CFG;
        req.master = master;
        req.order = order;
        req.clk_pha = clk_pha;
        req.clk_pol = clk_pol;
        req.clk_period_ps = clk_period_ps;
        req.bus_width = bus_width;
        req.trans_dir = trans_dir;
        req.data_len = data_len;
        `uvm_send(req)
    endtask

endclass

class qspi_bfm_data_push_seq #(
    type t_trans = qspi_bfm_default_transfer
) extends qspi_bfm_seq_base #(t_trans);

    `uvm_object_param_utils(qspi_bfm_data_push_seq#(t_trans));


    rand bit [15:0] data = 0;

    function new(string name = "qspi_bfm_trans_seq");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_create(req)
        req.cmd  = DRV_DATA_PUSH;
        req.data = data;
        `uvm_send(req)
    endtask

endclass


// class qspi_bfm_trans_seq #(
//     type t_trans = qspi_bfm_default_transfer
// ) extends qspi_bfm_seq_base #(t_trans);

//     `uvm_object_param_utils(qspi_bfm_trans_seq#(t_trans));



//     rand bit [ 3:0] bus_width = 1;
//     rand bit        trans_dir = 0;
//     rand bit [ 3:0] data_len  = 8;
//     rand bit        cs_end    = 0;
//     rand bit [15:0] data      = 0;

//     function new(string name = "qspi_bfm_trans_seq");
//         super.new(name);
//     endfunction


//     virtual task body();
//         `uvm_create(req)
//         req.cmd = DRV_TRANS;

//         `uvm_send(req)
//         get_response(rsp);
//     endtask

// endclass


`endif
