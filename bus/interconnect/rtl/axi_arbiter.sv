`default_nettype none

module axi_arbiter #(
    parameter int NUM_MASTERS = 4
) (
    input wire aclk,
    input wire aresetn,
    input wire [NUM_MASTERS-1:0] i_req,
    input wire i_handshake,
    output logic [NUM_MASTERS-1:0] o_gnt_r
);


    reg   [NUM_MASTERS-1:0] gnt_prev;

    logic [NUM_MASTERS-1:0] base_gnt;
    logic [NUM_MASTERS-1:0] masked_req;
    logic [NUM_MASTERS-1:0] gnt_next;

    //前回許可されたマスターより上位のマスターだけを残すマスク
    assign base_gnt   = (o_gnt_r != 0) ? o_gnt_r : gnt_prev;

    assign masked_req = i_req & ~((base_gnt - 1'b1) | base_gnt);

    //上位側にリクエストがあれば、上位側の最下位ビットを、なければ全体の最下位ビットを検出
    assign gnt_next   = (masked_req) ? (masked_req & -masked_req) : (i_req & -i_req);



    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            o_gnt_r  <= '0;
            gnt_prev <= '0;
        end else if (i_handshake && (o_gnt_r != 0)) begin
            gnt_prev <= o_gnt_r;

            if ((i_req & ~o_gnt_r) != '0) begin
                o_gnt_r <= gnt_next;
            end else begin
                o_gnt_r <= '0;
            end
        end else if ((i_req != 0) && (o_gnt_r == '0)) begin
            o_gnt_r <= gnt_next;
        end else begin
            o_gnt_r <= o_gnt_r;
        end
    end


endmodule
`default_nettype wire
