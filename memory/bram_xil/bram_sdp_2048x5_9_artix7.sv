`default_nettype none
module bram_sdp_2048x5_9_artix7 #(
    parameter int    EN_REGISTER_MODE = 0,
    parameter string INIT_FILE        = "NONE",
    parameter string WRITE_MODE       = "WRITE_FIRST",
    parameter int    DATA_WIDTH       = 9
) (
    input  wire                  RDCLK,
    input  wire                  WRCLK,
    input  wire                  RST,
    input  wire                  RDEN,
    input  wire                  WREN,
    input  wire  [ 0:0]          WE,
    input  wire  [10:0]          RDADDR,
    input  wire  [10:0]          WRADDR,
    input  wire  [DATA_WIDTH-1:0] DI,
    output logic [DATA_WIDTH-1:0] DO
);

    // Elaboration-time range check
    generate
        if (DATA_WIDTH < 5 || DATA_WIDTH > 9) begin : gen_error
            $fatal(1, "Error: DATA_WIDTH = %0d is out of range [5-9] for bram_sdp_2048x5_9_artix7.", DATA_WIDTH);
        end
        if (WRITE_MODE != "WRITE_FIRST" && WRITE_MODE != "READ_FIRST") begin : gen_write_mode_error
            $fatal(1, "Error: WRITE_MODE = %s is invalid (must be \"WRITE_FIRST\" or \"READ_FIRST\") for bram_sdp_2048x5_9_artix7.", WRITE_MODE);
        end
    endgenerate

    // BRAM_SDP_MACRO: Simple Dual Port RAM
    //                 Artix-7
    // Xilinx HDL Language Template, version 2022.1

    BRAM_SDP_MACRO #(
        .BRAM_SIZE("18Kb"),  // Target BRAM, "18Kb" or "36Kb" 
        .DEVICE("7SERIES"),  // Target device: "7SERIES" 
        .WRITE_WIDTH(DATA_WIDTH),  // Valid values are 1-72
        .READ_WIDTH(DATA_WIDTH),   // Valid values are 1-72
        .DO_REG(EN_REGISTER_MODE),  // Optional output register (0 or 1)
        .INIT_FILE(INIT_FILE),
        .SIM_COLLISION_CHECK("ALL"),  // Collision check enable "ALL", "WARNING_ONLY",
                                      //   "GENERATE_X_ONLY" or "NONE" 
        .SRVAL(72'h000000000000000000),  // Set/Reset value for port output
        .INIT(72'h000000000000000000),  // Initial values on output port
        .WRITE_MODE(WRITE_MODE)  // Specify "READ_FIRST" for same clock or synchronous clocks
                                     //   Specify "WRITE_FIRST for asynchronous clocks on ports
        /*
        .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
        .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
        */
    ) BRAM_SDP_MACRO_inst (
        .DO    (DO),      // Output read data port, width defined by READ_WIDTH parameter
        .DI    (DI),      // Input write data port, width defined by WRITE_WIDTH parameter
        .RDADDR(RDADDR),  // Input read address, width defined by read port depth
        .RDCLK (RDCLK),   // 1-bit input read clock
        .RDEN  (RDEN),    // 1-bit input read port enable
        .REGCE (1'b1),    // 1-bit input read output register enable
        .RST   (RST),     // 1-bit input reset
        .WE    (WE),      // Input write enable, width defined by write port depth
        .WRADDR(WRADDR),  // Input write address, width defined by write port depth
        .WRCLK (WRCLK),   // 1-bit input write clock
        .WREN  (WREN)     // 1-bit input write port enable
    );

    // End of BRAM_SDP_MACRO_inst instantiation

endmodule

`default_nettype wire
