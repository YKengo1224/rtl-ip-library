`default_nettype none
module axi_crossbar_addr #(
    parameter int NUM_MASTERS = 2,
    parameter int NUM_SLAVES = 2,
    parameter int ADDR_WIDTH = 32,
    parameter int USER_WIDTH = 1,
    parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] BASE_ADDR = '0,
    parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] ADDR_MASK = '0
) (
    input wire aclk,
    input wire aresetn,

    input  wire  [NUM_MASTERS-1:0][ADDR_WIDTH-1:0] s_addr,
    input  wire  [NUM_MASTERS-1:0]                 s_valid,
    output logic [NUM_MASTERS-1:0]                 s_ready,

    output logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] m_addr,
    output logic [NUM_SLAVES-1:0]                 m_valid,
    input  wire  [NUM_SLAVES-1:0]                 m_ready,

    input wire [NUM_SLAVES-1:0] i_handshake_done,
    output logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] o_gnt_matrix
);

    logic [NUM_MASTERS-1:0][NUM_SLAVES:0] dec_sel;
    logic [NUM_MASTERS-1:0] dec_err;


    logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] req_to_slave;
    logic [NUM_SLAVES-1:0][NUM_MASTERS-1:0] gnt_from_slave;

    assign o_gnt_matrix = gnt_from_slave;

    genvar m, s;
    generate
        for (m = 0; m < NUM_MASTERS; m++) begin : gen_dec
            axi_addr_decoder #(
                .ADDR_WIDTH(ADDR_WIDTH),
                .NUM_SLAVES(NUM_SLAVES),
                .BASE_ADDR (BASE_ADDR),
                .ADDR_MASK (ADDR_MASK)
            ) axi_addr_decoder_0 (
                .i_addr(s_addr[m]),
                .i_valid(s_valid[m]),
                .o_slave_sel(dec_sel[m]),
                .o_decode_err(dec_err[m])
            );
        end
    endgenerate

    always_comb begin
        for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
            for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
                req_to_slave[i_s][i_m] = s_valid[i_m] && dec_sel[i_m][i_s];
            end
        end
    end


    generate
        for (s = 0; s < NUM_SLAVES; s++) begin : gen_arb

            axi_arbiter #(
                .NUM_MASTERS(NUM_MASTERS)
            ) axi_arbiter_0 (
                .aclk(aclk),
                .aresetn(aresetn),
                .i_req(req_to_slave[s]),
                .i_handshake(i_handshake_done[s]),
                .o_gnt_r(gnt_from_slave[s])
            );
        end
    endgenerate

    always_comb begin
        for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
            m_addr[i_s]  = '0;
            m_valid[i_s] = 1'b0;

            for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
                if (gnt_from_slave[i_s][i_m]) begin
                    m_addr[i_s]  = s_addr[i_m];
                    m_valid[i_s] = s_valid[i_m];
                end
            end
        end
    end




    always_comb begin
        for (int i_m = 0; i_m < NUM_MASTERS; i_m++) begin
            s_ready[i_m] = 1'b0;
            for (int i_s = 0; i_s < NUM_SLAVES; i_s++) begin
                if (gnt_from_slave[i_s][i_m]) begin
                    s_ready[i_m] = m_ready[i_s];
                end
            end

            if (dec_sel[i_m][NUM_SLAVES]) begin
                s_ready[i_m] = 1'b1;
            end
        end
    end

endmodule
`default_nettype wire
