`ifndef _H_QSPI_BFM_DRIVER_SV
`define _H_QSPI_BFM_DRIVER_SV

class qspi_bfm_driver #(
    type t_if = qspi_bfm_default_interface,
    type t_trans = qspi_bfm_default_transfer
) extends uvm_driver #(t_trans);

    t_if vif;

    uvm_analysis_port #(t_trans) drv_rsv_ap;
    uvm_analysis_port #(t_trans) drv_send_ap;


    bit master;
    bit order;
    bit clk_pha;
    bit clk_pol;
    int clk_period_ps;



    `uvm_component_param_utils(qspi_bfm_driver#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv_rsv_ap  = new("drv_rsv_ap", this);
        drv_send_ap = new("drv_send_ap", this);

        if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
            `uvm_fatal("QSPI_DRV", "vif not found")
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_sig();
        forever begin
            get_and_drive();
        end
    endtask


    virtual protected task reset_sig();
        vif.clk_out  = 1'b0;
        vif.clk_oe   = 1'b0;
        vif.csn_out  = 1'b1;
        vif.csn_oe   = 1'b0;
        vif.data_out = '0;
        vif.data_oe  = '0;
    endtask

    virtual protected task get_and_drive();
        t_trans trans;
        seq_item_port.get_next_item(trans);
        case (trans.cmd)
            DRV_CFG:   drive_config(trans);
            DRV_TRANS: drive_transfer(trans);
        endcase
    endtask

    virtual task drive_config(t_trans trans);
        this.master = trans.master;
        this.order = trans.order;
        this.clk_pha = trans.clk_pha;
        this.clk_pol = trans.clk_pol;
        this.clk_period_ps = trans.clk_period_ps;


        if (this.master) begin
            vif.csn_oe = 1;
            vif.clk_oe = 1;
        end else begin
            vif.csn_oe = 0;
            vif.clk_oe = 0;
        end

        vif.clk_out = this.clk_pol;

        seq_item_port.item_done();
    endtask

    virtual task drive_transfer(t_trans trans);
        t_trans rsp;
        $cast(rsp, trans);
        rsp.set_id_info(trans);

        case (trans.bus_width)
            1: begin
                drv_send_ap.write(trans);
                if (this.master) vif.data_oe = 4'b0001;
                else vif.data_oe = 4'b0010;
            end
            2: begin
                if (trans.trans_dir) vif.data_oe = 4'b0000;
                else begin
                    vif.data_oe = 4'b0011;
                    drv_send_ap.write(trans);
                end
            end
            4: begin
                if (trans.trans_dir) vif.data_oe = 4'b0000;
                else begin
                    vif.data_oe = 4'b1111;
                    drv_send_ap.write(trans);
                end
            end
        endcase


        if (this.master || (!this.master && (vif.csn_in == 1'b1))) begin
            control_csn(1);
        end

        if (this.clk_pha == 0) begin
            drive_bits(trans, 0);
        end

        for (int i = 0; i < (trans.data_len / trans.bus_width); i++) begin
            wait_next_edge(trans);
            if (this.clk_pha == 1) drive_bits(trans, i);
            else sample_bits(trans, rsp, i);

            wait_next_edge(trans);
            if (this.clk_pha == 1) sample_bits(trans, rsp, i);
            else begin
                if (i < (trans.data_len / trans.bus_width) - 1) drive_bits(trans, i + 1);
            end
        end

        if (trans.cs_end) begin
            control_csn(0);
        end

        seq_item_port.item_done(rsp);

        if ((trans.bus_width != 1) && (!trans.trans_dir)) begin
            return;
        end
        drv_rsv_ap.write(rsp);
    endtask

    virtual task wait_next_edge(t_trans trans);
        if (this.master) begin
            #(this.clk_period_ps / 2);
            vif.clk_out = ~vif.clk_out;
        end else begin
            // Slaveなら、相手(Master)が叩いた信号のエッジを待つ
            @(posedge vif.clk_in or negedge vif.clk_in);
        end
    endtask


    virtual task control_csn(bit active);
        if (this.master) begin
            vif.csn_oe  = 1'b1;
            vif.csn_out = ~active;
        end else begin
            if (active) wait (!vif.csn_in);
            else wait (vif.csn_in);
        end
    endtask

    virtual task drive_bits(t_trans trans, int idx);
        case (trans.bus_width)
            1: begin  // Single
                if (this.master) begin
                    if (!this.order) begin
                        vif.data_out[0] = trans.data[trans.data_len-1-idx];
                    end else begin
                        vif.data_out[0] = trans.data[idx];
                    end
                end else begin
                    if (!this.order) begin
                        vif.data_out[1] = trans.data[trans.data_len-1-idx];
                    end else begin
                        vif.data_out[1] = trans.data[idx];
                    end
                end
            end
            2: begin
                if (trans.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Dual
                    vif.data_out[1:0] = {trans.data[8-1-(idx*2)], trans.data[8-2-(idx*2)]};
                end else begin
                    vif.data_out[1:0] = {trans.data[(idx*2)+1], trans.data[(idx*2)]};
                end
            end
            4: begin
                if (trans.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Quad
                    vif.data_out[3:0] = {
                        trans.data[8-1-(idx*4)],
                        trans.data[8-2-(idx*4)],
                        trans.data[8-3-(idx*4)],
                        trans.data[8-4-(idx*4)]
                    };
                end else begin
                    vif.data_out[3:0] = {
                        trans.data[(idx*4)+3],
                        trans.data[(idx*4)+2],
                        trans.data[(idx*4)+1],
                        trans.data[(idx*4)]
                    };
                end
            end
        endcase
    endtask

    virtual task sample_bits(t_trans trans, t_trans rsp, int idx);
        case (trans.bus_width)
            1: begin
                if (this.master) begin
                    if (!this.order) rsp.data[trans.data_len-1-idx] = vif.data_in[1];
                    else rsp.data[idx] = vif.data_in[1];
                end else begin
                    if (!this.order) rsp.data[trans.data_len-1-idx] = vif.data_in[0];
                    else rsp.data[idx] = vif.data_in[0];
                end
            end
            2: begin
                if (!trans.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Dual
                    rsp.data[trans.data_len-1-(idx*2)-:2] = vif.data_in[1:0];
                end else begin
                    rsp.data[(idx*2)+:2] = vif.data_in[1:0];
                end
            end
            4: begin
                if (!trans.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Dual
                    rsp.data[trans.data_len-1-(idx*4)-:4] = vif.data_in[3:0];
                end else begin
                    rsp.data[(idx*4)+:4] = vif.data_in[3:0];
                end
            end
        endcase
    endtask


endclass

`endif
