//
//  Port.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-17.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//

import Foundation
class Port {
        //var z80 : *Z80
    
    func ReadPort(_ address : UInt16) -> UInt8 {
        return 0
    }
    
    func WritePort (_ address : UInt16, _ b : UInt8){
        
    }
    
    func ReadPortInternal(_ address : UInt16, _ contend : Bool) -> UInt8 {
        return 0
    }
    
    
    func WritePortInternal (_ address : UInt16, _ b : UInt8, _ contend : Bool){
        
    }
    
    
    func ContendPortPreio( _ address : UInt16){
        
    }
    
    func ContendPortPostio( _ address : UInt16){
        
    }
    
    
    
}
