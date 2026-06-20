from dataclasses import dataclass, field
from typing import List, Optional

@dataclass
class FieldModel:
    name: str
    bits: str
    access: str
    init: int
    is_interrupt: bool = False
    source: Optional[str] = None
    mask: Optional[str] = None

    @property
    def width(self) -> int:
        if ":" in self.bits:
            msb, lsb = map(int, self.bits.split(":"))
            return msb - lsb + 1
        return 1

    @property
    def msb(self) -> int:
        if ":" in self.bits:
            return int(self.bits.split(":")[0])
        return int(self.bits)

    @property
    def lsb(self) -> int:
        if ":" in self.bits:
            return int(self.bits.split(":")[1])
        return int(self.bits)

    @property
    def bit_range(self) -> str:
        if ":" in self.bits:
            msb, lsb = map(int, self.bits.split(":"))
            return f"[{msb}:{lsb}]"
        return f"[{self.bits}]"

@dataclass
class RegisterModel:
    name: str
    offset: int
    fields: List[FieldModel] = field(default_factory=list)

@dataclass
class RegmapModel:
    registers: List[RegisterModel] = field(default_factory=list)
