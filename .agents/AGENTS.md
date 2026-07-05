## Project Overview
- A collection of repositories containing tools for FPGA development and SystemVerilog IPs.

## Coding Style
- **RTL**:
  - Use the `logic` type for combinational logic signals and the `reg` type for flip-flops (FF).
  - Prefix input signals with `i_` and output signals with `o_` (excluding clock and reset signals).
  - Suffix all signal names with their corresponding clock domain name, excluding clock and reset signals (e.g., `data_aclk`).
  - For `reg` type signals, append `r` to the clock domain suffix (e.g., `data_aclkr`).
  - **1 File 1 Module Rule**: Apply a strict one-module-per-file layout. Do not define helper or wrapper modules in the same file.
  - **Interface Arrays & Logic Binding**: When mapping interface arrays (e.g., `axi_if s_axi[N]`) to internal logic signals, map them to flat/multidimensional `logic` arrays. To bypass Vivado `xvlog` compiler errors for non-constant indexing of interface members, perform the mapping inside a `generate` loop using an `always_comb` block inside the main module (do not define separate binder modules).
- **UVM**:
  - Use UVM for all RTL simulation code.

## Git
- Follow the GitHub Flow workflow.
- Prefix commit messages with one of the following tags: `{add, refactor, update, bugfix}`.

## Constraints & Prohibitions
- Never modify files inside the `legacy/` or `deprecated/` directories.
- Do not add external dependencies without prior permission.

## Infrastructure & Tooling
- **Python Scripts & Code Generators**:
  - レジスタ定義（YAML等）からコード（RTLやUVM RAL）を生成するスクリプトを拡張・作成する際は、肥大化を防ぐためにパーサー（Parser）、共通データモデル（Model）、および各ターゲット用コード生成器（Generator）をモジュール化して明確に分離すること。
- **Makefiles with Python Virtual Environments (venv)**:
  - Makefile内でPythonの仮想環境（venv）の構築や実行を管理する際は、循環参照警告（`Circular dependency`）を回避し、かつ無駄な再セットアップを防いで実行を高速化するため、仮想環境ディレクトリそのものではなく `$(VENV)/bin/activate`（アクティベートファイル）などを依存先ターゲットとして利用すること。

## Verification & UVM
- **UVM BFM & Config Propagation**:
  - UVM Agentを記述する際は、エージェント単体で自律動作できるよう、`build_phase` 内で `uvm_config_db` から `config` オブジェクトを取得（get）し、見つからない場合はデフォルト設定で自ら `create` して、下位コンポーネント（Driver, Monitor）に `set` で伝搬する実装パターンを遵守すること。
  - BFMパッケージファイル（`xxx_pkg.sv`）を作成・更新する際は、パッケージの定義内で `xxx_config.sv` や `xxx_monitor.sv` などの構成ファイルすべてが漏れなくインクルードされているか確認すること。

- **UVM Test & Report Server Connection**:
  - 新規にUVMテストクラス（`xxx_test_base` 等）を記述する際は、共通パッケージ `common_pkg` をインポートし、`build_phase` 内で `my_report_server` をインスタンス化して登録（`uvm_report_server::set_server(custom_server)`）する UVM 環境の定石パターンを遵守すること。

- **Testbench Directory Structure & Waveform Dumps**:
  - テストベンチ最上位である `tb_top.sv` は `sim/tb` ディレクトリに配置し、UVMクラス関連の検証パッケージやファイル群は `sim/uvm` 内に配置すること。
  - `tb_top.sv` などのテストベンチコード内には波形ダンプ（`$dumpfile` や `$dumpvars` 等）を直接記述せず、シミュレーション用TCLや実行スクリプト側で動的に制御すること。

- **UVM Timeout Configuration**:
  - `uvm_top.set_timeout` を用いたタイムアウトの設定・上書きは、シーケンスの `body` タスクなど `run_phase` 開始後に行ってもタイマー起動済みのため反映されない。必ず `build_phase` （例: `tb_test_base`）などのシミュレーション開始前フェーズにて実行すること。
  - タイムアウト値は、極低速なテストケース（例: 110ボー等の長大シミュレーション）を考慮しつつ、ハング時に時間を浪費しないよう適切に定義し、シミュレーション実行スクリプトやMakefile側からコマンドライン引数（`+UVM_TIMEOUT` 等）で上書き可能にすること。

- **Virtual Interface Arrays**: When dynamically indexing interface arrays inside testbench loops or procedural blocks, assign the interfaces to a `virtual interface` array (e.g., `typedef virtual axi_if vif_t; vif_t vifs[N];`) at startup/initial phase, and index the virtual interface array.
- **Task Assignments**: In testbench tasks (especially `automatic` tasks), use blocking assignments (`=`) for task local (automatic) variables to prevent elaboration errors in `xelab`.

- **Xsim Simulation Options**:
  - `xsim` でカバレッジのデータベースディレクトリを指定するオプションは、`-covdir` ではなく `--cov_db_dir` を使用すること。
  - Always specify `-timescale 1ns/1ps` in the `xelab` compilation command in Makefiles/run scripts to prevent simulation data flow errors due to missing timescales in interfaces or design components.

## Rum simulation
- テストケースをsimulationを実行する際、RTLの修正は勝手に行わず、エラーが出たことを教えること
- ただし、UVMの修正はおこなっても良い

