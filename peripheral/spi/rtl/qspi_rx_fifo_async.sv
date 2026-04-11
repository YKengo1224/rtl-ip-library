`default_nettype none

module qspi_rx_fifo_async #(
    parameter int BITWIDTH = 32,
    parameter int FIFO_SIZE = 8,  //only 2**n
    parameter int SYNC_FF_DEPTH = 2,
    parameter int ALMOST_FULL_SIZE = 5,
    parameter int ALMOST_EMPTY_SIZE = 2
) (
    input  wire                 wclk,
    input  wire                 rclk,
    input  wire                 rst_n_wclk,
    input  wire                 rst_n_rclk,
    //data 
    input  wire                 w_en_wclk,
    input  wire  [BITWIDTH-1:0] data_in_wclk,
    input  wire                 r_en_rclk,
    output logic [BITWIDTH-1:0] data_out_rclkr,
    // output logic                data_out_valid_rclkr,
    //fifo status
    output logic                empty_wclkr,
    output logic                full_wclkr,
    // output logic                almost_full_wclkr,
    // output logic                almost_empty_wclkr,
    // output logic [BITWIDTH-1:0] fifo_available_wclkr,
    output logic                w_en_rclkr,
    output logic                empty_rclkr,
    output logic                full_rclkr,
    // output logic                almost_full_rclkr,
    // output logic                almost_empty_rclkr,
    // output logic [BITWIDTH-1:0] fifo_available_rclkr
    output logic [BITWIDTH-1:0] fifo_num_rclk
);

    logic [BITWIDTH-1:0] fifo_available_rclkr;

    assign fifo_num_rclk = FIFO_SIZE - fifo_available_rclkr;

    synchronizer #(
        .FF_DEPTH(SYNC_FF_DEPTH)
    ) w_en_synchronizer (
        .CLK(rclk),
        .RST_N(rst_n_rclk),
        .DATA_IN(w_en_wclk),
        .DATA_OUT(w_en_rclkr)
    );


    qspi_fifo_async #(
        .BITWIDTH(15),
        .FIFO_SIZE(FIFO_SIZE),  //only 2**n
        .SYNC_FF_DEPTH(2),
        .ALMOST_FULL_SIZE(FIFO_SIZE - 4),
        .ALMOST_EMPTY_SIZE(4)
    ) qspi_rx_fifo (
        .wclk(wclk),
        .rclk(rclk),
        .rst_n_wclk(rst_n_wclk),
        .rst_n_rclk(rst_n_rclk),
        .w_en_wclk(w_en_wclk),
        .data_in_wclk(data_in_wclk),
        .r_en_rclk(r_en_rclk),
        .data_out_rclkr(data_out_rclkr),
        .data_out_valid_rclkr(),
        .empty_wclkr(empty_wclkr),
        .full_wclkr(full_wclkr),
        .almost_full_wclkr(),
        .almost_empty_wclkr(),
        .fifo_available_wclkr(),
        .empty_rclkr(empty_rclkr),
        .full_rclkr(full_rclkr),
        .almost_full_rclkr(),
        .almost_empty_rclkr(),
        .fifo_available_rclkr(fifo_available_rclkr)
    );



endmodule

`default_nettype wire
