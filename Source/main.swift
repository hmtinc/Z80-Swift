//
//  main.swift
//  Z80-Swift
//
//  Created by Harsh Mistry on 2017-12-15.
//  Copyright © 2017 Harsh Mistry. All rights reserved.
//

import Foundation

//Read a rom at a given path and return a byte array or nil
func RomRead(path : String) -> [UInt8]?{
    //Create a blank byte array
    var romByteArray = [UInt8]()
    
    //Read contents of the file at the given path
    guard let data = NSData(contentsOfFile: path) else {return nil}
    
    //Create a buffer array
    var buffer = [UInt8](repeating: 0, count: data.length)
    
    //Read Bytes
    data.getBytes(&buffer, length : data.length)
    
    //Copy buffer to the romByteArray
    romByteArray = buffer
    
    //Read was successful, return the byteArray
    return romByteArray
}

var x : [uint8]! = RomRead(path: "myfile.dat")

var mem = Array(repeating: UInt8(0), count : 65536)
var count = 0;

for index in 0...(x!.count - 1) {
    mem[index] = x![index]
}

var z80 = CPU(rom : mem);
z80.debug = true;
z80.printRegisters()

while(!z80.halt){
    
    if(count > 30){
        break;
    }
    
    z80.parse()
    count += 1
}



z80.parse()

