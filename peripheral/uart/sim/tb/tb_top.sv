`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import package classes
    import axi4lite_pkg::*;
    import uart_bfm_pkg::*;
    import uart_val_pkg::*;
    import case_pkg::*;

    // Clock and Reset Signals
    logic aclk;
    logic gen_aresetn;
    logic sysclk;
    logic gen_sysrst_n;

    // Clock generation
    initial begin
        aclk = 0;
        forever #5 aclk = ~aclk; // 100MHz (5ns delay)
    end

    initial begin
        sysclk = 0;
        forever #6.7797 sysclk = ~sysclk; // 73.750MHz (6.7797ns delay)
    end

    // Reset generation
    initial begin
        gen_aresetn = 0;
        gen_sysrst_n = 0;
        #100; // 100ns delay
        gen_aresetn = 1;
        gen_sysrst_n = 1;
    end

    // Crgen interface instantiation
    crgen_if crgen_vif();

    logic test_reset_n;
    logic test_sysrst_n;
    assign test_reset_n = gen_aresetn && crgen_vif.aresetn;
    assign test_sysrst_n = gen_sysrst_n && crgen_vif.sysrst_n;

    // Interface Instantiations
    axi4lite_if axil_if(
        .aclk(aclk),
        .aresetn(test_reset_n)
    );

    uart_bfm_if uart_if(
        .rst_n(test_reset_n)
    );

    // Monitor interface instantiation
    uart_monitor_if mon_if(
        .clk(aclk),
        .rst_n(test_reset_n)
    );

    // DUT (Device Under Test) Instantiation
    uart_top #(
        .ADDR_BITWIDTH(32),
        .DATA_BITWIDTH(32),
        .VARID_ADDR_BITWIDTH(8)
    ) dut (
        .aclk(aclk),
        .aresetn(test_reset_n),
        .sysclk(sysclk),
        .sysrst_n(test_sysrst_n),
        
        // AXI4-Lite Channels
        .awaddr(axil_if.awaddr[31:0]),
        .awprot(axil_if.awprot[0]),
        .awvalid(axil_if.awvalid),
        .awready(axil_if.awready),
        .wdata(axil_if.wdata[31:0]),
        .wstrb(axil_if.wstrb[3:0]),
        .wvalid(axil_if.wvalid),
        .wready(axil_if.wready),
        .bresp(axil_if.bresp),
        .bvalid(axil_if.bvalid),
        .bready(axil_if.bready),
        .araddr(axil_if.araddr[31:0]),
        .arprot(axil_if.arprot[0]),
        .arvalid(axil_if.arvalid),
        .arready(axil_if.arready),
        .rdata(axil_if.rdata[31:0]),
        .rresp(axil_if.rresp),
        .rvalid(axil_if.rvalid),
        .rready(axil_if.rready),
        
        // UART Physical Interface (DUT TX/RTS -> BFM RX/CTS, BFM TX/RTS -> DUT RX/CTS)
        .o_uart_txd_sysclkr(uart_if.rxd),
        .i_uart_rxd(uart_if.txd),
        .o_uart_rts_sysclkr(uart_if.ctsn),
        .i_uart_ctsn(uart_if.rtsn),
        
        // Interrupt
        .o_interrupt_aclkr(mon_if.o_interrupt_aclkr)
    );

    // UVM setup and run_test
    initial begin
        // Pass virtual interfaces to UVM configuration database
        uvm_config_db#(virtual axi4lite_if)::set(null, "*", "axil_vif", axil_if);
        uvm_config_db#(virtual uart_bfm_if)::set(null, "*", "uart_vif", uart_if);
        uvm_config_db#(virtual crgen_if)::set(null, "*", "crgen_vif", crgen_vif);
        uvm_config_db#(virtual uart_monitor_if)::set(null, "*", "mon_vif", mon_if);
        
        // Start UVM phase execution
        // Start UVM phase execution
        run_test();
    end

    // Debug helper to trace RX state during testcase execution
    initial begin
        #0;
        while ($time < 1500000) begin // Dump from 0 to 1.5 ms
            #10000; // Check every 10 us (10,000 ns)
            $display("[DEBUG_TB_TOP] time=%0t, state=%0d, empty=%0b, cnt=%0d, clken=%0b, rxd=%0b, rst=%0b, sysrst=%0b",
                $time,
                dut.uart_rx.state,
                dut.uart_rx.i_fifo_empty_sysclk,
                dut.uart_rx.over_samp_timeout_cnt_sysclkr,
                dut.uart_rx.i_over_samp_clken_sysclk,
                dut.uart_rx.uart_rxd_sysclk,
                dut.aresetn,
                dut.sysrst_n
            );
        end
    end

endmodule
