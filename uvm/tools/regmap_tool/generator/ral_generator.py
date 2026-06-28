from .base import BaseGenerator
from ..model import RegmapModel

class RalGenerator(BaseGenerator):
    def __init__(self, model: RegmapModel, module_name: str):
        super().__init__(model)
        self.module_name = module_name

    def generate(self, output_filename: str):
        # 1. Register Classes Definition
        reg_classes = []
        
        access_map = {
            "RW": "RW",
            "R/W": "RW",
            "RO": "RO",
            "R": "RO",
            "WO": "WO",
            "W": "WO",
            "W1C": "W1C",
            "R1TRIG": "RO",
        }

        for reg in self.model.registers:
            reg_name_lower = reg.name.lower()
            class_name = f"reg_{reg_name_lower}"
            
            field_decls = []
            field_creates = []
            field_configs = []
            
            for field in reg.fields:
                f_name = field.name.lower()
                field_decls.append(f"    rand uvm_reg_field {f_name};")
                field_creates.append(f"        {f_name} = uvm_reg_field::type_id::create(\"{f_name}\");")
                
                uvm_access = access_map.get(field.access, "RW")
                is_rand = 1 if "W" in uvm_access else 0
                
                config_str = f"""        {f_name}.configure(
            .parent(this),
            .size({field.width}),
            .lsb_pos({field.lsb}),
            .access("{uvm_access}"),
            .volatile(0),
            .reset(32'h{field.init:x}),
            .has_reset(1),
            .is_rand({is_rand}),
            .individually_accessible(1)
        );"""
                field_configs.append(config_str)
                
            decl_str = "\n".join(field_decls)
            create_str = "\n".join(field_creates)
            config_block_str = "\n\n".join(field_configs)
            
            reg_class = f"""class {class_name} extends uvm_reg;
    `uvm_object_utils({class_name})

{decl_str}

    function new(string name = "{class_name}");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
{create_str}

{config_block_str}
    endfunction
endclass
"""
            reg_classes.append(reg_class)

        # 2. Register Block Class Definition
        reg_block_decls = []
        reg_block_builds = []
        block_class_name = f"{self.module_name}_reg_block"
        
        for reg in self.model.registers:
            reg_name_lower = reg.name.lower()
            reg_class_name = f"reg_{reg_name_lower}"
            
            reg_block_decls.append(f"    rand {reg_class_name} {reg_name_lower};")
            
            build_str = f"""        {reg_name_lower} = {reg_class_name}::type_id::create("{reg_name_lower}");
        {reg_name_lower}.configure(this);
        {reg_name_lower}.build();
        default_map.add_reg({reg_name_lower}, 8'h{reg.offset:02x}, "RW");"""
            reg_block_builds.append(build_str)
            
        block_decl_str = "\n".join(reg_block_decls)
        block_build_str = "\n\n".join(reg_block_builds)
        
        reg_block_class = f"""class {block_class_name} extends uvm_reg_block;
    `uvm_object_utils({block_class_name})

{block_decl_str}

    uvm_reg_map default_map;

    function new(string name = "{block_class_name}");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);

{block_build_str}

        lock_model();
    endfunction
endclass
"""

        # 3. Assembly and File Write
        macro_guard = f"_H_{block_class_name.upper()}_SV"
        
        reg_classes_str = "\n".join(reg_classes)
        full_content = f"""`ifndef {macro_guard}
`define {macro_guard}

//=============================================================================
// Register Definitions
//=============================================================================
{reg_classes_str}

//=============================================================================
// Register Block Definition
//=============================================================================
{reg_block_class}

`endif
"""

        with open(output_filename, 'w', encoding='utf-8') as f:
            f.write(full_content)
            
        print(f"Success Generated RAL Model: {output_filename}")
