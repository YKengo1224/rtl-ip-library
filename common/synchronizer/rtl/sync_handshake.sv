`default_nettype none
module sync_handshake #(
    parameter P_D_BITWIDTH = -1,
    parameter FF_DEPTH = -1
) (
    input  wire                     ICLK,
    input  wire                     OCLK,
    input  wire                     RST_N_ICLK,
    input  wire                     RST_N_OCLK,
    input  wire                     SEND_EN_ICLK,
    output wire                     REQ_OCLK,
    input  wire                     ACK_OCLK,
    input  wire  [P_D_BITWIDTH-1:0] D_IN_ICLK,
    output logic [P_D_BITWIDTH-1:0] D_OUT_ICLK
);


    (* ASYNC_REG = "TRUE"*) logic [FF_DEPTH-1:0] req_sync_ff_OCLKr;
    (* ASYNC_REG = "TRUE"*) logic [FF_DEPTH-1:0] ack_sync_ff_ICLKr;

    logic req_iclkr;
    logic ack_iclk;

    logic send_en_delay_iclkr;
    logic send_en_pedge_iclk;

    //###################################
    //extract edge(SEND_EN_ICLk)
    //###################################
    always_ff @(posedge ICLK or negedge RST_N_ICLK) begin
        if (!RST_N_ICLK) begin
            send_en_delay_iclkr <= 1'b0;
        end else begin
            send_en_delay_iclkr <= SEND_EN_ICLK;
        end
    end

    assign send_en_pedge_iclk = !send_en_delay_iclkr && SEND_EN_ICLK;


    always_ff @(posedge ICLK or negedge RST_N_ICLK) begin
        if (!RST_N_ICLK) begin
            D_OUT_ICLK <= '0;
        end else if (send_en_pedge_iclk) begin
            D_OUT_ICLK <= D_IN_ICLK;
        end
    end

    //###################################
    //request signal
    //###################################
    always_ff @(posedge ICLK or negedge RST_N_ICLK) begin
        if (!RST_N_ICLK) begin
            req_iclkr <= 1'b0;
        end else if (!req_iclkr && send_en_pedge_iclk) begin
            req_iclkr = 1'b1;
        end else if (req_iclkr && ack_iclk) begin
            req_iclkr = 1'b0;
        end
    end



    //###################################
    //syncronizer
    //###################################
    always_ff @(posedge OCLK or negedge RST_N_OCLK) begin
        if (!RST_N_OCLK) begin
            req_sync_ff_OCLKr <= '0;
        end else begin
            req_sync_ff_OCLKr[0] <= req_iclkr;
            for (int i = 1; i < FF_DEPTH; i++) begin
                req_sync_ff_OCLKr[i] <= req_sync_ff_OCLKr[i-1];
            end
        end
    end

    always_ff @(posedge ICLK or negedge RST_N_ICLK) begin
        if (!RST_N_ICLK) begin
            ack_sync_ff_ICLKr <= '0;
        end else begin
            ack_sync_ff_ICLKr[0] <= ACK_OCLK;
            for (int i = 1; i < FF_DEPTH; i++) begin
                ack_sync_ff_ICLKr[i] <= ack_sync_ff_ICLKr[i-1];
            end
        end
    end

    assign REQ_OCLK = req_sync_ff_OCLKr[FF_DEPTH-1];
    assign ack_iclk = ack_sync_ff_ICLKr[FF_DEPTH-1];


endmodule
`default_nettype wire
