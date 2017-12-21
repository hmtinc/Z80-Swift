//
//  z80.swift
//  Z80-Swift
//
//  Created by Harsh Mistry on 2017-12-15.
//  Copyright © 2017 Harsh Mistry. All rights reserved.
//

import Foundation


class CPU {
    var registers = Array(repeating: UInt8(0), count: 26)
    
    //Flags
    var iff1 : Bool = false
    var iff2 : Bool = false
    var stall : Bool = false
    var halt : Bool = false
    var debug : Bool = false
    var mode : Int = 0
    var ports = Ports()
    var mem : [UInt8]
    
    
    func printRegisters (){
        let registerNames : [String] = ["B", "C", "D", "E", "H", "L", "F", "A", "Bp", "Cp", "Dp",
                                        "Ep", "Hp", "LP", "Fp", "Ap", "I", "R", "IX", "IX + 1",
                                        "IY", "IY + 1", "SP", "SP + 1", "PC", "PC + 1"]
        
        print("")
        print("-----------Start------------");
        print("----------------------------");
        for i in 0..<registerNames.count {
            print(registerNames[i] + " : " + String(registers[i]))
        }
        print("-------------End-------------");
        print("-----------------------------");
    }
    
    init(rom : [uint8]) {
        mem = rom
    }
    
    func invalidOpCode(_ code : Int) {
        print("Invalid Opcode : " + String(code))
    }
    
    //Reset the CPU
    func reset() {
        registers = Array(repeating: UInt8(0), count: 26);
        registers[A] = 0xFF
        registers[SP] = 0xFF
        registers[SP] = 0xFF
        registers[SP + 1] = 0xFF
        iff1 = false
        iff2 = false
    }
    
    //Parse 1 opcode
    func parse() {
        if(ports.NMI){
            var stack = Sp(registers)
            stack = stack - 1
            mem[Int(stack)] = uint8(Pc(registers) >> 8);
            stack = stack - 1
            mem[Int(stack)] = uint8(Pc(registers));
            registers[SP] = uint8(stack >> 8)
            registers[SP + 1] = uint8(stack)
            registers[PC] = 0x00
            registers[PC + 1] = 0x66
            iff1 = iff2
            iff1 = false
            stallCpu(17, &registers)
            halt = true
            return
        }
        
        //Refuse to parse if halt is true
        if(halt) {return}
        
        //Obtain instruction
        let mc = fetch(&registers, &mem)
        let hi = UInt8(mc >> 6)
        let lo = UInt8(mc & 0x07)
        let r = UInt8((mc >> 3) & 0x07)
        
        if(hi == 1) {
            let useHL1 = r == 6
            let useHL2 = lo == 6
            if (useHL1 && useHL2){
                halt = true
                return;
            }
            
            let reg = useHL2 ? mem[Int(Hl(registers))] : registers[Int(lo)]
            if (useHL1) {
                mem[Int(Hl(registers))] = reg
            }
            else {
                registers[Int(r)] = reg
            }
            stallCpu(useHL1 || useHL2 ? 7 : 4, &registers)
            return
        }
        
        //Parse Op Code
        switch (mc) {
        case 0xCB:
            invalidOpCode(Int(mc))
        case 0xDD:
            invalidOpCode(Int(mc))
        case 0xED:
            invalidOpCode(Int(mc))
        case 0xFD:
            invalidOpCode(Int(mc))
        case 0x00:
            //Nop
            stallCpu(4, &registers)
        default:
            regularOpcodes(mc, hi, lo, r, &iff1, &iff2, &halt, &registers, &mem, &ports)
        }
        
        if(debug) {
            printRegisters()
        }
        
    }
    
}
