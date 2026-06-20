import os
import argparse
from regmap_tool.parser import RegmapParser
from regmap_tool.generator.rtl_generator import RtlGenerator
from regmap_tool.generator.ral_generator import RalGenerator

class RegmapYamlParser:
    def __init__(self, regmap_filename, template_filename, output_filename, ral_filename=None):
        self.regmap_filename = regmap_filename
        self.template_filename = template_filename
        self.output_filename = output_filename
        self.ral_filename = ral_filename
        self.model = None

    def parse(self):
        parser = RegmapParser(self.regmap_filename)
        self.model = parser.parse()

    def output_file(self):
        # 1. Generate RTL
        generator = RtlGenerator(self.model, self.template_filename)
        generator.generate(self.output_filename)
        
        # 2. Generate RAL (UVM Register Model) if specified
        if self.ral_filename:
            ral_dir = os.path.dirname(self.ral_filename)
            if ral_dir and not os.path.exists(ral_dir):
                os.makedirs(ral_dir, exist_ok=True)
            
            ral_generator = RalGenerator(self.model)
            ral_generator.generate(self.ral_filename)

def main():
    parser = argparse.ArgumentParser(description="Generate AXI-Lite Slave RTL and UVM RAL model from register map YAML.")
    parser.add_argument("-y", "--yaml", default="../doc/register_map.yaml", help="Path to register map YAML file")
    parser.add_argument("-t", "--template", default="./axilite_slv_template.sv", help="Path to RTL template file")
    parser.add_argument("-r", "--rtl-out", default="../rtl/uart_axilite_slv.sv", help="Path to output RTL file")
    parser.add_argument("-l", "--ral-out", default="../sim/tb/uart_reg_model.sv", help="Path to output UVM RAL model file (optional)")
    args = parser.parse_args()

    regmap_parser = RegmapYamlParser(args.yaml, args.template, args.rtl_out, args.ral_out)
    regmap_parser.parse()
    regmap_parser.output_file()

if __name__ == "__main__":
    main()
