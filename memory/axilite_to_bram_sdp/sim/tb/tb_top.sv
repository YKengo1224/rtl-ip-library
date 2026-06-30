`default_nettype none

module tb_top ();

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import tb_pkg::*;
    import case_pkg::*;

    parameter int ACLK_PERIOD_PS = 10000;  // 100 MHz

    logic aclk;
    logic aresetn;

    initial begin
        aclk <= 1'b0;
        forever begin
            #(ACLK_PERIOD_PS / 2);
            aclk <= ~aclk;
        end
    end

    initial begin
        aresetn = 1'b0;
        repeat (10) begin
            @(posedge aclk);
        end
        aresetn = 1'b1;
    end

    // Interface
    axi4lite_if axi4lite_if (
        .aclk(aclk),
        .aresetn(aresetn)
    );

    wire [63:0] rdata_w;
    assign axi4lite_if.rdata = rdata_w;
    assign rdata_w[63:32] = 32'h0;

    // DUT
    axilite_to_bram_sdp #(
        .DATA_WIDTH      (32),
        .RAM_DEPTH       (1024),
        .BYTE_WIDTH      (8),
        .WRITE_MODE      ("WRITE_FIRST"),
        .INIT_FILE       (""),
        .EN_REGISTER_MODE(1),
        .AXI_ADDR_WIDTH  (32)
    ) dut (
        .aclk   (aclk),
        .aresetn(aresetn),
        .awaddr (axi4lite_if.awaddr[31:0]),
        .awprot (axi4lite_if.awprot[0]),
        .awvalid(axi4lite_if.awvalid),
        .awready(axi4lite_if.awready),
        .wdata  (axi4lite_if.wdata[31:0]),
        .wstrb  (axi4lite_if.wstrb[3:0]),
        .wvalid (axi4lite_if.wvalid),
        .wready (axi4lite_if.wready),
        .bresp  (axi4lite_if.bresp),
        .bvalid (axi4lite_if.bvalid),
        .bready (axi4lite_if.bready),
        .araddr (axi4lite_if.araddr[31:0]),
        .arprot (axi4lite_if.arprot[0]),
        .arvalid(axi4lite_if.arvalid),
        .arready(axi4lite_if.arready),
        .rdata  (rdata_w[31:0]),
        .rresp  (axi4lite_if.rresp),
        .rvalid (axi4lite_if.rvalid),
        .rready (axi4lite_if.rready)
    );

    initial begin
        uvm_config_db#(virtual axi4lite_if)::set(null, "*", "axi4lite_m_vif", axi4lite_if);
        run_test();
    end

    initial begin
        repeat (10000) @(posedge aclk);
        $finish;
    end

endmodule

`default_nettype wire
