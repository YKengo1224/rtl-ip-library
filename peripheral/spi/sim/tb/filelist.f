
-f ${RTL_PATH}/filelist.f
-f ${LIB_AXI4LITE_PATH}/filelist.f
-f ${LIB_QSPI_BFM_PATH}/filelist.f      
+incdir+${SIM_HOME_PATH}/uvm/component
+incdir+${SIM_HOME_PATH}/uvm/sequence      
+incdir+${SIM_HOME_PATH}/uvm/test
+incdir+${SIM_HOME_PATH}/case


${SIM_HOME_PATH}/tb/monitor_if.sv      
${SIM_HOME_PATH}/uvm/base_pkg.sv
${SIM_HOME_PATH}/case/case_pkg.sv
${SIM_HOME_PATH}/tb/io.sv      
${SIM_HOME_PATH}/tb/bfm_connect.sv
${SIM_HOME_PATH}/tb/tb_top.sv
