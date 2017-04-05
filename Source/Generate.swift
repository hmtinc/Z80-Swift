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
    
    //Check if arg2 is blank 
    if (arg2 == ""){
        arg2 = arg1
        arg1 = "A"
    }
    
    if (len(s: arg1) == 1){
        
    }
    else if (opcode == "ADD"){
        
    }
    else if (len(s: arg2) == 2 && arg1 == "HL" ){
        
    }
    else {
        exit(2)
    }
    
}



