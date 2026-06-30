`default_nettype none

module axilite_to_bram_sdp #(
    parameter int DATA_WIDTH       = 32,
    parameter int RAM_DEPTH        = 1024,
    parameter int BYTE_WIDTH       = 8,
    parameter     WRITE_MODE       = "WRITE_FIRST",  // "WRITE_FIRST", "READ_FIRST"
    parameter     INIT_FILE        = "",             // Initialization Hex file path
    parameter int EN_REGISTER_MODE = 0,              // Enable output register (0 or 1)
    parameter int AXI_ADDR_WIDTH   = 32              // AXI address width
) (
    //====================================================
    // AXI4-Lite Ports
    //====================================================
    input  wire                          aclk,
    input  wire                          aresetn,
    //AW Channel
    input  wire  [  AXI_ADDR_WIDTH -1:0] awaddr,
    input  wire                          awprot,
    input  wire                          awvalid,
    output logic                         awready,
    //W Channel
    input  wire  [      DATA_WIDTH -1:0] wdata,
    input  wire  [(DATA_WIDTH/BYTE_WIDTH)-1:0] wstrb,
    input  wire                          wvalid,
    output logic                         wready,
    //B Channel
    output reg   [                  1:0] bresp,
    output reg                           bvalid,
    input  wire                          bready,
    //AR Channel
    input  wire  [  AXI_ADDR_WIDTH -1:0] araddr,
    input  wire                          arprot,
    input  wire                          arvalid,
    output reg                           arready,
    //R Channel
    output reg   [      DATA_WIDTH -1:0] rdata,
    output logic [                  1:0] rresp,
    output reg                           rvalid,
    input  wire                          rready
);

    localparam int ADDR_WIDTH = $clog2(RAM_DEPTH);
    localparam int ADDR_SHIFT = (DATA_WIDTH == 64) ? 3 :
                                (DATA_WIDTH == 32) ? 2 :
                                (DATA_WIDTH == 16) ? 1 : 0;

    //====================================================
    // Write Transaction
    //====================================================

    logic                         aw_trans_done;
    reg                           aw_trans_done_hold_aclkr;
    logic                         w_trans_done;
    reg                           w_trans_done_hold_aclkr;

    reg   [  AXI_ADDR_WIDTH -1:0] awaddr_hold_aclkr;
    reg                           awprot_hold_aclkr;
    reg   [      DATA_WIDTH -1:0] wdata_hold_aclkr;
    reg   [(DATA_WIDTH/BYTE_WIDTH)-1:0] wstrb_hold_aclkr;

    logic [  AXI_ADDR_WIDTH -1:0] target_awaddr;
    logic [      DATA_WIDTH -1:0] target_wdata;
    logic [(DATA_WIDTH/BYTE_WIDTH)-1:0] target_wstrb;

    logic                         aw_accepted;
    logic                         w_accepted;
    logic                         write_exec;


    assign aw_trans_done = awvalid && awready;
    assign w_trans_done = wvalid && wready;

    assign aw_accepted = (aw_trans_done || aw_trans_done_hold_aclkr);
    assign w_accepted = (w_trans_done || w_trans_done_hold_aclkr);
    assign write_exec = aw_accepted && w_accepted;


    //##########
    //AW Channel
    //##########
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            aw_trans_done_hold_aclkr <= 1'b0;
        end else if (aw_trans_done && !w_accepted) begin
            aw_trans_done_hold_aclkr <= 1'b1;
        end else if (w_accepted) begin
            aw_trans_done_hold_aclkr <= 1'b0;
        end
    end
    assign awready = !aw_trans_done_hold_aclkr && !bvalid;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            awaddr_hold_aclkr <= '0;
            awprot_hold_aclkr <= '0;
        end else if (aw_trans_done) begin
            awaddr_hold_aclkr <= awaddr;
            awprot_hold_aclkr <= awprot;
        end else if (write_exec) begin
            awaddr_hold_aclkr <= '0;
            awprot_hold_aclkr <= '0;
        end
    end
    assign target_awaddr = aw_trans_done_hold_aclkr ? awaddr_hold_aclkr : awaddr;

    //##########
    //W Channel
    //##########
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            w_trans_done_hold_aclkr <= 1'b0;
        end else if (w_trans_done && !aw_accepted) begin
            w_trans_done_hold_aclkr <= 1'b1;
        end else if (aw_accepted) begin
            w_trans_done_hold_aclkr <= 1'b0;
        end
    end
    assign wready = !w_trans_done_hold_aclkr && !bvalid;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            wdata_hold_aclkr <= '0;
            wstrb_hold_aclkr <= '0;
        end else if (w_trans_done) begin
            wdata_hold_aclkr <= wdata;
            wstrb_hold_aclkr <= wstrb;
        end else if (write_exec) begin
            wdata_hold_aclkr <= '0;
            wstrb_hold_aclkr <= '0;
        end
    end
    assign target_wdata = w_trans_done_hold_aclkr ? wdata_hold_aclkr : wdata;
    assign target_wstrb = w_trans_done_hold_aclkr ? wstrb_hold_aclkr : wstrb;

    //##########
    //B Channel
    //##########
    assign bresp = 2'b00;  //OKAY  
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            bvalid <= 1'b0;
        end else if (write_exec) begin
            bvalid <= 1'b1;
        end else if (bready) begin
            bvalid <= 1'b0;
        end
    end


    //====================================================
    // Read Transaction
    //====================================================
    logic ar_trans_done;
    logic r_trans_done;
    logic read_exec;

    assign ar_trans_done = arvalid && arready;
    assign r_trans_done = rvalid && rready;
    assign read_exec = ar_trans_done;

    assign rresp = 2'b0;

    // Read pipeline control to handle EN_REGISTER_MODE latency
    reg [1:0] read_pipe;
    reg       rvalid_r;
    reg [ADDR_WIDTH-1:0] araddr_r;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            arready   <= 1'b1;
            rvalid    <= 1'b0;
            read_pipe <= 2'b00;
            araddr_r  <= '0;
        end else begin
            // Address Acceptance
            if (ar_trans_done) begin
                arready  <= 1'b0;
                araddr_r <= araddr[ADDR_WIDTH - 1 + ADDR_SHIFT : ADDR_SHIFT];
                if (EN_REGISTER_MODE == 1) begin
                    read_pipe <= 2'b10; // 2 cycles latency total to DO
                end else begin
                    read_pipe <= 2'b01; // 1 cycle latency total to DO
                end
            end

            // Pipeline Shift
            if (read_pipe != 2'b00) begin
                if (read_pipe == 2'b01) begin
                    read_pipe <= 2'b00;
                    rvalid    <= 1'b1;
                end else begin
                    read_pipe <= read_pipe >> 1;
                end
            end

            // Read Completion
            if (rvalid && rready) begin
                rvalid  <= 1'b0;
                arready <= 1'b1;
            end
        end
    end

    // Address multiplexer for BRAM
    logic [ADDR_WIDTH-1:0] bram_rdaddr;
    assign bram_rdaddr = ar_trans_done ? araddr[ADDR_WIDTH - 1 + ADDR_SHIFT : ADDR_SHIFT] : araddr_r;


    bram_sdp #(
        .DATA_WIDTH      (DATA_WIDTH),
        .RAM_DEPTH       (RAM_DEPTH),
        .BYTE_WIDTH      (BYTE_WIDTH),
        .WRITE_MODE      (WRITE_MODE),
        .INIT_FILE       (INIT_FILE),
        .EN_REGISTER_MODE(EN_REGISTER_MODE)
    ) bram_inst (
        .WRCLK (aclk),
        .WREN  (write_exec),
        .WE    (target_wstrb),
        .WRADDR(target_awaddr[ADDR_WIDTH - 1 + ADDR_SHIFT : ADDR_SHIFT]),
        .DI    (target_wdata),

        .RDCLK (aclk),
        .RST   (!aresetn),
        .RDEN  (read_exec),
        .REGCE (1'b1),
        .RDADDR(bram_rdaddr),
        .DO    (rdata)
    );

endmodule
`default_nettype wire
