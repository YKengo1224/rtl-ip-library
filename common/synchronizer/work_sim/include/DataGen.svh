`ifndef _H_DATA_GEN
`define _H_DATA_GEN

typedef enum {
    MODE_RANDOM,
    MODE_CORNER
} gen_mode_e;


class DataGen #(
    parameter int BITWIDTH = 8
);

    virtual fifo_async_if                vif;

    rand bit                             r_en;
    rand bit                             w_en;
    rand bit              [BITWIDTH-1:0] wdata;

    bit                                  corner_step = 0;

    gen_mode_e                           w_en_mode   = MODE_RANDOM;
    gen_mode_e                           r_en_mode   = MODE_RANDOM;
    gen_mode_e                           wdata_mode  = MODE_RANDOM;

    constraint w_en_const {
        if (w_en_mode == MODE_CORNER) {
            w_en == 1'b1;
        } else {
            w_en dist {
                1'b1 := 50,
                1'b0 := 50
            };
        }
    }
    constraint r_en_const {
        if (r_en_mode == MODE_CORNER) {
            r_en == 1'b1;
        } else {
            r_en dist {
                1'b1 := 50,
                1'b0 := 50
            };
        }
    }

    constraint w_data_const {
        if (wdata_mode == MODE_CORNER) {
            if (corner_step == 0) {wdata == 0;} else {wdata == '1;}
        }
    }


    function new(virtual fifo_async_if vif_in);
        this.vif = vif_in;
    endfunction


    function void post_randomize();
        if (wdata_mode == MODE_CORNER) begin
            corner_step = ~corner_step;
        end
    endfunction

    task run();

        forever begin
            if (!this.randomize()) begin
                $error("Randomization failed!");
            end

            fork
                begin
                    @(posedge this.vif.WCLK);
                    this.vif.W_EN_WCLK <= this.w_en;
                    this.vif.DATA_IN_WCLK <= this.wdata;
                end
                begin
                    @(posedge this.vif.RCLK);
                    this.vif.R_EN_RCLK <= this.r_en;
                end
            join
        end

    endtask



endclass

`endif
