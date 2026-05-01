interface qspi_bfm_if;
    logic       clk_out;
    logic       clk_oe;
    logic       csn_out;
    logic       csn_oe;
    logic [3:0] data_out;
    logic [3:0] data_oe;
    logic       clk_in;
    logic       csn_in;
    logic [3:0] data_in;

    modport iobuf(
        input clk_out,
        input clk_oe,
        input csn_out,
        input csn_oe,
        input data_out,
        input data_oe,
        output clk_in,
        output csn_in,
        output data_in
    );



endinterface
