from BaseSimulator import BaseSimulator

class XsimSimulator(BaseSimulator):
    def __init__(self, args):
        super().__init__(args)
        
        # 各ステップのバイナリ
        self.bin_compile = "xvlog"
        self.bin_elab = "xelab"
        self.bin_run = "xsim"
 

        # 各ステップの基本オプション
        # xvlog: SystemVerilog対応(-sv), filelistの読み込み
        self.opt_compile = ["-sv", "-i", self.inc_dir, "-i", self.pat_dir, "-f", self.filelist]
        
        # xelab: トップモジュールの指定, 波形デバッグ有効化(-debug typical), スナップショット名
        self.opt_elab = ["-debug", "typical", "--timescale", self.timescale , "-top", self.top_module, "-snapshot", self.snapshot_name]
        
        # xsim: 実行(-R)
        self.opt_run = ["-R", "--testplusarg", f"WAVE_FILE={self.wave_file_name}"]

        # 追加オプション（引数による分岐）
        if self.args.cov:
            pass # 必要ならxsimのカバレッジオプションを追加
        if self.args.seed:
            self.opt_run.extend(["-sv_seed", str(self.args.seed)])

    def run(self):
        """xsimは compile -> elaborate -> simulate の3段階"""
        # Step 1: Compile
        cmd1 = [self.bin_compile] + self.opt_compile
        self.execute_cmd(cmd1, step_name="Compile (xvlog)")

        # Step 2: Elaborate
        cmd2 = [self.bin_elab] + self.opt_elab
        self.execute_cmd(cmd2, step_name="Elaborate (xelab)")

        # Step 3: Simulate
        cmd3 = [self.bin_run, self.snapshot_name] + self.opt_run
        self.execute_cmd(cmd3, step_name="Simulate (xsim)")
