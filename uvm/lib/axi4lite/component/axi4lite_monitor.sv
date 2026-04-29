`ifndef _H_AXI4LITE_MASTER_MONITOR_SV
`define _H_AXI4LITE_MASTER_MONITOR_SV

class axi4lite_master_monitor #(
    type t_if = axi4lite_default_interface,
    type t_trans = axi4lite_default_transfer
) extends uvm_monitor;

    t_if vif;

    uvm_analysis_port #(t_trans) item_collected_port;

    `uvm_component_param_utils(axi4lite_master_monitor#(t_if, t_trans))

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(t_if)::get(this, "", "vif", vif))
            `uvm_fatal("AXI4LITE_MNTR", "vif not found")
    endfunction


    virtual task run_phase(uvm_phase phase);

        bit     [63:0] awaddr[$];
        bit     [ 2:0] awprot[$];
        bit     [63:0] wdata [$];
        bit     [ 7:0] wstrb [$];
        bit     [15:0] bid   [$];
        bit     [ 1:0] bresp [$];



        bit     [63:0] araddr[$];
        bit     [15:0] arid  [$];
        bit     [ 2:0] arprot[$];
        bit     [63:0] rdata [$];
        bit     [ 1:0] rresp [$];


        t_trans        trans;


        forever begin
            @(posedge vif.clk);
            //--------------------------
            // WRITE
            //--------------------------
            if (vif.awvalid && vif.awready) begin
                awaddr.push_back(vif.awaddr);
                awprot.push_back(vif.awprot);

            end

            if (vif.wvalid && vif.wready) begin
                wdata.push_back(vif.wdata);
                wstrb.push_back(vif.wstrb);
            end

            if (vif.bvalid && vif.bready) begin
                bid.push_back(vif.bid);
                bresp.push_back(vif.bresp);
            end

            if (awaddr.size() && wdata.size() && bid.size()) begin
                trans = new();

                trans.cmd = WRITE;
                trans.id = bid.pop_front();
                trans.addr = awaddr.pop_front();
                trans.prot = awprot.pop_front();
                trans.data = wdata.pop_front();
                trans.wstrb = wstrb.pop_front();
                trans.resp = bresp.pop_front();
                item_collected_port.write(trans);
            end

            //--------------------------
            // READ
            //--------------------------
            if (vif.arvalid && vif.arready) begin
                arid.push_back(vif.arid);
                araddr.push_back(vif.araddr);
                arprot.push_back(vif.arprot);

            end

            if (vif.rvalid && vif.rready) begin
                rdata.push_back(vif.rdata);
                rresp.push_back(vif.rresp);
            end

            if (araddr.size() && rdata.size()) begin
                trans = new();

                trans.cmd = READ;
                trans.id = arid.pop_front();
                trans.addr = araddr.pop_front();
                trans.prot = arprot.pop_front();
                trans.data = rdata.pop_front();
                trans.resp = rresp.pop_front();
                item_collected_port.write(trans);
            end
        end
    endtask
endclass
`endif
