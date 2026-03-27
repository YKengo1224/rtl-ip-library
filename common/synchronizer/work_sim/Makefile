PAT := pat
TOP := sim_top
RAND_SEED := 50

RTL_DIR := ../rtl
INC_DIR := ./include
OUT_DIR := ./out
BENCH_DIR := ./bench
PAT_DIR := ./pat

RTL := $(wildcard $(RTL_DIR)/*.sv) $(wildcard $(RTL_DIR)/*.v)
SRC := $(RTL) $(wildcard $(BENCH_DIR)/*.sv) 
INC_SRC := $(wildcard $(INC_DIR)/*.svh) $(wildcard $(PAT_DIR)/*.svh) 
FILELIST := ./filelist.f
#WAVE_FILE := $(OUT_DIR)/wave.fst
WAVE_FILE := $(OUT_DIR)/wave.vcd
BIN_PATH := /home/kengo/work/build_dir/verilator
BIN := $(BIN_PATH)/bin/verilator
JOBS := 12
OPT := --binary --Wno-fatal --timing --trace --trace-fst  

OBJ := $(OUT_DIR)/V$(TOP)

OBJ_OPT := +WAVE_FILE=$(WAVE_FILE) +verilator+seed+$(RAND_SEED)

SIM := xsim

.PHONY:sim,clean

# sim:$(OBJ)
# 	$^ $(OBJ_OPT)

sim:
	./bin/runsim.py --sim $(SIM) --pat $(PAT) --wave $(WAVE_FILE)

$(OBJ):$(FILELIST) $(INC_SRC)
	export VERILATOR_ROOT=$(BIN_PATH) && $(BIN) $(OPT)  -j $(JOBS) --Mdir $(OUT_DIR)  --top sim_top +incdir+$(INC_DIR) +incdir+$(PAT_DIR) -f $(FILELIST)


$(FILELIST):$(SRC)
	@rm -f $@	
	@for file in $^; do \
		echo "$$file" >> $@; \
	done

clean:
	rm -rf $(OUT_DIR)
	rm -rf $(FILELIST)
