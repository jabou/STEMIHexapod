//
//  STEMICommunicator.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/04/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit


class STEMIHexapod {
    
    //handle this!
    
    //var mainJoystick: UIViewController!
    //var leftJoystick: UIViewController!
    //var rightJoystick: UIViewController!
    
    var openCommunication: Bool = false
    var out: NSOutputStream?
    var outForiOS7: Unmanaged<CFWriteStream>?
    var bufferOutput: [UInt8] = []
    var ipAddress: String!
    let slidersArray: [UInt8] = [50, 25, 0, 0, 0, 50, 0, 0, 0, 0, 0]
    
    init(){
        
    }
    
    init(connectWithIP: String, andPort: Int){
        self.ipAddress = connectWithIP
    }
    
    func dataSend(){

        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Sending Queue", nil)
        dispatch_async(dataSendQueue, {
            
            NSStream.getStreamsToHostWithName(self.ipAddress, port: 80, inputStream: nil, outputStream: &self.out)
            self.out!.open()
            self.bufferOutput = []
            
            while self.openCommunication == true {
                    
                NSThread.sleepForTimeInterval(0.2)
                    
                let pkt: [UInt8] = Array("PKT".utf8)
                self.bufferOutput.appendContentsOf(pkt)
                //self.bufferOutput.append(self.leftJoystick.getPower())
                //self.bufferOutput.append(self.leftJoystick.getAngle())
                //self.bufferOutput.append(self.rightJoystick.getRotation())
                //self.bufferOutput.append(self.mainJoystick.getStaticTilt())
                //self.bufferOutput.append(self.mainJoystick.getMovingTilt())
                //self.bufferOutput.append(1)
                //self.bufferOutput.append(self.mainJoystick.getAccelerometerX())
                //self.bufferOutput.append(self.mainJoystick.getAccelerometerY())
                self.bufferOutput.appendContentsOf(self.slidersArray)
                    
                self.out!.write(self.bufferOutput, maxLength: self.bufferOutput.count)
                    
                self.bufferOutput = []
            }
            self.out!.close()
                
        })
    }
    
}
