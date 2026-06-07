`default_nettype none

module uart_axilite_slv #(
    parameter int ADDR_BITWIDTH = 32,
    parameter int DATA_BITWIDTH = 32,
    parameter int VARID_ADDR_BITWIDTH = 8

) (
    input wire aclk,
    input wire aresetn,

    //====================================================
    // USER Ports
    //====================================================
    // __INSERT_PORTS__
    //====================================================
    // AXI4-Lite Ports
    //====================================================
    //AW Channel
    input  wire  [   ADDR_BITWIDTH -1:0] awaddr,
    input  wire                          awprot,
    input  wire                          awvalid,
    output logic                         awready,
    //W Channel
    input  wire  [   DATA_BITWIDTH -1:0] wdata,
    input  wire  [(ADDR_BITWIDTH/8)-1:0] wstrb,
    input  wire                          wvalid,
    output logic                         wready,
    //B Channel
    output reg   [                  1:0] bresp,
    output reg                           bvalid,
    input  wire                          bready,
    //AR Channel
    input  wire  [   ADDR_BITWIDTH -1:0] araddr,
    input  wire                          arprot,
    input  wire                          arvalid,
    output reg                           arready,
    //R Channel
    output reg   [   DATA_BITWIDTH -1:0] rdata,
    output logic [                  1:0] rresp,
    output reg                           rvalid,
    input  wire                          rready

);


    //====================================================
    // Write Transaction
    //====================================================

    logic                         aw_trans_done;
    reg                           aw_trans_done_hold_r;
    logic                         w_trans_done;
    reg                           w_trans_done_hold_r;

    reg   [   ADDR_BITWIDTH -1:0] awaddr_hold_r;
    reg                           awprot_hold_r;
    reg   [   DATA_BITWIDTH -1:0] wdata_hold_r;
    reg   [(ADDR_BITWIDTH/8)-1:0] wstrb_hold_r;

    logic [    ADDR_BITWIDTH-1:0] target_awaddr;
    logic [    DATA_BITWIDTH-1:0] target_wdata;
    logic [(DATA_BITWIDTH/8)-1:0] target_wstrb;

    logic                         aw_accepted;
    logic                         w_accepted;
    logic                         write_exec;


    assign aw_trans_done = awvalid && awready;
    assign w_trans_done = wvalid && wready;

    assign aw_accepted = (aw_trans_done || aw_trans_done_hold_r);
    assign w_accepted = (w_trans_done || w_trans_done_hold_r);
    assign write_exec = aw_accepted && w_accepted;


    //##########
    //AW Channel
    //##########
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            aw_trans_done_hold_r <= 1'b0;
        end else if (aw_trans_done && !w_accepted) begin
            aw_trans_done_hold_r <= 1'b1;
        end else if (w_accepted) begin
            aw_trans_done_hold_r <= 1'b0;
        end
    end
    assign awready = !aw_trans_done_hold_r && !bvalid;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            awaddr_hold_r <= '0;
            awprot_hold_r <= '0;
        end else if (aw_trans_done) begin
            awaddr_hold_r <= awaddr;
            awprot_hold_r <= awprot;
        end else if (write_exec) begin
            awaddr_hold_r <= '0;
            awprot_hold_r <= '0;
        end
    end
    assign target_awaddr = aw_trans_done_hold_r ? awaddr_hold_r : awaddr;

    //##########
    //W Channel
    //##########
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            w_trans_done_hold_r <= 1'b0;
        end else if (w_trans_done && !aw_accepted) begin
            w_trans_done_hold_r <= 1'b1;
        end else if (aw_accepted) begin
            w_trans_done_hold_r <= 1'b0;
        end
    end
    assign wready = !w_trans_done_hold_r && !bvalid;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            wdata_hold_r <= '0;
            wstrb_hold_r <= '0;
        end else if (w_trans_done) begin
            wdata_hold_r <= wdata;
            wstrb_hold_r <= wstrb;
        end else if (write_exec) begin
            wdata_hold_r <= '0;
            wstrb_hold_r <= '0;
        end
    end
    assign target_wdata = w_trans_done_hold_r ? wdata_hold_r : wdata;
    assign target_wstrb = w_trans_done_hold_r ? wstrb_hold_r : wstrb;

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
    // reg                           w_trans_done_hold_r;

    assign ar_trans_done = arvalid && arready;
    assign r_trans_done = rvalid && rready;
    assign read_exec = ar_trans_done;

    assign rresp = 2'b0;
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            arready <= 1'b1;
            rvalid  <= 1'b0;
        end else if (ar_trans_done) begin
            arready <= 1'b0;
            rvalid  <= 1'b1;
        end else if (r_trans_done) begin
            arready <= 1'b1;
            rvalid  <= 1'b0;
        end
    end


    //====================================================
    // USER_LOGIC
    //====================================================

    // __INSERT_DECLARATIONS__

    // __INSERT_DECODE__

    // __INSERT_OTHER_COMB_LOGIC__

    // __INSERT_WRITE_LOGIC__


    //Read logic
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rdata <= '0;
        end else if (read_exec) begin
            case (araddr[VARID_ADDR_BITWIDTH-1:0])
                // __INSERT_READ_LOGIC__
                default: begin
                end
            endcase
        end
    end

endmodule


`default_nettype wire
