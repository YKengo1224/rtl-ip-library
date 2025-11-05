SIM_TOOL := dsim
#SIM_TOOL := xrun

TB_DIR := $(CURDIR)/tb
RTL_DIR := $(CURDIR)/rtl
BFM_DIR := $(TB_DIR)/bfm
SIM_DIR := $(CURDIR)/sim_dir

TB_MODULE := tb_ahb_lite

TB_SRC := $(TB_DIR)/$(TB_MODULE).sv
BFM_SRC := $(wildcard $(BFM_DIR)/*.v)  $(wildcard $(BFM_DIR)/*.sv)
RTL_SRC := $(wildcard $(RTL_DIR)/*.v) $(wildcard $(RTL_DIR)/*.sv)


SIM_OPT := 

ifeq ($(SIM_TOOL),dsim)
	SIM_OPT := -sv +acc+b -noopt -top $(TB_MODULE)  
else
	SIM_OPT := hoge
endif


.PHONY: sim

sim: $(SRC)
	mkdir -p $(SIM_DIR)	
	cd $(SIM_DIR) && $(SIM_TOOL) $(SIM_OPT) $(TB_SRC) $(BFM_SRC) $(RTL_SRC)  

hoge:
	echo $(BFM_DIR)/*
