`ifndef _H_CLOCK_GEN
`define _H_CLOCK_GEN

class ClockGen;

    virtual fifo_async_if vif;

    function new(virtual fifo_async_if vif_in);
        this.vif = vif_in;
    endfunction

    task unreset();
        fork
            begin
                @(posedge this.vif.WCLK);
                this.vif.RST_N_WCLK = 1'b1;
            end
            begin
                @(posedge this.vif.RCLK);
                this.vif.RST_N_RCLK = 1'b1;
            end
        join
    endtask
    task reset();
        this.vif.RST_N_WCLK = 1'b0;
        this.vif.RST_N_RCLK = 1'b0;
        $display("rst value:%d", this.vif.RST_N_WCLK);

    endtask



    task clk_gen(real freq_MHz_WCLK, real freq_MHz_RCLK);
        real period_ns_WCLK = 1e9 / (freq_MHz_WCLK * 1e6);
        real period_ns_RCLK = 1e9 / (freq_MHz_RCLK * 1e6);


        this.vif.WCLK <= 1'b0;
        this.vif.RCLK <= 1'b0;


        fork : clk_threads
            begin
                forever begin
                    #(period_ns_WCLK / 2.0) this.vif.WCLK <= ~this.vif.WCLK;
                end
            end
            begin
                forever begin
                    #(period_ns_RCLK / 2.0) this.vif.RCLK <= ~this.vif.RCLK;
                end
            end
        join
    endtask

    // task stop_clk();
    //     disable clk_threads;
    // endtask


endclass

`endif
