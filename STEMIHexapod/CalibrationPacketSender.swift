//
//  CalibrationPacketSender.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 25/09/2016.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

enum CalibrationPacketSenderError: Error {
    case ipAddressError
}

protocol CalibrationPacketSenderDelegate: class {
    func calibrationConnectionLost()
    func calibrationConnectionActive()
}

class CalibrationPacketSender: NSObject, StreamDelegate {

    // Time in seconds
    let sendingInterval = 0.1

    var legsValuesArray: [UInt8] = []
    var hexapod: Hexapod
    var out: OutputStream?
    var openCommunication = true
    var connected = false
    var counter = 0
    weak var delegate: CalibrationPacketSenderDelegate?

    init(hexapod: Hexapod){
        self.hexapod = hexapod
    }

    func enterToCalibrationMode(_ complete: @escaping (Bool) -> Void) throws {
        guard let ipAddress = self.hexapod.ipAddress else {
            throw CalibrationPacketSenderError.ipAddressError
        }
        guard  let url = URL(string: "http://\(ipAddress)/linearization.bin") else {
            return
        }

        //Clear cache if .bin is saved
        URLCache.shared.removeAllCachedResponses()
        legsValuesArray = []

        //Configure for API call to STEMI
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        let session = URLSession(configuration: configuration)
        let request = URLRequest(url: url)
        let task: URLSessionTask = session.dataTask(with: request, completionHandler: { (data, response, error) in

            if let data = data {
                for index in 0..<data.count {
                    var value = UInt8(0)
                    (data as NSData).getBytes(&value, range: NSMakeRange(index,1))
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
        for (index, value) in legsValuesArray.enumerated() {
            do {
                try hexapod.setCalibrationValue(value, atIndex: index)
            } catch {
                print(error)
            }
        }

        sendData()
    }

    fileprivate func sendData() {
        let dataSendQueue: DispatchQueue = DispatchQueue(label: "Sending Queue", attributes: [])
        dataSendQueue.async(execute: {

            Stream.getStreamsToHost(withName: self.hexapod.ipAddress, port: self.hexapod.port, inputStream: nil, outputStream: &self.out)

            if let out = self.out {
                out.delegate = self
                out.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
                out.open()

                while self.openCommunication == true {

                    Thread.sleep(forTimeInterval: self.sendingInterval)

                    out.write(self.hexapod.calibrationPacket.toByteArray(), maxLength: self.hexapod.calibrationPacket.toByteArray().count)

                    if out.streamStatus == Stream.Status.open {
                        self.connected = true
                        self.counter = 0
                        self.delegate?.calibrationConnectionActive()
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
        Stream.getStreamsToHost(withName: self.hexapod.ipAddress, port: self.hexapod.port, inputStream: nil, outputStream: &self.out)
        if let out = self.out {
            out.delegate = self
            out.schedule(in: .main, forMode: RunLoopMode.defaultRunLoopMode)
            out.open()
            out.write(self.hexapod.calibrationPacket.toByteArray(), maxLength: self.hexapod.calibrationPacket.toByteArray().count)
            out.close()
        }
    }

    func stopSendingData(){
        self.openCommunication = false
    }

    fileprivate func dropConnection() {
        self.connected = false
        DispatchQueue.main.async {
            self.delegate?.calibrationConnectionLost()
        }
        self.stopSendingData()
    }

    @objc func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if aStream == out {
            switch eventCode {
            case Stream.Event.errorOccurred:
                break
            case Stream.Event.openCompleted:
                break
            case Stream.Event.hasSpaceAvailable:
                break
            default:
                break
            }
        }
    }
}
