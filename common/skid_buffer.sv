`default_nettype none

module skid_buffer #(
    parameter int BITWIDTH = 1
) (
    input                       clk,
    input                       rst_n,
    input  wire  [BITWIDTH-1:0] i_data,
    input  wire                 i_valid,
    output logic                o_ready_r,

    output logic [BITWIDTH-1:0] o_data_r,
    output logic                o_valid_r,
    input  wire                 i_ready

);

    logic [BITWIDTH-1:0] skid_data_r;

    localparam [1:0] S_EMPTY = 2'b01;
    localparam [1:0] S_NORMAL = 2'b11;
    localparam [1:0] S_SKIDDED = 2'b10;


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            skid_data_r <= '0;
            o_data_r <= '0;
            o_valid_r <= 1'b0;
            o_ready_r <= 1'b1;
        end else begin
            case ({
                o_valid_r, o_ready_r
            })
                S_EMPTY: begin
                    if (i_valid) begin
                        o_valid_r <= 1'b1;
                        o_data_r  <= i_data;
                    end
                end
                S_NORMAL: begin
                    if (i_valid && i_ready) begin
                        o_data_r <= i_data;
                    end else if (i_valid && !i_ready) begin
                        skid_data_r <= i_data;
                        o_valid_r   <= 1'b1;
                        o_ready_r   <= 1'b0;
                    end else if (!i_valid && i_ready) begin
                        o_valid_r <= 1'b0;
                    end
                end
                S_SKIDDED: begin
                    if (i_ready) begin
                        o_data_r  <= skid_data_r;
                        o_ready_r <= 1'b1;
                    end
                end
                default: begin
                    o_data_r  <= 1'b0;
                    o_ready_r <= 1'b1;
                end
            endcase
        end
    end



endmodule

`default_nettype wire
