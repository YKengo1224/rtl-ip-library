`ifndef _H_AXI4LITE_ADAPTER_SV
`define _H_AXI4LITE_ADAPTER_SV
class axi4lite_adapter #(
    type t_trans = axi4lite_default_transfer
) extends uvm_reg_adapter;

    `uvm_object_param_utils(axi4lite_adapter#(t_trans))

    function new(string name = "axi4lite_adapter");
        super.new(name);

        supports_byte_enable = 1;
        provides_responses   = 1;
    endfunction

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        t_trans bus_req = t_trans::type_id::create("bus_req");

        if (rw.kind == UVM_WRITE) begin
            bus_req.id = '0;
            bus_req.cmd = WRITE;
            bus_req.addr = rw.addr;
            bus_req.data = rw.data;
            bus_req.wstrb = rw.byte_en;
            bus_req.prot = 0;
        end else begin
            bus_req.id   = '0;
            bus_req.cmd  = READ;
            bus_req.addr = rw.addr;
            bus_req.data = rw.data;
            bus_req.prot = 0;
        end

        return bus_req;
    endfunction

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        t_trans bus_rsp;
        bit dec_reg_write;

        if (!$cast(bus_rsp, bus_item)) begin
            `uvm_fatal("AXI4LITE_ADPT", "Provided bus item is not of correct type")
        end

        rw.kind = (bus_rsp.cmd == READ) ? UVM_READ : UVM_WRITE;
        rw.addr = bus_rsp.addr;
        rw.data = bus_rsp.data;
        rw.status = (bus_rsp.resp == 2'b00) ? UVM_IS_OK : UVM_NOT_OK;

    endfunction
endclass

`endif
