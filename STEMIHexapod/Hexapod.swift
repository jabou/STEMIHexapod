//
//  STEMIHexapod.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 07/04/16.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit


public class Hexapod {
    
    var currPacket: Packet!
    var sendPacket: PacketSender!
    var ipAddress: String!
    var port: Int!
    let slidersArray: [UInt8] = [50, 25, 0, 0, 0, 50, 0, 0, 0, 0, 0]
    
    
    
    ///Initializes defoult connection with IP Address: _192.168.4.1_, and port: _80_
    public init(){
        self.ipAddress = "192.168.4.1"
        self.port = 80
        self.currPacket = Packet()
    }
    
    /**
    Initializes connection with custom IP Address and port
    
    - parameters:
        - connectWithIP: Takes IP Address *(def: 192.168.4.1)*
        - andPort: Takes port *(def: 80)*
    */
    public init(connectWithIP: String, andPort: Int){
        self.ipAddress = connectWithIP
        self.port = andPort
        self.currPacket = Packet()
    }
    
    public func setIP(newIP: String){
        self.ipAddress = newIP
    }
    
    public func connect(){
        self.sendPacket = PacketSender(hexapod: self)
        sendPacket.startSendingData()
    }
    
    public func disconnect(){
        sendPacket.stopSendingData()
    }
    
    public func goForward(){
        stopMoving()
        currPacket.power = 100
    }
    
    public func goBackward(){
        stopMoving()
        currPacket.power = 100
        //WARNING: FIX ANGLE!
        currPacket.angle = 180
    }
    
    public func goLeft(){
        stopMoving()
        currPacket.power = 100
        //WARNING: FIX ANGLE!
        currPacket.angle = 90 //-90
    }
    
    public func goRight(){
        stopMoving()
        currPacket.power = 100
        //WARNING: FIX ANGLE!
        currPacket.angle = 90
    }
    
    public func turnLeft(){
        stopMoving()
        //WARNING: fix angle!
        currPacket.rotation = 100 //-100
    }
    
    public func turnRight(){
        stopMoving()
        currPacket.rotation = 100
    }
    
    public func tiltForward(){
        setOrientationMode()
        //WARNING: fix accX
        currPacket.accX = 30 //-30
    }
    
    public func tiltBackward(){
        setOrientationMode()
        currPacket.accX = 30
    }
    
    public func tiltLeft(){
        setOrientationMode()
        //WARNING: fix accY
        currPacket.accY = 30 //-30
    }
    
    public func tiltRight(){
        setOrientationMode()
        currPacket.accY = 30
    }
    
    
    public func setJoystickParams(power: UInt8, angle: UInt8){
        currPacket.power = power
        currPacket.angle = angle
    }
    
    public func setJoystickParams(rotation: UInt8){
        currPacket.rotation = rotation
    }
    
    public func setAccX(x: UInt8){
        currPacket.accX = x
    }
    
    public func setAccY(y: UInt8){
        currPacket.accY = y
    }
    
    public func stopMoving(){
        currPacket.power = 0
        currPacket.angle = 0
        currPacket.rotation = 0
    }
    
    public func resetMovingParams(){
        currPacket.power = 0;
        currPacket.angle = 0;
        currPacket.rotation = 0;
        currPacket.staticTilt = 0;
        currPacket.movingTilt = 0;
        currPacket.onOff = 1;
        currPacket.accX = 0;
        currPacket.accY = 0;
    }
    
    public func setMovementMode(){
        currPacket.staticTilt = 0
        currPacket.movingTilt = 0
    }
    
    public func setRotationMode(){
        currPacket.staticTilt = 1
        currPacket.movingTilt = 0
    }
    
    public func setOrientationMode(){
        currPacket.staticTilt = 0
        currPacket.movingTilt = 1
    }
    
    public func turnOn(){
        currPacket.onOff = 1
    }
    
    public func turnOff(){
        currPacket.onOff = 2
    }
}
