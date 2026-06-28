import os
import argparse
from regmap_tool.parser import RegmapParser
from regmap_tool.generator.rtl_generator import RtlGenerator
from regmap_tool.generator.ral_generator import RalGenerator

class RegmapYamlParser:
    def __init__(self, regmap_filename, template_filename, output_filename, module_name, ral_filename=None):
        self.regmap_filename = regmap_filename
        self.template_filename = template_filename
        self.output_filename = output_filename
        self.module_name = module_name
        self.ral_filename = ral_filename
        self.model = None

    def parse(self):
        parser = RegmapParser(self.regmap_filename)
        self.model = parser.parse()

    def output_file(self):
        # 1. Generate RTL
        generator = RtlGenerator(self.model, self.template_filename, self.module_name)
        generator.generate(self.output_filename)
        
        # 2. Generate RAL (UVM Register Model) if specified
        if self.ral_filename:
            ral_dir = os.path.dirname(self.ral_filename)
            if ral_dir and not os.path.exists(ral_dir):
                os.makedirs(ral_dir, exist_ok=True)
            
            ral_generator = RalGenerator(self.model, self.module_name)
            ral_generator.generate(self.ral_filename)

def main():
    parser = argparse.ArgumentParser(description="Generate AXI-Lite Slave RTL and UVM RAL model from register map YAML.")
    parser.add_argument("-m", "--module-name", required=True, help="Base module name (e.g. uart)")
    parser.add_argument("-y", "--yaml", required=True, help="Path to register map YAML file")
    parser.add_argument("-t", "--template", required=True, help="Path to RTL template file")
    parser.add_argument("-r", "--rtl-out", required=True, help="Path to output RTL file")
    parser.add_argument("-l", "--ral-out", default=None, help="Path to output UVM RAL model file (optional)")
    args = parser.parse_args()

    regmap_parser = RegmapYamlParser(args.yaml, args.template, args.rtl_out, args.module_name, args.ral_out)
    regmap_parser.parse()
    regmap_parser.output_file()

if __name__ == "__main__":
    main()
