`default_nettype none
module fifo_async #(
    parameter int BITWIDTH = 32,
    parameter int FIFO_SIZE = 8,  //only 2**n
    parameter int SYNC_FF_DEPTH = 2
) (
    input wire W_CLK,
    input wire R_CLK,
    input wire RST_N_W_CLK,
    input wire RST_N_R_CLK,

    input  wire                 W_EN,
    input  wire  [BITWIDTH-1:0] DATA_IN,
    input  wire                 R_EN,
    output logic [BITWIDTH-1:0] DATA_OUT,
    output logic                DATA_OUT_VALID,
    output logic                EMPTY,
    output logic                FULL,
    output logic                ALMOST_FULL
);

    //########################################
    // Define Signal 
    //########################################
    localparam int ADDR_BITWIDTH = $clog2(FIFO_SIZE);

    wire                    write_valid;
    wire                    read_valid;

    logic [   BITWIDTH-1:0] data_ff         [0:FIFO_SIZE-1];

    logic [ADDR_BITWIDTH:0] w_ptr_w_clk;
    logic [ADDR_BITWIDTH:0] r_ptr_r_clk;
    logic [ADDR_BITWIDTH:0] w_ptr_next;
    logic [ADDR_BITWIDTH:0] r_ptr_next;
    logic [ADDR_BITWIDTH:0] w_ptr_bin_w_clk;
    logic [ADDR_BITWIDTH:0] r_ptr_bin_r_clk;

    logic [ADDR_BITWIDTH:0] w_ptr_r_clk;
    logic [ADDR_BITWIDTH:0] r_ptr_w_clk;

    logic [ADDR_BITWIDTH:0] fifo_cnt_w_clk;
    logic [ADDR_BITWIDTH:0] fifo_cnt_r_clk;

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
    assign write_valid = W_EN && !FULL;
    assign read_valid = R_EN && !EMPTY;

    //########################################
    // data register
    //########################################
    assign w_ptr_bin_w_clk = gray_to_bin(w_ptr_w_clk);
    always_ff @(posedge W_CLK or negedge RST_N_W_CLK) begin
        if (!RST_N_W_CLK) begin
            for (int i = 0; i < FIFO_SIZE; i++) begin
                data_ff[i] <= '0;
            end
        end else if (write_valid) begin
            data_ff[w_ptr_bin_w_clk[ADDR_BITWIDTH-1:0]] <= DATA_IN;
        end
    end

    //########################################
    // data out
    //########################################
    assign r_ptr_bin_r_clk = gray_to_bin(r_ptr_r_clk);
    always_ff @(posedge R_CLK or negedge RST_N_R_CLK) begin
        if (!RST_N_R_CLK) begin
            DATA_OUT <= '0;
            DATA_OUT_VALID <= 1'b0;
        end else if (read_valid) begin
            DATA_OUT <= data_ff[r_ptr_bin_r_clk[ADDR_BITWIDTH-1:0]];
            DATA_OUT_VALID <= 1'b1;
        end else begin
            DATA_OUT <= '0;
            DATA_OUT_VALID <= 1'b0;
        end
    end

    //########################################
    // increment R/W  pointer
    //########################################
    always_comb begin
        w_ptr_next = write_valid ? grayinc(w_ptr_w_clk) : w_ptr_w_clk;
        r_ptr_next = read_valid ? grayinc(r_ptr_r_clk) : r_ptr_r_clk;
    end

    always_ff @(posedge W_CLK or negedge RST_N_W_CLK) begin
        if (!RST_N_W_CLK) begin
            w_ptr_w_clk <= '0;
        end else begin
            w_ptr_w_clk <= w_ptr_next;
        end
    end
    always_ff @(posedge R_CLK or negedge RST_N_R_CLK) begin
        if (!RST_N_R_CLK) begin
            r_ptr_r_clk <= '0;
        end else begin
            r_ptr_r_clk <= r_ptr_next;
        end
    end
    //########################################
    // syncronizer 
    //########################################
    genvar gi;
    generate
        for (gi = 0; gi <= ADDR_BITWIDTH; gi++) begin
            synchronizer #(
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) wr2rd_synchronizer (
                .CLK(R_CLK),
                .RST_N(RST_N_R_CLK),
                .DATA_IN(w_ptr_w_clk[gi]),
                .DATA_OUT(w_ptr_r_clk[gi])
            );
            synchronizer #(
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) rd2wd_synchronizer (
                .CLK(W_CLK),
                .RST_N(RST_N_W_CLK),
                .DATA_IN(r_ptr_r_clk[gi]),
                .DATA_OUT(r_ptr_w_clk[gi])
            );
        end
    endgenerate

    //########################################
    // Full/Empty Flag Generation 
    //########################################
    assign fifo_cnt_w_clk = gray_to_bin(w_ptr_next) - gray_to_bin(r_ptr_w_clk);


    always_ff @(posedge W_CLK or negedge RST_N_W_CLK) begin
        if (!RST_N_W_CLK) begin
            FULL <= 1'b0;
        end else begin
            FULL <= (fifo_cnt_w_clk >= FIFO_SIZE);
        end
    end

    always_ff @(posedge R_CLK or negedge RST_N_R_CLK) begin
        if (!RST_N_R_CLK) begin
            EMPTY <= 1'b1;
        end else begin
            EMPTY <= (w_ptr_r_clk == r_ptr_next);
        end
    end




endmodule

`default_nettype wire
