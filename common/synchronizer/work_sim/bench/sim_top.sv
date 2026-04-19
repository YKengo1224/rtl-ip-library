`timescale 1ns / 1ps

`include "ClockGen.svh"
`include "DataGen.svh"
`include "Checker.svh"

module sim_top;

    `include "test_1_1_param.svh"

    wire                 WCLK;
    wire                 RCLK;
    wire                 RST_N_WCLK;
    wire                 RST_N_RCLK;

    wire                 W_EN_WCLK;
    wire  [BITWIDTH-1:0] DATA_IN_WCLK;
    wire                 R_EN_RCLK;
    logic [BITWIDTH-1:0] DATA_OUT_RCLKR;
    logic                DATA_OUT_VALID_RCLKR;

    logic                EMPTY_WCLKR;
    logic                FULL_WCLKR;
    logic                ALMOST_FULL_WCLKR;
    logic                ALMOST_EMPTY_WCLKR;
    logic [BITWIDTH-1:0] FIFO_AVAILABLE_WCLKR;

    logic                EMPTY_RCLKR;
    logic                FULL_RCLKR;
    logic                ALMOST_FULL_RCLKR;
    logic                ALMOST_EMPTY_RCLKR;
    logic [BITWIDTH-1:0] FIFO_AVAILABLE_RCLKR;



    fifo_async_if #(.BITWIDTH(BITWIDTH)) if1 ();

    // Class (virtual interface) -> DUT Inputs
    assign WCLK                     = if1.WCLK;
    assign RCLK                     = if1.RCLK;
    assign RST_N_WCLK               = if1.RST_N_WCLK;
    assign RST_N_RCLK               = if1.RST_N_RCLK;

    assign W_EN_WCLK                = if1.W_EN_WCLK;
    assign DATA_IN_WCLK             = if1.DATA_IN_WCLK;
    assign R_EN_RCLK                = if1.R_EN_RCLK;

    // DUT Outputs -> Class (virtual interface)
    assign if1.DATA_OUT_RCLKR       = DATA_OUT_RCLKR;
    assign if1.DATA_OUT_VALID_RCLKR = DATA_OUT_VALID_RCLKR;

    assign if1.EMPTY_WCLKR          = EMPTY_WCLKR;
    assign if1.FULL_WCLKR           = FULL_WCLKR;
    assign if1.ALMOST_FULL_WCLKR    = ALMOST_FULL_WCLKR;
    assign if1.ALMOST_EMPTY_WCLKR   = ALMOST_EMPTY_WCLKR;
    assign if1.FIFO_AVAILABLE_WCLKR = FIFO_AVAILABLE_WCLKR;

    assign if1.EMPTY_RCLKR          = EMPTY_RCLKR;
    assign if1.FULL_RCLKR           = FULL_RCLKR;
    assign if1.ALMOST_FULL_RCLKR    = ALMOST_FULL_RCLKR;
    assign if1.ALMOST_EMPTY_RCLKR   = ALMOST_EMPTY_RCLKR;
    assign if1.FIFO_AVAILABLE_RCLKR = FIFO_AVAILABLE_RCLKR;



    fifo_async #(
        .BITWIDTH(BITWIDTH),
        .FIFO_SIZE(FIFO_SIZE),
        .SYNC_FF_DEPTH(SYNC_FF_DEPTH),
        .ALMOST_FULL_SIZE(ALMOST_FULL_SIZE),
        .ALMOST_EMPTY_SIZE(ALMOST_EMPTY_SIZE)
    ) fifo_async_inst (
        .WCLK(WCLK),
        .RCLK(RCLK),
        .RST_N_WCLK(RST_N_WCLK),
        .RST_N_RCLK(RST_N_RCLK),
        .W_EN_WCLK(W_EN_WCLK),
        .DATA_IN_WCLK(DATA_IN_WCLK),
        .R_EN_RCLK(R_EN_RCLK),
        .DATA_OUT_RCLKR(DATA_OUT_RCLKR),
        .DATA_OUT_VALID_RCLKR(DATA_OUT_VALID_RCLKR),
        .EMPTY_WCLKR(EMPTY_WCLKR),
        .FULL_WCLKR(FULL_WCLKR),
        .ALMOST_FULL_WCLKR(ALMOST_FULL_WCLKR),
        .ALMOST_EMPTY_WCLKR(ALMOST_EMPTY_WCLKR),
        .FIFO_AVAILABLE_WCLKR(FIFO_AVAILABLE_WCLKR),
        .EMPTY_RCLKR(EMPTY_RCLKR),
        .FULL_RCLKR(FULL_RCLKR),
        .ALMOST_FULL_RCLKR(ALMOST_FULL_RCLKR),
        .ALMOST_EMPTY_RCLKR(ALMOST_EMPTY_RCLKR),
        .FIFO_AVAILABLE_RCLKR(FIFO_AVAILABLE_RCLKR)
    );

    //###############################
    // checker
    //###############################    


    ClockGen clk_gen;
    DataGen  data_gen;
    Checker checker_1;
   

    `include "test_1_1.svh"


    initial begin
        clk_gen  = new(if1);
        data_gen = new(if1);
        checker_1 = new(if1);       
    end

    initial begin
        sim_run();
    end

    initial begin
        #100s $error("TIME OUT!");
        $finish;
    end


    logic dummy_val;

    //###############################
    // dummy toggle
    //###############################
    initial begin
        dummy_val = 1'b0;
        if1.WCLK  = 1'b0;
        if1.RCLK  = 1'b0;
        #1;
        if1.W_EN_WCLK = 1'b0;
        if1.DATA_IN_WCLK = 'b0;
        if1.R_EN_RCLK = 1'b0;
    end
    initial begin
        // if1.W_EN_WCLK = 1'b0;
        // if1.DATA_IN_WCLK = 'b0;
    end

    //###############################
    // dump file
    //###############################
    string wave_filename;

    initial begin
        // "+WAVE_FILE=" で指定された引数があれば wave_filename に格納
        if ($value$plusargs("WAVE_FILE=%s", wave_filename)) begin
            $display("hogehogehoge");
            $dumpfile(wave_filename);
            $dumpvars(0, sim_top);
        end


    end

endmodule
