register_block{
  name 'qspi_axi4lite_slv'
  byte_size 256

  register {
    name 'qspi_ctrl'
    offset_address 0x00
    
    bit_field {
      name 'qspi_enable'; bit_assignment lsb: 0; type  :rw; initial_value default: 0
      comment <<~'COMMENT'
      0: spi動作無効
      1: spi動作有効                                                                                               
      COMMENT
    }
    bit_field {
      name 'reserved_0'; bit_assignment lsb: 1,width: 3; type  :reserved; comment '*1'
    }

    
    bit_field {
      name 'trans_dir'
      bit_assignment lsb: 4, width: 2
      type  :rw;
      initial_value default: 0
    }
    bit_field {
      name 'reserved_1'; bit_assignment lsb: 6,width: 2; type  :reserved; comment '*1'
    }

    
    bit_field {
      name 'protocol_sel';bit_assignment lsb: 8, width: 2;type  :rw; initial_value default: 0
    }    
    bit_field {
      name 'reserved_2'; bit_assignment lsb: 10,width: 2; type  :reserved; comment '*1'
    }

    
    bit_field {
       name 'word_width'; bit_assignment lsb: 12, width: 4;type  :rw; initial_value default: 1
    }

    
    bit_field {
       name 'spi_slave_en';bit_assignment lsb: 16, width: 1; type  :rw; initial_value default: 0
    }
    bit_field {
      name 'reserved_3'; bit_assignment lsb: 17,width: 3; type  :reserved; comment '*1'
    }


    bit_field {
       name 'cpha'; bit_assignment lsb: 20, width: 1; type  :rw; initial_value default: 0
    }
    bit_field {
      name 'cpol'; bit_assignment lsb: 21, width: 1; type  :rw; initial_value default: 0
     }
    bit_field {
      name 'reserved_4'; bit_assignment lsb: 22,width: 2; type  :reserved; comment '*1'
    }

    
    bit_field {
      name 'order'; bit_assignment lsb: 24, width: 1; type  :rw; initial_value default: 0
    }
    bit_field {
      name 'reserve_5'; bit_assignment lsb: 25,width: 3; type  :reserved; comment '*1'
    }

    bit_field {
      name 'rx_latch_delay'; bit_assignment lsb: 28, width: 4; type  :rw; initial_value default: 0
     }
    
   
  }

  
  register {
    name 'qspi_sw_reset'
    offset_address 0x04

    bit_field {
      name 'reserve'; bit_assignment lsb: 1,width: 31; type  :reserved; comment '*1'
    }
    bit_field {
      name 'sw_rst_n'; bit_assignment lsb: 0, width: 1; type  :rw; initial_value default: 0
    }    
  }

  register {
    name 'qspi_cs_ctrl'
    offset_address 0x08

    bit_field {
      name 'reserve_2'; bit_assignment lsb: 9,width: 23; type  :reserved; comment '*1'
    }
    bit_field {
      name 'cs_manual'; bit_assignment lsb: 8, width: 1; type :rw; initial_value default: 1
    }

    bit_field {
      name 'reserve_1'; bit_assignment lsb: 5,width: 2; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'cs_manual_en'; bit_assignment lsb: 4, width: 1; type :rw; initial_value default: 0
    }


    bit_field {
      name 'reserve_0'; bit_assignment lsb: 2,width: 2; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'cs_sel'; bit_assignment lsb: 0, width: 2; type :rw; initial_value default: 0
    }
  }


  register{
    name 'qspi_master_clk'
    offset_address 0x0C

    bit_field {
      name 'reserve'; bit_assignment lsb: 16,width: 16; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'clk_divisor'; bit_assignment lsb: 0, width: 16; type :rw; initial_value default: 0
    }
  } 
  

  register{
    name 'qspi_data'
    offset_address 0x10

    bit_field {
      name 'reserve'; bit_assignment lsb: 18,width: 14; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_clr'; bit_assignment lsb: 17, width: 1; type :wotrg; initial_value default: 0
    }    
    bit_field {      
      name 'tx_fifo_clr'; bit_assignment lsb: 16, width: 1; type :wotrg; initial_value default: 0
    }
    bit_field {      
      name 'data'; bit_assignment lsb: 0, width: 16; type :rowotrg; initial_value default: 0
    }
  }


  register{
    name 'qspi_int'
    offset_address 0x14
    

    bit_field {
      name 'reserve_6'; bit_assignment lsb: 21,width: 11; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_overflow'; bit_assignment lsb: 20, width: 1; type :rw; initial_value default: 0
    }

    
    bit_field {
      name 'reserve_5'; bit_assignment lsb:17 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_overflow'; bit_assignment lsb: 16, width: 1; type :rw; initial_value default: 0
    }

    bit_field {
      name 'reserve_4'; bit_assignment lsb:13 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_threshold'; bit_assignment lsb: 12, width: 1; type :rw; initial_value default: 0
    }

    bit_field {
      name 'reserve_3'; bit_assignment lsb:9 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_threshold'; bit_assignment lsb: 8, width: 1; type :rw; initial_value default: 0
    }

    
    bit_field {
      name 'reserve_2'; bit_assignment lsb: 5,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_not_empty'; bit_assignment lsb: 4, width: 1; type :rw; initial_value default: 0
    }

    
    bit_field {
      name 'reserve_1'; bit_assignment lsb:1 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_empty'; bit_assignment lsb: 0, width: 1; type :rw; initial_value default: 0
    }
  }

  register{
    name 'qspi_threshold_level'
    offset_address 0x18

    bit_field {
      name 'reserve_1'; bit_assignment lsb: 13,width: 19; type  :reserved; comment '*1'
    }    
    bit_field {      
      name 'rx_threshold_level'; bit_assignment lsb: 8, width: 5; type :rw; initial_value default: 0
    }
    

    bit_field {
      name 'reserve_0'; bit_assignment lsb: 5,width: 2; type  :reserved; comment '*1'
    }    
    bit_field {      
      name 'tx_threshold_level'; bit_assignment lsb: 0, width: 5; type :rw; initial_value default: 0
    }

  }


  

  register{
    name 'qspi_status'
    offset_address 0x1c


    bit_field {
      name 'reserve_5'; bit_assignment lsb: 25,width: 7; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'spi_busy'; bit_assignment lsb: 24, width: 1; type :ro; initial_value default: 0
    }
    
    bit_field {
      name 'reserve_4'; bit_assignment lsb: 21,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_num'; bit_assignment lsb: 16, width: 5; type :ro; initial_value default: 0
    }    
    bit_field {
      name 'reserve_3'; bit_assignment lsb: 14,width: 2; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_full'; bit_assignment lsb: 13, width: 1; type :ro; initial_value default: 0
    }
    bit_field {      
      name 'rx_fifo_empty'; bit_assignment lsb: 12, width: 1; type :ro; initial_value default: 0
    }

        
    bit_field {
      name 'reserve_1'; bit_assignment lsb: 9,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_available'; bit_assignment lsb: 4, width: 5; type :ro; initial_value default: 0
    }    
    bit_field {
      name 'reserve_0'; bit_assignment lsb: 2,width: 2; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_full'; bit_assignment lsb: 1, width: 1; type :ro; initial_value default: 0
    }
    bit_field {      
      name 'tx_fifo_empty'; bit_assignment lsb: 0, width: 1; type :ro; initial_value default: 0
    }

  }

  

  register{
    name 'qspi_int_rs'
    offset_address 0x20
    

    bit_field {
      name 'reserve_6'; bit_assignment lsb: 21,width: 11; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_overflow'; bit_assignment lsb: 20, width: 1; type :ro;  initial_value default: 0
    }
    
    bit_field {
      name 'reserve_5'; bit_assignment lsb:17 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_overflow'; bit_assignment lsb: 16, width: 1; type :ro;  initial_value default: 0
    }

    bit_field {
      name 'reserve_4'; bit_assignment lsb:13 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_threshold'; bit_assignment lsb: 12, width: 1; type :ro;  initial_value default: 0
    }

    bit_field {
      name 'reserve_3'; bit_assignment lsb:9 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_threshold'; bit_assignment lsb: 8, width: 1; type :ro;  initial_value default: 0
    }

    
    bit_field {
      name 'reserve_2'; bit_assignment lsb: 5,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_not_empty'; bit_assignment lsb: 4, width: 1; type :ro;  initial_value default: 0
    }

    
    bit_field {
      name 'reserve_1'; bit_assignment lsb:1 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_empty'; bit_assignment lsb: 0, width: 1; type :ro;   initial_value default: 0
    }
  }



  register{
    name 'qspi_int_ms'
    offset_address 0x24
    

    bit_field {
      name 'reserve_6'; bit_assignment lsb: 21,width: 11; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_overflow'; bit_assignment lsb: 20, width: 1; type :row1trg;  initial_value default: 0
    }
    
    bit_field {
      name 'reserve_5'; bit_assignment lsb:17 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_overflow'; bit_assignment lsb: 16, width: 1; type :row1trg;  initial_value default: 0
    }

    bit_field {
      name 'reserve_4'; bit_assignment lsb:13 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_threshold'; bit_assignment lsb: 12, width: 1; type :row1trg;  initial_value default: 0
    }

    bit_field {
      name 'reserve_3'; bit_assignment lsb:9 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_threshold'; bit_assignment lsb: 8, width: 1; type :row1trg;  initial_value default: 0
    }

    
    bit_field {
      name 'reserve_2'; bit_assignment lsb: 5,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'rx_fifo_not_empty'; bit_assignment lsb: 4, width: 1; type :row1trg;  initial_value default: 0
    }

    
    bit_field {
      name 'reserve_1'; bit_assignment lsb:1 ,width: 3; type  :reserved; comment '*1'
    }
    bit_field {      
      name 'tx_fifo_empty'; bit_assignment lsb: 0, width: 1; type :row1trg;   initial_value default: 0
    }
  }
  

  
}



    # bit_field {
    #   name ''
    #   bit_assignment lsb: 8, width: 2
    #   type  :rw;
    #   initial_value default: 0
    # }
