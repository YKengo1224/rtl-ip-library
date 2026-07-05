// =====================================================================
// AXI to AXI-Lite Adapter Module
// =====================================================================
module axi2axilite_adapter #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int ID_WIDTH   = 4
)(
    input logic clk,
    input logic rst_n,

    // AXI Slave Port (connected to AXI Master)
    axi_if.slave      s_axi,
    // AXI-Lite Master Port (connected to AXI-Lite Slave)
    axilite_if.master m_axilite
);

    // FSM States for Write Channel
    typedef enum logic [1:0] {
        W_IDLE,       // Wait for AWVALID
        W_TRANSFER,   // Issue AW and W to AXI-Lite, wait for both to complete
        W_BRESP,      // Wait for BVALID from AXI-Lite
        W_AXI_RESP    // Send aggregated BVALID back to AXI Master
    } w_state_t;
    w_state_t w_state;

    // FSM States for Read Channel
    typedef enum logic [1:0] {
        R_IDLE,       // Wait for ARVALID
        R_AR_TRANSFER,// Issue AR to AXI-Lite, wait for ARREADY
        R_DATA        // Wait for RVALID from AXI-Lite, send to AXI Master
    } r_state_t;
    r_state_t r_state;

    // ---------------------------------------------------------------------
    // Helper Function: Calculate next address for burst transfers
    // ---------------------------------------------------------------------
    function automatic logic [ADDR_WIDTH-1:0] get_next_addr(
        input logic [ADDR_WIDTH-1:0] addr,
        input logic [2:0]            size,
        input logic [1:0]            burst
    );
        logic [ADDR_WIDTH-1:0] next_a;
        int bytes;
        bytes = 1 << size; // Number of bytes per transfer

        // Note: WRAP burst (2'b10) boundaries can be complex to calculate. 
        // For standard adapter use-cases, we treat WRAP practically like INCR.
        // True WRAP requires masking based on len and size.
        if (burst == 2'b01 || burst == 2'b10) begin 
            next_a = addr + bytes; // INCR or WRAP (simplified)
        end else begin 
            next_a = addr;         // FIXED
        end
        return next_a;
    endfunction

    // ---------------------------------------------------------------------
    // Write Channel Logic
    // ---------------------------------------------------------------------
    // Latched AW parameters
    logic [ID_WIDTH-1:0]   awid_reg;
    logic [ADDR_WIDTH-1:0] awaddr_reg;
    logic [7:0]            awlen_reg;
    logic [2:0]            awsize_reg;
    logic [1:0]            awburst_reg;
    
    logic [7:0]            w_len_cnt;
    logic [1:0]            w_bresp_acc; // Accumulates worst error response
    
    // Internal flags to track AXI-Lite AW and W completion
    logic m_aw_valid_reg;
    logic m_w_valid_reg;

    // s_axi signal assignments (Write)
    assign s_axi.awready = (w_state == W_IDLE);
    // Accept W data only when we are in W_TRANSFER and the AXI-Lite is ready
    assign s_axi.wready  = (w_state == W_TRANSFER) && m_w_valid_reg && m_axilite.wready;
    assign s_axi.bid     = awid_reg;
    assign s_axi.bresp   = w_bresp_acc;
    assign s_axi.bvalid  = (w_state == W_AXI_RESP);

    // m_axilite signal assignments (Write)
    assign m_axilite.awaddr  = awaddr_reg;
    assign m_axilite.awvalid = m_aw_valid_reg;
    
    assign m_axilite.wdata   = s_axi.wdata;
    assign m_axilite.wstrb   = s_axi.wstrb;
    // Assert wvalid to AXI-Lite only if we haven't finished W and master has valid data
    assign m_axilite.wvalid  = (w_state == W_TRANSFER) && m_w_valid_reg && s_axi.wvalid;
    
    assign m_axilite.bready  = (w_state == W_BRESP);

    // Write FSM process
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state        <= W_IDLE;
            m_aw_valid_reg <= 1'b0;
            m_w_valid_reg  <= 1'b0;
            w_len_cnt      <= '0;
            w_bresp_acc    <= 2'b00;
            awid_reg       <= '0;
            awaddr_reg     <= '0;
            awlen_reg      <= '0;
            awsize_reg     <= '0;
            awburst_reg    <= '0;
        end else begin
            case (w_state)
                W_IDLE: begin
                    if (s_axi.awvalid && s_axi.awready) begin
                        // Latch transaction details
                        awid_reg    <= s_axi.awid;
                        awaddr_reg  <= s_axi.awaddr;
                        awlen_reg   <= s_axi.awlen;
                        awsize_reg  <= s_axi.awsize;
                        awburst_reg <= s_axi.awburst;
                        
                        w_len_cnt   <= '0;
                        w_bresp_acc <= 2'b00; // Reset response accumulator
                        
                        // Start the first AXI-Lite AW and W transfer
                        m_aw_valid_reg <= 1'b1;
                        m_w_valid_reg  <= 1'b1;
                        w_state        <= W_TRANSFER;
                    end
                end

                W_TRANSFER: begin
                    // Clear valid flags once accepted by AXI-Lite
                    if (m_axilite.awvalid && m_axilite.awready) begin
                        m_aw_valid_reg <= 1'b0;
                    end
                    if (m_axilite.wvalid && m_axilite.wready) begin
                        m_w_valid_reg <= 1'b0;
                    end
                    
                    // Transition to BRESP when BOTH AW and W transfers are complete
                    if ((~m_aw_valid_reg | (m_axilite.awvalid & m_axilite.awready)) &
                        (~m_w_valid_reg  | (m_axilite.wvalid  & m_axilite.wready))) begin
                        w_state <= W_BRESP;
                    end
                end

                W_BRESP: begin
                    if (m_axilite.bvalid && m_axilite.bready) begin
                        // Accumulate errors (OKAY=0, EXOKAY=1, SLVERR=2, DECERR=3)
                        // If an error occurs during burst, keep it as the final response
                        if (m_axilite.bresp != 2'b00) begin
                            w_bresp_acc <= m_axilite.bresp;
                        end

                        if (w_len_cnt == awlen_reg) begin
                            // Reached the end of the burst
                            w_state <= W_AXI_RESP;
                        end else begin
                            // Setup next transfer in the burst
                            w_len_cnt      <= w_len_cnt + 1;
                            awaddr_reg     <= get_next_addr(awaddr_reg, awsize_reg, awburst_reg);
                            
                            m_aw_valid_reg <= 1'b1;
                            m_w_valid_reg  <= 1'b1;
                            w_state        <= W_TRANSFER;
                        end
                    end
                end

                W_AXI_RESP: begin
                    // Wait for AXI Master to accept the final B response
                    if (s_axi.bvalid && s_axi.bready) begin
                        w_state <= W_IDLE;
                    end
                end
            endcase
        end
    end

    // ---------------------------------------------------------------------
    // Read Channel Logic
    // ---------------------------------------------------------------------
    // Latched AR parameters
    logic [ID_WIDTH-1:0]   arid_reg;
    logic [ADDR_WIDTH-1:0] araddr_reg;
    logic [7:0]            arlen_reg;
    logic [2:0]            arsize_reg;
    logic [1:0]            arburst_reg;
    
    logic [7:0]            r_len_cnt;
    logic                  m_ar_valid_reg;

    // s_axi signal assignments (Read)
    assign s_axi.arready = (r_state == R_IDLE);
    assign s_axi.rid     = arid_reg;
    assign s_axi.rdata   = m_axilite.rdata;
    assign s_axi.rresp   = m_axilite.rresp;
    assign s_axi.rlast   = (r_len_cnt == arlen_reg); // Assert last on final burst beat
    // Relay valid from AXI-Lite to AXI Master during R_DATA phase
    assign s_axi.rvalid  = (r_state == R_DATA) && m_axilite.rvalid;

    // m_axilite signal assignments (Read)
    assign m_axilite.araddr  = araddr_reg;
    assign m_axilite.arvalid = m_ar_valid_reg;
    // Accept read data from AXI-Lite only when AXI Master is ready
    assign m_axilite.rready  = (r_state == R_DATA) && s_axi.rready;

    // Read FSM process
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_state        <= R_IDLE;
            m_ar_valid_reg <= 1'b0;
            r_len_cnt      <= '0;
            arid_reg       <= '0;
            araddr_reg     <= '0;
            arlen_reg      <= '0;
            arsize_reg     <= '0;
            arburst_reg    <= '0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    if (s_axi.arvalid && s_axi.arready) begin
                        // Latch read transaction details
                        arid_reg    <= s_axi.arid;
                        araddr_reg  <= s_axi.araddr;
                        arlen_reg   <= s_axi.arlen;
                        arsize_reg  <= s_axi.arsize;
                        arburst_reg <= s_axi.arburst;
                        
                        r_len_cnt   <= '0;
                        
                        // Issue first AR to AXI-Lite
                        m_ar_valid_reg <= 1'b1;
                        r_state        <= R_AR_TRANSFER;
                    end
                end

                R_AR_TRANSFER: begin
                    // Wait for AXI-Lite to accept AR
                    if (m_axilite.arvalid && m_axilite.arready) begin
                        m_ar_valid_reg <= 1'b0;
                        r_state        <= R_DATA;
                    end
                end

                R_DATA: begin
                    // Wait for valid data from AXI-Lite and ready from AXI Master
                    if (s_axi.rvalid && s_axi.rready) begin
                        if (r_len_cnt == arlen_reg) begin
                            // Burst complete
                            r_state <= R_IDLE;
                        end else begin
                            // Setup next read in the burst sequence
                            r_len_cnt      <= r_len_cnt + 1;
                            araddr_reg     <= get_next_addr(araddr_reg, arsize_reg, arburst_reg);
                            
                            m_ar_valid_reg <= 1'b1;
                            r_state        <= R_AR_TRANSFER;
                        end
                    end
                end
            endcase
        end
    end

endmodule
