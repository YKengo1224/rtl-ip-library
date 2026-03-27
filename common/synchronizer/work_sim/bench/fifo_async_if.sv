interface fifo_async_if #(
    parameter int BITWIDTH = 32
);
    logic                WCLK;
    logic                RCLK;
    logic                RST_N_WCLK;
    logic                RST_N_RCLK;

    logic                W_EN_WCLK;
    logic [BITWIDTH-1:0] DATA_IN_WCLK;
    logic                R_EN_RCLK;
    logic [BITWIDTH-1:0] DATA_OUT_RCLKR;
    logic                DATA_OUT_VALID_RCLKR;

    logic                EMPTY_WCLKR;
    logic                FULL_WCLKR;
    logic                ALMOST_FULL_WCLKR;
    logic                ALMOST_EMPTY_WCLKR;
    logic [BITWIDTH-1:0] FIFO_AVAILABLE_WCLKR;

    logic                EMPTY_RCLKR;
    logic                FULL_RCLKR;
    logic                ALMOST_FULL_RCLKR;
    logic                ALMOST_EMPTY_RCLKR;
    logic [BITWIDTH-1:0] FIFO_AVAILABLE_RCLKR;

endinterface
