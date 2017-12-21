//
//  macros.swift
//  Z80-Swift
//
//  Created by Harsh Mistry on 2017-12-15.
//  Copyright © 2017 Harsh Mistry. All rights reserved.

//

import Foundation

enum Fl : uint8
{
    case C = 0x01
    case N = 0x02
    case PV = 0x04
    case H = 0x10
    case Z = 0x40
    case S = 0x80
    case None = 0x00
    case All = 0xD7
}

//Register References
let B = 0, C = 1, D = 2, E = 3, H = 4, L = 5, F = 6, A = 7, Bp = 8
let Cp = 9, Dp = 10, Ep = 11, Hp = 12, Lp = 13, Fp = 14, Ap = 15
let I = 16, R = 17, IX = 18, IY = 20, SP = 22, PC = 24

//16 Bit Registers
func Hl (_ registers : [UInt8] ) -> UInt16 { return  UInt16(registers[L] + (registers[H] << 8))}
func Sp (_ registers : [UInt8] ) -> UInt16 { return  UInt16(registers[SP + 1] + (registers[SP] << 8))}
func Ix (_ registers : [UInt8] ) -> UInt16 { return  UInt16(registers[IX + 1] + (registers[IX] << 8))}
func Iy (_ registers : [UInt8] ) -> UInt16 { return  UInt16(registers[IY + 1] + (registers[IY] << 8))}
func Bc (_ registers : [UInt8] ) -> UInt16 { return  UInt16((registers[B] << 8) + registers[C] )}
func De (_ registers : [UInt8] ) -> UInt16 { return  UInt16((registers[D] << 8) + registers[E] )}
func Pc (_ registers : [UInt8] ) -> UInt16 { return  UInt16(registers[PC + 1] + (registers[PC] << 8))}

//Helper functions
func swapRegisters(_ r1 : Int, _ r2 : Int, _ registers : inout [uint8] ){
    let temp = registers[r1]
    registers[r1] = registers[r2]
    registers[r2] = temp
}

func fetch(_ registers : inout [uint8], _ mem : inout [uint8]) -> uint8 {
    var pc = Pc(registers)
    let returnVal = mem[Int(pc)]
    pc = pc + 1
    registers[PC] = uint8(pc >> 8)
    registers[PC + 1] = uint8(pc & 0xFF)
    return returnVal
}

func fetch16(_ registers : inout [uint8], _ mem : inout [uint8]) -> uint16 {
    return uint16(fetch(&registers, &mem) + (fetch(&registers, &mem) << 8))
}

func jumpCond(_ condition : uint8, _ registers : inout [uint8] ) -> Bool{
    var value : uint8
    let cond = condition & 0xFE
    
    switch (cond){
    case 0 :
        value = Fl.Z.rawValue
    case 2 :
        value = Fl.C.rawValue
    case 4 :
        value = Fl.PV.rawValue
    case 6 :
        value = Fl.S.rawValue
    default :
        return false
    }
    
    return ((registers[F] & value) > 0) == ((condition & 1) == 1)
}

func Parity(_ val : uint16, _ registers : inout [uint8]) -> Bool{
    var parity = true;
    var tempVal = val;
    while (tempVal > 0){
        if ((tempVal & 1) == 1) { parity = !parity}
        tempVal = tempVal >> 1
    }
    return parity
}

func dec(_ b : uint8, _ registers : inout [uint8]) -> UInt8 {
    let sum = b &- 1
    var f = uint8(registers[F] & 0x28)
    if((sum & 0x80) > 0) {f = UInt8(f | 0x80)}
    if(sum == 0) {f = UInt8(f | 0x40)}
    if((b & 0x0F) == 0) {f = UInt8(f | 0x10)}
    if(b == 0x80) {f = UInt8(f | 0x04)}
    f = uint8(f | 0x02)
    registers[F] = f
    
    return UInt8(sum)
}

func Inc(_ b : uint8, _ registers : inout [uint8]) -> UInt8 {
    let sum = b &+ 1
    var f = uint8(registers[F] & 0x28)
    if((sum & 0x80) > 0) {f = UInt8(f | 0x80)}
    if(sum == 0) {f = UInt8(f | 0x40)}
    if((b & 0x0F) == 0) {f = UInt8(f | 0x10)}
    if(b == 0x80) {f = UInt8(f | 0x04)}
    f = uint8(f | 0x02)
    if(sum > 0xFF) { f = UInt8(f | 0x01)}
    registers[F] = f
    return UInt8(sum)
}

func Cmp(_ b : uint8, _ registers : inout [uint8]){
    
    let a = registers[A]
    let diff = a &- b
    var f = UInt8(registers[F] & 0x28)
    if ((diff & 0x80) > 0) { f = UInt8(f | 0x80)}
    if (diff == 0) { f = UInt8(f | 0x40) }
    if ((a & 0xF) < (b & 0xF)){ f = UInt8(f | 0x10)}
    if ((a > 0x80 && b > 0x80 && diff > 0) || (a < 0x80 && b < 0x80 && diff < 0)){f = UInt8(f | 0x04)}
    f = UInt8(f | 0x02)
    if (diff > 0xFF){ f = UInt8(f | 0x01) }
    registers[F] = f
}

func xor(_ b : uint8, _ registers : inout [uint8]) {
    let a = registers[A];
    let res = a ^ b
    registers[A] = res
    var f = uint8(registers[F] & 0x28)
    if((res & 0x80) > 0) {f |= UInt8(Fl.S.rawValue)}
    if(res == 0) {f |= UInt8(Fl.Z.rawValue)}
    if(Parity(uint16(res), &registers)) {f |= UInt8(Fl.PV.rawValue)}
    registers[F] = f
}

func or(_ b : uint8, _ registers : inout [uint8]) {
    let a = registers[A];
    let res = UInt8(a | b)
    registers[A] = res
    var f = uint8(registers[F] & 0x28)
    if((res & 0x80) > 0) {f |= UInt8(Fl.S.rawValue)}
    if(res == 0) {f |= UInt8(Fl.Z.rawValue)}
    if(Parity(uint16(res), &registers)) {f |= UInt8(Fl.PV.rawValue)}
    registers[F] = f
}

func and(_ b : uint8, _ registers : inout [uint8]) {
    let a = registers[A];
    let res = UInt8(a & b)
    registers[A] = res
    var f = uint8(registers[F] & 0x28)
    if((res & 0x80) > 0) {f |= UInt8(Fl.S.rawValue)}
    if(res == 0) {f |= UInt8(Fl.Z.rawValue)}
    f |= uint8(Fl.H.rawValue)
    if(Parity(uint16(res), &registers)) {f |= UInt8(Fl.PV.rawValue)}
    registers[F] = f
}

func sbc (_ b : uint8, _ registers : inout [uint8]){
    let a = registers[A]
    let c = uint8(registers[F] & 0x01)
    let diff = a &- b &- c
    var f = uint8(registers[F] & 0x28)
    if((diff & 0x80) > 0) {f |= uint8(Fl.S.rawValue)}
    if(diff == 0) {f |= UInt8(Fl.Z.rawValue)}
    if((a & 0xF) < (b & 0xF) + c) {f |= UInt8(Fl.H.rawValue)}
    if((a >= 0x80 && b >= 0x80 && diff > 0) || ( a < 0x80 && b < 0x80 && diff < 0)) {
        f |= UInt8(Fl.PV.rawValue)
    }
    f |= uint8(Fl.N.rawValue)
    if(diff > 0xFF) { f |= UInt8(Fl.C.rawValue)}
    registers[F] = f
}

func sub (_ b : uint8, _ registers : inout [uint8]){
    let a = registers[A]
    let diff = a &- b
    var f = uint8(registers[F] & 0x28)
    if((diff & 0x80) > 0) {f |= uint8(Fl.S.rawValue)}
    if(diff == 0) {f |= UInt8(Fl.Z.rawValue)}
    if((a & 0xF) < (b & 0xF)) {f |= UInt8(Fl.H.rawValue)}
    if((a >= 0x80 && b >= 0x80 && diff > 0) || ( a < 0x80 && b < 0x80 && diff < 0)) {
        f |= UInt8(Fl.PV.rawValue)
    }
    f |= uint8(Fl.N.rawValue)
    if(diff > 0xFF) { f |= UInt8(Fl.C.rawValue)}
    registers[F] = f
}

func adc (_ b : uint8, _ registers : inout [uint8]){
    let a = registers[A]
    let c = uint8(registers[F] & Fl.C.rawValue)
    let diff = a &+ b &+ c
    var f = uint8(registers[F] & 0x28)
    if((diff & 0x80) > 0) {f |= uint8(Fl.S.rawValue)}
    if(diff == 0) {f |= UInt8(Fl.Z.rawValue)}
    if((a & 0xF + b & 0xF) > 0xF) {f |= UInt8(Fl.H.rawValue)}
    if((a >= 0x80 && b >= 0x80 && diff > 0) || ( a < 0x80 && b < 0x80 && diff < 0)) {
        f |= UInt8(Fl.PV.rawValue)
    }
    f = uint8(f & ~uint8(Fl.N.rawValue))
    if(diff > 0xFF) { f |= UInt8(Fl.C.rawValue)}
    registers[F] = f
}

func add (_ b : uint8, _ registers : inout [uint8]){
    let a = registers[A]
    let diff = a &+ b
    registers[A] = uint8(diff)
    var f = uint8(registers[F] & 0x28)
    if((diff & 0x80) > 0) {f |= uint8(Fl.S.rawValue)}
    if(diff == 0) {f |= UInt8(Fl.Z.rawValue)}
    if((a & 0xF + b & 0xF) > 0xF) {f |= UInt8(Fl.H.rawValue)}
    if((a >= 0x80 && b >= 0x80 && diff > 0) || ( a < 0x80 && b < 0x80 && diff < 0)) {
        f |= UInt8(Fl.PV.rawValue)
    }
    if(diff > 0xFF) { f |= UInt8(Fl.C.rawValue)}
    registers[F] = f
}

func add(_ val1 : uint16, _ val2 : uint16, _ registers : inout [uint8]) -> uint16 {
    let sum = val1 &+ val2
    var f = uint8(registers[F] & uint8(Fl.H.rawValue | Fl.N.rawValue | Fl.C.rawValue))
    if ((val1 & 0x0FFF) + (val2 & 0x0FFF) > 0x0FFF){
        f |= uint8(Fl.H.rawValue)
    }
    if(sum > 0xFFFF){
        f |= uint8(Fl.C.rawValue)
    }
    registers[F] = f
    return uint16(sum)
}

func addHl (_ val : uint16, _ registers : inout [uint8]){
    let sum = add(Hl(registers), val, &registers)
    registers[H] = uint8(sum >> 8)
    registers[L] = uint8(sum & 0xFF)
}




func stallCpu(_ time : Int, _ registers : inout [uint8]) {
    let oneTick = 0.25
    let sleepTime = oneTick * Double(time)
    registers[R] = uint8((time + 3) / 4)
    usleep(uint32(sleepTime))
}

func pushPairSp(_ reg1 : Int, _ reg2 : Int, _ registers : inout [uint8], _ mem : inout [uint8]){
    var address = Int(Sp(registers))
    address -= 1
    mem[address] = registers[reg1]
    address -= 1
    mem[address] = registers[reg2]
    registers[SP + 1] = uint8(address & 0xFF)
    registers[SP] = uint8(address >> 8)
    stallCpu(11, &registers)
}

func popPairSp(_ reg1 : Int, _ reg2 : Int, _ registers : inout [uint8], _ mem : inout [uint8]){
    var address = Int(Sp(registers))
    registers[reg2] = mem[address]
    address += 1
    registers[reg1] = mem[address]
    address += 1
    registers[SP + 1] = uint8(address & 0xFF)
    registers[SP] = uint8(address >> 8)
    stallCpu(10, &registers)
}
