`ifndef _H_TB_SEQUENCE_BASE_SV
`define _H_TB_SEQUENCE_BASE_SV
class tb_seq_base extends uvm_sequence;
    `uvm_object_utils(tb_seq_base)

    `uvm_declare_p_sequencer(tb_sequencer)

    monitor_vif moni_vif;

    // axi4lite_write_seq #(axi4lite_trans) reg_write;
    // axi4lite_read_seq #(axi4lite_trans) reg_read;

    // qspi_bfm_config_seq #(qspi_bfm_trans) qspi_config;
    // qspi_bfm_data_push_seq #(qspi_bfm_trans) qspi_push_data;
    // qspi_bfm_trans_seq #(qspi_bfm_trans) qspi_trans;


    function new(string name = "tb_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);

        uvm_config_db#(monitor_vif)::get(null, "", "monitor_vif", moni_vif);
    endfunction  // new


    virtual task wait_clk(int i);
        repeat (i) begin
            @(posedge moni_vif.aclk);
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
