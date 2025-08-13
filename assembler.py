"""
MIPS Single-Cycle Processor Assembler
Converts MIPS assembly code to machine code for the custom MIPS implementation.
Supports all instructions defined in the ISA.md specification.
"""

import re
import sys
from typing import Dict, List, Tuple, Optional

class MIPSAssembler:
    def __init__(self):
        # Register mappings
        self.registers = {
            '$zero': 0, '$0': 0,
            '$at': 1, '$1': 1,
            '$v0': 2, '$2': 2, '$v1': 3, '$3': 3,
            '$a0': 4, '$4': 4, '$a1': 5, '$5': 5, '$a2': 6, '$6': 6, '$a3': 7, '$7': 7,
            '$t0': 8, '$8': 8, '$t1': 9, '$9': 9, '$t2': 10, '$10': 10, '$t3': 11, '$11': 11,
            '$t4': 12, '$12': 12, '$t5': 13, '$13': 13, '$t6': 14, '$14': 14, '$t7': 15, '$15': 15,
            '$s0': 16, '$16': 16, '$s1': 17, '$17': 17, '$s2': 18, '$18': 18, '$s3': 19, '$19': 19,
            '$s4': 20, '$20': 20, '$s5': 21, '$21': 21, '$s6': 22, '$22': 22, '$s7': 23, '$23': 23,
            '$t8': 24, '$24': 24, '$t9': 25, '$25': 25,
            '$k0': 26, '$26': 26, '$k1': 27, '$27': 27,
            '$gp': 28, '$28': 28, '$sp': 29, '$29': 29, '$fp': 30, '$30': 30, '$ra': 31, '$31': 31
        }
        
        # R-type instructions (opcode 0x00)
        self.r_type_functs = {
            'add': 0x20, 'sub': 0x22, 'mul': 0x18,
            'and': 0x24, 'or': 0x25, 'xor': 0x26,
            'sll': 0x00, 'srl': 0x02, 'sra': 0x03,
            'sllv': 0x04, 'srlv': 0x06, 'srav': 0x07,
            'rol': 0x1C, 'ror': 0x1D, 'rolv': 0x1E, 'rorv': 0x1F,
            'enc': 0x30, 'dec': 0x31
        }
        
        # I-type instructions
        self.i_type_opcodes = {
            'addi': 0x08, 'subi': 0x08,  # subi is alias for addi with negative immediate
            'lw': 0x23, 'sw': 0x2B,
            'beq': 0x04
        }
        
        # J-type instructions
        self.j_type_opcodes = {
            'jmp': 0x02, 'j': 0x02  # jmp and j are aliases
        }
        
        self.labels = {}  # Label name -> address mapping
        
    def parse_register(self, reg_str: str) -> int:
        """Parse register string and return register number."""
        reg_str = reg_str.strip()
        if reg_str in self.registers:
            return self.registers[reg_str]
        raise ValueError(f"Invalid register: {reg_str}")
    
    def parse_immediate(self, imm_str: str) -> int:
        """Parse immediate value (supports decimal, hex with 0x prefix)."""
        imm_str = imm_str.strip()
        if imm_str.startswith('0x') or imm_str.startswith('0X'):
            return int(imm_str, 16)
        elif imm_str.startswith('-0x') or imm_str.startswith('-0X'):
            return -int(imm_str[3:], 16)
        else:
            return int(imm_str)
    
    def parse_memory_operand(self, operand: str) -> Tuple[int, int]:
        """Parse memory operand like 'offset(reg)' and return (offset, reg_num)."""
        operand = operand.strip()
        if '(' in operand and operand.endswith(')'):
            parts = operand.split('(')
            offset_str = parts[0] if parts[0] else '0'
            reg_str = parts[1][:-1]  # Remove closing parenthesis
            offset = self.parse_immediate(offset_str)
            reg_num = self.parse_register(reg_str)
            return offset, reg_num
        else:
            raise ValueError(f"Invalid memory operand: {operand}")
    
    def encode_r_type(self, opcode: int, rs: int, rt: int, rd: int, shamt: int, funct: int) -> int:
        """Encode R-type instruction."""
        return (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct
    
    def encode_i_type(self, opcode: int, rs: int, rt: int, immediate: int) -> int:
        """Encode I-type instruction."""
        immediate = immediate & 0xFFFF  # Ensure 16-bit immediate
        return (opcode << 26) | (rs << 21) | (rt << 16) | immediate
    
    def encode_j_type(self, opcode: int, address: int) -> int:
        """Encode J-type instruction."""
        address = (address >> 2) & 0x3FFFFFF  # Word-aligned 26-bit address
        return (opcode << 26) | address
    
    def assemble_instruction(self, tokens: List[str], pc: int) -> int:
        """Assemble a single instruction from tokens."""
        if not tokens:
            raise ValueError("Empty instruction")
        
        instruction = tokens[0].lower()
        
        # R-type instructions
        if instruction in self.r_type_functs:
            funct = self.r_type_functs[instruction]
            
            # Shift instructions with immediate
            if instruction in ['sll', 'srl', 'sra', 'rol', 'ror']:
                if len(tokens) != 4:
                    raise ValueError(f"{instruction} requires 3 operands: rd, rt, shamt")
                rd = self.parse_register(tokens[1])
                rt = self.parse_register(tokens[2])
                shamt = self.parse_immediate(tokens[3])
                return self.encode_r_type(0x00, 0, rt, rd, shamt, funct)
            
            # Variable shift instructions
            elif instruction in ['sllv', 'srlv', 'srav', 'rolv', 'rorv']:
                if len(tokens) != 4:
                    raise ValueError(f"{instruction} requires 3 operands: rd, rt, rs")
                rd = self.parse_register(tokens[1])
                rt = self.parse_register(tokens[2])
                rs = self.parse_register(tokens[3])
                return self.encode_r_type(0x00, rs, rt, rd, 0, funct)
            
            # Regular 3-operand R-type instructions
            else:
                if len(tokens) != 4:
                    raise ValueError(f"{instruction} requires 3 operands: rd, rs, rt")
                rd = self.parse_register(tokens[1])
                rs = self.parse_register(tokens[2])
                rt = self.parse_register(tokens[3])
                return self.encode_r_type(0x00, rs, rt, rd, 0, funct)
        
        # I-type instructions
        elif instruction in self.i_type_opcodes:
            opcode = self.i_type_opcodes[instruction]
            
            if instruction in ['lw', 'sw']:
                if len(tokens) != 3:
                    raise ValueError(f"{instruction} requires 2 operands: rt, offset(rs)")
                rt = self.parse_register(tokens[1])
                offset, rs = self.parse_memory_operand(tokens[2])
                return self.encode_i_type(opcode, rs, rt, offset)
            
            elif instruction == 'beq':
                if len(tokens) != 4:
                    raise ValueError("beq requires 3 operands: rs, rt, label/offset")
                rs = self.parse_register(tokens[1])
                rt = self.parse_register(tokens[2])
                
                # Handle label or immediate offset
                target_str = tokens[3]
                if target_str in self.labels:
                    target_addr = self.labels[target_str]
                    offset = (target_addr - (pc + 4)) >> 2  # PC-relative, word-aligned
                else:
                    offset = self.parse_immediate(target_str)
                
                if offset < -32768 or offset > 32767:
                    raise ValueError(f"Branch target '{target_str}' is too far for beq instruction.")
                
                return self.encode_i_type(opcode, rs, rt, offset)
            
            elif instruction in ['addi', 'subi']:
                if len(tokens) != 4:
                    raise ValueError(f"{instruction} requires 3 operands: rt, rs, immediate")
                rt = self.parse_register(tokens[1])
                rs = self.parse_register(tokens[2])
                immediate = self.parse_immediate(tokens[3])
                
                # Handle subi as addi with negated immediate
                if instruction == 'subi':
                    immediate = -immediate
                
                return self.encode_i_type(opcode, rs, rt, immediate)
        
        # J-type instructions
        elif instruction in self.j_type_opcodes:
            opcode = self.j_type_opcodes[instruction]
            if len(tokens) != 2:
                raise ValueError(f"{instruction} requires 1 operand: address/label")
            
            target_str = tokens[1]
            if target_str in self.labels:
                address = self.labels[target_str]
            else:
                address = self.parse_immediate(target_str)
            
            return self.encode_j_type(opcode, address)
        
        else:
            raise ValueError(f"Unknown instruction: {instruction}")
    
    def first_pass(self, lines: List[str]) -> List[Tuple[int, List[str]]]:
        """First pass: collect labels and filter instructions."""
        instructions = []
        pc = 0
        
        for line_num, line in enumerate(lines, 1):
            # Remove comments
            line = line.split('#', 1)[0].split('//', 1)[0].strip()
            if not line:
                continue
            
            # Check for labels
            if ':' in line:
                parts = line.split(':', 1)
                label = parts[0].strip()
                self.labels[label] = pc
                
                # Check if there's an instruction after the label
                remaining = parts[1].strip()
                if remaining:
                    tokens = re.split(r'[,\s]+', remaining)
                    instructions.append((pc, tokens))
                    pc += 4
            else:
                # Regular instruction
                tokens = re.split(r'[,\s]+', line)
                instructions.append((pc, tokens))
                pc += 4
        
        return instructions
    
    def assemble_file(self, input_file: str, output_file: str, format_style: str = "full") -> None:
        """Assemble MIPS assembly file to machine code.
        
        Args:
            input_file: Path to input assembly file
            output_file: Path to output hex file
            format_style: Output format style
                - "full": Include PC, machine code, and original instruction
                - "pc": Include PC and machine code only
                - "clean": Machine code only (no comments)
        """
        try:
            with open(input_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # First pass: collect labels
            instructions = self.first_pass(lines)
            
            # Second pass: assemble instructions
            machine_code = []
            for pc, tokens in instructions:
                try:
                    code = self.assemble_instruction(tokens, pc)
                    # Format instruction text with proper MIPS syntax (commas between operands)
                    if len(tokens) > 1:
                        instruction_text = tokens[0] + ' ' + ', '.join(tokens[1:])
                    else:
                        instruction_text = tokens[0]
                    machine_code.append((f"{code:08X}", pc, instruction_text))
                except Exception as e:
                    print(f"Error at PC {pc:08X} with instruction {' '.join(tokens)}: {e}")
                    sys.exit(1)
            
            # Write output based on format style
            with open(output_file, 'w', encoding='utf-8') as f:
                if format_style != "clean":
                    f.write("// MIPS Machine Code\n")
                    f.write("// Generated by MIPS Assembler\n")
                    f.write("\n")
                
                # Calculate maximum instruction length for alignment
                max_instruction_len = 0
                if format_style == "full":
                    max_instruction_len = max(len(instruction) for _, _, instruction in machine_code)
                
                for hex_code, pc, instruction in machine_code:
                    if format_style == "full":
                        # Pad instruction to align PC addresses
                        padded_instruction = instruction.ljust(max_instruction_len)
                        f.write(f"{hex_code}  // {padded_instruction} | PC: {pc:08X}\n")
                    elif format_style == "pc":
                        f.write(f"{hex_code}  // PC: {pc:08X}\n")
                    elif format_style == "clean":
                        f.write(f"{hex_code}\n")
                    else:
                        # Default to full format
                        padded_instruction = instruction.ljust(max_instruction_len)
                        f.write(f"{hex_code}  // {padded_instruction} | PC: {pc:08X}\n")
            
            print(f"Assembly successful! Generated {len(machine_code)} instructions.")
            print(f"Output written to: {output_file}")
            print(f"Format style: {format_style}")
            
        except FileNotFoundError:
            print(f"Error: Input file '{input_file}' not found.")
            sys.exit(1)
        except Exception as e:
            print(f"Error: {e}")
            sys.exit(1)

def main():
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print("Usage: python assembler.py <input.asm> <output.hex> [format]")
        print("Example: python assembler.py test.asm test.hex")
        print("Format options:")
        print("  full  - Include PC, machine code, and original instruction (default)")
        print("  pc    - Include PC and machine code only")
        print("  clean - Machine code only (no comments)")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    format_style = sys.argv[3] if len(sys.argv) == 4 else "full"
    
    if format_style not in ["full", "pc", "clean"]:
        print(f"Error: Unknown format '{format_style}'. Use 'full', 'pc', or 'clean'.")
        sys.exit(1)
    
    assembler = MIPSAssembler()
    assembler.assemble_file(input_file, output_file, format_style)

if __name__ == "__main__":
    main()

