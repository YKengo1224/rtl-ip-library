import os
import venv
import subprocess
import sys


class Venv:
    def __init__(self, venv_name):
        self.py_venv = venv_name
        self.venv_python = os.path.join(self.py_venv, "bin", "python")
        self.venv_pip = os.path.join(self.py_venv, "bin", "pip")

    def gen_venv(self):
        if os.path.exists(self.venv_python):
            print(f"Waning:{self.venv_python} is allready exist")
            return

        print("create venv")
        venv.create(self.py_venv, with_pip=True)


    def install_pkg(self, list_name= None, pkg_name= None):
        if list_name is not None:
            subprocess.run([self.venv_pip, "install", "-r", list_name], check=True)
        if pkg_name is not None:
            subprocess.run([self.venv_pip, "install", pkg_name], check=True)

    def run(self, script_name):
        subprocess.run([self.venv_python, script_name], check=True)
