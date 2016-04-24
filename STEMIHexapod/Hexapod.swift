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
    
    /**
     Change IP Address to new one. By default this is set to _192.168.4.1_
     
     - parameters:
       - newIP: Takes new IP Address
     */
    public func setIP(newIP: String){
        self.ipAddress = newIP
    }
    
    /**
     Establish connection with Hexapod. After connection is established, it sends new packet every 200ms.
     */
    public func connect(){
        self.sendPacket = PacketSender(hexapod: self)
        sendPacket.startSendingData()
    }
    
    /**
     Stops sending data to Hexapod, and closes connection.
     */
    public func disconnect(){
        sendPacket.stopSendingData()
    }
    
    /**
     Moves Hexapod forward with max power.
     */
    public func goForward(){
        stopMoving()
        currPacket.power = 100
    }
    
    /**
     Moves Hexapod backward with max power.
     */
    public func goBackward(){
        stopMoving()
        currPacket.power = 100
        currPacket.angle = 90
    }
    
    /**
     Moves Hexapod left with max power.
     */
    public func goLeft(){
        stopMoving()
        currPacket.power = 100
        currPacket.angle = 210
    }
    
    /**
     Moves Hexapod right with max power.
     */
    public func goRight(){
        stopMoving()
        currPacket.power = 100
        currPacket.angle = 45
    }
    
    /**
     Rotate Hexapod left with max power.
     */
    public func turnLeft(){
        stopMoving()
        currPacket.rotation = 156
    }
    
    /**
     Rotate Hexapod right with max power.
     */
    public func turnRight(){
        stopMoving()
        currPacket.rotation = 100
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod forward.
     */
    public func tiltForward(){
        setOrientationMode()
        currPacket.accX = 226
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod backward.
     */
    public func tiltBackward(){
        setOrientationMode()
        currPacket.accX = 30
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod left.
     */
    public func tiltLeft(){
        setOrientationMode()
        currPacket.accY = 226
    }
    
    /**
     Turns orientation mode mode on, and tilt Hexapod right.
     */
    public func tiltRight(){
        setOrientationMode()
        currPacket.accY = 30
    }
    
    /**
     Sets parameters for moving Hexapod with custom Joystick. This is intended for moving the Hexapod: forward, backward , left and right.
     
     _It is proposed for user to use a circular joystick!_
     
     **angle values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets angle as shown:
     - For angle 0 - 180 you can use 0-90 (original devided by 2)
     - For angle 180 - 360 you can use 166-255 (this can be represented like value from -180 to 0. Logic is same: 255 + (original devided by 2))
     
     - parameters:
       - power: Takes values for movement speed (_Values must be: 0-100_)
       - angle: Takes values for angle of moving (_Values can be: 0-255, look at the description!_)
     */
    public func setJoystickParams(power: UInt8, angle: UInt8){
        currPacket.power = power
        currPacket.angle = angle
    }
    
    /**
     Sets parameters for moving Hexapod with custom Joystick. This is intended for rotating the Hexapod left and right.
     
     _It is proposed for user to use a linear (left to right) joystick!_
     
     **angle values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets rotation as shown:
     - For rotate to right you can use values 0 - 100
     - For rotate to left you can use 255-156 (this can be represented like value from 0 to -100 as 255 - position.)
     
     - parameters:
       - rotation: Takes values for rotation speed (_Values must be: 0-255, look at the description!_)
     */
    public func setJoystickParams(rotation: UInt8){
        currPacket.rotation = rotation
    }
    
    /**
     Sets parameters for tilding Hexapod in X direction.
     
     **This value must be max 40!**
     
     **x values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets x rotation as shown:
     - For tilt forward you can use values 0 - 216 (this can be represented like value from 0 to -100 as 255 - position.)
     - For tilt backward you can use 0 - 100.
     
     - parameters:
       - x: Takes values for X tilting (_Values must be: 0-255, look at the description!_)
     */
    public func setAccX(x: UInt8){
        currPacket.accX = x
    }
    
    /**
     Sets parameters for tilding Hexapod in Y direction.
     
     **This value must be max 40!**
     
     **y values:** Because Byte values are only positive numbers from 0 to 255, Hexapod gets y rotation as shown:
     - For tilt left you can use values 0 - 216 (this can be represented like value from 0 to -100 as 255 - position.)
     - For tilt right you can use 0 - 100.
     
     - parameters:
       - x: Takes values for Y tilting (_Values must be: 0-255, look at the description!_)
     */
    public func setAccY(y: UInt8){
        currPacket.accY = y
    }
    
    /**
     Stops Hexapod by setting power, angle and rotation to 0.
     */
    public func stopMoving(){
        currPacket.power = 0
        currPacket.angle = 0
        currPacket.rotation = 0
    }
    
    /**
     Resets all Hexapod moving and tilt values to 0.
     */
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
    
    /**
     In this mode, Hexapod can move forward, backward, left and right, and it can rotate itself to left and right.
     
     Accelerometer is off.
     */
    public func setMovementMode(){
        currPacket.staticTilt = 0
        currPacket.movingTilt = 0
    }
    
    /**
     In this mode, Hexapod can tilt backward, forward, left and right, and rotate left and right by accelerometer and joystick in place without moving.
     
     Accelerometer is on.
     */
    public func setRotationMode(){
        currPacket.staticTilt = 1
        currPacket.movingTilt = 0
    }
    
    /**
     This is combination of rotation and movement mode, Hexapod can move forward, backward, left and right, and it can rotate itself to left and right. Furthermore the Hexapod can tilt forward, backward, left and right by accelerometer.
     
     Accelerometer is on.
     */
    public func setOrientationMode(){
        currPacket.staticTilt = 0
        currPacket.movingTilt = 1
    }
    
    /**
     Puts Hexapod in standby.
     */
    public func turnOn(){
        currPacket.onOff = 1
    }
    
    /**
     Puts Hexapod out from standby.
     */
    public func turnOff(){
        currPacket.onOff = 0
    }
}
