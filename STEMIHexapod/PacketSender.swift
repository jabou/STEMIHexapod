//
//  PacketSender.swift
//  Pods
//
//  Created by Jasmin Abou Aldan on 24/04/16.
//
//

import UIKit

enum PacketSenderError: Error {
    case ipAddressError
}

protocol PacketSenderDelegate: class {
    func connectionLost()
    func connectionActive()
}

class PacketSender: NSObject, StreamDelegate {

    // Time in seconds
    let sendingInterval = 0.1

    var hexapod: Hexapod
    var out: OutputStream?
    var openCommunication = true
    var connected = false
    var counter = 0
    weak var delegate: PacketSenderDelegate?
    
    init(hexapod: Hexapod){
        self.hexapod = hexapod
    }

    func startSendingData() throws {

        guard let ipAddress = self.hexapod.ipAddress else {
            throw PacketSenderError.ipAddressError
        }
        guard let url = URL(string: "http://\(ipAddress)/stemiData.json") else {
            return
        }

        //Clear cache if json is saved
        URLCache.shared.removeAllCachedResponses()

        //Configure for API call to STEMI
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3
        let session = URLSession(configuration: configuration)
        let request = URLRequest(url: url)
        let task: URLSessionTask = session.dataTask(with: request, completionHandler: { (data, response, error) in

            //If there is data, try to read it
            if let data = data {
                //Try to read data from json
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let valide = jsonData["isValid"] as? Bool {
                            //JSON is OK - start sending data
                            if valide {
                                self.sendData()
                                self.delegate?.connectionActive()
                            } else {
                                self.dropConnection()
                            }
                        }
                    }
                }
                //Error with reading data
                catch {
                   self.dropConnection()
                }
            }
            //There is no data on this network -> error
            else {
                self.dropConnection()
            }
        })
        task.resume()
    }

    func stopSendingData(){
        self.openCommunication = false
    }

    fileprivate func dropConnection() {
        self.connected = false
        DispatchQueue.main.async {
            self.delegate?.connectionLost()
        }
        self.stopSendingData()
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

                    out.write(self.hexapod.currPacket.toByteArray(), maxLength: self.hexapod.currPacket.toByteArray().count)

                    if out.streamStatus == Stream.Status.open {
                        DispatchQueue.main.async {
                            self.delegate?.connectionActive()
                        }
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
