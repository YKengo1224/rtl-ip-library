`default_nettype none
module io #(
    parameter real DELAY_OUT = 0,
    parameter real DELAY_IN  = 0
) (
    input  wire data_out,
    input  wire oe,
    output wire data_in,
    inout  wire pad
);

    assign #DELAY_IN data_in = pad;

    assign #DELAY_OUT pad = (oe) ? data_out : 1'bz;


endmodule
