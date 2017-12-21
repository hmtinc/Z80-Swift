//
//  ports.swift
//  Z80-Swift
//
//  Created by Harsh Mistry on 2017-12-15.
//  Copyright © 2017 Harsh Mistry. All rights reserved.
//

import Foundation

class Ports {
    var data : [UInt8] = [];
    var NMI : Bool = false;
    var MI : Bool = false;
    
    var portData = [uint16 : uint8]()
    
    func readPort(_ address : uint16) -> uint8{
        print("Reading port at " + String(address))
        return portData[address] ?? uint8(0)
    }
    
    func writePort(_ address : uint16, _ value : uint8){
        print("Writing value = " + String(value) + " to port at " + String(address))
        portData[address] = value
    }
}
