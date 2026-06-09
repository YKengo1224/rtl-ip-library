`default_nettype none
module uart_top #(
    parameter int ADDR_BITWIDTH = 32,
    parameter int DATA_BITWIDTH = 32,
    parameter int VARID_ADDR_BITWIDTH = 8
) (
    input  wire                          aclk,
    input  wire                          aresetn,
    input  wire                          sysclk,
    input  wire                          sysrst_n,
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
    input  wire                          rready,
    //====================================================
    // UART Signals
    //====================================================
    output logic                         o_uart_txd_sysclkr,
    input  wire                          i_uart_rxd,
    output logic                         o_uart_rts_sysclkr,
    input  wire                          i_uart_cts,
    //====================================================
    // Interuppt
    //====================================================
    output wire                          o_interrupt_aclkr
);





endmodule

`default_nettype wire
