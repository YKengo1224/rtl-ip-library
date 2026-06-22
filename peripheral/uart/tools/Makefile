# Variables for Python and Virtual Environment
VENV         = venv
PYTHON       = $(VENV)/bin/python
PIP          = $(VENV)/bin/pip
ACTIVATE     = $(VENV)/bin/activate

# Paths for Register Map inputs and outputs
YAML         = ../doc/register_map.yaml
TEMPLATE     = ./axilite_slv_template.sv
RTL_OUT      = ../rtl/uart_axilite_slv.sv
RAL_OUT      = ../sim/uvm/ral/uart_reg_model.sv

.PHONY: all run clean venv

all: run

# Rule to initialize venv and install dependencies
venv: $(ACTIVATE)

$(ACTIVATE):
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install pyyaml
	touch $(ACTIVATE)

# Rule to run the register generator with path variables
run: $(ACTIVATE)
	$(PYTHON) gen_axilite_slv.py \
		-y $(YAML) \
		-t $(TEMPLATE) \
		-r $(RTL_OUT) \
		-l $(RAL_OUT)

# Rule to delete the virtual environment
clean:
	rm -rf $(VENV)
