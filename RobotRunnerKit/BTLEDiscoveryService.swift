//*************************************************************************************************
//
//          File:           BTLEDiscoveryService.swift
//          Project:        BTLEDemo
//          Description:    This class manages the discovery process for BTLE, encapsulating the
//                          plumbing, peripheral references and queing structures need.
//
//                          A single instantiation of this class is used, and is instantiated at
//                          the top of this class
//
//          Date:           Created by Rob Kerr on 3/28/15.
//          Copyright:      Copyright (c) 2015 Mobile Toolworks, LLC. All rights reserved.
//
//**************************************************************************************************
import Foundation
import CoreBluetooth

public enum BTLEServiceLogLevel {
    case None, Verbose
}


// Delegate methods that notify the application's controller(s) what's happening in BT land
public protocol BTLEDiscoveryDelegate {
    func foundPeripheral(peripheral: CBPeripheral, RSSI: NSNumber!)
    func peripheralConnected(peripheral: CBPeripheral)
}

// Define the class
public class BTLEDiscoveryService: NSObject, CBCentralManagerDelegate {
  
    var logLevel : BTLEServiceLogLevel = .Verbose
    public var delegate : BTLEDiscoveryDelegate?
    
    private var centralManager: CBCentralManager?
    private var peripheralBLE: CBPeripheral?
    
    //*******************************************************************
    //
    //    Function: init
    // Description: Allocate queue & create the single CBCentralManager
    //
    //*******************************************************************
    public override init() {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        super.init()

        let centralQueue = dispatch_queue_create("com.mobiletoolworks.BTLEDemo", DISPATCH_QUEUE_SERIAL)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
  
    //*******************************************************************
    //
    //    Function: startScanning
    // Description: instruct CBCentralManager to start scanning for us.
    //              pass in ServiceUUID so we limit radio use and don't
    //              find out about services we don't care for
    //
    //*******************************************************************
    public func startScanning() {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }

        if let central = centralManager {
            print("&&&&&&&&&&&&& Start scanning &&&&&&&&&&&&&&&&&")
            
            central.scanForPeripheralsWithServices([ServiceUUID], options: nil)
        }
    }
  
    //*******************************************************************
    //
    //    Function: peripheralService/didSet
    // Description: When the peripheralService instance is set, instruct
    //              that service to start discovering characteristics
    //              find out about services we don't care for
    //
    //*******************************************************************
    public var peripheralService: BTLEPeripheralService? {
        didSet {
            if let service = self.peripheralService {
                service.startDiscoveringServices()
            }
        }
    }
  
  // MARK: - CBCentralManagerDelegate
  
    //*******************************************************************
    //
    //    Function: didDiscoverPeripheral
    // Description: CBCentralManager callback to let us know that a
    //              peripheral with one of the services we care about
    //              has been found. 
    //
    //              We respond by passing the info on to our Controller
    //              delegate
    //
    //*******************************************************************
    public func centralManager(central: CBCentralManager,
                didDiscoverPeripheral peripheral: CBPeripheral,
                advertisementData: [String : AnyObject], RSSI: NSNumber) {

        if logLevel == .Verbose {
            print(__FUNCTION__)
        }

        if delegate != nil {
            delegate?.foundPeripheral(peripheral, RSSI: RSSI)
        }
    }

    //*******************************************************************
    //
    //    Function: connectPeripheral
    // Description: Call by an outside controller to connect to a
    //              specific peripheral.
    //
    //              Normally the caller has received a list of peripherals
    //              via the foundPeripheal delegate method, and a user has
    //              selected that peripheral from a list
    //
    //*******************************************************************
    public func connectPeripheral(peripheral: CBPeripheral!) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        // Be sure to retain the peripheral or it will fail during connection.

        // Validate peripheral information
        if ((peripheral == nil) || (peripheral.name == nil) || (peripheral.name == "")) {
            if logLevel == .Verbose {
                print("Peripheral nas no name or it is nil")
            }
            return
        }

        // If not already connected to a peripheral, then connect to this one
        if ((self.peripheralBLE == nil) || (self.peripheralBLE?.state == CBPeripheralState.Disconnected)) {
            
            // Connect to peripheral
            if logLevel == .Verbose {
                print("Attempt to connect to peripheral")
            }

            // Retain the peripheral before trying to connect
            self.peripheralBLE = peripheral

            // Reset service (this will call the deinit() to reset an old connection, if there is one)
            self.peripheralService = nil


            if let cm = self.centralManager {
                print("About to call connectPeripheral")
                cm.connectPeripheral(peripheral, options: nil)
                print("After call to connectPeripheral")
            }
        }
        
        
        if let central = centralManager {
            // Stop scanning for new devices
            if logLevel == .Verbose {
                print("&&&&&&&&&&&&& Stop scanning &&&&&&&&&&&&&&&&&")
            }
            
            central.stopScan()
        }


    }
    
    //*******************************************************************
    //
    //    Function: disconnectPeripheral
    // Description: Programatically disconnect the peripheral
    //
    //*******************************************************************
    public func disconnectPeripheral(peripheral: CBPeripheral!) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
        
        if peripheral == nil {
            if logLevel == .Verbose {
                print("peripheral is already nil, just returning")
            }
            return
        }
        if let cm = self.centralManager {
            if logLevel == .Verbose {
                print("calling cancelPeripheralConnection")
            }
            cm.cancelPeripheralConnection(peripheral)
        }
    }
    
    //*******************************************************************
    //
    //    Function: didConnectPeripheral
    // Description: CBCentralManager callback to let us know we have 
    //              successfully connected to a peripheral
    //
    //*******************************************************************
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {

        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
/*
        if (peripheral == nil) {
            if logLevel == .Verbose {
                print("Peripheral is nil, returning silently")
            }
            return;
        }
*/
        // Create new service class
        if (peripheral == self.peripheralBLE) {
            if logLevel == .Verbose {
                print("Creating service class")
            }

            self.peripheralService = BTLEPeripheralService(initWithPeripheral: peripheral)
            
            if delegate != nil {
                delegate?.peripheralConnected(peripheral)
            }
        }
    }
  
    //*******************************************************************
    //
    //    Function: didDisconnectPeripheral
    // Description: CBCentralManager callback to let us know we have
    //              successfully disconnected from a peripheral
    //
    //*******************************************************************
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {

        if logLevel == .Verbose {
            print(__FUNCTION__)
        }
/*
        if (peripheral == nil) {
            return;
        }
*/
        // See if it was our peripheral that disconnected
        if (peripheral == self.peripheralBLE) {
            print("&&&&&&&&&&&&&  CLEARING DEVICES IN DISCOVERYSERVICE &&&&&&&&&&&&&&&&&&&")
            
            clearDevices()
        }

        // Start scanning for new devices
//        self.startScanning()
    }
  
  // MARK: - Private
  
    //*******************************************************************
    //
    //    Function: clearDevices
    // Description: CBCentralManager callback to let us know we have
    //              successfully disconnected from a peripheral
    //
    //*******************************************************************
    public func clearDevices() {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }

        self.peripheralService = nil
        self.peripheralBLE = nil
    }
  
    //*******************************************************************
    //
    //    Function: centralManagerDidUpdateState
    // Description: CBCentralManager callback to let us its state has been
    //              updated.  Typically this is called when BlueTooth is 
    //              powered off/not available, or some global bluetooth
    //              status change happens
    //
    //*******************************************************************
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        if logLevel == .Verbose {
            print(__FUNCTION__)
        }

        switch (central.state) {
            case CBCentralManagerState.PoweredOff:
                if logLevel == .Verbose {
                    print("Powered Off")
                }
            self.clearDevices()

            case CBCentralManagerState.Unauthorized:
                // Indicate to user that the iOS device does not support BLE.
                if logLevel == .Verbose {
                    print("BLE not supported")
                }
                break

            case CBCentralManagerState.Unknown:
                // Wait for another event
                if logLevel == .Verbose {
                    print("Unknown")
                }
                break

            case CBCentralManagerState.PoweredOn:
                if logLevel == .Verbose {
                    print("Powered On")
                }
                self.startScanning()

            case CBCentralManagerState.Resetting:
                if logLevel == .Verbose {
                    print("Powered Resetting")
                }
                self.clearDevices()

                case CBCentralManagerState.Unsupported:
                if logLevel == .Verbose {
                    print("Unsupported")
                }
                break
        }
    }
}
