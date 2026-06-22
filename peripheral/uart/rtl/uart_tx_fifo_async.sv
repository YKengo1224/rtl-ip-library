`default_nettype none
module uart_tx_fifo_async #(
    parameter int SYNC_FF_DEPTH = 2,
    parameter int ALMOST_FULL_SIZE = 5,
    parameter int ALMOST_EMPTY_SIZE = 2
) (
    input wire aclk,
    input wire sysclk,
    input wire aresetn,
    input wire sysrst_n,

    //=========================================
    // Data Interface
    //=========================================
    input wire       i_uart_tx_data_wtrig_aclk,  // Read trigger from AXI
    input wire [8:0] i_uart_tx_data_aclk,

    input  wire       i_tx_fifo_ren_sysclk,
    output wire [8:0] o_tx_fifo_rdata_sysclkr,
    output wire       o_tx_fifo_rdata_valid_sysclkr,

    //=========================================
    // FIFO Status Interface
    //=========================================
    output wire o_tx_fifo_empty_aclkr,
    output wire o_tx_fifo_full_aclkr,
    output wire o_tx_fifo_almost_full_aclkr,
    output wire o_tx_fifo_almost_empty_aclkr,
    output wire o_tx_fifo_empty_sysclkr,
    output wire o_tx_fifo_full_sysclkr,
    output wire o_tx_fifo_almost_full_sysclkr,
    output wire o_tx_fifo_almost_empty_sysclkr,

    //=========================================
    // Interrupt Signals
    //=========================================
    input  wire [4:0] i_tx_fifo_th_level_aclk,        // Threshold level
    output reg        o_int_tx_fifo_th_raw_set_aclkr  // 1-clock pulse on threshold crossing
);

    //=========================================
    // Internal Signals
    //=========================================
    // Interrupt generation signals
    wire  [4:0] tx_fifo_available_aclk;
    wire  [4:0] tx_fifo_free_aclk;
    logic       tx_int_fifo_th_aclk;
    reg         tx_int_fifo_th_prev_aclkr;

    //=========================================
    // Async FIFO Instantiation
    // aclk (write) -> sysclk (read)
    // Note: Underflow protection is handled inside this core IP.
    //=========================================
    uart_fifo_async #(
        .BITWIDTH(9),
        .FIFO_SIZE(16),  // only 2**n
        .SYNC_FF_DEPTH(SYNC_FF_DEPTH),
        .ALMOST_FULL_SIZE(ALMOST_FULL_SIZE),
        .ALMOST_EMPTY_SIZE(ALMOST_EMPTY_SIZE)
    ) uart_fifo_async (
        .WCLK                (aclk),
        .RCLK                (sysclk),
        .RST_N_WCLK          (aresetn),
        .RST_N_RCLK          (sysrst_n),
        .W_EN_WCLK           (i_uart_tx_data_wtrig_aclk),
        .DATA_IN_WCLK        (i_uart_tx_data_aclk),
        .R_EN_RCLK           (i_tx_fifo_ren_sysclk),
        .DATA_OUT_RCLKR      (o_tx_fifo_rdata_sysclkr),
        .DATA_OUT_VALID_RCLKR(o_tx_fifo_rdata_valid_sysclkr),
        .EMPTY_WCLKR         (o_tx_fifo_empty_aclkr),
        .FULL_WCLKR          (o_tx_fifo_full_aclkr),
        .ALMOST_FULL_WCLKR   (o_tx_fifo_almost_full_aclkr),
        .ALMOST_EMPTY_WCLKR  (o_tx_fifo_almost_empty_aclkr),
        .FIFO_AVAILABLE_WCLKR(tx_fifo_available_aclk),
        .EMPTY_RCLKR         (o_tx_fifo_empty_sysclkr),
        .FULL_RCLKR          (o_tx_fifo_full_sysclkr),
        .ALMOST_FULL_RCLKR   (o_tx_fifo_almost_full_sysclkr),
        .ALMOST_EMPTY_RCLKR  (o_tx_fifo_almost_empty_sysclkr),
        .FIFO_AVAILABLE_RCLKR()
    );


    //=========================================
    // Threshold Interrupt Logic
    //=========================================

    assign tx_fifo_free_aclk = 5'd16 - tx_fifo_available_aclk;

    // Compare available data against the threshold level
    always_comb begin
        if (tx_fifo_free_aclk >= i_tx_fifo_th_level_aclk) begin
            tx_int_fifo_th_aclk = 1'b1;
        end else begin
            tx_int_fifo_th_aclk = 1'b0;
        end
    end

    // 1-stage delay for edge detection
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            tx_int_fifo_th_prev_aclkr <= 1'b0;
        end else begin
            tx_int_fifo_th_prev_aclkr <= tx_int_fifo_th_aclk;
        end
    end

    // Rising edge detection (!prev && current) -> generates a 1-clock pulse
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            o_int_tx_fifo_th_raw_set_aclkr <= 1'b0;
        end else begin
            o_int_tx_fifo_th_raw_set_aclkr <= !tx_int_fifo_th_prev_aclkr && tx_int_fifo_th_aclk;
        end
    end

endmodule
`default_nettype wire
