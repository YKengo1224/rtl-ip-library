`default_nettype none

module qspi_core (
    input wire sysclk,
    input wire srstn_sysclk,

    input  wire         qspi_ctrl_qspi_enable_sysclk_i,
    input  wire  [ 1:0] qspi_ctrl_trans_dir_sysclk_i,
    input  wire  [ 1:0] qspi_ctrl_protocol_sel_sysclk_i,
    input  wire  [ 3:0] qspi_ctrl_word_width_sysclk_i,
    input  wire         qspi_ctrl_spi_slave_en_sysclk_i,
    input  wire         qspi_ctrl_cpol_sysclk_i,
    input  wire         qspi_ctrl_cpha_sysclk_i,
    input  wire         qspi_ctrl_order_sysclk_i,
    input  wire  [ 3:0] qspi_ctrl_rx_latch_delay_sysclk_i,
    input  wire         qspi_sw_reset_sw_rst_n_sysclk_i,
    input  wire         qspi_cs_ctrl_cs_manual_sysclk_i,
    input  wire         qspi_cs_ctrl_cs_manual_en_sysclk_i,
    input  wire  [ 1:0] qspi_cs_ctrl_cs_sel_sysclk_i,
    input  wire  [15:0] qspi_master_clk_clk_divisor_sysclk_i,
    output logic        qspi_status_spi_busy_sysclk_o_r,
    //tx fifo
    input  wire         qspi_status_tx_fifo_full_sysclk_i,
    input  wire         qspi_status_tx_fifo_empty_sysclk_i,
    output logic        qspi_tx_fifo_r_en_sysclk_o_r,
    input  wire  [15:0] qspi_tx_fifo_data_out_sysclk_i,
    input  wire         qspi_tx_fifo_data_out_valid_sysclk_i,
    //rx fifo                 
    input  wire         qspi_status_rx_fifo_full_sysclk_i,
    input  wire         qspi_status_rx_fifo_empty_sysclk_i,
    output logic        qspi_rx_fifo_w_en_sysclk_o_r,
    output logic [15:0] qspi_rx_fifo_data_in_sysclk_o_r,
    //QSPI signal
    output logic        qspi_sclk_out_sysclk_o_r,
    output logic        qspi_sclk_out_en_sysclk_o_r,
    output logic [ 3:0] qspi_csn_out_sysclk_o_r,
    output logic [ 3:0] qspi_csn_out_en_sysclk_o_r,
    output logic [ 3:0] qspi_data_out_sysclk_o_r,
    output logic [ 3:0] qspi_data_out_en_sysclk_o_r,
    input  wire         qspi_sclk_in_sysclk_i,
    input  wire  [ 3:0] qspi_csn_in_sysclk_i,
    input  wire  [ 3:0] qspi_data_in_sysclk_i
);
    import qspi_pkg::*;


    typedef enum logic [2:0] {
        S_IDLE,
        S_FETCH,
        S_SEND,
        S_SEND_FETCH
    } state_t;

    state_t state;
    state_t state_next;

    logic   master_detect;
    logic   slave_detect;


    // mode
    typedef enum logic [1:0] {
        MODE_0,
        MODE_1,
        MODE_2,
        MODE_3
    } mode_t;
    mode_t        qspi_mode_sysclk;



    // clock divisor signal
    logic  [31:0] divisor_count_max;
    logic         master_first_edge_sysclk_r;
    logic         master_second_edge_sysclk_r;
    logic  [31:0] divisor_count_sysclk_r;
    // sclk_in edge detect
    logic         slave_posedge_sysclk;
    logic         slave_negedge_sysclk;
    logic         qspi_sclk_in_sysclk_i_prev;
    // clock edge select
    logic         shift_edge_sysclk;
    logic         sample_edge_sysclk;
    // trans bit counter
    logic         transaction_start_sysclk;
    logic  [ 4:0] trans_bit_counter_sysclk_r;
    logic  [ 4:0] trans_bit_counter_next_sysclk;
    logic  [ 4:0] max_trans_bit_counter_sysclk_r;
    logic         finish_trans_sysclk;
    // tx data fetch
    logic  [15:0] tx_data_next_sysclk_r;
    logic         tx_data_next_valid_sysclk_r;
    logic  [15:0] tx_data_sysclk_r;
    logic         tx_data_valid_sysclk_r;
    // rx data serial to pararel
    logic  [15:0] rx_data_sysclk_r;

    assign master_detect = !qspi_ctrl_spi_slave_en_sysclk_i;
    assign slave_detect = qspi_ctrl_spi_slave_en_sysclk_i && (qspi_ctrl_protocol_sel_sysclk_i == SINGLE_SPI_MODE);


    always_comb begin
        state_next = state;
        if (!qspi_ctrl_qspi_enable_sysclk_i || (slave_detect & qspi_csn_in_sysclk_i)) begin
            state_next = S_IDLE;
        end else begin
            case (state)
                S_IDLE: begin
                    if (master_detect && !qspi_status_tx_fifo_empty_sysclk_i) begin
                        state_next = S_FETCH;
                    end else if (slave_detect && !qspi_csn_in_sysclk_i) begin
                        if (!qspi_status_tx_fifo_empty_sysclk_i) begin
                            state_next = S_FETCH;
                        end else begin
                            state_next = S_SEND;
                        end
                    end
                end  // case: S_IDLE
                S_FETCH: begin
                    if (qspi_tx_fifo_data_out_valid_sysclk_i) begin
                        state_next = S_SEND;
                    end
                end
                S_SEND: begin
                    if((trans_bit_counter_sysclk_r+2) >= max_trans_bit_counter_sysclk_r 
                        && !qspi_status_tx_fifo_empty_sysclk_i) begin
                        state_next = S_SEND_FETCH;
                    end else if(master_detect && finish_trans_sysclk && !tx_data_next_valid_sysclk_r) begin
                        state_next = S_IDLE;
                    end
                end
                S_SEND_FETCH: begin
                    if (qspi_tx_fifo_data_out_valid_sysclk_i) begin
                        state_next = S_SEND;
                    end
                end
            endcase
        end
    end



    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            state <= S_IDLE;
        end else begin
            state <= state_next;
        end
    end

    //-----------------------------------
    // tx data fetch
    //-----------------------------------
    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_tx_fifo_r_en_sysclk_o_r <= 1'b0;
        end else if ((state_next == S_FETCH) && (state == S_IDLE)) begin
            qspi_tx_fifo_r_en_sysclk_o_r <= 1'b1;
        end else if ((state_next == S_SEND_FETCH) || (state == S_SEND_FETCH)) begin
            if (!qspi_tx_fifo_r_en_sysclk_o_r) begin
                qspi_tx_fifo_r_en_sysclk_o_r <= 1'b1;
            end else begin
                qspi_tx_fifo_r_en_sysclk_o_r <= 1'b0;
            end
        end else begin
            qspi_tx_fifo_r_en_sysclk_o_r <= 1'b0;
        end
    end

    // always_comb begin
    //     if (!qspi_ctrl_cpol_sysclk_i && !qspi_ctrl_cpha_sysclk_i) begin
    //         qspi_mode_sysclk = MODE_0;
    //     end else if(!qspi_ctrl_cpol_sysclk_i && qspi_ctrl_cpha_sysclk_i) begin
    // end
    //-----------------------------------
    // clock_divisor
    //-----------------------------------

    assign divisor_count_max = (1 << (qspi_master_clk_clk_divisor_sysclk_i + 1));

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            master_first_edge_sysclk_r  <= 1'b0;
            master_second_edge_sysclk_r <= 1'b0;
        end else if ((state_next != S_IDLE) && (state_next != S_FETCH) && (state != S_FETCH)) begin
            if (divisor_count_sysclk_r == ((divisor_count_max >> 1) - 1)) begin
                master_first_edge_sysclk_r  <= 1'b1;
                master_second_edge_sysclk_r <= 1'b0;
            end else if (divisor_count_sysclk_r == (divisor_count_max - 1)) begin
                master_first_edge_sysclk_r  <= 1'b0;
                master_second_edge_sysclk_r <= 1'b1;
            end else begin
                master_first_edge_sysclk_r  <= 1'b0;
                master_second_edge_sysclk_r <= 1'b0;
            end
        end else begin
            master_first_edge_sysclk_r  <= 1'b0;
            master_second_edge_sysclk_r <= 1'b0;
        end
    end

    // always_comb begin
    //     if (qspi_ctrl_cpol_sysclk_i) begin
    //         master_posedge_sysclk = master_second_edge_sysclk_r;
    //         master_negedge_sysclk = master_first_edge_sysclk_r;
    //     end else begin
    //         master_posedge_sysclk = master_first_edge_sysclk_r;
    //         master_negedge_sysclk = master_second_edge_sysclk_r;
    //     end
    // end


    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            divisor_count_sysclk_r <= '0;
        end else if ((state_next != S_IDLE) && (master_detect)) begin
            if (divisor_count_sysclk_r == (divisor_count_max - 1)) begin
                divisor_count_sysclk_r <= '0;
            end else begin
                divisor_count_sysclk_r <= divisor_count_sysclk_r + 'd1;
            end
        end else begin
            divisor_count_sysclk_r <= '0;
        end
    end

    //-----------------------------------
    // sclk_in edge detect
    //-----------------------------------

    always_comb begin
        slave_posedge_sysclk = !qspi_sclk_in_sysclk_i_prev && qspi_sclk_in_sysclk_i;
        slave_negedge_sysclk = qspi_sclk_in_sysclk_i_prev && !qspi_sclk_in_sysclk_i;
    end

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_sclk_in_sysclk_i_prev <= 1'b0;
        end else begin
            qspi_sclk_in_sysclk_i_prev <= qspi_sclk_in_sysclk_i;
        end
    end

    //-----------------------------------
    // clock edge select
    //-----------------------------------
    always_comb begin
        if (master_detect) begin
            if (qspi_ctrl_cpha_sysclk_i) begin
                shift_edge_sysclk  = master_first_edge_sysclk_r;
                sample_edge_sysclk = master_second_edge_sysclk_r;
            end else begin
                shift_edge_sysclk  = master_second_edge_sysclk_r;
                sample_edge_sysclk = master_first_edge_sysclk_r;
            end
        end else if (slave_detect) begin
            if (!qspi_ctrl_cpol_sysclk_i && !qspi_ctrl_cpha_sysclk_i) begin
                shift_edge_sysclk  = slave_negedge_sysclk;
                sample_edge_sysclk = slave_posedge_sysclk;
            end else if (!qspi_ctrl_cpol_sysclk_i && qspi_ctrl_cpha_sysclk_i) begin
                shift_edge_sysclk  = slave_posedge_sysclk;
                sample_edge_sysclk = slave_negedge_sysclk;
            end
            if (qspi_ctrl_cpol_sysclk_i && !qspi_ctrl_cpha_sysclk_i) begin
                shift_edge_sysclk  = slave_posedge_sysclk;
                sample_edge_sysclk = slave_negedge_sysclk;
            end else if (qspi_ctrl_cpol_sysclk_i && qspi_ctrl_cpha_sysclk_i) begin
                shift_edge_sysclk  = slave_negedge_sysclk;
                sample_edge_sysclk = slave_posedge_sysclk;
            end
        end else begin
            shift_edge_sysclk  = 1'b0;
            sample_edge_sysclk = 1'b0;
        end
    end



    //-----------------------------------
    // trans_bit_counter
    //-----------------------------------    
    assign transaction_start_sysclk = ((state == S_IDLE) && (state_next != S_IDLE));
    assign finish_trans_sysclk = (shift_edge_sysclk && (trans_bit_counter_sysclk_r == (max_trans_bit_counter_sysclk_r-1)));


    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            max_trans_bit_counter_sysclk_r <= '0;
        end else if (transaction_start_sysclk) begin
            case (qspi_ctrl_protocol_sel_sysclk_i)
                SINGLE_SPI_MODE: begin
                    max_trans_bit_counter_sysclk_r <= qspi_ctrl_word_width_sysclk_i;
                end
                DUAL_SPI_MODE: begin
                    max_trans_bit_counter_sysclk_r <= 4;  //8 / 2
                end
                QUAD_SPI_MODE: begin
                    max_trans_bit_counter_sysclk_r <= 2;  //8 / 4
                end
            endcase
        end
    end


    always_comb begin
        //start && mode (0 or 1) 
        if (transaction_start_sysclk && (qspi_ctrl_cpol_sysclk_i == qspi_ctrl_cpha_sysclk_i)) begin
            trans_bit_counter_next_sysclk = 5'b0;
        end else if ((state_next != S_IDLE)) begin
            if (shift_edge_sysclk) begin
                if (trans_bit_counter_sysclk_r == (max_trans_bit_counter_sysclk_r - 1)) begin
                    trans_bit_counter_next_sysclk = 5'b0;
                end else begin
                    trans_bit_counter_next_sysclk = trans_bit_counter_sysclk_r + 5'b1;
                end
            end else begin
                trans_bit_counter_next_sysclk = trans_bit_counter_sysclk_r;
            end
        end else begin
            trans_bit_counter_next_sysclk = 5'b0;
        end
    end

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            trans_bit_counter_sysclk_r <= '0;
        end else begin
            trans_bit_counter_sysclk_r <= trans_bit_counter_next_sysclk;
        end
    end


    //-----------------------------------
    // tx data fetch
    //-----------------------------------    

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            tx_data_next_sysclk_r <= '0;
            tx_data_next_valid_sysclk_r <= 1'b0;
        end else if ((state == S_SEND_FETCH) && qspi_tx_fifo_data_out_valid_sysclk_i) begin
            tx_data_next_sysclk_r <= qspi_tx_fifo_data_out_sysclk_i;
            tx_data_next_valid_sysclk_r <= 1'b1;
        end else if ((state == S_SEND)) begin
            if (finish_trans_sysclk && tx_data_next_valid_sysclk_r) begin
                tx_data_next_valid_sysclk_r <= 1'b0;
            end
        end else begin
            tx_data_next_valid_sysclk_r <= 1'b0;
        end
    end


    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            tx_data_sysclk_r <= '0;
            tx_data_valid_sysclk_r <= '0;
        end else if ((state == S_FETCH) && (state_next == S_SEND)) begin
            tx_data_sysclk_r <= qspi_tx_fifo_data_out_sysclk_i;
            tx_data_valid_sysclk_r <= 1'b1;
        end else if (state == S_SEND) begin
            if (finish_trans_sysclk) begin
                if (tx_data_next_valid_sysclk_r) begin
                    tx_data_sysclk_r <= tx_data_next_sysclk_r;
                    tx_data_valid_sysclk_r <= 1'b1;
                end else begin
                    tx_data_valid_sysclk_r <= 1'b0;
                end
            end
        end else begin
            tx_data_valid_sysclk_r <= 1'b0;
        end
    end



    //-----------------------------------
    // tx data pararel to serial
    //-----------------------------------

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_data_out_sysclk_o_r <= '0;
            qspi_data_out_en_sysclk_o_r <= '0;
        end else if ((state_next == S_SEND) || (state_next == S_SEND_FETCH)) begin
            case (qspi_ctrl_protocol_sel_sysclk_i)
                SINGLE_SPI_MODE: begin
                    qspi_data_out_sysclk_o_r[3:1] <= '0;
                    qspi_data_out_en_sysclk_o_r   <= 4'b0001;
                    if (slave_detect && !tx_data_valid_sysclk_r) begin
                        qspi_data_out_sysclk_o_r[0] <= '0;
                    end else if (qspi_ctrl_order_sysclk_i) begin
                        qspi_data_out_sysclk_o_r[0] <= tx_data_sysclk_r[trans_bit_counter_next_sysclk];
                    end else begin
                        qspi_data_out_sysclk_o_r[0] <= tx_data_sysclk_r[(qspi_ctrl_word_width_sysclk_i - 1) - trans_bit_counter_next_sysclk];
                    end
                end
                DUAL_SPI_MODE: begin
                    qspi_data_out_sysclk_o_r[3:2] <= '0;
                    if (qspi_ctrl_trans_dir_sysclk_i) begin
                        qspi_data_out_en_sysclk_o_r <= 4'b0011;
                        if (qspi_ctrl_order_sysclk_i) begin
                            qspi_data_out_sysclk_o_r[1:0] <= tx_data_sysclk_r[(trans_bit_counter_next_sysclk << 1) +: 2];
                        end else begin
                            qspi_data_out_sysclk_o_r[1:0] <= tx_data_sysclk_r[(8 - 2) - (trans_bit_counter_next_sysclk << 1) +: 2];
                        end
                    end else begin
                        qspi_data_out_sysclk_o_r[1:0] <= '0;
                        qspi_data_out_en_sysclk_o_r   <= '0;
                    end
                end
                QUAD_SPI_MODE: begin
                    if (qspi_ctrl_trans_dir_sysclk_i) begin
                        if (qspi_ctrl_order_sysclk_i) begin
                            qspi_data_out_sysclk_o_r[3:0] <= tx_data_sysclk_r[(trans_bit_counter_next_sysclk << 2) +: 4];
                        end else begin
                            qspi_data_out_sysclk_o_r[3:0] <= tx_data_sysclk_r[(8 - 4) - (trans_bit_counter_next_sysclk << 2) +: 4];
                        end
                        qspi_data_out_en_sysclk_o_r <= '1;
                    end else begin
                        qspi_data_out_sysclk_o_r[3:0] <= '0;
                        qspi_data_out_en_sysclk_o_r   <= '0;
                    end
                end
            endcase
        end else begin
            qspi_data_out_sysclk_o_r <= '0;
            qspi_data_out_en_sysclk_o_r <= '0;
        end
    end



    //-----------------------------------
    // rx data serial to pararel
    //-----------------------------------
    logic [3:0] latch_delay_count_r;
    logic [3:0] latch_delay_count_next;
    logic       rx_data_latch_en;

    assign rx_data_latch_en = (latch_delay_count_r == qspi_ctrl_rx_latch_delay_sysclk_i);


    always_comb begin
        if (sample_edge_sysclk && (qspi_ctrl_rx_latch_delay_sysclk_i != 4'd0)) begin
            latch_delay_count_next = 4'd1;
        end else if (latch_delay_count_r != 4'd0) begin
            if (rx_data_latch_en) begin
                latch_delay_count_next = 4'd0;
            end else begin
                latch_delay_count_next = latch_delay_count_r + 4'd1;
            end
        end else begin
            latch_delay_count_next = 4'd0;
        end

    end

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            latch_delay_count_r <= 4'd0;
        end else begin
            latch_delay_count_r <= latch_delay_count_next;
        end
    end

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            rx_data_sysclk_r <= '0;
        end else if ((state_next == S_SEND) || (state_next == S_SEND_FETCH)) begin
            if (rx_data_latch_en) begin
                if (finish_trans_sysclk) begin
                    rx_data_sysclk_r <= '0;
                end else begin
                    case (qspi_ctrl_protocol_sel_sysclk_i)
                        SINGLE_SPI_MODE: begin
                            if (qspi_ctrl_order_sysclk_i) begin
                                rx_data_sysclk_r <= {
                                    qspi_data_in_sysclk_i[1], rx_data_sysclk_r[15:1]
                                };
                            end else begin
                                rx_data_sysclk_r <= {
                                    rx_data_sysclk_r[14:0], qspi_data_in_sysclk_i[1]
                                };
                            end
                        end
                        DUAL_SPI_MODE: begin
                            if (qspi_ctrl_trans_dir_sysclk_i) begin
                                if (qspi_ctrl_order_sysclk_i) begin
                                    rx_data_sysclk_r <= {
                                        8'd0, qspi_data_in_sysclk_i[1:0], rx_data_sysclk_r[7:2]
                                    };
                                end else begin
                                    rx_data_sysclk_r <= {
                                        8'd0, rx_data_sysclk_r[5:0], qspi_data_in_sysclk_i[1:0]
                                    };
                                end
                            end else begin
                                rx_data_sysclk_r <= '0;
                            end
                        end
                        QUAD_SPI_MODE: begin
                            if (qspi_ctrl_trans_dir_sysclk_i) begin
                                if (qspi_ctrl_order_sysclk_i) begin
                                    rx_data_sysclk_r <= {
                                        8'd0, qspi_data_in_sysclk_i[3:0], rx_data_sysclk_r[7:4]
                                    };
                                end else begin
                                    rx_data_sysclk_r <= {
                                        8'd0, rx_data_sysclk_r[3:0], qspi_data_in_sysclk_i[3:0]
                                    };
                                end
                            end else begin
                                rx_data_sysclk_r <= '0;
                            end
                        end
                    endcase
                end
            end
        end else begin
            rx_data_sysclk_r <= '0;
        end
    end




    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_rx_fifo_data_in_sysclk_o_r <= 16'd0;
            qspi_rx_fifo_w_en_sysclk_o_r <= 1'b0;
        end else if (finish_trans_sysclk) begin
            case (qspi_ctrl_protocol_sel_sysclk_i)
                SINGLE_SPI_MODE: begin
                    qspi_rx_fifo_w_en_sysclk_o_r <= 1'b1;
                    if (qspi_ctrl_order_sysclk_i) begin
                        qspi_rx_fifo_data_in_sysclk_o_r <= {
                            qspi_data_in_sysclk_i[1], rx_data_sysclk_r[15:1]
                        } >> (16 - qspi_ctrl_word_width_sysclk_i);
                    end else begin
                        qspi_rx_fifo_data_in_sysclk_o_r <= {
                            rx_data_sysclk_r[15:1], qspi_data_in_sysclk_i[1]
                        };

                    end
                end
                DUAL_SPI_MODE: begin
                    if (qspi_ctrl_trans_dir_sysclk_i == 2'b0) begin
                        qspi_rx_fifo_w_en_sysclk_o_r <= 1'b1;
                        if (qspi_ctrl_order_sysclk_i) begin
                            qspi_rx_fifo_data_in_sysclk_o_r <= {
                                8'd0, qspi_data_in_sysclk_i[1:0], rx_data_sysclk_r[7:2]
                            };
                        end else begin
                            qspi_rx_fifo_data_in_sysclk_o_r <= {
                                8'd0, rx_data_sysclk_r[5:0], qspi_data_in_sysclk_i[1:0]
                            };
                        end
                    end else begin
                        qspi_rx_fifo_w_en_sysclk_o_r <= 1'b0;
                        qspi_rx_fifo_data_in_sysclk_o_r <= '0;
                    end
                end
                QUAD_SPI_MODE: begin
                    if (qspi_ctrl_trans_dir_sysclk_i == 2'b0) begin
                        qspi_rx_fifo_w_en_sysclk_o_r <= 1'b1;
                        if (qspi_ctrl_order_sysclk_i) begin
                            qspi_rx_fifo_data_in_sysclk_o_r <= {
                                8'd0, qspi_data_in_sysclk_i[3:0], rx_data_sysclk_r[7:4]
                            };
                        end else begin
                            qspi_rx_fifo_data_in_sysclk_o_r <= {
                                8'd0, rx_data_sysclk_r[3:0], qspi_data_in_sysclk_i[3:0]
                            };
                        end
                    end else begin
                        qspi_rx_fifo_w_en_sysclk_o_r <= 1'b0;
                        qspi_rx_fifo_data_in_sysclk_o_r <= '0;
                    end
                end
            endcase
        end else begin
            qspi_rx_fifo_data_in_sysclk_o_r <= 16'd0;
            qspi_rx_fifo_w_en_sysclk_o_r <= 1'b0;
        end
    end


    //-----------------------------------
    // generate clk
    //-----------------------------------

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_sclk_out_sysclk_o_r <= 1'b0;
            qspi_sclk_out_en_sysclk_o_r <= 1'b0;
        end else if (master_detect) begin
            qspi_sclk_out_en_sysclk_o_r <= 1'b1;
            case (state_next)
                S_IDLE, S_FETCH: begin
                    qspi_sclk_out_sysclk_o_r <= qspi_ctrl_cpol_sysclk_i;
                end
                S_SEND, S_SEND_FETCH: begin
                    if (shift_edge_sysclk || sample_edge_sysclk) begin
                        qspi_sclk_out_sysclk_o_r <= ~qspi_sclk_out_sysclk_o_r;
                    end
                end
            endcase
        end else begin
            qspi_sclk_out_sysclk_o_r <= 1'b0;
            qspi_sclk_out_en_sysclk_o_r <= 1'b0;
        end
    end

    //-----------------------------------
    // generate csn
    //-----------------------------------

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_csn_out_sysclk_o_r <= '1;
            qspi_csn_out_en_sysclk_o_r <= '0;
        end else if (master_detect) begin
            qspi_csn_out_en_sysclk_o_r <= '1;
            if (qspi_cs_ctrl_cs_manual_en_sysclk_i) begin
                qspi_csn_out_sysclk_o_r <= set_csn(qspi_cs_ctrl_cs_manual_sysclk_i);
            end else begin
                qspi_csn_out_sysclk_o_r <= set_csn(state_next != S_IDLE);
            end
        end else begin
            qspi_csn_out_sysclk_o_r <= '1;
            qspi_csn_out_en_sysclk_o_r <= '0;
        end
    end

    function [3:0] set_csn(input data_in);
        case (qspi_cs_ctrl_cs_sel_sysclk_i)
            2'd0: set_csn = {3'b0, data_in};
            2'd1: set_csn = {2'b0, data_in, 1'b0};
            2'd2: set_csn = {1'b0, data_in, 2'b0};
            2'd3: set_csn = {data_in, 3'b0};
        endcase
    endfunction


    //-----------------------------------
    // spi_busy
    //-----------------------------------

    always_ff @(posedge sysclk or negedge srstn_sysclk) begin
        if (!srstn_sysclk) begin
            qspi_status_spi_busy_sysclk_o_r <= 1'b0;
        end else if (qspi_sw_reset_sw_rst_n_sysclk_i) begin
            qspi_status_spi_busy_sysclk_o_r <= 1'b0;
        end else begin
            qspi_status_spi_busy_sysclk_o_r <= (state_next != S_IDLE);
        end
    end


endmodule

`default_nettype wire
