interface axi_if #(
    parameter int ID_WIDTH   = 4,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int USER_WIDTH = 1
) ();

    typedef logic [ID_WIDTH-1:0] id_type;
    typedef logic [ADDR_WIDTH-1:0] addr_type;
    typedef logic [USER_WIDTH-1:0] user_type;


    // =========================================================
    // AW (Write Address) Channel
    // =========================================================
    logic [      ID_WIDTH-1:0] awid;
    logic [    ADDR_WIDTH-1:0] awaddr;
    logic [               7:0] awlen;  // AXI4: 8-bit, AXI3: 4-bit
    logic [               2:0] awsize;
    logic [               1:0] awburst;
    logic                      awlock;  // AXI4: 1-bit, AXI3: 2-bit
    logic [               3:0] awcache;
    logic [               2:0] awprot;
    logic [               3:0] awqos;
    logic [               3:0] awregion;
    logic [    USER_WIDTH-1:0] awuser;
    logic                      awvalid;
    logic                      awready;

    // =========================================================
    // W (Write Data) Channel
    // =========================================================
    logic [    DATA_WIDTH-1:0] wdata;
    logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic                      wlast;
    logic [    USER_WIDTH-1:0] wuser;
    logic                      wvalid;
    logic                      wready;

    // =========================================================
    // B (Write Response) Channel
    // =========================================================
    logic [      ID_WIDTH-1:0] bid;
    logic [               1:0] bresp;
    logic [    USER_WIDTH-1:0] buser;
    logic                      bvalid;
    logic                      bready;

    // =========================================================
    // AR (Read Address) Channel
    // =========================================================
    logic [      ID_WIDTH-1:0] arid;
    logic [    ADDR_WIDTH-1:0] araddr;
    logic [               7:0] arlen;
    logic [               2:0] arsize;
    logic [               1:0] arburst;
    logic                      arlock;
    logic [               3:0] arcache;
    logic [               2:0] arprot;
    logic [               3:0] arqos;
    logic [               3:0] arregion;
    logic [    USER_WIDTH-1:0] aruser;
    logic                      arvalid;
    logic                      arready;

    // =========================================================
    // R (Read Data) Channel
    // =========================================================
    logic [      ID_WIDTH-1:0] rid;
    logic [    DATA_WIDTH-1:0] rdata;
    logic [               1:0] rresp;
    logic                      rlast;
    logic [    USER_WIDTH-1:0] ruser;
    logic                      rvalid;
    logic                      rready;

    // =========================================================
    // Modports (方向定義)
    // =========================================================

    modport master(
        output awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
        input awready,

        output wdata, wstrb, wlast, wuser, wvalid,
        input wready,

        input bid, bresp, buser, bvalid,
        output bready,

        output arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
        input arready,

        input rid, rdata, rresp, rlast, ruser, rvalid,
        output rready
    );

    modport slave(
        input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awqos, awregion, awuser, awvalid,
        output awready,

        input wdata, wstrb, wlast, wuser, wvalid,
        output wready,

        output bid, bresp, buser, bvalid,
        input bready,

        input  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arqos, arregion, aruser, arvalid,
        output arready,

        output rid, rdata, rresp, rlast, ruser, rvalid,
        input rready
    );


endinterface
