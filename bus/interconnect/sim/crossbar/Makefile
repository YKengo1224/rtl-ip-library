RTL_DIR = ../../rtl
SRC = $(RTL_DIR)/axi_if.sv \
      $(RTL_DIR)/axi_addr_decoder.sv \
      $(RTL_DIR)/axi_arbiter.sv \
      $(RTL_DIR)/axi_crossbar_addr.sv \
      $(RTL_DIR)/axi_crossbar.sv \
      tb_crossbar.sv

.PHONY: all compile elab sim clean

all: sim

compile:
	xvlog -sv $(SRC)

elab: compile
	xelab -debug typical -top tb_crossbar -snapshot tb_crossbar_snapshot -timescale 1ns/1ps

sim: elab
	xsim tb_crossbar_snapshot -tclbatch run.tcl

clean:
	rm -rf xsim.dir/ xvlog.log xelab.log xsim.log xvlog.pb xelab.pb xsim.pb tb_crossbar_snapshot.wdb
