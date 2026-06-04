RTL_PATH = $(HOME)/work/personal/RTL/rtl-ip-library/peripheral/spi/rtl
RGGEN_SV_RTL_ROOT = $(RTL_PATH)/regfile_rggen/rggen-sv-rtl
FILELIST_PATH = $(RTL_PATH)/filelist.f

# 2. -e オプションでコンテナに注入
DOCKER_RUN = docker run --rm -i \
	--user $(shell id -u):$(shell id -g) \
	-e RTL_PATH=$(RTL_PATH) \
	-e RGGEN_SV_RTL_ROOT=$(RGGEN_SV_RTL_ROOT) \
	-e FILELIST_PATH=$(FILELIST_PATH) \
	-v /home:/home \
	-v /tmp:/tmp \
	-w $(CURDIR) \
	fpga_oss_env


docker_run:
	$(DOCKER_RUN)

synth:
	$(DOCKER_RUN) yosys -s syn.sys
