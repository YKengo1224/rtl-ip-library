import yaml
from .model import RegmapModel, RegisterModel, FieldModel

class RegmapParser:
    def __init__(self, regmap_filename: str):
        self.regmap_filename = regmap_filename

    def parse(self) -> RegmapModel:
        with open(self.regmap_filename, 'r', encoding='utf-8') as f:
            reg_map = yaml.safe_load(f)

        registers = []
        for reg in reg_map['registers']:
            fields = []
            for field in reg['fields']:
                fields.append(FieldModel(
                    name=field['name'],
                    bits=str(field['bits']),
                    access=field['access'],
                    init=field['init'],
                    is_interrupt=field.get('is_interrupt', False),
                    source=field.get('source'),
                    mask=field.get('mask')
                ))
            registers.append(RegisterModel(
                name=reg['name'],
                offset=reg['offset'],
                fields=fields
            ))
        return RegmapModel(registers=registers)
