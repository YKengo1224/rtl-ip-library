`ifndef _H_AXI4LITE_MASTER_DRIVER_SV
`define _H_AXI4LITE_MASTER_DRIVER_SV

class axi4lite_master_driver #(
    type t_if = axi4lite_default_transfer,
    type t_trans = axi4lite_default_transfer
) extends uvm_driver #(t_trans);

    t_if vif;
    t_trans rsp;


    `uvm_component_param_utils(axi4lite_master_driver#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
            `uvm_fatal("AXI4LITE_DRV", "vif not found")
    endfunction : build_phase



    virtual task run_phase(uvm_phase phase);
        forever begin
            if (!vif.aresetn) begin
                reset_sig();
            end else begin
                get_and_drive();
            end
        end
    endtask : run_phase

    virtual protected task reset_sig();
        vif.awvalid = '0;
        vif.awid = '0;
        vif.awaddr = '0;
        vif.awprot = '0;

        vif.wvalid = 1'b0;
        vif.wdata = '0;
        vif.wstrb = '0;

        vif.bready = 1'b0;
        vif.bid = '0;

        vif.arvalid = 1'b0;
        vif.arid = '0;
        vif.araddr = '0;
        vif.arprot = '0;

        vif.rready = 1'b0;
    endtask

    virtual protected task get_and_drive();
        t_trans trans;

        seq_item_port.get_next_item(trans);

        case (trans.cmd)
            DRV_AW: drive_aw(trans);
            DRV_W:  drive_w(trans);
            DRV_B:  drive_b(trans);
            DRV_AR: drive_ar(trans);
            DRV_R:  drive_r(trans);
            READ:   read(trans);
            WRITE:  write(trans);
        endcase
    endtask

    virtual protected task drive_aw_internal(t_trans trans);
        @(posedge vif.aclk);
        vif.awvalid = 1'b1;
        vif.awid = trans.id;
        vif.awaddr = trans.addr;
        vif.awprot = trans.prot;
        do begin
            @(posedge vif.aclk);
            if (!vif.aresetn) return;
        end while (!vif.awready);

        vif.awvalid = 1'b0;
        vif.awid = '0;
        vif.awaddr = '0;
        vif.awprot = '0;
    endtask

    virtual protected task drive_w_internal(t_trans trans);
        @(posedge vif.aclk);
        vif.wvalid = 1'b1;
        vif.wdata  = trans.data;
        vif.wstrb  = trans.wstrb;
        do begin
            @(posedge vif.aclk);
            if (!vif.aresetn) return;
        end while (!vif.wready);
        vif.wvalid = 1'b0;
        vif.wdata  = '0;
        vif.wstrb  = '0;
    endtask

    virtual protected task drive_b_internal(t_trans trans);
        @(posedge vif.aclk);
        vif.bready = 1'b1;
        do begin
            @(posedge vif.aclk);
            if (!vif.aresetn) return;
        end while (!vif.bvalid);

        vif.bready = 1'b0;
        vif.bid = '0;
    endtask
    virtual protected task drive_ar_internal(t_trans trans);
        @(posedge vif.aclk);
        vif.arvalid = 1'b1;
        vif.arid = trans.id;
        vif.araddr = trans.addr;
        vif.arprot = trans.prot;
        do begin
            @(posedge vif.aclk);
            if (!vif.aresetn) return;
        end while (!vif.arready);

        vif.arvalid = 1'b0;
        vif.arid = '0;
        vif.araddr = '0;
        vif.arprot = '0;
    endtask

    virtual protected task drive_r_internal(t_trans trans);
        @(posedge vif.aclk);
        vif.rready = 1'b1;
        do begin
            @(posedge vif.aclk);
            if (!vif.aresetn) return;
        end while (!vif.rvalid);

        vif.rready = 1'b0;
    endtask


    virtual protected task drive_aw(t_trans trans);
        fork
            begin
                drive_aw_internal(trans);
            end
        join_none
        seq_item_port.item_done();
    endtask

    virtual protected task drive_w(t_trans trans);
        fork
            begin
                drive_w_internal(trans);
            end
        join_none
        seq_item_port.item_done();
    endtask

    virtual protected task drive_b(t_trans trans);

        fork
            begin
                drive_b_internal(trans);

                $cast(rsp, trans.clone());
                rsp.set_id_info(trans);
                rsp.resp = vif.bresp;
                rsp.id = vif.bid;

                vif.bready = 1'b0;
                vif.bid = '0;

                seq_item_port.item_done(rsp);
            end
        join_none

    endtask

    virtual protected task drive_ar(t_trans trans);
        fork
            begin
                drive_ar_internal(trans);
            end
        join_none
        seq_item_port.item_done();
    endtask

    virtual protected task drive_r(t_trans trans);
        fork
            begin
                drive_r_internal(trans);

                $cast(rsp, trans.clone());
                rsp.set_id_info(trans);
                rsp.data   = vif.rdata;
                rsp.resp   = vif.rresp;

                vif.rready = 1'b0;

                seq_item_port.item_done(rsp);
            end
        join_none
    endtask

    virtual protected task write(t_trans trans);
        fork
            begin
                drive_aw_internal(trans);
            end
            begin
                drive_w_internal(trans);
            end
            begin
                drive_b_internal(trans);
            end
        join

        $cast(rsp, trans.clone());
        rsp.set_id_info(trans);
        rsp.resp = vif.bresp;
        rsp.id   = vif.bid;

        seq_item_port.item_done(rsp);
    endtask

    virtual protected task read(t_trans trans);
        fork
            begin
                drive_ar_internal(trans);
            end
            begin
                drive_r_internal(trans);
            end
        join
        $cast(rsp, trans.clone());
        rsp.cmd = READ;
        rsp.set_id_info(trans);
        rsp.data = vif.rdata;
        rsp.resp = vif.rresp;

        seq_item_port.item_done(rsp);
    endtask


endclass : axi4lite_master_driver


`endif

