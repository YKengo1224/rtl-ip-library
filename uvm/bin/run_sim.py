#!/usr/bin/python3
import os
import subprocess
from pathlib import Path
import argparse
import shlex
from enum import Enum, auto

class Simulator(Enum):
    XSIM = auto()
    VERILATOR = auto()
    DSIM = auto()
    XCELIUM = auto()
    VCS = auto()

class Runsim:
    def __init__(self):
        self.simulator = Simulator.XSIM
        self.home_dir = Path.cwd()
        self.work_dir = self.home_dir / "work"
        self.log_dir = self.home_dir / "log"
        self.bin_dir = self.home_dir / "bin"
        self.rtl_dir = self.home_dir / "rtl"
        self.parser = argparse.ArgumentParser(description='Run RTL Simulation Script')
        self.add_arg()
        self.build_cmd = []
        self.elab_cmd = []
        self.run_cmd = []

    def _prepare_xsim_filelist(self, original_f):
        self.work_dir.mkdir(parents=True, exist_ok=True)
        processed_f = self.work_dir / "xsim_filelist.f"

        lines = self._recursive_flatten_filelist(original_f)
        
        with open(processed_f, 'w') as f_out:
            for line in lines:
                line = os.path.expandvars(line)
                if line.strip().startswith("+incdir+"):
                    line = line.replace("+incdir+", "-i ", 1)

                f_out.write(line + "\n")

        return processed_f
    def _recursive_flatten_filelist(self, file_path):
        expanded_lines = []
        path = Path(os.path.expandvars(str(file_path))).resolve()
        
        if not path.exists():
            print(f"WARNING: File not found: {path}")
            return []

        with open(path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith(('#', '//')): continue
                               
                if line.startswith(('-f', '-F')):
                    sub_file = line.split(None, 1)[1]
                    expanded_lines.extend(self._recursive_flatten_filelist(sub_file))
                else:
                    expanded_lines.append(line)
        return expanded_lines
    
    def add_arg(self):
        sim_choices = [s.name.lower() for s in Simulator]
        
        self.parser.add_argument('-s','--simulator', choices=sim_choices, default='xsim', help="")
        self.parser.add_argument('--work_dir', help="")
        self.parser.add_argument('--log_dir', help="")
        self.parser.add_argument('--timescale', default='1ns/1ps', help='')
        self.parser.add_argument('--no-uvm', action='store_true', help="")
        self.parser.add_argument('-c', '--cov', action='store_true', help="")
        self.parser.add_argument('-w', '--wave', action='store_true', help="")
        self.parser.add_argument('-f',"--filelist", default="filelist.f", help="")
        self.parser.add_argument('-seed', default='1', help="")
        self.parser.add_argument('-top', default="tb_top", help="")
        self.parser.add_argument('testname', help="")
        self.parser.add_argument('-el','--env_path_list', default='', help="設定する環境変数のlistを取得")
        
        
    def parse_arg(self):
        self.args = self.parser.parse_args()

        self.simulator = Simulator[self.args.simulator.upper()]

        if self.args.work_dir:
            self.work_dir = Path(self.args.work_dir) / self.args.testname
        else:
            self.work_dir = self.work_dir / self.args.testname
        if self.args.log_dir:
            self.log_dir = Path(self.args.log_dir) / self.args.testname
        else:
            self.log_dir = self.log_dir / self.args.testname


    def build(self):
        match self.simulator:
            case Simulator.XSIM:
                xsim_f = self._prepare_xsim_filelist(self.args.filelist)
                
                self.build_cmd.append("xvlog")
                self.build_cmd.extend(['-sv'])
                if not self.args.no_uvm:
                    self.build_cmd.extend(['-L', 'uvm'])
                    
                self.build_cmd.extend(['-f', str(xsim_f)])
                self.build_cmd.extend(['-log', str(self.log_dir / 'xvlog.log')])

                self.elab_cmd.append("xelab")
                self.elab_cmd.append(self.args.top)
                self.elab_cmd.extend(['-log', str(self.log_dir / 'xelab.log')])
                self.elab_cmd.extend(['-debug', 'typical'])
                self.elab_cmd.append('--incr')
                if not self.args.no_uvm:
                    self.elab_cmd.extend(['-L', 'uvm'])

                self.elab_cmd.extend(['-timescale', self.args.timescale])
                if self.args.cov:
                    self.elab_cmd.extend(['--cc_type', 'sbct'])

                self.run_cmd.append("xsim")
                self.run_cmd.append(self.args.top)
                self.run_cmd.extend(['--log', str(self.log_dir / 'xsim.log')])
                self.run_cmd.extend(['--sv_seed', self.args.seed])
                
                if self.args.wave:
                    self.run_cmd.extend(['--tclbatch', str(self.bin_dir / 'xsim_wave.tcl')])
                    self.run_cmd.extend(['--wdb', str(self.work_dir/ 'wave.wdb')])
                else:
                    self.run_cmd.append("-R")
                    
                if not self.args.no_uvm:
                    self.run_cmd.extend(['--testplusarg', 'UVM_TESTNAME=tb_test_base'])
                    self.run_cmd.extend(['--testplusarg', f'TEST_CASE={self.args.testname}'])

                    

            case _:
                raise NotImplementedError(f"Simulator {self.simulator.name} is not implemented yet.")

    def def_env(self):
        env_items = []
        
        if self.args.env_path_list and os.path.isfile(self.args.env_path_list):
            with open(self.args.env_path_list, 'r') as f:
                env_items = f.readlines()        
                
        for item in env_items:
            item = item.strip()
            # 空行やコメント（#）をスルーする
            if not item or item.startswith('#'):
                continue
                
            if '=' in item:
                key, value = item.split('=', 1)
                # 重要：valueの中にある別の環境変数（${HOME}など）も展開してセットする
                expanded_value = os.path.expandvars(value.strip())
                os.environ[key.strip()] = expanded_value
                # デバッグ用に print しておくと安心
                # print(f"ENV: {key.strip()} = {expanded_value}")
                
    def execute_cmd(self):
        self.work_dir.mkdir(parents=True, exist_ok=True)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        if self.build_cmd:
            print(f"Command : {shlex.join(self.build_cmd)}\n")
            subprocess.run(self.build_cmd, cwd=self.work_dir, check=True)
        if self.elab_cmd:
            print(f"Command : {shlex.join(self.elab_cmd)}\n")
            subprocess.run(self.elab_cmd, cwd=self.work_dir, check=True)

        print(f"Command : {shlex.join(self.run_cmd)}\n")
        subprocess.run(self.run_cmd, cwd=self.work_dir, check=True)
  

    def check_result(self):
        log_file = self.log_dir / 'xsim.log'
        if not log_file.exists():
            print(f"ERROR: Log file not found: {log_file}")
            import sys
            sys.exit(1)
            
        print(f"\n--- Checking Simulation Result ({self.args.testname}) ---")
        
        uvm_errors = -1
        uvm_fatals = -1
        has_pass_keyword = False
        
        with open(log_file, 'r', errors='ignore') as f:
            for line in f:
                if "Number of UVM_ERROR messages" in line:
                    parts = line.split(":")
                    if len(parts) >= 2:
                        try:
                            uvm_errors = int(parts[-1].strip())
                        except ValueError:
                            pass
                elif "UVM_ERROR" in line and ":" in line:
                    parts = line.split(":")
                    if len(parts) >= 2:
                        try:
                            # Extract numeric value
                            uvm_errors = int(parts[-1].strip())
                        except ValueError:
                            pass
                            
                if "Number of UVM_FATAL messages" in line:
                    parts = line.split(":")
                    if len(parts) >= 2:
                        try:
                            uvm_fatals = int(parts[-1].strip())
                        except ValueError:
                            pass
                elif "UVM_FATAL" in line and ":" in line:
                    parts = line.split(":")
                    if len(parts) >= 2:
                        try:
                            # Extract numeric value
                            uvm_fatals = int(parts[-1].strip())
                        except ValueError:
                            pass
                
                # Detect the PASS keyword from test sequence logs
                if "PASS" in line:
                    if "UVM_INFO" in line or "RAL_SEQ" in line or "UART_SEQ" in line:
                        has_pass_keyword = True

        print(f"UVM Errors: {uvm_errors}")
        print(f"UVM Fatals: {uvm_fatals}")
        print(f"PASS Keyword Detected: {has_pass_keyword}")

        if uvm_errors == 0 and uvm_fatals == 0 and has_pass_keyword:
            print("\n>>> RESULT: PASS <<<\n")
        else:
            print("\n>>> RESULT: FAIL <<<\n")
            import sys
            sys.exit(1)

    def run(self):
        self.parse_arg()
        self.def_env()
        self.build()
        self.execute_cmd()
        self.check_result()


if __name__ == "__main__":
    sim = Runsim()
    sim.run()        
