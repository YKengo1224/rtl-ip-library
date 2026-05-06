`ifndef _H_QSPI_BFM_DRIVER_SV
`define _H_QSPI_BFM_DRIVER_SV

class qspi_bfm_driver #(
    type t_if = qspi_bfm_default_interface,
    type t_trans = qspi_bfm_default_transfer
) extends uvm_driver #(t_trans);

    t_if                                vif;

    uvm_analysis_port #(t_trans)        drv_rsv_ap;
    uvm_analysis_port #(t_trans)        drv_send_ap;


    bit                                 master;
    bit                                 order;
    bit                                 clk_pha;
    bit                                 clk_pol;
    int                                 clk_period_ps;


    bit                          [ 3:0] bus_width;
    bit                                 trans_dir;
    bit                          [ 3:0] data_len;
    // bit       [15:0] data;

    bit                          [15:0] send_data_queue[$];


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
        fork
            begin
                slave_trans_bg();
            end
            begin
                forever begin
                    get_and_drive();
                end
            end
        join

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
            DRV_CFG: drive_config(trans);
            DRV_DATA_PUSH: begin
                send_data_queue.push_back(trans.data);
                seq_item_port.item_done();
            end
            // DRV_TRANS: drive_transfer(trans);
        endcase
    endtask

    virtual task drive_config(t_trans trans);
        this.master = trans.master;
        this.order = trans.order;
        this.clk_pha = trans.clk_pha;
        this.clk_pol = trans.clk_pol;
        this.clk_period_ps = trans.clk_period_ps;

        this.bus_width = trans.bus_width;
        this.trans_dir = trans.trans_dir;
        this.data_len = trans.data_len;

        //set csn and clk output enable
        if (this.master) begin
            vif.csn_oe = 1;
            vif.clk_oe = 1;
        end else begin
            vif.csn_oe = 0;
            vif.clk_oe = 0;
        end

        //set data output enable
        case (trans.bus_width)
            1: begin
                if (this.master) vif.data_oe = 4'b0001;
                else vif.data_oe = 4'b0010;
            end
            2: begin
                if (trans.trans_dir) vif.data_oe = 4'b0000;
                else begin
                    vif.data_oe = 4'b0011;
                end
            end
            4: begin
                if (trans.trans_dir) vif.data_oe = 4'b0000;
                else begin
                    vif.data_oe = 4'b1111;
                end
            end
        endcase


        vif.clk_out = this.clk_pol;

        seq_item_port.item_done();
    endtask

    virtual task slave_trans_bg();
        t_trans        trans;
        t_trans        rsp;
        bit     [15:0] sdata;
        int            csn_error = 0;


        forever begin
            rsp = t_trans::type_id::create("rsp");
            trans = t_trans::type_id::create("trans");
            trans.data = 0;
            rsp.data = 0;
            csn_error = 0;

            wait (vif.rst_n);

            wait (!this.master);

            if (vif.csn_in) wait (!vif.csn_in);

            sdata = (send_data_queue.size() != 0) ? send_data_queue.pop_front() : '0;

            if (this.clk_pha == 0) begin
                drive_bits(sdata, 0);
            end
            for (int i = 0; i < (this.data_len / this.bus_width); i++) begin
                slave_wait_edge();
                if (vif.csn_in) begin
                    if (i != 0) begin
                        `uvm_error("DRV", $sformatf("error csn(first edge), loop:%d", i))
                    end
                    csn_error = 1;
                    break;
                end

                if (this.clk_pha == 1) drive_bits(sdata, i);
                else sample_bits(rsp, i);



                slave_wait_edge();
                if (vif.csn_in) begin
                    if (i != 0) begin
                        `uvm_error("DRV", $sformatf("error csn(second edge), loop:%d", i))
                    end
                    csn_error = 1;
                    break;
                end

                if (this.clk_pha == 1) sample_bits(rsp, i);
                else begin
                    if (i < (this.data_len / this.bus_width) - 1) drive_bits(sdata, i + 1);
                end
            end

            if ((!csn_error) && !((this.bus_width != 1) && (this.trans_dir))) begin
                trans.data = sdata;
                drv_send_ap.write(trans);
            end

            if ((!csn_error) && !((this.bus_width != 1) && (!this.trans_dir))) begin
                drv_rsv_ap.write(rsp);
            end
        end
    endtask

    virtual task slave_wait_edge();
        fork
            begin
                @(posedge vif.clk_in or negedge vif.clk_in);
            end
            begin
                wait (vif.csn_in);
            end
        join_any
        disable fork;
    endtask

    virtual task drive_bits(bit [15:0] sdata, int idx);
        case (this.bus_width)
            1: begin  // Single
                if (this.master) begin
                    if (!this.order) begin
                        vif.data_out[0] = sdata[this.data_len-1-idx];
                    end else begin
                        vif.data_out[0] = sdata[idx];
                    end
                end else begin
                    if (!this.order) begin
                        vif.data_out[1] = sdata[this.data_len-1-idx];
                    end else begin
                        vif.data_out[1] = sdata[idx];
                    end
                end
            end
            2: begin
                if (this.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Dual
                    vif.data_out[1:0] = {sdata[8-1-(idx*2)], sdata[8-2-(idx*2)]};
                end else begin
                    vif.data_out[1:0] = {sdata[(idx*2)+1], sdata[(idx*2)]};
                end
            end
            4: begin
                if (this.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Quad
                    vif.data_out[3:0] = {
                        sdata[8-1-(idx*4)],
                        sdata[8-2-(idx*4)],
                        sdata[8-3-(idx*4)],
                        sdata[8-4-(idx*4)]
                    };
                end else begin
                    vif.data_out[3:0] = {
                        sdata[(idx*4)+3], sdata[(idx*4)+2], sdata[(idx*4)+1], sdata[(idx*4)]
                    };
                end
            end
        endcase
    endtask


    virtual task sample_bits(t_trans rsp, int idx);
        case (this.bus_width)
            1: begin
                if (this.master) begin
                    if (!this.order) rsp.data[this.data_len-1-idx] = vif.data_in[1];
                    else rsp.data[idx] = vif.data_in[1];
                end else begin
                    if (!this.order) rsp.data[this.data_len-1-idx] = vif.data_in[0];
                    else rsp.data[idx] = vif.data_in[0];
                end
            end
            2: begin
                if (!this.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Dual
                    rsp.data[this.data_len-1-(idx*2)-:2] = vif.data_in[1:0];
                end else begin
                    rsp.data[(idx*2)+:2] = vif.data_in[1:0];
                end
            end
            4: begin
                if (!this.trans_dir) begin
                    return;
                end
                if (!this.order) begin  // Dual
                    rsp.data[this.data_len-1-(idx*4)-:4] = vif.data_in[3:0];
                end else begin
                    rsp.data[(idx*4)+:4] = vif.data_in[3:0];
                end
            end
        endcase
    endtask


endclass

`endif
