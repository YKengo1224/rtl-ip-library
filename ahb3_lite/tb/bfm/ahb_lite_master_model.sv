module ahb_lite_master_model #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic                  HCLK,
    input  logic                  HRESETn,
    output logic [ADDR_WIDTH-1:0] HADDR,
    output logic [           1:0] HTRANS,
    output logic                  HWRITE,
    output logic [           2:0] HSIZE,
    output logic [           2:0] HBURST,
    output logic [DATA_WIDTH-1:0] HWDATA,
    input  logic [DATA_WIDTH-1:0] HRDATA,
    input  logic                  HREADY
);

    //===========================================================
    // Local parameters
    //===========================================================
    localparam [1:0] TR_IDLE = 2'b00;
    localparam [1:0] TR_BUSY = 2'b01;
    localparam [1:0] TR_NONSEQ = 2'b10;
    localparam [1:0] TR_SEQ = 2'b11;

    // burst type
    localparam [2:0] BURST_SINGLE = 3'b000;
    localparam [2:0] BURST_INCR4 = 3'b011;
    localparam [2:0] BURST_INCR8 = 3'b101;
    localparam [2:0] BURST_INCR16 = 3'b111;

    //===========================================================
    // Internal registers
    //===========================================================
    logic [ADDR_WIDTH-1:0] addr_q;
    logic [DATA_WIDTH-1:0] wdata_q;
    logic [           2:0] size_q;
    logic [           2:0] burst_q;
    logic                  write_q;

    //===========================================================
    // Task : Single write
    //===========================================================
    task automatic ahb_single_write(input [ADDR_WIDTH-1:0] addr, input [DATA_WIDTH-1:0] data,
                                    input [2:0] size);
        @(posedge HCLK);
        HADDR  <= addr;
        HWRITE <= 1;
        HSIZE  <= size;
        HBURST <= BURST_SINGLE;
        HTRANS <= TR_NONSEQ;
        HWDATA <= data;

        forever begin
            @(posedge HCLK);
            if (HREADY) begin
                break;
            end
        end
        HTRANS <= TR_IDLE;
    endtask

    //===========================================================
    // Task : Single read
    //===========================================================
    task automatic ahb_single_read(input [ADDR_WIDTH-1:0] addr, input [2:0] size,
                                   output [DATA_WIDTH-1:0] data_out);
        @(posedge HCLK);
        HADDR  <= addr;
        HWRITE <= 0;
        HSIZE  <= size;
        HBURST <= BURST_SINGLE;
        HTRANS <= TR_NONSEQ;

        forever begin
            @(posedge HCLK);
            if (HREADY) begin
                break;
            end
        end
        data_out = HRDATA;
        HTRANS <= TR_IDLE;
    endtask

    //===========================================================
    // Task : Burst Write (INCR type)
    //===========================================================
    task automatic ahb_burst_write(input [ADDR_WIDTH-1:0] start_addr,
                                   input [DATA_WIDTH-1:0] data_array[], input [2:0] size,
                                   input [2:0] burst_type);
        int i;
        int burst_len;
        case (burst_type)
            BURST_INCR4:  burst_len = 4;
            BURST_INCR8:  burst_len = 8;
            BURST_INCR16: burst_len = 16;
            default:      burst_len = data_array.size();
        endcase

        @(posedge HCLK);
        HWRITE <= 1;
        HSIZE  <= size;
        HBURST <= burst_type;
        HTRANS <= TR_NONSEQ;
        HADDR  <= start_addr;
        HWDATA <= data_array[0];

        for (i = 1; i < burst_len; i++) begin
            forever begin
                @(posedge HCLK);
                if (HREADY) begin
                    break;
                end
            end
            HADDR  <= start_addr + (i * (1 << size));
            HWDATA <= data_array[i];
            HTRANS <= TR_SEQ;
        end

        forever begin
            @(posedge HCLK);
            if (HREADY) begin
                break;
            end
        end
        HTRANS <= TR_IDLE;
    endtask

    //===========================================================
    // Task : Burst Read (INCR type)
    //===========================================================
    task automatic ahb_burst_read(input [ADDR_WIDTH-1:0] start_addr, input [2:0] size,
                                  input [2:0] burst_type, output [DATA_WIDTH-1:0] data_array[]);
        int i;
        int burst_len;
        case (burst_type)
            BURST_INCR4:  burst_len = 4;
            BURST_INCR8:  burst_len = 8;
            BURST_INCR16: burst_len = 16;
            default:      burst_len = 1;
        endcase

        @(posedge HCLK);
        HWRITE <= 0;
        HSIZE  <= size;
        HBURST <= burst_type;
        HTRANS <= TR_NONSEQ;
        HADDR  <= start_addr;

        for (i = 0; i < burst_len; i++) begin
            forever begin
                @(posedge HCLK);
                if (HREADY) begin
                    break;
                end
            end
            data_array[i] = HRDATA;
            HADDR  <= start_addr + ((i + 1) * (1 << size));
            HTRANS <= (i == burst_len - 1) ? TR_IDLE : TR_SEQ;
        end
    endtask

    //===========================================================
    // Default signals
    //===========================================================
    initial begin
        HADDR  = '0;
        HTRANS = TR_IDLE;
        HWRITE = 0;
        HSIZE  = 3'b010;  // word
        HBURST = BURST_SINGLE;
        HWDATA = '0;
    end

endmodule
