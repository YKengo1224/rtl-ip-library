class sample_seq extends tb_seq_base;
    `uvm_object_utils(sample_seq)

    function new(string name = "sample_seq");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction

    virtual task body();
        bit [63:0] rdata;

        wait (moni_vif.aresetn);
        wait (moni_vif.srstn_sysclk);

        `uvm_info("SEQ", "SEQ_START", UVM_LOW)
          
 
        write_reg(.addr(32'h0000), .id(0), .prot(0),.wstrb(4'b1111), .data(32'h0000_8001));
        write_reg(.addr(32'h0010), .id(0), .prot(0),.wstrb(4'b1111), .data(32'h0000_005A));
        write_reg(.addr(32'h0010), .id(0), .prot(0),.wstrb(4'b1111), .data(32'h0000_00AA));

        repeat(1000) @(posedge moni_vif.aclk);
       
        read_reg(.addr(32'h0000), .id(0), .prot(0), .data(rdata));
        `uvm_info("SEQ", $sformatf("rdata:%x:", rdata), UVM_LOW)
    endtask

endclass
