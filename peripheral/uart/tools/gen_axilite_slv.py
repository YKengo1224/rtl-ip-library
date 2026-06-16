import yaml
import os

class RegmapYamlParser:

    def __init__(self, regmap_filename, template_filename, output_filename):
        self.regmap_filename = regmap_filename
        self.template_filename = template_filename
        self.output_filename = output_filename
        self.rtl_ports = []        
        self.rtl_decl = []
        self.rtl_decode = []
        self.rtl_comb = []
        self.rtl_write_logic = []
        self.rtl_read_logic = []
        self.interrupt_signals = []        

    def parse(self):
        with open(self.regmap_filename, 'r', encoding='utf-8') as f:
            reg_map = yaml.safe_load(f)

        
        for reg in reg_map['registers']:
            reg_name = reg['name']
            offset_hex = f"8'h{reg['offset']:02X}"

            bit_map = ["1'b0"] * 32
                        
            for field in reg['fields']:
                name = field['name']
                bits = str(field['bits'])
                acc = field['access']
                init = field['init']
                

                if ":" in bits:
                    msb, lsb = map(int, bits.split(":"))
                    width = msb - lsb + 1
                    bit_range = f"[{msb}:{lsb}]"
                else :
                    msb = lsb = int(bits)
                    width = 1
                    bit_range = f"[{lsb}]"
                    
                width_str = f"[{width-1}:0]" if width > 1 else "     "
               
                #Port declear
                if acc == "W1C":
                    port_name = f"i_{name}_set_aclk"
                    self.rtl_ports.append(f"    input wire {width_str} {port_name},")
                elif "W" in acc:
                    port_name = f"o_{name}_aclkr"                    
                    self.rtl_ports.append(f"    output reg {width_str} {port_name},")
                    if "WO" in acc:
                        wtrig_port_name = f"o_{name}_wtrig_aclkr"
                        self.rtl_ports.append(f"    output reg     {wtrig_port_name},")
                        
                if "RO" in acc:
                    read_port_name = f"i_{name}_aclk"
                    if "source" not in field:
                        self.rtl_ports.append(f"    input wire {width_str} {read_port_name},")
                if "R1TRIG" in acc:
                    read_port_name = f"i_{name}_aclk"
                    rtrig_port_name = f"o_{name}_rtrig_aclkr"
                    if "source" not in field:
                        self.rtl_ports.append(f"    input wire {width_str} {read_port_name},")
                        self.rtl_ports.append(f"    output reg        {rtrig_port_name},")
                    
                #Write logic 
                if "W" in acc:
                    we_signal = f"we_{name}"

                    wstrb_cond = " || ".join([f"target_wstrb[{b}]" for b in range(lsb // 8, (msb // 8) + 1)])
                    if (msb // 8) - (lsb // 8) > 0:
                        wstrb_cond = f"({wstrb_cond})" # 複数ある場合はカッコで括る
                    
                    self.rtl_decl.append(f"    wire {we_signal};")
                    self.rtl_decode.append(f"    assign {we_signal} = write_exec && (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == {offset_hex}) && {wstrb_cond};")

                    if acc == "W1C":
                        self.rtl_decl.append(f"    reg {name}_aclkr;")
                        always_block = f"""
    //Field : {name}_aclkr
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            {name}_aclkr <= {width}'d{init};
        end else if({we_signal} && target_wdata{bit_range}) begin
            {name}_aclkr <= {width}'d0; 
        end else if({port_name}) begin
            {name}_aclkr <= {width}'d1;
        end                                          
    end  

          """
                        #add interrupt source list
                        if field.get("is_interrupt") == True:
                            self.interrupt_signals.append(f"({name}_aclkr)")
                    
                    else:
                        always_block = f"""
    //Field : {port_name}
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            {port_name} <= {width}'d{init};
        end else if({we_signal}) begin
            {port_name} <= target_wdata{bit_range}; 
        end
    end

"""
                    self.rtl_write_logic.append(always_block)

                    if "WO" in acc:
                        print('hoge')
                        always_block = f"""
    //Field : {wtrig_port_name}
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            {wtrig_port_name} <= 1'd0;
        end else begin
            {wtrig_port_name} <= {we_signal};
        end
    end

"""
                        self.rtl_write_logic.append(always_block)
                        
                #Read
                if "R1TRIG" in acc:
                    print("piyo")
                    trig_always_block = f"""
    //Field : {wtrig_port_name}
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            {rtrig_port_name} <= 1'd0;
        end else begin
            {rtrig_port_name} <= read_exec &&  (target_awaddr[VARID_ADDR_BITWIDTH-1:0] == {offset_hex});
        end
    end

"""
                    self.rtl_write_logic.append(trig_always_block)
                if acc != "WO":
                    #select insert_read_logic
                    if "source" in field and "mask" in field:
                        src_sig = f"{field['source']}_aclkr"
                        mask_sig= f"o_{field['mask']}_aclkr"
                        self.rtl_decl.append(f"    wire {name};")
                        self.rtl_comb.append(f"    assign {name} = {src_sig} & {mask_sig};")                        
                        insert_read_logic = name
                    elif acc == "W1C":
                        insert_read_logic = f"{name}_aclkr"
                    elif "R1TRIG" in acc:
                        print(read_port_name)
                        insert_read_logic = read_port_name
                    elif "RO" in acc:
                        print(read_port_name)
                        insert_read_logic = read_port_name
                    else :
                        insert_read_logic = port_name                    
                    
                    if msb == lsb:
                        bit_map[31 - lsb] = insert_read_logic
                    else :
                        for b in range(lsb, msb + 1):
                            bit_map[31 - b] = None
                        bit_map[31 - msb] = insert_read_logic
                        
                    #add interrupt source list
                    if field.get("is_interrupt") == True:
                        self.interrupt_signals.append(f"({insert_read_logic})")
                        
                        
                        
                        
            # add read case
            concat_items = []
            zero_count = 0
            idx = 0

            while idx < 32:
                item = bit_map[idx]
                if item == "1'b0":
                    zero_count += 1
                    idx += 1
                elif item is None:
                    idx += 1
                else:
                    if zero_count > 0:
                        concat_items.append(f"{zero_count}'h0")
                        zero_count = 0
                    concat_items.append(item)
                    idx += 1

            if zero_count > 0:
                concat_items.append(f"{zero_count}'h0")

            concat_str = f"{{ {', '.join(concat_items)} }}" if len(concat_items) > 1 else concat_items[0]            
            self.rtl_read_logic.append(f"                {offset_hex}: rdata <= {concat_str};")



        #generate interrupt logic
        if self.interrupt_signals:
            self.rtl_ports.append("    output wire        o_interrupt_aclkr,")            
            always_block = f"""
    //Field : {name}
    always @(posedge aclk or negedge aresetn) begin
        if(!aresetn) begin
            o_interrupt_aclkr <= 1'd0;
        end else if({we_signal}) begin
            o_interrupt_aclkr <= {' | '.join(self.interrupt_signals)}; 
        end
    end

"""        
            self.rtl_comb.append(always_block)
    def output_file(self):
        if not os.path.exists(self.template_filename):
            print(f"Error:{self.template_filename} is not exist")
            return

        with open(self.template_filename, 'r', encoding='utf-8') as f:
            template_str = f.read()

            final_rtl = template_str.replace('// __INSERT_PORTS__', "\n".join(self.rtl_ports))
            final_rtl = final_rtl.replace('// __INSERT_DECLARATIONS__', "\n".join(self.rtl_decl))
            final_rtl = final_rtl.replace('// __INSERT_DECODE__', "\n".join(self.rtl_decode))
            final_rtl = final_rtl.replace('// __INSERT_OTHER_COMB_LOGIC__', "\n".join(self.rtl_comb))
            final_rtl = final_rtl.replace('// __INSERT_WRITE_LOGIC__', "\n".join(self.rtl_write_logic))
            final_rtl = final_rtl.replace('// __INSERT_READ_LOGIC__', "\n".join(self.rtl_read_logic))


        with open (self.output_filename, 'w', encoding='utf-8') as f:
            f.write(final_rtl)

        print(f"Success Generated {self.output_filename}")

if __name__ == "__main__":
    YAML_FILE     = "../doc/register_map.yaml"
    TEMPLATE_FILE = "./axilite_slv_template.sv" # ひな型のパス
    OUTPUT_FILE   = "../rtl/uart_axilite_slv.sv"       # 生成先ファイルのパス    
    parser = RegmapYamlParser(YAML_FILE, TEMPLATE_FILE, OUTPUT_FILE)
    parser.parse() # YAMLファイルがあればここで実行
    parser.output_file()
