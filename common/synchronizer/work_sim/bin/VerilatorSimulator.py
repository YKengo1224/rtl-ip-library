from BaseSimulator import BaseSimulator

class VerilatorSimulator(BaseSimulator):
    def __init__(self, args):
        super().__init__(args)
        self.bin_compile = "verilator"
        self.bin_run = f"./obj_dir/V{self.top_module}"
        
        self.opt_compile = ["--binary", "-j", "12", "-Wno-fatal", "--top", self.top_module, "-f", self.filelist]
        self.opt_run = []

        if self.args.trace:
            self.opt_compile.append("--trace-fst")
        if self.args.seed:
            self.opt_run.append(f"+verilator+seed+{self.args.seed}")

    def run(self):
        # Step 1: Compile (C++生成とビルド)
        cmd1 = [self.bin_compile] + self.opt_compile
        self.execute_cmd(cmd1, step_name="Compile (Verilator)")

        # Step 2: Simulate (生成されたバイナリの実行)
        cmd2 = [self.bin_run] + self.opt_run
        self.execute_cmd(cmd2, step_name="Simulate (Binary)")
