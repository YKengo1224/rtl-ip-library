import argparse
import subprocess
import sys
import os

class BaseSimulator:
    def __init__(self, args):
        self.args = args
        self.top_module = "sim_top"
        self.filelist = "filelist.f"
        self.snapshot_name = f"snapshot_{self.args.pat}"
        self.log_dir = "./logs"
        self.inc_dir = "./include"
        self.pat_dir = "./pat"
        self.timescale = "1ns/1ps"
        self.wave_file_name = self.args.wave
        
        # ログディレクトリの作成
        os.makedirs(self.log_dir, exist_ok=True)

    def execute_cmd(self, cmd_list, step_name=""):
        """サブプロセスを実行する共通メソッド"""
        cmd_str = " ".join(cmd_list)
        print(f"\n[{self.args.sim.upper()}] Running {step_name}...")
        print(f"COMMAND: {cmd_str}")
        
        if self.args.dry_run:
            return

        try:
            # 実行して結果を待つ
            subprocess.run(cmd_list, check=True)
            print(f"[{self.args.sim.upper()}] {step_name} SUCCESS")
        except subprocess.CalledProcessError as e:
            print(f"\n[{self.args.sim.upper()}] {step_name} FAILED with code {e.returncode}")
            sys.exit(e.returncode)

    def run(self):
        """子クラスでオーバーライドされるメイン処理"""
        raise NotImplementedError("Subclasses must implement run()")
