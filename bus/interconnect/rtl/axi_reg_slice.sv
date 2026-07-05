`default_nettype none

module axi_reg_slice #(
    parameter int ID_WIDTH   = 4,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_WIDTH = 1
) (
    input wire    aclk,
    input wire    aresetn,
    axi_if.slave  axi_s_if,
    axi_if.master axi_m_if
);

    localparam int AW_WIDTH = ID_WIDTH + ADDR_WIDTH + USER_WIDTH + 29;
    wire [AW_WIDTH-1:0] aw_in_data;
    wire [AW_WIDTH-1:0] aw_out_data;

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

    axi_skid_buffer #(.BITWIDTH(AW_WIDTH)) skid_buffer_aw (
        .clk(aclk),
        .rst_n(aresetn),
        .i_data(aw_in_data),
        .i_valid(axi_s_if.awvalid),
        .o_ready_r(axi_s_if.awready),
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

    assign w_in_data = {
        axi_s_if.wdata,
        axi_s_if.wstrb,
        axi_s_if.wlast,
        axi_s_if.wuser
    };

    axi_skid_buffer #(.BITWIDTH(W_WIDTH)) skid_buffer_w (
        .clk(aclk),
        .rst_n(aresetn),
        .i_data(w_in_data),
        .i_valid(axi_s_if.wvalid),
        .o_ready_r(axi_s_if.wready),
        .o_data_r(w_out_data),
        .o_valid_r(axi_m_if.wvalid),
        .i_ready(axi_m_if.wready)
    );

    assign {
        axi_m_if.wdata,
        axi_m_if.wstrb,
        axi_m_if.wlast,
        axi_m_if.wuser
    } = w_out_data;

    localparam int B_WIDTH = ID_WIDTH + USER_WIDTH + 2;
    wire [B_WIDTH-1:0] b_in_data;
    wire [B_WIDTH-1:0] b_out_data;

    assign b_in_data = {
        axi_m_if.bid,
        axi_m_if.bresp,
        axi_m_if.buser
    };

    axi_skid_buffer #(.BITWIDTH(B_WIDTH)) skid_buffer_b (
        .clk(aclk),
        .rst_n(aresetn),
        .i_data(b_in_data),
        .i_valid(axi_m_if.bvalid),
        .o_ready_r(axi_m_if.bready),
        .o_data_r(b_out_data),
        .o_valid_r(axi_s_if.bvalid),
        .i_ready(axi_s_if.bready)
    );

    assign {
        axi_s_if.bid,
        axi_s_if.bresp,
        axi_s_if.buser
    } = b_out_data;

    localparam int AR_WIDTH = ID_WIDTH + ADDR_WIDTH + USER_WIDTH + 29;
    wire [AR_WIDTH-1:0] ar_in_data;
    wire [AR_WIDTH-1:0] ar_out_data;

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

    axi_skid_buffer #(.BITWIDTH(AR_WIDTH)) skid_buffer_ar (
        .clk(aclk),
        .rst_n(aresetn),
        .i_data(ar_in_data),
        .i_valid(axi_s_if.arvalid),
        .o_ready_r(axi_s_if.arready),
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

    assign r_in_data = {
        axi_m_if.rid,
        axi_m_if.rdata,
        axi_m_if.rresp,
        axi_m_if.rlast,
        axi_m_if.ruser
    };

    axi_skid_buffer #(.BITWIDTH(R_WIDTH)) skid_buffer_r (
        .clk(aclk),
        .rst_n(aresetn),
        .i_data(r_in_data),
        .i_valid(axi_m_if.rvalid),
        .o_ready_r(axi_m_if.rready),
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
