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


//Registers
var intArr : [UInt8] = [0,0,0,0,0,0,0,0 0,0,0,0,0,0,0,0, 0, 0, 0, 0, 0, 0, 0, 0]

var A = 0, F = 1, B = 2, C =  3, D = 4, E = 5, H = 6, L = 7
var A_ = 8, F_ = 9, B_ = 10, C_ =  11, D_ = 12, E_ = 13, H = 14, L = 15
var IXH = 16, IXL = 17, IYH = 18, IYL = 19
var  I = 20, IFF1 = 21, IFF2 = 22, IM = 23   

var bc = register16(B, C) 
var bc_ = register16(B_ , C_)
var hl = register16(H, L)
var hl_ = register16(H_ , L_)
var af = register16(A, F)
var de = register16(D, E)
var ix = register16(IXH, IYL)
var de_ = register16(D_ E_)

// The highest bit (bit 7) of the R register
var R7 : UInt8 

// The low 7 bits of the R register. 16 bits long so it can
// also act as an RZX instruction counter.
var R : uint16 
    
var sp, pc : uint16 
       
var EventNextEvent : Int 
    
// Number of tstates since the beginning of the last frame.
// The value of this variable is usually smaller than TStatesPerFrame,
 // but in some unlikely circumstances it may be >= than that.
var Tstates : Int
    
var Halted : Bool
    
// Needed when executing opcodes prefixed by 0xCB
var  tempaddr : uint16
    
var interruptsEnabledAt : Int
    
var rzxInstructionsOffset : Int

func splitWord(_ word : uint16) -> [UInt8] {
    return [UInt8(word >> 8), UInt8(word & 0xff)]
}

func joinBytes(_ h : UInt8, _ l : UInt8) -> uint16 {
    return uint16(l) | (uint16(h) << 8)
}

struct register16 {
    var high : Int
    var low : Int

    mutating func inc() {
        var temp = get() + 1
        intArr[high] = UInt8(temp >> 8)
        intArr[low] = UInt8(temp & 0xff)
    }
    
    mutating func dec() {
        var temp = get() - 1
        intArr[high] = UInt8(temp >> 8)
        intArr[low]= UInt8(temp & 0xff)
    }
    
    mutating func set(value : uint16) {
        intArr[high] = splitWord(value)[0]
        intArr[low] = splitWord(value)[1]
    }
    
    func get() -> uint16 {
        return joinBytes(intArr[high], intArr[low])
    }
}

struct Z80 {    
    //Reset z80
    func reset(){
        //Set all registers to 0 
        for index in 0...23 {
            intArr[index] = 0
        }

        sp = 0
        r = 0
        R7 = 0
        pc = 0
        Tstates = 0 
        Halted = false
        interruptsEnabledAt = 0
    }

    // Interrupt process a Z80 maskable interrupt
    func Interrupt() {
        if (intArr[IFF1] != 0){
            //Set Halted to false
            if Halted {
                pc += 1
                Halted = false
            }

            Tstates += 7

            intArr[R] = (intArr[R] + 1) & 0x7f
            intArr[IFF1] = 0
            intArr[IFF2] = 0

            //Push pc
            let pch = splitWord(pc)[0]
            let pc1 = splitWord(pc)[1]
            sp -= 1
            memory.WriteByte(sp, pch)
            sp -= 1
            memory.WriteByte(sp, pc1)


            switch intArr[IM] {
            case 0:
                pc = 0x0038
            case 1:
                pc = 0x0038
            case 2:
                var intTemp : uint16 = (uint16(intArr[I] << 8) | 0xff
                pc1 = memory.ReadByte(intTemp)
                intTemp += 1
                pch = memory.ReadByte(intTemp)
                pc = joinBytes(pch, pc1)
            default : 
                exit(1)
            }

        }
    }

 // Process a Z80 non-maskable interrupt.
   func NonMaskableInterrupt() {
	if Halted {
		pc += 1
		Halted = false
	}

	Tstates += 7

	R = (R + 1) & 0x7f
    intArr[IFF1] = 0
    intArr[IFF2] = 0

	 //Push pc
    let pch = splitWord(pc)[0]
    let pc1 = splitWord(pc)[1]
    sp -= 1
    memory.WriteByte(sp, pch)
    sp -= 1
    memory.WriteByte(sp, pc1)

	pc = 0x0066
   }




}
