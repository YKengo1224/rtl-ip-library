`default_nettype none

module spi_core #(
    parameter int BITWIDTH = 8,
    parameter int P_VALID_BIT_BITWIDTH = $clog2(BITWIDTH) + 1
) (
    input  wire                             clk,
    input  wire                             rst_n,
    input  wire  [                    31:0] spiclk_period_i,
    input  wire                             sys_en_i,
    input  wire                             w_en_i,
    input  wire  [P_VALID_BIT_BITWIDTH-1:0] sdata_valid_bit_num_i,
    input  wire  [            BITWIDTH-1:0] sdata_i,
    output wire                             w_done_o,
    input  wire                             r_en_i,
    input  wire  [P_VALID_BIT_BITWIDTH-1:0] rdata_valid_bit_num_i,
    output wire  [            BITWIDTH-1:0] rdata_o,
    output wire                             rdone_o,
    //SPI signal
    output logic                            spiclk_o,
    output logic                            cs_o,
    output logic                            mosi_o,
    input  logic                            miso_i
);


    //logic [BITWIDTH-1:0]  rdata_r;   


    logic if_busy;
    logic if_busy_r;

    logic [31:0] gen_clk_count;
    logic [P_VALID_BIT_BITWIDTH-1:0] spi_count;


    logic [BITWIDTH-1:0] sdata_buffer_r;
    logic [BITWIDTH-1:0] rdata_buffer_r;

    // always_comb begin
    //     if_busy = if_busy_r;
    //     if (!if_busy) begin
    //         if (en_i) begin
    //             if_busy = 1'b1;
    //         end
    //     end else begin
    //         if (w_en_i && (spi_count == sdata_valid_bit_num_i)) begin
    //             if_busy = 1'b0;
    //         end else if (!r_en_i && (spi_count == rdata_valid_bit_num_i)) begin
    //             if_busy = 1'b0;
    //         end
    //     end
    // end

    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         if_busy_r <= 1'b0;
    //     end else begin
    //         if_busy_r <= if_busy;
    //     end
    // end

    //generate clk
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gen_clk_count <= '0;
        end else if (sys_en_i) begin
            if (gen_clk_count == spiclk_period_i) begin
                gen_clk_count <= '0;
            end else begin
                gen_clk_count <= gen_clk_count + (BITWIDTH)'('b1);
            end
        end
    end
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            spiclk_o <= 1'b0;
        end else if (sys_en_i) begin
            if (gen_clk_count == spiclk_period_i) begin
                gen_clk_count <= '0;
            end else begin
                gen_clk_count <= gen_clk_count + (BITWIDTH)'('b1);
            end
        end
    end    
    

endmodule

`default_nettype wire
