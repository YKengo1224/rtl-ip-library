FILENAME := ./rtl/pwm.sv
EL_FILE  := ./verilog-mode/e/verilog-mode.el
CMD      := emacs --batch --quick  $(FILENAME) 

auto   : $(FILENAME)
	$(CMD) -f verilog-batch-auto
delete : $(FILENAME)
	$(CMD) -f verilog-batch-delete-auto
inject : $(FILENAME)
	$(CMD) -f verilog-batch-inject-auto
