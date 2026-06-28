from ..model import RegmapModel

class BaseGenerator:
    def __init__(self, model: RegmapModel):
        self.model = model

    def generate(self, output_filename: str):
        raise NotImplementedError
