#!/usr/bin/python3
import os
import sys
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
        self.base_work_dir.mkdir(parents=True, exist_ok=True)
        processed_f = self.base_work_dir / "xsim_filelist.f"

        lines = self._recursive_flatten_filelist(original_f)
        
        # Prepend timescale_dummy.sv to force default 1ns/1ps timescale in xvlog
        dummy_file = self.bin_dir.parent / "tb" / "timescale_dummy.sv"
        if dummy_file.exists():
            lines.insert(0, str(dummy_file.resolve()))
        
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
        self.parser.add_argument('testname', nargs='?', default=None, help="")
        self.parser.add_argument('-el','--env_path_list', default='', help="設定する環境変数のlistを取得")
        self.parser.add_argument('-a', '--all', action='store_true', help="caseディレクトリにあるすべてのケースを実行")
        self.parser.add_argument('--timeout', default=None, help="UVM simulation timeout (e.g., 300ms, 500us)")
        
        
    def parse_arg(self):
        self.args = self.parser.parse_args()

        self.simulator = Simulator[self.args.simulator.upper()]

        if not self.args.all and not self.args.testname:
            self.parser.error("testname is required when -a/--all is not specified")

        self.base_work_dir = Path(self.args.work_dir) if self.args.work_dir else self.home_dir / "work"
        self.base_log_dir = Path(self.args.log_dir) if self.args.log_dir else self.home_dir / "log"

        if self.args.testname:
            self.work_dir = self.base_work_dir / self.args.testname
            self.log_dir = self.base_log_dir / self.args.testname

    def build(self):
        match self.simulator:
            case Simulator.XSIM:
                xsim_f = self._prepare_xsim_filelist(self.args.filelist)
                
                self.build_cmd.append("xvlog")
                self.build_cmd.extend(['-sv'])
                if not self.args.no_uvm:
                    self.build_cmd.extend(['-L', 'uvm'])
                    
                self.build_cmd.extend(['-f', str(xsim_f)])
                self.build_cmd.extend(['-log', str(self.base_log_dir / 'xvlog.log')])

                self.elab_cmd.append("xelab")
                self.elab_cmd.append(self.args.top)
                self.elab_cmd.extend(['-log', str(self.base_log_dir / 'xelab.log')])
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
                    self.run_cmd.extend(['--wdb', str(self.work_dir / 'wave.wdb')])
                else:
                    self.run_cmd.append("-R")
                    
                if self.args.cov:
                    self.run_cmd.extend(['--cov_db_dir', str(self.work_dir / 'xsim.covdb')])
                    
                if not self.args.no_uvm:
                    self.run_cmd.extend(['--testplusarg', 'UVM_TESTNAME=tb_test_base'])
                    self.run_cmd.extend(['--testplusarg', f'TEST_CASE={self.args.testname}'])
                    if self.args.timeout:
                        self.run_cmd.extend(['--testplusarg', f'UVM_TIMEOUT={self.args.timeout},NO'])

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
                
    def execute_cmd(self, run_build=True):
        self.base_work_dir.mkdir(parents=True, exist_ok=True)
        self.base_log_dir.mkdir(parents=True, exist_ok=True)
        self.work_dir.mkdir(parents=True, exist_ok=True)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        if run_build:
            if self.build_cmd:
                print(f"Command : {shlex.join(self.build_cmd)}\n")
                subprocess.run(self.build_cmd, cwd=self.base_work_dir, check=True)
            if self.elab_cmd:
                print(f"Command : {shlex.join(self.elab_cmd)}\n")
                subprocess.run(self.elab_cmd, cwd=self.base_work_dir, check=True)

        print(f"Command : {shlex.join(self.run_cmd)}\n")
        subprocess.run(self.run_cmd, cwd=self.base_work_dir, check=True)
  

    def check_result(self, exit_on_fail=True):
        log_file = self.log_dir / 'xsim.log'
        if not log_file.exists():
            print(f"ERROR: Log file not found: {log_file}")
            if exit_on_fail:
                import sys
                sys.exit(1)
            return False
            
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
            return True
        else:
            print("\n>>> RESULT: FAIL <<<\n")
            if exit_on_fail:
                import sys
                sys.exit(1)
            return False

    def run(self):
        self.parse_arg()
        self.def_env()
        if self.args.all:
            self.run_all()
        else:
            self.build()
            self.execute_cmd(run_build=True)
            self.check_result(exit_on_fail=True)

    def run_all(self):
        case_dir = self.home_dir / "case"
        if not case_dir.exists():
            case_dir = self.home_dir / "sim" / "case"
            
        testcases = []
        if case_dir.exists():
            for f in sorted(case_dir.glob("test_*.sv")):
                testcases.append(f.stem)

        passed = []
        failed = []

        print(f"Starting execution of all {len(testcases)} testcases from case directory...")

        # 1. Run build (compile & elaboration) once before the loop
        print("Pre-building design (compiling and elaborating) once for all testcases...")
        # Temporarily set dummy testname for build command generation
        self.args.testname = "shared_build"
        self.work_dir = self.base_work_dir
        self.log_dir = self.base_log_dir
        
        self.base_work_dir.mkdir(parents=True, exist_ok=True)
        self.base_log_dir.mkdir(parents=True, exist_ok=True)
        
        self.build_cmd = []
        self.elab_cmd = []
        self.run_cmd = []
        self.build()
        
        try:
            if self.build_cmd:
                print(f"Command : {shlex.join(self.build_cmd)}\n")
                subprocess.run(self.build_cmd, cwd=self.base_work_dir, check=True)
            if self.elab_cmd:
                print(f"Command : {shlex.join(self.elab_cmd)}\n")
                subprocess.run(self.elab_cmd, cwd=self.base_work_dir, check=True)
        except Exception as e:
            print(f"ERROR: Build failed (compile or elaboration error): {e}")
            sys.exit(1)

        # 2. Run simulation for each testcase
        for idx, tc in enumerate(testcases, 1):
            print(f"[{idx}/{len(testcases)}] Running {tc}...")
            
            self.args.testname = tc
            self.work_dir = self.base_work_dir / tc
            self.log_dir = self.base_log_dir / tc
            
            self.build_cmd = []
            self.elab_cmd = []
            self.run_cmd = []
            self.build()
            
            try:
                # Skip building and only run xsim
                self.execute_cmd(run_build=False)
                is_pass = self.check_result(exit_on_fail=False)
            except Exception as e:
                print(f"  -> Process Error occurred: {e}")
                is_pass = False
                
            if is_pass:
                passed.append(tc)
                print(f"  -> PASS")
            else:
                failed.append(tc)
                print(f"  -> FAIL")

        print("\n==========================================")
        print("        UART Verification Summary         ")
        print("==========================================")
        print(f"Total Run   : {len(testcases)}")
        print(f"Passed      : {len(passed)}")
        print(f"Failed      : {len(failed)}")
        print("==========================================")
        
        if failed:
            print("\nFailed testcases:")
            for tc in failed:
                print(f" - {tc}")
            sys.exit(1)
        else:
            print("\nAll executed tests passed successfully!")
            sys.exit(0)



if __name__ == "__main__":
    sim = Runsim()
    sim.run()        
