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
    logic aresetn;
    logic sysclk;
    logic sysrst_n;

    // Clock generation
    initial begin
        aclk = 0;
        forever #5ns aclk = ~aclk; // 100MHz
    end

    initial begin
        sysclk = 0;
        forever #6.7797ns sysclk = ~sysclk; // 73.750MHz
    end

    // Reset generation
    initial begin
        aresetn = 0;
        sysrst_n = 0;
        #100ns;
        aresetn = 1;
        sysrst_n = 1;
    end

    // Interface Instantiations
    axi4lite_if axil_if(
        .aclk(aclk),
        .aresetn(aresetn)
    );

    uart_bfm_if uart_if(
        .rst_n(aresetn)
    );

    // DUT (Device Under Test) Instantiation
    uart_top #(
        .ADDR_BITWIDTH(32),
        .DATA_BITWIDTH(32),
        .VARID_ADDR_BITWIDTH(8)
    ) dut (
        .aclk(aclk),
        .aresetn(aresetn),
        .sysclk(sysclk),
        .sysrst_n(sysrst_n),
        
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
        .o_interrupt_aclkr()
    );

    // UVM setup and run_test
    initial begin
        // Pass virtual interfaces to UVM configuration database
        uvm_config_db#(virtual axi4lite_if)::set(null, "*", "axil_vif", axil_if);
        uvm_config_db#(virtual uart_bfm_if)::set(null, "*", "uart_vif", uart_if);
        
        // Start UVM phase execution
        run_test();
    end

endmodule
