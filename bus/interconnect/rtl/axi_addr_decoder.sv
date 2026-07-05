`default_nettype none
module axi_addr_decoder #(
    parameter int                                    ADDR_WIDTH = 32,
    parameter int                                    NUM_SLAVES = 4,
    parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] BASE_ADDR  = '0,
    parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] ADDR_MASK  = '0
) (
    input  wire  [ADDR_WIDTH-1:0] i_addr,
    input  wire                   i_valid,
    output logic [  NUM_SLAVES:0] o_slave_sel,
    output logic                  o_decode_err
);

    always_comb begin
        o_slave_sel  = '0;
        o_decode_err = 1'b0;

        if (i_valid) begin
            for (int i = 0; i < NUM_SLAVES; i++) begin
                if ((i_addr & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i])) begin
                    o_slave_sel[i] = 1'b1;
                end
            end
            if (o_slave_sel == '0) begin
                o_decode_err = 1'b1;
                o_slave_sel[NUM_SLAVES] = 1'b1;
            end
        end

    end

endmodule
`default_nettype wire
