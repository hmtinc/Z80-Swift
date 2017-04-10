//
//  Generate.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-04.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation

//Script Based of z80.pl from the SMS Miracle Emulator 
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

//Individual Opcode Routines (They will be called using Swift Closures

func ADC(_ a : String, _ b : String) { arithmetic_logical(opcode: "ADC", arg1: a, arg2: b)}

func ADD(_ a : String, _ b : String) { arithmetic_logical(opcode: "ADD", arg1: a, arg2: b)}

func AND(_ a : String, _ b : String) { arithmetic_logical(opcode: "AND", arg1: a, arg2: b)}

func BIT (_ a : String, _ b : String){
    if len(s : b) == 1 {
        ln(sList: ["z80.bit(", a, ", z80.", b, ")"])
    } else if b == "(REGISTER+dd)" {
        ln(sList: ["var bytetemp = z80.memory.ReadByte( z80.tempaddr )"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.tempaddr, 1 )"])
        ln(sList: ["z80.biti(", a, ", bytetemp, z80.tempaddr)"])
    } else {
        ln(sList: ["var bytetemp = z80.memory.ReadByte( z80.HL() )"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.HL(), 1 )"])
        ln(sList: ["z80.bit(", b, ", bytetemp)"])
    }
}

func CALL (_ a : String, _ b : String) { call_jp(opcode: "CALL", condition: a, offset: b) }

func CCF (_ a : String, _ b : String) {
    ln(sList: ["z80.F = ( z80.F & ( FLAG_P | FLAG_Z | FLAG_S ) ) |"])
    ln(sList: ["        ternOpB( ( z80.F & FLAG_C ) != 0, FLAG_H, FLAG_C ) |"])
    ln(sList: ["        ( z80.A & ( FLAG_3 | FLAG_5 ) )"])
}

func CP(_ a : String, _ b : String) { arithmetic_logical(opcode: "CP", arg1: a, arg2: b)}

func CPD(_ a : String, _ b : String) {cpi_cpd(opcode: "CPD")}

func CPDR(_ a : String, _ b : String) {cpir_cpdr(opcode: "CPDR")}

func CPI(_ a : String, _ b : String) {cpi_cpd(opcode: "CPI")}

func CPIR(_ a : String, _ b : String) {cpir_cpdr(opcode: "CPIR")}

func CPL (_ a : String, _ b : String) {
    ln(sList: ["z80.A ^= 0xff"])
    ln(sList: ["z80.F = ( z80.F & ( FLAG_C | FLAG_P | FLAG_Z | FLAG_S ) ) |"])
    ln(sList: ["        ( z80.A & ( FLAG_3 | FLAG_5 ) ) | "])
    ln(sList: ["        ( FLAG_N | FLAG_H )"])
}

func DAA (_ a : String, _ b : String) {
    ln(sList: ["var add : UInt8 = 0"])
    ln(sList: ["var carry : UInt8 = ( z80.F & FLAG_C )"])
    ln(sList: ["if ( (z80.F & FLAG_H ) != 0) || ( ( z80.A & 0x0f ) > 9 ) { add = 6 }"])
    ln(sList: ["if (carry != 0) || ( z80.A > 0x99 ) { add |= 0x60 }"])
    ln(sList: ["if z80.A > 0x99 { carry = FLAG_C }"])
    ln(sList: ["if (z80.F & FLAG_N) != 0 {"])
    ln(sList: ["  z80.sub(add)"])
    ln(sList: ["} else {"])
    ln(sList: ["  z80.add(add)"])
    ln(sList: ["}"])
    ln(sList: ["var temp : UInt8 = UInt8(int(z80.F) & ^(FLAG_C | FLAG_P)) | carry | parityTable[z80.A]"])
    ln(sList: ["z80.F = temp"])
}

func DEC(_ a : String, _ b : String) {inc_dec(opcode: "DEC", arg: a)}

func DI(_ a : String, _ b : String) {
    ln(sList: ["z80.IFF1 = 0"])
    ln(sList: ["z80.IFF2 = 0"])
}

func DJNZ(_ a : String, _ b : String) {
    ln(sList: ["z80.memory.ContendReadNoMreq(z80.IR(), 1)"])
    ln(sList: ["z80.B -= 1"])
    ln(sList: ["if z80.B != 0 {"])
    ln(sList: ["  z80.jr()"])
    ln(sList: ["} else {"])
    ln(sList: ["  z80.memory.ContendRead( z80.PC(), 3 )"])
    ln(sList: ["}"])
    ln(sList: ["z80.IncPC(1)"])
}

func EI(_ a : String, _ b : String) {
    ln(sList: ["// Interrupts are not accepted immediately after an EI, but are"])
    ln(sList: ["// accepted after the next instruction"])
    ln(sList: ["z80.IFF1 = 1"])
    ln(sList: ["z80.IFF2 = 1"])
    ln(sList: ["z80.interruptsEnabledAt = int(z80.Tstates)"])
    ln(sList: ["// eventAdd(z80.Tstates + 1, z80InterruptEvent)"])
}

func EX(_ a : String, _ b : String) {
    if (a == "AF") && (b == "AF'") {
        ln(sList: ["var olda = z80.A"])
        ln(sList: ["var oldf = z80.F"])
        ln(sList: ["z80.A = z80.A_; z80.F = z80.F_"])
        ln(sList: ["z80.A_ = olda; z80.F_ = oldf"])
    } else if (a == "(SP)") && (b == "HL" || b == "REGISTER") {
        var high : String; var  low : String
        
        if b == "HL" {
            high = "H"; low = "L"
        } else {
            high = "REGISTERH" ; low = "REGISTERL"
        }
        ln(sList: ["var bytetempl = z80.memory.ReadByte( z80.SP() )"])
        ln(sList: ["var bytetemph = z80.memory.ReadByte( z80.SP() + 1 )"])
        ln(sList: ["z80.memory.ContendReadNoMreq( z80.SP() + 1, 1 )"])
        ln(sList: ["z80.memory.WriteByte( z80.SP() + 1, z80.", high, " )"])
        ln(sList: ["z80.memory.WriteByte( z80.SP(),     z80.", low, "  )"])
        ln(sList: ["z80.memory.ContendWriteNoMreq_loop( z80.SP(), 1, 2 )"])
        ln(sList: ["z80.", low, " = bytetempl"])
        ln(sList: ["z80.", high, " = bytetemph"])
    } else if (a == "DE") && (b == "HL") {
        ln(sList: ["var wordtemp : UInt16 = z80.DE()"])
        ln(sList: ["z80.SetDE(z80.HL())"])
        ln(sList: ["z80.SetHL(wordtemp)"])
    } else {
        exit(10)
    }

}

func EXX(_ a : String, _ b : String) {
    ln(sList: ["var wordtemp : UInt16 = z80.BC()"])
    ln(sList: ["z80.SetBC(z80.BC_())"])
    ln(sList: ["z80.SetBC_(wordtemp)"])
    ln(sList: [])
    ln(sList: ["wordtemp = z80.DE()"])
    ln(sList: ["z80.SetDE(z80.DE_())"])
    ln(sList: ["z80.SetDE_(wordtemp)"])
    ln(sList: [])
    ln(sList: ["wordtemp = z80.HL()"])
    ln(sList: ["z80.SetHL(z80.HL_())"])
    ln(sList: ["z80.SetHL_(wordtemp)"])
}

func HALT(_ a : String, _ b : String) {
    ln(sList: ["z80.Halted = true"])
    ln(sList: ["z80.DecPC(1)"])
    ln(sList: ["return"])
}

func IM(_ a : String, _ b : String) {
    ln(sList: ["z80.IM = ", a])
}

func IN(_ register : String, _ port : String) {
    if (register == "A") && (port == "(nn)") {
        ln(sList: ["var intemp : UInt16 = UInt16(z80.memory.ReadByte(z80.PC())) + (uint16(z80.A) << 8 )"])
        ln(sList: ["z80.IncPC(1)"])
        ln(sList: ["z80.A = z80.readPort(intemp)"])
    } else if (register == "F") && (port == "(C)") {
        ln(sList: ["var bytetemp : UInt8"])
        ln(sList: ["z80.in(&bytetemp, z80.BC())"])
    } else if (len(s: register) == 1) && (port == "(C)") {
        ln(sList: ["z80.in(&z80.", register, ", z80.BC())"])
    } else {
        exit(20)
    }
}

func INC(_ a : String, _ b : String) {inc_dec(opcode: "INC", arg: a)}

func IND(_ a : String, _ b : String) {ini_ind(opcode: "IND")}

func INDR(_ a : String, _ b : String) {inir_indr(opcode: "INDR")}

func INI(_ a : String, _ b : String) {ini_ind(opcode: "INI")}

func INIR(_ a : String, _ b : String) {inir_indr(opcode: "INIR")}

func JP(_ a : String, _ b : String) {
    if (a == "HL") || (a == "REGISTER") {
        ln(sList: ["z80.SetPC(z80.", a, "())\t\t/* NB: NOT INDIRECT! */"])
    } else {
        call_jp(opcode: "JP", condition: a, offset: b)
    }
}

func JR(_ a : String, _ b : String) {
    
    //Create Copies, because Swift 3!
    var condition = a
    var offset = b
    
    if offset == "" {
        offset = condition
        condition = ""
    }
    
    if condition == "" {
        ln(sList: ["z80.jr()"])
    } else {
        var condition_string : String
        if not[condition]! {
            condition_string = "(z80.F & FLAG_" + flag[condition]! + ") == 0"
        } else {
            condition_string = "(z80.F & FLAG_" + flag[condition]! + ") != 0"
        }
        ln(sList: ["if ", condition_string, " {"])
        ln(sList: ["  z80.jr()"])
        ln(sList: ["} else {"])
        ln(sList: ["  z80.memory.ContendRead( z80.PC(), 3 )"])
        ln(sList: ["}"])
    }
    
    ln(sList: ["z80.IncPC(1)"])
}

func LD(_ a : String, _ b : String) {
    
    //Create Copies, because Swift 3!
    var dest = a
    var src = b
    
    if (len(s: dest) == 1) || matches(s: dest, pattern: "^REGISTER[HL]$") {
        if (len(s: src) == 1) || matches(s: src, pattern: "^REGISTER[HL]$") {
            if (dest == "R") && (src == "A") {
                ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 )"])
                ln(sList: ["/* Keep the RZX instruction counter right */"])
                ln(sList: ["z80.rzxInstructionsOffset += ( int(z80.R) - int(z80.A))"])
                ln(sList: ["z80.R, z80.R7 = uint16(z80.A), z80.A"])
            } else if (dest == "A") && (src == "R") {
                ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 )"])
                ln(sList: ["z80.A = byte(z80.R&0x7f) | (z80.R7 & 0x80)"])
                ln(sList: ["z80.F = ( z80.F & FLAG_C ) | sz53Table[z80.A] | ternOpB(z80.IFF2 != 0, FLAG_V, 0)"])
            } else {
                if (src == "I") || (dest == "I") {
                    ln(sList: ["z80.memory.ContendReadNoMreq( z80.IR(), 1 )"])
                }
                if dest != src {
                    ln(sList: ["z80.", dest, " = z80.", src])
                }
                if (dest == "A") && (src == "I") {
                    ln(sList: ["z80.F = ( z80.F & FLAG_C ) | sz53Table[z80.A] | ternOpB(z80.IFF2 != 0, FLAG_V, 0)"])
                }
            }
        } else if src == "nn" {
            ln(sList: ["z80.", dest, " = z80.memory.ReadByte(z80.PC())"])
            ln(sList: ["z80.IncPC(1)"])
        } else if matches(s: src, pattern: "^\\(..\\)$") {
            let register = src.substring(from: 1).substring(to: 1)
            ln(sList: ["z80.", dest, " = z80.memory.ReadByte(z80.", register, "())"])
        } else if src == "(nnnn)" {
            ln(sList: ["var wordtemp : UInt16 = UInt16(z80.memory.ReadByte(z80.PC()))"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["wordtemp |= UInt16(z80.memory.ReadByte(z80.PC())) << 8"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["z80.A = z80.memory.ReadByte(wordtemp)"])
        } else if src == "(REGISTER+dd)" {
            ln(sList: ["var offset : UInt8 = z80.memory.ReadByte( z80.PC() )"])
            ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.PC(), 1, 5 )"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["z80.", dest, " = z80.memory.ReadByte(z80.REGISTER() + uint16(signExtend(offset)))"])
        } else {
            exit(33)
        }
    } else if (len(s: dest) == 2) || (dest == "REGISTER") {
        var high : String; var low : String
        
        if (dest == "SP") || (dest == "REGISTER") {
            high = (dest + "H")
            low = (dest + "L")
        } else {
            high = src.substring(to: 1)
            low = src.substring(from: 1).substring(to: 1)
        }
        
        if src == "nnnn" {
            ln(sList: ["b1 := z80.memory.ReadByte(z80.PC())"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["b2 := z80.memory.ReadByte(z80.PC())"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["z80.Set", high, low, "(joinBytes(b2, b1))"])
        } else if ((src == "HL") || (src == "REGISTER")) {
            ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.IR(), 1, 2 )"])
            ln(sList: ["z80.SetSP(z80.", src, "())"])
        } else if src == "(nnnn)" {
            if low == "SPL" {
                ln(sList: ["var spl = splitWord(z80.SP()); var sph = spl \nz80.ld16rrnn(&spl, &sph)\nz80.SetSP(joinBytes(sph, spl))\n // break"])
            } else {
                ln(sList: ["z80.ld16rrnn(&z80.", low, ", &z80.", high, ")\n // break"])
            }
        } else {
            exit(34)
        }
    } else if matches(s: dest, pattern: "^\\(..\\)$") {
        var register = dest.substring(from: 1).substring(to: 1)
        
        if len(s: src) == 1 {
            ln(sList: ["z80.memory.WriteByte(z80.", register, "(),z80.", src, ")"])
        } else if src == "nn" {
            ln(sList: ["z80.memory.WriteByte(z80.", register, "(),z80.memory.ReadByte(z80.PC()))"])
            ln(sList: ["z80.IncPC(1)"])
        } else {
            exit(35)
        }
    } else if dest == "(nnnn)" {
        if src == "A" {
            ln(sList: ["var wordtemp : UInt16 = UInt16(z80.memory.ReadByte(z80.PC()))"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["wordtemp |= UInt16(z80.memory.ReadByte(z80.PC())) << 8"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["z80.memory.WriteByte(wordtemp, z80.A)"])
        } else if (len(s: src) == 2) || (src == "REGISTER") {
            var high : String ; var low : String
            if (src == "SP") || (src == "REGISTER") {
                high = (src + "H")
                low = (src + "L")
            } else {
                high = src.substring(to: 1)
                low = src.substring(from: 1).substring(to: 1)
            }
            if low == "SPL" {
                ln(sList: ["var spl = splitWord(z80.sp); var sph = spl \nz80.ld16nnrr(spl, sph)\n // break"])
            } else {
                ln(sList: ["z80.ld16nnrr(z80.", low, ", z80.", high, ")\n // break"])
            }
        } else {
            exit(35)
        }
    } else if dest == "(REGISTER+dd)" {
        if len(s: src) == 1 {
            ln(sList: ["offset := z80.memory.ReadByte( z80.PC() )"])
            ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.PC(), 1, 5 )"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["z80.memory.WriteByte(z80.REGISTER() + uint16(signExtend(offset)), z80.", src, " )"])
        } else if src == "nn" {
            ln(sList: ["offset := z80.memory.ReadByte( z80.PC() )"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["var value = z80.memory.ReadByte( z80.PC() )"])
            ln(sList: ["z80.memory.ContendReadNoMreq_loop( z80.PC(), 1, 2 )"])
            ln(sList: ["z80.IncPC(1)"])
            ln(sList: ["z80.memory.WriteByte(z80.REGISTER() + UInt16(signExtend(offset)), value )"])
        } else {
            exit(55)
        }
    } else {
        exit(65)
    }
}

func LDD(_ a : String, _ b : String) { ldi_ldd(opcode: "LDD") }

func LDDR(_ a : String, _ b : String) { ldir_lddr(opcode: "LDDR") }

func LDI(_ a : String, _ b : String) { ldi_ldd(opcode: "LDI") }

func LDIR(_ a : String, _ b : String) { ldir_lddr(opcode: "LDIR") }

func NEG(_ a : String, _ b : String) {
    ln(sList: ["var bytetemp = z80.A"])
    ln(sList: ["z80.A = 0"])
    ln(sList: ["z80.sub(bytetemp)"])
}

//No Operation
func NOP (_ a : String, _ b : String) {}

func OR(_ a : String, _ b : String) { arithmetic_logical(opcode: "OR", arg1: a, arg2: b) }

func OTDR(_ a : String, _ b : String) { otir_otdr(opcode: "OTDR") }

func OTIR(_ a : String, _ b : String) { otir_otdr(opcode: "OTIR") }


func OUT(port : String, register : String) {
    if (port == "(nn)") && (register == "A") {
        ln(sList: ["var outtemp : UInt16 = UInt16(z80.memory.ReadByte(z80.PC())) + (UInt16(z80.A) << 8)"])
        ln(sList: ["z80.IncPC(1)"])
        ln(sList: ["z80.writePort(outtemp, z80.A)"])
    } else if (port == "(C)") && (len(s: register) == 1) {
        if register == "0" {
            ln(sList: ["z80.writePort(z80.BC(), ", register, ")"])
        } else {
            ln(sList: ["z80.writePort(z80.BC(), z80.", register, ")"])
        }
    } else {
        exit(90)
    }
}
