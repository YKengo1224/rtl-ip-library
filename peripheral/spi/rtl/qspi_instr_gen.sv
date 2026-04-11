`default_nettype none
module qspi_instr_gen (
    input              aclk,
    input              arestn,
    //tx_fifo status
    input  logic       qspi_status_tx_fifo_empty_aclk_i,
    input  logic       qspi_status_tx_fifo_full_aclk_i,
    input  logic [4:0] qspi_status_tx_fifo_available_aclk_i,
    //rx_fifo status
    input  logic       qspi_status_rx_fifo_empty_aclk_i,
    input  logic       qspi_status_rx_fifo_full_aclk_i,
    input  logic [4:0] qspi_status_rx_fifo_num_aclk_i,
    // data
    input  logic       qspi_tx_data_write_trigger_aclk_i,
    input  logic       qspi_rx_data_write_trigger_aclk_i,
    // slave signal                       
    input  logic       qspi_int_rx_fifo_overflow_aclk_i,
    input  logic       qspi_int_tx_fifo_overflow_aclk_i,
    input  logic       qspi_int_rx_fifo_threshold_aclk_i,
    input  logic       qspi_int_tx_fifo_threshold_aclk_i,
    input  logic       qspi_int_rx_fifo_not_empty_aclk_i,
    input  logic       qspi_int_tx_fifo_empty_aclk_i,
    // input  logic       qspi_int_ms_rx_fifo_overflow_aclk_i,
    // input  logic       qspi_int_ms_tx_fifo_overflow_aclk_i,
    // input  logic       qspi_int_ms_rx_fifo_threshold_aclk_i,
    // input  logic       qspi_int_ms_tx_fifo_threshold_aclk_i,
    // input  logic       qspi_int_ms_rx_fifo_not_empty_aclk_i,
    // input  logic       qspi_int_ms_tx_fifo_empty_aclk_i,
    input  logic [4:0] qspi_rx_threshold_level_aclk_i,
    input  logic [4:0] qspi_tx_threshold_level_aclk_i,
    output logic       qspi_int_rs_rx_fifo_overflow_aclk_o_r,
    output logic       qspi_int_rs_tx_fifo_overflow_aclk_o_r,
    output logic       qspi_int_rs_rx_fifo_threshold_aclk_o_r,
    output logic       qspi_int_rs_tx_fifo_threshold_aclk_o_r,
    output logic       qspi_int_rs_rx_fifo_not_empty_aclk_o_r,
    output logic       qspi_int_rs_tx_fifo_empty_aclk_o_r,
    // instr signal
    output logic       qspi_instr_aclk_o_r
);


    logic qspi_int_rs_rx_fifo_overflow_aclk;
    logic qspi_int_rs_tx_fifo_overflow_aclk;
    logic qspi_int_rs_rx_fifo_threshold_aclk;
    logic qspi_int_rs_tx_fifo_threshold_aclk;
    logic qspi_int_rs_rx_fifo_not_empty_aclk;
    logic qspi_int_rs_tx_fifo_empty_aclk;


    logic qspi_int_ms_rx_fifo_overflow_aclk;
    logic qspi_int_ms_tx_fifo_overflow_aclk;
    logic qspi_int_ms_rx_fifo_threshold_aclk;
    logic qspi_int_ms_tx_fifo_threshold_aclk;
    logic qspi_int_ms_rx_fifo_not_empty_aclk;
    logic qspi_int_ms_tx_fifo_empty_aclk;

    always_comb begin
        qspi_int_rs_rx_fifo_overflow_aclk = (qspi_rx_ffio_full_rclk_i && qspi_rx_data_write_trigger_aclk_i);
        qspi_int_rs_tx_fifo_overflow_aclk = (qspi_tx_ffio_full_rclk_i && qspi_tx_data_write_trigger_aclk_i);
        qspi_int_rs_rx_fifo_threshold_aclk = (qspi_status_rx_fifo_num_aclk_i <= qspi_rx_threshold_level_aclk_i);
        qspi_int_rs_tx_fifo_threshold_aclk = (qspi_status_tx_fifo_available_aclk_i <= qspi_tx_threshold_level_aclk_i);
        qspi_int_rs_rx_fifo_not_empty_aclk = !qspi_status_rx_fifo_empty_aclk_i;
        qspi_int_rs_tx_fifo_empty_aclk = qspi_status_tx_fifo_empty_aclk_i;
    end


    always_comb begin
        qspi_int_ms_rx_fifo_overflow_aclk  = qspi_int_rx_fifo_overflow_aclk_i  &  qspi_int_rs_rx_fifo_overflow_aclk;
        qspi_int_ms_tx_fifo_overflow_aclk  = qspi_int_tx_fifo_overflow_aclk_i  &  qspi_int_rs_tx_fifo_overflow_aclk;
        qspi_int_ms_rx_fifo_threshold_aclk = qspi_int_rx_fifo_threshold_aclk_i & qspi_int_rs_rx_fifo_threshold_aclk;
        qspi_int_ms_tx_fifo_threshold_aclk = qspi_int_tx_fifo_threshold_aclk_i & qspi_int_rs_tx_fifo_threshold_aclk;
        qspi_int_ms_rx_fifo_not_empty_aclk = qspi_int_rx_fifo_not_empty_aclk_i & qspi_int_rs_rx_fifo_not_empty_aclk;
        qspi_int_ms_tx_fifo_empty_aclk     = qspi_int_tx_fifo_empty_aclk_i     & qspi_int_rs_tx_fifo_empty_aclk;
    end


    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            qspi_int_rs_rx_fifo_overflow_aclk_o_r <= 1'b0;
            qspi_int_rs_tx_fifo_overflow_aclk_o_r <= 1'b0;
            qspi_int_rs_rx_fifo_threshold_aclk_o_r <= 1'b0;
            qspi_int_rs_tx_fifo_threshold_aclk_o_r <= 1'b0;
            qspi_int_rs_rx_fifo_not_empty_aclk_o_r <= 1'b0;
            qspi_int_rs_tx_fifo_empty_aclk_o_r <= 1'b0;
        end else begin
            qspi_int_rs_rx_fifo_overflow_aclk_o_r  <= qspi_int_rs_rx_fifo_overflow_aclk;
            qspi_int_rs_tx_fifo_overflow_aclk_o_r  <= qspi_int_rs_tx_fifo_overflow_aclk;
            qspi_int_rs_rx_fifo_threshold_aclk_o_r <= qspi_int_rs_rx_fifo_threshold_aclk;
            qspi_int_rs_tx_fifo_threshold_aclk_o_r <= qspi_int_rs_tx_fifo_threshold_aclk;
            qspi_int_rs_rx_fifo_not_empty_aclk_o_r <= qspi_int_rs_rx_fifo_not_empty_aclk;
            qspi_int_rs_tx_fifo_empty_aclk_o_r     <= qspi_int_rs_tx_fifo_empty_aclk;
        end
    end


    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            qspi_instr_aclk_o_r <= 1'b0;
        end else begin
            qspi_instr_aclk_o_r <= qspi_int_ms_rx_fifo_overflow_aclk
                | qspi_int_ms_tx_fifo_overflow_aclk
                | qspi_int_ms_rx_fifo_threshold_aclk
                | qspi_int_ms_tx_fifo_threshold_aclk
                | qspi_int_ms_rx_fifo_not_empty_aclk
                | qspi_int_ms_tx_fifo_empty_aclk;
        end

    end



endmodule

`default_nettype wire
