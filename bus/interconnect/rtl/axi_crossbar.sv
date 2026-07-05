`default_nettype none

module axi_crossbar #(
    parameter int NUM_MASTERS = 2,
    parameter int NUM_SLAVES = 2,
    parameter int ID_WIDTH = 4,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_WIDTH = 1,
    parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] BASE_ADDR = '0,
    parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] ADDR_MASK = '0
) (
    input wire aclk,
    input wire aresetn,

    axi_if.slave  s_axi[NUM_MASTERS],
    axi_if.master m_axi[NUM_SLAVES]
);

    logic [NUM_MASTERS-1:0][ID_WIDTH-1:0]      s_awid;
    logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]    s_awaddr;
    logic [NUM_MASTERS-1:0][7:0]               s_awlen;
    logic [NUM_MASTERS-1:0][2:0]               s_awsize;
    logic [NUM_MASTERS-1:0][1:0]               s_awburst;
    logic [NUM_MASTERS-1:0]                    s_awlock;
    logic [NUM_MASTERS-1:0][3:0]               s_awcache;
    logic [NUM_MASTERS-1:0][2:0]               s_awprot;
    logic [NUM_MASTERS-1:0][3:0]               s_awqos;
    logic [NUM_MASTERS-1:0][3:0]               s_awregion;
    logic [NUM_MASTERS-1:0][USER_WIDTH-1:0]    s_awuser;
    logic [NUM_MASTERS-1:0]                    s_awvalid;
    logic [NUM_MASTERS-1:0]                    s_awready;

    logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0]    s_wdata;
    logic [NUM_MASTERS-1:0][(DATA_WIDTH/8)-1:0] s_wstrb;
    logic [NUM_MASTERS-1:0]                    s_wlast;
    logic [NUM_MASTERS-1:0][USER_WIDTH-1:0]    s_wuser;
    logic [NUM_MASTERS-1:0]                    s_wvalid;
    logic [NUM_MASTERS-1:0]                    s_wready;

    logic [NUM_MASTERS-1:0][ID_WIDTH-1:0]      s_bid;
    logic [NUM_MASTERS-1:0][1:0]               s_bresp;
    logic [NUM_MASTERS-1:0][USER_WIDTH-1:0]    s_buser;
    logic [NUM_MASTERS-1:0]                    s_bvalid;
    logic [NUM_MASTERS-1:0]                    s_bready;

    logic [NUM_MASTERS-1:0][ID_WIDTH-1:0]      s_arid;
    logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]    s_araddr;
    logic [NUM_MASTERS-1:0][7:0]               s_arlen;
    logic [NUM_MASTERS-1:0][2:0]               s_arsize;
    logic [NUM_MASTERS-1:0][1:0]               s_arburst;
    logic [NUM_MASTERS-1:0]                    s_arlock;
    logic [NUM_MASTERS-1:0][3:0]               s_arcache;
    logic [NUM_MASTERS-1:0][2:0]               s_arprot;
    logic [NUM_MASTERS-1:0][3:0]               s_arqos;
    logic [NUM_MASTERS-1:0][3:0]               s_arregion;
    logic [NUM_MASTERS-1:0][USER_WIDTH-1:0]    s_aruser;
    logic [NUM_MASTERS-1:0]                    s_arvalid;
    logic [NUM_MASTERS-1:0]                    s_arready;

    logic [NUM_MASTERS-1:0][ID_WIDTH-1:0]      s_rid;
    logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0]    s_rdata;
    logic [NUM_MASTERS-1:0][1:0]               s_rresp;
    logic [NUM_MASTERS-1:0]                    s_rlast;
    logic [NUM_MASTERS-1:0][USER_WIDTH-1:0]    s_ruser;
    logic [NUM_MASTERS-1:0]                    s_rvalid;
    logic [NUM_MASTERS-1:0]                    s_rready;

    logic [NUM_SLAVES-1:0][ID_WIDTH-1:0]       m_awid;
    logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0]     m_awaddr;
    logic [NUM_SLAVES-1:0][7:0]                m_awlen;
    logic [NUM_SLAVES-1:0][2:0]                m_awsize;
    logic [NUM_SLAVES-1:0][1:0]                m_awburst;
    logic [NUM_SLAVES-1:0]                     m_awlock;
    logic [NUM_SLAVES-1:0][3:0]                m_awcache;
    logic [NUM_SLAVES-1:0][2:0]                m_awprot;
    logic [NUM_SLAVES-1:0][3:0]                m_awqos;
    logic [NUM_SLAVES-1:0][3:0]                m_awregion;
    logic [NUM_SLAVES-1:0][USER_WIDTH-1:0]     m_awuser;
    logic [NUM_SLAVES-1:0]                     m_awvalid;
    logic [NUM_SLAVES-1:0]                     m_awready;

    logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0]     m_wdata;
    logic [NUM_SLAVES-1:0][(DATA_WIDTH/8)-1:0] m_wstrb;
    logic [NUM_SLAVES-1:0]                     m_wlast;
    logic [NUM_SLAVES-1:0][USER_WIDTH-1:0]     m_wuser;
    logic [NUM_SLAVES-1:0]                     m_wvalid;
    logic [NUM_SLAVES-1:0]                     m_wready;

    logic [NUM_SLAVES-1:0][ID_WIDTH-1:0]       m_bid;
    logic [NUM_SLAVES-1:0][1:0]                m_bresp;
    logic [NUM_SLAVES-1:0][USER_WIDTH-1:0]     m_buser;
    logic [NUM_SLAVES-1:0]                     m_bvalid;
    logic [NUM_SLAVES-1:0]                     m_bready;

    logic [NUM_SLAVES-1:0][ID_WIDTH-1:0]       m_arid;
    logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0]     m_araddr;
    logic [NUM_SLAVES-1:0][7:0]                m_arlen;
    logic [NUM_SLAVES-1:0][2:0]                m_arsize;
    logic [NUM_SLAVES-1:0][1:0]                m_arburst;
    logic [NUM_SLAVES-1:0]                     m_arlock;
    logic [NUM_SLAVES-1:0][3:0]                m_arcache;
    logic [NUM_SLAVES-1:0][2:0]                m_arprot;
    logic [NUM_SLAVES-1:0][3:0]                m_arqos;
    logic [NUM_SLAVES-1:0][3:0]                m_arregion;
    logic [NUM_SLAVES-1:0][USER_WIDTH-1:0]     m_aruser;
    logic [NUM_SLAVES-1:0]                     m_arvalid;
    logic [NUM_SLAVES-1:0]                     m_arready;

    logic [NUM_SLAVES-1:0][ID_WIDTH-1:0]       m_rid;
    logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0]     m_rdata;
    logic [NUM_SLAVES-1:0][1:0]                m_rresp;
    logic [NUM_SLAVES-1:0]                     m_rlast;
    logic [NUM_SLAVES-1:0][USER_WIDTH-1:0]     m_ruser;
    logic [NUM_SLAVES-1:0]                     m_rvalid;
    logic [NUM_SLAVES-1:0]                     m_rready;

    genvar i_m, i_s;
    generate
        for (i_m = 0; i_m < NUM_MASTERS; i_m++) begin : gen_master_signals
            always_comb begin
                s_awid[i_m]     = s_axi[i_m].awid;
                s_awaddr[i_m]   = s_axi[i_m].awaddr;
                s_awlen[i_m]    = s_axi[i_m].awlen;
                s_awsize[i_m]   = s_axi[i_m].awsize;
                s_awburst[i_m]  = s_axi[i_m].awburst;
                s_awlock[i_m]   = s_axi[i_m].awlock;
                s_awcache[i_m]  = s_axi[i_m].awcache;
                s_awprot[i_m]   = s_axi[i_m].awprot;
                s_awqos[i_m]    = s_axi[i_m].awqos;
                s_awregion[i_m] = s_axi[i_m].awregion;
                s_awuser[i_m]   = s_axi[i_m].awuser;
                s_awvalid[i_m]  = s_axi[i_m].awvalid;
                
                s_wdata[i_m]    = s_axi[i_m].wdata;
                s_wstrb[i_m]    = s_axi[i_m].wstrb;
                s_wlast[i_m]    = s_axi[i_m].wlast;
                s_wuser[i_m]    = s_axi[i_m].wuser;
                s_wvalid[i_m]   = s_axi[i_m].wvalid;
                
                s_bready[i_m]   = s_axi[i_m].bready;

                s_arid[i_m]     = s_axi[i_m].arid;
                s_araddr[i_m]   = s_axi[i_m].araddr;
                s_arlen[i_m]    = s_axi[i_m].arlen;
                s_arsize[i_m]   = s_axi[i_m].arsize;
                s_arburst[i_m]  = s_axi[i_m].arburst;
                s_arlock[i_m]   = s_axi[i_m].arlock;
                s_arcache[i_m]  = s_axi[i_m].arcache;
                s_arprot[i_m]   = s_axi[i_m].arprot;
                s_arqos[i_m]    = s_axi[i_m].arqos;
                s_arregion[i_m] = s_axi[i_m].arregion;
                s_aruser[i_m]   = s_axi[i_m].aruser;
                s_arvalid[i_m]  = s_axi[i_m].arvalid;
                
                s_rready[i_m]   = s_axi[i_m].rready;

                s_axi[i_m].awready = s_awready[i_m];
                s_axi[i_m].wready  = s_wready[i_m];
                s_axi[i_m].bid     = s_bid[i_m];
                s_axi[i_m].bresp   = s_bresp[i_m];
                s_axi[i_m].buser   = s_buser[i_m];
                s_axi[i_m].bvalid  = s_bvalid[i_m];
                s_axi[i_m].arready = s_arready[i_m];
                s_axi[i_m].rid     = s_rid[i_m];
                s_axi[i_m].rdata   = s_rdata[i_m];
                s_axi[i_m].rresp   = s_rresp[i_m];
                s_axi[i_m].rlast   = s_rlast[i_m];
                s_axi[i_m].ruser   = s_ruser[i_m];
                s_axi[i_m].rvalid  = s_rvalid[i_m];
            end
        end

        for (i_s = 0; i_s < NUM_SLAVES; i_s++) begin : gen_slave_signals
            always_comb begin
                m_awready[i_s]  = m_axi[i_s].awready;
                m_wready[i_s]   = m_axi[i_s].wready;
                
                m_bid[i_s]      = m_axi[i_s].bid;
                m_bresp[i_s]    = m_axi[i_s].bresp;
                m_buser[i_s]    = m_axi[i_s].buser;
                m_bvalid[i_s]   = m_axi[i_s].bvalid;
                
                m_arready[i_s]  = m_axi[i_s].arready;
                
                m_rid[i_s]      = m_axi[i_s].rid;
                m_rdata[i_s]    = m_axi[i_s].rdata;
                m_rresp[i_s]    = m_axi[i_s].rresp;
                m_rlast[i_s]    = m_axi[i_s].rlast;
                m_ruser[i_s]    = m_axi[i_s].ruser;
                m_rvalid[i_s]   = m_axi[i_s].rvalid;

                m_axi[i_s].awid     = m_awid[i_s];
                m_axi[i_s].awaddr   = m_awaddr[i_s];
                m_axi[i_s].awlen    = m_awlen[i_s];
                m_axi[i_s].awsize   = m_awsize[i_s];
                m_axi[i_s].awburst  = m_awburst[i_s];
                m_axi[i_s].awlock   = m_awlock[i_s];
                m_axi[i_s].awcache  = m_awcache[i_s];
                m_axi[i_s].awprot   = m_awprot[i_s];
                m_axi[i_s].awqos    = m_awqos[i_s];
                m_axi[i_s].awregion = m_awregion[i_s];
                m_axi[i_s].awuser   = m_awuser[i_s];
                m_axi[i_s].awvalid  = m_awvalid[i_s];
                
                m_axi[i_s].wdata    = m_wdata[i_s];
                m_axi[i_s].wstrb    = m_wstrb[i_s];
                m_axi[i_s].wlast    = m_wlast[i_s];
                m_axi[i_s].wuser    = m_wuser[i_s];
                m_axi[i_s].wvalid   = m_wvalid[i_s];
                
                m_axi[i_s].bready   = m_bready[i_s];

                m_axi[i_s].arid     = m_arid[i_s];
                m_axi[i_s].araddr   = m_araddr[i_s];
                m_axi[i_s].arlen    = m_arlen[i_s];
                m_axi[i_s].arsize   = m_arsize[i_s];
                m_axi[i_s].arburst  = m_arburst[i_s];
                m_axi[i_s].arlock   = m_arlock[i_s];
                m_axi[i_s].arcache  = m_arcache[i_s];
                m_axi[i_s].arprot   = m_arprot[i_s];
                m_axi[i_s].arqos    = m_arqos[i_s];
                m_axi[i_s].arregion = m_arregion[i_s];
                m_axi[i_s].aruser   = m_aruser[i_s];
                m_axi[i_s].arvalid  = m_arvalid[i_s];
                
                m_axi[i_s].rready   = m_rready[i_s];
            end
        end
    endgenerate

    logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] aw_gnt;
    logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] ar_gnt;

    logic [NUM_SLAVES-1:0]                  b_handshake_done;
    logic [NUM_SLAVES-1:0]                  r_handshake_done;

    always_comb begin
        for (int i = 0; i < NUM_SLAVES; i++) begin
            b_handshake_done[i] = m_bvalid[i] & m_bready[i];
            r_handshake_done[i] = m_rvalid[i] & m_rready[i] & m_rlast[i];
        end
    end

    axi_crossbar_addr #(
        .NUM_MASTERS(NUM_MASTERS),
        .NUM_SLAVES (NUM_SLAVES),
        .ADDR_WIDTH (ADDR_WIDTH),
        .USER_WIDTH (USER_WIDTH),
        .BASE_ADDR  (BASE_ADDR),
        .ADDR_MASK  (ADDR_MASK)
    ) u_crossbar_aw (
        .aclk        (aclk),
        .aresetn     (aresetn),
        .s_addr      (s_awaddr),
        .s_valid     (s_awvalid),
        .s_ready     (s_awready),
        .m_addr      (m_awaddr),
        .m_valid     (m_awvalid),
        .m_ready     (m_awready),
        .i_handshake_done (b_handshake_done),
        .o_gnt_matrix(aw_gnt)
    );

    always_comb begin
        for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
            m_wdata[i_s]    = '0;
            m_wstrb[i_s]    = '0;
            m_wlast[i_s]    = 1'b0;
            m_wuser[i_s]    = '0;
            m_wvalid[i_s]   = 1'b0;

            m_awid[i_s]     = '0;
            m_awlen[i_s]    = '0;
            m_awsize[i_s]   = '0;
            m_awburst[i_s]  = '0;
            m_awlock[i_s]   = 1'b0;
            m_awcache[i_s]  = '0;
            m_awprot[i_s]   = '0;
            m_awqos[i_s]    = '0;
            m_awregion[i_s] = '0;
            m_awuser[i_s]   = '0;

            for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
                if (aw_gnt[i_s][i_m]) begin
                    m_wdata[i_s]    = s_wdata[i_m];
                    m_wstrb[i_s]    = s_wstrb[i_m];
                    m_wlast[i_s]    = s_wlast[i_m];
                    m_wuser[i_s]    = s_wuser[i_m];
                    m_wvalid[i_s]   = s_wvalid[i_m];

                    m_awid[i_s]     = s_awid[i_m];
                    m_awlen[i_s]    = s_awlen[i_m];
                    m_awsize[i_s]   = s_awsize[i_m];
                    m_awburst[i_s]  = s_awburst[i_m];
                    m_awlock[i_s]   = s_awlock[i_m];
                    m_awcache[i_s]  = s_awcache[i_m];
                    m_awprot[i_s]   = s_awprot[i_m];
                    m_awqos[i_s]    = s_awqos[i_m];
                    m_awregion[i_s] = s_awregion[i_m];
                    m_awuser[i_s]   = s_awuser[i_m];
                end
            end
        end

        for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
            s_wready[i_m] = 1'b0;
            for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
                if (aw_gnt[i_s][i_m]) begin
                    s_wready[i_m] = m_wready[i_s];
                end
            end
        end
    end

    always_comb begin
        for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
            s_bid[i_m]    = '0;
            s_bresp[i_m]  = '0;
            s_buser[i_m]  = '0;
            s_bvalid[i_m] = 1'b0;

            for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
                if (aw_gnt[i_s][i_m]) begin
                    s_bid[i_m]    = m_bid[i_s];
                    s_bresp[i_m]  = m_bresp[i_s];
                    s_buser[i_m]  = m_buser[i_s];
                    s_bvalid[i_m] = m_bvalid[i_s];
                end
            end
        end

        for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
            m_bready[i_s] = 1'b0;
            for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
                if (aw_gnt[i_s][i_m]) begin
                    m_bready[i_s] = s_bready[i_m];
                end
            end
        end
    end

    axi_crossbar_addr #(
        .NUM_MASTERS(NUM_MASTERS),
        .NUM_SLAVES (NUM_SLAVES),
        .ADDR_WIDTH (ADDR_WIDTH),
        .USER_WIDTH (USER_WIDTH),
        .BASE_ADDR  (BASE_ADDR),
        .ADDR_MASK  (ADDR_MASK)
    ) u_crossbar_ar (
        .aclk        (aclk),
        .aresetn     (aresetn),
        .s_addr      (s_araddr),
        .s_valid     (s_arvalid),
        .s_ready     (s_arready),
        .m_addr      (m_araddr),
        .m_valid     (m_arvalid),
        .m_ready     (m_arready),
        .i_handshake_done (r_handshake_done),
        .o_gnt_matrix(ar_gnt)
    );

    always_comb begin
        for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
            m_arid[i_s]     = '0;
            m_arlen[i_s]    = '0;
            m_arsize[i_s]   = '0;
            m_arburst[i_s]  = '0;
            m_arlock[i_s]   = 1'b0;
            m_arcache[i_s]  = '0;
            m_arprot[i_s]   = '0;
            m_arqos[i_s]    = '0;
            m_arregion[i_s] = '0;
            m_aruser[i_s]   = '0;

            for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
                if (ar_gnt[i_s][i_m]) begin
                    m_arid[i_s]     = s_arid[i_m];
                    m_arlen[i_s]    = s_arlen[i_m];
                    m_arsize[i_s]   = s_arsize[i_m];
                    m_arburst[i_s]  = s_arburst[i_m];
                    m_arlock[i_s]   = s_arlock[i_m];
                    m_arcache[i_s]  = s_arcache[i_m];
                    m_arprot[i_s]   = s_arprot[i_m];
                    m_arqos[i_s]    = s_arqos[i_m];
                    m_arregion[i_s] = s_arregion[i_m];
                    m_aruser[i_s]   = s_aruser[i_m];
                end
            end
        end

        for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
            s_rid[i_m]    = '0;
            s_rdata[i_m]  = '0;
            s_rresp[i_m]  = '0;
            s_rlast[i_m]  = 1'b0;
            s_ruser[i_m]  = '0;
            s_rvalid[i_m] = 1'b0;

            for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
                if (ar_gnt[i_s][i_m]) begin
                    s_rid[i_m]    = m_rid[i_s];
                    s_rdata[i_m]  = m_rdata[i_s];
                    s_rresp[i_m]  = m_rresp[i_s];
                    s_rlast[i_m]  = m_rlast[i_s];
                    s_ruser[i_m]  = m_ruser[i_s];
                    s_rvalid[i_m] = m_rvalid[i_s];
                end
            end
        end

        for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
            m_rready[i_s] = 1'b0;
            for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
                if (ar_gnt[i_s][i_m]) begin
                    m_rready[i_s] = s_rready[i_m];
                end
            end
        end
    end

endmodule
`default_nettype wire
