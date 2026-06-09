`default_nettype none
module uart_tx (
    input  wire        sysclk,
    input  wire        sysrst_n,
    //config
    input  wire        i_break_send_sysclk,
    input  wire        i_uart_enable_sysclk,
    input  wire [ 3:0] i_conf_data_bit_width_sysclk,
    input  wire [ 1:0] i_conf_stop_bit_width_sel_sysclk,
    input  wire [ 1:0] i_conf_parity_bit_sysclk,
    input  wire        i_conf_tx_inv_sysclk,
    input  wire        i_conf_hw_flow_en_sysclk,
    input  wire        i_conf_samp_num_sel_sysclk,
    input  wire [ 1:0] i_conf_over_samp_sel_sysclk,
    input  wire [15:0] i_conf_clk_div_sysclk,
    //oversampel clk_en
    input  wire        i_over_samp_clken,
    //fifo signals
    output reg         o_fifo_ren_sysclkr,
    input  wire [ 8:0] i_fifo_rdata_sysclk,
    input  wire        i_fifo_rdata_valid_sysclk,
    input  wire        i_fifo_empty_sysclk,
    //status
    output reg         o_rx_busy_sysclkr,
    //uart signals
    output reg         o_uart_txd_sysclkr,
    input  wire        i_uart_ctsn_sysclk

);

    typedef enum logic [3:0] {
        S_IDLE,
        S_SEND_START,
        S_SEND_DATA,
        S_SEND_PARITY,
        S_SEND_STOP,
        S_SEND_BREAK
    } STATE_t;

    STATE_t state;
    STATE_t state_next;

    wire    hw_cts_en_sysclk;
    assign hw_cts_en_sysclk = i_conf_hw_flow_en_sysclk && i_uart_ctsn_sysclk;



    reg   [5:0] over_samp_cnt_sysclkr;
    reg   [5:0] over_samp_cnt_max_sysclkr;
    logic       send_bit_done_sysclk;

    reg   [3:0] send_data_bit_cnt_sysclkr;
    logic [3:0] send_data_bit_cnt_max_sysclk;
    logic       send_data_bit_done_sysclk;



    reg   [8:0] send_data_latch_sysclkr;
    logic [8:0] send_data_latch_mask_sysclk;


    logic       parity_even;
    logic       parity_odd;
    logic       parity_sel;



    reg         uart_txd_sysclkr;


    always_comb begin
        state_next = state;
        case (state)
            S_IDLE: begin
                if (!i_fifo_empty_sysclk && !hw_cts_en_sysclk) begin
                    state_next = S_SEND_START;
                end else if (i_break_send_sysclk && !hw_cts_en_sysclk) begin
                    state_next = S_SEND_BREAK;
                end
            end
            S_SEND_START: begin
                if (send_bit_done_sysclk) begin
                    state_next = S_SEND_DATA;
                end
            end
            S_SEND_DATA: begin
                if (send_data_bit_done_sysclk) begin
                    if (i_conf_parity_bit_sysclk != 00) begin  //if parity bit enable
                        state_next = S_SEND_PARITY;
                    end else begin
                        state_next = S_SEND_STOP;
                    end
                end
            end
            S_SEND_PARITY: begin
                if (send_bit_done_sysclk) begin
                    state_next = S_SEND_STOP;
                end
            end
            S_SEND_STOP: begin
                if (send_bit_done_sysclk) begin
                    state_next = S_IDLE;
                end
            end
            S_SEND_BREAK: begin
                if (!i_break_send_sysclk) begin
                    state_next = S_IDLE;
                end
            end
            default: begin
                state_next = S_IDLE;
            end
        endcase
        if (!i_uart_enable_sysclk) begin
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
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            over_samp_cnt_max_sysclkr <= '0;
        end else if ((state != S_SEND_STOP) || (state_next == S_SEND_STOP)) begin
            case (i_conf_stop_bit_width_sel_sysclk)
                2'b00: over_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr >> 1;
                2'b01: over_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr;
                2'b10:
                over_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr + (over_samp_cnt_max_sysclkr >>1);
                2'b11: over_samp_cnt_max_sysclkr <= over_samp_cnt_max_sysclkr << 1;
            endcase
        end else begin
            case (i_conf_over_samp_sel_sysclk)
                2'b00:   over_samp_cnt_max_sysclkr = 6'd8;  //8
                2'b01:   over_samp_cnt_max_sysclkr = 6'd16;  //16
                2'b10:   over_samp_cnt_max_sysclkr = 6'd32;  // 32
                default: over_samp_cnt_max_sysclkr = 6'd0;
            endcase
        end
    end


    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            over_samp_cnt_sysclkr <= '0;
        end else if (state_next == S_IDLE) begin
            over_samp_cnt_sysclkr <= '0;
        end else if (i_over_samp_clken) begin
            if (send_bit_done_sysclk) begin
                over_samp_cnt_sysclkr <= '0;
            end else begin
                over_samp_cnt_sysclkr <= over_samp_cnt_sysclkr + 1;
            end
        end
    end

    assign send_bit_done_sysclk = over_samp_cnt_sysclkr == (over_samp_cnt_max_sysclk - 1);

    //####################
    //send data bit cnt
    //####################
    always_comb begin
        case (i_conf_data_bit_width_sysclk)
            4'd5: send_data_bit_cnt_max_sysclk = 4'd5;
            4'd6: send_data_bit_cnt_max_sysclk = 4'd6;
            4'd7: send_data_bit_cnt_max_sysclk = 4'd7;
            4'd8: send_data_bit_cnt_max_sysclk = 4'd8;
            4'd9: send_data_bit_cnt_max_sysclk = 4'd9;
            default: send_data_bit_cnt_max_sysclk = 4'd0;
        endcase
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            send_data_bit_cnt_sysclkr <= '0;
        end else if (state_next == S_IDLE) begin
            send_data_bit_cnt_sysclkr <= '0;
        end else if (send_bit_done_sysclk) begin
            if (send_data_bit_done_sysclk) begin
                send_data_bit_cnt_sysclkr <= '0;
            end else begin
                send_data_bit_cnt_sysclkr <= send_data_bit_cnt_sysclkr + 1;
            end
        end
    end

    assign send_data_bit_done_sysclk = (send_data_bit_cnt_sysclkr == (send_data_bit_cnt_max_sysclk - 1));


    //####################
    //read tx fifo
    //####################
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            o_fifo_ren_sysclkr <= '0;
        end else begin
            o_fifo_ren_sysclkr <= (state == S_IDLE) && (state_next == S_SEND_START);
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            send_data_latch_sysclkr <= '0;
        end else if (i_fifo_rdata_valid_sysclk) begin
            send_data_latch_sysclkr <= i_fifo_rdata_sysclk;
        end
    end

    always_comb begin
        case (i_conf_data_bit_width_sysclk)
            4'd5: send_data_latch_mask_sysclk = send_data_latch_sysclkr & 9'h01F;
            4'd6: send_data_latch_mask_sysclk = send_data_latch_sysclkr & 9'h03F;
            4'd7: send_data_latch_mask_sysclk = send_data_latch_sysclkr & 9'h07F;
            4'd8: send_data_latch_mask_sysclk = send_data_latch_sysclkr & 9'h0FF;
            4'd9: send_data_latch_mask_sysclk = send_data_latch_sysclkr & 9'h1FF;
            default: send_data_latch_mask_sysclk = 9'h000;
        endcase
    end

    //####################
    //calcurate parity
    //####################
    always_comb begin
        parity_even = ^send_data_latch_mask_sysclk;
        parity_odd  = ~(^send_data_latch_mask_sysclk);
        parity_sel  = (i_conf_parity_bit_sysclk[0]) ? parity_odd : parity_even;
    end


    //####################
    //tx_data
    //####################
    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            uart_txd_sysclkr <= 1'd1;
        end else begin
            case (state_next)
                S_IDLE: begin
                    uart_txd_sysclkr <= 1'd1;
                end
                S_SEND_START: begin
                    uart_txd_sysclkr <= 1'd0;
                end
                S_SEND_DATA: begin
                    case (send_data_bit_cnt_sysclkr)
                        4'd0: uart_txd_sysclkr <= send_data_latch_sysclkr[0];
                        4'd1: uart_txd_sysclkr <= send_data_latch_sysclkr[1];
                        4'd2: uart_txd_sysclkr <= send_data_latch_sysclkr[2];
                        4'd3: uart_txd_sysclkr <= send_data_latch_sysclkr[3];
                        4'd4: uart_txd_sysclkr <= send_data_latch_sysclkr[4];
                        4'd5: uart_txd_sysclkr <= send_data_latch_sysclkr[5];
                        4'd6: uart_txd_sysclkr <= send_data_latch_sysclkr[6];
                        4'd7: uart_txd_sysclkr <= send_data_latch_sysclkr[7];
                        4'd8: uart_txd_sysclkr <= send_data_latch_sysclkr[8];
                        default uart_txd_sysclkr <= 1'b0;
                    endcase
                end
                S_SEND_PARITY: begin
                    uart_txd_sysclkr <= parity_sel;
                end
                S_SEND_STOP: begin
                    uart_txd_sysclkr <= 1'd1;
                end
                S_SEND_BREAK: begin
                    uart_txd_sysclkr <= 1'd0;
                end
            endcase
        end
    end

    always @(posedge sysclk or negedge sysrst_n) begin
        if (!sysrst_n) begin
            o_uart_txd_sysclkr <= 1'd1;
        end else begin
            o_uart_txd_sysclkr <= (i_conf_tx_inv_sysclk) ? ~uart_txd_sysclkr : uart_txd_sysclkr;
        end
    end

endmodule

`default_nettype wire
