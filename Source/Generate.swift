//
//  Generate.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-04.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation

//Script Based of z80.pl from the script provided with FUSE  
//Additional elements ported from https://github.com/remogatto/z80/


//Extension to extract strings
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

//Output
var output = "";

//Not Flags 
var not = ["NC" : true, "NZ" : true, "P": true, "PO" : true]

//Use F & Flag_<something> 
var flag = ["C":"C", "NC":"C", "PE":"P","PO":"P", "M":"S", "P":"S", "Z":"Z", "NZ":"Z"]

//Determine if a string matches a pattern 
func matches(s : String, pattern : String) -> Bool {
    return (s.range(of: s, options: .regularExpression) != nil)
}

//Convert a string to lower case 
func lc(s : String) -> String {
    return s.lowercased()
}

//Write to output with \n terminator 
func nlPrint (s : String){
    print(s, to: &output)
}

//Write to output with no \n terminator
func nnlPrint (s : String) {
    print(s, separator: "", terminator: "", to: &output)
}

//Joins the strings in a array and prints them to output 
func ln (sList : [String]) {
    for index in 0 ..< sList.count {
        nnlPrint(s: sList[index])
    }
    
    //Print a new line 
    print()
}

//If Statement (Helps reduce lines of code) 
func _if(cond : Bool, if_true : String, if_false : String ) -> String {
    if (cond) { return if_true }
    else { return if_false }
}

//Get length (Helps reduce lines of code)
func len(s : String) -> Int{
    return s.characters.count
}

//General Opcode Methods

//From z80.pl (General Arthmetic Logic)
func arithmetic_logical(opcode : String, arg1 : String, arg2 : String){
    //Make Copies Because Swift 3!
    var opcode = opcode
    var arg1 = arg1
    var arg2 = arg2
    
    //Temp Variables
    var lc_opcode = ""
    
    //Check if arg2 is blank 
    if (arg2 == ""){
        arg2 = arg1
        arg1 = "A"
    }
    
   
    if (len(s: arg1) == 1){
        if (len(s: arg2) == 1 || matches(s: arg2, pattern: "$REGISTER[HL]$")){
            lc_opcode = lc(s: opcode)
            ln(sList: ["z80.", lc_opcode, "(z80.", arg2, ")"])
        }
        else if (arg2 == "(REGISTER+dd)"){
            lc_opcode = lc(s: opcode)
            ln(sList: ["var offset : UInt8 = z80.memory.ReadByte( z80.PC() )"])
            ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.PC(), 1, 5"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte(z80.REGISTER() + UInt16(signExtend(offset)))"])
            ln(sList: ["z80.", lc_opcode, "(bytetemp)"])
        }
        else {
            let register = _if(cond: arg2 == "arg2", if_true: "HL", if_false: "PC")
            let increment = _if(cond: register == "PC", if_true: "z80.IncPC(1)", if_false: "")
            lc_opcode = lc(s: opcode)
            ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte(z80.", register, "())"])
            ln(sList: [increment])
            ln(sList: ["z80.", lc_opcode, "(bytetemp)"])
        }
    }
    else if (opcode == "ADD"){
        lc_opcode = lc(s: opcode)
        ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.IR(), 1, 7 )"])
        ln(sList: ["z80.", lc_opcode, "16(z80.", lc(s : arg1), ", z80.", arg2, "())"])
    }
    else if (len(s: arg2) == 2 && arg1 == "HL" ){
        lc_opcode = lc(s: opcode)
        ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.IR(), 1, 7 )"])
        ln(sList: ["z80.", lc_opcode, "16(z80.", arg2, "())"])
    }
    else {
        exit(2)
    }
}

func call_jp(opcode : String, condition : String, offset : String) {
    let lc_opcode = lc(s: opcode)
    if offset == "" {
        ln(sList: ["z80.", lc_opcode, "()"])
    } else {
        var condition_string : String
        if not[condition]!{
            condition_string = "(z80.F & FLAG_" + flag[condition]! + ") == 0"
        } else {
            condition_string = "(z80.F & FLAG_" + flag[condition]! + ") != 0"
        }
        ln(sList: ["if ", condition_string, "{"])
        ln(sList: ["  z80.", lc_opcode, "()"])
        ln(sList: ["} else {"])
        ln(sList:["  z80.memory.ContendRead(z80.PC(), 3); z80.memory.ContendRead( z80.PC() + 1, 3 ); z80.IncPC(2);"])
        ln(sList:["}"])
    }
}

func cpi_cpd(opcode : String) {
    let modifier = _if(cond: opcode == "CPI", if_true: "Inc", if_false: "Dec")
    
    ln(sList: ["var value : UInt8 = z80.memory.ReadByte( z80.HL() )"])
    ln(sList: ["var bytetemp : UInt8 = z80.A - value"])
    ln(sList: ["var lookup : UInt8 = ((z80.A & 0x08 ) >> 3 ) | (((value) & 0x08 ) >> 2 ) | ((bytetemp & 0x08 ) >> 1)"])
    ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.HL(), 1, 5 )"])
    ln(sList: ["z80.", modifier, "HL(); z80.DecBC()"])
    ln(sList: ["z80.F = (z80.F & FLAG_C) | ternOpB(z80.BC() != 0, FLAG_V | FLAG_N, FLAG_N) | halfcarrySubTable[lookup] | ternOpB(bytetemp != 0, 0, FLAG_Z) | (bytetemp & FLAG_S )"])
    ln(sList: ["if (z80.F & FLAG_H) != 0 { bytetemp-- }"])
    ln(sList: ["z80.F |= (bytetemp & FLAG_3) | ternOpB((bytetemp & 0x02) != 0, FLAG_5, 0)"])
}

func cpir_cpdr(opcode : String) {
    let modifier = _if(cond: opcode == "CPIR", if_true: "Inc", if_false: "Dec")
    
    ln(sList: ["var value : UInt8 = z80.memory.ReadByte( z80.HL() )"])
    ln(sList: ["var bytetemp : UInt8 = z80.A - value"])
    ln(sList: ["var lookup : UInt8 = ((z80.A & 0x08) >> 3) | (((value) & 0x08) >> 2) | ((bytetemp & 0x08) >> 1)"])
    
    ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.HL(), 1, 5 )"])
    ln(sList: ["z80.DecBC()"])
    ln(sList: ["z80.F = ( z80.F & FLAG_C ) | ( ternOpB(z80.BC() != 0, ( FLAG_V | FLAG_N ),FLAG_N)) | halfcarrySubTable[lookup] | ( ternOpB(bytetemp != 0, 0, FLAG_Z )) | ( bytetemp & FLAG_S )"])
    ln(sList: ["if (z80.F & FLAG_H) != 0 {"])
    ln(sList: ["  bytetemp--"])
    ln(sList: ["}"])
    ln(sList: ["z80.F |= ( bytetemp & FLAG_3 ) | ternOpB((bytetemp & 0x02) != 0, FLAG_5, 0)"])
    ln(sList: ["if ( z80.F & ( FLAG_V | FLAG_Z ) ) == FLAG_V {"])
    ln(sList: ["  z80.memory.ContendReadNoMreq_loop( z80.HL(), 1, 5 )"])
    ln(sList: ["  z80.DecPC(2)"])
    ln(sList: ["}"])
    ln(sList: ["z80.", modifier, "HL()"])
}

func inc_dec(opcode : String, arg : String) {
    let modifier = _if(cond: opcode == "INC", if_true: "Inc", if_false: "Dec")
    
    if len(s : arg) == 1 || matches(s: arg, pattern: "^REGISTER[HL]$") {
        ln(sList: ["z80.", lc(s: opcode), arg, "()"])
    } else if len(s: arg) == 2 || arg == "REGISTER" {
        ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.IR(), 1, 2 )"])
        ln(sList: ["z80.", modifier, arg, "()"])
    } else if arg == "(HL)" {
        ln(sList: ["{"])
        ln(sList: ["  var bytetemp : UInt8 = z80.memory.ReadByte( z80.HL() )"])
        ln(sList: ["  z80.memory.ContendReadNoMreq( z80.HL(), 1 )"])
        ln(sList: ["  z80.", lc(s: opcode), "(&bytetemp)"])
        ln(sList: ["  z80.memory.WriteByte(z80.HL(), bytetemp)"])
        ln(sList: ["}"])
    } else if arg == "(REGISTER+dd)" {
        ln(sList: ["var offset : UInt8 = z80.memory.ReadByte( z80.PC() )"])
        ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.PC(), 1, 5 )"])
        ln(sList: ["z80.IncPC(1)"])
        ln(sList: ["var wordtemp : UInt16 = z80.REGISTER() + uint16(signExtend(offset))"])
        ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte( wordtemp )"])
        ln(sList: ["z80.memory.ContendReadNoMreq( wordtemp, 1 )"])
        ln(sList: ["z80.", lc(s: opcode), "(&bytetemp)"])
        ln(sList: ["z80.memory.WriteByte(wordtemp,bytetemp)"])
    } else {
        exit(2)
    }
}

func ini_ind(opcode : String) {
    let modifier = _if(cond: opcode == "INI", if_true: "Inc", if_false: "Dec")
    let operation = _if(cond: opcode == "INI", if_true: "+", if_false: "-")
    
    ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 );"])
    ln(sList: ["var initemp : UInt8 = z80.readPort(z80.BC());"])
    ln(sList: ["z80.memory.WriteByte( z80.HL(), initemp );"])
    ln(sList: [])
    ln(sList: ["z80.B--; z80.", modifier, "HL()"])
    ln(sList: ["var initemp2 : UInt8 = initemp + z80.C ", operation, " 1;"])
    ln(sList: ["z80.F = ternOpB((initemp & 0x80) != 0, FLAG_N, 0) |"])
    ln(sList: ["        ternOpB(initemp2 < initemp, FLAG_H | FLAG_C, 0) |"])
    ln(sList: ["        ternOpB(parityTable[(initemp2 & 0x07) ^ z80.B] != 0, FLAG_P, 0 ) |"])
    ln(sList: ["        sz53Table[z80.B]"])
}

func inir_indr(opcode: String) {
    let modifier = _if(cond: opcode == "INIR", if_true: "Inc", if_false: "Dec")
    let operation = _if(cond: opcode == "INIR", if_true: "+", if_false: "-")
    
    ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 );"])
    ln(sList: ["var initemp : UInt8 = z80.readPort(z80.BC());"])
    ln(sList: ["z80.memory.WriteByte( z80.HL(), initemp );"])
    ln(sList: [])
    ln(sList: ["z80.B--;"])
    ln(sList: ["var initemp2 : UInt8 = initemp + z80.C ", operation, " 1;"])
    ln(sList: ["z80.F = ternOpB(initemp & 0x80 != 0, FLAG_N, 0) |"])
    ln(sList: ["        ternOpB(initemp2 < initemp, FLAG_H | FLAG_C, 0 ) |"])
    ln(sList: ["        ternOpB(parityTable[ ( initemp2 & 0x07 ) ^ z80.B ] != 0, FLAG_P, 0) |"])
    ln(sList: ["        sz53Table[z80.B];"])
    ln(sList: [])
    ln(sList: ["if z80.B != 0 {"])
    ln(sList: ["  z80.memory.ContendWriteNoMreq_loop( z80.HL(), 1, 5 )"])
    ln(sList: ["  z80.DecPC(2)"])
    ln(sList: ["}"])
    ln(sList: ["z80.", modifier, "HL()"])
}

func ldi_ldd(opcode : String) {
    let modifier = _if(cond: opcode == "LDI", if_true: "Inc", if_false: "Dec")
    
    ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte( z80.HL() )"])
    ln(sList: ["z80.DecBC()"])
    ln(sList: ["z80.memory.WriteByte(z80.DE(), bytetemp);"])
    ln(sList: ["z80.memory.ContendWriteNoMreq_loop( z80.DE(), 1, 2 )"])
    ln(sList: ["z80.", modifier, "DE(); z80.", modifier, "HL();"])
    ln(sList: ["bytetemp += z80.A;"])
    ln(sList: ["z80.F = ( z80.F & ( FLAG_C | FLAG_Z | FLAG_S ) ) |"])
    ln(sList: ["        ternOpB(z80.BC() != 0, FLAG_V, 0) |"])
    ln(sList: ["        ( bytetemp & FLAG_3 ) |"])
    ln(sList: ["        ternOpB((bytetemp & 0x02) != 0, FLAG_5, 0)"])
}

func ldir_lddr(opcode : String) {
    let modifier = _if(cond: opcode == "LDIR", if_true: "Inc", if_false: "Dec")
    
    ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte( z80.HL() )"])
    ln(sList: ["z80.memory.WriteByte(z80.DE(), bytetemp);"])
    ln(sList: ["z80.memory.ContendWriteNoMreq_loop(z80.DE(), 1, 2)"])
    ln(sList: ["z80.DecBC()"])
    ln(sList: ["bytetemp += z80.A;"])
    ln(sList: ["z80.F = (z80.F & ( FLAG_C | FLAG_Z | FLAG_S )) | ternOpB(z80.BC() != 0, FLAG_V, 0 ) | (bytetemp & FLAG_3) | ternOpB((bytetemp & 0x02 != 0), FLAG_5, 0 )"])
    ln(sList: ["if z80.BC() != 0 {"])
    ln(sList: ["  z80.memory.ContendWriteNoMreq_loop( z80.DE(), 1, 5 )"])
    ln(sList: ["  z80.DecPC(2)"])
    ln(sList: ["}"])
    ln(sList: ["z80.", modifier, "HL(); z80.", modifier, "DE()"])
}

func otir_otdr(opcode : String) {
    let modifier = _if(cond: opcode == "OTIR", if_true: "Inc", if_false: "Dec")
    
    ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 );"])
    ln(sList: ["var outitemp : UInt8 = z80.memory.ReadByte( z80.HL() );"])
    ln(sList: ["z80.B--;"])
    ln(sList: ["z80.writePort(z80.BC(), outitemp);"])
    ln(sList: [])
    ln(sList: ["z80.", modifier, "HL()"])
    ln(sList: ["var outitemp2 : UInt8 = outitemp + z80.L;"])
    ln(sList: ["z80.F = ternOpB((outitemp & 0x80) != 0, FLAG_N, 0 ) |"])
    ln(sList: ["    ternOpB(outitemp2 < outitemp, FLAG_H | FLAG_C, 0) |"])
    ln(sList: ["    ternOpB(parityTable[ ( outitemp2 & 0x07 ) ^ z80.B ] != 0, FLAG_P, 0 ) |"])
    ln(sList: ["    sz53Table[z80.B]"])
    ln(sList: [])
    ln(sList: ["if z80.B != 0 {"])
    ln(sList: ["  z80.memory.ContendReadNoMreq_loop( z80.BC(), 1, 5 )"])
    ln(sList: ["  z80.DecPC(2)"])
    ln(sList: ["}"])
}

func outi_outd(opcode: String) {
    let modifier = _if(cond: opcode == "OUTI", if_true: "Inc", if_false: "Dec")
    
    ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 )"])
    ln(sList: ["var outitemp : UInt8 = z80.memory.ReadByte( z80.HL() )"])
    ln(sList: ["z80.B--;"])
    ln(sList: ["z80.writePort(z80.BC(), outitemp)"])
    ln(sList: [])
    ln(sList: ["z80.", modifier, "HL()"])
    ln(sList: ["var outitemp2 : UInt8 = outitemp + z80.L"])
    ln(sList: ["z80.F = ternOpB((outitemp & 0x80) != 0, FLAG_N, 0) |"])
    ln(sList: ["        ternOpB(outitemp2 < outitemp, FLAG_H | FLAG_C, 0) |"])
    ln(sList: ["        ternOpB(parityTable[ ( outitemp2 & 0x07 ) ^ z80.B ] != 0, FLAG_P, 0 ) |"])
    ln(sList: ["        sz53Table[z80.B]"])
}

func push_pop(opcode : String, regpair :String) {
    var high, low : String
    
    if regpair == "REGISTER" {
        high = "REGISTERH"
        low =  "REGISTERL"
    } else {
        //Extract String Pairs
        high = regpair.substring(to: 1)
        low = regpair.substring(to: 2).substring(from: 1)
    }
    
    let lc_opcode = lc(s: opcode)
    if (lc_opcode == "pop") {
        ln(sList: ["z80.", low, ", z80.", high, " = z80.", lc_opcode, "16()"])
    } else {
        ln(sList: ["z80.", lc_opcode, "16(z80.", low, ", z80.", high, ")"])
    }
}

func res_set_hexmask(_ opcode : String, _ bit : UInt) -> String {
    var mask = 1 << bit
    var hexOutput = ""
    
    if opcode == "RES" {
        mask = 0xff - mask
    }

   //Format Output
    print(NSString(format : "0x%02x", mask), separator: "", terminator: "", to: &hexOutput)
    
    //Return hex code
    return hexOutput
}

func res_set(opcode : String, bit : UInt, register : String) {
    let opp = _if(cond: opcode == "RES", if_true: "&", if_false: "|")
    
    let hex_mask = res_set_hexmask(opcode, bit)
    
    if len(s: register) == 1 {
        ln(sList: ["z80.", register, " ", opp, "= ", hex_mask])
    } else if register == "(HL)" {
        ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte( z80.HL() )"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.HL(), 1 )"])
        ln(sList: ["z80.memory.WriteByte( z80.HL(), bytetemp ", opp, " ", hex_mask, " )"])
    } else if register == "(REGISTER+dd)" {
        ln(sList: ["var bytetemp byte = z80.memory.ReadByte( z80.tempaddr )"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.tempaddr, 1 )"])
        ln(sList: ["z80.memory.WriteByte( z80.tempaddr, bytetemp ", opp, " ", hex_mask, " )"])
    } else {
        exit(3)
    }
}

func rotate_shift(opcode : String, register : String) {
    let lc_opcode = lc(s: opcode)
    
    if len(s : register) == 1 {
        ln(sList: ["z80.", register, " = z80.", lc_opcode, "(z80.", register, ")"])
    } else if register == "(HL)" {
        ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte(z80.HL())"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.HL(), 1 )"])
        ln(sList: ["bytetemp = z80.", lc_opcode, "(bytetemp)"])
        ln(sList: ["z80.memory.WriteByte(z80.HL(),bytetemp)"])
    } else if register == "(REGISTER+dd)" {
        ln(sList: ["var bytetemp : UInt8 = z80.memory.ReadByte(z80.tempaddr)"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.tempaddr, 1 )"])
        ln(sList: ["bytetemp = z80.", lc_opcode, "(bytetemp)"])
        ln(sList: ["z80.memory.WriteByte(z80.tempaddr, bytetemp)"])
    } else {
        exit(4)
    }
}


//Define a type for Operation  Codes using swifts typealias
typealias Opcode = UInt8


