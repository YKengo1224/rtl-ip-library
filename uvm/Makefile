WORK_DIR = $(CURDIR)/work
LOG_DIR = $(CURDIR)/log
BIN_DIR = $(CURDIR)/bin

RUN_SIM = $(BIN_DIR)/run_sim.py
SIMULATOR := xsim
TIMESCALE = 1ns/1ps
FILELIST = $(CURDIR)/tb/filelist.f
TOP_MODULE = tb_top
ENV_LIST = $(CURDIR)/tb/env_path_list.f
TEST_CASE := test_master_standard_seq
# TEST_CASE := test_master_random_seq
# TEST_CASE := sample_seq

COV_EN ?= 1
WAVE_EN ?= 1
TIMEOUT ?=

ifeq ($(COV_EN),1)
  COV_OPT = -c
else
  COV_OPT =
endif

ifeq ($(WAVE_EN),1)
  WAVE_OPT = -w
else
  WAVE_OPT =
endif

ifneq ($(TIMEOUT),)
  TIMEOUT_OPT = --timeout $(TIMEOUT)
else
  TIMEOUT_OPT =
endif

run:
	$(RUN_SIM) -s $(SIMULATOR) --work_dir $(WORK_DIR) --log_dir $(LOG_DIR) --timescale $(TIMESCALE) $(COV_OPT) $(WAVE_OPT) $(TIMEOUT_OPT) -f $(FILELIST) -top $(TOP_MODULE) -el $(ENV_LIST) $(TEST_CASE)

run_all:
	$(RUN_SIM) -s $(SIMULATOR) --work_dir $(WORK_DIR) --log_dir $(LOG_DIR) --timescale $(TIMESCALE) $(COV_OPT) $(WAVE_OPT) $(TIMEOUT_OPT) -f $(FILELIST) -top $(TOP_MODULE) -el $(ENV_LIST) -a


clean:
	rm -rf $(WORK_DIR) $(LOG_DIR)
