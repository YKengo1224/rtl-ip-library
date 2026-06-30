`default_nettype none

module bram_tdp #(
    parameter int DATA_WIDTH = 32,
    parameter int RAM_DEPTH  = 1024,
    parameter int BYTE_WIDTH = 8,
    parameter     WRITE_MODE_A = "READ_FIRST", // "WRITE_FIRST", "READ_FIRST", "NO_CHANGE"
    parameter     WRITE_MODE_B = "READ_FIRST", // "WRITE_FIRST", "READ_FIRST", "NO_CHANGE"
    parameter     INIT_FILE    = "",            // Initialization Hex file path
    parameter int EN_REGISTER_MODE_A = 0,       // Enable port A output register (0 or 1)
    parameter int EN_REGISTER_MODE_B = 0        // Enable port B output register (0 or 1)
)(
    input  wire                                  CLKA,
    input  wire                                  RSTA,
    input  wire                                  ENA,
    input  wire                                  REGCEA,
    input  wire [(DATA_WIDTH/BYTE_WIDTH)-1:0]    WEA,
    input  wire [$clog2(RAM_DEPTH)-1:0]          ADDRA,
    input  wire [DATA_WIDTH-1:0]                 DIA,
    output logic [DATA_WIDTH-1:0]                DOA,

    input  wire                                  CLKB,
    input  wire                                  RSTB,
    input  wire                                  ENB,
    input  wire                                  REGCEB,
    input  wire [(DATA_WIDTH/BYTE_WIDTH)-1:0]    WEB,
    input  wire [$clog2(RAM_DEPTH)-1:0]          ADDRB,
    input  wire [DATA_WIDTH-1:0]                 DIB,
    output logic [DATA_WIDTH-1:0]                DOB
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

    // Port A operation
    logic [DATA_WIDTH-1:0] ram_data_a;

    generate
        if (WRITE_MODE_A == "WRITE_FIRST") begin : gen_port_a_write_first
            always_ff @(posedge CLKA) begin
                if (ENA) begin
                    for (int i = 0; i < NUM_BYTES; i++) begin
                        if (WEA[i]) begin
                            ram[ADDRA][i*BYTE_WIDTH +: BYTE_WIDTH] <= DIA[i*BYTE_WIDTH +: BYTE_WIDTH];
                            ram_data_a[i*BYTE_WIDTH +: BYTE_WIDTH] <= DIA[i*BYTE_WIDTH +: BYTE_WIDTH];
                        end else begin
                            ram_data_a[i*BYTE_WIDTH +: BYTE_WIDTH] <= ram[ADDRA][i*BYTE_WIDTH +: BYTE_WIDTH];
                        end
                    end
                end
            end
        end else if (WRITE_MODE_A == "NO_CHANGE") begin : gen_port_a_no_change
            always_ff @(posedge CLKA) begin
                if (ENA) begin
                    logic is_write;
                    is_write = |WEA;

                    for (int i = 0; i < NUM_BYTES; i++) begin
                        if (WEA[i]) begin
                            ram[ADDRA][i*BYTE_WIDTH +: BYTE_WIDTH] <= DIA[i*BYTE_WIDTH +: BYTE_WIDTH];
                        end
                    end

                    if (!is_write) begin
                        ram_data_a <= ram[ADDRA];
                    end
                end
            end
        end else begin : gen_port_a_read_first // "READ_FIRST"
            always_ff @(posedge CLKA) begin
                if (ENA) begin
                    for (int i = 0; i < NUM_BYTES; i++) begin
                        if (WEA[i]) begin
                            ram[ADDRA][i*BYTE_WIDTH +: BYTE_WIDTH] <= DIA[i*BYTE_WIDTH +: BYTE_WIDTH];
                        end
                    end
                    ram_data_a <= ram[ADDRA];
                end
            end
        end
    endgenerate

    // Port A output register
    generate
        if (EN_REGISTER_MODE_A == 1) begin : gen_out_reg_a
            always_ff @(posedge CLKA) begin
                if (RSTA) begin
                    DOA <= {DATA_WIDTH{1'b0}};
                end else if (REGCEA) begin
                    DOA <= ram_data_a;
                end
            end
        end else begin : gen_bypass_a
            assign DOA = ram_data_a;
        end
    endgenerate


    // Port B operation
    logic [DATA_WIDTH-1:0] ram_data_b;

    generate
        if (WRITE_MODE_B == "WRITE_FIRST") begin : gen_port_b_write_first
            always_ff @(posedge CLKB) begin
                if (ENB) begin
                    for (int i = 0; i < NUM_BYTES; i++) begin
                        if (WEB[i]) begin
                            ram[ADDRB][i*BYTE_WIDTH +: BYTE_WIDTH] <= DIB[i*BYTE_WIDTH +: BYTE_WIDTH];
                            ram_data_b[i*BYTE_WIDTH +: BYTE_WIDTH] <= DIB[i*BYTE_WIDTH +: BYTE_WIDTH];
                        end else begin
                            ram_data_b[i*BYTE_WIDTH +: BYTE_WIDTH] <= ram[ADDRB][i*BYTE_WIDTH +: BYTE_WIDTH];
                        end
                    end
                end
            end
        end else if (WRITE_MODE_B == "NO_CHANGE") begin : gen_port_b_no_change
            always_ff @(posedge CLKB) begin
                if (ENB) begin
                    logic is_write;
                    is_write = |WEB;

                    for (int i = 0; i < NUM_BYTES; i++) begin
                        if (WEB[i]) begin
                            ram[ADDRB][i*BYTE_WIDTH +: BYTE_WIDTH] <= DIB[i*BYTE_WIDTH +: BYTE_WIDTH];
                        end
                    end

                    if (!is_write) begin
                        ram_data_b <= ram[ADDRB];
                    end
                end
            end
        end else begin : gen_port_b_read_first // "READ_FIRST"
            always_ff @(posedge CLKB) begin
                if (ENB) begin
                    for (int i = 0; i < NUM_BYTES; i++) begin
                        if (WEB[i]) begin
                            ram[ADDRB][i*BYTE_WIDTH +: BYTE_WIDTH] <= DIB[i*BYTE_WIDTH +: BYTE_WIDTH];
                        end
                    end
                    ram_data_b <= ram[ADDRB];
                end
            end
        end
    endgenerate

    // Port B output register
    generate
        if (EN_REGISTER_MODE_B == 1) begin : gen_out_reg_b
            always_ff @(posedge CLKB) begin
                if (RSTB) begin
                    DOB <= {DATA_WIDTH{1'b0}};
                end else if (REGCEB) begin
                    DOB <= ram_data_b;
                end
            end
        end else begin : gen_bypass_b
            assign DOB = ram_data_b;
        end
    endgenerate

endmodule

`default_nettype wire
