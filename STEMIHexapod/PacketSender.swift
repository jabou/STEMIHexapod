//
//  PacketSender.swift
//  Pods
//
//  Created by Jasmin Abou Aldan on 24/04/16.
//
//

protocol PacketSenderDelegate {
    func connectionLost()
}


class PacketSender {
    
    var hexapod: Hexapod
    var sendingInterval = 200
    var out: NSOutputStream?
    var input: NSInputStream?
    var openCommunication = true
    var connected = false
    var counter = 0
    var delegate: PacketSenderDelegate?
    
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

                if self.out!.streamStatus == NSStreamStatus.Open {
                    self.connected = true
                    self.counter = 0
                } else {
                    self.counter += 1
                    if self.counter == 10 {
                        self.connected = false
                        self.delegate?.connectionLost()
                        self.stopSendingData()
                        self.counter = 0
                    }
                }
            }
            
            self.out!.close()
            
        })
        
    }
    
    func stopSendingData(){
        self.openCommunication = false
    }
}
