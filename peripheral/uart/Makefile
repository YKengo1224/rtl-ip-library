# ターゲットファイル（make auto FILE=hoge.sv のように外から上書き可能）
FILE ?= rtl/uart_top.sv

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

