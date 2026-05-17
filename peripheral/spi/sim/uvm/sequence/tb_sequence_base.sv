`ifndef _H_TB_SEQUENCE_BASE_SV
`define _H_TB_SEQUENCE_BASE_SV
class tb_seq_base extends uvm_sequence;
    `uvm_object_utils(tb_seq_base)

    `uvm_declare_p_sequencer(tb_sequencer)

    monitor_vif moni_vif;

    axi4lite_write_seq #(axi4lite_trans) reg_write;
    axi4lite_read_seq #(axi4lite_trans) reg_read;

    qspi_bfm_config_seq #(qspi_bfm_trans) qspi_config;
    qspi_bfm_data_push_seq #(qspi_bfm_trans) qspi_push_data;
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
                             int clock_period_ps, bit [3:0] bus_width = 1, bit trans_dir = 0,
                             bit [3:0] data_len = 8);
        `uvm_do_on_with(qspi_config, p_sequencer.qspi_sqr[bfm_sel],
                        {
        master==is_master;
        order==is_lsb;
        clk_pha==pha;
        clk_pol==pol;
        clk_period_ps==clock_period_ps;
        bus_width == local:: bus_width;
        trans_dir == local:: trans_dir;
        data_len==local::data_len;
                        })
    endtask


    virtual task bfm_push_data(int bfm_sel, bit [15:0] data);
        `uvm_do_on_with(qspi_push_data, p_sequencer.qspi_sqr[bfm_sel], {data==local::data;})
    endtask


    virtual task conf(bit [1:0] mode, bit [3:0] protocol_sel = 1, bit [1:0] trans_dir = 0,
                      bit [3:0] word_width = 8, bit spi_slave_en = 0, bit order = 0,
                      bit [3:0] rx_latch_delay = 0, int bfm_sel = 0, int clock_period_ps);
        bit [63:0] rdata;
        bit [15:0] spi_rdata;
        bit [31:0] write_data;
        case (protocol_sel)
            1: begin
                write_data = {
                    rx_latch_delay,
                    {3'd0, order},
                    {2'b0, mode},
                    {3'b0, spi_slave_en},
                    word_width,
                    {4'b0},
                    {2'b0, trans_dir},
                    4'b1
                };
                write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
            end
            2: begin
                write_data = {
                    rx_latch_delay,
                    {3'd0, order},
                    {2'b0, mode},
                    {3'b0, spi_slave_en},
                    word_width,
                    {4'b10},
                    {2'b0, trans_dir},
                    4'b1
                };
                write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
            end
            4: begin
                write_data = {
                    rx_latch_delay,
                    {3'd0, order},
                    {2'b0, mode},
                    {3'b0, spi_slave_en},
                    word_width,
                    {4'b11},
                    {2'b0, trans_dir},
                    4'b1
                };
                write_reg(.addr(32'h0000), .id(0), .prot(0), .xfer_bytes(4), .data(write_data));
            end
        endcase
        config_qspi(.bfm_sel(bfm_sel), .is_master(spi_slave_en), .is_lsb(order), .pha(mode[0]),
                    .pol(mode[1]), .clock_period_ps(clock_period_ps), .bus_width(protocol_sel),
                    .trans_dir(trans_dir[0]), .data_len(word_width));

    endtask
endclass
`endif
