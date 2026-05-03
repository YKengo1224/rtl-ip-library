WORK_DIR = $(CURDIR)/work
LOG_DIR = $(CURDIR)/log
BIN_DIR = $(CURDIR)/bin

RUN_SIM = $(BIN_DIR)/run_sim.py
TIMESCALE = 1ns/1ps
FILELIST = $(CURDIR)/tb/filelist.f
TOP_MODULE = tb_top
ENV_LIST = $(CURDIR)/tb/env_path_list.f
TEST_CASE := test_master_standard_seq

run:
	$(RUN_SIM) --work_dir $(WORK_DIR) --log_dir $(LOG_DIR) --timescale $(TIMESCALE) -c -w -f $(FILELIST) -top $(TOP_MODULE) -el $(ENV_LIST) $(TEST_CASE)   
