`default_nettype none
module axi_master #(
    parameter int P_A_BITWIDTH = 32,
    parameter int P_D_BITWIDTH = 32,
    parameter int P_S_BITWIDTH = P_D_BITWIDTH / 8
) (
           axi_if.master                    axi_if,
    //write transaction
    input  wire                             W_REQ_I,
    input  wire          [P_A_BITWIDTH-1:0] W_ADDR_I,
    input  wire          [             7:0] W_LEN_I,
    input  wire          [             2:0] W_SIZE_I,
    input  wire          [P_D_BITWIDTH-1:0] W_DATA_I,
    input  wire                             W_VALID_I,
    output logic                            W_READY_O,
    input  wire                             W_LAST_I,
    output logic                            W_DONE_O,
    output logic         [             1:0] W_RESP_O,
    //read transaction
    input  wire                             R_REQ_I,
    input  wire          [P_A_BITWIDTH-1:0] R_ADDR_I,
    input  wire                             R_LEN_I,
    input  wire                             R_SIZE_I,
    output logic         [P_D_BITWIDTH-1:0] R_DATA_O,
    output logic                            R_VALID_O,
    output logic         [P_S_BITWIDTH-1:0] R_STRB_O,
    input  wire                             R_READY_I,
    output logic                            R_LAST_O,
    output logic                            R_DONE_O,
    output logic                            R_RESP_O
);


    typedef enum logic [1:0] {
        AW_IDLE,
        AW_TRANS
    } AwState_t;

    typedef enum logic [1:0] {
        W_IDLE,
        W_TRANS,
        W_TRANS_LAST
    } WState_t;
    typedef enum logic [1:0] {
        B_IDLE,
        B_TRANS
    } BState_t;

   typedef enum logic [1:0] {
       READ_IDLE,
       READ_TRANS
   } ReadState_t

    typedef enum logic [1:0] {
        AR_IDLE,
        AR_TRANS
    } ArState_t;
    typedef enum logic [1:0] {
        R_IDLE,
        R_TRANS,
        R_TRANS_LAST
    } RState_t;


    AwState_t aw_state_next;
    AwState_t aw_state;

    WState_t w_state_next;
    WState_t w_state;

    BState_t b_state_next;
    BState_t b_state;

    ReadState_t read_state_next;
    ReadState_t read_state;   
    
    ArState_t ar_state_next;
    ArState_t ar_state;

    RState_t r_state_next;
    RState_t r_state;


    logic [7:0] w_trans_num_r;
    logic [7:0] r_trans_num_r;


    //=================================
    //state
    //=================================


   
endmodule

`default_nettype wire
