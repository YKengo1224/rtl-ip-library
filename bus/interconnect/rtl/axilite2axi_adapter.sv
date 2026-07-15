`default_nettype none

module axilite2axi_adapter #(
    parameter int ID_WIDTH   = 4,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_WIDTH = 1
) (
    input wire aclk,
    input wire aresetn,

    // Input: AXI4-Lite (From Master)
    axilite_if.slave s_axilite,
    
    // Output: Full AXI4 (To Crossbar)
    axi_if.master    m_axi
);

    // ---------------------------------------------------------
    // Using SystemVerilog built-in function $clog2
    // If 32-bit (4 Bytes), SIZE_VAL = $clog2(4) = 2 (3'b010)
    // If 64-bit (8 Bytes), SIZE_VAL = $clog2(8) = 3 (3'b011)
    // ---------------------------------------------------------
    localparam logic [2:0] SIZE_VAL = $clog2(DATA_WIDTH / 8);

    // =========================================================
    // AW (Write Address) Channel
    // =========================================================
    assign m_axi.awid     = '0;               // ID not required in AXI4-Lite
    assign m_axi.awaddr   = s_axilite.awaddr; // Direct connection
    assign m_axi.awlen    = 8'h00;            // Burst length is 0 (1 beat per transfer)
    assign m_axi.awsize   = SIZE_VAL;         // Bytes per beat based on data width
    assign m_axi.awburst  = 2'b01;            // INCR (AXI4-Lite default)
    assign m_axi.awlock   = 1'b0;             // Normal access
    assign m_axi.awcache  = 4'b0000;          // Device Non-bufferable
    assign m_axi.awprot   = s_axilite.awprot; // Direct connection
    assign m_axi.awqos    = 4'h0;             // QoS not required
    assign m_axi.awregion = 4'h0;             // Region not required
    assign m_axi.awuser   = '0;               // User extension not required
    assign m_axi.awvalid  = s_axilite.awvalid;
    assign s_axilite.awready = m_axi.awready;

    // =========================================================
    // W (Write Data) Channel
    // =========================================================
    assign m_axi.wdata    = s_axilite.wdata;
    assign m_axi.wstrb    = s_axilite.wstrb;
    assign m_axi.wlast    = 1'b1;             // Always assert last flag for single beat transfer
    assign m_axi.wuser    = '0;
    assign m_axi.wvalid   = s_axilite.wvalid;
    assign s_axilite.wready  = m_axi.wready;

    // =========================================================
    // B (Write Response) Channel
    // =========================================================
    assign s_axilite.bresp   = m_axi.bresp;
    assign s_axilite.bvalid  = m_axi.bvalid;
    assign m_axi.bready   = s_axilite.bready;
    // Note: m_axi.bid and m_axi.buser from crossbar are discarded (left open)

    // =========================================================
    // AR (Read Address) Channel
    // =========================================================
    assign m_axi.arid     = '0;
    assign m_axi.araddr   = s_axilite.araddr;
    assign m_axi.arlen    = 8'h00;
    assign m_axi.arsize   = SIZE_VAL;
    assign m_axi.arburst  = 2'b01;
    assign m_axi.arlock   = 1'b0;
    assign m_axi.arcache  = 4'b0000;
    assign m_axi.arprot   = s_axilite.arprot;
    assign m_axi.arqos    = 4'h0;
    assign m_axi.arregion = 4'h0;
    assign m_axi.aruser   = '0;
    assign m_axi.arvalid  = s_axilite.arvalid;
    assign s_axilite.arready = m_axi.arready;

    // =========================================================
    // R (Read Data) Channel
    // =========================================================
    assign s_axilite.rdata   = m_axi.rdata;
    assign s_axilite.rresp   = m_axi.rresp;
    assign s_axilite.rvalid  = m_axi.rvalid;
    assign m_axi.rready   = s_axilite.rready;
    // Note: m_axi.rid, m_axi.rlast, and m_axi.ruser from crossbar are discarded (left open)

endmodule
`default_nettype wire
