//
//  InterfaceController.swift
//  Robot Runner WatchKit Extension
//
//  Created by Rob Kerr on 4/25/15.
//  Copyright (c) 2015 Mobile Toolworks LLC. All rights reserved.
//

import WatchKit
import Foundation
import CoreBluetooth
import RobotRunnerKit

enum RobotStatus {
    case Unknown, Running, Stopped
}

// The global discovery service used by all modules needing BTLE services
let sharedBTLEDiscoveryService = BTLEDiscoveryService();


class InterfaceController: WKInterfaceController, BTLEDiscoveryDelegate, BTLERobotPeripheralDelegate {

    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var tempLabel: WKInterfaceLabel!
    @IBOutlet weak var lightLabel: WKInterfaceLabel!
    @IBOutlet weak var button: WKInterfaceButton!
    @IBOutlet weak var image: WKInterfaceImage!
    

    var robotStatus : RobotStatus = RobotStatus.Unknown
    
    override func awakeWithContext(context: AnyObject?) {
        print(__FUNCTION__)
        
        super.awakeWithContext(context)
        
        robotStatus = RobotStatus.Unknown           // status Uknown when form is launched
        sharedBTLEDiscoveryService                  // Start the Bluetooth discovery process
        sharedBTLEDiscoveryService.delegate = self  // Set discovery delegate to self
    }
    
    override func didDeactivate() {
        print("=========== DEACTIVATING =================")
        
        // This method is called when watch view controller is no longer visible
        image.stopAnimating()
        
        // Disconnect from peripheral as app disappears from the foreground
        if let p = sharedBTLEDiscoveryService.peripheralService?.peripheral {
            print("=========== CALLING DISCONNECT =================")
            sharedBTLEDiscoveryService.disconnectPeripheral(p)
        } else {
            print("=========== UNABLE TO CALL DISCONNECT !!!!!!! =================")
        }
        
        super.didDeactivate()
    }
    
    @IBAction func buttonTapped() {
        
        if robotStatus == .Running {
            stopRobot()
        } else if robotStatus == .Stopped {
            startRobot()
        }
    }
    
    func foundPeripheral(peripheral: CBPeripheral, RSSI: NSNumber!) {
        print(__FUNCTION__)
        sharedBTLEDiscoveryService.connectPeripheral(peripheral)    // connect to 1st peripheral found
    }
    
    func peripheralConnected(peripheral: CBPeripheral) {
        print(__FUNCTION__)
        
        if let p = sharedBTLEDiscoveryService.peripheralService {
            p.delegate = self
        }
        
    }
    
    func temperatureUpdated(temperature: Int) {
        print("*************  ☀️\(temperature)℉  ******************")

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tempLabel.setText("☀️\(temperature)℉")
        })

    }
    
    func lightLevelUpdated(level: Int) {
        print("*************  🔦\(level)%  ******************")
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.lightLabel.setText("🔦\(level)%")
        })
        
    }
    
    func machineRunningUpdated(isRunning: Bool) {
        print(__FUNCTION__)
        
        var newRobotStatus : RobotStatus

        // translate to Enum
        if isRunning {
            newRobotStatus = RobotStatus.Running
        } else {
            newRobotStatus = RobotStatus.Stopped
        }

        // if reported status is not what we already know, then change the UI
        if robotStatus == RobotStatus.Unknown || newRobotStatus != robotStatus {
            
            if isRunning {
                setRobotRunning()
            } else {
                setRobotStopped()
            }
        }
    }
    
    func machineSentDataPackage(package: String) {
        print(__FUNCTION__)
        
    }

    override func willActivate() {
        print(__FUNCTION__)

        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        tempLabel.setText("--")
        lightLabel.setText("--")
        
        button.setBackgroundColor(UIColor.grayColor())
        button.setTitle("Not connected")
        image.setImageNamed("IdleRobot")
        
        robotStatus = RobotStatus.Unknown

        sharedBTLEDiscoveryService.startScanning()
        
    }

    
    func startRobot() {

        let animateDuration = 0.5
        
        // animate the robot starting
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.image.setImageNamed("StartingRobot")
            self.image.startAnimatingWithImagesInRange(NSRange(location: 0, length: 7), duration: animateDuration, repeatCount: 1)
        })
        
        
        
        // use GCD to set stopped status after animation is over
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animateDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            self.setRobotRunning()
            
            if let p = sharedBTLEDiscoveryService.peripheralService {
                p.writeByte(65) // send start command
            }
        })
    }
    
    func stopRobot() {

        let animateDuration = 0.5
        
        // animate the robot stopping
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.image.setImageNamed("StoppingRobot")
            self.image.startAnimatingWithImagesInRange(NSRange(location: 0, length: 7), duration: animateDuration, repeatCount: 1)
        })
        
        // use GCD to set stopped status after animation is over
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(animateDuration * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            self.setRobotStopped()
            
            if let p = sharedBTLEDiscoveryService.peripheralService {
                p.writeByte(66) // send stop command
            }
        })
        
    }
    
    func setRobotRunning() {
        robotStatus = .Running

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // set labels and button state
            self.statusLabel.setText("Running")
            self.button.setBackgroundColor(UIColor.redColor())
            self.button.setTitle("Stop")
            
            // animate the robot starting
            self.image.setImageNamed("RunningRobot")
            self.image.startAnimatingWithImagesInRange(NSRange(location: 0, length: 35), duration: 4, repeatCount: 0)
        })

    }
    
    func setRobotStopped() {
        robotStatus = .Stopped

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.statusLabel.setText("Stopped")
            self.button.setBackgroundColor(UIColor.greenColor())
            self.button.setTitle("Start")
        })
    }
    
}
