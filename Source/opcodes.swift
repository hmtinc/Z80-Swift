//
//  opcodes.swift
//  Z80-Swift
//
//  Created by Harsh Mistry on 2017-12-19.
//  Copyright © 2017 Harsh Mistry. All rights reserved.
//

import Foundation


//Parse Regular Opcodes
func regularOpcodes(_ opCode : uint8,
                    _ hiByte : uint8,
                    _ loByte : uint8,
                    _ rByte : uint8,
                    _ iff1 : inout Bool,
                    _ iff2 : inout Bool,
                    _ halt : inout Bool,
                    _ registers : inout [uint8],
                    _ mem : inout [uint8],
                    _ ports : inout Ports){
    
    let r = Int(rByte)
    let lo = Int(loByte)
    let hi = Int(hiByte)
    
    switch (opCode) {
    case 0x01, 0x11, 0x21:
        //LD dd, nn
        registers[r + 1] = fetch(&registers, &mem)
        registers[r] = fetch(&registers, &mem)
        stallCpu(10, &registers)
    case 0x31 :
        //LD SP, nn
        registers[SP + 1] = fetch(&registers, &mem)
        registers[SP] = fetch(&registers, &mem)
        stallCpu(10, &registers)
    case 0x06, 0x0e, 0x16, 0x1e, 0x26, 0x2e, 0x3e:
        //Ld r, n
        registers[r] = fetch(&registers, &mem)
    case 0x36 :
        //LD (HL) , n
        mem[Int(Hl(registers))] = fetch(&registers, &mem)
        stallCpu(10, &registers)
    case 0x0A :
        //LD A , (BC)
        registers[A] = mem[Int(Bc(registers))]
        stallCpu(7, &registers)
    case 0x1A:
        //LD A, (DE)
        registers[A] = mem[Int(De(registers))]
        stallCpu(7, &registers)
    case 0x3A:
        //LD A, (nn)
        registers[A] = mem[Int(fetch16(&registers, &mem))]
        stallCpu(13, &registers)
    case 0x02:
        //LD (BC), A
        mem[Int(Bc(registers))] = registers[A]
        stallCpu(7, &registers)
    case 0x12:
        //LD (DE), A
        mem[Int(De(registers))] = registers[A]
        stallCpu(7, &registers)
    case 0x32:
        //LD (nn), A
        mem[Int(fetch16(&registers, &mem))] = registers[A]
        stallCpu(13, &registers)
    case 0x2A:
        //LD HL, (nn)
        var address = Int(fetch16(&registers, &mem))
        registers[L] = mem[address]
        address = address + 1
        registers[H] = mem[address]
        stallCpu(16, &registers)
    case 0x22:
        //LD nn, HL
        var address = Int(fetch16(&registers, &mem))
        mem[address] = registers[L]
        address = address + 1
        mem[address] = registers[H]
        stallCpu(16, &registers)
    case 0xF9:
        //LD SP, HL
        registers[SP + 1] = registers[L]
        registers[SP]  = registers[H]
        stallCpu(6, &registers)
    case 0xC5:
        pushPairSp(B, C, &registers, &mem)
    case 0xD5:
        //Push DE
        pushPairSp(D, E, &registers, &mem)
    case 0xE5:
        //Push HL
        pushPairSp(H, L, &registers, &mem)
    case 0xF5:
        //Push AF
        pushPairSp(A, F, &registers, &mem)
    case 0xC1:
        //Pop BC
        popPairSp(B, C, &registers, &mem)
    case 0xD1:
        //Pop DE
        popPairSp(D, E, &registers, &mem)
    case 0xE1:
        //POP HL
        popPairSp(H, L, &registers, &mem)
    case 0xF1:
        //POP AF
        popPairSp(A, F, &registers, &mem)
    case 0xEB:
        //EX DE, HL
        swapRegisters(D, H, &registers)
        swapRegisters(E, L, &registers)
        stallCpu(4, &registers)
    case 0x08:
        //EX DE, HL
        swapRegisters(Ap, A, &registers)
        swapRegisters(Fp, F, &registers)
        stallCpu(4, &registers)
    case 0xD9:
        //EXX
        swapRegisters(B, Bp, &registers)
        swapRegisters(C, Cp, &registers)
        swapRegisters(D, Dp, &registers)
        swapRegisters(E, Ep, &registers)
        swapRegisters(H, Hp, &registers)
        swapRegisters(L, Lp, &registers)
        stallCpu(4, &registers)
    case 0xE3:
        //EX (SP), HL
        var address = Int(Sp(registers))
        var temp = registers[L]
        registers[L] = mem[address]
        mem[address] = temp
        address += 1
        
        temp = registers[H]
        registers[H] = mem[address]
        mem[address] = temp
        stallCpu(19, &registers)
    case 0x80, 0x81,0x82, 0x83, 0x84, 0x85, 0x87:
        //ADD A, r
        add(registers[lo], &registers)
    case 0xC6:
        //Add A, n
        add(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
        stallCpu(4, &registers)
    case 0x86:
        //Add A, (HL)
        add(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0x87, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8F :
        //ADC A, r
        adc(registers[lo], &registers)
        stallCpu(4, &registers)
    case 0xCE :
        //ADC A, n
        adc(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
    case 0x8E:
        //ADC A, (AL)
        adc(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x97 :
        //SUB A, r
        sub(registers[lo], &registers)
    case 0xD6:
        //Add A, n
        sub(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
    case 0x96:
        //SUB A, (HL)
        sub(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9F:
        //SBC A, r
        sbc(registers[lo], &registers)
        stallCpu(4, &registers)
    case 0xDE:
        //SBC A, n
        sbc(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
    case 0x9E :
        //SBC A, (HL)
        adc(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA7 :
        //AND A, r
        and(registers[lo], &registers)
    case 0xE6 :
        //And A, n
        and(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
    case 0xA6 :
        //AND A, (HL)
        and(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB7 :
        //Or A, r
        or(registers[lo], &registers)
        stallCpu(4, &registers)
    case 0xF6 :
        //Or A, n
        or(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
    case 0xB6 :
        //Or A, (HL)
        or(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAF:
        //XOR A, r
        xor(registers[lo], &registers)
    case 0xEE :
        //XOR A, n
        xor(uint8(fetch(&registers, &mem)), &registers)
        stallCpu(4, &registers)
    case 0xAE :
        //XOR A, (HL)
        xor(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0xF3:
        //DI
        iff1 = false
        iff2 = false
        stallCpu(4, &registers)
    case 0xFB :
        //EI
        iff1 = true
        iff2 = true
        stallCpu(4, &registers)
    case 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBF:
        //CP A, r
        Cmp(registers[lo], &registers)
        stallCpu(4, &registers)
    case 0xBE :
        //CP A, (HL)
        Cmp(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0x04, 0x0C, 0x14, 0x1C, 0x24, 0x2C, 0x3C:
        //INC r
        registers[r] = Inc(registers[r], &registers)
        stallCpu(4, &registers)
    case 0x34:
        //Inc (HL)
        mem[Int(Hl(registers))] = Inc(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0x05, 0x0d, 0x15, 0x1D, 0x25, 0x2D, 0x3D:
        //DEC r
        registers[r] = dec(registers[r], &registers)
        stallCpu(4, &registers)
    case 0x35:
        //DEC (HL)
        mem[Int(Hl(registers))] = dec(mem[Int(Hl(registers))], &registers)
        stallCpu(7, &registers)
    case 0x27:
        //DAA
        var a = registers[A]
        let f = registers[F]
        if((a & 0x0F) > 0x09 || (f & uint8(Fl.H.rawValue)) > 0){
            add(0x06, &registers)
            a = registers[A]
        }
        if((a & 0xF0) > 0x09 || (f & uint8(Fl.C.rawValue)) > 0){
            add(0x06, &registers)
        }
        stallCpu(4, &registers)
    case 0x2F:
        //CPL
        registers[A] ^= 0xFF
        registers[F] |= uint8(Fl.H.rawValue | Fl.N.rawValue)
        stallCpu(4, &registers)
    case 0x3F:
        //CCF
        registers[F] &= ~uint8(Fl.N.rawValue)
        registers[F] ^= uint8(Fl.C.rawValue)
        stallCpu(4, &registers)
    case 0x37 :
        //SCF
        registers[F] &= ~uint8(Fl.N.rawValue)
        registers[F] |= uint8(Fl.C.rawValue)
        stallCpu(4, &registers)
    case 0x09 :
        //ADD HL, BC
        addHl(Bc(registers), &registers)
        stallCpu(4, &registers)
    case 0x19 :
        //ADD HL, DE
        addHl(De(registers), &registers)
        stallCpu(4, &registers)
    case 0x29 :
        //ADD HL, HL
        addHl(Hl(registers), &registers)
        stallCpu(4, &registers)
    case 0x39 :
        //ADD HL, SP
        addHl(Sp(registers), &registers)
        stallCpu(4, &registers)
    case 0x03:
        //INC BC
        let val = Bc(registers) + 1
        registers[B] = uint8(val >> 8)
        registers[C] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x13:
        //INC DE
        let val = De(registers) + 1
        registers[D] = uint8(val >> 8)
        registers[E] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x23 :
        //INC HL
        let val = Hl(registers) + 1
        registers[H] = uint8(val >> 8)
        registers[L] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x33 :
        //INC SP
        let val = Sp(registers) + 1
        registers[SP] = uint8(val >> 8)
        registers[SP + 1] = uint8(val & 0xFF)
        stallCpu(4, &registers)
        
    case 0x0B:
        //DEC BC
        let val = Bc(registers) - 1
        registers[B] = uint8(val >> 8)
        registers[C] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x1B:
        //DEC DE
        let val = De(registers) - 1
        registers[D] = uint8(val >> 8)
        registers[E] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x2B :
        //DEC HL
        let val = Hl(registers) - 1
        registers[H] = uint8(val >> 8)
        registers[L] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x3B :
        //DEC SP
        let val = Sp(registers) - 1
        registers[SP] = uint8(val >> 8)
        registers[SP + 1] = uint8(val & 0xFF)
        stallCpu(4, &registers)
    case 0x07:
        //RLCA
        var a = registers[A]
        let c = uint8((a & 0x80) >> 7)
        a <<= 1
        registers[A] = a
        registers[F] &= uint8(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue))
        registers[F] |= c
        stallCpu(4, &registers)
    case 0x0F:
        //RRCA
        var a = registers[A]
        let c = uint8(a & 0x01)
        a >>= 1
        registers[A] = a
        registers[F] &= uint8(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue))
        registers[F] |= c
        stallCpu(4, &registers)
    case 0x1F :
        //RRA
        var a = registers[A]
        let c = uint8(a & 0x01)
        a >>= 1
        var f = registers[F]
        a |= uint8((f & uint8(Fl.C.rawValue)) << 7)
        registers[A] = a
        f &= uint8(~(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue))
        f |= c
        registers[F] = f
        stallCpu(4, &registers)
    case 0xC3:
        //JP
        let addr = fetch16(&registers, &mem)
        registers[PC] = uint8(addr >> 8)
        registers[PC + 1] = uint8(addr)
        stallCpu(10, &registers)
    case 0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA:
        //JP with condition
        let addr = fetch16(&registers, &mem)
        if(jumpCond(rByte, &registers)){
            registers[PC] = uint8(addr >> 8)
            registers[PC + 1] = uint8(addr)
        }
        stallCpu(10, &registers)
    case 0x18 :
        let d = Int8(fetch(&registers, &mem))
        let addr = Int(Pc(registers)) + Int(d)
        registers[PC] = uint8(addr >> 8)
        registers[PC + 1] = uint8(addr)
        stallCpu(12, &registers)
    case 0x20, 0x28, 0x30, 0x38 :
        //JR with condition
        let d = Int8(fetch(&registers, &mem))
        let addr = Int(Pc(registers)) + Int(d)
        if(jumpCond(uint8(r & 3), &registers)){
            registers[PC] = uint8(addr >> 8)
            registers[PC + 1] = uint8(addr)
            stallCpu(12, &registers)
        }
        else {
            stallCpu(7, &registers)
        }
    case 0xE9:
        //JP HL
        let addr = Hl(registers)
        registers[PC] = uint8(addr >> 8)
        registers[PC + 1] = uint8(addr)
        stallCpu(4, &registers)
    case 0x10:
        //DJNZ
        let d = Int8(fetch(&registers, &mem))
        let addr = Int(Pc(registers)) + Int(d)
        var b = registers[B]
        b -= 1
        registers[B] = b
        if(b != 0){
            registers[PC] = uint8(addr >> 8)
            registers[PC + 1] = uint8(addr)
            stallCpu(12, &registers)
        }
        else {
            stallCpu(8, &registers)
        }
    case 0xCD:
        //CALL
        let addr = fetch16(&registers, &mem)
        var stack = Sp(registers)
        stack -= 1
        mem[Int(stack)] = uint8(Pc(registers) >> 8)
        stack -= 1
        mem[Int(stack)] = uint8(Pc(registers))
        registers[SP] = uint8(stack >> 8)
        registers[SP + 1] = uint8(stack)
        registers[PC] = uint8(addr >> 8)
        registers[PC + 1] = uint8(addr)
        stallCpu(17, &registers)
    case 0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC:
        //Call with condition
        let addr = fetch16(&registers, &mem)
        if(jumpCond(rByte, &registers)){
            var stack = Sp(registers)
            stack -= 1
            mem[Int(stack)] = uint8(Pc(registers) >> 8)
            stack -= 1
            mem[Int(stack)] = uint8(Pc(registers))
            registers[SP] = uint8(stack >> 8)
            registers[SP + 1] = uint8(stack)
            registers[PC] = uint8(addr >> 8)
            registers[PC + 1] = uint8(addr)
            stallCpu(17, &registers)
        }else {
            stallCpu(10, &registers)
        }
    case 0xC9:
        //Return
        var stack = Sp(registers)
        registers[PC + 1] = mem[Int(stack)]
        stack += 1
        registers[PC] = mem[Int(stack)]
        registers[SP] = uint8(stack >> 8)
        registers[SP + 1] = uint8(stack)
        stallCpu(10, &registers)
    case 0xC0, 0xC8, 0xD0, 0xD8, 0xE0, 0xE8, 0xF0, 0xF8 :
        //Return with condition
        if(jumpCond(rByte, &registers)){
            var stack = Sp(registers)
            registers[PC + 1] = mem[Int(stack)]
            stack += 1
            registers[PC] = mem[Int(stack)]
            registers[SP] = uint8(stack >> 8)
            registers[SP + 1] = uint8(stack)
            stallCpu(11, &registers)
        }
        else {
            stallCpu(5, &registers)
        }
    case 0xC7, 0xCF, 0xD7, 0xDF, 0xE7, 0xEF, 0xF7, 0xFF:
        //RST
        var stack = Sp(registers)
        stack -= 1
        mem[Int(stack)] = uint8(Pc(registers) >> 8)
        stack -= 1
        mem[Int(stack)] = uint8(Pc(registers))
        registers[SP] = uint8(stack >> 8)
        registers[SP + 1] = uint8(stack)
        registers[PC] = 0
        registers[PC + 1] = uint8(opCode & 0x38)
        stallCpu(17, &registers)
    case 0xDB :
        //In A
        let port = fetch(&registers, &mem) + (registers[A] << 8)
        registers[A] = ports.readPort(uint16(port))
        stallCpu(11, &registers)
    case 0xD3:
        //Out
        //In A
        let port = fetch(&registers, &mem) + (registers[A] << 8)
        ports.writePort(uint16(port), registers[A])
        stallCpu(11, &registers)
    default :
        print("ERROR : Regular Parse Failed")
        halt = true
        
    }
    
    

}
