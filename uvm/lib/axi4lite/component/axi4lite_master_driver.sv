`ifndef _H_AXI4LITE_MASTER_DRIVER_SV
`define _H_AXI4LITE_MASTER_DRIVER_SV

class axi4lite_master_driver #(
    type t_if = axi4lite_default_transfer,
    type t_trans = axi4lite_default_transfer
) extends uvm_driver #(t_trans);

    t_if vif;
    t_trans rsp;

    mailbox #(t_trans) aw_req_fifo;
    mailbox #(t_trans) w_req_fifo;
    mailbox #(t_trans) b_req_fifo;
    mailbox #(t_trans) ar_req_fifo;
    mailbox #(t_trans) r_req_fifo;

    mailbox #(t_trans) b_rsp_fifo;
    mailbox #(t_trans) r_rsp_fifo;

    `uvm_component_param_utils(axi4lite_master_driver#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
        aw_req_fifo = new();
        w_req_fifo  = new();
        b_req_fifo  = new();
        ar_req_fifo = new();
        r_req_fifo  = new();
        b_rsp_fifo  = new();
        r_rsp_fifo  = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
            `uvm_fatal("AXI4LITE_DRV", "vif not found")
    endfunction : build_phase



    virtual task run_phase(uvm_phase phase);
        reset_sig();
        fork
            get_items();
            drive_aw();
            drive_w();
            drive_b();
            drive_ar();
            drive_r();
        join
    endtask : run_phase



    virtual protected task reset_sig();
        vif.awvalid <= '0;
        vif.awid <= '0;
        vif.awaddr <= '0;
        vif.awprot <= '0;

        vif.wvalid <= 1'b0;
        vif.wdata <= '0;
        vif.wstrb <= '0;

        vif.bready <= 1'b0;
        vif.bid <= '0;

        vif.arvalid <= 1'b0;
        vif.arid <= '0;
        vif.araddr <= '0;
        vif.arprot <= '0;

        vif.rready <= 1'b0;
    endtask



    virtual protected task get_items();
        t_trans trans;
        t_trans rsp;

        forever begin
            seq_item_port.get_next_item(trans);
            case (trans.cmd)
                DRV_AW: begin
                    aw_req_fifo.put(trans);
                    seq_item_port.item_done();
                end
                DRV_W: begin
                    w_req_fifo.put(trans);
                    seq_item_port.item_done();
                end
                DRV_AR: begin
                    ar_req_fifo.put(trans);
                    seq_item_port.item_done();
                end

                DRV_B: begin
                    b_req_fifo.put(trans);
                    b_rsp_fifo.get(rsp);
                    rsp.set_id_info(trans);
                    seq_item_port.item_done(rsp);
                end
                DRV_R: begin
                    r_req_fifo.put(trans);
                    r_rsp_fifo.get(rsp);
                    rsp.set_id_info(trans);
                    seq_item_port.item_done(rsp);
                end
                READ: begin
                    r_req_fifo.put(trans);
                    ar_req_fifo.put(trans);
                    r_rsp_fifo.get(rsp);
                    rsp.set_id_info(trans);
                    seq_item_port.item_done(rsp);
                end
                WRITE: begin
                    aw_req_fifo.put(trans);
                    w_req_fifo.put(trans);
                    b_req_fifo.put(trans);
                    b_rsp_fifo.get(rsp);
                    rsp.set_id_info(trans);
                    seq_item_port.item_done(rsp);

                end
            endcase
        end
    endtask

    virtual protected task drive_aw();
        t_trans trans;
        forever begin
            aw_req_fifo.get(trans);
            @(posedge vif.aclk);
            vif.awvalid <= 1'b1;
            vif.awid <= trans.id;
            vif.awaddr <= trans.addr;
            vif.awprot <= trans.prot;
            forever begin
                @(posedge vif.aclk);
                if (!vif.aresetn) break;
                if (vif.awready) break;
            end
            vif.awvalid <= 1'b0;
            vif.awid <= '0;
            vif.awaddr <= '0;
            vif.awprot <= '0;
        end
    endtask

    virtual protected task drive_w();
        t_trans trans;
        forever begin
            w_req_fifo.get(trans);
            @(posedge vif.aclk);
            vif.wvalid <= 1'b1;
            vif.wdata  <= trans.data;
            vif.wstrb  <= trans.wstrb;
            forever begin
                @(posedge vif.aclk);
                if (!vif.aresetn) break;
                if (vif.wready) break;
            end
            vif.wvalid <= 1'b0;
            vif.wdata  <= '0;
            vif.wstrb  <= '0;
        end
    endtask

    virtual protected task drive_b();
        t_trans trans;
        t_trans rsp;
        forever begin
            b_req_fifo.get(trans);
            @(posedge vif.aclk);
            vif.bready <= 1'b1;
            forever begin
                @(posedge vif.aclk);
                if (!vif.aresetn) begin
                    vif.bready <= 1'b0;
                    break;
                end
                if (vif.bvalid) break;
            end

            vif.bvalid <= 1'b0;
            if (vif.aresetn) begin
                rsp = t_trans::type_id::create("rsp");
                rsp.resp = vif.bresp;
                rsp.id = vif.bid;
                b_rsp_fifo.put(rsp);
            end
        end
    endtask
    virtual protected task drive_ar();
        t_trans trans;
        forever begin
            ar_req_fifo.get(trans);
            @(posedge vif.aclk);
            vif.arvalid <= 1'b1;
            vif.arid <= trans.id;
            vif.araddr <= trans.addr;
            vif.arprot <= trans.prot;
            forever begin
                @(posedge vif.aclk);
                if (!vif.aresetn) break;
                if (vif.arready) break;
            end
            vif.arvalid <= 1'b0;
            vif.arid <= '0;
            vif.araddr <= '0;
            vif.arprot <= '0;
        end
    endtask
    virtual protected task drive_r();
        t_trans trans;
        t_trans rsp;
        forever begin
            r_req_fifo.get(trans);
            @(posedge vif.aclk);
            vif.rready <= 1'b1;
            forever begin
                @(posedge vif.aclk);
                if (!vif.aresetn) begin
                    vif.rready <= 1'b0;
                    break;
                end
                if (vif.rvalid) break;
            end

            vif.rready <= 1'b0;
            if (vif.aresetn) begin
                rsp = t_trans::type_id::create("rsp");
                rsp.data = vif.rdata;
                rsp.resp = vif.rresp;
                rsp.id = vif.rid;
                r_rsp_fifo.put(rsp);
            end
        end
    endtask



endclass : axi4lite_master_driver


`endif

