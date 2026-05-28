## qspi_axi4lite_slv

* byte_size
    * 256
* bus_width
    * 32

|name|offset_address|
|:--|:--|
|[qspi_ctrl](#qspi_axi4lite_slv-qspi_ctrl)|0x00|
|[qspi_sw_reset](#qspi_axi4lite_slv-qspi_sw_reset)|0x04|
|[qspi_cs_ctrl](#qspi_axi4lite_slv-qspi_cs_ctrl)|0x08|
|[qspi_master_clk](#qspi_axi4lite_slv-qspi_master_clk)|0x0c|
|[qspi_data](#qspi_axi4lite_slv-qspi_data)|0x10|
|[qspi_int](#qspi_axi4lite_slv-qspi_int)|0x14|
|[qspi_threshold_level](#qspi_axi4lite_slv-qspi_threshold_level)|0x18|
|[qspi_status](#qspi_axi4lite_slv-qspi_status)|0x1c|
|[qspi_int_rs](#qspi_axi4lite_slv-qspi_int_rs)|0x20|
|[qspi_int_ms](#qspi_axi4lite_slv-qspi_int_ms)|0x24|

### <div id="qspi_axi4lite_slv-qspi_ctrl"></div>qspi_ctrl

* offset_address
    * 0x00
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|qspi_enable|[0]|rw|default: 0x0|||0: spi動作無効<br>1: spi動作有効|
|reserved_0|[3:1]|reserved||||*1|
|trans_dir|[5:4]|rw|default: 0x0||||
|reserved_1|[7:6]|reserved||||*1|
|protocol_sel|[9:8]|rw|default: 0x0||||
|reserved_2|[11:10]|reserved||||*1|
|word_width|[15:12]|rw|default: 0x1||||
|spi_slave_en|[16]|rw|default: 0x0||||
|reserved_3|[19:17]|reserved||||*1|
|cpha|[20]|rw|default: 0x0||||
|cpol|[21]|rw|default: 0x0||||
|reserved_4|[23:22]|reserved||||*1|
|order|[24]|rw|default: 0x0||||
|reserve_5|[27:25]|reserved||||*1|
|rx_latch_delay|[31:28]|rw|default: 0x0||||

### <div id="qspi_axi4lite_slv-qspi_sw_reset"></div>qspi_sw_reset

* offset_address
    * 0x04
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve|[31:1]|reserved||||*1|
|sw_rst_n|[0]|rw|default: 0x0||||

### <div id="qspi_axi4lite_slv-qspi_cs_ctrl"></div>qspi_cs_ctrl

* offset_address
    * 0x08
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve_2|[31:9]|reserved||||*1|
|cs_manual|[8]|rw|default: 0x1||||
|reserve_1|[6:5]|reserved||||*1|
|cs_manual_en|[4]|rw|default: 0x0||||
|reserve_0|[3:2]|reserved||||*1|
|cs_sel|[1:0]|rw|default: 0x0||||

### <div id="qspi_axi4lite_slv-qspi_master_clk"></div>qspi_master_clk

* offset_address
    * 0x0c
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve|[31:16]|reserved||||*1|
|clk_divisor|[15:0]|rw|default: 0x0000||||

### <div id="qspi_axi4lite_slv-qspi_data"></div>qspi_data

* offset_address
    * 0x10
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve|[31:18]|reserved||||*1|
|rx_fifo_clr|[17]|wotrg|default: 0x0||||
|tx_fifo_clr|[16]|wotrg|default: 0x0||||
|data|[15:0]|rowotrg|default: 0x0000||||

### <div id="qspi_axi4lite_slv-qspi_int"></div>qspi_int

* offset_address
    * 0x14
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve_6|[31:21]|reserved||||*1|
|rx_fifo_overflow|[20]|rw|default: 0x0||||
|reserve_5|[19:17]|reserved||||*1|
|tx_fifo_overflow|[16]|rw|default: 0x0||||
|reserve_4|[15:13]|reserved||||*1|
|rx_fifo_threshold|[12]|rw|default: 0x0||||
|reserve_3|[11:9]|reserved||||*1|
|tx_fifo_threshold|[8]|rw|default: 0x0||||
|reserve_2|[7:5]|reserved||||*1|
|rx_fifo_not_empty|[4]|rw|default: 0x0||||
|reserve_1|[3:1]|reserved||||*1|
|tx_fifo_empty|[0]|rw|default: 0x0||||

### <div id="qspi_axi4lite_slv-qspi_threshold_level"></div>qspi_threshold_level

* offset_address
    * 0x18
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve_1|[31:13]|reserved||||*1|
|rx_threshold_level|[12:8]|rw|default: 0x00||||
|reserve_0|[6:5]|reserved||||*1|
|tx_threshold_level|[4:0]|rw|default: 0x00||||

### <div id="qspi_axi4lite_slv-qspi_status"></div>qspi_status

* offset_address
    * 0x1c
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve_5|[31:25]|reserved||||*1|
|spi_busy|[24]|ro|default: 0x0||||
|reserve_4|[23:21]|reserved||||*1|
|rx_fifo_num|[20:16]|ro|default: 0x00||||
|reserve_3|[15:14]|reserved||||*1|
|rx_fifo_full|[13]|ro|default: 0x0||||
|rx_fifo_empty|[12]|ro|default: 0x0||||
|reserve_1|[11:9]|reserved||||*1|
|tx_fifo_available|[8:4]|ro|default: 0x00||||
|reserve_0|[3:2]|reserved||||*1|
|tx_fifo_full|[1]|ro|default: 0x0||||
|tx_fifo_empty|[0]|ro|default: 0x0||||

### <div id="qspi_axi4lite_slv-qspi_int_rs"></div>qspi_int_rs

* offset_address
    * 0x20
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve_6|[31:21]|reserved||||*1|
|rx_fifo_overflow|[20]|ro|default: 0x0||||
|reserve_5|[19:17]|reserved||||*1|
|tx_fifo_overflow|[16]|ro|default: 0x0||||
|reserve_4|[15:13]|reserved||||*1|
|rx_fifo_threshold|[12]|ro|default: 0x0||||
|reserve_3|[11:9]|reserved||||*1|
|tx_fifo_threshold|[8]|ro|default: 0x0||||
|reserve_2|[7:5]|reserved||||*1|
|rx_fifo_not_empty|[4]|ro|default: 0x0||||
|reserve_1|[3:1]|reserved||||*1|
|tx_fifo_empty|[0]|ro|default: 0x0||||

### <div id="qspi_axi4lite_slv-qspi_int_ms"></div>qspi_int_ms

* offset_address
    * 0x24
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|reserve_6|[31:21]|reserved||||*1|
|rx_fifo_overflow|[20]|row1trg|default: 0x0||||
|reserve_5|[19:17]|reserved||||*1|
|tx_fifo_overflow|[16]|row1trg|default: 0x0||||
|reserve_4|[15:13]|reserved||||*1|
|rx_fifo_threshold|[12]|row1trg|default: 0x0||||
|reserve_3|[11:9]|reserved||||*1|
|tx_fifo_threshold|[8]|row1trg|default: 0x0||||
|reserve_2|[7:5]|reserved||||*1|
|rx_fifo_not_empty|[4]|row1trg|default: 0x0||||
|reserve_1|[3:1]|reserved||||*1|
|tx_fifo_empty|[0]|row1trg|default: 0x0||||
