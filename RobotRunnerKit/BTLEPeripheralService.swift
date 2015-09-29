//*************************************************************************************************
//
//          File:           BTLEPeripheralService.swift
//          Project:        BTLEDemo
//          Description:    Class that manages an active connection with a BTLE peripheral
//                          This class exists as long as an active connection is being maintained.
//
//                          The instantion of this class is "owned" by the BTLEDiscoveryService class,
//                          which is created into global scope at the top of BTLEDiscoveryService.swift
//
//          Date:           Created by Rob Kerr on 3/28/15.
//          Copyright:      Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//
//**************************************************************************************************
import Foundation
import CoreBluetooth


// UUIDs for Servcies and characteristics of interest
let ServiceUUID = CBUUID(string: "713D0000-503E-4C75-BA94-3148F18D941E")    // The service on the peripheral we care about
let TxUUID = CBUUID(string: "713D0002-503E-4C75-BA94-3148F18D941E")         // Tx is data receieved from the pheripheral to us
let RxUUID = CBUUID(string: "713D0003-503E-4C75-BA94-3148F18D941E")         // Rx is data sent from us to the peripheral

// Notification key this app is sent when there's a servie change notification
public let ServiceChangedStatusNotification = "ServiceChangedStatusNotification"


// Delegate methods that notify the application's controller(s) what's happening in BT land
public protocol BTLERobotPeripheralDelegate {
    func temperatureUpdated(temperature: Int)
    func lightLevelUpdated(level: Int)
    func machineRunningUpdated(isRunning: Bool)
    func machineSentDataPackage(package: String)
}


// Define the class
public class BTLEPeripheralService: NSObject, CBPeripheralDelegate {
    
    var logLevel : BTLEServiceLogLevel = .Verbose
    public var peripheral: CBPeripheral?             // The perhipheral this class has a connection with
    var RxCharacteristic: CBCharacteristic?   // Characteristic used by the peripheral to RECEIVE data FROM THIS CLASS
    var TxCharacteristic: CBCharacteristic?   // Characteristic used by the peripheral to SEND data TO THIS CLASS
    
    var machineRunning : Bool! = false
    var machineTemperature : Int! = 0
    var machineLightLevel : Int! = 0
  
    public var delegate : BTLERobotPeripheralDelegate?
    
    //*******************************************************************
    //
    //    Function: initWithPeripheral
    // Description: Construct this object given a known CBPeripheral
    //
    //*******************************************************************
    public init(initWithPeripheral peripheral: CBPeripheral) {
        super.init()

        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        self.peripheral = peripheral
        self.peripheral?.delegate = self
    }
  
    //*******************************************************************
    //
    //    Function: deinit
    // Description: Nils the CBPeripheral reference and notify the OS
    //              we're no longer interested in receiving updates
    //              about this perhipheral
    //
    //*******************************************************************
    deinit {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        if peripheral != nil {
            peripheral = nil
        }
        
        // Deallocating therefore send notification
        self.InformNotificationCenter(false)
    }
  
    //*******************************************************************
    //
    //    Function: startDiscoveringServices
    // Description: Destructore that nils the CBPeripheral reference and
    //              notifies the OS that we're no longer interested in
    //              receiving updates about this perhipheral
    //
    //*******************************************************************
    func startDiscoveringServices() {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        self.peripheral?.discoverServices([ServiceUUID])
    }
  
  // Mark: - CBPeripheralDelegate
  
    //*******************************************************************
    //
    //    Function: didDiscoverServices
    // Description: callback to let us know the service we're interested
    //              in has been discovered.  If all appears OK, we should
    //              trigger a discover of characteristics
    //
    //*******************************************************************
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        let interestingCharacteristics: [CBUUID] = [RxUUID, TxUUID]  // explicitely limit what characteristics are interesting

        if (peripheral != self.peripheral) {
            // Wrong Peripheral
            if logLevel == .Verbose {
                print("didDiscoverServcies: Wrong peripheral")
            }
            return
        }

        if (error != nil) {
            if logLevel == .Verbose {
                print("didDiscoverServcies: error detected and ignored")
            }
            return
        }

        if ((peripheral.services == nil) || (peripheral.services!.count == 0)) {
            // No Services
            if logLevel == .Verbose {
                print("didDiscoverServices: service count is zero")
            }
            return
        }

        for service in peripheral.services! {
            if logLevel == .Verbose {
                print("didDiscoverServcies: found service")
            }
            
            if service.UUID == ServiceUUID {
                if logLevel == .Verbose {
                    print("didDiscoverServcies: found expected service")
                }
                peripheral.discoverCharacteristics(interestingCharacteristics, forService: service )
            }
        }
    }
  
    //*******************************************************************
    //
    //    Function: didDiscoverCharacteristicsForService
    // Description: callback to let us know one or more of the
    //              characteristics we're interested in were discovered.
    //
    //*******************************************************************
    public func peripheral(peripheral: CBPeripheral,
                didDiscoverCharacteristicsForService service: CBService,
                error: NSError?) {

        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
                    
        if self.peripheral == nil {
            if logLevel == .Verbose {
                print("***************self.peripheral is nil!*****************")
                return;
            }
        }
                    
        if (peripheral != self.peripheral) {
            if logLevel == .Verbose {
                print("wrong peripheral")
            }
            // Wrong Peripheral
            return
        }

        if (error != nil) {
            if logLevel == .Verbose {
                print("didDiscoverCharacteristicsForService: found and ignored error")
            }
            return
        }

        for characteristic in service.characteristics! {
            if logLevel == .Verbose {
                print(">>> Found a characteristic")
            }

            if characteristic.UUID == RxUUID {
                if logLevel == .Verbose {
                    print("            Found Rx characteristic")
                }
                self.RxCharacteristic = (characteristic )
                peripheral.setNotifyValue(true, forCharacteristic: characteristic )
                self.InformNotificationCenter(true)
            }
            if characteristic.UUID == TxUUID {
                if logLevel == .Verbose {
                    print("             Found Tx characteristic")
                }
                self.TxCharacteristic = (characteristic )
                peripheral.setNotifyValue(true, forCharacteristic: characteristic )
                self.InformNotificationCenter(true)
            }
        }
    }
    
    //*******************************************************************
    //
    //    Function: didUpdateNotificationStateForCharacteristic
    // Description: callback to let us know the notification state for
    //              a characteristic we're monitorig has been updated
    //
    //*******************************************************************
    public func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
    }
    
    //*******************************************************************
    //
    //    Function: didUpdateValueForCharacteristic
    // Description: callback to let us know the value of a characteristic
    //              we're monitoring has been udpated
    //
    //*******************************************************************
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        if error != nil {
            if logLevel == .Verbose {
                print("Error reading value for characteristic: \(error!.description)")
            }
        } else {
            if characteristic == self.TxCharacteristic {
                
            }
            
            if characteristic.value != nil {
                /*
               println(characteristic.value)
                
                
                let nsd = characteristic.value
                
                
                if logLevel == .Verbose {
                    println("Received value: \(value)")
                }
                */
            
                // 1st byte will be the command from the device
                // 1=Send Machine Status. The 2nd byte will be boolean (0 or 1)
                // 2=Send Temperature. 2nd Byte will be the temp (as an unsigned 0-255)
                // 3=Send Light Level. 2nd Byte will be the light level from 0-100
                // 4=Send data package. String begins from byte #2 and continues until string ends
                
                /*
                var command : UInt8 = 0
                characteristic.value.getBytes(&command, length: sizeofValue(command))
                */
                
                let count = characteristic.value!.length / sizeof(UInt8)
                
                if (count > 1) {
                    var array = [UInt8](count:count, repeatedValue:0)
                    characteristic.value!.getBytes(&array, length: count * sizeof(UInt8))
                    
                    switch (array[0]) {
                    case 1:
                        if array[1] == 0 {
                            self.machineRunning = false;
                        } else {
                            self.machineRunning = true;
                        }
                        print("Received new machine running status: \(self.machineRunning)")
                        
                        if let d = delegate {
                            d.machineRunningUpdated(self.machineRunning)
                        }
                        
                        break
                        
                    case 2:
                        self.machineTemperature = Int(array[1]);
                        print("Received new machine temperature: \(self.machineTemperature)")
                        
                        if let d = delegate {
                            d.temperatureUpdated(self.machineTemperature)
                        }

                        break
                        
                    case 3:
                        self.machineLightLevel = Int(array[1]);
                        print("Received new light level: \(self.machineLightLevel)")
                        
                        if let d = delegate {
                            d.lightLevelUpdated(self.machineLightLevel)
                        }
                        
                        break
/*
                    case 4:
                        var str = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)?.substringFromIndex(1)
                        if let d = delegate {
                            if let s = str {
                                d.machineSentDataPackage(s)
                            }
                            
                        }
*/
                    default:
                        if logLevel == .Verbose {
                            print("Received some data from BTLE, but the 1st byte of '\(array[0])' didn't match a recognized command")
                        }
                        break
                    }
                }
                
                
                
            }
        }
    }
  
  // Mark: - Private
  
    //*******************************************************************
    //
    //    Function: writeByte
    // Description: function explosed to callers to write a byte to the
    //              connected peripheral
    //
    //*******************************************************************
    public func writeByte(position: UInt8) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }

        // See if characteristic has been discovered before writing to it
        if self.RxCharacteristic == nil {
            if logLevel == .Verbose {
                print("ERROR: trying to write a byte when Rx characteristic is not discovered")
            }
            return
        }

        // Copy the value to write into an NSData stream with length of 1
        var positionValue = position
        let data = NSData(bytes: &positionValue, length: sizeof(UInt8))

        if let periph = self.peripheral {
            if logLevel == .Verbose {
                print("Writing value: \(positionValue)")
            }
            
            periph.writeValue(data, forCharacteristic: self.RxCharacteristic!, type: CBCharacteristicWriteType.WithoutResponse)
        } else {
            if logLevel == .Verbose {
                print("Peripheral is nil, cannot write to it")
            }
        }

    }
  
    //*******************************************************************
    //
    //    Function: InformNotificationCenter
    // Description: Let NSNotificationCenter know whether we're connected
    //              to the peripheral or not so it knows whether to send
    //              updates to us
    //
    //*******************************************************************
    func InformNotificationCenter(isBluetoothConnected: Bool) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }

        let connectionDetails = ["isConnected": isBluetoothConnected]
        NSNotificationCenter.defaultCenter().postNotificationName(ServiceChangedStatusNotification, object: self, userInfo: connectionDetails)
    }
  
}