`default_nettype none

module bram_sdp #(
    parameter int DATA_WIDTH = 32,
    parameter int RAM_DEPTH  = 1024,
    parameter int BYTE_WIDTH = 8,
    parameter     WRITE_MODE = "WRITE_FIRST", // "WRITE_FIRST", "READ_FIRST"
    parameter     INIT_FILE  = "",            // Initialization Hex file path
    parameter int EN_REGISTER_MODE = 0        // Enable output register (0 or 1)
)(
    input  wire                                  WRCLK,
    input  wire                                  WREN,
    input  wire [(DATA_WIDTH/BYTE_WIDTH)-1:0]    WE,
    input  wire [$clog2(RAM_DEPTH)-1:0]          WRADDR,
    input  wire [DATA_WIDTH-1:0]                 DI,

    input  wire                                  RDCLK,
    input  wire                                  RST,         // Synchronous reset for output register
    input  wire                                  RDEN,
    input  wire                                  REGCE,       // Clock enable for output register
    input  wire [$clog2(RAM_DEPTH)-1:0]          RDADDR,
    output logic [DATA_WIDTH-1:0]                DO
);

    localparam int ADDR_WIDTH = $clog2(RAM_DEPTH);
    localparam int NUM_BYTES = DATA_WIDTH / BYTE_WIDTH;

    // RAM array
    reg [DATA_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    // RAM Initialization
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, ram);
        end
    end

    // Write operation (on WRCLK)
    always_ff @(posedge WRCLK) begin
        if (WREN) begin
            for (int i = 0; i < NUM_BYTES; i++) begin
                if (WE[i]) begin
                    ram[WRADDR][i*BYTE_WIDTH +: BYTE_WIDTH] <= DI[i*BYTE_WIDTH +: BYTE_WIDTH];
                end
            end
        end
    end

    // Core read output (before output register)
    logic [DATA_WIDTH-1:0] ram_data;

    generate
        if (WRITE_MODE == "WRITE_FIRST") begin : gen_write_first
            always_ff @(posedge RDCLK) begin
                if (RDEN) begin
                    // Forward write data to read output if write/read access same address
                    if (WREN && (WRADDR == RDADDR)) begin
                        for (int i = 0; i < NUM_BYTES; i++) begin
                            if (WE[i]) begin
                                ram_data[i*BYTE_WIDTH +: BYTE_WIDTH] <= DI[i*BYTE_WIDTH +: BYTE_WIDTH];
                            end else begin
                                ram_data[i*BYTE_WIDTH +: BYTE_WIDTH] <= ram[RDADDR][i*BYTE_WIDTH +: BYTE_WIDTH];
                            end
                        end
                    end else begin
                        ram_data <= ram[RDADDR];
                    end
                end
            end
        end else begin : gen_read_first // "READ_FIRST"
            always_ff @(posedge RDCLK) begin
                if (RDEN) begin
                    ram_data <= ram[RDADDR];
                end
            end
        end
    endgenerate

    // Output register stage
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
