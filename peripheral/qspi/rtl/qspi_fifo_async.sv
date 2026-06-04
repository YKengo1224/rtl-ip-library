`default_nettype none
module qspi_fifo_async #(
    parameter int BITWIDTH = 32,
    parameter int FIFO_SIZE = 8,  //only 2**n
    parameter int SYNC_FF_DEPTH = 2,
    parameter int ALMOST_FULL_SIZE = 5,
    parameter int ALMOST_EMPTY_SIZE = 2
) (
    input  wire                        wclk,
    input  wire                        rclk,
    input  wire                        rst_n_wclk,
    input  wire                        rst_n_rclk,
    //data 
    input  wire                        w_en_wclk,
    input  wire  [       BITWIDTH-1:0] data_in_wclk,
    input  wire                        r_en_rclk,
    output logic [       BITWIDTH-1:0] data_out_rclkr,
    output logic                       data_out_valid_rclkr,
    //fifo status
    output logic                       empty_wclkr,
    output logic                       full_wclkr,
    output logic                       almost_full_wclkr,
    output logic                       almost_empty_wclkr,
    output logic [$clog2(FIFO_SIZE):0] fifo_available_wclkr,

    output logic                       empty_rclkr,
    output logic                       full_rclkr,
    output logic                       almost_full_rclkr,
    output logic                       almost_empty_rclkr,
    output logic [$clog2(FIFO_SIZE):0] fifo_available_rclkr
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
    assign write_valid = w_en_wclk && !full_wclkr;
    assign read_valid = r_en_rclk && !empty_rclkr;

    //########################################
    // data register
    //########################################
    assign w_ptr_bin_wclk = gray_to_bin(w_ptr_wclk);
    always_ff @(posedge wclk or negedge rst_n_wclk) begin
        if (!rst_n_wclk) begin
            for (int i = 0; i < FIFO_SIZE; i++) begin
                data_ff[i] <= '0;
            end
        end else if (write_valid) begin
            data_ff[w_ptr_bin_wclk[ADDR_BITWIDTH-1:0]] <= data_in_wclk;
        end
    end

    //########################################
    // data out
    //########################################
    assign r_ptr_bin_rclk = gray_to_bin(r_ptr_rclk);



    // always_ff @(posedge rclk or negedge rst_n_rclk) begin
    //     if (!rst_n_rclk) begin
    //         data_out_rclkr <= '0;
    //         data_out_valid_rclkr <= 1'b0;
    //     end else if (read_valid) begin
    //         data_out_rclkr <= data_ff[r_ptr_bin_rclk[ADDR_BITWIDTH-1:0]];
    //         data_out_valid_rclkr <= 1'b1;
    //     end else begin
    //         data_out_rclkr <= '0;
    //         data_out_valid_rclkr <= 1'b0;
    //     end
    // end

    always_ff @(posedge rclk or negedge rst_n_rclk) begin
        if (!rst_n_rclk) begin
            data_out_rclkr <= '0;
            data_out_valid_rclkr <= 1'b0;
        end else begin
            data_out_rclkr <= data_ff[r_ptr_bin_rclk[ADDR_BITWIDTH-1:0]];
            data_out_valid_rclkr <= 1'b1;
        end
    end


    //########################################
    // increment R/W  pointer
    //########################################
    always_comb begin
        w_ptr_next = write_valid ? grayinc(w_ptr_wclk) : w_ptr_wclk;
        r_ptr_next = read_valid ? grayinc(r_ptr_rclk) : r_ptr_rclk;
    end

    always_ff @(posedge wclk or negedge rst_n_wclk) begin
        if (!rst_n_wclk) begin
            w_ptr_wclk <= '0;
        end else begin
            w_ptr_wclk <= w_ptr_next;
        end
    end
    always_ff @(posedge rclk or negedge rst_n_rclk) begin
        if (!rst_n_rclk) begin
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
            qspi_synchronizer #(                                
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) wr2rd_synchronizer (
                .CLK(rclk),
                .RST_N(rst_n_rclk),
                .DATA_IN(w_ptr_wclk[gi]),
                .DATA_OUT(w_ptr_rclk[gi])
            );
            qspi_synchronizer #(
                .FF_DEPTH(SYNC_FF_DEPTH)
            ) rd2wd_synchronizer (
                .CLK(wclk),
                .RST_N(rst_n_wclk),
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


    always_ff @(posedge wclk or negedge rst_n_wclk) begin
        if (!rst_n_wclk) begin
            empty_wclkr <= '1;
            full_wclkr <= '0;
            almost_full_wclkr <= '0;
            almost_empty_wclkr <= '1;
            fifo_available_wclkr <= FIFO_SIZE;
        end else begin
            empty_wclkr <= (w_ptr_next == r_ptr_wclk);
            full_wclkr <= (fifo_cnt_wclk >= FIFO_SIZE);
            almost_full_wclkr <= (fifo_cnt_wclk >= ALMOST_FULL_SIZE);
            almost_empty_wclkr <= (fifo_cnt_wclk < ALMOST_EMPTY_SIZE);
            fifo_available_wclkr <= FIFO_SIZE - fifo_cnt_wclk;
        end
    end

    always_ff @(posedge rclk or negedge rst_n_rclk) begin
        if (!rst_n_rclk) begin
            empty_rclkr <= '1;
            full_rclkr <= '0;
            almost_full_rclkr <= '0;
            almost_empty_rclkr <= '1;
            fifo_available_rclkr <= FIFO_SIZE;
        end else begin
            empty_rclkr <= (w_ptr_rclk == r_ptr_next);
            full_rclkr <= (fifo_cnt_rclk >= FIFO_SIZE);
            almost_full_rclkr <= (fifo_cnt_rclk >= ALMOST_FULL_SIZE);
            almost_empty_rclkr <= (fifo_cnt_rclk < ALMOST_EMPTY_SIZE);
            fifo_available_rclkr <= FIFO_SIZE - fifo_cnt_rclk;
        end
    end




    //synopsys translate_off   

    wr_gray_check :
    assert property (@(posedge wclk) disable iff (!rst_n_wclk) (write_valid) |-> $countones(
        w_ptr_wclk ^ w_ptr_next
    ) == 1);

    rd_gray_check :
    assert property (@(posedge rclk) disable iff (!rst_n_rclk) (read_valid) |-> $countones(
        r_ptr_rclk ^ r_ptr_next
    ) == 1);


    //synopsys translate_on



endmodule

`default_nettype wire
