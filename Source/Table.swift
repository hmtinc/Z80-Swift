//
//  Table.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-17.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation


/* Whether a half carry occurred or not can be determined by looking at
   the 3rd bit of the two arguments and the result; these are hashed
   into this table in the form r12, where r is the 3rd bit of the
   result, 1 is the 3rd bit of the 1st argument and 2 is the
   third bit of the 2nd argument; the tables differ for add and subtract
   operations */

var halfcarryAddTable : [UInt8] = [0, FLAG_H, FLAG_H, FLAG_H, 0, 0, 0, FLAG_H]
var halfcarrySubTable : [UInt8] = [0, 0, FLAG_H, 0, FLAG_H, 0, FLAG_H, FLAG_H]

/* Similarly, overflow can be determined by looking at the 7th bits; again
   the hash into this table is r12 */
var overflowAddTable : [UInt8] = [0, 0, 0, FLAG_V, FLAG_V, 0, 0, 0]
var overflowSubTable : [UInt8] = [0, FLAG_V, 0, 0, 0, 0, FLAG_V, 0]


//Allocate space for 768 8-bit integers
var sz53Table : [UInt8] = Array(repeating: 0, count: 256)
var sz53pTable : [UInt8] = Array(repeating: 0, count: 256)
var parityTable : [UInt8] = Array(repeating: 0, count: 256)

func SetTableValues() {

    //Temporary Variables
    var parity : UInt8 = 0
    var j : UInt8 = 0 

    for index in 0...255 {
        sz53Table[index] = UInt8(index) & (0x08 | 0x20 | 0x80)
        j = UInt8(index)
        parity = 0

        for indexk in 0...8 {
            parity ^= j & 1
            j >>= 1
        } 

        parityTable[index] = ternOpB(parity != 0, 0, 0x04)
        sz53pTable[index] = sz53Table[index] | parityTable[index]
    }

    sz53Table[0] |= 0x40
    sz53pTable[0] |= 0x40

}
