`ifndef _H_TB_SEQUENCE_BASE_SV
`define _H_TB_SEQUENCE_BASE_SV
class tb_seq_base extends uvm_sequence;
    `uvm_object_utils(tb_seq_base)

    `uvm_declare_p_sequencer(tb_sequencer)

    monitor_vif moni_vif;

    axi4lite_write_seq #(axi4lite_trans) reg_write;
    axi4lite_read_seq #(axi4lite_trans) reg_read;

    qspi_bfm_config_seq #(qspi_bfm_trans) qspi_config;
    qspi_bfm_trans_seq #(qspi_bfm_trans) qspi_trans;

    function new(string name = "tb_seq_base");
        super.new(name);
        set_automatic_phase_objection(1);

        uvm_config_db#(monitor_vif)::get(null, "", "monitor_vif", moni_vif);
    endfunction  // new


    virtual task write_reg(bit [63:0] addr, bit [15:0] id = 0, bit [2:0] prot = 0, int xfer_bytes,
                           bit [63:0] data);
        `uvm_do_on_with(reg_write, p_sequencer.axi4lite_m_sqr,
                        {
        addr==local::addr;
        id==local::id;
        prot==local::prot;
        data==local::data;
        xfer_bytes==local::xfer_bytes;
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

    virtual task config_qspi(int bfm_sel, bit is_master, bit is_lsb, bit pha, bit pol,
                             int clock_period_ps);
        `uvm_do_on_with(qspi_config, p_sequencer.qspi_sqr[bfm_sel],
                        {
        master==is_master;
        order==is_lsb;
        clk_pha==pha;
        clk_pol==pol;
        clk_period_ps==clock_period_ps;})
    endtask


    virtual task trans_qspi(int bfm_sel, bit [3:0] bus_width = 1, bit trans_dir = 0,
                            bit data_len = 8, bit cs_end, bit [15:0] data = 0);
        `uvm_do_on_with(qspi_trans, p_sequencer.qspi_sqr[bfm_sel],
                        {
        bus_width == local:: bus_width;
        trans_dir == local:: trans_dir;
        data_len==local::data_len;
        cs_end==local::cs_end;
        data==local::data;
        })
    endtask
endclass
`endif
