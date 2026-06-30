`ifndef _H_TB_SEQUENCE_BASE_SV
`define _H_TB_SEQUENCE_BASE_SV

class tb_seq_base extends uvm_sequence;
    `uvm_object_utils(tb_seq_base)
    `uvm_declare_p_sequencer(tb_sequencer)

    axi4lite_write_seq #(axi4lite_trans) reg_write;
    axi4lite_read_seq #(axi4lite_trans) reg_read;

    function new(string name = "tb_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task wait_clk(int i);
        axi4lite_master_vif vif;
        if (!uvm_config_db#(axi4lite_master_vif)::get(null, "", "axi4lite_m_vif", vif)) begin
            `uvm_fatal("SEQ", "Failed to get axi4lite_m_vif from config_db")
        end
        repeat (i) begin
            @(posedge vif.aclk);
        end
    endtask

    virtual task write_reg(bit [63:0] addr, bit [15:0] id = 0, bit [2:0] prot = 0, int wstrb,
                           bit [63:0] data);
        `uvm_do_on_with(reg_write, p_sequencer.axi4lite_m_sqr,
                        {
        addr==local::addr;
        id==local::id;
        prot==local::prot;
        data==local::data;
        wstrb==local::wstrb;
        })
    endtask

    virtual task read_reg(bit [63:0] addr, bit [15:0] id = 0, bit [2:0] prot = 0,
                          ref bit [63:0] data);
        `uvm_do_on_with(reg_read, p_sequencer.axi4lite_m_sqr,
                        {
        addr==local::addr;
        id==local::id;
        prot==local::prot;
        })
        data = reg_read.rsp.data;
    endtask
endclass

`endif
