//
//  Memory.swift
//  Z80
//
//  Created by Harsh Mistry on 2017-04-17.
//  Copyright © 2017 Harsh Mistry  Inc. All rights reserved.
//
import Foundation

    //Data goes here
    var data_array = Array(repeating: UInt8(0), count: 65536)
    
    //Data Map 
    var data_map : [UInt16 : UInt8] = [0  : 0]

//Define the memory class
class Memory {    
    //var z80 : *Z80
    
    func ReadByte (_ address : UInt16) -> UInt8 {
        //Format Values
        var states = String(format: "%5d", Tstates)
        var addressStr = String(format: "%04x", address)
        var combinedStr = states + " MC " + addressStr + "\n"

        //append events
        events.append(combinedStr)

        contendMemory(address, 3)

        return ReadByteInternal(address)
    }
    
    func ReadByteInternal (_address : UInt16) -> UInt8 {
          //Format Values
        var states = String(format: "%5d", Tstates)
        var addressStr = String(format: "%04x", address)
        var readStr = String(format:"%02x", data_array[Int(address)])
        var combinedStr = states + " MR " + addressStr + " " + readStr + "\n"

        //append events
        events.append(combinedStr)

        //Return memory 
        return data_array[Int(address)]
    }
    
    func WriteByte (_ address : UInt16, _ value : UInt8) {
          //Format Values
        var states = String(format: "%5d", Tstates)
        var addressStr = String(format: "%04x", address)
        var combinedStr = states + " MC " + addressStr + "\n"

        //append events
        events.append(combinedStr)

        contendMemory(address, 3)

        return WriteByteInternal(address, value)
    }
    
    func WriteByteInternal (_ address : UInt16, _ value : UInt8) {
       //Format Values
        var states = String(format: "%5d", Tstates)
        var addressStr = String(format: "%04x", address)
        var readStr = String(format:"%02x", value)
        var combinedStr = states + " MW " + addressStr + " " + readStr + "\n"

         //append events
        events.append(combinedStr)

        //Add memmory 
        data_array[int(address)] = value
        data_array[int(address)] = value

        if b == 0{
            dirtyMemory[address] = true
        } 
        
    }
    
      func ContentRead(_ address : UInt16, _ time : Int){
        //Format Values
        var states = String(format: "%5d", Tstates)
        var addressStr = String(format: "%04x", address)
        var combinedStr = states + " MC " + addressStr + "\n"

        //append events
        events.append(combinedStr)

        contendMemory(address, time)
    }
    
    func ContentReadNoMreq(_ address : UInt16, _ time : Int){
        ContentRead(addres, time)

    }
    
    func ContentReadNoMreq_loop(_ address : UInt16, _ time : Int, _ count : UInt){
        for index in 0...time  {
            ContentReadNoMreq(addres, time)
        }
    }
    
    func Read(_ address : UInt16) -> UInt8 {
       return data_array[Int(address)]
    }
    
    func Write (_ address : UInt16, _ value : UInt8, _ protectRom : Bool){
        data_array[Int(address)] = value 
        data_map[Int(addres)] = value
    }
    
    func Data() -> [UInt8]{
        return data_array
    }

}
