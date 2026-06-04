`default_nettype none
module qspi_instr_gen #(
    parameter FIFO_SIZE = 32
) (
    input wire                       aclk,
    input wire                       aresetn,
    //tx_fifo status
    input wire                       qspi_status_tx_fifo_empty_aclk_i,
    input wire                       qspi_status_tx_fifo_full_aclk_i,
    input wire [$clog2(FIFO_SIZE):0] qspi_status_tx_fifo_available_aclk_i,
    //rx_fifo status
    input wire                       qspi_status_rx_fifo_empty_aclk_i,
    input wire                       qspi_status_rx_fifo_full_aclk_i,
    input wire [$clog2(FIFO_SIZE):0] qspi_status_rx_fifo_num_aclk_i,
    // data
    input wire                       qspi_data_tx_data_write_trigger_aclk_i,
    input wire                       qspi_data_rx_data_write_trigger_aclk_i,
    // slave signal                       
    input wire                       qspi_int_rx_fifo_overflow_aclk_i,
    input wire                       qspi_int_tx_fifo_overflow_aclk_i,
    input wire                       qspi_int_rx_fifo_threshold_aclk_i,
    input wire                       qspi_int_tx_fifo_threshold_aclk_i,
    input wire                       qspi_int_rx_fifo_not_empty_aclk_i,
    input wire                       qspi_int_tx_fifo_empty_aclk_i,

    input wire [4:0] qspi_threshold_level_rx_threshold_level_aclk_i,
    input wire [4:0] qspi_threshold_level_tx_threshold_level_aclk_i,

    input wire qspi_int_ms_rx_fifo_overflow_crear_trigger_aclk_i,
    input wire qspi_int_ms_tx_fifo_overflow_crear_trigger_aclk_i,
    input wire qspi_int_ms_rx_fifo_threshold_crear_trigger_aclk_i,
    input wire qspi_int_ms_tx_fifo_threshold_crear_trigger_aclk_i,
    input wire qspi_int_ms_rx_fifo_not_empty_crear_trigger_aclk_i,
    input wire qspi_int_ms_tx_fifo_empty_crear_trigger_aclk_i,


    output logic qspi_int_rs_rx_fifo_overflow_aclk_o_r,
    output logic qspi_int_rs_tx_fifo_overflow_aclk_o_r,
    output logic qspi_int_rs_rx_fifo_threshold_aclk_o_r,
    output logic qspi_int_rs_tx_fifo_threshold_aclk_o_r,
    output logic qspi_int_rs_rx_fifo_not_empty_aclk_o_r,
    output logic qspi_int_rs_tx_fifo_empty_aclk_o_r,

    output logic qspi_int_ms_rx_fifo_overflow_aclk_o_r,
    output logic qspi_int_ms_tx_fifo_overflow_aclk_o_r,
    output logic qspi_int_ms_rx_fifo_threshold_aclk_o_r,
    output logic qspi_int_ms_tx_fifo_threshold_aclk_o_r,
    output logic qspi_int_ms_rx_fifo_not_empty_aclk_o_r,
    output logic qspi_int_ms_tx_fifo_empty_aclk_o_r,
    // instr signal
    output logic qspi_instr_aclk_o_r
);




    logic rx_fifo_overflow_aclk_prev;
    logic tx_fifo_overflow_aclk_prev;
    logic rx_fifo_threshold_aclk_prev;
    logic tx_fifo_threshold_aclk_prev;
    logic rx_fifo_not_empty_aclk_prev;
    logic tx_fifo_empty_aclk_prev;

    logic rx_fifo_overflow_aclk;
    logic tx_fifo_overflow_aclk;
    logic rx_fifo_threshold_aclk;
    logic tx_fifo_threshold_aclk;
    logic rx_fifo_not_empty_aclk;
    logic tx_fifo_empty_aclk;


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
        rx_fifo_overflow_aclk = (qspi_status_rx_fifo_full_aclk_i && qspi_data_rx_data_write_trigger_aclk_i);
        tx_fifo_overflow_aclk = (qspi_status_tx_fifo_full_aclk_i && qspi_data_tx_data_write_trigger_aclk_i);
        rx_fifo_threshold_aclk = (qspi_status_rx_fifo_num_aclk_i >= qspi_threshold_level_rx_threshold_level_aclk_i);
        tx_fifo_threshold_aclk = (qspi_status_tx_fifo_available_aclk_i >= qspi_threshold_level_tx_threshold_level_aclk_i);
        rx_fifo_not_empty_aclk = !qspi_status_rx_fifo_empty_aclk_i;
        tx_fifo_empty_aclk = qspi_status_tx_fifo_empty_aclk_i;
    end

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rx_fifo_overflow_aclk_prev <= 1'b0;
            tx_fifo_overflow_aclk_prev <= 1'b0;
            rx_fifo_threshold_aclk_prev <= 1'b0;
            tx_fifo_threshold_aclk_prev <= 1'b1;
            rx_fifo_not_empty_aclk_prev <= 1'b0;
            tx_fifo_empty_aclk_prev <= 1'b1;
        end else begin
            rx_fifo_overflow_aclk_prev <= rx_fifo_overflow_aclk;
            tx_fifo_overflow_aclk_prev <= tx_fifo_overflow_aclk;
            rx_fifo_threshold_aclk_prev <= rx_fifo_threshold_aclk;
            tx_fifo_threshold_aclk_prev <= tx_fifo_threshold_aclk;
            rx_fifo_not_empty_aclk_prev <= rx_fifo_not_empty_aclk;
            tx_fifo_empty_aclk_prev <= tx_fifo_empty_aclk;
        end
    end

    //qspi_int_rs
    always_comb begin
        qspi_int_rs_rx_fifo_overflow_aclk = qspi_int_rs_rx_fifo_overflow_aclk_o_r;
        if (qspi_int_ms_rx_fifo_overflow_crear_trigger_aclk_i) begin
            qspi_int_rs_rx_fifo_overflow_aclk = 1'b0;
        end else if (!rx_fifo_overflow_aclk_prev && rx_fifo_overflow_aclk) begin
            qspi_int_rs_rx_fifo_overflow_aclk = 1'b1;
        end
    end

    always_comb begin
        qspi_int_rs_tx_fifo_overflow_aclk = qspi_int_rs_tx_fifo_overflow_aclk_o_r;
        if (qspi_int_ms_tx_fifo_overflow_crear_trigger_aclk_i) begin
            qspi_int_rs_tx_fifo_overflow_aclk = 1'b0;
        end else if (!tx_fifo_overflow_aclk_prev && tx_fifo_overflow_aclk) begin
            qspi_int_rs_tx_fifo_overflow_aclk = 1'b1;
        end
    end


    always_comb begin
        qspi_int_rs_rx_fifo_threshold_aclk = qspi_int_rs_rx_fifo_threshold_aclk_o_r;
        if (qspi_int_ms_rx_fifo_threshold_crear_trigger_aclk_i) begin
            qspi_int_rs_rx_fifo_threshold_aclk = 1'b0;
        end else if (!rx_fifo_threshold_aclk_prev && rx_fifo_threshold_aclk) begin
            qspi_int_rs_rx_fifo_threshold_aclk = 1'b1;
        end
    end


    always_comb begin
        qspi_int_rs_tx_fifo_threshold_aclk = qspi_int_rs_tx_fifo_threshold_aclk_o_r;
        if (qspi_int_ms_tx_fifo_threshold_crear_trigger_aclk_i) begin
            qspi_int_rs_tx_fifo_threshold_aclk = 1'b0;
        end else if (!tx_fifo_threshold_aclk_prev && tx_fifo_threshold_aclk) begin
            qspi_int_rs_tx_fifo_threshold_aclk = 1'b1;
        end
    end


    always_comb begin
        qspi_int_rs_rx_fifo_not_empty_aclk = qspi_int_rs_rx_fifo_not_empty_aclk_o_r;
        if (qspi_int_ms_rx_fifo_not_empty_crear_trigger_aclk_i) begin
            qspi_int_rs_rx_fifo_not_empty_aclk = 1'b0;
        end else if (!rx_fifo_not_empty_aclk_prev && rx_fifo_not_empty_aclk) begin
            qspi_int_rs_rx_fifo_not_empty_aclk = 1'b1;
        end
    end


    always_comb begin
        qspi_int_rs_tx_fifo_empty_aclk = qspi_int_rs_tx_fifo_empty_aclk_o_r;
        if (qspi_int_ms_tx_fifo_empty_crear_trigger_aclk_i) begin
            qspi_int_rs_tx_fifo_empty_aclk = 1'b0;
        end else if (!tx_fifo_empty_aclk_prev && tx_fifo_empty_aclk) begin
            qspi_int_rs_tx_fifo_empty_aclk = 1'b1;
        end
    end



    always_comb begin
        qspi_int_ms_rx_fifo_overflow_aclk = qspi_int_rx_fifo_overflow_aclk_i  &  qspi_int_rs_rx_fifo_overflow_aclk;
        qspi_int_ms_tx_fifo_overflow_aclk = qspi_int_tx_fifo_overflow_aclk_i  &  qspi_int_rs_tx_fifo_overflow_aclk;
        qspi_int_ms_rx_fifo_threshold_aclk =qspi_int_rx_fifo_threshold_aclk_i & qspi_int_rs_rx_fifo_threshold_aclk;
        qspi_int_ms_tx_fifo_threshold_aclk =qspi_int_tx_fifo_threshold_aclk_i & qspi_int_rs_tx_fifo_threshold_aclk;
        qspi_int_ms_rx_fifo_not_empty_aclk =qspi_int_rx_fifo_not_empty_aclk_i & qspi_int_rs_rx_fifo_not_empty_aclk;
        qspi_int_ms_tx_fifo_empty_aclk     = qspi_int_tx_fifo_empty_aclk_i     & qspi_int_rs_tx_fifo_empty_aclk;
    end


    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            qspi_int_ms_rx_fifo_overflow_aclk_o_r <= 1'b0;
            qspi_int_ms_tx_fifo_overflow_aclk_o_r <= 1'b0;
            qspi_int_ms_rx_fifo_threshold_aclk_o_r <= 1'b0;
            qspi_int_ms_tx_fifo_threshold_aclk_o_r <= 1'b0;
            qspi_int_ms_rx_fifo_not_empty_aclk_o_r <= 1'b0;
            qspi_int_ms_tx_fifo_empty_aclk_o_r <= 1'b0;


            qspi_int_rs_rx_fifo_overflow_aclk_o_r <= 1'b0;
            qspi_int_rs_tx_fifo_overflow_aclk_o_r <= 1'b0;
            qspi_int_rs_rx_fifo_threshold_aclk_o_r <= 1'b0;
            qspi_int_rs_tx_fifo_threshold_aclk_o_r <= 1'b0;
            qspi_int_rs_rx_fifo_not_empty_aclk_o_r <= 1'b0;
            qspi_int_rs_tx_fifo_empty_aclk_o_r <= 1'b0;
        end else begin
            qspi_int_ms_rx_fifo_overflow_aclk_o_r  <= qspi_int_ms_rx_fifo_overflow_aclk;
            qspi_int_ms_tx_fifo_overflow_aclk_o_r  <= qspi_int_ms_tx_fifo_overflow_aclk;
            qspi_int_ms_rx_fifo_threshold_aclk_o_r <= qspi_int_ms_rx_fifo_threshold_aclk;
            qspi_int_ms_tx_fifo_threshold_aclk_o_r <= qspi_int_ms_tx_fifo_threshold_aclk;
            qspi_int_ms_rx_fifo_not_empty_aclk_o_r <= qspi_int_ms_rx_fifo_not_empty_aclk;
            qspi_int_ms_tx_fifo_empty_aclk_o_r     <= qspi_int_ms_tx_fifo_empty_aclk;

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
