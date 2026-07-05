`default_nettype none
`timescale 1ns/1ps

module tb_crossbar;

    localparam int NUM_MASTERS = 2;
    localparam int NUM_SLAVES = 2;
    localparam int ID_WIDTH = 4;
    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;
    localparam int USER_WIDTH = 1;

    logic clk;
    logic rst_n;

    axi_if #(
        .ID_WIDTH(ID_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    ) s_axi_if[NUM_MASTERS] ();

    axi_if #(
        .ID_WIDTH(ID_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    ) m_axi_if[NUM_SLAVES] ();

    typedef virtual axi_if #(ID_WIDTH, ADDR_WIDTH, DATA_WIDTH, USER_WIDTH) vif_t;
    vif_t master_vif[NUM_MASTERS];
    vif_t slave_vif[NUM_SLAVES];

    initial begin
        master_vif[0] = s_axi_if[0];
        master_vif[1] = s_axi_if[1];
        slave_vif[0] = m_axi_if[0];
        slave_vif[1] = m_axi_if[1];
    end

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    axi_crossbar #(
        .NUM_MASTERS(NUM_MASTERS),
        .NUM_SLAVES(NUM_SLAVES),
        .ID_WIDTH(ID_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH),
        .BASE_ADDR({32'h1000_0000, 32'h0000_0000}),
        .ADDR_MASK({32'hF000_0000, 32'hF000_0000})
    ) u_dut (
        .aclk(clk),
        .aresetn(rst_n),
        .s_axi(s_axi_if),
        .m_axi(m_axi_if)
    );

    task automatic axi_write(
        vif_t m_if,
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [DATA_WIDTH-1:0] data,
        input logic [ID_WIDTH-1:0] id = '0
    );
        fork
            begin
                m_if.awid = id;
                m_if.awaddr = addr;
                m_if.awlen = 8'd0;
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
                m_if.awvalid = 1'b0;
            end
            begin
                m_if.wdata = data;
                m_if.wstrb = 4'hF;
                m_if.wlast = 1'b1;
                m_if.wuser = '0;
                m_if.wvalid = 1'b1;
                wait (m_if.wready);
                @(posedge clk);
                m_if.wvalid = 1'b0;
            end
        join
        m_if.bready = 1'b1;
        wait (m_if.bvalid);
        @(posedge clk);
        m_if.bready = 1'b0;
    endtask

    task automatic axi_read(
        vif_t m_if,
        input logic [ADDR_WIDTH-1:0] addr,
        output logic [DATA_WIDTH-1:0] data,
        input logic [ID_WIDTH-1:0] id = '0
    );
        m_if.arid = id;
        m_if.araddr = addr;
        m_if.arlen = 8'd0;
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
        m_if.arvalid = 1'b0;

        m_if.rready = 1'b1;
        wait (m_if.rvalid);
        data = m_if.rdata;
        @(posedge clk);
        m_if.rready = 1'b0;
    endtask

    task automatic axi_slave_model(
        vif_t s_if,
        input int slave_id
    );
        logic [DATA_WIDTH-1:0] mem[256];
        logic [ADDR_WIDTH-1:0] awaddr_reg;
        logic [ID_WIDTH-1:0] awid_reg;
        logic aw_received;
        logic w_received;
        logic [DATA_WIDTH-1:0] wdata_reg;

        s_if.awready = 1'b0;
        s_if.wready = 1'b0;
        s_if.arready = 1'b0;
        s_if.bvalid = 1'b0;
        s_if.rvalid = 1'b0;
        s_if.rlast = 1'b0;
        s_if.rresp = 2'b00;
        s_if.bresp = 2'b00;
        aw_received = 1'b0;
        w_received = 1'b0;

        fork
            forever begin
                @(posedge clk);
                if (!rst_n) begin
                    s_if.awready = 1'b0;
                    s_if.wready = 1'b0;
                    s_if.bvalid = 1'b0;
                    aw_received = 1'b0;
                    w_received = 1'b0;
                end else begin
                    if (s_if.awvalid && !aw_received) begin
                        s_if.awready = 1'b1;
                    end else begin
                        s_if.awready = 1'b0;
                    end

                    if (s_if.awvalid && s_if.awready) begin
                        awaddr_reg = s_if.awaddr;
                        awid_reg = s_if.awid;
                        aw_received = 1'b1;
                    end

                    if (s_if.wvalid && !w_received) begin
                        s_if.wready = 1'b1;
                    end else begin
                        s_if.wready = 1'b0;
                    end

                    if (s_if.wvalid && s_if.wready) begin
                        wdata_reg = s_if.wdata;
                        w_received = 1'b1;
                    end

                    if (aw_received && w_received && !s_if.bvalid) begin
                        mem[awaddr_reg[9:2]] = wdata_reg;
                        s_if.bid = awid_reg;
                        s_if.bvalid = 1'b1;
                        aw_received = 1'b0;
                        w_received = 1'b0;
                    end

                    if (s_if.bvalid && s_if.bready) begin
                        s_if.bvalid = 1'b0;
                    end
                end
            end

            forever begin
                @(posedge clk);
                if (!rst_n) begin
                    s_if.arready = 1'b0;
                    s_if.rvalid = 1'b0;
                    s_if.rlast = 1'b0;
                end else begin
                    if (s_if.arvalid && !s_if.rvalid) begin
                        s_if.arready = 1'b1;
                    end else begin
                        s_if.arready = 1'b0;
                    end

                    if (s_if.arvalid && s_if.arready) begin
                        s_if.rid = s_if.arid;
                        s_if.rdata = mem[s_if.araddr[9:2]];
                        s_if.rvalid = 1'b1;
                        s_if.rlast = 1'b1;
                    end

                    if (s_if.rvalid && s_if.rready) begin
                        s_if.rvalid = 1'b0;
                        s_if.rlast = 1'b0;
                    end
                end
            end
        join
    endtask

    initial begin
        for (int i = 0; i < NUM_SLAVES; i++) begin
            automatic int id = i;
            fork
                axi_slave_model(slave_vif[id], id);
            join_none
        end
    end

    initial begin
        rst_n = 1'b0;
        for (int i = 0; i < NUM_MASTERS; i++) begin
            master_vif[i].awvalid = 1'b0;
            master_vif[i].wvalid = 1'b0;
            master_vif[i].bready = 1'b0;
            master_vif[i].arvalid = 1'b0;
            master_vif[i].rready = 1'b0;
        end

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        $display("Test 1: Master 0 to Slave 0");
        axi_write(master_vif[0], 32'h0000_0100, 32'hDEAD_BEEF, 4'h1);
        begin
            logic [31:0] rdata;
            axi_read(master_vif[0], 32'h0000_0100, rdata, 4'h1);
            if (rdata !== 32'hDEAD_BEEF) begin
                $display("ERROR: Test 1 failed! Read %h, expected %h", rdata, 32'hDEAD_BEEF);
                $finish;
            end
        end

        $display("Test 2: Master 0 to Slave 1");
        axi_write(master_vif[0], 32'h1000_0200, 32'hCAFE_BABE, 4'h2);
        begin
            logic [31:0] rdata;
            axi_read(master_vif[0], 32'h1000_0200, rdata, 4'h2);
            if (rdata !== 32'hCAFE_BABE) begin
                $display("ERROR: Test 2 failed! Read %h, expected %h", rdata, 32'hCAFE_BABE);
                $finish;
            end
        end

        $display("Test 3: Master 1 to Slave 0");
        axi_write(master_vif[1], 32'h0000_0300, 32'h1234_5678, 4'h3);
        begin
            logic [31:0] rdata;
            axi_read(master_vif[1], 32'h0000_0300, rdata, 4'h3);
            if (rdata !== 32'h1234_5678) begin
                $display("ERROR: Test 3 failed! Read %h, expected %h", rdata, 32'h1234_5678);
                $finish;
            end
        end

        $display("Test 4: Master 1 to Slave 1");
        axi_write(master_vif[1], 32'h1000_0400, 32'h8765_4321, 4'h4);
        begin
            logic [31:0] rdata;
            axi_read(master_vif[1], 32'h1000_0400, rdata, 4'h4);
            if (rdata !== 32'h8765_4321) begin
                $display("ERROR: Test 4 failed! Read %h, expected %h", rdata, 32'h8765_4321);
                $finish;
            end
        end

        $display("Test 5: Arbitration conflict to Slave 0");
        fork
            axi_write(master_vif[0], 32'h0000_0500, 32'hAAAA_AAAA, 4'h5);
            axi_write(master_vif[1], 32'h0000_0504, 32'hBBBB_BBBB, 4'h6);
        join
        
        fork
            begin
                logic [31:0] rdata;
                axi_read(master_vif[0], 32'h0000_0500, rdata, 4'h5);
                if (rdata !== 32'hAAAA_AAAA) begin
                    $display("ERROR: Test 5 Master 0 failed! Read %h, expected %h", rdata, 32'hAAAA_AAAA);
                    $finish;
                end
            end
            begin
                logic [31:0] rdata;
                axi_read(master_vif[1], 32'h0000_0504, rdata, 4'h6);
                if (rdata !== 32'hBBBB_BBBB) begin
                    $display("ERROR: Test 5 Master 1 failed! Read %h, expected %h", rdata, 32'hBBBB_BBBB);
                    $finish;
                end
            end
        join

        $display("SUCCESS: All tests passed!");
        $finish;
    end

endmodule
`default_nettype wire
