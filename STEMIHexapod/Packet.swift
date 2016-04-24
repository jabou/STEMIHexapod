//
//  Packet.swift
//  Pods
//
//  Created by Jasmin Abou Aldan on 24/04/16.
//
//


class Packet{
    
    var power: UInt8 = 0
    var angle: UInt8 = 0
    var rotation: UInt8 = 0
    var staticTilt: UInt8 = 0
    var movingTilt: UInt8 = 0
    var onOff: UInt8 = 1;
    var accX: UInt8 = 0;
    var accY: UInt8 = 0;
    let slidersArray: [UInt8] = [50, 25, 0, 0, 0, 50, 0, 0, 0]
    
    var bufferOutput: [UInt8] = []

    
    func toByteArray() -> [UInt8] {
        
        self.bufferOutput = []
        
        let pkt: [UInt8] = Array("PKT".utf8)
        self.bufferOutput.appendContentsOf(pkt)
        self.bufferOutput.append(power)
        self.bufferOutput.append(angle)
        self.bufferOutput.append(rotation)
        self.bufferOutput.append(staticTilt)
        self.bufferOutput.append(movingTilt)
        self.bufferOutput.append(onOff)
        self.bufferOutput.append(accX)
        self.bufferOutput.append(accY)
        self.bufferOutput.appendContentsOf(self.slidersArray)
        
        return bufferOutput
    }

    
}