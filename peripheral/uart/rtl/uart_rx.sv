`default_nettype none

module uart_rx (
    input  wire       sysclk,
    input  wire       sysrst_n,
    //config
    input  wire       i_uart_enable_sysclk,
    input  wire [3:0] i_conf_data_bit_width_sysclk,
    input  wire [1:0] i_conf_stop_bit_width_sel_sysclk,
    input  wire [1:0] i_conf_parity_bit_sysclk,
    input  wire       i_conf_rx_inv_sysclk,
    input  wire       i_conf_hw_flow_en_sysclk,
    input  wire       i_conf_samp_num_sel_sysclk,
    input  wire [1:0] i_conf_over_samp_sel_sysclk,
    //oversampel clk_en
    input  wire       i_over_samp_clken_sysclk,
    //fifo signals
    output reg        o_fifo_wen_sysclkr,
    output reg  [8:0] o_fifo_wdata_sysclkr,
    input  wire       i_fifo_empty_sysclk,
    input  wire       i_fifo_full_sysclk,
    input  wire       i_fifo_almost_full_sysclk,
    //status
    output reg        o_rx_busy_sysclkr,
    output reg        o_rx_framing_err_trig_sysclkr,
    output reg        o_rx_parity_err_trig_sysclkr,
    output reg        o_rx_overrun_err_tirg_sysclkr,
    output reg        o_rx_detect_timeout_tirg_sysclkr,
    output reg        o_rx_detect_break_sysclkr,
    //uart signals
    input  wire       i_uart_rxd_sysclk,
    output reg        o_uart_rtsn_sysclk
);


    typedef enum logic [3:0] {
        S_IDLE,
        S_JUDGE_START,
        S_D_WAIT_SAMPLE,
        S_D_SAMPLE,
        S_P_WAIT_SAMPLE,
        S_P_SAMPLE,
        S_S_WAIT_SAMPLE,
        S_S_SAMPLE,
        S_JUDGE_ERROR,
        S_DEC_BREAK
    } STATE_t;

    STATE_t state;
    STATE_t state_next;

    logic uart_rxd_sysclk;

    reg [5:0] over_samp_cnt_sysclkr;
    reg [5:0] over_samp_cnt_max_sysclkr;
    reg [5:0] over_stop_samp_cnt_max_sysclkr;
    logic sample_rx_bit_done_sysclk;

    //sample start bit signals
    logic [1:0] detect_start_bit_sysclk; // 0:detect busy 1: detect(->S_D_WAIT_SAMPLE) ,2:not detect(->S_IDLE)
    logic [5:0] detect_start_bit_criteria_sysclk;
    reg [5:0] judge_start_latch_cnt_sysclkr;

    //sample signals
    reg [1:0] sample_bit_sysclkr;
    logic sample_bit_trig_sysclk;
    logic sample_bit_judge_sysclk;

    //sample data signals
    reg [5:0] sample_data_bit_cnt_sysclkr;
    logic [5:0] sample_data_bit_cnt_max_sysclk;
    logic sample_data_done_sysclk;
    reg [8:0] sample_data_latch_sysclkr;
    logic [8:0] sample_data_latch_mask_sysclk;


    //sample  parity signals
    reg data_parity_sysclkr;
    reg sample_parity_bit_sysclkr;

    //stop data signal
    reg sample_stop_bit_sysclkr;
    logic rx_detect_break_sysclk;


    //check timeout
    localparam int TIMEOUT_CNT_MAX = 32 * 12 * 4;  //over sample_num * bitnum * data nnnnum
    reg   [$clog2(TIMEOUT_CNT_MAX):0] over_samp_timeout_cnt_sysclkr;
    reg   [$clog2(TIMEOUT_CNT_MAX):0] over_samp_timeout_cnt_max_sysclkr;
    logic                               detect_timeout_tirg_sysclk;




    always_comb begin
        if (i_conf_rx_inv_sysclk) begin
            uart_rxd_sysclk = ~i_uart_rxd_sysclk;
        end else begin
            uart_rxd_sysclk = i_uart_rxd_sysclk;
        end
    end

    always_comb begin
        state_next = state;
        case (state)
            S_IDLE: begin
                if (uart_rxd_sysclk != 0) begin
                    state_next = S_JUDGE_START;
                end
            end
            S_JUDGE_START: begin
                case (detect_start_bit_sysclk)
                    2'b01: state_next = S_D_WAIT_SAMPLE;
                    2'b10: state_next = S_IDLE;
                endcase
            end
            S_D_WAIT_SAMPLE: begin
                if (sample_data_done_sysclk) begin
                end
            end
            S_D_SAMPLE: begin
                if (sample_data_bit_cnt_sysclkr == '0) begin
                    if (i_conf_parity_bit_sysclk == 2'b00) begin
                        state_next = S_S_WAIT_SAMPLE;
                    end else begin
                        state_next = S_P_WAIT_SAMPLE;
                    end
                end else begin
                    state_next = S_D_WAIT_SAMPLE;
                end
            end
            S_P_WAIT_SAMPLE: begin
                if (sample_rx_bit_done_sysclk) begin
                    state_next = S_P_SAMPLE;
                end
            end
            S_P_SAMPLE: begin
                state_next = S_S_WAIT_SAMPLE;
            end
            S_S_WAIT_SAMPLE: begin
                if (sample_rx_bit_done_sysclk) begin
                    state_next = S_S_SAMPLE;
                end
            end
            S_S_SAMPLE: begin
                state_next = S_JUDGE_ERROR;
            end
            S_JUDGE_ERROR: begin
                if (rx_detect_break_sysclk) begin
                    state_next = S_DEC_BREAK;
                end else begin
                    state_next = S_IDLE;
                end
            end
            S_DEC_BREAK: begin
                if (uart_rxd_sysclk) begin
                    state_next = S_IDLE;
                end
            end
        endcase
        if (i_uart_enable_sysclk) begin
            state_next = S_IDLE;
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            state <= S_IDLE;
        end else begin
            state <= state_next;
        end
    end

    //####################
    //over samp cnt
    //####################
    always_comb begin
        case (i_conf_stop_bit_width_sel_sysclk)
            2'b00: over_stop_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr >> 1;
            2'b01: over_stop_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr;
            2'b10:
            over_stop_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr + (over_samp_cnt_max_sysclkr >>1);
            2'b11: over_stop_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr << 1;
        endcase
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            over_samp_cnt_max_sysclkr <= '0;
        end else if (state_next == S_S_WAIT_SAMPLE) begin
            over_samp_cnt_max_sysclkr <= (over_samp_cnt_max_sysclkr >> 1) + (over_stop_samp_cnt_max_sysclkr >> 1);
        end else begin
            case (i_conf_over_samp_sel_sysclk)
                2'b00:   over_samp_cnt_max_sysclkr <= 6'd8;  //8
                2'b01:   over_samp_cnt_max_sysclkr <= 6'd16;  //16
                2'b10:   over_samp_cnt_max_sysclkr <= 6'd32;  // 32
                default: over_samp_cnt_max_sysclkr <= 6'd0;
            endcase
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            over_samp_cnt_sysclkr <= '0;
        end else if (state_next == S_IDLE) begin
            over_samp_cnt_sysclkr <= '0;
        end else if (i_over_samp_clken_sysclk) begin
            if (sample_rx_bit_done_sysclk) begin
                over_samp_cnt_sysclkr <= '0;
            end else if ((state == S_JUDGE_START) && (state_next == S_D_WAIT_SAMPLE)) begin
                over_samp_cnt_sysclkr <= '0;
            end else begin
                over_samp_cnt_sysclkr <= over_samp_cnt_sysclkr + 1;
            end
        end
    end

    assign sample_rx_bit_done_sysclk = (over_samp_cnt_sysclkr == (over_samp_cnt_max_sysclk - 1));

    //####################
    //detect start bit
    //####################
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            judge_start_latch_cnt_sysclkr <= '0;
        end else if (state == S_JUDGE_START) begin
            if (i_over_samp_clken_sysclk) begin
                judge_start_latch_cnt_sysclkr <= judge_start_latch_cnt_sysclkr + ~uart_txd_sysclk;
            end else begin
                judge_start_latch_cnt_sysclkr <= judge_start_latch_cnt_sysclkr;
            end
        end else begin
            judge_start_latch_cnt_sysclkr <= '0;
        end
    end


    assign detect_start_bit_criteria_sysclk = 3 << i_conf_over_samp_sel_sysclk;


    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            detect_start_bit_sysclkr <= '0;
        end else if (state == S_JUDGE_START) begin
            if (over_samp_cnt_sysclkr == (over_samp_cnt_max_sysclkr >> 1)) begin
                if (judge_start_latch_cnt_sysclkr >= detect_start_bit_criteria_sysclk) begin
                    detect_start_bit_sysclkr <= 2'b01;
                end else begin
                    detect_start_bit_sysclkr <= 2'b10;
                end
            end else begin
                detect_start_bit_sysclkr <= '0;
            end
        end
    end


    //####################
    //sample bit
    //####################

    always_comb begin
        if (i_conf_samp_num_sel_sysclk) begin  //3
            sample_bit_trig_sysclk = i_over_samp_clken_sysclk && 
                                    ((over_samp_cnt_sysclkr == (over_samp_cnt_max_sysclk - 3))  ||
                                     (over_samp_cnt_sysclkr == (over_samp_cnt_max_sysclk - 2))  ||
                                     (over_samp_cnt_sysclkr == (over_samp_cnt_max_sysclk - 1)));
        end else begin
            sample_bit_trig_sysclk = sample_rx_bit_done_sysclk;
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            sample_bit_sysclkr <= 2'b0;
        end else if ((state_next == S_D_WAIT_SAMPLE) || (state_next == S_P_WAIT_SAMPLE) || (state_next == S_S_WAIT_SAMPLE)) begin
            if (sample_bit_trig_sysclk) begin
                sample_bit_sysclkr <= sample_bit_sysclkr + uart_rxd_sysclk;
            end else begin
                sample_bit_sysclkr <= sample_bit_sysclkr;
            end
        end else begin
            sample_bit_sysclkr <= 2'b0;
        end
    end

    always_comb begin
        if (i_conf_samp_num_sel_sysclk) begin
            if (sample_bit_sysclkr >= 2'b10) begin
                sample_bit_judge_sysclk = 1'b1;
            end else begin
                sample_bit_judge_sysclk = 1'b0;
            end
        end else begin
            sample_bit_judge_sysclk = uart_rxd_sysclk;
        end
    end


    //####################
    //sample data
    //####################
    always_comb begin
        case (i_conf_data_bit_width_sysclk)
            4'd5: sample_data_bit_cnt_max_sysclk = 4'd5;
            4'd6: sample_data_bit_cnt_max_sysclk = 4'd6;
            4'd7: sample_data_bit_cnt_max_sysclk = 4'd7;
            4'd8: sample_data_bit_cnt_max_sysclk = 4'd8;
            4'd9: sample_data_bit_cnt_max_sysclk = 4'd9;
            default: sample_data_bit_cnt_max_sysclk = 4'd0;
        endcase
    end


    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            sample_data_bit_cnt_sysclkr <= '0;
        end else if ((state == S_D_WAIT_SAMPLE) && (state == S_D_SAMPLE)) begin
            if (sample_rx_bit_done_sysclk) begin
                if (sample_data_done_sysclk) begin
                    sample_data_bit_cnt_sysclkr <= '0;
                end else begin
                    sample_data_bit_cnt_sysclkr <= sample_data_bit_cnt_sysclkr + 'd1;
                end
            end else begin
                sample_data_bit_cnt_sysclkr <= sample_data_bit_cnt_sysclkr;
            end
        end else begin
            sample_data_bit_cnt_sysclkr <= '0;
        end
    end

    assign sample_data_done_sysclk = (sample_data_bit_cnt_sysclkr == (sample_data_bit_cnt_max_sysclk - 1));



    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            sample_data_latch_sysclkr <= '0;
        end else if (state == S_IDLE) begin
            sample_data_latch_sysclkr <= '0;
        end else if (state == S_D_SAMPLE) begin
            sample_data_latch_sysclkr = {
                sample_data_latch_sysclkr[8:0], sample_data_bit_judge_sysclk
            };
        end else begin
            sample_data_latch_sysclkr <= sample_data_latch_sysclkr;
        end
    end

    always_comb begin
        case (i_conf_data_bit_width_sysclk)
            4'd5: sample_data_latch_mask_sysclk = sample_data_latch_sysclkr & 9'h01F;
            4'd6: sample_data_latch_mask_sysclk = sample_data_latch_sysclkr & 9'h03F;
            4'd7: sample_data_latch_mask_sysclk = sample_data_latch_sysclkr & 9'h07F;
            4'd8: sample_data_latch_mask_sysclk = sample_data_latch_sysclkr & 9'h0FF;
            4'd9: sample_data_latch_mask_sysclk = sample_data_latch_sysclkr & 9'h1FF;
            default: sample_data_latch_mask_sysclk = 9'h000;
        endcase
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            data_parity_sysclkr <= 1'b0;
        end else if (state == S_IDLE) begin
            data_parity_sysclkr <= 1'b0;
        end else if (state == S_P_SAMPLE) begin
            if (i_conf_parity_bit_sysclk[0]) begin
                data_parity_sysclkr <= ^sample_data_latch_mask_sysclk;  //odd 
            end else begin
                data_parity_sysclkr <= ~sample_data_latch_mask_sysclk;  //even
            end
        end else begin
            data_parity_sysclkr <= data_parity_sysclkr;
        end
    end

    //####################
    //sample parity bit
    //####################    
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            sample_parity_bit_sysclkr <= 1'b0;
        end else if (state == S_IDLE) begin
            sample_parity_bit_sysclkr <= 1'b0;
        end else if (state == S_P_SAMPLE) begin
            sample_parity_bit_sysclkr <= sample_bit_judge_sysclk;
        end else begin
            sample_parity_bit_sysclkr <= sample_parity_bit_sysclkr;
        end
    end


    //####################
    //sample stop bit
    //####################
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            sample_stop_bit_sysclkr <= 1'b0;
        end else if (state == S_IDLE) begin
            sample_stop_bit_sysclkr <= 1'b0;
        end else if (state == S_P_SAMPLE) begin
            sample_stop_bit_sysclkr <= sample_bit_judge_sysclk;
        end else begin
            sample_stop_bit_sysclkr <= sample_stop_bit_sysclkr;
        end
    end

    //####################
    //judge error
    //####################
    always_comb begin
        if(!(|sample_data_latch_sysclkr) && !sample_parity_bit_sysclkr && !sample_stop_bit_sysclkr) begin
            rx_detect_break_sysclk = 1'b1;
        end else begin
            rx_detect_break_sysclk = 1'b0;
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            o_rx_framing_err_trig_sysclkr <= 1'b0;
            o_rx_parity_err_trig_sysclkr  <= 1'b0;
            o_rx_overrun_err_tirg_sysclkr <= 1'b0;

        end else if (state == S_JUDGE_ERROR) begin
            if (rx_detect_break_sysclk) begin
                o_rx_framing_err_trig_sysclkr <= 1'b0;
                o_rx_parity_err_trig_sysclkr  <= 1'b0;
                o_rx_overrun_err_tirg_sysclkr <= 1'b0;
            end else if (sample_stop_bit_sysclkr != 1'b1) begin
                o_rx_framing_err_trig_sysclkr <= 1'b1;
                o_rx_parity_err_trig_sysclkr  <= 1'b0;
                o_rx_overrun_err_tirg_sysclkr <= 1'b0;
            end else if (sample_parity_bit_sysclkr != data_parity_sysclkr) begin
                o_rx_framing_err_trig_sysclkr <= 1'b0;
                o_rx_parity_err_trig_sysclkr  <= 1'b1;
                o_rx_overrun_err_tirg_sysclkr <= 1'b0;
            end else if (i_fifo_full_sysclk) begin
                o_rx_framing_err_trig_sysclkr <= 1'b0;
                o_rx_parity_err_trig_sysclkr  <= 1'b0;
                o_rx_overrun_err_tirg_sysclkr <= 1'b1;
            end
        end else begin
            o_rx_framing_err_trig_sysclkr <= 1'b0;
            o_rx_parity_err_trig_sysclkr  <= 1'b0;
            o_rx_overrun_err_tirg_sysclkr <= 1'b0;
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            o_rx_detect_break_sysclkr <= 1'b0;
        end else if (state_next == S_DEC_BREAK) begin
            o_rx_detect_break_sysclkr <= 1'b1;
        end else begin
            o_rx_detect_break_sysclkr <= 1'b0;
        end
    end


    //####################
    //fifo signals
    //####################
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            o_fifo_wen_sysclkr   <= 1'b0;
            o_fifo_wdata_sysclkr <= '0;
        end else if ((state == S_JUDGE_ERROR) && 
                     !o_rx_framing_err_trig_sysclkr && 
                     !o_rx_parity_err_trig_sysclkr &&
                     !o_rx_overrun_err_tirg_sysclkr
        ) begin
            o_fifo_wen_sysclkr   <= 1'b0;
            o_fifo_wdata_sysclkr <= sample_data_latch_mask_sysclk;
        end else begin
            o_fifo_wen_sysclkr   <= 1'b0;
            o_fifo_wdata_sysclkr <= '0;
        end
    end


    //####################
    //hw flow signal
    //####################
    assign o_uart_rtsn_sysclk = i_fifo_almost_full_sysclk;


    //####################
    //theck timeout
    //####################
    assign detect_timeout_tirg_sysclk = over_samp_timeout_cnt_sysclkr == (TIMEOUT_CNT_MAX - 1);
   
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            over_samp_timeout_cnt_sysclkr <= '0;
        end else if ((state_next == S_IDLE) && i_fifo_empty_sysclk) begin
            if (i_over_samp_clken_sysclk) begin
                if (detect_timeout_tirg_sysclk) begin
                    over_samp_timeout_cnt_sysclkr <= '0;
                end else begin
                    over_samp_timeout_cnt_sysclkr <= over_samp_timeout_cnt_sysclkr + 'd1;
                end
            end
        end else begin
            over_samp_cnt_sysclkr <= '0;
        end
    end

endmodule
`default_nettype wire
