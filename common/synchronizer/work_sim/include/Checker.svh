`ifndef _H_CHECKER
`define _H_CHECKER



class Checker #(
    parameter int BITWIDTH = 8
);
    virtual fifo_async_if vif;
    bit [BITWIDTH-1:0] wdata_list[$];
    bit [BITWIDTH-1:0] rdata_list[$];

    function new(virtual fifo_async_if vif_in);
        this.vif = vif_in;
    endfunction

    virtual task wdata_moni();
        forever begin
            @(posedge this.vif.WCLK);
            #1;
            if (this.vif.RST_N_WCLK && this.vif.W_EN_WCLK && !this.vif.FULL_WCLKR) begin
                wdata_list.push_back(this.vif.DATA_IN_WCLK);
            end
        end
    endtask


    virtual task rdata_moni();
        forever begin
            @(posedge this.vif.RCLK);
            #1;
            if (this.vif.RST_N_RCLK && this.vif.DATA_OUT_VALID_RCLKR) begin
                rdata_list.push_back(this.vif.DATA_OUT_RCLKR);
            end
        end
    endtask


    virtual task data_check();
        bit [BITWIDTH-1:0] pop_wdata;
        bit [BITWIDTH-1:0] pop_rdata;
        int                cnt = 0;
        fork
            begin
                this.wdata_moni();
            end
            begin
                this.rdata_moni();
            end
            begin
                forever begin
                    @(negedge vif.RST_N_WCLK);
                    wdata_list.delete();
                end
            end
            begin
                forever begin
                    @(negedge vif.RST_N_RCLK);
                    rdata_list.delete();
                end
            end
            begin
                forever begin
                    wait ((wdata_list.size() != 0) && (rdata_list.size() != 0));
                    pop_wdata = wdata_list.pop_front();
                    pop_rdata = rdata_list.pop_front();
                    if (pop_wdata != pop_rdata) begin
                        $error("data missmatch :: wdata:%d,rdata:%d", pop_wdata, pop_rdata);
                        $finish;
                    end
                    cnt++;
                    if (cnt % 1000 == 0) begin
                        $display("[%d]%d pass", $time, cnt);
                    end
                end
            end
        join

    endtask

endclass

`endif
