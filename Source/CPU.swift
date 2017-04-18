//
//  CPU.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-17.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation

// The flags
let FLAG_C = 0x01
let FLAG_N = 0x02
let FLAG_P = 0x04
let FLAG_V = FLAG_P
let FLAG_3 = 0x08
let FLAG_H = 0x10
let FLAG_5 = 0x20
let FLAG_Z = 0x40
let FLAG_S = 0x80

let SHIFT_0xCB = 256
let SHIFT_0xED = 512
let SHIFT_0xDD = 768
let SHIFT_0xDDCB = 1024
let SHIFT_0xFDCB = 1024
let SHIFT_0xFD = 1280

func splitWord(_ word : uint16) -> [UInt8] {
    return [UInt8(word >> 8), UInt8(word & 0xff)]
}

func joinBytes(_ h : UInt8, _ l : UInt8) -> uint16 {
    return uint16(l) | (uint16(h) << 8)
}

struct register16 {
    var high : &UInt8
    var low : &UInt8
    
    mutating func inc() {
        var temp = get() + 1
        high = UInt8(temp >> 8)
        low = UInt8(temp & 0xff)
    }
    
    mutating func dec() {
        var temp = get() - 1
        high = UInt8(temp >> 8)
        low = UInt8(temp & 0xff)
    }
    
    mutating func set(value : uint16) {
        high = splitWord(value)[0]
        low = splitWord(value)[1]
    }
    
    func get() -> uint16 {
        return joinBytes(high, low)
    }
}

struct Z80 {
    var A, F, B, C, D, E, H, L        : UInt8
    var A_, F_, B_, C_, D_, E_, H_, L_ : UInt8
    var IXH, IXL, IYH, IYL             : UInt8
    var I, IFF1, IFF2, IM              : UInt8
    
    // The highest bit (bit 7) of the R register
    var R7 : UInt8
    
    // The low 7 bits of the R register. 16 bits long so it can
    // also act as an RZX instruction counter.
    var R : uint16
    
    var sp, pc : uint16
    
    var bc, bc_, hl, hl_, af, de, de_, ix, iy : register16
    
    var EventNextEvent : Int
    
    // Number of tstates since the beginning of the last frame.
    // The value of this variable is usually smaller than TStatesPerFrame,
    // but in some unlikely circumstances it may be >= than that.
    var Tstates : Int
    
    var Halted : Bool
    
    // Needed when executing opcodes prefixed by 0xCB
    var  tempaddr : uint16
    
    var interruptsEnabledAt : Int
    
    var memory : Memory
    var ports : Port
    
    var rzxInstructionsOffset : Int
}

