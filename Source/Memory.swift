//
//  Memory.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-17.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation

//Define the memory class
class Memory {
    
    //Data goes here
    var data_array = Array(repeating: UInt8(0), count: 65536)
    
    //Data Map 
    var data_map : [UInt16 : UInt8] = [0  : 0]
    
    //var z80 : *Z80
    
    func ReadByte (_ address : UInt16) -> UInt8 {
        return 0
    }
    
    func ReadByteInternal (_address : UInt16) -> UInt8 {
        return 0
    }
    
    func WriteByte (_ address : UInt16, _ value : UInt8) {
        
    }
    
    func WriteByteInternal (_ address : UInt16, _ value : UInt8) {
        
    }
    
    func ContentRead(_ address : UInt16, _ time : Int){
        
    }
    
    func ContentReadNoMreq(_ address : UInt16, _ time : Int){
        
    }
    
    func ContentReadNoMreq_loop(_ address : UInt16, _ time : Int, _ count : UInt){
        
    }
    
    func Read(_ address : UInt16) -> UInt8 {
       return 0
    }
    
    func Write (_ address : UInt16, _ value : UInt8, _ protectRom : Bool){
        
    }
    
    func Data() -> [UInt8]{
        return [0]
    }

    
    init () {
        
    }
}
