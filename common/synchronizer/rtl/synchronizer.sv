`default_nettype none

module synchronizer #(
    parameter int FF_DEPTH = 2
) (
    input  wire  CLK,
    input  wire  RST_N,
    input  wire  DATA_IN,
    output logic DATA_OUT
);


    generate
        if (FF_DEPTH == 0) begin
            assign DATA_OUT = DATA_IN;
        end else begin

            (* ASYNC_REG = "TRUE"*) logic [FF_DEPTH-1:0] sync_ff;

            always_ff @(posedge CLK or negedge RST_N) begin
                if (!RST_N) begin
                    sync_ff <= '0;
                end else begin
                    sync_ff[0] <= DATA_IN;
                    for (int i = 1; i < FF_DEPTH; i++) begin
                        sync_ff[i] <= sync_ff[i-1];
                    end
                end
            end

            assign DATA_OUT = sync_ff[FF_DEPTH-1];
        end
    endgenerate


endmodule
`default_nettype wire
