package qspi_axi4lite_slv_ral_pkg;
  import uvm_pkg::*;
  import rggen_ral_pkg::*;
  `include "uvm_macros.svh"
  `include "rggen_ral_macros.svh"
  class qspi_ctrl_reg_model extends rggen_ral_reg;
    rand rggen_ral_field qspi_enable;
    rand rggen_ral_field trans_dir;
    rand rggen_ral_field protocol_sel;
    rand rggen_ral_field word_width;
    rand rggen_ral_field spi_slave_en;
    rand rggen_ral_field cpha;
    rand rggen_ral_field cpol;
    rand rggen_ral_field order;
    rand rggen_ral_field rx_latch_delay;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(qspi_enable, 0, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(trans_dir, 4, 2, "RW", 0, 2'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(protocol_sel, 8, 2, "RW", 0, 2'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(word_width, 12, 4, "RW", 0, 4'h1, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(spi_slave_en, 16, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(cpha, 20, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(cpol, 21, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(order, 24, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_latch_delay, 28, 4, "RW", 0, 4'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_sw_reset_reg_model extends rggen_ral_reg;
    rand rggen_ral_field sw_rst_n;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(sw_rst_n, 0, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_cs_ctrl_reg_model extends rggen_ral_reg;
    rand rggen_ral_field cs_manual;
    rand rggen_ral_field cs_manual_en;
    rand rggen_ral_field cs_sel;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(cs_manual, 8, 1, "RW", 0, 1'h1, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(cs_manual_en, 4, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(cs_sel, 0, 2, "RW", 0, 2'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_master_clk_reg_model extends rggen_ral_reg;
    rand rggen_ral_field clk_divisor;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(clk_divisor, 0, 16, "RW", 0, 16'h0000, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_data_reg_model extends rggen_ral_reg;
    rand rggen_ral_field rx_fifo_clr;
    rand rggen_ral_field tx_fifo_clr;
    rand rggen_ral_rowo_field data;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(rx_fifo_clr, 17, 1, "WO", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_clr, 16, 1, "WO", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(data, 0, 16, "ROWO", 1, 16'h0000, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_int_reg_model extends rggen_ral_reg;
    rand rggen_ral_field rx_fifo_overflow;
    rand rggen_ral_field tx_fifo_overflow;
    rand rggen_ral_field rx_fifo_threshold;
    rand rggen_ral_field tx_fifo_threshold;
    rand rggen_ral_field rx_fifo_not_empty;
    rand rggen_ral_field tx_fifo_empty;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(rx_fifo_overflow, 20, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_overflow, 16, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_threshold, 12, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_threshold, 8, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_not_empty, 4, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_empty, 0, 1, "RW", 0, 1'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_threshold_level_reg_model extends rggen_ral_reg;
    rand rggen_ral_field rx_threshold_level;
    rand rggen_ral_field tx_threshold_level;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(rx_threshold_level, 8, 5, "RW", 0, 5'h0a, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_threshold_level, 0, 5, "RW", 0, 5'h0a, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_status_reg_model extends rggen_ral_reg;
    rand rggen_ral_field spi_busy;
    rand rggen_ral_field rx_fifo_num;
    rand rggen_ral_field rx_fifo_full;
    rand rggen_ral_field rx_fifo_empty;
    rand rggen_ral_field tx_fifo_available;
    rand rggen_ral_field tx_fifo_full;
    rand rggen_ral_field tx_fifo_empty;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(spi_busy, 24, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_num, 16, 5, "RO", 1, 5'h00, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_full, 13, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_empty, 12, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_available, 4, 5, "RO", 1, 5'h00, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_full, 1, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_empty, 0, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_int_rs_reg_model extends rggen_ral_reg;
    rand rggen_ral_field rx_fifo_overflow;
    rand rggen_ral_field tx_fifo_overflow;
    rand rggen_ral_field rx_fifo_threshold;
    rand rggen_ral_field tx_fifo_threshold;
    rand rggen_ral_field rx_fifo_not_empty;
    rand rggen_ral_field tx_fifo_empty;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(rx_fifo_overflow, 20, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_overflow, 16, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_threshold, 12, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_threshold, 8, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_not_empty, 4, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_empty, 0, 1, "RO", 1, 1'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_int_ms_reg_model extends rggen_ral_reg;
    rand rggen_ral_row1trg_field rx_fifo_overflow;
    rand rggen_ral_row1trg_field tx_fifo_overflow;
    rand rggen_ral_row1trg_field rx_fifo_threshold;
    rand rggen_ral_row1trg_field tx_fifo_threshold;
    rand rggen_ral_row1trg_field rx_fifo_not_empty;
    rand rggen_ral_row1trg_field tx_fifo_empty;
    function new(string name);
      super.new(name, 32, 0);
    endfunction
    function void build();
      `rggen_ral_create_field(rx_fifo_overflow, 20, 1, "ROW1TRG", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_overflow, 16, 1, "ROW1TRG", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_threshold, 12, 1, "ROW1TRG", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_threshold, 8, 1, "ROW1TRG", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(rx_fifo_not_empty, 4, 1, "ROW1TRG", 1, 1'h0, '{}, 1, 0, 0, "")
      `rggen_ral_create_field(tx_fifo_empty, 0, 1, "ROW1TRG", 1, 1'h0, '{}, 1, 0, 0, "")
    endfunction
  endclass
  class qspi_axi4lite_slv_block_model extends rggen_ral_block;
    rand qspi_ctrl_reg_model qspi_ctrl;
    rand qspi_sw_reset_reg_model qspi_sw_reset;
    rand qspi_cs_ctrl_reg_model qspi_cs_ctrl;
    rand qspi_master_clk_reg_model qspi_master_clk;
    rand qspi_data_reg_model qspi_data;
    rand qspi_int_reg_model qspi_int;
    rand qspi_threshold_level_reg_model qspi_threshold_level;
    rand qspi_status_reg_model qspi_status;
    rand qspi_int_rs_reg_model qspi_int_rs;
    rand qspi_int_ms_reg_model qspi_int_ms;
    function new(string name);
      super.new(name, 4, 0);
    endfunction
    function void build();
      `rggen_ral_create_reg(qspi_ctrl, '{}, '{}, 8'h00, "RW", "g_qspi_ctrl.u_register")
      `rggen_ral_create_reg(qspi_sw_reset, '{}, '{}, 8'h04, "RW", "g_qspi_sw_reset.u_register")
      `rggen_ral_create_reg(qspi_cs_ctrl, '{}, '{}, 8'h08, "RW", "g_qspi_cs_ctrl.u_register")
      `rggen_ral_create_reg(qspi_master_clk, '{}, '{}, 8'h0c, "RW", "g_qspi_master_clk.u_register")
      `rggen_ral_create_reg(qspi_data, '{}, '{}, 8'h10, "RW", "g_qspi_data.u_register")
      `rggen_ral_create_reg(qspi_int, '{}, '{}, 8'h14, "RW", "g_qspi_int.u_register")
      `rggen_ral_create_reg(qspi_threshold_level, '{}, '{}, 8'h18, "RW", "g_qspi_threshold_level.u_register")
      `rggen_ral_create_reg(qspi_status, '{}, '{}, 8'h1c, "RO", "g_qspi_status.u_register")
      `rggen_ral_create_reg(qspi_int_rs, '{}, '{}, 8'h20, "RO", "g_qspi_int_rs.u_register")
      `rggen_ral_create_reg(qspi_int_ms, '{}, '{}, 8'h24, "RW", "g_qspi_int_ms.u_register")
    endfunction
  endclass
endpackage
