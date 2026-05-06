`default_nettype none


module tb_top ();

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import base_pkg::*;
    import case_pkg::*;

    parameter int ACLK_PERIOD_PS = 8000;  //125 MHz
    parameter int SYSCLK_PERIOD_PS = 5000;  // 200 MHz


    logic aclk;
    logic sysclk;
    logic aresetn;
    logic srstn_sysclk;

    initial begin
        aclk <= 1'b0;
        forever begin
            #(ACLK_PERIOD_PS / 2);
            aclk <= ~aclk;
        end
    end
    initial begin
        sysclk <= 1'b0;
        forever begin
            #(SYSCLK_PERIOD_PS / 2);
            sysclk <= ~sysclk;
        end
    end
    initial begin
        aresetn = 1'b0;
        repeat (10) begin
            @(posedge aclk);
        end
        aresetn = 1'b1;
    end
    initial begin
        srstn_sysclk = 1'b0;
        repeat (10) begin
            @(posedge sysclk);
        end
        srstn_sysclk = 1'b1;
    end


    tb_test_base       dummy;
    sample_seq         dummy_seq;


    logic              qspi_sclk_out_sysclk_o_r;
    logic              qspi_sclk_out_en_sysclk_o_r;
    logic        [3:0] qspi_csn_out_sysclk_o_r;
    logic        [3:0] qspi_csn_out_en_sysclk_o_r;
    logic        [3:0] qspi_data_out_sysclk_o_r;
    logic        [3:0] qspi_data_out_en_sysclk_o_r;
    wire               qspi_sclk_in_i;
    wire         [3:0] qspi_csn_in_i;
    wire         [3:0] qspi_data_in_i;
    //Interrupt Signal
    // output wire                      qspi_instr_aclk_o_r


    axi4lite_if axi4lite_if (
        .aclk(aclk),
        .aresetn(aresetn)
    );

    qspi_bfm_if bfm0_if (.rst_n(srstn_sysclk));
    qspi_bfm_if bfm1_if (.rst_n(srstn_sysclk));
    qspi_bfm_if bfm2_if (.rst_n(srstn_sysclk));
    qspi_bfm_if bfm3_if (.rst_n(srstn_sysclk));

    qspi_top #(
        .SYNC_FF_DEPTH(2),
        .ID_WIDTH     (1),
        .ADDRESS_WIDTH(16),
        .BUS_WIDTH    (32),
        .FIFO_SIZE    (32)
    ) qspi_top (
        .aclk               (aclk),
        .sysclk             (aclk),
        .aresetn            (aresetn),
        .srstn_sysclk       (srstn_sysclk),
        .awvalid            (axi4lite_if.awvalid),
        .awready            (axi4lite_if.awready),
        .awid               (axi4lite_if.awid),
        .awaddr             (axi4lite_if.awaddr),
        .awprot             (axi4lite_if.awprot),
        .wvalid             (axi4lite_if.wvalid),
        .wready             (axi4lite_if.wready),
        .wdata              (axi4lite_if.wdata),
        .wstrb              (axi4lite_if.wstrb),
        .bvalid             (axi4lite_if.bvalid),
        .bready             (axi4lite_if.bready),
        .bid                (axi4lite_if.bid),
        .bresp              (axi4lite_if.bresp),
        .arvalid            (axi4lite_if.arvalid),
        .arready            (axi4lite_if.arready),
        .araddr             (axi4lite_if.araddr),
        .arid               (axi4lite_if.arid),
        .arprot             (axi4lite_if.arprot),
        .rvalid             (axi4lite_if.rvalid),
        .rready             (axi4lite_if.rready),
        .rid                (axi4lite_if.rid),
        .rresp              (axi4lite_if.rresp),
        .rdata              (axi4lite_if.rdata),
        .qspi_sclk_out_sysclk_o_r,
        .qspi_sclk_out_en_sysclk_o_r,
        .qspi_csn_out_sysclk_o_r,
        .qspi_csn_out_en_sysclk_o_r,
        .qspi_data_out_sysclk_o_r,
        .qspi_data_out_en_sysclk_o_r,
        .qspi_sclk_in_i,
        .qspi_csn_in_i,
        .qspi_data_in_i,
        .qspi_instr_aclk_o_r()
    );

    bfm_connect #(
        .DLY_DATA_OUT({0, 0, 0, 0}),
        .DLY_DATA_IN ({0, 0, 0, 0})
    ) connect (
        .bfm0_if,
        .bfm1_if,
        .bfm2_if,
        .bfm3_if,
        .qspi_sclk_out_sysclk_o_r,
        .qspi_sclk_out_en_sysclk_o_r,
        .qspi_csn_out_sysclk_o_r,
        .qspi_csn_out_en_sysclk_o_r,
        .qspi_data_out_sysclk_o_r,
        .qspi_data_out_en_sysclk_o_r,
        .qspi_sclk_in_i,
        .qspi_csn_in_i,
        .qspi_data_in_i
    );

    monitor_if monitor_if (
        .aclk               (aclk),
        .sysclk             (aclk),
        .aresetn            (aresetn),
        .srstn_sysclk       (srstn_sysclk),
        .qspi_instr_aclk_o_r()
    );



    initial begin
        uvm_config_db#(virtual axi4lite_if)::set(null, "*", "axi4lite_m_vif", axi4lite_if);
        uvm_config_db#(virtual qspi_bfm_if)::set(null, "*", "bfm0_vif", bfm0_if);
        uvm_config_db#(virtual qspi_bfm_if)::set(null, "*", "bfm1_vif", bfm1_if);
        uvm_config_db#(virtual qspi_bfm_if)::set(null, "*", "bfm2_vif", bfm2_if);
        uvm_config_db#(virtual qspi_bfm_if)::set(null, "*", "bfm3_vif", bfm3_if);
        uvm_config_db#(monitor_vif)::set(null, "*", "monitor_vif", monitor_if);
        run_test();
    end


    initial begin
        repeat (100000) @(posedge aclk);
        $finish;
    end

endmodule

`default_nettype wire
