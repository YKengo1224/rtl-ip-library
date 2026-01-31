`default_nettype none

module pwm_apb_slv #(
    parameter int P_ADDR_BITWIDTH = 32,
    parameter int P_DATA_BITWIDTH = 32
) (
    input  wire                            PCLK,
    input  wire                            PRESETn,
    input  wire  [    P_ADDR_BITWIDTH-1:0] PADDR,
    input  wire                            PPROT,
    input  wire                            PSEL,
    input  wire                            PENABLE,
    input  wire                            PWRITE,
    input  wire  [    P_DATA_BITWIDTH-1:0] PWDATA,
    input  wire  [(P_DATA_BITWIDTH/8)-1:0] PSTRB,
    output logic                           PREADY,
    output logic                           PRDATA,
    output logic                           PSLVERR,
    //PWM Divisor Register
    output logic [                    7:0] PWM_DIV,
    //PWM0  Register
    output logic                           PWM_EN0,
    output logic                           PWM_INV0,
    output logic [                   15:0] PWM_PERIOD0,
    output logic [                   15:0] PWM_DUTY0,
    //PWM1 Register
    output logic                           PWM_EN1,
    output logic                           PWM_INV1,
    output logic [                   15:0] PWM_PERIOD1,
    output logic [                   15:0] PWM_DUTY1,
    //PWM2 Register
    output logic                           PWM_EN2,
    output logic                           PWM_INV2,
    output logic [                   15:0] PWM_PERIOD2,
    output logic [                   15:0] PWM_DUTY2,
    //PWM3 Register
    output logic                           PWM_EN3,
    output logic                           PWM_INV3,
    output logic [                   15:0] PWM_PERIOD3,
    output logic [                   15:0] PWM_DUTY3
);


    assign PREADY  = 1'b1;
    assign PSLVERR = 1'b0;




    wire  read_en;
    wire  write_en;


    //register accsecc enable    
    logic pwm_div_acc;
    logic pwm_en0_acc;
    logic pwm_en1_acc;
    logic pwm_en2_acc;
    logic pwm_en3_acc;
    logic pwm_inv0_acc;
    logic pwm_inv1_acc;
    logic pwm_inv2_acc;
    logic pwm_inv3_acc;
    logic pwm_period0_acc;
    logic pwm_period1_acc;
    logic pwm_period2_acc;
    logic pwm_period3_acc;
    logic pwm_duty0_acc;
    logic pwm_duty1_acc;
    logic pwm_duty2_acc;
    logic pwm_duty3_acc;

    // regsiter write enable
    logic pwm_div_wr;
    logic pwm_en0_wr;
    logic pwm_en1_wr;
    logic pwm_en2_wr;
    logic pwm_en3_wr;
    logic pwm_inv0_wr;
    logic pwm_inv1_wr;
    logic pwm_inv2_wr;
    logic pwm_inv3_wr;
    logic pwm_period0_wr;
    logic pwm_period1_wr;
    logic pwm_period2_wr;
    logic pwm_period3_wr;
    logic pwm_duty0_wr;
    logic pwm_duty1_wr;
    logic pwm_duty2_wr;
    logic pwm_duty3_wr;

    // register read enable
    logic pwm_div_rd;
    logic pwm_en0_rd;
    logic pwm_en1_rd;
    logic pwm_en2_rd;
    logic pwm_en3_rd;
    logic pwm_inv0_rd;
    logic pwm_inv1_rd;
    logic pwm_inv2_rd;
    logic pwm_inv3_rd;
    logic pwm_period0_rd;
    logic pwm_period1_rd;
    logic pwm_period2_rd;
    logic pwm_period3_rd;
    logic pwm_duty0_rd;
    logic pwm_duty1_rd;
    logic pwm_duty2_rd;
    logic pwm_duty3_rd;



    assign pwm_en0_acc     = (PADDR[6:0] == 7'h00);
    assign pwm_inv0_acc    = (PADDR[6:0] == 7'h04);
    assign pwm_period0_acc = (PADDR[6:0] == 7'h08);
    assign pwm_duty0_acc   = (PADDR[6:0] == 7'h10);
    assign pwm_en1_acc     = (PADDR[6:0] == 7'h14);
    assign pwm_inv1_acc    = (PADDR[6:0] == 7'h18);
    assign pwm_period1_acc = (PADDR[6:0] == 7'h1C);
    assign pwm_duty1_acc   = (PADDR[6:0] == 7'h20);
    assign pwm_en2_acc     = (PADDR[6:0] == 7'h24);
    assign pwm_inv2_acc    = (PADDR[6:0] == 7'h28);
    assign pwm_period2_acc = (PADDR[6:0] == 7'h2C);
    assign pwm_duty2_acc   = (PADDR[6:0] == 7'h30);
    assign pwm_en3_acc     = (PADDR[6:0] == 7'h34);
    assign pwm_inv3_acc    = (PADDR[6:0] == 7'h38);
    assign pwm_period3_acc = (PADDR[6:0] == 7'h3C);
    assign pwm_duty3_acc   = (PADDR[6:0] == 7'h40);

    assign pwm_en0_wr      = write_en && (PADDR[6:0] == 7'h00);
    assign pwm_inv0_wr     = write_en && (PADDR[6:0] == 7'h04);
    assign pwm_period0_wr  = write_en && (PADDR[6:0] == 7'h08);
    assign pwm_duty0_wr    = write_en && (PADDR[6:0] == 7'h10);
    assign pwm_en1_wr      = write_en && (PADDR[6:0] == 7'h14);
    assign pwm_inv1_wr     = write_en && (PADDR[6:0] == 7'h18);
    assign pwm_period1_wr  = write_en && (PADDR[6:0] == 7'h1C);
    assign pwm_duty1_wr    = write_en && (PADDR[6:0] == 7'h20);
    assign pwm_en2_wr      = write_en && (PADDR[6:0] == 7'h24);
    assign pwm_inv2_wr     = write_en && (PADDR[6:0] == 7'h28);
    assign pwm_period2_wr  = write_en && (PADDR[6:0] == 7'h2C);
    assign pwm_duty2_wr    = write_en && (PADDR[6:0] == 7'h30);
    assign pwm_en3_wr      = write_en && (PADDR[6:0] == 7'h34);
    assign pwm_inv3_wr     = write_en && (PADDR[6:0] == 7'h38);
    assign pwm_period3_wr  = write_en && (PADDR[6:0] == 7'h3C);
    assign pwm_duty3_wr    = write_en && (PADDR[6:0] == 7'h40);

    assign pwm_en0_rd      = read_en && (PADDR[6:0] == 7'h00);
    assign pwm_inv0_rd     = read_en && (PADDR[6:0] == 7'h04);
    assign pwm_period0_rd  = read_en && (PADDR[6:0] == 7'h08);
    assign pwm_duty0_rd    = read_en && (PADDR[6:0] == 7'h10);
    assign pwm_en1_rd      = read_en && (PADDR[6:0] == 7'h14);
    assign pwm_inv1_rd     = read_en && (PADDR[6:0] == 7'h18);
    assign pwm_period1_rd  = read_en && (PADDR[6:0] == 7'h1C);
    assign pwm_duty1_rd    = read_en && (PADDR[6:0] == 7'h20);
    assign pwm_en2_rd      = read_en && (PADDR[6:0] == 7'h24);
    assign pwm_inv2_rd     = read_en && (PADDR[6:0] == 7'h28);
    assign pwm_period2_rd  = read_en && (PADDR[6:0] == 7'h2C);
    assign pwm_duty2_rd    = read_en && (PADDR[6:0] == 7'h30);
    assign pwm_en3_rd      = read_en && (PADDR[6:0] == 7'h34);
    assign pwm_inv3_rd     = read_en && (PADDR[6:0] == 7'h38);
    assign pwm_period3_rd  = read_en && (PADDR[6:0] == 7'h3C);
    assign pwm_duty3_rd    = read_en && (PADDR[6:0] == 7'h40);

    assign read_en         = PSEL && PREADY && !PWRITE;
    assign write_en        = PSEL && PREADY && PWRITE && PENABLE;


    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= '0;
        end else begin
            PRDATA <=     pwm_en0_rd     ? PWM_EN0 : 
                          pwm_inv0_rd    ? PWM_INV0 : 
                          pwm_period0_rd ? PWM_PERIOD0 : 
                          pwm_duty0_rd   ? PWM_DUTY0 : 
                          pwm_en1_rd     ? PWM_EN1 : 
                          pwm_inv1_rd    ? PWM_INV1 : 
                          pwm_period1_rd ? PWM_PERIOD1 : 
                          pwm_duty1_rd   ? PWM_DUTY1 : 
                          pwm_en2_rd     ? PWM_EN2: 
                          pwm_inv2_rd    ? PWM_INV2 : 
                          pwm_period2_rd ? PWM_PERIOD2 : 
                          pwm_duty2_rd   ? PWM_DUTY2 : 
                          pwm_en3_rd     ? PWM_EN3 : 
                          pwm_inv3_rd    ? PWM_INV3 : 
                          pwm_period3_rd ? PWM_PERIOD3 : 
                          pwm_duty3_rd   ? PWM_DUTY3 : '0;
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_DIV <= '0;
            //end else if(write_en) begin
        end else if (pwm_div_wr) begin
            PWM_DIV <= PWDATA[7:0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_EN0 <= '0;
            //end else if(write_en) begin
        end else if (pwm_en0_wr) begin
            PWM_EN0 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_INV0 <= '0;
            //end else if(write_en) begin
        end else if (pwm_inv0_wr) begin
            PWM_INV0 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_PERIOD0 <= '0;
            //end else if(write_en) begin
        end else if (pwm_period0_wr) begin
            PWM_PERIOD0 <= PWDATA[15:0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_DUTY0 <= '0;
            //end else if(write_en) begin
        end else if (pwm_duty0_wr) begin
            PWM_DUTY0 <= PWDATA[15:0];
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_EN1 <= '0;
            //end else if(write_en) begin
        end else if (pwm_en1_wr) begin
            PWM_EN1 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_INV1 <= '0;
            //end else if(write_en) begin
        end else if (pwm_inv1_wr) begin
            PWM_INV1 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_PERIOD1 <= '0;
            //end else if(write_en) begin
        end else if (pwm_period1_wr) begin
            PWM_PERIOD1 <= PWDATA[15:0];
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_DUTY1 <= '0;
            //end else if(write_en) begin
        end else if (pwm_duty1_wr) begin
            PWM_DUTY1 <= PWDATA[15:0];
        end
    end

    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            pwm_en2 <= '0;
            //end else if(write_en) begin
        end else if (PWM_EN2_wr) begin
            pwm_en2 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_INV2 <= '0;
            //end else if(write_en) begin
        end else if (pwm_inv2_wr) begin
            PWM_INV2 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_PERIOD2 <= '0;
            //end else if(write_en) begin
        end else if (pwm_period2_wr) begin
            PWM_PERIOD2 <= PWDATA[15:0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_DUTY2 <= '0;
            //end else if(write_en) begin
        end else if (pwm_duty2_wr) begin
            PWM_DUTY2 <= PWDATA[15:0];
        end
    end


    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_EN3 <= '0;
        end else if (pwm_en3_wr) begin
            PWM_EN3 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_INV3 <= '0;
        end else if (pwm_inv3_wr) begin
            PWM_INV3 <= PWDATA[0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_PERIOD3 <= '0;
        end else if (pwm_period3_wr) begin
            PWM_PERIOD3 <= PWDATA[15:0];
        end
    end
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PWM_DUTY3 <= '0;
        end else if (pwm_duty3_wr) begin
            PWM_DUTY3 <= PWDATA[15:0];
        end
    end

endmodule

`default_nettype wire
