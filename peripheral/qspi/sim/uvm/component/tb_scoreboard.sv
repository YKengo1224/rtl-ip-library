`ifndef _H_TB_SCOREBOARD_SV
`define _H_TB_SCOREBOARD_SV

`uvm_analysis_imp_decl(_bfm_send)
`uvm_analysis_imp_decl(_bfm_rsv)
`uvm_analysis_imp_decl(_reg)

class tb_scoreboard extends uvm_scoreboard;


    uvm_analysis_imp_bfm_send #(qspi_bfm_trans, tb_scoreboard) bfm_send_imp;
    uvm_analysis_imp_bfm_rsv #(qspi_bfm_trans, tb_scoreboard) bfm_rsv_imp;
    uvm_analysis_imp_reg #(axi4lite_trans, tb_scoreboard) reg_imp;


    bit [31:0] qspi_status;

    bit [15:0] dut_sdata_queue[$];
    bit [15:0] dut_rdata_queue[$];
    bit [15:0] bfm_sdata_queue[$];
    bit [15:0] bfm_rdata_queue[$];


    `uvm_component_utils(tb_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);

    endfunction  // new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        bfm_send_imp = new("bfm_send_imp", this);
        bfm_rsv_imp = new("bfm_rsv_imp", this);
        reg_imp = new("reg_imp", this);
        qspi_status = 32'h0000_1000;
    endfunction

    function void write_reg(axi4lite_trans trans);
        bit [15:0] data;

        if ((trans.addr == 32'h00) && (trans.cmd == WRITE) && (trans.resp == 'b00)) begin
            for (int i = 0; i < (32 / 8); i++) begin
                if (trans.wstrb[i]) begin
                    qspi_status[8*i+:8] = trans.data[8*i+:8];
                end else begin
                    qspi_status[8*i+:8] = qspi_status;
                end
            end
        end
        if (trans.addr == 32'h10) begin
            if (trans.resp == 'b00) begin
                if (trans.cmd == WRITE) begin
                    if ((qspi_status[9:8] != 00) && (qspi_status[5:4] != 1)) begin
                        return;//Dua. Quad SPI && trans_dir is not transmite                       
                    end
                    for (int i = 0; i < (16 / 8); i++) begin
                        if (trans.wstrb[i]) begin
                            data[8*i+:8] = trans.data[8*i+:8];
                        end else begin
                            data[8*i+:8] = '0;
                        end
                    end
                    dut_sdata_queue.push_back(data);
                end else begin
                    dut_rdata_queue.push_back(trans.data[15:0]);
                end
            end
        end
    endfunction


    function void write_bfm_send(qspi_bfm_trans trans);
        bfm_sdata_queue.push_back(trans.data);
    endfunction

    function void write_bfm_rsv(qspi_bfm_trans trans);
        bfm_rdata_queue.push_back(trans.data);
    endfunction


    task run_phase(uvm_phase phase);
        fork
            begin
                bit [15:0] sdata;
                bit [15:0] rdata;
                forever begin
                    wait (bfm_rdata_queue.size() != 0);

                    if (dut_sdata_queue.size() == 0) begin
                        `uvm_error("SCB", $sformatf(
                                   "mismatch queue size!! dut send num:%d, bfm receive num:%d",
                                   dut_sdata_queue.size(),
                                   bfm_rdata_queue.size()
                                   ));
                    end

                    sdata = dut_sdata_queue.pop_front();
                    rdata = bfm_rdata_queue.pop_front();

                    if (sdata != rdata) begin
                        `uvm_error(
                            "SCB", $sformatf(
                            "mismatch data!! dut send data:%h, bfm receive_data:%h", sdata, rdata));
                    end else begin
                        `uvm_info("SCB", $sformatf(
                                  "OK!! dut send data:%h, bfm receive_data:%h", sdata, rdata),
                                  UVM_LOW);
                    end

                end
            end

            begin
                bit [15:0] sdata;
                bit [15:0] rdata;
                forever begin
                    wait (dut_rdata_queue.size() != 0);

                    if (bfm_sdata_queue.size() == 0) begin
                        `uvm_error("SCB", $sformatf(
                                   "mismatch queue size!! bfm send num:%d, dut receive num:%x",
                                   bfm_sdata_queue.size(),
                                   dut_rdata_queue.size()
                                   ));
                    end

                    sdata = bfm_sdata_queue.pop_front();
                    rdata = dut_rdata_queue.pop_front();

                    if (sdata != rdata) begin
                        `uvm_error(
                            "SCB", $sformatf(
                            "mismatch data!! bfm send data:%h, dut receive_data:%h", sdata, rdata));
                    end else begin
                        `uvm_info("SCB", $sformatf(
                                  "OK!! bfm send data:%h, dut receive_data:%h", sdata, rdata),
                                  UVM_LOW);
                    end
                end
            end
        join
    endtask

    // function void check_phase(uvm_phase phase);

    //     int dut_rdata_size;



    //     super.check_phase(phase);





    //     dut_rdata_size = dut_rdata_queue.size();



    //     for (int i = 0; i < dut_rdata_size; i++) begin



    //     end

    // endfunction

endclass
`endif
