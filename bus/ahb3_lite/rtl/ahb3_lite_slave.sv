`default_nettype none

module ahb3_lite_slave #(
) (
    input  wire         clk_i,
    input  wire         rst_n_i,
    input  wire  [31:0] haddr_i,
    input  wire  [ 2:0] hburst_i,
    //input wire        h_must_lock,
    //input wire [3:0] hprot_i,
    input  wire  [ 2:0] hsize_i,
    input  wire  [ 1:0] htrans_i,
    input  wire  [31:0] hwdata_i,
    input  wire         hwrite_i,
    input  wire         hsel_i,
    output logic [31:0] hrdata_o,
    output logic        hready_o,
    output logic        hresp_o
);


    //######################################
    // trans type
    //######################################
    localparam [1:0] TRANS_IDLE = 2'b00;
    localparam [1:0] TRANS_BUSY = 2'b01;
    localparam [1:0] TRANS_NONSEQ = 2'b10;
    localparam [1:0] TRANS_SEQ = 2'b11;



    //######################################
    // burst type
    //######################################
    localparam [2:0] BURST_SINGLE = 3'b000;
    localparam [2:0] BURST_INCR = 3'b001;
    localparam [2:0] BURST_WRAP4 = 3'b010;
    localparam [2:0] BURST_INCR4 = 3'b011;
    localparam [2:0] BURST_WRAP8 = 3'b100;
    localparam [2:0] BURST_INCR8 = 3'b101;
    localparam [2:0] BURST_WRAP16 = 3'b110;
    localparam [2:0] BURST_INCR16 = 3'b111;



    //######################################
    // burst data transfer  max count 
    //######################################
    localparam [3:0] BURST_4_MAX = 4'd3;
    localparam [3:0] BURST_8_MAX = 4'd7;
    localparam [3:0] BURST_16_MAX = 4'd15;


    //######################################
    // hsize parameter 
    //######################################
    localparam [2:0] SIZE_BYTE = 3'b000;
    localparam [2:0] SIZE_HWORD = 3'b001;
    localparam [2:0] SIZE_WORD = 3'b010;
    localparam [2:0] SIZE_DWORD = 3'b011;
    localparam [2:0] SIZE_4WORD = 3'b101;
    localparam [2:0] SIZE_8WORD = 3'b110;
    localparam [2:0] SIZE_16WORD = 3'b111;
    //######################################
    //######################################

    wire         valid_transfer;
    logic        burst_flag;
    logic [ 3:0] burst_count;
    logic [ 3:0] burst_count_max;


    logic [31:0] haddr_ff;
    logic        ready;
    logic        resp;

    assign valid_transfer = (hready_o && hsel_i);


    //######################################
    // state  
    //######################################
    typedef enum logic [3:0] {
        S_IDLE,
        S_ADDR,
        S_READ,
        S_WRITE,
        S_BURST_READ,
        S_BURST_WRITE,
        S_BURST_READ_STREAM,  // formerly NON_SIZE
        S_BURST_WRITE_STREAM  // formerly NON_SIZE
    } state_t;


    state_t state;
    state_t state_next;


    always_comb begin
        state_next = state;
        case (state)
            S_IDLE: begin
                state_next = select_trans_type();
            end
            S_WRITE, S_READ: begin
                state_next = select_trans_type();
            end
            S_BURST_WRITE, S_BURST_READ: begin
                if (burst_count == burst_count_max) begin
                    state_next = select_trans_type();
                end
            end
            S_BURST_READ_STREAM, S_BURST_WRITE_STREAM: begin
                if (htrans_i != TRANS_SEQ) begin
                    state_next = select_trans_type();
                end
            end
            default: begin
                state_next = S_IDLE;
            end
        endcase
    end

    function state_t select_trans_type();
        if (valid_transfer && (htrans_i == TRANS_NONSEQ)) begin
            if (hburst_i == BURST_SINGLE) begin
                if (hwrite_i) begin
                    select_trans_type = S_WRITE;
                end else begin
                    select_trans_type = S_READ;
                end
            end else if (hburst_i == BURST_INCR) begin
                if (hwrite_i) begin
                    select_trans_type = S_BURST_WRITE_STREAM;
                end else begin
                    select_trans_type = S_BURST_READ_STREAM;
                end
            end else begin
                if (hwrite_i) begin
                    select_trans_type = S_BURST_WRITE;
                end else begin
                    select_trans_type = S_BURST_READ;
                end
            end
        end else begin
            select_trans_type = S_IDLE;
        end
    endfunction


    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= S_IDLE;
        end else begin
            state <= state_next;
        end
    end

    //######################################
    //######################################


    //######################################
    // BURST transfer
    //######################################
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            burst_count <= '0;
        end else if ((state == S_BURST_WRITE) || (state == S_BURST_READ)) begin
            if (valid_transfer) begin
                if ((htrans_i == TRANS_SEQ)) begin
                    if (burst_count == (burst_count_max - 1)) begin
                        burst_count <= '0;
                    end else begin
                        burst_count <= burst_count + 1;
                    end
                end else begin
                    burst_count <= '0;
                end
            end
        end else begin
            burst_count <= '0;
        end
    end

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            burst_count_max <= '0;
        end else if ((state_next == S_BURST_WRITE) && (state_next == S_BURST_READ)) begin
            case (hburst_i)
                BURST_INCR4, BURST_WRAP4: begin
                    burst_count_max <= BURST_4_MAX;
                end
                BURST_INCR8, BURST_WRAP8: begin
                    burst_count_max <= BURST_8_MAX;
                end
                BURST_INCR16, BURST_WRAP16: begin
                    burst_count_max <= BURST_16_MAX;
                end
                default: begin
                    burst_count_max <= '0;
                end
            endcase
        end
    end

    //######################################
    //######################################

    //######################################
    // addr ff(1delay addr)
    //######################################

    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            haddr_ff <= '0;
        end else if (hready_o) begin
            haddr_ff <= haddr_i;
        end
    end

    //######################################
    //######################################


    //######################################
    // write transfer
    //######################################

    reg [31:0] test_reg;
    reg [31:0] test2_reg;


    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            test_reg  <= 'd0;
            test2_reg <= 'd0;
        end else if (hready_o) begin
            case (state)
                S_WRITE: begin
                    case (haddr_ff[31:2])
                        'h0: begin
                            test_reg <= write_reg(test_reg);
                        end
                        'h1: begin
                            test2_reg <= write_reg(test2_reg);
                        end
                    endcase
                end
                S_BURST_WRITE, S_BURST_WRITE_STREAM: begin
                    if (htrans_i == TRANS_SEQ) begin
                        case (haddr_ff[31:2])
                            'h0: begin
                                test_reg <= write_reg(test_reg);
                            end
                            'h1: begin
                                test2_reg <= write_reg(test2_reg);
                            end
                        endcase
                    end
                end
            endcase
        end
    end

    function automatic [31:0] write_reg(input [31:0] reg_in);
        write_reg = reg_in;
        case (hsize_i)
            SIZE_BYTE: begin
                case (haddr_ff[1:0])
                    2'b00: write_reg[7:0] = hwdata_i[7:0];
                    2'b01: write_reg[15:8] = hwdata_i[15:8];
                    2'b10: write_reg[23:16] = hwdata_i[23:16];
                    2'b11: write_reg[31:24] = hwdata_i[31:24];
                endcase
            end
            SIZE_HWORD: begin
                case (haddr_ff[1:0])
                    2'b00: write_reg[15:0] = hwdata_i[15:0];
                    2'b10: write_reg[31:16] = hwdata_i[31:16];
                endcase
            end
            SIZE_WORD: begin
                write_reg = hwdata_i;
            end
        endcase
    endfunction

    //######################################
    //######################################

    //######################################
    // read transfer
    //######################################


    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            hrdata_o <= '0;
        end else if (ready) begin
            case (state_next)
                S_READ: begin
                    case (haddr_i[31:2])
                        'h0: begin
                            test_reg <= write_reg(test_reg);
                        end
                        'h1: begin
                            test2_reg <= write_reg(test2_reg);
                        end
                    endcase
                end
                S_BURST_READ, S_BURST_READ_STREAM: begin
                    if (htrans_i[1] == 1) begin  //NONSEQ or SEQ
                        case (haddr_i[31:2])
                            'h0: begin
                                test_reg <= write_reg(test_reg);
                            end
                            'h1: begin
                                test2_reg <= write_reg(test2_reg);
                            end
                        endcase
                    end
                end
            endcase
        end
    end



    function automatic [31:0] read_reg(input [31:0] reg_in);
        read_reg = '0;
        case (hsize_i)
            SIZE_BYTE: begin
                case (haddr_i[1:0])
                    2'b00: read_reg[7:0] = reg_in[7:0];
                    2'b01: read_reg[15:8] = reg_in[15:8];
                    2'b10: read_reg[23:16] = reg_in[23:16];
                    2'b11: read_reg[31:24] = reg_in[31:24];
                endcase
            end
            SIZE_HWORD: begin
                case (haddr_i[1:0])
                    2'b00: read_reg[15:0] = reg_in[15:0];
                    2'b10: read_reg[31:16] = reg_in[31:16];
                endcase
            end
            SIZE_WORD: begin
                read_reg = reg_in;
            end
        endcase
    endfunction


    //######################################
    //######################################


    //######################################
    // ready
    //######################################
    assign ready = 1'b1;
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            hready_o <= 1'b1;
        end else begin
            hready_o <= ready;
        end
    end

    //######################################
    //######################################

    //######################################
    // respone
    //######################################
    assign resp = 1'b0;
    always_ff @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            hresp_o <= 1'b1;
        end else begin
            hresp_o <= resp;
        end
    end

    //######################################
    //######################################
endmodule
`default_nettype wire
