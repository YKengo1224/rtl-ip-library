#!/usr/local/bin/python3
import os
import subprocess
from Venv import Venv

GIT_PATH = "https://github.com/lowRISC/ibex.git"
IBEX_HOME = "ibex"
CONFIG_NAME = "maxperf"


def main():

    #create venv
    my_venv = Venv("py_venv")
    my_venv.gen_venv()

    fusesoc = os.path.join(my_venv.py_venv, "bin", "fusesoc")
    print(fusesoc)

    #git clone
    print(f"Cloning {GIT_PATH} into {IBEX_HOME}...")
    if not os.path.exists(IBEX_HOME):
        subprocess.run(["git", "clone", GIT_PATH, IBEX_HOME], check=True)


    # package install
    my_venv.install_pkg(pkg_name="fusesoc")
    req_file = os.path.join(IBEX_HOME, "python-requirements.txt")
    if os.path.exists(req_file):    
        my_venv.install_pkg(list_name=req_file)

        
    print(f"Getting config options via Make for IBEX_CONFIG={CONFIG_NAME}...")
    try:
        
        config_opt_str = subprocess.check_output(
            ["make", "test-cfg", f"IBEX_CONFIG={CONFIG_NAME}"],
            cwd=IBEX_HOME,
            text=True
            ).strip()
        config_opts = config_opt_str.split()
        print(f"Config Options: {config_opts}")
    except subprocess.CalledProcessError as e:
        print(f"Error running make: {e}")
        return

    #generate IP
    cmd = ([fusesoc, "library", "add", "ibex", IBEX_HOME])
    print(f"Executing: {' '.join(cmd)}")    
    subprocess.run([fusesoc, "library", "add", "ibex", IBEX_HOME])        

    cmd_run = [fusesoc, "--cores-root", IBEX_HOME, "run",  "--target=lint", "--setup", "lowrisc:ibex:ibex_top"] + config_opts
    subprocess.run(cmd_run)

if __name__ == "__main__":
    main()
