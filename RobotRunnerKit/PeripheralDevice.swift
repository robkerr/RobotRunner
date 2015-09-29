//
//  PeripheralDevice.swift
//
//  Created by Rob Kerr on 3/21/15.
//  Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//

import Foundation
import CoreBluetooth

public class PeripheralDevice : NSObject {
    public var peripheral : CBPeripheral
    public var signalStrength : Float
    
    public init(peripheral: CBPeripheral, signalStrength: Float) {
        self.peripheral = peripheral
        self.signalStrength = signalStrength
    }
    
}