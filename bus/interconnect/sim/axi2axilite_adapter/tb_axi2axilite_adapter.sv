`default_nettype none
`timescale 1ns/1ps

module tb_axi2axilite_adapter;
    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;
    localparam int ID_WIDTH = 4;

    logic clk;
    logic rst_n;

    axi_if #(
        .ID_WIDTH(ID_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(1)
    ) s_axi_if ();

    axilite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) m_axilite_if ();

    typedef virtual axi_if #(ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, 1) vif_axi_t;
    typedef virtual axilite_if #(ADDR_WIDTH, DATA_WIDTH) vif_axilite_t;

    vif_axi_t s_axi = s_axi_if;
    vif_axilite_t m_axilite = m_axilite_if;

    axi2axilite_adapter #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ID_WIDTH(ID_WIDTH)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi(s_axi_if),
        .m_axilite(m_axilite_if)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic axi_write(
        vif_axi_t m_if,
        input logic [ADDR_WIDTH-1:0] addr,
        ref logic [DATA_WIDTH-1:0] data[],
        input logic [7:0] len = '0,
        input logic [ID_WIDTH-1:0] id = '0
    );
        $display("[TB AXI Master] Write Transaction Start (addr=%h, len=%d)", addr, len);
        fork
            begin
                m_if.awid = id;
                m_if.awaddr = addr;
                m_if.awlen = len;
                m_if.awsize = 3'b010;
                m_if.awburst = 2'b01;
                m_if.awlock = 1'b0;
                m_if.awcache = '0;
                m_if.awprot = '0;
                m_if.awqos = '0;
                m_if.awregion = '0;
                m_if.awuser = '0;
                m_if.awvalid = 1'b1;
                wait (m_if.awready);
                @(posedge clk);
                #1;
                m_if.awvalid = 1'b0;
            end
            begin
                for (int i = 0; i <= len; i++) begin
                    m_if.wdata = data[i];
                    m_if.wstrb = 4'hF;
                    m_if.wlast = (i == len) ? 1'b1 : 1'b0;
                    m_if.wuser = '0;
                    m_if.wvalid = 1'b1;
                    wait (m_if.wready);
                    @(posedge clk);
                    #1;
                    m_if.wvalid = 1'b0;
                end
            end
        join
        m_if.bready = 1'b1;
        wait (m_if.bvalid);
        @(posedge clk);
        #1;
        m_if.bready = 1'b0;
    endtask

    task automatic axi_read(
        vif_axi_t m_if,
        input logic [ADDR_WIDTH-1:0] addr,
        ref logic [DATA_WIDTH-1:0] data[],
        input logic [7:0] len = '0,
        input logic [ID_WIDTH-1:0] id = '0
    );
        $display("[TB AXI Master] Read Transaction Start (addr=%h, len=%d)", addr, len);
        m_if.arid = id;
        m_if.araddr = addr;
        m_if.arlen = len;
        m_if.arsize = 3'b010;
        m_if.arburst = 2'b01;
        m_if.arlock = 1'b0;
        m_if.arcache = '0;
        m_if.arprot = '0;
        m_if.arqos = '0;
        m_if.arregion = '0;
        m_if.aruser = '0;
        m_if.arvalid = 1'b1;
        wait (m_if.arready);
        @(posedge clk);
        #1;
        m_if.arvalid = 1'b0;

        m_if.rready = 1'b1;
        for (int i = 0; i <= len; i++) begin
            wait (m_if.rvalid);
            data[i] = m_if.rdata;
            @(posedge clk);
            #1;
        end
        m_if.rready = 1'b0;
    endtask

    int max_awready_delay = 0;
    int max_wready_delay = 0;
    int max_bvalid_delay = 0;
    int max_arready_delay = 0;
    int max_rvalid_delay = 0;

    task automatic axilite_slave_model(
        vif_axilite_t s_if
    );
        logic [DATA_WIDTH-1:0] mem[256];
        logic [ADDR_WIDTH-1:0] awaddr_reg;
        logic aw_received;
        logic w_received;
        logic [DATA_WIDTH-1:0] wdata_reg;

        s_if.awready = 1'b0;
        s_if.wready = 1'b0;
        s_if.arready = 1'b0;
        s_if.bvalid = 1'b0;
        s_if.rvalid = 1'b0;
        s_if.bresp = 2'b00;
        s_if.rresp = 2'b00;
        aw_received = 1'b0;
        w_received = 1'b0;

        fork
            forever begin
                if (s_if.awvalid && !aw_received) begin
                    int delay;
                    delay = (max_awready_delay > 0) ? $urandom_range(0, max_awready_delay) : 0;
                    repeat (delay) @(posedge clk);
                    s_if.awready = 1'b1;
                    wait (s_if.awvalid);
                    @(posedge clk);
                    #1;
                    awaddr_reg = s_if.awaddr;
                    aw_received = 1'b1;
                    s_if.awready = 1'b0;
                end
                @(posedge clk);
            end

            forever begin
                if (s_if.wvalid && !w_received) begin
                    int delay;
                    delay = (max_wready_delay > 0) ? $urandom_range(0, max_wready_delay) : 0;
                    repeat (delay) @(posedge clk);
                    s_if.wready = 1'b1;
                    wait (s_if.wvalid);
                    @(posedge clk);
                    #1;
                    wdata_reg = s_if.wdata;
                    w_received = 1'b1;
                    s_if.wready = 1'b0;
                end
                @(posedge clk);
            end

            forever begin
                if (aw_received && w_received) begin
                    int delay;
                    delay = (max_bvalid_delay > 0) ? $urandom_range(0, max_bvalid_delay) : 0;
                    repeat (delay) @(posedge clk);
                    mem[awaddr_reg[9:2]] = wdata_reg;
                    s_if.bvalid = 1'b1;
                    s_if.bresp = 2'b00;
                    wait (s_if.bready);
                    @(posedge clk);
                    #1;
                    s_if.bvalid = 1'b0;
                    aw_received = 1'b0;
                    w_received = 1'b0;
                end
                @(posedge clk);
            end

            forever begin
                if (s_if.arvalid) begin
                    int delay;
                    delay = (max_arready_delay > 0) ? $urandom_range(0, max_arready_delay) : 0;
                    repeat (delay) @(posedge clk);
                    s_if.arready = 1'b1;
                    wait (s_if.arvalid);
                    @(posedge clk);
                    #1;
                    s_if.arready = 1'b0;
                    
                    delay = (max_rvalid_delay > 0) ? $urandom_range(0, max_rvalid_delay) : 0;
                    repeat (delay) @(posedge clk);
                    s_if.rdata = mem[s_if.araddr[9:2]];
                    s_if.rresp = 2'b00;
                    s_if.rvalid = 1'b1;
                    wait (s_if.rready);
                    @(posedge clk);
                    #1;
                    s_if.rvalid = 1'b0;
                end
                @(posedge clk);
            end
        join
    endtask

    initial begin
        fork
            axilite_slave_model(m_axilite);
        join_none
    end

    initial begin
        rst_n = 1'b0;
        s_axi.awvalid = 1'b0;
        s_axi.wvalid = 1'b0;
        s_axi.bready = 1'b0;
        s_axi.arvalid = 1'b0;
        s_axi.rready = 1'b0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        $display("==================================================");
        $display("Test 1: Single Write & Read (No Delay)");
        $display("==================================================");
        max_awready_delay = 0;
        max_wready_delay = 0;
        max_bvalid_delay = 0;
        max_arready_delay = 0;
        max_rvalid_delay = 0;
        begin
            automatic logic [31:0] wdata[] = new[1];
            automatic logic [31:0] rdata[] = new[1];
            wdata[0] = 32'h1111_2222;
            axi_write(s_axi, 32'h0000_1000, wdata, 8'd0, 4'h1);
            axi_read(s_axi, 32'h0000_1000, rdata, 8'd0, 4'h1);
            if (rdata[0] !== 32'h1111_2222) begin
                $display("ERROR: Test 1 failed! Read %h, expected %h", rdata[0], 32'h1111_2222);
                $finish;
            end
        end

        $display("==================================================");
        $display("Test 2: Burst Write & Read (INCR, 4 beats, No Delay)");
        $display("==================================================");
        begin
            automatic logic [31:0] wdata[] = new[4];
            automatic logic [31:0] rdata[] = new[4];
            wdata[0] = 32'hA0A0_B0B0;
            wdata[1] = 32'hC0C0_D0D0;
            wdata[2] = 32'hE0E0_F0F0;
            wdata[3] = 32'h1234_5678;
            axi_write(s_axi, 32'h0000_2000, wdata, 8'd3, 4'h2);
            axi_read(s_axi, 32'h0000_2000, rdata, 8'd3, 4'h2);
            for (int i = 0; i < 4; i++) begin
                if (rdata[i] !== wdata[i]) begin
                    $display("ERROR: Test 2 failed at beat %d! Read %h, expected %h", i, rdata[i], wdata[i]);
                    $finish;
                end
            end
        end

        $display("==================================================");
        $display("Test 3: Single & Burst under Configurable Random Latency");
        $display("==================================================");
        max_awready_delay = 4;
        max_wready_delay = 4;
        max_bvalid_delay = 4;
        max_arready_delay = 4;
        max_rvalid_delay = 4;
        begin
            automatic logic [31:0] wdata[] = new[4];
            automatic logic [31:0] rdata[] = new[4];
            
            wdata[0] = 32'h5555_AAAA;
            axi_write(s_axi, 32'h0000_3000, wdata, 8'd0, 4'h3);
            axi_read(s_axi, 32'h0000_3000, rdata, 8'd0, 4'h3);
            if (rdata[0] !== 32'h5555_AAAA) begin
                $display("ERROR: Test 3 Single failed! Read %h, expected %h", rdata[0], 32'h5555_AAAA);
                $finish;
            end

            wdata[0] = 32'h1122_3344;
            wdata[1] = 32'h5566_7788;
            wdata[2] = 32'h99AA_BBCC;
            wdata[3] = 32'hDDEE_FF00;
            axi_write(s_axi, 32'h0000_4000, wdata, 8'd3, 4'h4);
            axi_read(s_axi, 32'h0000_4000, rdata, 8'd3, 4'h4);
            for (int i = 0; i < 4; i++) begin
                if (rdata[i] !== wdata[i]) begin
                    $display("ERROR: Test 3 Burst failed at beat %d! Read %h, expected %h", i, rdata[i], wdata[i]);
                    $finish;
                end
            end
        end

        $display("==================================================");
        $display("SUCCESS: All tests passed!");
        $display("==================================================");
        $finish;
    end
endmodule
`default_nettype wire
