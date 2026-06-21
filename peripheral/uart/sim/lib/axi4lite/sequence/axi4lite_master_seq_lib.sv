`ifndef _H_AXI4LITE_MASTER_SEQ_LIB_SV
`define _H_AXI4LITE_MASTER_SEQ_LIB_SV
class axi4lite_master_seq_base #(
    type t_trans = axi4lite_default_transfer
) extends uvm_sequence #(t_trans);

    `uvm_object_param_utils(axi4lite_master_seq_base#(t_trans));

    function new(string name = "axi4lite_master_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task drive_aw(bit [15:0] id, bit [63:0] addr, bit [2:0] prot);
        `uvm_create(req)
        req.cmd  = DRV_AW;
        req.id   = id;
        req.addr = addr;
        req.prot = prot;
        `uvm_send(req)
    endtask

    virtual task drive_w(bit [63:0] data, bit [7:0] wstrb);
        `uvm_create(req)
        req.cmd   = DRV_W;
        req.data  = data;
        req.wstrb = wstrb;
        `uvm_send(req)
    endtask

    virtual task drive_b();
        `uvm_create(req)
        req.cmd = DRV_B;
        `uvm_send(req)
        get_response(rsp);
    endtask

    virtual task drive_ar(bit [15:0] id, bit [63:0] addr, bit [2:0] prot);
        `uvm_create(req)
        req.cmd  = DRV_AR;
        req.id   = id;
        req.addr = addr;
        req.prot = prot;
        `uvm_send(req)
    endtask

    virtual task drive_r();
        `uvm_create(req)
        req.cmd = DRV_R;
        `uvm_send(req)
        get_response(rsp);
    endtask
endclass


class axi4lite_write_seq #(
    type t_trans = axi4lite_default_transfer
) extends axi4lite_master_seq_base #(t_trans);

    `uvm_object_param_utils(axi4lite_write_seq#(t_trans));

    rand bit [63:0] addr;
    rand bit [15:0] id    = 0;
    rand bit [ 2:0] prot  = 0;
    rand bit [63:0] data;
    rand bit [ 7:0] wstrb;

    function new(string name = "axi4lite_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        drive_aw(id, addr, prot);
        drive_w(data, wstrb);
        drive_b();
    endtask

endclass


class axi4lite_read_seq #(
    type t_trans = axi4lite_default_transfer
) extends axi4lite_master_seq_base #(t_trans);

    `uvm_object_param_utils(axi4lite_read_seq#(t_trans));

    rand bit [63:0] addr;
    rand bit [15:0] id    = 0;
    rand bit [2:0]   prot = 0;

    function new(string name = "axi4lite_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        drive_ar(id, addr, prot);
        drive_r();
    endtask

endclass


`endif
