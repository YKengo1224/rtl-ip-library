interface axi4lite_if (
    input wire aclk,
    input wire aresetn
);
    logic        awvalid = '0;
    logic        awready = '0;
    logic [15:0] awid = '0;
    logic [63:0] awaddr = '0;
    logic [ 2:0] awprot = '0;
    logic        wvalid = '0;
    logic        wready = '0;
    logic [63:0] wdata = '0;
    logic [ 7:0] wstrb = '0;
    logic        bvalid = '0;
    logic        bready = '0;
    logic [15:0] bid = '0;
    logic [ 1:0] bresp = '0;
    logic        arvalid = '0;
    logic        arready = '0;
    logic [63:0] araddr = '0;
    logic [15:0] arid = '0;
    logic [ 2:0] arprot = '0;
    logic        rvalid = '0;
    logic        rready = '0;
    logic [15:0] rid = '0;
    logic [ 1:0] rresp = '0;
    logic [63:0] rdata;


endinterface
