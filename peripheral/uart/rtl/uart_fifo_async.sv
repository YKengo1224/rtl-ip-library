`default_nettype none
module uart_fifo_async #(
    parameter int BITWIDTH = 32,
    parameter int FIFO_SIZE = 8,  //only 2**n
    parameter int SYNC_FF_DEPTH = 2,
    parameter int ALMOST_FULL_SIZE = 5,
    parameter int ALMOST_EMPTY_SIZE = 2
) (
    input  wire                        WCLK,
    input  wire                        RCLK,
    input  wire                        RST_N_WCLK,
    input  wire                        RST_N_RCLK,
    //data 
    input  wire                        W_EN_WCLK,
    input  wire  [       BITWIDTH-1:0] DATA_IN_WCLK,
    input  wire                        R_EN_RCLK,
    output logic [       BITWIDTH-1:0] DATA_OUT_RCLKR,
    output logic                       DATA_OUT_VALID_RCLKR,
    //fifo status
    output logic                       EMPTY_WCLKR,
    output logic                       FULL_WCLKR,
    output logic                       ALMOST_FULL_WCLKR,
    output logic                       ALMOST_EMPTY_WCLKR,
    output logic [$clog2(FIFO_SIZE):0] FIFO_AVAILABLE_WCLKR,

    output logic                       EMPTY_RCLKR,
    output logic                       FULL_RCLKR,
    output logic                       ALMOST_FULL_RCLKR,
    output logic                       ALMOST_EMPTY_RCLKR,
    output logic [$clog2(FIFO_SIZE):0] FIFO_AVAILABLE_RCLKR
);

    //########################################
    // Define Signal 
    //########################################
    localparam int ADDR_BITWIDTH = $clog2(FIFO_SIZE);

    wire                    write_valid;
    wire                    read_valid;

    logic [   BITWIDTH-1:0] data_ff        [0:FIFO_SIZE-1];

    logic [ADDR_BITWIDTH:0] w_ptr_wclk;
    logic [ADDR_BITWIDTH:0] r_ptr_rclk;
    logic [ADDR_BITWIDTH:0] w_ptr_next;
    logic [ADDR_BITWIDTH:0] r_ptr_next;
    logic [ADDR_BITWIDTH:0] w_ptr_bin_wclk;
    logic [ADDR_BITWIDTH:0] r_ptr_bin_rclk;

    logic [ADDR_BITWIDTH:0] w_ptr_rclk;
    logic [ADDR_BITWIDTH:0] r_ptr_wclk;

    logic [ADDR_BITWIDTH:0] fifo_cnt_wclk;
    logic [ADDR_BITWIDTH:0] fifo_cnt_rclk;

    //########################################
    // Define Function
    //########################################
    function automatic [ADDR_BITWIDTH:0] bin_to_gray(input [ADDR_BITWIDTH:0] bin_data);
        bin_to_gray = bin_data ^ (bin_data >> 1);
    endfunction

    function automatic [ADDR_BITWIDTH:0] gray_to_bin(input [ADDR_BITWIDTH:0] gray_data);
        gray_to_bin[ADDR_BITWIDTH] = gray_data[ADDR_BITWIDTH];
        for (int i = ADDR_BITWIDTH - 1; i >= 0; i--) begin
            gray_to_bin[i] = gray_to_bin[i+1] ^ gray_data[i];
        end
    endfunction

    function automatic [ADDR_BITWIDTH:0] grayinc(input [ADDR_BITWIDTH:0] gray_data);
        logic [ADDR_BITWIDTH:0] bin_data;
        bin_data = gray_to_bin(gray_data);
        bin_data = bin_data + {{ADDR_BITWIDTH{1'b0}}, 1'b1};
        grayinc  = bin_to_gray(bin_data);
    endfunction

    //########################################
    // data valid signal
    //########################################
    assign write_valid = W_EN_WCLK && !FULL_WCLKR;
    assign read_valid = R_EN_RCLK && !EMPTY_RCLKR;

    //########################################
    // data register
    //########################################
    assign w_ptr_bin_wclk = gray_to_bin(w_ptr_wclk);
    always_ff @(posedge WCLK or negedge RST_N_WCLK) begin
        if (!RST_N_WCLK) begin
            for (int i = 0; i < FIFO_SIZE; i++) begin
                data_ff[i] <= '0;
            end
        end else if (write_valid) begin
            data_ff[w_ptr_bin_wclk[ADDR_BITWIDTH-1:0]] <= DATA_IN_WCLK;
        end
    end

    //########################################
    // data out
    //########################################
    assign r_ptr_bin_rclk = gray_to_bin(r_ptr_rclk);
    always_ff @(posedge RCLK or negedge RST_N_RCLK) begin
        if (!RST_N_RCLK) begin
            DATA_OUT_RCLKR <= '0;
            DATA_OUT_VALID_RCLKR <= 1'b0;
        end else if (read_valid) begin
            DATA_OUT_RCLKR <= data_ff[r_ptr_bin_rclk[ADDR_BITWIDTH-1:0]];
            DATA_OUT_VALID_RCLKR <= 1'b1;
        end else begin
            DATA_OUT_RCLKR <= '0;
            DATA_OUT_VALID_RCLKR <= 1'b0;
        end
    end

    //########################################
    // increment R/W  pointer
    //########################################
    always_comb begin
        w_ptr_next = write_valid ? grayinc(w_ptr_wclk) : w_ptr_wclk;
        r_ptr_next = read_valid ? grayinc(r_ptr_rclk) : r_ptr_rclk;
    end

    always_ff @(posedge WCLK or negedge RST_N_WCLK) begin
        if (!RST_N_WCLK) begin
            w_ptr_wclk <= '0;
        end else begin
            w_ptr_wclk <= w_ptr_next;
        end
    end
    always_ff @(posedge RCLK or negedge RST_N_RCLK) begin
        if (!RST_N_RCLK) begin
            r_ptr_rclk <= '0;
        end else begin
            r_ptr_rclk <= r_ptr_next;
        end
    end
    //########################################
    // syncronizer 
    //########################################
    genvar gi;
    generate
        for (gi = 0; gi <= ADDR_BITWIDTH; gi++) begin
            uart_synchronizer #(
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) wr2rd_synchronizer (
                .CLK(RCLK),
                .RST_N(RST_N_RCLK),
                .DATA_IN(w_ptr_wclk[gi]),
                .DATA_OUT(w_ptr_rclk[gi])
            );
            uart_synchronizer #(
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) rd2wd_synchronizer (
                .CLK(WCLK),
                .RST_N(RST_N_WCLK),
                .DATA_IN(r_ptr_rclk[gi]),
                .DATA_OUT(r_ptr_wclk[gi])
            );
        end
    endgenerate

    //########################################
    // Full/Empty Flag Generation 
    //########################################
    assign fifo_cnt_wclk = gray_to_bin(w_ptr_next) - gray_to_bin(r_ptr_wclk);
    assign fifo_cnt_rclk = gray_to_bin(w_ptr_rclk) - gray_to_bin(r_ptr_next);


    always_ff @(posedge WCLK or negedge RST_N_WCLK) begin
        if (!RST_N_WCLK) begin
            EMPTY_WCLKR <= '1;
            FULL_WCLKR <= '0;
            ALMOST_FULL_WCLKR <= '0;
            ALMOST_EMPTY_WCLKR <= '1;
            FIFO_AVAILABLE_WCLKR <= '0;
        end else begin
            EMPTY_WCLKR <= (w_ptr_next == r_ptr_wclk);
            FULL_WCLKR <= (fifo_cnt_wclk >= FIFO_SIZE);
            ALMOST_FULL_WCLKR <= (fifo_cnt_wclk >= ALMOST_FULL_SIZE);
            ALMOST_EMPTY_WCLKR <= (fifo_cnt_wclk < ALMOST_EMPTY_SIZE);
            FIFO_AVAILABLE_WCLKR <= fifo_cnt_wclk;
        end
    end

    always_ff @(posedge RCLK or negedge RST_N_RCLK) begin
        if (!RST_N_RCLK) begin
            EMPTY_RCLKR <= '1;
            FULL_RCLKR <= '0;
            ALMOST_FULL_RCLKR <= '0;
            ALMOST_EMPTY_RCLKR <= '1;
            FIFO_AVAILABLE_RCLKR <= '0;
        end else begin
            EMPTY_RCLKR <= (w_ptr_rclk == r_ptr_next);
            FULL_RCLKR <= (fifo_cnt_rclk >= FIFO_SIZE);
            ALMOST_FULL_RCLKR <= (fifo_cnt_rclk >= ALMOST_FULL_SIZE);
            ALMOST_EMPTY_RCLKR <= (fifo_cnt_rclk < ALMOST_EMPTY_SIZE);
            FIFO_AVAILABLE_RCLKR <= fifo_cnt_rclk;
        end
    end




    //synopsys translate_off   

    wr_gray_check :
    assert property (@(posedge WCLK) disable iff (!RST_N_WCLK) (write_valid) |-> $countones(
        w_ptr_wclk ^ w_ptr_next
    ) == 1);

    rd_gray_check :
    assert property (@(posedge RCLK) disable iff (!RST_N_RCLK) (read_valid) |-> $countones(
        r_ptr_rclk ^ r_ptr_next
    ) == 1);


    //synopsys translate_on



endmodule

`default_nettype wire
