//
//  CalibrationPacketSender.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 25/09/2016.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit


class CalibrationPacketSender: NSObject, NSStreamDelegate {

    var legsValuesArray: [UInt8] = []
    var hexapod: Hexapod
    var sendingInterval = 200
    var out: NSOutputStream?
    var openCommunication = true
    var connected = false
    var counter = 0


    init(hexapod: Hexapod){
        self.hexapod = hexapod
    }

    func enterToCalibrationMode(complete: (Bool) -> Void) {
        //Clear cache if .bin is saved
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        legsValuesArray = []

        //Configure for API call to STEMI
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 3
        let session = NSURLSession(configuration: configuration)
        let request = NSURLRequest(URL: NSURL(string: "http://\(self.hexapod.ipAddress)/linearization.bin")!)
        let task: NSURLSessionTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in

            if let data = data {
                for index in 0..<data.length {
                    var value = UInt8(0)
                    data.getBytes(&value, range: NSMakeRange(index,1))
                    if index > 2 && index < 21 {
                        self.legsValuesArray.append(value)
                    }
                }
                complete(true)
                self.sendPackage()
            } else {
                #if DEVELOPMENT
                    print("Error in reading data. Check if file is present on Hexapod")
                #endif
            }

        })
        task.resume()
    }

    func sendPackage() {
        for (index, value) in legsValuesArray.enumerate() {
            do {
                try hexapod.setCalibrationValue(value, atIndex: index)
            } catch {
                print(error)
            }
        }

        sendData()
    }

    private func sendData() {
        let dataSendQueue: dispatch_queue_t = dispatch_queue_create("Sending Queue", nil)
        dispatch_async(dataSendQueue, {

            NSStream.getStreamsToHostWithName(self.hexapod.ipAddress, port: self.hexapod.port, inputStream: nil, outputStream: &self.out)

            if let out = self.out {
                out.delegate = self
                out.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                out.open()

                while self.openCommunication == true {

                    NSThread.sleepForTimeInterval(0.2)

                    out.write(self.hexapod.calibrationPacket.toByteArray(), maxLength: self.hexapod.calibrationPacket.toByteArray().count)

                    if out.streamStatus == NSStreamStatus.Open {
                        self.connected = true
                        self.counter = 0
                    } else {
                        self.counter += 1
                        if self.counter == 10 {
                            self.dropConnection()
                            self.counter = 0
                        }
                    }
                }
                self.out!.close()
            }
            
        })
    }

    func sendOnePackage() {
        NSStream.getStreamsToHostWithName(self.hexapod.ipAddress, port: self.hexapod.port, inputStream: nil, outputStream: &self.out)
        if let out = self.out {
            out.delegate = self
            out.scheduleInRunLoop(.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            out.open()
            out.write(self.hexapod.calibrationPacket.toByteArray(), maxLength: self.hexapod.calibrationPacket.toByteArray().count)
            out.close()
        }
    }

    func stopSendingData(){
        self.openCommunication = false
    }

    private func dropConnection() {
        self.connected = false
//        dispatch_async(dispatch_get_main_queue()) {
//            self.delegate?.connectionLost()
//        }
        self.stopSendingData()
    }

    @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if aStream == out {
            switch eventCode {
            case NSStreamEvent.ErrorOccurred:
                break
            case NSStreamEvent.OpenCompleted:
                break
            case NSStreamEvent.HasSpaceAvailable:
                break
            default:
                break
            }
        }
    }
}
