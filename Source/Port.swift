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
       return ReadPortInternal(address, true)
    }
    
    func WritePort (_ address : UInt16, _ b : UInt8){
        return WritePortInternal(address, b, true)
    }
    
    func ReadPortInternal(_ address : UInt16, _ contend : Bool) -> UInt8 {
        if (contend){
            ContendPortPreio(address)
        }

        var readByte : UInt8 = UInt8(address >> 8)

        //Format Values
        var states = String(format: "%5d", z80.Tstates)
        var addressStr = String(format: "%04x", address)
        var readStr = String(format:"%02x", readByte)
        var combinedStr = states + " PR " + addressStr + " " + readStr + "\n"

        //Add to the events array
        events.append(combinedStr)

        if (contend) {
            ContendPortPostio(address)
        }

        return readByte
    }
    
    
    func WritePortInternal (_ address : UInt16, _ b : UInt8, _ contend : Bool){
        if contend {
		    p.ContendPortPreio(address)
	    }

        //Format Values
        var states = String(format: "%5d", z80.Tstates)
        var addressStr = String(format: "%04x", address)
        var byteStr = String(format: "%02x", b)
        var combinedStr = states + " PW " + addressStr + " " + byteStr + "\n"

        //Add to the events array
        events.append(combinedStr)

	    if contend {
		    p.ContendPortPostio(address)
	    }
    }
    
    
    func ContendPortPreio( _ address : UInt16){

        if (port & 0xc000) == 0x4000 {
            //Format Values
            var states = String(format: "%5d", z80.Tstates)
            var addressStr = String(format: "%04x", address)
            var combinedStr = states + " PC " + addressStr + "\n"

            //Add to the events array
            events.append(combinedStr)
	     }

         //Increment states
	     Tstates += 1
    }
    
    func ContendPortPostio( _ address : UInt16){
        if (address & 0x0001 == 1){
            if (address & 0xc000) == 0x4000{
                for index in 0...2{
                    //Format Values
                    var states = String(format: "%5d", z80.Tstates)
                    var addressStr = String(format: "%04x", address)
                    var combinedStr = states + " PC " + addressStr + "\n"

                    //Add to the events array
                    events.append(combinedStr)

                    contendPort(1)
                }
            } else {
                Tstates += 3
            }
        } 
        else {
              //Format Values
              var states = String(format: "%5d", z80.Tstates)
              var addressStr = String(format: "%04x", address)
              var combinedStr = states + " PC " + addressStr + "\n"

              //Add to the events array
             events.append(combinedStr)

            contendPort(3)
        }
    }
    
    
}
