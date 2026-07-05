`default_nettype none

module axi_clk_converter #(
    parameter int ID_WIDTH = 4,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_WIDTH = 1,
    parameter int ADDR_FIFO_SIZE = 8,
    parameter int DATA_FIFO_SIZE = 8
) (
    input wire sclk,
    input wire mclk,
    input wire sresetn,
    input wire mresetn,
    axi_if.slave axi_s_if,
    axi_if.master axi_m_if
);

    localparam int AW_WIDTH = ID_WIDTH + ADDR_WIDTH + USER_WIDTH + 29;
    wire [AW_WIDTH-1:0] aw_in_data;
    wire [AW_WIDTH-1:0] aw_out_data;
    wire [AW_WIDTH-1:0] aw_fifo_out_data;
    wire aw_fifo_full;
    wire aw_fifo_empty;
    wire aw_fifo_valid;
    wire aw_skid_ready;

    assign aw_in_data = {
        axi_s_if.awid,
        axi_s_if.awaddr,
        axi_s_if.awlen,
        axi_s_if.awsize,
        axi_s_if.awburst,
        axi_s_if.awlock,
        axi_s_if.awcache,
        axi_s_if.awprot,
        axi_s_if.awqos,
        axi_s_if.awregion,
        axi_s_if.awuser
    };

    assign axi_s_if.awready = !aw_fifo_full;

    axi_fifo_async #(
        .BITWIDTH(AW_WIDTH),
        .FIFO_SIZE(ADDR_FIFO_SIZE),
        .SYNC_FF_DEPTH(2)
    ) fifo_aw (
        .WCLK(sclk),
        .RCLK(mclk),
        .RST_N_WCLK(sresetn),
        .RST_N_RCLK(mresetn),
        .W_EN_WCLK(axi_s_if.awvalid && !aw_fifo_full),
        .DATA_IN_WCLK(aw_in_data),
        .R_EN_RCLK(!aw_fifo_empty && (aw_skid_ready || !aw_fifo_valid)),
        .DATA_OUT_RCLKR(aw_fifo_out_data),
        .DATA_OUT_VALID_RCLKR(aw_fifo_valid),
        .EMPTY_WCLKR(),
        .FULL_WCLKR(aw_fifo_full),
        .ALMOST_FULL_WCLKR(),
        .ALMOST_EMPTY_WCLKR(),
        .FIFO_AVAILABLE_WCLKR(),
        .EMPTY_RCLKR(aw_fifo_empty),
        .FULL_RCLKR(),
        .ALMOST_FULL_RCLKR(),
        .ALMOST_EMPTY_RCLKR(),
        .FIFO_AVAILABLE_RCLKR()
    );

    axi_skid_buffer #(
        .BITWIDTH(AW_WIDTH)
    ) skid_buffer_aw (
        .clk(mclk),
        .rst_n(mresetn),
        .i_data(aw_fifo_out_data),
        .i_valid(aw_fifo_valid),
        .o_ready_r(aw_skid_ready),
        .o_data_r(aw_out_data),
        .o_valid_r(axi_m_if.awvalid),
        .i_ready(axi_m_if.awready)
    );

    assign {
        axi_m_if.awid,
        axi_m_if.awaddr,
        axi_m_if.awlen,
        axi_m_if.awsize,
        axi_m_if.awburst,
        axi_m_if.awlock,
        axi_m_if.awcache,
        axi_m_if.awprot,
        axi_m_if.awqos,
        axi_m_if.awregion,
        axi_m_if.awuser
    } = aw_out_data;

    localparam int W_WIDTH = DATA_WIDTH + (DATA_WIDTH / 8) + USER_WIDTH + 1;
    wire [W_WIDTH-1:0] w_in_data;
    wire [W_WIDTH-1:0] w_out_data;
    wire [W_WIDTH-1:0] w_fifo_out_data;
    wire w_fifo_full;
    wire w_fifo_empty;
    wire w_fifo_valid;
    wire w_skid_ready;

    assign w_in_data = {axi_s_if.wdata, axi_s_if.wstrb, axi_s_if.wlast, axi_s_if.wuser};

    assign axi_s_if.wready = !w_fifo_full;

    axi_fifo_async #(
        .BITWIDTH(W_WIDTH),
        .FIFO_SIZE(DATA_FIFO_SIZE),
        .SYNC_FF_DEPTH(2)
    ) fifo_w (
        .WCLK(sclk),
        .RCLK(mclk),
        .RST_N_WCLK(sresetn),
        .RST_N_RCLK(mresetn),
        .W_EN_WCLK(axi_s_if.wvalid && !w_fifo_full),
        .DATA_IN_WCLK(w_in_data),
        .R_EN_RCLK(!w_fifo_empty && (w_skid_ready || !w_fifo_valid)),
        .DATA_OUT_RCLKR(w_fifo_out_data),
        .DATA_OUT_VALID_RCLKR(w_fifo_valid),
        .EMPTY_WCLKR(),
        .FULL_WCLKR(w_fifo_full),
        .ALMOST_FULL_WCLKR(),
        .ALMOST_EMPTY_WCLKR(),
        .FIFO_AVAILABLE_WCLKR(),
        .EMPTY_RCLKR(w_fifo_empty),
        .FULL_RCLKR(),
        .ALMOST_FULL_RCLKR(),
        .ALMOST_EMPTY_RCLKR(),
        .FIFO_AVAILABLE_RCLKR()
    );

    axi_skid_buffer #(
        .BITWIDTH(W_WIDTH)
    ) skid_buffer_w (
        .clk(mclk),
        .rst_n(mresetn),
        .i_data(w_fifo_out_data),
        .i_valid(w_fifo_valid),
        .o_ready_r(w_skid_ready),
        .o_data_r(w_out_data),
        .o_valid_r(axi_m_if.wvalid),
        .i_ready(axi_m_if.wready)
    );

    assign {axi_m_if.wdata, axi_m_if.wstrb, axi_m_if.wlast, axi_m_if.wuser} = w_out_data;

    localparam int B_WIDTH = ID_WIDTH + USER_WIDTH + 2;
    wire [B_WIDTH-1:0] b_in_data;
    wire [B_WIDTH-1:0] b_out_data;
    wire [B_WIDTH-1:0] b_fifo_out_data;
    wire b_fifo_full;
    wire b_fifo_empty;
    wire b_fifo_valid;
    wire b_skid_ready;

    assign b_in_data = {axi_m_if.bid, axi_m_if.bresp, axi_m_if.buser};

    assign axi_m_if.bready = !b_fifo_full;

    axi_fifo_async #(
        .BITWIDTH(B_WIDTH),
        .FIFO_SIZE(ADDR_FIFO_SIZE),
        .SYNC_FF_DEPTH(2)
    ) fifo_b (
        .WCLK(mclk),
        .RCLK(sclk),
        .RST_N_WCLK(mresetn),
        .RST_N_RCLK(sresetn),
        .W_EN_WCLK(axi_m_if.bvalid && !b_fifo_full),
        .DATA_IN_WCLK(b_in_data),
        .R_EN_RCLK(!b_fifo_empty && (b_skid_ready || !b_fifo_valid)),
        .DATA_OUT_RCLKR(b_fifo_out_data),
        .DATA_OUT_VALID_RCLKR(b_fifo_valid),
        .EMPTY_WCLKR(),
        .FULL_WCLKR(b_fifo_full),
        .ALMOST_FULL_WCLKR(),
        .ALMOST_EMPTY_WCLKR(),
        .FIFO_AVAILABLE_WCLKR(),
        .EMPTY_RCLKR(b_fifo_empty),
        .FULL_RCLKR(),
        .ALMOST_FULL_RCLKR(),
        .ALMOST_EMPTY_RCLKR(),
        .FIFO_AVAILABLE_RCLKR()
    );

    axi_skid_buffer #(
        .BITWIDTH(B_WIDTH)
    ) skid_buffer_b (
        .clk(sclk),
        .rst_n(sresetn),
        .i_data(b_fifo_out_data),
        .i_valid(b_fifo_valid),
        .o_ready_r(b_skid_ready),
        .o_data_r(b_out_data),
        .o_valid_r(axi_s_if.bvalid),
        .i_ready(axi_s_if.bready)
    );

    assign {axi_s_if.bid, axi_s_if.bresp, axi_s_if.buser} = b_out_data;

    localparam int AR_WIDTH = ID_WIDTH + ADDR_WIDTH + USER_WIDTH + 29;
    wire [AR_WIDTH-1:0] ar_in_data;
    wire [AR_WIDTH-1:0] ar_out_data;
    wire [AR_WIDTH-1:0] ar_fifo_out_data;
    wire ar_fifo_full;
    wire ar_fifo_empty;
    wire ar_fifo_valid;
    wire ar_skid_ready;

    assign ar_in_data = {
        axi_s_if.arid,
        axi_s_if.araddr,
        axi_s_if.arlen,
        axi_s_if.arsize,
        axi_s_if.arburst,
        axi_s_if.arlock,
        axi_s_if.arcache,
        axi_s_if.arprot,
        axi_s_if.arqos,
        axi_s_if.arregion,
        axi_s_if.aruser
    };

    assign axi_s_if.arready = !ar_fifo_full;

    axi_fifo_async #(
        .BITWIDTH(AR_WIDTH),
        .FIFO_SIZE(ADDR_FIFO_SIZE),
        .SYNC_FF_DEPTH(2)
    ) fifo_ar (
        .WCLK(sclk),
        .RCLK(mclk),
        .RST_N_WCLK(sresetn),
        .RST_N_RCLK(mresetn),
        .W_EN_WCLK(axi_s_if.arvalid && !ar_fifo_full),
        .DATA_IN_WCLK(ar_in_data),
        .R_EN_RCLK(!ar_fifo_empty && (ar_skid_ready || !ar_fifo_valid)),
        .DATA_OUT_RCLKR(ar_fifo_out_data),
        .DATA_OUT_VALID_RCLKR(ar_fifo_valid),
        .EMPTY_WCLKR(),
        .FULL_WCLKR(ar_fifo_full),
        .ALMOST_FULL_WCLKR(),
        .ALMOST_EMPTY_WCLKR(),
        .FIFO_AVAILABLE_WCLKR(),
        .EMPTY_RCLKR(ar_fifo_empty),
        .FULL_RCLKR(),
        .ALMOST_FULL_RCLKR(),
        .ALMOST_EMPTY_RCLKR(),
        .FIFO_AVAILABLE_RCLKR()
    );

    axi_skid_buffer #(
        .BITWIDTH(AR_WIDTH)
    ) skid_buffer_ar (
        .clk(mclk),
        .rst_n(mresetn),
        .i_data(ar_fifo_out_data),
        .i_valid(ar_fifo_valid),
        .o_ready_r(ar_skid_ready),
        .o_data_r(ar_out_data),
        .o_valid_r(axi_m_if.arvalid),
        .i_ready(axi_m_if.arready)
    );

    assign {
        axi_m_if.arid,
        axi_m_if.araddr,
        axi_m_if.arlen,
        axi_m_if.arsize,
        axi_m_if.arburst,
        axi_m_if.arlock,
        axi_m_if.arcache,
        axi_m_if.arprot,
        axi_m_if.arqos,
        axi_m_if.arregion,
        axi_m_if.aruser
    } = ar_out_data;

    localparam int R_WIDTH = ID_WIDTH + DATA_WIDTH + USER_WIDTH + 3;
    wire [R_WIDTH-1:0] r_in_data;
    wire [R_WIDTH-1:0] r_out_data;
    wire [R_WIDTH-1:0] r_fifo_out_data;
    wire r_fifo_full;
    wire r_fifo_empty;
    wire r_fifo_valid;
    wire r_skid_ready;

    assign r_in_data = {
        axi_m_if.rid, axi_m_if.rdata, axi_m_if.rresp, axi_m_if.rlast, axi_m_if.ruser
    };

    assign axi_m_if.rready = !r_fifo_full;

    axi_fifo_async #(
        .BITWIDTH(R_WIDTH),
        .FIFO_SIZE(DATA_FIFO_SIZE),
        .SYNC_FF_DEPTH(2)
    ) fifo_r (
        .WCLK(mclk),
        .RCLK(sclk),
        .RST_N_WCLK(mresetn),
        .RST_N_RCLK(sresetn),
        .W_EN_WCLK(axi_m_if.rvalid && !r_fifo_full),
        .DATA_IN_WCLK(r_in_data),
        .R_EN_RCLK(!r_fifo_empty && (r_skid_ready || !r_fifo_valid)),
        .DATA_OUT_RCLKR(r_fifo_out_data),
        .DATA_OUT_VALID_RCLKR(r_fifo_valid),
        .EMPTY_WCLKR(),
        .FULL_WCLKR(r_fifo_full),
        .ALMOST_FULL_WCLKR(),
        .ALMOST_EMPTY_WCLKR(),
        .FIFO_AVAILABLE_WCLKR(),
        .EMPTY_RCLKR(r_fifo_empty),
        .FULL_RCLKR(),
        .ALMOST_FULL_RCLKR(),
        .ALMOST_EMPTY_RCLKR(),
        .FIFO_AVAILABLE_RCLKR()
    );

    axi_skid_buffer #(
        .BITWIDTH(R_WIDTH)
    ) skid_buffer_r (
        .clk(sclk),
        .rst_n(sresetn),
        .i_data(r_fifo_out_data),
        .i_valid(r_fifo_valid),
        .o_ready_r(r_skid_ready),
        .o_data_r(r_out_data),
        .o_valid_r(axi_s_if.rvalid),
        .i_ready(axi_s_if.rready)
    );

    assign {
        axi_s_if.rid,
        axi_s_if.rdata,
        axi_s_if.rresp,
        axi_s_if.rlast,
        axi_s_if.ruser
    } = r_out_data;

endmodule

`default_nettype wire
