-f ${UART_RTL_PATH}/filelist.f
-f ${LIB_COMMON_PATH}/filelist.f
-f ${LIB_AXI4LITE_PATH}/filelist.f
-f ${LIB_UART_BFM_PATH}/filelist.f

+incdir+${UART_SIM_PATH}/uvm
+incdir+${UART_SIM_PATH}/uvm/component
+incdir+${UART_SIM_PATH}/uvm/sequence
+incdir+${UART_SIM_PATH}/uvm/test
+incdir+${UART_SIM_PATH}/uvm/ral
+incdir+${UART_SIM_PATH}/case

${UART_SIM_PATH}/uvm/uart_val_pkg.sv
${UART_SIM_PATH}/case/case_pkg.sv
${UART_SIM_PATH}/tb/crgen_if.sv
${UART_SIM_PATH}/tb/uart_monitor_if.sv
${UART_SIM_PATH}/tb/tb_top.sv
