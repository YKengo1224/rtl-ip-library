`ifndef _H_UART_REG_BLOCK_SV
`define _H_UART_REG_BLOCK_SV

//=============================================================================
// Register Definitions
//=============================================================================
class reg_uart_ctrl extends uvm_reg;
    `uvm_object_utils(reg_uart_ctrl)

    rand uvm_reg_field break_send;
    rand uvm_reg_field uart_enable;

    function new(string name = "reg_uart_ctrl");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        break_send = uvm_reg_field::type_id::create("break_send");
        uart_enable = uvm_reg_field::type_id::create("uart_enable");

        break_send.configure(
            .parent(this),
            .size(1),
            .lsb_pos(4),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        uart_enable.configure(
            .parent(this),
            .size(1),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_conf_frame extends uvm_reg;
    `uvm_object_utils(reg_uart_conf_frame)

    rand uvm_reg_field conf_data_bit_width;
    rand uvm_reg_field conf_stop_bit_width_sel;
    rand uvm_reg_field conf_parity_bit;

    function new(string name = "reg_uart_conf_frame");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        conf_data_bit_width = uvm_reg_field::type_id::create("conf_data_bit_width");
        conf_stop_bit_width_sel = uvm_reg_field::type_id::create("conf_stop_bit_width_sel");
        conf_parity_bit = uvm_reg_field::type_id::create("conf_parity_bit");

        conf_data_bit_width.configure(
            .parent(this),
            .size(4),
            .lsb_pos(8),
            .access("RW"),
            .volatile(0),
            .reset(32'h8),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        conf_stop_bit_width_sel.configure(
            .parent(this),
            .size(2),
            .lsb_pos(4),
            .access("RW"),
            .volatile(0),
            .reset(32'h1),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        conf_parity_bit.configure(
            .parent(this),
            .size(2),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_conf_mode extends uvm_reg;
    `uvm_object_utils(reg_uart_conf_mode)

    rand uvm_reg_field conf_tx_inv;
    rand uvm_reg_field conf_rx_inv;
    rand uvm_reg_field conf_hw_flow_en;

    function new(string name = "reg_uart_conf_mode");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        conf_tx_inv = uvm_reg_field::type_id::create("conf_tx_inv");
        conf_rx_inv = uvm_reg_field::type_id::create("conf_rx_inv");
        conf_hw_flow_en = uvm_reg_field::type_id::create("conf_hw_flow_en");

        conf_tx_inv.configure(
            .parent(this),
            .size(1),
            .lsb_pos(5),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        conf_rx_inv.configure(
            .parent(this),
            .size(1),
            .lsb_pos(4),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        conf_hw_flow_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_conf_samp extends uvm_reg;
    `uvm_object_utils(reg_uart_conf_samp)

    rand uvm_reg_field conf_samp_num_sel;
    rand uvm_reg_field conf_over_samp_sel;
    rand uvm_reg_field conf_clk_div;

    function new(string name = "reg_uart_conf_samp");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        conf_samp_num_sel = uvm_reg_field::type_id::create("conf_samp_num_sel");
        conf_over_samp_sel = uvm_reg_field::type_id::create("conf_over_samp_sel");
        conf_clk_div = uvm_reg_field::type_id::create("conf_clk_div");

        conf_samp_num_sel.configure(
            .parent(this),
            .size(1),
            .lsb_pos(20),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        conf_over_samp_sel.configure(
            .parent(this),
            .size(2),
            .lsb_pos(16),
            .access("RW"),
            .volatile(0),
            .reset(32'h1),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        conf_clk_div.configure(
            .parent(this),
            .size(16),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_data extends uvm_reg;
    `uvm_object_utils(reg_uart_data)

    rand uvm_reg_field uart_data;

    function new(string name = "reg_uart_data");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        uart_data = uvm_reg_field::type_id::create("uart_data");

        uart_data.configure(
            .parent(this),
            .size(9),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_status extends uvm_reg;
    `uvm_object_utils(reg_uart_status)

    rand uvm_reg_field break_det;
    rand uvm_reg_field rx_busy;
    rand uvm_reg_field tx_busy;
    rand uvm_reg_field rx_fifo_full;
    rand uvm_reg_field rx_fifo_empty;
    rand uvm_reg_field tx_fifo_full;
    rand uvm_reg_field tx_fifo_empty;

    function new(string name = "reg_uart_status");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        break_det = uvm_reg_field::type_id::create("break_det");
        rx_busy = uvm_reg_field::type_id::create("rx_busy");
        tx_busy = uvm_reg_field::type_id::create("tx_busy");
        rx_fifo_full = uvm_reg_field::type_id::create("rx_fifo_full");
        rx_fifo_empty = uvm_reg_field::type_id::create("rx_fifo_empty");
        tx_fifo_full = uvm_reg_field::type_id::create("tx_fifo_full");
        tx_fifo_empty = uvm_reg_field::type_id::create("tx_fifo_empty");

        break_det.configure(
            .parent(this),
            .size(1),
            .lsb_pos(16),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        rx_busy.configure(
            .parent(this),
            .size(1),
            .lsb_pos(12),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        tx_busy.configure(
            .parent(this),
            .size(1),
            .lsb_pos(8),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        rx_fifo_full.configure(
            .parent(this),
            .size(1),
            .lsb_pos(5),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        rx_fifo_empty.configure(
            .parent(this),
            .size(1),
            .lsb_pos(4),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        tx_fifo_full.configure(
            .parent(this),
            .size(1),
            .lsb_pos(1),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        tx_fifo_empty.configure(
            .parent(this),
            .size(1),
            .lsb_pos(0),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_int_ctrl extends uvm_reg;
    `uvm_object_utils(reg_uart_int_ctrl)

    rand uvm_reg_field int_break_det_en;
    rand uvm_reg_field int_parity_err_en;
    rand uvm_reg_field int_framing_err_en;
    rand uvm_reg_field int_rx_timeout_en;
    rand uvm_reg_field int_overrun_err_en;
    rand uvm_reg_field int_tx_fifo_th_en;
    rand uvm_reg_field int_rx_fifo_th_en;

    function new(string name = "reg_uart_int_ctrl");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        int_break_det_en = uvm_reg_field::type_id::create("int_break_det_en");
        int_parity_err_en = uvm_reg_field::type_id::create("int_parity_err_en");
        int_framing_err_en = uvm_reg_field::type_id::create("int_framing_err_en");
        int_rx_timeout_en = uvm_reg_field::type_id::create("int_rx_timeout_en");
        int_overrun_err_en = uvm_reg_field::type_id::create("int_overrun_err_en");
        int_tx_fifo_th_en = uvm_reg_field::type_id::create("int_tx_fifo_th_en");
        int_rx_fifo_th_en = uvm_reg_field::type_id::create("int_rx_fifo_th_en");

        int_break_det_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(24),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_parity_err_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(20),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_framing_err_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(16),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_rx_timeout_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(12),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_overrun_err_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(8),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_tx_fifo_th_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(4),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_rx_fifo_th_en.configure(
            .parent(this),
            .size(1),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_int_conf_th extends uvm_reg;
    `uvm_object_utils(reg_uart_int_conf_th)

    rand uvm_reg_field rx_fifo_th_level;
    rand uvm_reg_field tx_fifo_th_level;

    function new(string name = "reg_uart_int_conf_th");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        rx_fifo_th_level = uvm_reg_field::type_id::create("rx_fifo_th_level");
        tx_fifo_th_level = uvm_reg_field::type_id::create("tx_fifo_th_level");

        rx_fifo_th_level.configure(
            .parent(this),
            .size(5),
            .lsb_pos(8),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        tx_fifo_th_level.configure(
            .parent(this),
            .size(5),
            .lsb_pos(0),
            .access("RW"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_int_rs extends uvm_reg;
    `uvm_object_utils(reg_uart_int_rs)

    rand uvm_reg_field int_break_det_raw;
    rand uvm_reg_field int_parity_err_raw;
    rand uvm_reg_field int_framing_err_raw;
    rand uvm_reg_field int_rx_timeout_raw;
    rand uvm_reg_field int_overrun_err_raw;
    rand uvm_reg_field int_tx_fifo_th_raw;
    rand uvm_reg_field int_rx_fifo_th_raw;

    function new(string name = "reg_uart_int_rs");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        int_break_det_raw = uvm_reg_field::type_id::create("int_break_det_raw");
        int_parity_err_raw = uvm_reg_field::type_id::create("int_parity_err_raw");
        int_framing_err_raw = uvm_reg_field::type_id::create("int_framing_err_raw");
        int_rx_timeout_raw = uvm_reg_field::type_id::create("int_rx_timeout_raw");
        int_overrun_err_raw = uvm_reg_field::type_id::create("int_overrun_err_raw");
        int_tx_fifo_th_raw = uvm_reg_field::type_id::create("int_tx_fifo_th_raw");
        int_rx_fifo_th_raw = uvm_reg_field::type_id::create("int_rx_fifo_th_raw");

        int_break_det_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(24),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_parity_err_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(20),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_framing_err_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(16),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_rx_timeout_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(12),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_overrun_err_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(8),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_tx_fifo_th_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(4),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );

        int_rx_fifo_th_raw.configure(
            .parent(this),
            .size(1),
            .lsb_pos(0),
            .access("W1C"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(1),
            .individually_accessible(1)
        );
    endfunction
endclass

class reg_uart_int_ms extends uvm_reg;
    `uvm_object_utils(reg_uart_int_ms)

    rand uvm_reg_field int_break_det_masked;
    rand uvm_reg_field int_parity_err_masked;
    rand uvm_reg_field int_framing_err_masked;
    rand uvm_reg_field int_rx_timeout_masked;
    rand uvm_reg_field int_overrun_err_masked;
    rand uvm_reg_field int_tx_fifo_th_masked;
    rand uvm_reg_field int_rx_fifo_th_masked;

    function new(string name = "reg_uart_int_ms");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        int_break_det_masked = uvm_reg_field::type_id::create("int_break_det_masked");
        int_parity_err_masked = uvm_reg_field::type_id::create("int_parity_err_masked");
        int_framing_err_masked = uvm_reg_field::type_id::create("int_framing_err_masked");
        int_rx_timeout_masked = uvm_reg_field::type_id::create("int_rx_timeout_masked");
        int_overrun_err_masked = uvm_reg_field::type_id::create("int_overrun_err_masked");
        int_tx_fifo_th_masked = uvm_reg_field::type_id::create("int_tx_fifo_th_masked");
        int_rx_fifo_th_masked = uvm_reg_field::type_id::create("int_rx_fifo_th_masked");

        int_break_det_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(24),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        int_parity_err_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(20),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        int_framing_err_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(16),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        int_rx_timeout_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(12),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        int_overrun_err_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(8),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        int_tx_fifo_th_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(4),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );

        int_rx_fifo_th_masked.configure(
            .parent(this),
            .size(1),
            .lsb_pos(0),
            .access("RO"),
            .volatile(0),
            .reset(32'h0),
            .has_reset(1),
            .is_rand(0),
            .individually_accessible(1)
        );
    endfunction
endclass


//=============================================================================
// Register Block Definition
//=============================================================================
class uart_reg_block extends uvm_reg_block;
    `uvm_object_utils(uart_reg_block)

    rand reg_uart_ctrl uart_ctrl;
    rand reg_uart_conf_frame uart_conf_frame;
    rand reg_uart_conf_mode uart_conf_mode;
    rand reg_uart_conf_samp uart_conf_samp;
    rand reg_uart_data uart_data;
    rand reg_uart_status uart_status;
    rand reg_uart_int_ctrl uart_int_ctrl;
    rand reg_uart_int_conf_th uart_int_conf_th;
    rand reg_uart_int_rs uart_int_rs;
    rand reg_uart_int_ms uart_int_ms;

    uvm_reg_map default_map;

    function new(string name = "uart_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);

        uart_ctrl = reg_uart_ctrl::type_id::create("uart_ctrl");
        uart_ctrl.configure(this);
        uart_ctrl.build();
        default_map.add_reg(uart_ctrl, 8'h00, "RW");

        uart_conf_frame = reg_uart_conf_frame::type_id::create("uart_conf_frame");
        uart_conf_frame.configure(this);
        uart_conf_frame.build();
        default_map.add_reg(uart_conf_frame, 8'h04, "RW");

        uart_conf_mode = reg_uart_conf_mode::type_id::create("uart_conf_mode");
        uart_conf_mode.configure(this);
        uart_conf_mode.build();
        default_map.add_reg(uart_conf_mode, 8'h08, "RW");

        uart_conf_samp = reg_uart_conf_samp::type_id::create("uart_conf_samp");
        uart_conf_samp.configure(this);
        uart_conf_samp.build();
        default_map.add_reg(uart_conf_samp, 8'h0c, "RW");

        uart_data = reg_uart_data::type_id::create("uart_data");
        uart_data.configure(this);
        uart_data.build();
        default_map.add_reg(uart_data, 8'h10, "RW");

        uart_status = reg_uart_status::type_id::create("uart_status");
        uart_status.configure(this);
        uart_status.build();
        default_map.add_reg(uart_status, 8'h14, "RW");

        uart_int_ctrl = reg_uart_int_ctrl::type_id::create("uart_int_ctrl");
        uart_int_ctrl.configure(this);
        uart_int_ctrl.build();
        default_map.add_reg(uart_int_ctrl, 8'h18, "RW");

        uart_int_conf_th = reg_uart_int_conf_th::type_id::create("uart_int_conf_th");
        uart_int_conf_th.configure(this);
        uart_int_conf_th.build();
        default_map.add_reg(uart_int_conf_th, 8'h20, "RW");

        uart_int_rs = reg_uart_int_rs::type_id::create("uart_int_rs");
        uart_int_rs.configure(this);
        uart_int_rs.build();
        default_map.add_reg(uart_int_rs, 8'h24, "RW");

        uart_int_ms = reg_uart_int_ms::type_id::create("uart_int_ms");
        uart_int_ms.configure(this);
        uart_int_ms.build();
        default_map.add_reg(uart_int_ms, 8'h28, "RW");

        lock_model();
    endfunction
endclass


`endif
