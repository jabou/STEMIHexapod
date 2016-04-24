//
//  PacketSender.swift
//  Pods
//
//  Created by Jasmin Abou Aldan on 24/04/16.
//
//


class PacketSender {
    
    var hexapod: Hexapod
    var sendingInterval = 200
    var out: NSOutputStream?
    var openCommunication = true
    
    init(hexapod: Hexapod){
        self.hexapod = hexapod
    }
    
    init(hexapod: Hexapod, sendingInterval: Int){
        self.hexapod = hexapod
        self.sendingInterval = sendingInterval
    }
    
    func startSendingData(){
        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Sending Queue", nil)
        dispatch_async(dataSendQueue, {
            
            NSStream.getStreamsToHostWithName(self.hexapod.ipAddress, port: self.hexapod.port, inputStream: nil, outputStream: &self.out)
            
            self.out!.open()
            
            while self.openCommunication == true {
                
                NSThread.sleepForTimeInterval(0.2)
                
                self.out!.write(self.hexapod.currPacket.toByteArray(), maxLength: self.hexapod.currPacket.toByteArray().count)
                
            }
            self.out!.close()
            
        })
        
    }
    
    func stopSendingData(){
        self.openCommunication = false
    }
    
}
