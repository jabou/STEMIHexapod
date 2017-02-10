//
//  CalibrationPackage.swift
//  STEMI
//
//  Created by Jasmin Abou Aldan on 25/09/2016.
//  Copyright © 2016 Jasmin Abou Aldan. All rights reserved.
//

import UIKit

enum WriteData: UInt8 {
    case no
    case yes
}

class CalibrationPackage {

    var writeToHexapod: UInt8 = WriteData.no.rawValue
    var legsValues: [UInt8] = [50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50,50]

    var bufferOutput: [UInt8] = []

    func toByteArray() -> [UInt8] {

        self.bufferOutput = []

        let pkt: [UInt8] = Array("LIN".utf8)
        self.bufferOutput.append(contentsOf: pkt)
        self.bufferOutput.append(contentsOf: legsValues)
        self.bufferOutput.append(writeToHexapod)

        return bufferOutput
    }

}
