// =============================================================
// AXI4 Full Interface
// =============================================================
// This interface defines a standard AXI4-Full bus.
// It supports burst transactions, ID tagging, and user signals.
// Compatible with Xilinx, ARM, and AMBA AXI4 specifications.
//
// Author : kengo yanagihara
// =============================================================
interface axi_if #(
    parameter int P_A_BITWIDTH = 32,                  // Address width
    parameter int P_D_BITWIDTH = 32,                  // Data width
    parameter int P_S_BITWIDTH = (P_D_BITWIDTH / 8),  // Strobe width
    parameter int P_I_BITWIDTH = 4,                   // ID width
    parameter int P_U_BITWIDTH = 1,                   // USER signal width
    parameter int P_R_BITWIDTH = 4,                   // REGION signal width
    parameter int P_Q_BITWIDTH = 4                    // QOS signal width
);

    // ---------------------------------------------------------
    // Global Signals
    // ---------------------------------------------------------
    logic                    ACLK;  // Global clock
    logic                    ARESETn;  // Active-Low synchronous reset

    // ---------------------------------------------------------
    // Read Address Channel (AR)
    // ---------------------------------------------------------
    logic [P_I_BITWIDTH-1:0] ARID;  // Transaction ID
    logic [P_A_BITWIDTH-1:0] ARADDR;  // Read address
    logic [             7:0] ARLEN;  // Burst length (number of beats - 1)
    logic [             2:0] ARSIZE;  // Burst size (bytes per beat = 2^ARSIZE)
    logic [             1:0] ARBURST;  // Burst type (FIXED, INCR, WRAP)
    logic                    ARLOCK;  // Lock type (atomic access)
    logic [             3:0] ARCACHE;  // Memory type (cacheable, bufferable, etc.)
    logic [             2:0] ARPROT;  // Protection type (privileged, secure, etc.)
    logic [P_Q_BITWIDTH-1:0] ARQOS;  // Quality of service
    logic [P_R_BITWIDTH-1:0] ARREGION;  // Region identifier
    logic [P_U_BITWIDTH-1:0] ARUSER;  // User-defined signal
    logic                    ARVALID;  // Address valid
    logic                    ARREADY;  // Address ready

    // ---------------------------------------------------------
    // Read Data Channel (R)
    // ---------------------------------------------------------
    logic [P_I_BITWIDTH-1:0] RID;  // Transaction ID
    logic [P_D_BITWIDTH-1:0] RDATA;  // Read data
    logic [             1:0] RRESP;  // Read response
    logic                    RLAST;  // Last transfer in burst
    logic [P_U_BITWIDTH-1:0] RUSER;  // User-defined signal
    logic                    RVALID;  // Read valid
    logic                    RREADY;  // Read ready

    // ---------------------------------------------------------
    // Write Address Channel (AW)
    // ---------------------------------------------------------
    logic [P_I_BITWIDTH-1:0] AWID;  // Transaction ID
    logic [P_A_BITWIDTH-1:0] AWADDR;  // Write address
    logic [             7:0] AWLEN;  // Burst length (number of beats - 1)
    logic [             2:0] AWSIZE;  // Burst size (bytes per beat = 2^AWSIZE)
    logic [             1:0] AWBURST;  // Burst type
    logic                    AWLOCK;  // Lock type
    logic [             3:0] AWCACHE;  // Memory type
    logic [             2:0] AWPROT;  // Protection type
    logic [P_Q_BITWIDTH-1:0] AWQOS;  // Quality of service
    logic [P_R_BITWIDTH-1:0] AWREGION;  // Region identifier
    logic [P_U_BITWIDTH-1:0] AWUSER;  // User-defined signal
    logic                    AWVALID;  // Address valid
    logic                    AWREADY;  // Address ready

    // ---------------------------------------------------------
    // Write Data Channel (W)
    // ---------------------------------------------------------
    logic [P_I_BITWIDTH-1:0] WID;  // Transaction ID
    logic [P_D_BITWIDTH-1:0] WDATA;  // Write data
    logic [P_S_BITWIDTH-1:0] WSTRB;  // Write strobe (byte enables)
    logic                    WLAST;  // Last transfer in burst
    logic [P_U_BITWIDTH-1:0] WUSER;  // User-defined signal
    logic                    WVALID;  // Write valid
    logic                    WREADY;  // Write ready

    // ---------------------------------------------------------
    // Write Response Channel (B)
    // ---------------------------------------------------------
    logic [P_I_BITWIDTH-1:0] BID;  // Transaction ID
    logic [             1:0] BRESP;  // Write response
    logic [P_U_BITWIDTH-1:0] BUSER;  // User-defined signal
    logic                    BVALID;  // Write response valid
    logic                    BREADY;  // Write response ready


    // ---------------------------------------------------------
    // function
    // ---------------------------------------------------------
    function automatic logic aw_handshake();
        return AWREADY && AWVALID;
    endfunction

    function automatic logic w_handshake();
        return WREADY && WVALID;
    endfunction

    function automatic logic b_handshake();
        return BREADY && BVALID;
    endfunction

    function automatic logic ar_handshake();
        return ARREADY && ARVALID;
    endfunction

    function automatic logic r_handshake();
        return RREADY && RVALID;
    endfunction
    // ---------------------------------------------------------
    // Master / Slave Modport Definitions
    // ---------------------------------------------------------
    modport master(
        input ACLK, ARESETn,

        // Read Address
        output ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, ARREGION, ARUSER, ARVALID,
        input ARREADY,

        // Read Data
        input RID, RDATA, RRESP, RLAST, RUSER, RVALID,
        output RREADY,

        // Write Address
        output AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, AWREGION, AWUSER, AWVALID,
        input AWREADY,

        // Write Data
        output WID, WDATA, WSTRB, WLAST, WUSER, WVALID,
        input WREADY,

        // Write Response
        input BID, BRESP, BUSER, BVALID,
        output BREADY,

        //function
        import aw_handshake, w_handshake, b_handshake, ar_handshake, r_handshake
    );

    modport slave(
        input ACLK, ARESETn,

        // Read Address
        input  ARID, ARADDR, ARLEN, ARSIZE, ARBURST, ARLOCK, ARCACHE, ARPROT, ARQOS, ARREGION, ARUSER, ARVALID,
        output ARREADY,

        // Read Data
        output RID, RDATA, RRESP, RLAST, RUSER, RVALID,
        input RREADY,

        // Write Address
        input  AWID, AWADDR, AWLEN, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWPROT, AWQOS, AWREGION, AWUSER, AWVALID,
        output AWREADY,

        // Write Data
        input WID, WDATA, WSTRB, WLAST, WUSER, WVALID,
        output WREADY,

        // Write Response
        output BID, BRESP, BUSER, BVALID,
        input BREADY,

        //function
        import aw_handshake, w_handshake, b_handshake, ar_handshake, r_handshake
    );

endinterface
