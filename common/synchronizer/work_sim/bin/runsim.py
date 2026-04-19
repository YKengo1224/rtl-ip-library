#!/usr/bin/env python3
import argparse
import subprocess
import sys
import os

from XsimSimulator import XsimSimulator
from VerilatorSimulator import VerilatorSimulator


def main():
    parser = argparse.ArgumentParser(description="Multi-Simulator Run Script")
    parser.add_argument("--sim", choices=["xsim", "verilator"], default="xsim", help="Target simulator (default: xsim)")
    parser.add_argument("--pat", type=str, default="default_test", help="Test pattern name")
    parser.add_argument("--wave", type=str, default="wave.fst", help="wavefile  name")
    parser.add_argument("--seed", type=int, help="Random seed for SystemVerilog randomize()")
    parser.add_argument("--cov", action="store_true", help="Enable coverage collection")
    parser.add_argument("--trace", action="store_true", help="Enable waveform dumping")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing")

    args = parser.parse_args()

    print(f"=== Starting Simulation Environment ===")
    print(f" Simulator : {args.sim}")
    print(f" Pattern   : {args.pat}")
    print(f" Seed      : {args.seed if args.seed else 'Random/Default'}")
    print(f"=======================================")

    # 指定されたシミュレータのクラスをインスタンス化
    if args.sim == "xsim":
        sim_runner = XsimSimulator(args)
    elif args.sim == "verilator":
        sim_runner = VerilatorSimulator(args)
    else:
        print(f"Error: Unknown simulator {args.sim}")
        sys.exit(1)

    # 実行！
    sim_runner.run()

if __name__ == "__main__":
    main()
