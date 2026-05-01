import base_pkg::*;
module bfm_connect #(
    parameter real DLY_DATA_OUT[4] = '{default: 0},
    parameter real DLY_DATA_IN [4] = '{default: 0}
) (
           qspi_bfm_if.iobuf       bfm0_if,
           qspi_bfm_if.iobuf       bfm1_if,
           qspi_bfm_if.iobuf       bfm2_if,
           qspi_bfm_if.iobuf       bfm3_if,
    input  wire                    qspi_sclk_out_sysclk_o_r,
    input  wire                    qspi_sclk_out_en_sysclk_o_r,
    input  wire              [3:0] qspi_csn_out_sysclk_o_r,
    input  wire              [3:0] qspi_csn_out_en_sysclk_o_r,
    input  wire              [3:0] qspi_data_out_sysclk_o_r,
    input  wire              [3:0] qspi_data_out_en_sysclk_o_r,
    output wire                    qspi_sclk_in_i,
    output wire              [3:0] qspi_csn_in_i,
    output wire              [3:0] qspi_data_in_i
);

    wire       sclk_pad;
    wire [3:0] csn_pad;
    wire [3:0] data_pad;

    //dut io buffer
    io io_dut_sclk (
        .data_out(qspi_sclk_out_sysclk_o_r),
        .oe(qspi_sclk_out_en_sysclk_o_r),
        .data_in(qspi_sclk_in_i),
        .pad(sclk_pad)
    );
    io io_bfm0_sclk (
        .data_out(bfm0_if.clk_out),
        .oe(bfm0_if.clk_oe),
        .data_in(bfm0_if.clk_in),
        .pad(sclk_pad)
    );
    io io_bfm1_sclk (
        .data_out(bfm1_if.clk_out),
        .oe(bfm1_if.clk_oe),
        .data_in(bfm1_if.clk_in),
        .pad(sclk_pad)
    );
    io io_bfm2_sclk (
        .data_out(bfm2_if.clk_out),
        .oe(bfm2_if.clk_oe),
        .data_in(bfm2_if.clk_in),
        .pad(sclk_pad)
    );
    io io_bfm3_sclk (
        .data_out(bfm3_if.clk_out),
        .oe(bfm3_if.clk_oe),
        .data_in(bfm3_if.clk_in),
        .pad(sclk_pad)
    );


    // DUT CSN[0] <-> BFM0
    io io_dut_csn0 (
        .data_out(qspi_csn_out_sysclk_o_r[0]),
        .oe(qspi_csn_out_en_sysclk_o_r[0]),
        .data_in(qspi_csn_in_i[0]),
        .pad(csn_pad[0])
    );
    io io_bfm0_csn (
        .data_out(bfm0_if.csn_out),
        .oe(bfm0_if.csn_oe),
        .data_in(bfm0_if.csn_in),
        .pad(csn_pad[0])
    );

    // DUT CSN[1] <-> BFM1
    io io_dut_csn1 (
        .data_out(qspi_csn_out_sysclk_o_r[1]),
        .oe(qspi_csn_out_en_sysclk_o_r[1]),
        .data_in(qspi_csn_in_i[1]),
        .pad(csn_pad[1])
    );
    io io_bfm1_csn (
        .data_out(bfm1_if.csn_out),
        .oe(bfm1_if.csn_oe),
        .data_in(bfm1_if.csn_in),
        .pad(csn_pad[1])
    );

    // DUT CSN[2] <-> BFM2
    io io_dut_csn2 (
        .data_out(qspi_csn_out_sysclk_o_r[2]),
        .oe(qspi_csn_out_en_sysclk_o_r[2]),
        .data_in(qspi_csn_in_i[2]),
        .pad(csn_pad[2])
    );
    io io_bfm2_csn (
        .data_out(bfm2_if.csn_out),
        .oe(bfm2_if.csn_oe),
        .data_in(bfm2_if.csn_in),
        .pad(csn_pad[2])
    );

    // DUT CSN[3] <-> BFM3
    io io_dut_csn3 (
        .data_out(qspi_csn_out_sysclk_o_r[3]),
        .oe(qspi_csn_out_en_sysclk_o_r[3]),
        .data_in(qspi_csn_in_i[3]),
        .pad(csn_pad[3])
    );
    io io_bfm3_csn (
        .data_out(bfm3_if.csn_out),
        .oe(bfm3_if.csn_oe),
        .data_in(bfm3_if.csn_in),
        .pad(csn_pad[3])
    );



    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_qspi_data
            // DUT Data bit[i]
            io #(
                .DELAY_OUT(DLY_DATA_OUT[i]),
                .DELAY_IN (DLY_DATA_IN[i])
            ) io_dut_data (
                .data_out(qspi_data_out_sysclk_o_r[i]),
                .oe      (qspi_data_out_en_sysclk_o_r[i]),
                .data_in (qspi_data_in_i[i]),
                .pad     (data_pad[i])
            );

            // BFM0 Data bit[i]
            io io_bfm0_data (
                .data_out(bfm0_if.data_out[i]),
                .oe      (bfm0_if.data_oe[i]),
                .data_in (bfm0_if.data_in[i]),
                .pad     (data_pad[i])
            );

            // BFM1 Data bit[i]
            io io_bfm1_data (
                .data_out(bfm1_if.data_out[i]),
                .oe      (bfm1_if.data_oe[i]),
                .data_in (bfm1_if.data_in[i]),
                .pad     (data_pad[i])
            );

            // BFM2 Data bit[i]
            io io_bfm2_data (
                .data_out(bfm2_if.data_out[i]),
                .oe      (bfm2_if.data_oe[i]),
                .data_in (bfm2_if.data_in[i]),
                .pad     (data_pad[i])
            );

            // BFM3 Data bit[i]
            io io_bfm3_data (
                .data_out(bfm3_if.data_out[i]),
                .oe      (bfm3_if.data_oe[i]),
                .data_in (bfm3_if.data_in[i]),
                .pad     (data_pad[i])
            );
        end
    endgenerate
endmodule
