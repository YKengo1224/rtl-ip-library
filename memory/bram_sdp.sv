`default_nettype none

module bram_sdp #(
    parameter int DATA_WIDTH = 32,
    parameter int RAM_DEPTH  = 1024,
    parameter int BYTE_WIDTH = 8,
    parameter     INIT_FILE  = "",
    parameter int EN_REGISTER_MODE = 0
)(
    input  wire                              WRCLK,
    input  wire                              WREN,
    input  wire [(DATA_WIDTH/BYTE_WIDTH)-1:0] WE,
    input  wire [$clog2(RAM_DEPTH)-1:0]       WRADDR,
    input  wire [DATA_WIDTH-1:0]             DI,

    input  wire                              RDCLK,
    input  wire                              RST,
    input  wire                              RDEN,
    input  wire                              REGCE,
    input  wire [$clog2(RAM_DEPTH)-1:0]       RDADDR,
    output logic [DATA_WIDTH-1:0]            DO
);

    localparam int ADDR_WIDTH = $clog2(RAM_DEPTH);
    localparam int NUM_BYTES  = DATA_WIDTH / BYTE_WIDTH;

    (* ram_style = "block" *)
    reg [DATA_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, ram);
        end
    end

    always_ff @(posedge WRCLK) begin
        if (WREN) begin
            for (int i = 0; i < NUM_BYTES; i++) begin
                if (WE[i]) begin
                    ram[WRADDR][i*BYTE_WIDTH +: BYTE_WIDTH] <= DI[i*BYTE_WIDTH +: BYTE_WIDTH];
                end
            end
        end
    end

    logic [DATA_WIDTH-1:0] raw_ram_data;

    always_ff @(posedge RDCLK) begin
        if (RDEN) begin
            raw_ram_data <= ram[RDADDR];
        end
    end

    logic [DATA_WIDTH-1:0] ram_data;
    assign ram_data = raw_ram_data;

    generate
        if (EN_REGISTER_MODE == 1) begin : gen_out_reg
            always_ff @(posedge RDCLK) begin
                if (RST) begin
                    DO <= {DATA_WIDTH{1'b0}};
                end else if (REGCE) begin
                    DO <= ram_data;
                end
            end
        end else begin : gen_bypass
            assign DO = ram_data;
        end
    endgenerate

endmodule

`default_nettype wire
