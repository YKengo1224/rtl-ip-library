`default_nettype none

module uart_axilite_slv #(
    parameter int ADDR_BITWIDTH = 32,
    parameter int DATA_BITWIDTH = 32,
    parameter int VARID_ADDR_BITWIDTH = 8

) (
    input wire aclk,
    input wire aresetn,

    //====================================================
    // USER Ports
    //====================================================
        output reg       o_uart_enable_aclkr,
    output reg [3:0] o_conf_data_bit_width_aclkr,
    output reg [1:0] o_conf_stop_bit_width_sel_aclkr,
    output reg [1:0] o_conf_parity_bit_aclkr,
    output reg       o_conf_tx_env_aclkr,
    output reg       o_conf_rx_env_aclkr,
    output reg       o_conf_hw_flow_en_aclkr,
    output reg       o_conf__samp_num_sel_aclkr,
    output reg [1:0] o_conf_over_samp_sel_aclkr,
    output reg [15:0] o_conf_clk_div_aclkr,
    output reg       o_break_send_aclkr,
    output reg       o_idle_send_aclkr,
    output reg [3:0] o_data_aclkr,
    input wire       i_rx_busy,
    input wire       i_tx_busy,
    input wire       i_rx_fifo_full,
    input wire       i_rx_fifo_empty,
    input wire       i_tx_fifo_full,
    input wire       i_tx_fifo_empty,
    output reg       o_int_break_det_en_aclkr,
    output reg       o_int_parity_err_en_aclkr,
    output reg       o_int_framing_err_en_aclkr,
    output reg       o_int_rx_timeout_en_aclkr,
    output reg       o_int_overrun_err_en_aclkr,
    output reg       o_int_tx_fifo_th_en_aclkr,
    output reg       o_int_rx_fifo_th_en_aclkr,
    output reg [3:0] o_rx_fifo_th_level_aclkr,
    output reg [3:0] o_tx_fifo_th_level_aclkr,
    input wire       i_int_break_det_raw_set,
    input wire       i_int_parity_err_raw_set,
    input wire       i_int_framing_err_raw_set,
    input wire       i_int_rx_timeout_raw_set,
    input wire       i_int_overrun_err_raw_set,
    input wire       i_int_tx_fifo_th_raw_set,
    input wire       i_int_rx_fifo_th_raw_set,
    output wire        o_interrupt_aclkr,
    //====================================================
    // AXI4-Lite Ports
    //====================================================
    //AW Channel
    input  wire  [   ADDR_BITWIDTH -1:0] awaddr,
    input  wire                          awprot,
    input  wire                          awvalid,
    output logic                         awready,
    //W Channel
    input  wire  [   DATA_BITWIDTH -1:0] wdata,
    input  wire  [(ADDR_BITWIDTH/8)-1:0] wstrb,
    input  wire                          wvalid,
    output logic                         wready,
    //B Channel
    output reg   [                  1:0] bresp,
    output reg                           bvalid,
    input  wire                          bready,
    //AR Channel
    input  wire  [   ADDR_BITWIDTH -1:0] araddr,
    input  wire                          arprot,
    input  wire                          arvalid,
    output reg                           arready,
    //R Channel
    output reg   [   DATA_BITWIDTH -1:0] rdata,
    output logic [                  1:0] rresp,
    output reg                           rvalid,
    input  wire                          rready

);


    //====================================================
    // Write Transaction
    //====================================================

    logic                         aw_trans_done;
    reg                           aw_trans_done_hold_aclkr;
    logic                         w_trans_done;
    reg                           w_trans_done_hold_aclkr;

    reg   [   ADDR_BITWIDTH -1:0] awaddr_hold_aclkr;
    reg                           awprot_hold_aclkr;
    reg   [   DATA_BITWIDTH -1:0] wdata_hold_aclkr;
    reg   [(ADDR_BITWIDTH/8)-1:0] wstrb_hold_aclkr;

    logic [    ADDR_BITWIDTH-1:0] target_awaddr;
    logic [    DATA_BITWIDTH-1:0] target_wdata;
    logic [(DATA_BITWIDTH/8)-1:0] target_wstrb;

    logic                         aw_accepted;
    logic                         w_accepted;
    logic                         write_exec;


    assign aw_trans_done = awvalid && awready;
    assign w_trans_done = wvalid && wready;

    assign aw_accepted = (aw_trans_done || aw_trans_done_hold_aclkr);
    assign w_accepted = (w_trans_done || w_trans_done_hold_aclkr);
    assign write_exec = aw_accepted && w_accepted;


    //##########
    //AW Channel
    //##########
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            aw_trans_done_hold_aclkr <= 1'b0;
        end else if (aw_trans_done && !w_accepted) begin
            aw_trans_done_hold_aclkr <= 1'b1;
        end else if (w_accepted) begin
            aw_trans_done_hold_aclkr <= 1'b0;
        end
    end
    assign awready = !aw_trans_done_hold_aclkr && !bvalid;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            awaddr_hold_aclkr <= '0;
            awprot_hold_aclkr <= '0;
        end else if (aw_trans_done) begin
            awaddr_hold_aclkr <= awaddr;
            awprot_hold_aclkr <= awprot;
        end else if (write_exec) begin
            awaddr_hold_aclkr <= '0;
            awprot_hold_aclkr <= '0;
        end
    end
    assign target_awaddr = aw_trans_done_hold_aclkr ? awaddr_hold_aclkr : awaddr;

    //##########
    //W Channel
    //##########
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            w_trans_done_hold_aclkr <= 1'b0;
        end else if (w_trans_done && !aw_accepted) begin
            w_trans_done_hold_aclkr <= 1'b1;
        end else if (aw_accepted) begin
            w_trans_done_hold_aclkr <= 1'b0;
        end
    end
    assign wready = !w_trans_done_hold_aclkr && !bvalid;

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            wdata_hold_aclkr <= '0;
            wstrb_hold_aclkr <= '0;
        end else if (w_trans_done) begin
            wdata_hold_aclkr <= wdata;
            wstrb_hold_aclkr <= wstrb;
        end else if (write_exec) begin
            wdata_hold_aclkr <= '0;
            wstrb_hold_aclkr <= '0;
        end
    end
    assign target_wdata = w_trans_done_hold_aclkr ? wdata_hold_aclkr : wdata;
    assign target_wstrb = w_trans_done_hold_aclkr ? wstrb_hold_aclkr : wstrb;

    //##########
    //B Channel
    //##########
    assign bresp = 2'b00;  //OKAY  
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            bvalid <= 1'b0;
        end else if (write_exec) begin
            bvalid <= 1'b1;
        end else if (bready) begin
            bvalid <= 1'b0;
        end
    end


    //====================================================
    // Read Transaction
    //====================================================
    logic ar_trans_done;
    logic r_trans_done;
    logic read_exec;

    assign ar_trans_done = arvalid && arready;
    assign r_trans_done = rvalid && rready;
    assign read_exec = ar_trans_done;

    assign rresp = 2'b0;
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            arready <= 1'b1;
            rvalid  <= 1'b0;
        end else if (ar_trans_done) begin
            arready <= 1'b0;
            rvalid  <= 1'b1;
        end else if (r_trans_done) begin
            arready <= 1'b1;
            rvalid  <= 1'b0;
        end
    end


    //====================================================
    // USER_LOGIC
    //====================================================

        wire we_uart_enable;
    wire we_conf_data_bit_width;
    wire we_conf_stop_bit_width_sel;
    wire we_conf_parity_bit;
    wire we_conf_tx_env;
    wire we_conf_rx_env;
    wire we_conf_hw_flow_en;
    wire we_conf__samp_num_sel;
    wire we_conf_over_samp_sel;
    wire we_conf_clk_div;
    wire we_break_send;
    wire we_idle_send;
    wire we_data;
    wire we_int_break_det_en;
    wire we_int_parity_err_en;
    wire we_int_framing_err_en;
    wire we_int_rx_timeout_en;
    wire we_int_overrun_err_en;
    wire we_int_tx_fifo_th_en;
    wire we_int_rx_fifo_th_en;
    wire we_rx_fifo_th_level;
    wire we_tx_fifo_th_level;
    wire we_int_break_det_raw;
    reg int_break_det_raw_aclkr;
    wire we_int_parity_err_raw;
    reg int_parity_err_raw_aclkr;
    wire we_int_framing_err_raw;
    reg int_framing_err_raw_aclkr;
    wire we_int_rx_timeout_raw;
    reg int_rx_timeout_raw_aclkr;
    wire we_int_overrun_err_raw;
    reg int_overrun_err_raw_aclkr;
    wire we_int_tx_fifo_th_raw;
    reg int_tx_fifo_th_raw_aclkr;
    wire we_int_rx_fifo_th_raw;
    reg int_rx_fifo_th_raw_aclkr;
    wire int_break_det_masked;
    wire int_parity_err_masked;
    wire int_framing_err_masked;
    wire int_rx_timeout_masked;
    wire int_overrun_err_masked;
    wire int_tx_fifo_th_masked;
    wire int_rx_fifo_th_masked;

        assign we_uart_enable = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h00) && target_wstrb[0];
    assign we_conf_data_bit_width = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h04) && target_wstrb[1];
    assign we_conf_stop_bit_width_sel = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h04) && target_wstrb[0];
    assign we_conf_parity_bit = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h04) && target_wstrb[0];
    assign we_conf_tx_env = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h08) && target_wstrb[0];
    assign we_conf_rx_env = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h08) && target_wstrb[0];
    assign we_conf_hw_flow_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h08) && target_wstrb[0];
    assign we_conf__samp_num_sel = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h0C) && target_wstrb[2];
    assign we_conf_over_samp_sel = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h0C) && target_wstrb[2];
    assign we_conf_clk_div = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h0C) && (target_wstrb[0] || target_wstrb[1]);
    assign we_break_send = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h10) && target_wstrb[0];
    assign we_idle_send = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h10) && target_wstrb[0];
    assign we_data = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h10) && target_wstrb[0];
    assign we_int_break_det_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[3];
    assign we_int_parity_err_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[2];
    assign we_int_framing_err_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[2];
    assign we_int_rx_timeout_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[1];
    assign we_int_overrun_err_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[1];
    assign we_int_tx_fifo_th_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[0];
    assign we_int_rx_fifo_th_en = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h18) && target_wstrb[0];
    assign we_rx_fifo_th_level = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h20) && target_wstrb[0];
    assign we_tx_fifo_th_level = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h20) && target_wstrb[0];
    assign we_int_break_det_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[3];
    assign we_int_parity_err_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[2];
    assign we_int_framing_err_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[2];
    assign we_int_rx_timeout_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[1];
    assign we_int_overrun_err_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[1];
    assign we_int_tx_fifo_th_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[0];
    assign we_int_rx_fifo_th_raw = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == 8'h24) && target_wstrb[0];

        assign int_break_det_masked = int_break_det_raw_aclkr & o_int_break_det_en_aclkr;
    assign int_parity_err_masked = int_parity_err_raw_aclkr & o_int_parity_err_en_aclkr;
    assign int_framing_err_masked = int_framing_err_raw_aclkr & o_int_framing_err_en_aclkr;
    assign int_rx_timeout_masked = int_rx_timeout_raw_aclkr & o_int_rx_timeout_en_aclkr;
    assign int_overrun_err_masked = int_overrun_err_raw_aclkr & o_int_overrun_err_en_aclkr;
    assign int_tx_fifo_th_masked = int_tx_fifo_th_raw_aclkr & o_int_tx_fifo_th_en_aclkr;
    assign int_rx_fifo_th_masked = int_rx_fifo_th_raw_aclkr & o_int_rx_fifo_th_en_aclkr;

    //Field : int_rx_fifo_th_masked
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_interrupt_aclkr <= 1'd0;
        end else if(we_int_rx_fifo_th_raw) begin
            o_interrupt_aclkr <= (int_break_det_masked) | (int_parity_err_masked) | (int_framing_err_masked) | (int_rx_timeout_masked) | (int_overrun_err_masked) | (int_tx_fifo_th_masked) | (int_rx_fifo_th_masked); 
        end
    end



    
    //Field : uart_enable
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_uart_enable_aclkr <= 1'd0;
        end else if(we_uart_enable) begin
            o_uart_enable_aclkr <= target_wdata[0]; 
        end
    end



    //Field : conf_data_bit_width
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_data_bit_width_aclkr <= 4'd8;
        end else if(we_conf_data_bit_width) begin
            o_conf_data_bit_width_aclkr <= target_wdata[11:8]; 
        end
    end



    //Field : conf_stop_bit_width_sel
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_stop_bit_width_sel_aclkr <= 2'd1;
        end else if(we_conf_stop_bit_width_sel) begin
            o_conf_stop_bit_width_sel_aclkr <= target_wdata[5:4]; 
        end
    end



    //Field : conf_parity_bit
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_parity_bit_aclkr <= 2'd0;
        end else if(we_conf_parity_bit) begin
            o_conf_parity_bit_aclkr <= target_wdata[1:0]; 
        end
    end



    //Field : conf_tx_env
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_tx_env_aclkr <= 1'd0;
        end else if(we_conf_tx_env) begin
            o_conf_tx_env_aclkr <= target_wdata[5]; 
        end
    end



    //Field : conf_rx_env
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_rx_env_aclkr <= 1'd0;
        end else if(we_conf_rx_env) begin
            o_conf_rx_env_aclkr <= target_wdata[4]; 
        end
    end



    //Field : conf_hw_flow_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_hw_flow_en_aclkr <= 1'd0;
        end else if(we_conf_hw_flow_en) begin
            o_conf_hw_flow_en_aclkr <= target_wdata[0]; 
        end
    end



    //Field : conf__samp_num_sel
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf__samp_num_sel_aclkr <= 1'd0;
        end else if(we_conf__samp_num_sel) begin
            o_conf__samp_num_sel_aclkr <= target_wdata[20]; 
        end
    end



    //Field : conf_over_samp_sel
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_over_samp_sel_aclkr <= 2'd1;
        end else if(we_conf_over_samp_sel) begin
            o_conf_over_samp_sel_aclkr <= target_wdata[17:16]; 
        end
    end



    //Field : conf_clk_div
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_conf_clk_div_aclkr <= 16'd0;
        end else if(we_conf_clk_div) begin
            o_conf_clk_div_aclkr <= target_wdata[15:0]; 
        end
    end



    //Field : break_send
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_break_send_aclkr <= 1'd0;
        end else if(we_break_send) begin
            o_break_send_aclkr <= target_wdata[5]; 
        end
    end



    //Field : idle_send
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_idle_send_aclkr <= 1'd0;
        end else if(we_idle_send) begin
            o_idle_send_aclkr <= target_wdata[4]; 
        end
    end



    //Field : data
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_data_aclkr <= 4'd0;
        end else if(we_data) begin
            o_data_aclkr <= target_wdata[3:0]; 
        end
    end



    //Field : int_break_det_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_break_det_en_aclkr <= 1'd0;
        end else if(we_int_break_det_en) begin
            o_int_break_det_en_aclkr <= target_wdata[24]; 
        end
    end



    //Field : int_parity_err_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_parity_err_en_aclkr <= 1'd0;
        end else if(we_int_parity_err_en) begin
            o_int_parity_err_en_aclkr <= target_wdata[20]; 
        end
    end



    //Field : int_framing_err_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_framing_err_en_aclkr <= 1'd0;
        end else if(we_int_framing_err_en) begin
            o_int_framing_err_en_aclkr <= target_wdata[16]; 
        end
    end



    //Field : int_rx_timeout_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_rx_timeout_en_aclkr <= 1'd0;
        end else if(we_int_rx_timeout_en) begin
            o_int_rx_timeout_en_aclkr <= target_wdata[12]; 
        end
    end



    //Field : int_overrun_err_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_overrun_err_en_aclkr <= 1'd0;
        end else if(we_int_overrun_err_en) begin
            o_int_overrun_err_en_aclkr <= target_wdata[8]; 
        end
    end



    //Field : int_tx_fifo_th_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_tx_fifo_th_en_aclkr <= 1'd0;
        end else if(we_int_tx_fifo_th_en) begin
            o_int_tx_fifo_th_en_aclkr <= target_wdata[4]; 
        end
    end



    //Field : int_rx_fifo_th_en
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_int_rx_fifo_th_en_aclkr <= 1'd0;
        end else if(we_int_rx_fifo_th_en) begin
            o_int_rx_fifo_th_en_aclkr <= target_wdata[0]; 
        end
    end



    //Field : rx_fifo_th_level
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_rx_fifo_th_level_aclkr <= 4'd0;
        end else if(we_rx_fifo_th_level) begin
            o_rx_fifo_th_level_aclkr <= target_wdata[7:4]; 
        end
    end



    //Field : tx_fifo_th_level
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_tx_fifo_th_level_aclkr <= 4'd0;
        end else if(we_tx_fifo_th_level) begin
            o_tx_fifo_th_level_aclkr <= target_wdata[3:0]; 
        end
    end



    //Field : int_break_det_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_break_det_raw_aclkr <= 1'd0;
        end else if(we_int_break_det_raw && target_wdata[24]) begin
            int_break_det_raw_aclkr <= 1'd0; 
        end else if(i_int_break_det_raw_set) begin
            int_break_det_raw_aclkr <= 1'd1;
        end                                          
    end  

          

    //Field : int_parity_err_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_parity_err_raw_aclkr <= 1'd0;
        end else if(we_int_parity_err_raw && target_wdata[20]) begin
            int_parity_err_raw_aclkr <= 1'd0; 
        end else if(i_int_parity_err_raw_set) begin
            int_parity_err_raw_aclkr <= 1'd1;
        end                                          
    end  

          

    //Field : int_framing_err_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_framing_err_raw_aclkr <= 1'd0;
        end else if(we_int_framing_err_raw && target_wdata[16]) begin
            int_framing_err_raw_aclkr <= 1'd0; 
        end else if(i_int_framing_err_raw_set) begin
            int_framing_err_raw_aclkr <= 1'd1;
        end                                          
    end  

          

    //Field : int_rx_timeout_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_rx_timeout_raw_aclkr <= 1'd0;
        end else if(we_int_rx_timeout_raw && target_wdata[12]) begin
            int_rx_timeout_raw_aclkr <= 1'd0; 
        end else if(i_int_rx_timeout_raw_set) begin
            int_rx_timeout_raw_aclkr <= 1'd1;
        end                                          
    end  

          

    //Field : int_overrun_err_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_overrun_err_raw_aclkr <= 1'd0;
        end else if(we_int_overrun_err_raw && target_wdata[8]) begin
            int_overrun_err_raw_aclkr <= 1'd0; 
        end else if(i_int_overrun_err_raw_set) begin
            int_overrun_err_raw_aclkr <= 1'd1;
        end                                          
    end  

          

    //Field : int_tx_fifo_th_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_tx_fifo_th_raw_aclkr <= 1'd0;
        end else if(we_int_tx_fifo_th_raw && target_wdata[4]) begin
            int_tx_fifo_th_raw_aclkr <= 1'd0; 
        end else if(i_int_tx_fifo_th_raw_set) begin
            int_tx_fifo_th_raw_aclkr <= 1'd1;
        end                                          
    end  

          

    //Field : int_rx_fifo_th_raw
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            int_rx_fifo_th_raw_aclkr <= 1'd0;
        end else if(we_int_rx_fifo_th_raw && target_wdata[0]) begin
            int_rx_fifo_th_raw_aclkr <= 1'd0; 
        end else if(i_int_rx_fifo_th_raw_set) begin
            int_rx_fifo_th_raw_aclkr <= 1'd1;
        end                                          
    end  

          


    //Read logic
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rdata <= '0;
        end else if (read_exec) begin
            case (araddr[VARID_ADDR_BITWIDTH-1:0])
                                8'h00: rdata <= { 31'h0, o_uart_enable_aclkr };
                8'h04: rdata <= { 20'h0, o_conf_data_bit_width_aclkr, 2'h0, o_conf_stop_bit_width_sel_aclkr, 2'h0, o_conf_parity_bit_aclkr };
                8'h08: rdata <= { 26'h0, o_conf_tx_env_aclkr, o_conf_rx_env_aclkr, 3'h0, o_conf_hw_flow_en_aclkr };
                8'h0C: rdata <= { 11'h0, o_conf__samp_num_sel_aclkr, 2'h0, o_conf_over_samp_sel_aclkr, o_conf_clk_div_aclkr };
                8'h10: rdata <= { 28'h0, o_data_aclkr };
                8'h14: rdata <= { 19'h0, i_rx_busy, 3'h0, i_tx_busy, 2'h0, i_rx_fifo_full, i_rx_fifo_empty, 2'h0, i_tx_fifo_full, i_tx_fifo_empty };
                8'h18: rdata <= { 7'h0, o_int_break_det_en_aclkr, 3'h0, o_int_parity_err_en_aclkr, 3'h0, o_int_framing_err_en_aclkr, 3'h0, o_int_rx_timeout_en_aclkr, 3'h0, o_int_overrun_err_en_aclkr, 3'h0, o_int_tx_fifo_th_en_aclkr, 3'h0, o_int_rx_fifo_th_en_aclkr };
                8'h20: rdata <= { 24'h0, o_rx_fifo_th_level_aclkr, o_tx_fifo_th_level_aclkr };
                8'h24: rdata <= { 7'h0, o_tx_fifo_th_level_aclkr, 3'h0, o_tx_fifo_th_level_aclkr, 3'h0, o_tx_fifo_th_level_aclkr, 3'h0, o_tx_fifo_th_level_aclkr, 3'h0, o_tx_fifo_th_level_aclkr, 3'h0, o_tx_fifo_th_level_aclkr, 3'h0, o_tx_fifo_th_level_aclkr };
                8'h28: rdata <= { 7'h0, int_break_det_masked, 3'h0, int_parity_err_masked, 3'h0, int_framing_err_masked, 3'h0, int_rx_timeout_masked, 3'h0, int_overrun_err_masked, 3'h0, int_tx_fifo_th_masked, 3'h0, int_rx_fifo_th_masked };
                default: begin
                end
            endcase
        end
    end

endmodule


`default_nettype wire
