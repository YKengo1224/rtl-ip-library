`ifndef _H_TB_SEQUENCE_LIST_SV
`define _H_TB_SEQUENCE_LIST_SV

package case_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import tb_pkg::*;

    class test_bram_write_read_seq extends tb_seq_base;
        `uvm_object_utils(test_bram_write_read_seq)

        function new(string name = "test_bram_write_read_seq");
            super.new(name);
        endfunction

        virtual task body();
            bit [63:0] rd_data;
            `uvm_info("SEQ", "Starting BRAM write/read sequence...", UVM_LOW)

            // Wait reset release
            wait_clk(20);

            // Test 1: Simple write and read
            `uvm_info("SEQ", "Test 1: Simple write/read...", UVM_LOW)
            write_reg(64'h0000_0000, 0, 0, 4'hF, 64'hDEAD_BEEF);
            wait_clk(5);
            read_reg(64'h0000_0000, 0, 0, rd_data);
            `uvm_info("SEQ", $sformatf("Read Back: 0x%0h", rd_data), UVM_LOW);

            write_reg(64'h0000_0004, 0, 0, 4'hF, 64'h1234_5678);
            wait_clk(5);
            read_reg(64'h0000_0004, 0, 0, rd_data);
            `uvm_info("SEQ", $sformatf("Read Back: 0x%0h", rd_data), UVM_LOW);

            // Test 2: Byte-write strobe check
            `uvm_info("SEQ", "Test 2: Byte-write strobe check...", UVM_LOW)
            write_reg(64'h0000_0000, 0, 0, 4'h9, 64'hAAAA_BBBB); // Write byte 0 and 3
            wait_clk(5);
            read_reg(64'h0000_0000, 0, 0, rd_data);
            `uvm_info("SEQ", $sformatf("Read Back (Expected 0xAAAD_BEBB): 0x%0h", rd_data), UVM_LOW);

            // Test 3: Random access
            `uvm_info("SEQ", "Test 3: Random write/read...", UVM_LOW)
            for (int i = 0; i < 20; i++) begin
                bit [9:0] rand_word = $urandom_range(0, 1023);
                bit [63:0] rand_addr = rand_word * 4;
                bit [31:0] rand_data = $urandom();
                write_reg(rand_addr, 0, 0, 4'hF, rand_data);
                wait_clk(2);
                read_reg(rand_addr, 0, 0, rd_data);
            end

            wait_clk(20);
            `uvm_info("SEQ", "BRAM write/read sequence completed.", UVM_LOW)
        endtask
    endclass
endpackage

`endif
