



task sim_run();
    int clk_param_num = 4;
    int count = 0;
    real clk_freq_MHz[];

    clk_freq_MHz = new[clk_param_num];
    clk_freq_MHz[0] = 22.5;
    clk_freq_MHz[1] = 50.0;
    clk_freq_MHz[2] = 125.0;
    clk_freq_MHz[3] = 200.0;

    $display("rst value:%d", if1.RST_N_WCLK);

    fork
        begin
            for (int i_wclk = 0; i_wclk < clk_param_num; i_wclk++) begin
                for (int i_rclk = 0; i_rclk < clk_param_num; i_rclk++) begin
                    for (int i_w_en = 0; i_w_en < 2; i_w_en++) begin
                        data_gen.w_en_mode = (i_w_en == 0) ? MODE_CORNER : MODE_RANDOM;
                        for (int i_r_en = 0; i_r_en < 2; i_r_en++) begin
                            data_gen.r_en_mode = (i_r_en == 0) ? MODE_CORNER : MODE_RANDOM;
                            for (int i_data = 0; i_data < 2; i_data++) begin
                                data_gen.wdata_mode = (i_data == 0) ? MODE_CORNER : MODE_RANDOM;

                                fork
                                    begin
                                        clk_gen.clk_gen(clk_freq_MHz[i_wclk], clk_freq_MHz[i_rclk]);
                                    end
                                    begin
                                        data_gen.run();
                                    end

                                    begin
                                        clk_gen.reset();
                                        @(posedge if1.WCLK);
                                        @(posedge if1.WCLK);
                                        @(posedge if1.WCLK);
                                        @(posedge if1.WCLK);
                                        clk_gen.unreset();
                                        #100us;
                                    end
                                join_any

                                disable fork;

                                $display("pattern_%d:finised", count);
                                count++;

                                #1;

                            end
                        end
                    end

                end
            end
        end
       begin
          checker_1.data_check();          
       end
    join_any
    $finish();

endtask
