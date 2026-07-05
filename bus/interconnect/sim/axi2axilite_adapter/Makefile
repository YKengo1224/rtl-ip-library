RTL_DIR = ../../rtl
SRC = $(RTL_DIR)/axi_if.sv \
      $(RTL_DIR)/axilite_if.sv \
      $(RTL_DIR)/axi2axilite_adapter.sv \
      tb_axi2axilite_adapter.sv

.PHONY: all compile elab sim clean

all: sim

compile:
	xvlog -sv $(SRC)

elab: compile
	xelab -debug typical -top tb_axi2axilite_adapter -snapshot tb_axi2axilite_adapter_snapshot -timescale 1ns/1ps

sim: elab
	xsim tb_axi2axilite_adapter_snapshot -tclbatch run.tcl

clean:
	rm -rf xsim.dir/ xvlog.log xelab.log xsim.log xvlog.pb xelab.pb xsim.pb tb_axi2axilite_adapter_snapshot.wdb xsim.jou xsim*.jou xsim*.log
