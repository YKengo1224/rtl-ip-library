`default_nettype none
module uart_rx_fifo_async #(
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
    input  wire       i_rx_fifo_wen_sysclk,
    input  wire [8:0] i_rx_fifo_wdata_sysclk,
    input  wire       i_uart_data_rtrig_aclk,  // Read trigger from AXI
    output wire [8:0] o_uart_data_aclkr,       // FWFT read data output

    //=========================================
    // FIFO Status Interface
    //=========================================
    output wire o_rx_fifo_empty_sysclkr,
    output wire o_rx_fifo_full_sysclkr,
    output wire o_rx_fifo_almost_full_sysclkr,
    output wire o_rx_fifo_almost_empty_sysclkr,
    output wire o_rx_fifo_empty_aclkr,
    output wire o_rx_fifo_full_aclkr,
    output wire o_rx_fifo_almost_full_aclkr,
    output wire o_rx_fifo_almost_empty_aclkr,

    //=========================================
    // Interrupt Signals
    //=========================================
    input  wire [4:0] i_rx_fifo_th_level_aclk,        // Threshold level
    output reg        o_int_rx_fifo_th_raw_set_aclkr  // 1-clock pulse on threshold crossing
);

    //=========================================
    // Internal Signals
    //=========================================
    logic       rx_fifo_ren_aclk;
    wire  [8:0] rx_fifo_rdata_aclk;
    wire        rx_fifo_rdata_valid_aclk;

    // FWFT hold registers
    reg   [8:0] rx_fifo_rdata_hold_aclkr;
    reg         rx_fifo_rdata_hold_valid_aclkr;

    // Interrupt generation signals
    wire  [4:0] rx_fifo_available_aclk;
    logic       rx_int_fifo_th_aclk;
    reg         rx_int_fifo_th_prev_aclkr;

    //=========================================
    // Async FIFO Instantiation
    // sysclk (write) -> aclk (read)
    // Note: Underflow protection is handled inside this core IP.
    //=========================================
    uart_fifo_async #(
        .BITWIDTH(9),
        .FIFO_SIZE(16),  // only 2**n
        .SYNC_FF_DEPTH(SYNC_FF_DEPTH),
        .ALMOST_FULL_SIZE(ALMOST_FULL_SIZE),
        .ALMOST_EMPTY_SIZE(ALMOST_EMPTY_SIZE)
    ) uart_fifo_async (
        .WCLK                (sysclk),
        .RCLK                (aclk),
        .RST_N_WCLK          (sysrst_n),
        .RST_N_RCLK          (aresetn),
        .W_EN_WCLK           (i_rx_fifo_wen_sysclk),
        .DATA_IN_WCLK        (i_rx_fifo_wdata_sysclk),
        .R_EN_RCLK           (rx_fifo_ren_aclk),
        .DATA_OUT_RCLKR      (rx_fifo_rdata_aclk),
        .DATA_OUT_VALID_RCLKR(rx_fifo_rdata_valid_aclk),
        .EMPTY_WCLKR         (o_rx_fifo_empty_sysclkr),
        .FULL_WCLKR          (o_rx_fifo_full_sysclkr),
        .ALMOST_FULL_WCLKR   (o_rx_fifo_almost_full_sysclkr),
        .ALMOST_EMPTY_WCLKR  (o_rx_fifo_almost_empty_sysclkr),
        .FIFO_AVAILABLE_WCLKR(),
        .EMPTY_RCLKR         (o_rx_fifo_empty_aclkr),
        .FULL_RCLKR          (o_rx_fifo_full_aclkr),
        .ALMOST_FULL_RCLKR   (o_rx_fifo_almost_full_aclkr),
        .ALMOST_EMPTY_RCLKR  (o_rx_fifo_almost_empty_aclkr),
        .FIFO_AVAILABLE_RCLKR(rx_fifo_available_aclk)
    );

    //=========================================
    // FWFT (First-Word Fall-Through) Logic
    // Pre-fetches the next word so it is immediately available on the AXI bus.
    //=========================================

    // Read Enable Generation
    always_comb begin
        // Prefetch: FIFO has data, hold register is empty, and no data is currently in transit
        if (!o_rx_fifo_empty_aclkr && !rx_fifo_rdata_hold_valid_aclkr && !rx_fifo_rdata_valid_aclk) begin
            rx_fifo_ren_aclk = 1'b1;
            // User read: trigger a new read from the FIFO
        end else if (i_uart_data_rtrig_aclk) begin
            rx_fifo_ren_aclk = 1'b1;
        end else begin
            rx_fifo_ren_aclk = 1'b0;
        end
    end

    // Hold Register: Latch the incoming data from the FIFO
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rx_fifo_rdata_hold_aclkr <= '0;
        end else if (rx_fifo_rdata_valid_aclk) begin
            rx_fifo_rdata_hold_aclkr <= rx_fifo_rdata_aclk;
        end
    end

    // Valid Flag: Track if the hold register contains unread data
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rx_fifo_rdata_hold_valid_aclkr <= 1'b0;
        end else if (rx_fifo_rdata_valid_aclk) begin
            rx_fifo_rdata_hold_valid_aclkr <= 1'b1;  // New data arrived
        end else if (i_uart_data_rtrig_aclk) begin
            rx_fifo_rdata_hold_valid_aclkr <= 1'b0;  // Data was consumed by AXI
        end
    end

    // Direct output to the AXI bus
    assign o_uart_data_aclkr = rx_fifo_rdata_hold_aclkr;

    //=========================================
    // Threshold Interrupt Logic
    //=========================================

    // Compare available data against the threshold level
    always_comb begin
        if ((rx_fifo_available_aclk + rx_fifo_rdata_hold_valid_aclkr) >= i_rx_fifo_th_level_aclk) begin
            rx_int_fifo_th_aclk = 1'b1;
        end else begin
            rx_int_fifo_th_aclk = 1'b0;
        end
    end

    // 1-stage delay for edge detection
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rx_int_fifo_th_prev_aclkr <= 1'b0;
        end else begin
            rx_int_fifo_th_prev_aclkr <= rx_int_fifo_th_aclk;
        end
    end

    // Rising edge detection (!prev && current) -> generates a 1-clock pulse
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            o_int_rx_fifo_th_raw_set_aclkr <= 1'b0;
        end else begin
            o_int_rx_fifo_th_raw_set_aclkr <= !rx_int_fifo_th_prev_aclkr && rx_int_fifo_th_aclk;
        end
    end

endmodule
`default_nettype wire
