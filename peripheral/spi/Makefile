# ターゲットファイル（make auto FILE=hoge.sv のように外から上書き可能）
FILE ?= rtl/qspi_top.sv

# -Q (--quick) オプションで init.el などの個人設定を完全スキップ（爆速化）
# 標準搭載の verilog-mode を使うため、--load は不要
EMACS_CMD := emacs --batch -Q $(FILE)

# phonyターゲット（同名のファイルがあっても必ず実行させるおまじない）
.PHONY: auto delete inject

auto:
	@echo "🚀 Running verilog-auto on $(FILE)..."
	$(EMACS_CMD) -f verilog-batch-auto

delete:
	@echo "🧹 Deleting verilog-auto from $(FILE)..."
	$(EMACS_CMD) -f verilog-batch-delete-auto

inject:
	@echo "💉 Injecting verilog-auto into $(FILE)..."
	$(EMACS_CMD) -f verilog-batch-inject-auto

# SIM_TOOL := dsim
# #SIM_TOOL := xrun

# TB_DIR := $(CURDIR)/tb
# RTL_DIR := $(CURDIR)/rtl
# BFM_DIR := $(TB_DIR)/bfm
# SIM_DIR := $(CURDIR)/sim_dir

# TB_MODULE := tb_ahb_lite

# TB_SRC := $(TB_DIR)/$(TB_MODULE).sv
# BFM_SRC := $(wildcard $(BFM_DIR)/*.v)  $(wildcard $(BFM_DIR)/*.sv)
# RTL_SRC := $(wildcard $(RTL_DIR)/*.v) $(wildcard $(RTL_DIR)/*.sv)


# SIM_OPT := 

# ifeq ($(SIM_TOOL),dsim)
# 	SIM_OPT := -sv +acc+b -noopt -top $(TB_MODULE)  
# else
# 	SIM_OPT := hoge
# endif


# .PHONY: sim

# sim: $(SRC)
# 	mkdir -p $(SIM_DIR)	
# 	cd $(SIM_DIR) && $(SIM_TOOL) $(SIM_OPT) $(TB_SRC) $(BFM_SRC) $(RTL_SRC)  

# hoge:
# 	echo $(BFM_DIR)/*
