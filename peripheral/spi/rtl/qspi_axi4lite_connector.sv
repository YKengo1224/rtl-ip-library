//-----------------------------------------------------------------------------
// Title         : QSPI
// Project       : rtl-ip-library
//-----------------------------------------------------------------------------
// File          : qspi_axi4lite_connector.sv
// Author        : kengo yanagihara
// Created       : 28.03.2026
// Last modified : 2026/03/28
//-----------------------------------------------------------------------------
// Description :
// Module for connecting the axi4lite interface
//-----------------------------------------------------------------------------
// Copyright (c)  Kengo Yanagihara
//
//------------------------------------------------------------------------------
// Modification history:
// 28.03.2026 : created
//-----------------------------------------------------------------------------


`default_nettype none
module qspi_axi4lite_connector #(
    parameter int ID_WIDTH      = 0,
    parameter int ADDRESS_WIDTH = 16,
    parameter int BUS_WIDTH     = 32
) (

    interface s_axi_if,


    input  wire                      awvalid,
    output logic                     awready,
    input  wire  [     ID_WIDTH-1:0] awid,
    input  wire  [ADDRESS_WIDTH-1:0] awaddr,
    input  wire  [              2:0] awprot,
    input  wire                      wvalid,
    output logic                     wready,
    input  wire  [    BUS_WIDTH-1:0] wdata,
    input  wire  [  BUS_WIDTH/8-1:0] wstrb,
    output logic                     bvalid,
    input  wire                      bready,
    output logic [     ID_WIDTH-1:0] bid,
    output logic [              1:0] bresp,
    input  wire                      arvalid,
    output logic                     arready,
    input  wire  [ADDRESS_WIDTH-1:0] araddr,
    input  wire  [     ID_WIDTH-1:0] arid,
    input  wire  [              2:0] arprot,
    output logic                     rvalid,
    input  wire                      rready,
    output logic [     ID_WIDTH-1:0] rid,
    output logic [              1:0] rresp,
    output logic [    BUS_WIDTH-1:0] rdata
);

    assign s_axi_if.awvalid = awvalid;
    assign awready          = s_axi_if.awready;
    assign s_axi_if.awid    = awid;
    assign s_axi_if.awaddr  = awaddr;
    assign s_axi_if.awprot  = awprot;
    assign s_axi_if.wvalid  = wvalid;
    assign wready           = s_axi_if.wready;
    assign s_axi_if.wdata   = wdata;
    assign s_axi_if.wstrb   = wstrb;
    assign bvalid           = s_axi_if.bvalid;
    assign s_axi_if.bready  = bready;
    assign bid              = s_axi_if.bid;
    assign bresp            = s_axi_if.bresp;
    assign s_axi_if.arvalid = arvalid;
    assign arready          = s_axi_if.arready;
    assign s_axi_if.araddr  = araddr;
    assign s_axi_if.arid    = arid;
    assign s_axi_if.arprot  = arprot;
    assign rvalid           = s_axi_if.rvalid;
    assign s_axi_if.rready  = rready;
    assign rid              = s_axi_if.rid;
    assign rresp            = s_axi_if.rresp;
    assign rdata            = s_axi_if.rdata;

endmodule
`default_nettype wire
