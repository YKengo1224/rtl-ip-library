module tb_ahb_lite;

    logic clk, rstn;
    logic [31:0] HADDR, HWDATA, HRDATA;
    logic [1:0] HTRANS;
    logic [2:0] HSIZE, HBURST;
    logic HWRITE, HREADY;

    // DUT
    ahb_lite_master_model master (
        .HCLK(clk),
        .HRESETn(rstn),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HWRITE(HWRITE),
        .HSIZE(HSIZE),
        .HBURST(HBURST),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HREADY(HREADY)
    );

    ahb3_lite_slave slabe_inst (
        clk_i(clk),
        rst_n_i(rstn),
        haddr_i(HADDR),
        hburst_i(HBURST),
        h_must_lock,
        prot_i,
        hsize_i(HSIZE),
        htrans_i(HTRANS),
        hwdata_i(HWDATA),
        hwrite_i(HWRITE),
        hsel_i(1'b1),
        hrdata_o(HRDATA),
        hready_o(HREADY),
        hresp_o
    );


    // クロックとリセット
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        rstn   = 0;
        HREADY = 1;
        #20 rstn = 1;
    end

    // テストシーケンス
    initial begin
        logic [31:0] rdata;
        logic [31:0] burst_wdata[0:3];
        logic [31:0] burst_rdata[0:3];

        burst_wdata[0] = 32'h11111111;
        burst_wdata[1] = 32'h22222222;
        burst_wdata[2] = 32'h33333333;
        burst_wdata[3] = 32'h44444444;

        wait (rstn);

        // single write
        master.ahb_single_write(32'h0000_0000, 32'hDEAD_BEEF, 3'b010);

        // single read
        master.ahb_single_read(32'h0000_0000, 3'b010, rdata);
        $display("read: %h", rdata);

        // // burst write (INCR4)
        // master.ahb_burst_write(32'h0000_0000, burst_wdata, 3'b010, master.BURST_INCR4);

        // // burst read (INCR4)
        // master.ahb_burst_read(32'h0000_0000, 3'b010, master.BURST_INCR4, burst_rdata);

        $finish;
    end
endmodule
