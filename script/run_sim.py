#!/usr/bin/env python3
import argparse
import subprocess
import sys
import os

def build_cmd(args):
    """選択されたシミュレータに応じてコマンドを組み立てる"""
    sim = args.sim
    top_module = "sim_top"
    filelist = "-f filelist.f" # ソースコードのリストをまとめたファイル
    
    cmd = []

    if sim == "verilator":
        # Verilatorのパスや環境変数は必要に応じて設定
        bin_path = "/home/kengo/work/build_dir/verilator/bin/verilator"
        cmd = [bin_path, "--binary", "-j", "12", "-Wno-fatal", "--top", top_module, filelist]
        
        # オプションの追加例
        if args.cov:
            cmd.append("--coverage")
        if args.trace:
            cmd.append("--trace") # 波形ダンプ

    elif sim == "xrun":
        cmd = ["xrun", "-64bit", "-top", top_module, filelist]
        if args.cov:
            cmd.append("-coverage all")
        if args.trace:
            cmd.append("-access +rwc")

    elif sim == "questa":
        # Questaは vlib -> vlog -> vsim の手順を踏むか、qrun を使う
        cmd = ["qrun", "-top", top_module, filelist]
        if args.cov:
            cmd.append("-coverage")

    else:
        print(f"Error: Unsupported simulator {sim}")
        sys.exit(1)

    # テストパターンの指定 (マクロで渡す例)
    if args.pat:
        if sim == "verilator":
            cmd.append(f"+define+TEST_PAT={args.pat}")
        else:
            cmd.append(f"+define+TEST_PAT={args.pat}")

    return cmd

def main():
    parser = argparse.ArgumentParser(description="Simulation Runner Script")
    parser.add_argument("--sim", choices=["verilator", "xrun", "questa", "dsim"], default="verilator", help="Target simulator")
    parser.add_argument("--pat", type=str, required=True, help="Test pattern name (e.g., pat_01)")
    parser.add_argument("--cov", action="store_true", help="Enable coverage collection")
    parser.add_argument("--trace", action="store_true", help="Enable waveform dumping")
    parser.add_argument("--dry-run", action="store_true", help="Print command only, do not execute")
    
    args = parser.parse_args()

    # コマンドの組み立て
    cmd = build_cmd(args)
    cmd_str = " ".join(cmd)
    
    print(f"--- Running Simulation ---")
    print(f"Simulator : {args.sim}")
    print(f"Pattern   : {args.pat}")
    print(f"Command   : {cmd_str}\n")

    if args.dry_run:
        sys.exit(0)

    # 実行
    try:
        # 環境変数が必要な場合（Verilatorなど）は env 引数で渡す
        my_env = os.environ.copy()
        my_env["VERILATOR_ROOT"] = "/home/kengo/work/build_dir/verilator"

        result = subprocess.run(cmd, env=my_env, check=True)
        print("\n--- Simulation Finished Successfully ---")
    except subprocess.CalledProcessError as e:
        print(f"\n--- Simulation Failed with return code {e.returncode} ---")
        sys.exit(e.returncode)

if __name__ == "__main__":
    main()
